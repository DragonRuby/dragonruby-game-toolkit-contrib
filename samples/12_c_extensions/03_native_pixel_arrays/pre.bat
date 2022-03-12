set DRB_ROOT=..\..\..\
md native
md native\windows-amd64
clang -shared .\app\ext.c --sysroot=C:\mingw-w64\mingw64 --target=x86_64-w64-mingw32 -fuse-ld=lld -isystem %DRB_ROOT%\include -I. -o native\windows-amd64\ext.dll
