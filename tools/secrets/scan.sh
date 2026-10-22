#!/bin/sh
# Scans for leaked TMDB credentials. Only ADDED lines are scanned (diff modes).
#
#   sh tools/secrets/scan.sh --staged                  staged changes
#   sh tools/secrets/scan.sh --range <rev-list args>   commits, e.g. base..head or "<sha> --not --remotes"
#   sh tools/secrets/scan.sh <files...>                whole files
#
# Detects: the real key (when the gitignored secrets file exists), 32-hex TMDB v3 keys,
# TMDB v4 read tokens, and the secrets file itself being committed.
# Output: file:line: <kind> (<first 4 chars>...). The full value is never printed.
# Exit 1 on any hit, 2 on usage/git errors, 0 otherwise.
set -u
# Byte-wise text handling: in a UTF-8 locale awk aborts on invalid bytes and grep hides binary matches.
export LC_ALL=C

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || ROOT=$(cd "$HERE/../.." && pwd)
. "$HERE/lib.sh"

TMP=$(mktemp -d) || exit 2
trap 'rm -rf "$TMP"' EXIT INT TERM
CONTENT="$TMP/content"   # one added line per row
META="$TMP/meta"         # "<file>\t<line>" per row, same row numbers as CONTENT
HITS="$TMP/hits"
: > "$CONTENT"; : > "$META"; : > "$HITS"

SECRETS_RE='(^|/)Config/Secrets\.xcconfig$'

# Reads a unified diff (-U0) on stdin and appends the added lines to CONTENT/META.
parse_diff() {
  awk -v C="$CONTENT" -v M="$META" '
    /^diff / { inhunk = 0; f = ""; next }
    inhunk == 0 && /^\+\+\+ / {
      f = substr($0, 5)
      if (f == "/dev/null") f = ""; else sub(/^b\//, "", f)
      next
    }
    /^@@ / {
      inhunk = 1
      s = $0; sub(/^@@ [^+]*\+/, "", s); sub(/[ ,].*/, "", s); ln = s + 0
      next
    }
    inhunk == 1 && /^\+/ {
      if (f != "") { print substr($0, 2) >> C; print f "\t" ln >> M }
      ln++
    }
  '
}

report() { # <kind> <n> <match>
  _file=$(sed -n "${2}p" "$META")
  _line=${_file##*	}
  _file=${_file%	*}
  _m=$(printf '%s' "$3" | sed 's/^[^0-9A-Za-z]*//; s/[^0-9A-Za-z]*$//' | cut -c1-4)
  printf '%s:%s: %s (%s...)\n' "$_file" "$_line" "$1" "$_m"
  echo x >> "$HITS"
}

flag_secrets_file() { # reads paths on stdin
  grep -E "$SECRETS_RE" | sort -u | while IFS= read -r p; do
    printf '%s: secrets file must never be committed (%s)\n' "$p" "Config/Secrets.xcconfig"
    echo x >> "$HITS"
  done
}

[ $# -ge 1 ] || { echo "usage: scan.sh --staged | --range <rev-list args> | <files...>" >&2; exit 2; }

case "$1" in
  --staged)
    git diff --cached --name-only --diff-filter=d | flag_secrets_file
    git diff --cached -U0 --no-color --no-ext-diff --diff-filter=d | parse_diff
    ;;
  --range)
    shift
    [ $# -ge 1 ] || { echo "scan.sh: --range needs a revision range" >&2; exit 2; }
    git log --name-only --diff-filter=d --format= "$@" > "$TMP/names" 2>"$TMP/err" \
      || { echo "scan.sh: git log failed: $(head -n 1 "$TMP/err")" >&2; exit 2; }
    flag_secrets_file < "$TMP/names"
    git log -p --diff-merges=first-parent -U0 --no-color --no-ext-diff --diff-filter=d --format= "$@" | parse_diff
    ;;
  *)
    : > "$TMP/files"
    for f in "$@"; do
      [ -f "$f" ] || continue
      printf '%s\n' "$f" | flag_secrets_file
      grep -Iq . "$f" 2>/dev/null || continue   # skip binary and empty files
      printf '%s\n' "$f" >> "$TMP/files"
    done
    while IFS= read -r f; do
      awk -v C="$CONTENT" -v M="$META" -v F="$f" '{ print $0 >> C; print F "\t" FNR >> M }' "$f"
    done < "$TMP/files"
    ;;
esac

if write_keyfile "$ROOT" "$TMP/key"; then
  grep -a -n -o -F -f "$TMP/key" "$CONTENT" | while IFS=: read -r n m; do
    report "real TMDB API key" "$n" "$m"
  done
fi

grep -a -n -o -E '(^|[^0-9A-Za-z])[0-9a-fA-F]{32}([^0-9A-Za-z]|$)' "$CONTENT" | while IFS=: read -r n m; do
  report "32-hex key (TMDB v3)" "$n" "$m"
done

grep -a -n -o -E 'eyJhbGciOiJIUzI1NiJ9\.[A-Za-z0-9_-]+' "$CONTENT" | while IFS=: read -r n m; do
  report "TMDB v4 read token" "$n" "$m"
done

if [ -s "$HITS" ]; then
  exit 1
fi
exit 0
