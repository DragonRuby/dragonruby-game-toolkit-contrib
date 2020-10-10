set DRB_ROOT=..\..\..\
md build.dir
%DRB_ROOT%\dragonruby-bind.exe --output=build.dir\ext-bind.c app\ext.c
clang -shared .\build.dir\ext-bind.c --sysroot=C:\mingw-w64\x86_64-8.1.0\mingw64 --target=x86_64-w64-mingw32 -fuse-ld=lld -isystem %DRB_ROOT%\include -I. -o build.dir\ext.lib
