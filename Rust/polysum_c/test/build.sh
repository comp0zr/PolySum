#!/bin/sh

ScriptDir="$(readlink -m "$(dirname $0)")"

(
  cd "$ScriptDir"
  cargo build
  export LIBRARY_PATH="$LIBRARY_PATH:$ScriptDir/../target/debug"
  gcc test.c -o test -I"$ScriptDir/../src" -lgmp -lpolysum_c -Wall
)
