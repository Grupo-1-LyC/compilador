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
@STRING7 	db "Escriba numero_entero", "$", 30 dup (?)
@STRING8 	db "MAXI", "$", 30 dup (?)
@FLOAT9 	dd -1.0000
@STRING10 	db "Esto es una constante string", "$", 30 dup (?)
@INT11 	dd 5.0000
@FLOAT12 	dd 142.5640
@INT13 	dd 4.0000
@INT14 	dd 4.0000
@INT15 	dd 1.0000
@INT16 	dd 3.0000
@INT17 	dd 2.0000
@INT18 	dd 12.0000
@INT19 	dd 24.0000
@INT20 	dd 576.0000
@INT21 	dd 2.0000
@INT22 	dd 2.0000
@INT23 	dd 12.0000
@INT24 	dd 3.0000
@FLOAT25 	dd 6.5000
@INT26 	dd 3.0000
@FLOAT27 	dd 2.5000
@INT28 	dd 4.0000
@INT29 	dd 2.0000
@INT30 	dd -4.0000
@INT31 	dd 2.0000
@INT32 	dd 0.0000
@INT33 	dd 32000.0000
@INT34 	dd 10.0000
@INT35 	dd 11.0000
@INT36 	dd 2.0000
@aux32 	dd ?
@aux38 	dd ?
@aux40 	dd ?
@aux48 	dd ?
@aux55 	dd ?
@aux57 	dd ?
@aux68 	dd ?
@aux88 	dd ?
@aux103 	dd ?
@aux105 	dd ?
@aux112 	dd ?

.CODE

START:
MOV EAX, @DATA
MOV DS, EAX
MOV ES, EAX

displayString @STRING7
newLine
getFloat numero_entero,0
MOV  SI, OFFSET @STRING8
MOV  DI, OFFSET constante_string
STRCPY
fld @FLOAT9
fstp numero_flotante
displayString constante_string
newLine
displayString @STRING10
newLine
displayFloat @INT11,0
newLine
displayFloat @FLOAT12,4
newLine
fld @INT13
fld numero_entero
fcomp
fstsw ax
sahf
ffree
jb _jump_74
_jump_23:
fld @INT13
fld numero_entero
fcomp
fstsw ax
sahf
ffree
jna _jump_36
fld @INT15
fld numero_entero
fxch
fsub
fstp @aux32
ffree
fld @aux32
fstp numero_entero
jmp _jump_23
_jump_36:
fld @INT18
fld @INT17
fxch
fmul
fstp @aux38
ffree
fld @INT19
fld @aux38
fxch
fmul
fstp @aux40
ffree
fld @INT20
fld @aux40
fcomp
fstsw ax
sahf
ffree
je _jump_52
fld @INT18
fld @INT17
fxch
fadd
fstp @aux48
ffree
fld @aux48
fstp resultado_take1
jmp _jump_72
_jump_52:
fld @INT16
fld @FLOAT25
fxch
fsub
fstp @aux55
ffree
fld @FLOAT27
fld @aux55
fxch
fsub
fstp @aux57
ffree
fld @aux57
fstp resultado_take2
displayFloat resultado_take2,4
newLine
fld resultado_take3
fstp resultado_take3
displayFloat resultado_take3,0
newLine
fld @INT17
fld @INT30
fxch
fadd
fstp @aux68
ffree
fld @aux68
fstp resultado_take4
displayFloat resultado_take4,0
newLine
_jump_72:
jmp _jump_116
_jump_74:
_jump_74:
fld numero_entero
fld @INT32
fcomp
fstsw ax
sahf
ffree
ja _jump_116
fld numero_entero
fld @INT33
fcomp
fstsw ax
sahf
ffree
jb _jump_116
fld numero_flotante
fld numero_entero
fxch
fmul
fstp @aux88
ffree
fld @aux88
fstp numero_entero
fld @INT34
fld numero_entero
fcomp
fld @INT35
fld numero_entero
fcomp
fstsw ax
sahf
ffree
jna _jump_109
fld numero_flotante
fld numero_entero
fxch
fdiv
fstp @aux103
ffree
fld @INT17
fld @aux103
fxch
fmul
fstp @aux105
ffree
fld @aux105
fstp numero_entero
jmp _jump_114
_jump_109:
fld numero_entero
fld numero_entero
fxch
fadd
fstp @aux112
ffree
fld @aux112
fstp numero_entero
_jump_114:
jmp _jump_74
_jump_116:

MOV EAX, 4C00h
INT 21h

END START
