:: Script para windows
flex Lexico.l
bison -dyv Sintactico.y

gcc lex.yy.c y.tab.c -o compilador -std=gnu99

compilador.exe prueba2.txt

@echo off
del compilador.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause
