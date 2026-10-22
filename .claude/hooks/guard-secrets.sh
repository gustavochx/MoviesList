#!/bin/sh
# Claude Code PreToolUse hook. Blocks (exit 2) tool calls that would expose or leak the TMDB key.
# Reads the hook JSON from stdin. Never prints the key. Fails closed when jq is missing.

block() { echo "guard-secrets: $1" >&2; exit 2; }

command -v jq >/dev/null 2>&1 || block "jq is required for this hook (brew install jq); blocking the call."

INPUT=$(cat)
q() { printf '%s' "$INPUT" | jq -r "$1" 2>/dev/null; }
printf '%s' "$INPUT" | jq -e . >/dev/null 2>&1 || block "could not parse the hook input; blocking the call."

TOOL=$(q '.tool_name // empty')
ROOT=${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}
[ -n "$ROOT" ] || ROOT=$(pwd)

is_secrets_path() { # path -> 0 when it names the secrets file
  case "$1" in
    Secrets.xcconfig|*/Secrets.xcconfig) return 0 ;;
  esac
  return 1
}

case "$TOOL" in
  Read|Edit|Write|MultiEdit|NotebookEdit)
    P=$(q '.tool_input.file_path // .tool_input.notebook_path // empty')
    if is_secrets_path "$P"; then
      block "access to Config/Secrets.xcconfig is not allowed; it holds the real TMDB key."
    fi
    ;;
  Grep)
    P=$(q '.tool_input.path // empty')
    G=$(q '.tool_input.glob // empty')
    if is_secrets_path "$P"; then
      block "searching Config/Secrets.xcconfig is not allowed."
    fi
    case "$P" in
      Config|Config/|*/Config|*/Config/) block "searching the Config directory is not allowed; it contains the secrets file." ;;
    esac
    case "$G" in
      *Secrets*|*.xcconfig*|*Config*) block "a Grep glob that can match Config/Secrets.xcconfig is not allowed." ;;
    esac
    ;;
  Bash)
    CMD=$(q '.tool_input.command // empty')
    if printf '%s' "$CMD" | grep -q -E 'Secrets\.xcconfig|TMDB_API_KEY|TMDBAPIKey'; then
      NL=$(printf '%s' "$CMD" | wc -l | tr -d ' ')
      if [ "$NL" = 0 ] && printf '%s' "$CMD" | grep -q -E '^[[:space:]]*(sh[[:space:]]+)?(\./)?tools/secrets/(scan|leak-count)\.sh([[:space:]]+[^;&|`$()<>]*)?[[:space:]]*$'; then
        :   # the only sanctioned way to touch the secret: count-only / masked scripts
      else
        block "commands that mention the secrets file or the TMDB key are blocked; use 'sh tools/secrets/leak-count.sh <file>' or 'sh tools/secrets/scan.sh'."
      fi
    fi
    if printf '%s' "$CMD" | grep -q -E 'git[[:space:]]+(.*[[:space:]])?add([[:space:]]|$)' \
       && printf '%s' "$CMD" | grep -q -E '(^|[[:space:]])(--force|-[A-Za-z]*f[A-Za-z]*)([[:space:]]|$)' \
       && printf '%s' "$CMD" | grep -q -E 'Config(/|[[:space:]]|$)|[[:space:]]\.([[:space:]]|$)|[[:space:]](-A|--all)([[:space:]]|$)'; then
      block "'git add --force' on Config/ (or on everything) could stage the secrets file."
    fi
    if printf '%s' "$CMD" | grep -q -E 'git[[:space:]]+(.*[[:space:]])?(commit|push)([[:space:]]|$)'; then
      if printf '%s' "$CMD" | grep -q -E -e '--no-verify'; then
        block "--no-verify is not allowed on git commit/push; the secret-scan hooks must run."
      fi
      if printf '%s' "$CMD" | grep -q -E 'git[[:space:]]+(.*[[:space:]])?commit([[:space:]]|$)' \
         && printf '%s' "$CMD" | grep -q -E '[[:space:]]-[A-Za-z]*n[A-Za-z]*([[:space:]]|$)'; then
        block "git commit -n (--no-verify) is not allowed; the secret-scan hooks must run."
      fi
    fi
    ;;
esac

# Block any call whose input contains the real key value (Write/Edit content, Bash, Grep pattern...).
TMPD=$(mktemp -d 2>/dev/null) || exit 0
trap 'rm -rf "$TMPD"' EXIT INT TERM
if [ -f "$ROOT/tools/secrets/lib.sh" ]; then
  . "$ROOT/tools/secrets/lib.sh"
  if write_keyfile "$ROOT" "$TMPD/key"; then
    if printf '%s' "$INPUT" | jq -c '.tool_input // empty' 2>/dev/null | grep -q -F -f "$TMPD/key"; then
      block "the call contains the real TMDB API key value; keep it only in the gitignored secrets file."
    fi
  fi
fi
exit 0
