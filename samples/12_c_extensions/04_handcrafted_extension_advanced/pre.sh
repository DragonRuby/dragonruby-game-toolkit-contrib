#!/bin/sh

OSTYPE=`uname -s`
if [ "x$OSTYPE" = "xDarwin" ]; then
  PLATFORM=macos
  DLLEXT=dylib
else
  PLATFORM=linux-amd64
  DLLEXT=so
fi

DRB_ROOT=..

mkdir -p native/$PLATFORM

clang \
  -isystem $DRB_ROOT -isystem $DRB_ROOT -I. \
  -O3 \
  -DMRB_INT64=1 \
  -fPIC -shared native/ext-bindings.c -o native/$PLATFORM/ext_$SUFFIX.$DLLEXT
