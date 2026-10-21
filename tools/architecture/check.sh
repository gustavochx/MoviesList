#!/bin/sh
# Module dependency check. Uses the maintainer-local ios-modularization skill, which is not part of this repo;
# without it the check is skipped so it never blocks anyone.
set -e
VALIDATOR="$HOME/.claude/skills/ios-modularization/scripts/validate_graph.py"
if [ ! -f "$VALIDATOR" ]; then
  echo "ios-modularization skill not installed; architecture check skipped"
  exit 0
fi
python3 "$VALIDATOR" --root "$(cd "$(dirname "$0")/../.." && pwd)"
