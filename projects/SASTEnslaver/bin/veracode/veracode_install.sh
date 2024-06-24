#! /usr/bin/env sh
#
# Enable installing from a curl command
#
# For example
# curl -fsS https://tools.veracode.com/veracode-cli/install | sh
#
# This script reads the following environment variables:
#
# VERACODE_CLI_DOWNLOAD_URL: The download URL (default is
# https://tools.veracode.com/veracode-cli).

DOWNLOAD_URL=${VERACODE_CLI_DOWNLOAD_URL:-'https://tools.veracode.com/veracode-cli'}
CURL_C='curl --location --show-error --connect-timeout 10 --ssl-reqd '

command_exist() {
  type "$@" &> /dev/null
}

echo Installing Veracode CLI...
echo Checking prerequisites...

test_supported_os() {
  local os_name=$1
  local os_major=$(echo $2 | cut -f 1 -d . )
  local os_minor=$(echo $2 | cut -f 2 -d . )

  if [ -z "${os_major}" ] ; then
    os_major=0
  fi

  if [ -z "${os_minor}" ] ; then
    os_minor=0
  fi

  # Major version must be a number
  if ! (echo "${os_major}" | grep -q '^[0-9][0-9]*$') ; then
    return 1
  fi

  # Minor version of pre-releases may have non-numeric suffix, e.g.,
  # Alpine 3.12_alpha20200122
  os_minor=$(echo "${os_minor}" | grep -o '^[0-9]*')
  if [ -z "${os_minor}" ] ; then
    return 1
  fi

  case "${os_name}" in
    rhel)
      if [ "${os_major}" -ge 7 ] ; then
        return 0
      fi
      ;;
    ubuntu)
      if [ "${os_major}" -gt 18 -o \
           "${os_major}" -eq 18 -a "${os_minor}" -ge 4 ] ; then
        return 0
      fi
      ;;
    debian)
      if [ "${os_major}" -ge 9 ] ; then
        return 0
      fi
      ;;
    centos)
      if [ "${os_major}" -ge 7 ] ; then
        return 0
      fi
      ;;
    fedora)
      if [ "${os_major}" -ge 19 ] ; then
        return 0
      fi
      ;;
    alpine)
      if [ "${os_major}" -gt 3 -o \
           "${os_major}" -eq 3 -a "${os_minor}" -ge 11 ] ; then
        return 0
      fi
      ;;
    esac
    return 1
}

#
# Gather OS information
#
if [ -r /etc/os-release ]; then
  .     /etc/os-release
  if ! test_supported_os "$ID" "$VERSION_ID" ; then
    LINUX_VERSION=${VERSION:-"$VERSION_ID"}
    echo "WARNING: Veracode CLI has not validated support of $ID version $LINUX_VERSION." >&2
  fi
  arch=$(uname -m)
  if [ "$arch" = "x86_64" ]; then
    tgz_suffix=linux_x86
  fi
else
  # test for centos version 6 that does not have /etc/os-release.
  if [ -r /etc/system-release ] ; then
    ID=$(awk '{print $1;}' /etc/system-release | tr [A-Z] [a-z])
    VERSION_ID=$(awk '{print $3;}' /etc/system-release)
    MAJOR_VERSION=$(echo $VERSION_ID | cut -f 1 -d . )
    if [ "$ID" != centos ] || [ "$MAJOR_VERSION" -lt "7" ] ; then
      echo "Veracode CLI has not validated support of $ID version $VERSION_ID."
      exit 1
    fi
    arch=$(uname -m)
    if [ "$arch" = "x86_64" ]; then
      tgz_suffix=linux_x86
    fi
  else
    if command_exist sw_vers; then
      # might be a mac
      ID=$(sw_vers | grep ProductName | awk -F':' '{print tolower($2)}' | tr -d '[:space:]')
      VERSION_ID=$(sw_vers | grep ProductVersion | awk -F':' '{print $2}' | tr -d '[:space:]')
      arch=$(uname -m)
      if [ "$arch" = "arm64" ]; then
        tgz_suffix=macosx_arm64
      elif [ "$arch" = "x86_64" ]; then
        tgz_suffix=macosx_x86
      else
        echo "Veracode CLI has not validated support of $ID version $VERSION_ID architecture $arch."
      fi
    else
      echo 'WARNING: Veracode CLI has not validated installation on this os distribution.' >&2
    fi
  fi
fi

if [ -z "$tgz_suffix" ]; then
  echo 'Unrecognized OS; please contact us at <support@veracode.com> for help. Supported OS and architectures are MacOS (Intel or M1/M2) or Linux (Intel).' >&2
  exit 1
fi

HOMEBREW=false
if [ "$ID" = macosx ] && [ -x /usr/local/bin/brew ] ; then
  HOMEBREW=true
fi

#
# Test for better install options
#
#if [ "$ID" = macosx ] && [ $HOMEBREW = true ] ; then
#  cat << END_BREW_INSTALL
#Found homebrew on your system. Consider installing using:

#brew tap veracode/veracode-cli
#brew update
#brew install veracode-cli

#END_BREW_INSTALL
#fi

#if command_exist apt-get; then
#  cat << END_UBUNTU_INSTALL
# Found apt-get on your system.  In the future, consider installing by retrieving and installing our GPG signing key
#    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DF7DD7A50B746DD4
# Adding veracode to your apt repo list and installing
#    sudo add-apt-repository "deb https://tools.veracode.com/veracode-cli/ubuntu stable/"
#    sudo apt-get update
#    sudo apt-get install veracode-cli

#END_UBUNTU_INSTALL
#fi

#
# Fetch the latest veracode-cli tgz, and continue with local install.
#
# ALWAYS USE THE LATEST VERSION OF THE VERACODE CLI, CHANGE THE VERACODE_CLI_VERSION
# AT YOUR OWN RISK!
#
LATEST_VERSION=${VERACODE_CLI_VERSION:-$(${CURL_C} --silent ${DOWNLOAD_URL}/LATEST_VERSION)}
if [ "$?" -ne 0 ] ; then
  exit 1
fi

if [ -f "veracode" ]; then
  if [ -n "$(./veracode version | grep ${LATEST_VERSION})" ]; then
    echo "You have the latest version - $LATEST_VERSION installed on this machine."
    exit 1
  fi
fi

echo Downloading veracode-cli_${LATEST_VERSION}_${tgz_suffix}.tar.gz...

TMPDIR=$(mktemp -d /tmp/veracode-cli.XXXXXX)
# trap "rm -rf ${TMPDIR}" EXIT

RUNDIR=$PWD
{ cd ${TMPDIR}; ${CURL_C} --progress-bar "${DOWNLOAD_URL}/veracode-cli_${LATEST_VERSION}_${tgz_suffix}.tar.gz" | tar zxf -; }

cd $RUNDIR

# run install
chmod +x ${TMPDIR}/veracode-cli_${LATEST_VERSION}_${tgz_suffix}/install.sh
${TMPDIR}/veracode-cli_${LATEST_VERSION}_${tgz_suffix}/install.sh "local"