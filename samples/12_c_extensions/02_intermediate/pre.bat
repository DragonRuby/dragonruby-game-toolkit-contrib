set DRB_ROOT=..\..\..\
md native
md native\windows-amd64
%DRB_ROOT%\dragonruby-bind.exe --ffi-module=RE --output=native\re-bindings.c app\re.h
clang -shared .\native\re-bindings.c .\app\re.c --sysroot=C:\mingw-w64\mingw64 --target=x86_64-w64-mingw32 -fuse-ld=lld -isystem %DRB_ROOT%\include -I. -o native\windows-amd64\ext.dll
