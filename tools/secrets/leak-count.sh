#!/bin/sh
# Usage: sh tools/secrets/leak-count.sh <file>
# Prints only how many lines of <file> contain the real TMDB key (0 when there is no secrets file).
# The key is read from the gitignored secrets file and never printed.
set -u

[ $# -eq 1 ] || { echo "usage: leak-count.sh <file>" >&2; exit 2; }
[ -f "$1" ] || { echo "leak-count.sh: no such file: $1" >&2; exit 2; }

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || ROOT=$(cd "$HERE/../.." && pwd)
. "$HERE/lib.sh"

TMP=$(mktemp -d) || exit 2
trap 'rm -rf "$TMP"' EXIT INT TERM

if write_keyfile "$ROOT" "$TMP/key"; then
  grep -c -F -f "$TMP/key" "$1"
  exit 0
fi
echo 0
