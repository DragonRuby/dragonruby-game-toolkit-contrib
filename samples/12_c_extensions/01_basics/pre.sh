#!/bin/sh
DRB_ROOT=../../..
mkdir -p build.dir

$DRB_ROOT/dragonruby-bind --output=build.dir/ext-bindings.c app/ext.c
clang \
  -isystem $DRB_ROOT/include -I. \
  -undefined dynamic_lookup \
  -fPIC -shared build.dir/ext-bindings.c -o build.dir/ext.lib

