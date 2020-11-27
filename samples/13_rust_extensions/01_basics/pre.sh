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

pushd rust-basic-crate
cargo build --release
cbindgen --config cbindgen.toml --crate rust-basic-crate --output ../app/ext.h
popd

$DRB_ROOT/dragonruby-bind --output=native/ext-bindings.c app/ext.h
echo "\nIgnore the above error about #include\n"
clang \
  -isystem $DRB_ROOT/include -I. \
  -fPIC -shared native/ext-bindings.c rust-basic-crate/target/release/librust_basic_crate.$DLLEXT -o native/$PLATFORM/ext.$DLLEXT

