@echo off
for /f %%i in ('cd') do @set PREFIX=%%i
path %path%;%prefix%\bin\
if not exist bin\make.exe (copy /y bin\bat2exe.exe bin\make.exe >NUL: & echo %prefix%\bin\_make.exe >>bin\make.exe & echo %prefix%\bin\_make.exe SHELL=%prefix%\bin\sh.exe >>bin\make.exe)
if not exist ..\tmp mkdir ..\tmp

echo *******************************************************************************
echo *                              Welcome to amiga-gcc                           *
echo *******************************************************************************
dir bin\*.exe /w
@echo on

m68k-amigaos-gcc hello.c -o hello -Os -noixemul

@cmd /k
