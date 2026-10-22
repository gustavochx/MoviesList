# Sourced by the other tools/secrets scripts and by .claude/hooks/guard-secrets.sh.
# Never prints the key.

# write_keyfile <repo root> <dest>
# Writes the real TMDB key (from the gitignored secrets file) to <dest>, mode 600.
# Returns 1 when the secrets file is missing or its value is empty (dest is removed).
write_keyfile() {
  _secrets="$1/Config/Secrets.xcconfig"
  [ -f "$_secrets" ] || return 1
  ( umask 077
    sed -n 's/^[[:space:]]*TMDB_API_KEY[[:space:]]*=[[:space:]]*//p' "$_secrets" \
      | head -n 1 | sed 's/[[:space:]].*$//' > "$2" )
  if grep -q . "$2"; then
    return 0
  fi
  rm -f "$2"
  return 1
}
