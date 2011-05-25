######################################################################
# This script retrieves, builds and installs the specified version of
# Erlang. Run as root unless you have chowned the /usr/local directory
# to your own user, add yourself to a common group and chgrp the local
# directory, or change the permissions recursively on /usr/local.
######################################################################
#!/usr/bin/env bash

USAGE="Usage: `basename $0` [-w [32 | 64] ] [-d] Version"
WORDSIZE="32"   #default to 32-bit word size
INSTALL_DOCS=0
OPTSTRING=":dhw:"
OTP_SITE="http://erlang.org/download"
OTP_DIR="/usr/local/lib/erlang"
SRC_DIR="/usr/local/src"
WORD_SIZE_BUILD_FLAG=""
OSNAME=`uname`
BUILD_FLAGS="--enable-threads --enable-smp-support --enable-kernel-poll --enable-hipe"
DOC_MSG="Not installing docs"

parse_options() {
  while getopts $OPTSTRING Option
  do
    case $Option in
      d ) INSTALL_DOCS=1
          DOC_MSG="Will install docs";;
      w ) case $OPTARG in
            "32" ) WORD_SIZE_BUILD_FLAG=""
                   BUILD_TYPE="Building 32-bit version of Erlang"
                   ;;
            "64" ) case $OSNAME in
                   "Darwin" ) WORD_SIZE_BUILD_FLAG="--enable-darwin-64bit";;
                   "Linux"  ) WORD_SIZE_BUILD_FLAG="--enable-m64-build";;
                         *  ) echo "Unsupported OS"; exit 0
                   esac
                   BUILD_TYPE="Building 64-bit version of Erlang"
                    ;;
            * ) echo $USAGE
                exit 0
                ;;
          esac
          ;;
      h | *)
        echo $USAGE
        exit 0
        ;;
    esac
  done

  shift `expr $OPTIND - 1`

  if [ $# -eq 0 ]; then
    echo $USAGE >&2
    exit 1
  fi

  OTP_VERSION=`echo $1 | awk '{ print toupper($1); }'`
  OTP_SRC="otp_src_$OTP_VERSION"
  OTP_DOC="otp_doc_html_$OTP_VERSION"
}

clean_up_erlang_directory() {
  if [ -e "$OTP_DIR" ]
  then
    echo "Removing older version of Erlang"
    rm -rf $OTP_DIR
  fi
}

download_erlang() {
  cd $SRC_DIR
  OTP_FILENAME="$OTP_SRC.tar.gz"
  if [ -e "$OTP_FILENAME" ]
  then
    echo "Attempting to remove $OTP_FILENAME"
    rm $OTP_FILENAME      # remove any existing archive
  fi

  wget "$OTP_SITE/$OTP_FILENAME"
  if [ $? -ne  0 ]
  then
    echo "Error $rc while downloading $FILENAME"
    exit 1
  fi
}

build_erlang() {
  # clean up build directory
  if [ -e "$SRC_DIR/$OTP_SRC" ]
  then
    rm -rf $SRC_DIR/$OTP_SRC
  fi

  # untar the source
  tar xfvz $OTP_FILENAME

  # change to source directory, configure, make and install
  cd $SRC_DIR/$OTP_SRC
  ./configure $BUILD_FLAGS $WORD_SIZE_BUILD_FLAG
  echo "Building Erlang $OTP_SRC..."
  make
  echo "Installing Erlang $OTP_SRC..."
  make install
  echo "Erlang installation complete..."
}

housekeeping() {
  echo "Do you want to remove the $OTP_SRC tarball? (y/n)?";
  read ANS
  if [[ "$ANS" == "y" || "ANS" == "Y" ]]
  then
  rm $SRC_DIR/$OTP_FILENAME
  fi
}

build_dialyzer() {
  cd ~
  DIALYZER_DIR="~/.dialyzer_plt"
  if [ -e "$DIALYZER_DIR" ]
  then
    rm -rf $DIALYZER_DIR
  fi
  echo "Building dialyzer..."
  dialyzer --build_plt --apps erts stdlib kernel crypto
  echo "Dialyzer build complete..."
}

install_docs() {
  cd $SRC_DIR
  echo "Downloading Erlang HTML Docs..."
  DOC_FILENAME="$OTP_DOC.tar.gz"
  wget "$OTP_SITE/$DOC_FILENAME"
  if [ $? -ne 0 ]
  then
    echo "Error $rc while downloading $OTP_SITE/$DOC_FILENAME"
  exit 1
  fi
  cd $OTP_DIR
  tar xfvz $SRC_DIR/$DOC_FILENAME
  rm $SRC_DIR/$DOC_FILENAME
}

# main function

# parse options and set flags
parse_options "$@"

echo $BUILD_TYPE
echo $DOC_MSG

clean_up_erlang_directory
download_erlang
build_erlang
housekeeping	# <=== Not needed for automatic installs
build_dialyzer

if [ "$INSTALL_DOCS" -eq 1 ]
then
  echo $DOC_MSG
  install_docs
else
  echo $DOC_MSG
fi

exit 0
