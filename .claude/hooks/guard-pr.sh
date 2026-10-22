#!/bin/sh
# Claude Code PreToolUse hook. Blocks `gh pr create` unless the body comes from a
# --body-file that passes tools/pr/check-body.sh. Fails closed when jq is missing.

block() { echo "guard-pr: $1" >&2; exit 2; }

command -v jq >/dev/null 2>&1 || block "jq is required for this hook (brew install jq); blocking the call."

INPUT=$(cat)
printf '%s' "$INPUT" | jq -e . >/dev/null 2>&1 || block "could not parse the hook input; blocking the call."

[ "$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')" = Bash ] || exit 0
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
printf '%s' "$CMD" | grep -q -E 'gh[[:space:]]+pr[[:space:]]+create' || exit 0

ROOT=${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}
[ -n "$ROOT" ] || ROOT=$(pwd)
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty')
[ -n "$CWD" ] && [ -d "$CWD" ] || CWD=$ROOT

if printf '%s' "$CMD" | grep -q -E '(^|[[:space:]])(--body|-b[^[:space:]]*|--fill|--fill-first|--web)([[:space:]=]|$)'; then
  block "gh pr create must not use --body/-b/--fill/--fill-first/--web; write the PR body from .github/pull_request_template.md to a file and pass --body-file <file>."
fi

FILE=$(printf '%s' "$CMD" | sed -n -E 's/.*(--body-file|-F)[[:space:]=]+("[^"]*"|'"'"'[^'"'"']*'"'"'|[^[:space:]]+).*/\2/p' | head -n 1 | sed -E "s/^[\"']//; s/[\"']\$//")
[ -n "$FILE" ] || block "gh pr create needs --body-file <file> with the filled-in PR template."
[ "$FILE" != "-" ] || block "--body-file - (stdin) can't be checked; write the body to a file."

case "$FILE" in
  /*) PATH_TO_CHECK=$FILE ;;
  *) PATH_TO_CHECK=$CWD/$FILE ;;
esac
[ -f "$PATH_TO_CHECK" ] || block "body file not found: $FILE (it must exist before gh pr create runs)."

if ! RESULT=$(cd "$ROOT" && sh tools/pr/check-body.sh "$PATH_TO_CHECK" 2>&1); then
  block "PR body failed the template check: $(printf '%s' "$RESULT" | tr '\n' ' ')"
fi
exit 0
