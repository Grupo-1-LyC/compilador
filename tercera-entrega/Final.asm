include macros2.asm
include number.asm

.MODEL LARGE
.386
.STACK 200h
.DATA

numero_entero 	dd ?
resultado_take1 	dd ?
resultado_take3 	dd ?
resultado_take4 	dd ?
constante_string 	db ?
numero_flotante 	dd ?
resultado_take2 	dd ?
@string7 	db "MAXI", "$", 30 dup (?)
@float8 	dd 0.0000
@string9 	db "Esto es una constante string", "$", 30 dup (?)
@int10 	dd 5.0000
@float11 	dd 142.5640
@int12 	dd 4.0000
@int13 	dd 4.0000
@int14 	dd 1.0000
@int15 	dd 3.0000
@int16 	dd 2.0000
@int17 	dd 12.0000
@int18 	dd 24.0000
@int19 	dd 576.0000
@int20 	dd 2.0000
@int21 	dd 2.0000
@int22 	dd 12.0000
@int23 	dd 3.0000
@float24 	dd 6.5000
@int25 	dd 3.0000
@float26 	dd 2.5000
@int27 	dd 4.0000
@int28 	dd 2.0000
@int29 	dd -4.0000
@int30 	dd 2.0000
@int31 	dd 0.0000
@int32 	dd 32000.0000
@int33 	dd 10.0000
@int34 	dd 11.0000
@int35 	dd 2.0000

.CODE

START:
MOV EAX, @DATA
MOV DS, EAX
MOV ES, EAX


MOV EAX, 4C00h
INT 21h

END START
