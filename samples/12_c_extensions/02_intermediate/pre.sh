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

$DRB_ROOT/dragonruby-bind -ffi-module=RE --output=native/re-bindings.c app/re.h
clang \
  -isystem $DRB_ROOT/include -I. \
  -fPIC -shared app/re.c native/re-bindings.c -o native/$PLATFORM/ext.$DLLEXT

