#!/bin/bash

GITHUB_DOWNLOAD=https://repo.databend.rs/databend
GITHUB_TAG=https://repo.databend.rs/databend/tags.json

assert_nz() {
    if [ -z "$1" ]; then
        log_err "assert_nz $2"
        exit 1
    fi
}

check_proc() {
    # Check for /proc by looking for the /proc/self/exe link
    # This is only run on Linux
    if ! test -L /proc/self/exe ; then
        err "fatal: Unable to find /proc/self/exe.  Is /proc mounted?  Installation cannot proceed without /proc."
    fi
}

need_cmd() {
    if ! check_cmd "$1"; then
        log_err "need '$1' (command not found)"
        exit 1
    fi
}

check_cmd() {
    command -v "$1" > /dev/null 2>&1
}

log_prefix() {
  echo "$0"
}

echoerr() {
  echo "$@"
}

log_debug() {
  log_priority 7 || return 0
  echoerr "$(log_prefix)" "$(log_tag 7)" "$@"
}

log_err() {
  log_priority 3 || return 0
  echoerr "$(log_prefix)" "$(log_tag 3)" "$@"
}
_logp=6
log_set_priority() {
  _logp="$1"
}
log_priority() {
  if test -z "$1"; then
    echo "$_logp"
    return
  fi
  [ "$1" -le "$_logp" ]
}
log_tag() {
  case $1 in
    0) echo "emerg" ;;
    1) echo "alert" ;;
    2) echo "crit" ;;
    3) echo "err" ;;
    4) echo "warning" ;;
    5) echo "notice" ;;
    6) echo "info" ;;
    7) echo "debug" ;;
    *) echo "$1" ;;
  esac
}

log_info() {
  log_priority 6 || return 0
  echoerr "$(log_prefix)" "$(log_tag 6)" "$@"
}

log_crit() {
  log_priority 2 || return 0
  echoerr "$(log_prefix)" "$(log_tag 2)" "$@"
}



# problematic in arm/v7 and arm/v6 environment
get_bitness() {
    need_cmd head
    # Architecture detection without dependencies beyond coreutils.
    # ELF files start out "\x7fELF", and the following byte is
    #   0x01 for 32-bit and
    #   0x02 for 64-bit.
    # The printf builtin on some shells like dash only supports octal
    # escape sequences, so we use those.
    local _current_exe_head
    _current_exe_head=$(head -c 5 /proc/self/exe )
    if [ "$_current_exe_head" = "$(printf '\177ELF\001')" ]; then
        echo 32
    elif [ "$_current_exe_head" = "$(printf '\177ELF\002')" ]; then
        echo 64
    else
        log_err "unknown platform bitness"
    fi
}

# Cross-platform architecture detection, borrowed from rustup-init.sh
get_architecture() {
    local _ostype _cputype _bitness _arch _clibtype _is_rosseta
    _ostype="$(uname -s)"
    _cputype="$(uname -m)"
    _clibtype="gnu"
    if [ "$_ostype" = Linux ]; then
        if [ "$(uname -o)" = Android ]; then
            _ostype=Android
        fi
        if ldd --version 2>&1 | grep -q 'musl'; then
            _clibtype="musl"
        fi
    fi

    if [ "$_ostype" = Darwin ] && [ "$_cputype" = i386 ]; then
        # Darwin `uname -m` lies
        if sysctl hw.optional.x86_64 | grep -q ': 1'; then
            _cputype=x86_64
        fi
    fi

    if [ "$_ostype" = SunOS ]; then
        # Both Solaris and illumos presently announce as "SunOS" in "uname -s"
        # so use "uname -o" to disambiguate.  We use the full path to the
        # system uname in case the user has coreutils uname first in PATH,
        # which has historically sometimes printed the wrong value here.
        if [ "$(/usr/bin/uname -o)" = illumos ]; then
            _ostype=illumos
        fi

        # illumos systems have multi-arch userlands, and "uname -m" reports the
        # machine hardware name; e.g., "i86pc" on both 32- and 64-bit x86
        # systems.  Check for the native (widest) instruction set on the
        # running kernel:
        if [ "$_cputype" = i86pc ]; then
            _cputype="$(isainfo -n)"
        fi
    fi

    case "$_ostype" in

        Android)
            _ostype=linux-android
            ;;

        Linux)
            check_proc
            _ostype=unknown-linux-$_clibtype
            _bitness=$(get_bitness)
            ;;

        FreeBSD)
            _ostype=unknown-freebsd
            ;;

        NetBSD)
            _ostype=unknown-netbsd
            ;;

        DragonFly)
            _ostype=unknown-dragonfly
            ;;

        Darwin)
            _ostype=apple-darwin
            ;;

        illumos)
            _ostype=unknown-illumos
            ;;

        MINGW* | MSYS* | CYGWIN*)
            _ostype=pc-windows-gnu
            ;;

        *)
            log_err "unrecognized OS type: $_ostype"
            ;;

    esac

    case "$_cputype" in

        i386 | i486 | i686 | i786 | x86)
            _cputype=i686
            ;;

        xscale | arm)
            _cputype=arm
            if [ "$_ostype" = "linux-android" ]; then
                _ostype=linux-androideabi
            fi
            ;;

        armv6l)
            _cputype=arm
            if [ "$_ostype" = "linux-android" ]; then
                _ostype=linux-androideabi
            else
                _ostype="${_ostype}eabihf"
            fi
            ;;

        armv7l | armv8l)
            _cputype=armv7
            if [ "$_ostype" = "linux-android" ]; then
                _ostype=linux-androideabi
            else
                _ostype="${_ostype}eabihf"
            fi
            ;;

        aarch64 | arm64)
            _cputype=aarch64
            ;;

        x86_64 | x86-64 | x64 | amd64)
            _cputype=x86_64
            ;;

        mips)
            _cputype=$(get_endianness mips '' el)
            ;;

        mips64)
            if [ "$_bitness" -eq 64 ]; then
                # only n64 ABI is supported for now
                _ostype="${_ostype}abi64"
                _cputype=$(get_endianness mips64 '' el)
            fi
            ;;

        ppc)
            _cputype=powerpc
            ;;

        ppc64)
            _cputype=powerpc64
            ;;

        ppc64le)
            _cputype=powerpc64le
            ;;

        s390x)
            _cputype=s390x
            ;;
        riscv64)
            _cputype=riscv64gc
            ;;
        *)
            log_err "unknown CPU type: $_cputype"

    esac

    # Detect 64-bit linux with 32-bit userland
    if [ "${_ostype}" = unknown-linux-gnu ] && [ "${_bitness}" -eq 32 ]; then
        case $_cputype in
            x86_64)
                _cputype=i686
                ;;
            mips64)
                _cputype=$(get_endianness mips '' el)
                ;;
            powerpc64)
                _cputype=powerpc
                ;;
            aarch64)
                _cputype=armv7
                if [ "$_ostype" = "linux-android" ]; then
                    _ostype=linux-androideabi
                else
                    _ostype="${_ostype}eabihf"
                fi
                ;;
            riscv64gc)
                log_err "riscv64 with 32-bit userland unsupported"
                ;;
        esac
    fi

    # Detect armv7 but without the CPU features Rust needs in that build,
    # and fall back to arm.
    # See https://github.com/rust-lang/rustup.rs/issues/587.
    if [ "$_ostype" = "unknown-linux-gnueabihf" ] && [ "$_cputype" = armv7 ]; then
        if ensure grep '^Features' /proc/cpuinfo | grep -q -v neon; then
            # At least one processor does not have NEON.
            _cputype=arm
        fi
    fi

    _arch="${_cputype}-${_ostype}"

    RETVAL="$_arch"
}

assert_supported_architecture() {
    local _arch="$1"; shift

    # Match against all supported architectures
    case $_arch in
        x86_64-apple-darwin)
            echo "x86_64-apple-darwin"
            return 0
            ;;
        aarch64-unknown-linux-gnu)
            echo "aarch64-unknown-linux-gnu"
            return 0
            ;;
        x86_64-unknown-linux-gnu)
            echo "x86_64-unknown-linux-gnu"
            return 0
            ;;
        aarch64-apple-darwin)
            echo "x86_64-apple-darwin"
            return 0
            ;;
        *)
          echo "current architecture $_arch is not supported, Make sure this script is up-to-date and file request at https://github.com/$DATABEND_REPO/issues/new"
          return 1
          ;;
    esac

    return 1
}


choose_mirror() {
  code=$(curl -s -o /dev/null -w "%{http_code}" -m 3 "$GITHUB_TAG")
  if [ "$(( $code / 100))" != 2 ] && [ "$(( $code / 100))" != 3 ]; then
    echo "mirror in $GITHUB_TAG not available"
    # switch to repo.databend.rs
    DATABEND_REPO=datafuselabs/databend
    GITHUB_DOWNLOAD=https://github.com/${DATABEND_REPO}/releases/download
    GITHUB_TAG=https://api.github.com/repos/${DATABEND_REPO}/tags
  fi
  code=$(curl -s -o /dev/null -w "%{http_code}" -m 3 "$GITHUB_TAG")
  if [ "$(( $code / 100))" != "2" ] && [ "$(( $code / 100))" != 3 ]; then
    echo "mirror in $GITHUB_TAG not available"
    return 1
  fi
  return 0
}
# Exit immediately, prompting the user to file an issue on GH
abort_prompt_issue() {
    log_err ""
    log_err "If you believe this is a bug (or just need help),"
    log_err "please feel free to file an issue on Github ❤️"
    log_err "    https://github.com/$DATABEND_REPO/issues/new"
    exit 1
}

set_tag() {
  local _tag="$TAG"; shift
  if [ -z "$_tag" ]; then
      _tag=$(get_latest_tag "$DATABEND_REPO") || return 1
  fi

  TAG=$(echo "$_tag" | tr -d '"')
}

get_latest_tag() {
  # shellcheck disable=SC2046
  # shellcheck disable=SC2021
  curl --silent "${GITHUB_TAG}"  |  grep -Eo '"name"[^,]*' | sed -r 's/^[^:]*:(.*)$/\1/' | head -n 1 | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//' |  tr -d '[{}]'
}
# Run a command that should never fail. If the command fails execution
# will immediately terminate with an error showing the failing
# command.
ensure() {
    if ! "$@"; then
        log_err "command failed: $*"
        exit 1
    fi
}
need_cmd() {
    if ! check_cmd "$1"; then
        log_err "need '$1' (command not found)"
        exit 1
    fi
}
is_command() {
  command -v "$1" >/dev/null
}

# Untar release binary files
# @param $1: The target tar file
# @return: Status 0 if the architecture is supported, exit if not
untar() {
  local tarball=$1; shift
  case "${tarball}" in
    *.tar.gz | *.tgz) tar --no-same-owner -xzf "${tarball}" ;;
    *.tar) tar --no-same-owner -xf "${tarball}" ;;
    *.zip) unzip "${tarball}" ;;
    *)
      log_err "untar unknown archive format for ${tarball}"
      return 1
      ;;
  esac
}

set_name_url() {
  local _arch=$1;
  local _version=$2; shift
  NAME=databend-${_version}-${_arch}.tar.gz
  TARBALL=${NAME}
  TARBALL_URL=${GITHUB_DOWNLOAD}/${_version}/${TARBALL}
  echo "$TARBALL_URL"
}

set_name() {
  local _arch=$1;
  local _version=$2; shift
  NAME=databend-${_version}-${_arch}.tar.gz
  echo "$NAME"
}

download_databend() {
    local _status
    local _name="$1";
    local _url="$2"; shift
    tmpdir=$(mktemp -d)
    log_debug "downloading files into ${tmpdir}"
    log_info "😊 Start to download databend in ${_url}"
    http_download "${tmpdir}/${_name}" "${_url}"
    _status=$?
    if [ $_status -ne 0 ]; then
        log_err "❌ Failed to download databend!"
        log_err "    Error downloading from ${_url}"
        rm -rf tmpdir
        abort_prompt_issue
    fi
    log_info "✅ Successfully downloaded databend in ${_url}"
    srcdir="${tmpdir}"
    (cd "${tmpdir}" && untar "${_name}")
    _status=$?
    if [ $_status -ne 0 ]; then
        log_err "❌ Failed to unzip databend!"
        log_err "    Error from untar ${_name}"
        rm -rf tmpdir
        abort_prompt_issue
    fi
    # shellcheck disable=SC2043
    for f in bin configs readme.txt scripts; do
      #TODO(zhihanz) for windows we should add .exe suffix
      mv "${srcdir}/${f}" "./"
    done 
    ensure chmod +x ./bin/*
    cp scripts/*.sh .
    ensure chmod +x *.sh
    rm -rf "${tmpdir}"
    return $_status
}

http_download() {
  log_debug "http_download $2"
  if is_command curl; then
    http_download_curl "$@"
    return
  fi
  log_crit "http_download unable to find curl"
  return 1
}
http_download_curl() {
  local_file=$1
  source_url=$2
  header=$3
  if [ -z "$header" ]; then
    code=$(curl -w '%{http_code}' -L -o "$local_file" "$source_url")
  else
    code=$(curl -w '%{http_code}' -L -H "$header" -o "$local_file" "$source_url")
  fi
  if [ "$(( $code / 100 ))" != 2 ] && [ "$(( $code / 100 ))" != 3 ]; then
    log_debug "http_download_curl received HTTP status $code"
    return 1
  fi
  return 0
}

print_hint(){
    log_info "💡 Startup @ ./start.sh"
    echo "./start.sh"
}

main(){
      local _status _target _version _url _name
      need_cmd curl
      need_cmd uname
      need_cmd mktemp
      need_cmd chmod
      need_cmd tar

      get_architecture || return 1
      local _arch="$RETVAL"
      assert_nz ${_arch}
      _target=$(assert_supported_architecture ${_arch})
      choose_mirror || return 1
      set_tag || return 1
      _version="$TAG"
      _name=$(set_name "$_target" "$_version" || return 1)
      _url=$(set_name_url "$_target" "$_version" || return 1)
      echo ${_url}
      download_databend "$_name" "$_url" || return 1

      print_hint || return 1
}

#----
main
