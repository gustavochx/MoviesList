#!/bin/sh
# Usage: sh tools/pr/check-body.sh [file]   (reads stdin when no file is given)
# Checks a PR body against .github/pull_request_template.md:
#   - every "## " heading of the template is present
#   - "## Summary" has text besides HTML comments
#   - at least one box under "## Type" is ticked
# Unticked boxes under "## Verification" only warn. Exit 1 when any error was found.
set -u

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || ROOT=$(cd "$(dirname "$0")/../.." && pwd)
TEMPLATE="$ROOT/.github/pull_request_template.md"
[ -f "$TEMPLATE" ] || { echo "check-body: template not found: $TEMPLATE" >&2; exit 2; }

TMP=$(mktemp -d) || exit 2
trap 'rm -rf "$TMP"' EXIT INT TERM

if [ $# -ge 1 ]; then
  [ -f "$1" ] || { echo "check-body: no such file: $1" >&2; exit 2; }
  tr -d '\r' < "$1" > "$TMP/raw"
else
  tr -d '\r' > "$TMP/raw"
fi

# Drop HTML comments (single- and multi-line) so placeholders don't count as content.
awk '
  { line = $0; out = ""
    while (length(line) > 0) {
      if (inc) { i = index(line, "-->"); if (i == 0) line = ""; else { line = substr(line, i + 3); inc = 0 } }
      else { i = index(line, "<!--"); if (i == 0) { out = out line; line = "" } else { out = out substr(line, 1, i - 1); line = substr(line, i + 4); inc = 1 } }
    }
    print out }
' "$TMP/raw" | sed 's/[[:space:]]*$//' > "$TMP/body"

section() { # <heading>: lines under it until the next "## "
  awk -v h="$1" '$0 == h { on = 1; next } /^## / { on = 0 } on' "$TMP/body"
}

errors=0
err() { echo "error: $1"; errors=$((errors + 1)); }

grep '^## ' "$TEMPLATE" | sed 's/[[:space:]]*$//' > "$TMP/headings"
while IFS= read -r h; do
  grep -q -x -F -- "$h" "$TMP/body" || err "missing section '$h'"
done < "$TMP/headings"

if grep -q -x -F -- '## Summary' "$TMP/body"; then
  [ "$(section '## Summary' | grep -c '[^[:space:]]')" -gt 0 ] || err "'## Summary' is empty (comments don't count)"
fi

if grep -q -x -F -- '## Type' "$TMP/body"; then
  [ "$(section '## Type' | grep -c '^[[:space:]]*- \[[xX]\]')" -gt 0 ] || err "no box ticked under '## Type'"
fi

if grep -q -x -F -- '## Verification' "$TMP/body"; then
  unticked=$(section '## Verification' | grep -c '^[[:space:]]*- \[ \]')
  [ "$unticked" -eq 0 ] || echo "warning: $unticked unticked box(es) under '## Verification'"
fi

if [ "$errors" -gt 0 ]; then
  echo "check-body: $errors problem(s). Fill in .github/pull_request_template.md and keep its sections."
  exit 1
fi
echo "check-body: OK"
