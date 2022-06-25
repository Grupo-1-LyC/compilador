:: Script para windows
PATH=C:\TASM;
tasm numbers.asm
tasm Final.asm
tlink Final.obj numbers.obj

Final.exe

@echo off
del Final.exe
del Final.obj 
del Final.map
del numbers.obj

pause