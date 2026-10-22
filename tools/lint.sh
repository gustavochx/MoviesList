#!/bin/sh
# Lints the project with SwiftLint (config: .swiftlint.yml). Strict: any violation fails.
# Part of the definition of done, so a missing SwiftLint is an error, not a skip.
set -e
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# SwiftLint needs SourceKit from Xcode; the Command Line Tools (a common xcode-select default) do not ship it.
if [ -z "$DEVELOPER_DIR" ] && [ -d /Applications/Xcode.app/Contents/Developer ]; then
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi
if ! command -v swiftlint >/dev/null 2>&1; then
  echo "SwiftLint is not installed. Install it with: brew install swiftlint" >&2
  exit 1
fi
cd "$(dirname "$0")/.."
echo "SwiftLint $(swiftlint version)"
swiftlint lint --strict --quiet
echo "SwiftLint: 0 violations"
