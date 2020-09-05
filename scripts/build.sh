#!/bin/bash

COLOR_RESET="\033[0m"
COLOR_RED="\033[38;5;9m"
COLOR_LIGHTCYAN="\033[1;36m"
COLOR_LIGHTGREEN="\033[1;32m"

ROOT=$(cd $(dirname $0)/.. ; pwd)
HASH=${HASH:-$(git branch --no-color | grep '*' | sed 's/\*\ //')}
if [ ! -z "$(echo ${HASH} | grep -oE "(detached|no branch)")" ] ; then
    HASH="$(git log -1 --format=%h)"
else
    HASH="${HASH}-$(git log -1 --format=%h)"
fi
SHORT_VER=$(cat "$ROOT/version.txt")
LONG_VER="$SHORT_VER-$HASH"

[ ! -z $ENV ] || ENV=local
ENV=${ENV/prod*/production}

error() {
    echo -e "${COLOR_RED}ERROR: $1${COLOR_RESET}" >&2
    exit 1
}

warn() {
    echo -e "${COLOR_RED}WARNING: $1${COLOR_RESET}"
}

info() {
    echo -e "${COLOR_LIGHTCYAN}$1${COLOR_RESET}"
}

success() {
    echo -e "${COLOR_LIGHTGREEN}$1${COLOR_RESET}"
}

_trap() {
  echo interrupted >&2
  exit 1
}

trap '_trap' SIGINT SIGTERM

BUILD_DIR=${BUILD_DIR:-${ROOT}/build}
OUT_FILENAME="wip"
OUT_FILEEXT=""
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
GOOS=${GOOS:-}

if [ -z "${GOOS}" ] ; then
    if [[ ${PLATFORM} =~ "mingw64" ]] ; then
        export GOOS=windows
    else
        export GOOS=${PLATFORM}
    fi
fi

info "Building..."
info "Target platform: $GOOS"

if [ ${GOOS} = "windows" ] ; then
    OUT_FILEEXT=".exe"
fi

info "Building version ${LONG_VER}"
echo ""

go build -ldflags "-s -w -X main.AppVersion=${LONG_VER}" \
    -o "${BUILD_DIR}/${OUT_FILENAME}${OUT_FILEEXT}" "${ROOT}/cmd/wip/main.go"
if [ $? -gt 0 ] ; then
    error "Build failed!"
fi

success "Build succeeded"

