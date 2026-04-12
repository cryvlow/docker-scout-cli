#!/bin/sh

# note: we require errors to propagate (don't set -e)

# Copyright © 2023 Docker, Inc.

set -u

PROJECT_NAME="docker-scout"
OWNER=docker
REPO="scout-cli"
GITHUB_DOWNLOAD_PREFIX=https://github.com/${OWNER}/${REPO}/releases/download
INSTALL_SH_BASE_URL=https://raw.githubusercontent.com/${OWNER}/${REPO}
BINARY="docker-scout"
DOCKER_HOME=${DOCKER_HOME:-~/.docker}
DEFAULT_INSTALL_DIR=${DOCKER_HOME}/cli-plugins
PROGRAM_ARGS="$*"

DOWNLOAD_TAG_INSTALL_SCRIPT=${DOWNLOAD_TAG_INSTALL_SCRIPT:-true}

usage() (
  this="$1"
  cat <<EOF
$this: download go binaries for ${OWNER}/${REPO}

Usage: $this [-b] dir [-d] [tag]
  -b  the installation directory (defaults to ${DEFAULT_INSTALL_DIR})
  -d  turns on debug logging
  -dd turns on trace logging
  [tag] the specific release to use (if missing, then the latest will be used)
EOF
  exit 2
)

is_command() (
  command -v "$1" >/dev/null
)

echo_stderr() (
  echo "$@" 1>&2
)

_logp=2
log_set_priority() {
  _logp="$1"
}

log_priority() (
  if test -z "$1"; then
    echo "$_logp"
    return
  fi
  [ "$1" -le "$_logp" ]
)

init_colors() {
  RED=''
  BLUE=''
  PURPLE=''
  BOLD=''
  RESET=''
  if test -t 1 && is_command tput; then
      ncolors=$(tput colors)
      if test -n "$ncolors" && test "$ncolors" -ge 8; then
        RED='\033[0;31m'
        BLUE='\033[0;34m'
        PURPLE='\033[0;35m'
        BOLD='\033[1m'
        RESET='\033[0m'
      fi
  fi
}

init_colors

log_tag() (
  case "$1" in
    0) echo "${RED}${BOLD}[error]${RESET}" ;;
    1) echo "${RED}[warn]${RESET}" ;;
    2) echo "[info]${RESET}" ;;
    3) echo "${BLUE}[debug]${RESET}" ;;
    4) echo "${PURPLE}[trace]${RESET}" ;;
    *) echo "[$1]" ;;
  esac
)

log_trace_priority=4
log_trace() (
  priority=$log_trace_priority
  log_priority "$priority" || return 0
  echo_stderr "$(log_tag "$priority")" "$@" "$RESET"
)

log_debug_priority=3
log_debug() (
  priority=$log_debug_priority
  log_priority "$priority" || return 0
  echo_stderr "$(log_tag "$priority")" "$@" "$RESET"
)

log_info_priority=2
log_info() (
  priority=$log_info_priority
  log_priority "$priority" || return 0
  echo_stderr "$(log_tag "$priority")" "$@" "$RESET"
)

log_warn_priority=1
log_warn() (
  priority=$log_warn_priority
  log_priority "$priority" || return 0
  echo_stderr "$(log_tag "$priority")" "$@" "$RESET"
)

log_err_priority=0
log_err() (
  priority=$log_err_priority
  log_priority "$priority" || return 0
  echo_stderr "$(log_tag "$priority")" "$@" "$RESET"
)

# ================== CAMBIOS IMPORTANTES ==================

download_asset() (
  download_url="$1"
  destination="$2"
  name="$3"
  os="$4"
  arch="$5"
  version="$6"
  format="$7"

  checksums_filepath=$(download_github_release_checksums "$download_url" "$name" "$version" "$destination")

  log_trace "checksums content:\n$(cat "${checksums_filepath}")"

  asset_filename=$(search_for_asset "$checksums_filepath" "$name" "$os" "$arch" "$format")

  if [ -z "$asset_filename" ]; then
      return 1
  fi

  asset_url="${download_url}/${asset_filename}"
  asset_filepath="${destination}/${asset_filename}"
  http_download "$asset_filepath" "$asset_url" ""

  hash_sha256_verify "$asset_filepath" "$checksums_filepath"

  echo "$asset_filepath"
)

main() (

  install_dir=${install_dir:-${DEFAULT_INSTALL_DIR}}

  while getopts "b:dh?x" arg; do
    case "$arg" in
      b) install_dir="$OPTARG" ;;
      d)
        if [ "$_logp" = "$log_info_priority" ]; then
          log_set_priority $log_debug_priority
        else
          log_set_priority $log_trace_priority
        fi
        ;;
      h | \?) usage "$0" ;;
      x) set -x ;;
    esac
  done

  shift $((OPTIND - 1))
  tag="$1"

  if ! tag=$(get_release_tag "$OWNER" "$REPO" "$tag"); then
      log_err "unable to find tag='${tag}'"
      return 1
  fi

  version=$(tag_to_version "$tag")

  if [ "$DOWNLOAD_TAG_INSTALL_SCRIPT" = "true" ]; then
      export DOWNLOAD_TAG_INSTALL_SCRIPT=false
      log_info "fetching release script for tag='${tag}'"
      # shellcheck disable=SC2086
      http_copy "${INSTALL_SH_BASE_URL}/${tag}/install.sh" "" | sh -s -- $PROGRAM_ARGS
      exit "$?"
  fi

  download_dir=$(mktemp -d)

  if ! download_and_install_asset "$GITHUB_DOWNLOAD_PREFIX/$tag" "$download_dir" "$install_dir" "$PROJECT_NAME" "linux" "amd64" "$version" "tar.gz" "$BINARY"; then
      log_err "failed to install ${BINARY}"
      return 1
  fi

  log_info "installed ${install_dir}/${BINARY}"
)

set +u
if [ -z "$TEST_INSTALL_SH" ]; then
  set -u
  main "$@"
fi
set -u