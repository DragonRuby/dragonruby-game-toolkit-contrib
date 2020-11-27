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

cd rust-basic-crate
cargo build --release
cbindgen --config cbindgen.toml --crate rust-basic-crate --output ../app/ext.h
cd ../

$DRB_ROOT/dragonruby-bind --compiler-flags="-isysroot $(xcrun --show-sdk-path) $(clang -E -xc++ -Wp,-v /dev/null 2>&1 | sed -n '/^#include <...>/,/^End of search/p'| sed '1d;$d;s/\/\(.*\)/-I \/\1/;s/ (framework directory)//') -isystem $DRB_ROOT/include -I." --output=native/ext-bindings.c app/ext.h
clang \
  -isystem $DRB_ROOT/include -I. \
  -fPIC -shared native/ext-bindings.c rust-basic-crate/target/release/librust_basic_crate.$DLLEXT -o native/$PLATFORM/ext.$DLLEXT

