#!/bin/sh

OSTYPE=`uname -s`
if [ "x$OSTYPE" = "xDarwin" ]; then
  PLATFORM=macos
  DLLEXT=dylib
else
  PLATFORM=linux-amd64
  DLLEXT=so
fi

DRB_ROOT=../../..
mkdir -p native/$PLATFORM

cd regex-capi
cargo build --release
cd ../

$DRB_ROOT/dragonruby-bind --compiler-flags="-isysroot $(xcrun --show-sdk-path) $(clang -E -xc++ -Wp,-v /dev/null 2>&1 | sed -n '/^#include <...>/,/^End of search/p'| sed '1d;$d;s/\/\(.*\)/-I \/\1/;s/ (framework directory)//') -isystem $DRB_ROOT/include -I." --output=native/ext-bindings.c --ffi-module=RURE regex-capi/include/rure.h
clang \
  -isystem $DRB_ROOT/include -I. -I regex-capi/include \
  -fPIC -shared native/ext-bindings.c regex-capi/target/release/librure.$DLLEXT -o native/$PLATFORM/ext.$DLLEXT
