@for /f %%i in ('cd') do @set PREFIX=%%i
@path %path%;%prefix%\bin\
@copy /y bin\bat2exe.exe bin\make.exe >NUL:
@echo %prefix%\bin\_make.exe >>bin\make.exe
@echo %prefix%\bin\_make.exe SHELL=%prefix%\bin\sh.exe >>bin\make.exe

@echo *******************************************************************************
@echo *                              Welcome to amiga-gcc                           *
@echo *******************************************************************************
@dir bin\*.exe /w

m68k-amigaos-gcc hello.c -o hello -Os -noixemul

@cmd /k
