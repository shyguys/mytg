#!/bin/bash
#
# Terragrunt wrapper to simplify commonly used commands.

# ---------------------------------------- BEGIN LIBRARY ----------------------------------------- #

source "${BASH_FUNCTION_LIBRARY_SCRIPTS_DIR}/log.sh"

# ----------------------------------------- END LIBRARY ------------------------------------------ #

# ################################################################################################ #

# ------------------------------------ BEGIN GLOBAL VARIABLES ------------------------------------ #

declare SCRIPT_NAME
declare GETOPT_OPTS
declare GETOPT_LONGOPTS
declare GETOPT_PARSED_ARGS
declare -i GETOPT_RETURN_CODE

SCRIPT_NAME="$(basename ${0%.*})"

# ------------------------------------- END GLOBAL VARIABLES ------------------------------------- #

# ################################################################################################ #

# ----------------------------------------- BEGIN CLEAR ------------------------------------------ #

display_tg_clear_usage() {
  cat << EOL
Usage: ${SCRIPT_NAME} clear [DIRECTORIES...] [OPTION...]
Recursively deletes all Terragrunt cache files. If no directory is
provided, the current directory will be used as starting location.

Options:
  --help    display this usage information.
EOL
}

tg_clear() {
  GETOPT_LONGOPTS="help"
  GETOPT_PARSED_ARGS="$(getopt -n "${SCRIPT_NAME}" -o "${GETOPT_OPTS}" -l "${GETOPT_LONGOPTS}" -- "$@")"
  GETOPT_RETURN_CODE=$?
  if [[ GETOPT_RETURN_CODE -ne 0 ]]; then
    display_tg_clear_usage
    exit 2
  fi

  local -a DIRECTORIES
  local DIRECTORY

  eval set -- "${GETOPT_PARSED_ARGS}"
  while true; do
    case "${1}" in
      "--help")
        display_tg_clear_usage
        return 0
      ;;

      "--")
        shift 1
        DIRECTORIES=("$@")
        shift $#
        break
      ;;
    esac
  done
  
  if [[ ${#DIRECTORIES[@]} -eq 0 ]]; then
    DIRECTORIES=(".")
  fi

  for DIRECTORY in "${DIRECTORIES[@]}"; do
    if [[ "${DIRECTORY}" == "-"* ]]; then
      log --warning "skipping '${DIRECTORY}' ..."
      continue
    fi

    find "${DIRECTORY}" \
      -type "d" \
      -name ".terragrunt-cache" \
      -prune \
      -exec echo "${SCRIPT_NAME}: removing '{}' ..." \; \
      -exec rm -rf {} \;

    find "${DIRECTORY}" \
      -type "f" \
      -name ".terraform.lock.hcl" \
      -exec echo "${SCRIPT_NAME}: removing '{}' ..." \; \
      -delete
  done
}

# ------------------------------------------ END CLEAR ------------------------------------------- #

# ################################################################################################ #

# ------------------------------------------ BEGIN MAIN ------------------------------------------ #

display_main_usage() {
  cat << EOL
Usage: ${SCRIPT_NAME} <COMMAND GROUP> [OPTION...]
Terragrunt wrapper to simplify commonly used commands.

Command groups:
  clear    recursively delete all Terragrunt cache files.

Options:
  --help    display this usage information.
EOL
}

main() {
  local COMMAND_GROUP

  COMMAND_GROUP="${1}"
  shift 1

  case "${COMMAND_GROUP}" in
    "clear")
      tg_clear "$@"
    ;;

    "--help")
      display_main_usage
      return 0
    ;;

    *)
      display_main_usage
      exit 2
    ;;
  esac
}

# ------------------------------------------- END MAIN ------------------------------------------- #

main "$@"
