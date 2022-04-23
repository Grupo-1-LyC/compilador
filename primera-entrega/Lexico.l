%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"

int yylval;
char *yyltext;

char msg_error[100];

void errorLexico(char *error);

%}

%option noyywrap
%option yylineno

/*=====Palabras reservadas=====*/
PR_IF           "IF"
PR_ELSE         "ELSE"
PR_WHILE        "WHILE"
PR_BETWEEN      "BETWEEN"
PR_TAKE         "TAKE"
PR_READ         "READ"
PR_PRINT        "WRITE"
PR_DECVAR       "DECVAR"
PR_ENDDEC       "ENDDEC"
/* Falta definir si aplicarán los tipos de dato*/
PR_INTEGER      "INTEGER"
PR_FLOAT        "FLOAT"
PR_STRING       "STRING"

/*======Operador asignación======*/
OP_ASIGN   		"="
/*======Operadores matemáticos======*/
OP_SUM		    "+"
OP_MUL          "*"
OP_RES		    "-"
OP_DIV          "/"
/*======Operadores lógicos======*/
OP_AND          "and"
OP_OR           "or"
OP_NOT          "not"
/*======Operadores comparación======*/
OP_IGUAL        "=="
OP_DIF          "!="
OP_MENOR        "<"
OP_MAYOR        ">"
OP_MENOR_I      "<="
OP_MAYOR_I      ">="

/*======Agrupadores======*/
PAR_A           "("
PAR_C           ")"
COR_A           "["
COR_C           "]"
LLAVE_A         "{"
LLAVE_C         "}"          

/*======Conjuntos======*/
DIGITO			[0-9]
LETRA			[a-zA-Z]

/*======Caracteres especiales======*/
GUION_BAJO      "_"
PUNTO           "."
COMILLA_D       "\""
COMENT_A        "/*"
COMENT_C        "*/"

/*======Constantes======*/
CTE_INT		    {DIGITO}+
CTE_FLOAT       {DIGITO}+{PUNTO}?{DIGITO}*
/*A definir si es así*/
CTE_STRING      {COMILLA_D}.*{COMILLA_D}

/*======Identificador======*/
ID			    {LETRA}({LETRA}|{GUION_BAJO}|{DIGITO})*

/*======Comentario======*/
/*A definir si es así*/
COMENTARIO      {COMENT_A}.*{COMENT_C}

%%
{PR_IF}             {printf("\nPR_IF: %s\n", yytext);return PR_IF;}
{PR_ELSE}           {printf("\nPR_ELSE: %s\n", yytext);return PR_ELSE;}
{PR_WHILE}          {printf("\nPR_WHILE: %s\n", yytext);return PR_WHILE;}
{PR_BETWEEN}        {printf("\nPR_BETWEEN: %s\n", yytext);return PR_BETWEEN;}
{PR_TAKE}           {printf("\nPR_TAKE: %s\n", yytext);return PR_TAKE;}
{PR_READ}           {printf("\nPR_READ: %s\n", yytext);return PR_READ;}
{PR_PRINT}          {printf("\nPR_PRINT: %s\n", yytext);return PR_PRINT;}

{PR_INTEGER}        {printf("\nPR_INTEGER: %s\n", yytext);return PR_INTEGER;}
{PR_FLOAT}          {printf("\nPR_FLOAT: %s\n", yytext);return PR_FLOAT;}
{PR_STRING}         {printf("\nPR_STRING: %s\n", yytext);return PR_STRING;}

{OP_ASIGN}   		{printf("\nOP_ASIGN: %s\n", yytext);return OP_ASIGN;}

{OP_SUM}		    {printf("\nOP_SUM: %s\n", yytext);return OP_SUM;}
{OP_MUL}            {printf("\nOP_MUL: %s\n", yytext);return OP_MUL;}
{OP_RES}		    {printf("\nOP_RES: %s\n", yytext);return OP_RES;}
{OP_DIV}            {printf("\nOP_DIV: %s\n", yytext);return OP_DIV;}

{OP_AND}            {printf("\nOP_AND: %s\n", yytext);return OP_AND;}
{OP_OR}             {printf("\nOP_OR: %s\n", yytext);return OP_OR;}
{OP_NOT}            {printf("\nOP_NOT: %s\n", yytext);return OP_NOT;}

{OP_IGUAL}          {printf("\nOP_IGUAL: %s\n", yytext);return OP_IGUAL;}
{OP_DIF}            {printf("\nOP_DIF: %s\n", yytext);return OP_DIF;}
{OP_MENOR}          {printf("\nOP_MENOR: %s\n", yytext);return OP_MENOR;}
{OP_MAYOR}          {printf("\nOP_MAYOR: %s\n", yytext);return OP_MAYOR;}
{OP_MENOR_I}        {printf("\nOP_MENOR_I: %s\n", yytext);return OP_MENOR_I;}
{OP_MAYOR_I}        {printf("\nOP_MAYOR_I: %s\n", yytext);return OP_MAYOR_I;}

{PAR_A}             {printf("\nPAR_A: %s\n", yytext);return PAR_A;}
{PAR_C}             {printf("\nPAR_C: %s\n", yytext);return PAR_C;}
{COR_A}             {printf("\nCOR_A: %s\n", yytext);return COR_A;}
{COR_C}             {printf("\nCOR_C: %s\n", yytext);return COR_C;}
{LLAVE_A}           {printf("\nLLAVE_A: %s\n", yytext);return LLAVE_A;}
{LLAVE_C}           {printf("\nLLAVE_C: %s\n", yytext);return LLAVE_C;}

{CTE_INT}           {printf("\nCTE_INT: %s\n", yytext);return CTE_INT;}
{CTE_FLOAT}         {printf("\nCTE_FLOAT: %s\n", yytext);return CTE_FLOAT;}
{CTE_STRING}        {printf("\nCTE_STRING: %s\n", yytext);return CTE_STRING;}

{ID}                {printf("\nID: %s\n", yytext);return ID;}

{COMENTARIO}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.			        {sprintf(msg_error, "Caracter no reconocido %s", yytext);errorLexico(msg_error);}
%%

void errorLexico(char *error) {
    printf("Error léxico: %s\n", error);
    exit(2);
}
