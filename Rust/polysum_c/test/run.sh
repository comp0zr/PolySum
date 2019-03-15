#!/bin/sh
ScriptDir="$(readlink -m "$(dirname $0)")"

(
  cd "$ScriptDir"
  if [ ! -x test ]; then
    ./build.sh
  fi

  export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$ScriptDir/../target/debug"
  ./test "$@"
)

