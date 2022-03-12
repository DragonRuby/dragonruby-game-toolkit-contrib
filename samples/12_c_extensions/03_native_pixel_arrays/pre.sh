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

clang \
  -isystem $DRB_ROOT/include -isystem $DRB_ROOT -I. \
  -fPIC -shared app/ext.c -o native/$PLATFORM/ext.$DLLEXT

