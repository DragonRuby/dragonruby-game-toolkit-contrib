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

$DRB_ROOT/dragonruby-bind --output=native/ext-bindings.c app/ext.c
clang \
  -isystem $DRB_ROOT/include -I. \
  -fPIC -shared native/ext-bindings.c -o native/$PLATFORM/ext.$DLLEXT

