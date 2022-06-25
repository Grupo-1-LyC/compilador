:: Script para windows
flex Lexico.l
bison -dyv Sintactico.y

gcc lex.yy.c y.tab.c -o Grupo1 -std=gnu99

Grupo1.exe prueba.txt

@echo off
del Grupo1.exe
del lex.yy.c
del y.tab.c
del y.tab.h
del y.output

pause
