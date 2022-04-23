%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

char *yyltext;

char msg_error[100];
int MAXLEXEMA = 100;
char lexema[100];

int MAXINT = 32768;
int MININT = -32768;

float MAXFLOAT = 2147483648;
float MINFLOAT = -2147483648;

int MAXSTRING = 30;

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
PR_WRITE        "WRITE"
PR_DECVAR       "DECVAR"
PR_ENDDEC       "ENDDEC"

/*=====Tipos de datos=====*/
PR_INTEGER      "INTEGER"
PR_FLOAT        "FLOAT"
PR_STRING       "STRING"

/*======Operador asignación======*/
OP_ASIGN   		":="
/*======Operadores matemáticos======*/
OP_SUM		    "+"
OP_MUL          "*"
OP_RES		    "-"
OP_DIV          "/"
/*======Operadores lógicos======*/
OP_AND          "AND"
OP_OR           "OR"
OP_NOT          "NOT"
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
DOS_PUNTOS      ":"
COMA            ","
PUNTO_COMA      ";"
COMILLA_D       "\""
COMENT_A        "-/"
COMENT_C        "/-"

/*======Constantes======*/
CTE_INT		    {OP_RES}?{DIGITO}+
CTE_FLOAT       {OP_RES}?({DIGITO}+{PUNTO}?{DIGITO}*|{DIGITO}*{PUNTO}?{DIGITO}+)
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
{PR_WRITE}          {printf("\nPR_WRITE: %s\n", yytext);return PR_WRITE;}
{PR_DECVAR}         {printf("\nPR_DECVAR: %s\n", yytext);return PR_DECVAR;}
{PR_ENDDEC}         {printf("\nPR_ENDDEC: %s\n", yytext);return PR_ENDDEC;}

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

{DOS_PUNTOS}        {printf("\nDOS_PUNTOS: %s\n", yytext);return DOS_PUNTOS;}
{COMA}              {printf("\nCOMA: %s\n", yytext);return COMA;}
{PUNTO_COMA}        {printf("\nPUNTO_COMA: %s\n", yytext);return PUNTO_COMA;}

{CTE_INT}           { 
                        if(strtol(yytext, (char **)NULL, 10) < MININT || strtol(yytext, (char **)NULL, 10) > MAXINT){
                            sprintf(msg_error, "Constante INTEGER %s fuera de rango. Mínimo permitido %d. Máximo permitido %d", yytext, MININT, MAXINT);
                            errorLexico(msg_error);
                        }
                        else{   
                            yylval.int_val=strtol(yytext, (char **)NULL, 10);
                            return CTE_INT;
                        }
                    }
{CTE_FLOAT}         {
                        if(atof(yytext) < MINFLOAT || atof(yytext) > MAXFLOAT){
                            sprintf(msg_error, "Constante FLAOT %s fuera de rango. Mínimo permitido %f. Máximo permitido %f", yytext, MINFLOAT, MAXFLOAT);
                            errorLexico(msg_error);
                        }
                        else{
                            yylval.float_val=atof(yytext);
                            return CTE_FLOAT;
                        }
                    }
{CTE_STRING}        {
                        if(strlen(yytext) > MAXSTRING) {
                            sprintf(msg_error, "Constante STRING %s excede la máxima longitud permitida. Máximo permitido: %d", yytext, MAXSTRING);
                            errorLexico(msg_error);
                        }
                        yylval.str_val=yytext;
                        return CTE_STRING;
                    }

{ID}                {
                        if(strlen(yytext) > MAXLEXEMA){
                            sprintf(msg_error, "Identificador de la variable %s excede la máxima longitud permitida. Máximo permitido: %d", yytext, MAXLEXEMA);
                            errorLexico(msg_error);
                        } 
                        sprintf(lexema, "%s", yytext);
                        yylval.str_val=lexema;
                        return ID;
                    }

{COMENTARIO}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.			        {
                        sprintf(msg_error, "Caracter %s no reconocido", yytext);
                        errorLexico(msg_error);
                    }
%%

void errorLexico(char *error) {
    printf("\nERROR LÉXICO: %s\n", error);
    exit(2);
}
