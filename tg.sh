#!/bin/bash
#
# Terragrunt wrapper to simplify commonly used commands.

# ------------------------------------ BEGIN GLOBAL VARIABLES ------------------------------------ #

# None.

# ------------------------------------- END GLOBAL VARIABLES ------------------------------------- #

# ################################################################################################ #

# --------------------------------- BEGIN COMMAND GROUP 'CLEAR' ---------------------------------- #

tg::clear::usage() {
  echo "Usage: tg clear [DIRECTORIES...] [GLOBAL OPTIONS]"
  echo "  Recursively deletes all terragrunt cache files. If no directory is"
  echo "  provided, the current directory will be used as starting location."
  echo
  tg::usage::global_options
}

tg::clear() {
  local -a DIRECTORIES
  local DIRECTORY

  DIRECTORIES=(".")

  if [[ "${1}" == "--help" ]]; then
    tg::clear::usage
    exit
  fi

  if [[ $# -gt 0 ]]; then
    DIRECTORIES=("$@")
  fi

  for DIRECTORY in "${DIRECTORIES[@]}"; do
    if [[ "${DIRECTORY}" == "-"* ]]; then
      echo "tg: skipping '${DIRECTORY}' ..."
      continue
    fi

    find "${DIRECTORY}" \
      -type "d" \
      -name ".terragrunt-cache" \
      -prune \
      -exec echo "tg: removing '{}' ..." \; \
      -exec rm -rf {} \;

    find "${DIRECTORY}" \
      -type "f" \
      -name ".terraform.lock.hcl" \
      -exec echo "tg: removing '{}' ..." \; \
      -delete
  done
}

# ---------------------------------- END COMMAND GROUP 'CLEAR' ----------------------------------- #

# ################################################################################################ #

# --------------------------------- BEGIN COMMAND GROUP 'STATE' ---------------------------------- #

tg::state() {
  echo "# TBD."
}

# ---------------------------------- END COMMAND GROUP 'STATE' ----------------------------------- #

# ################################################################################################ #

# --------------------------------- BEGIN COMMAND GROUP 'USAGE' ---------------------------------- #

tg::usage::global_options() {
  echo "Global Options:"
  echo "  --help    displays the usage of the provided command group."
}

# ---------------------------------- END COMMAND GROUP 'USAGE' ----------------------------------- #

# ################################################################################################ #

# ------------------------------------------ BEGIN MAIN ------------------------------------------ #

main::usage() {
  echo "Usage: tg <COMMAND GROUP> [GLOBAL OPTIONS]"
  echo "  Terragrunt wrapper to simplify commonly used commands."
  echo
  echo "Command Groups:"
  echo "  clear    recursively deletes all terragrunt cache files."
  echo
  tg::usage::global_options
}

main() {
  local COMMAND_GROUP

  COMMAND_GROUP="${1}"
  shift 1

  case "${COMMAND_GROUP}" in
    "clear")
      tg::clear "$@"
    ;;

    *)
      main::usage
    ;;
  esac
}

# ------------------------------------------- END MAIN ------------------------------------------- #

main "$@"
