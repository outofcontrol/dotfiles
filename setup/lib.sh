# Shared helpers for the setup scripts. Source at the top of each script:
#   . "$HOME/.dotfiles/setup/lib.sh"
# Works under both bash and zsh with only BSD tools available.
#
# Every failed step is appended to $DOTFILES_FAILURES. installscript truncates
# that file before running the scripts and prints it when they are done, so a
# step that fails is reported instead of scrolling past.

DOTFILES_FAILURES="${DOTFILES_FAILURES:-$HOME/.dotfiles-install-failures.log}"
# zsh sets $0 to the sourced file; ZSH_ARGZERO keeps the script that sourced it.
SETUP_SCRIPT="${SETUP_SCRIPT:-$(basename "${ZSH_ARGZERO:-$0}")}"

# try <command...>
# Run the command. On failure print it, record it, and carry on (returns 0 so
# scripts under set -e keep going).
try() {
  if "$@"; then
    return 0
  fi
  echo "FAILED: $*" >&2
  echo "$SETUP_SCRIPT: $*" >> "$DOTFILES_FAILURES"
  return 0
}

# check <label> <command...>
# Verify an expected outcome after a step. Records the label on failure.
check() {
  label="$1"; shift
  if "$@" >/dev/null 2>&1; then
    return 0
  fi
  echo "MISSING: $label" >&2
  echo "$SETUP_SCRIPT: $label" >> "$DOTFILES_FAILURES"
  return 0
}

# report_failures
# Print everything recorded so far. Returns 1 if there was anything.
report_failures() {
  if [ -s "$DOTFILES_FAILURES" ]; then
    echo
    echo 'The following steps FAILED or left something missing:'
    sed 's/^/  /' "$DOTFILES_FAILURES"
    echo
    echo "Fix these by hand or re-run the relevant setup script. Log: $DOTFILES_FAILURES"
    return 1
  fi
  echo 'All setup steps completed.'
  return 0
}
