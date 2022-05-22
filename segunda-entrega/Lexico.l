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
PREGUNTA_A      "¿"
PREGUNTA_C      "?"
EXCLAMACION_A   "¡"
EXCLAMACION_C   "!"
ESPACIO         " "
IGUAL           "="

/*======Constantes======*/
CTE_INT		    {OP_RES}?{DIGITO}+
CTE_FLOAT       {OP_RES}?({DIGITO}+{PUNTO}?{DIGITO}*|{DIGITO}*{PUNTO}?{DIGITO}+)
CTE_STRING      {COMILLA_D}.*{COMILLA_D}

/*======Identificador======*/
ID			    {LETRA}({LETRA}|{GUION_BAJO}|{DIGITO})*

/*======Comentario======*/
COMENTARIO      {COMENT_A}({DIGITO}*|{LETRA}*|{GUION_BAJO}*|{PUNTO}*|{DOS_PUNTOS}*|{COMA}*|{PUNTO_COMA}*|{COMILLA_D}*|{ESPACIO}*|{PREGUNTA_A}*|{PREGUNTA_C}*|{EXCLAMACION_A}*|{EXCLAMACION_C}*|{PAR_A}*|{PAR_C}*|{COR_A}*|{COR_C}*|{LLAVE_A}*|{LLAVE_C}*|{OP_MAYOR}*|{OP_MENOR}*|{OP_SUM}*|{OP_RES}*|{OP_DIV}*|{OP_MUL}*|{IGUAL}*)*{COMENT_C}

%%
{PR_IF}             {return PR_IF;}
{PR_ELSE}           {return PR_ELSE;}
{PR_WHILE}          {return PR_WHILE;}
{PR_BETWEEN}        {return PR_BETWEEN;}
{PR_TAKE}           {return PR_TAKE;}
{PR_READ}           {return PR_READ;}
{PR_WRITE}          {return PR_WRITE;}
{PR_DECVAR}         {return PR_DECVAR;}
{PR_ENDDEC}         {return PR_ENDDEC;}

{PR_INTEGER}        {return PR_INTEGER;}
{PR_FLOAT}          {return PR_FLOAT;}
{PR_STRING}         {return PR_STRING;}

{OP_ASIGN}   		{return OP_ASIGN;}

{OP_SUM}		    {return OP_SUM;}
{OP_MUL}            {return OP_MUL;}
{OP_RES}		    {return OP_RES;}
{OP_DIV}            {return OP_DIV;}

{OP_AND}            {return OP_AND;}
{OP_OR}             {return OP_OR;}
{OP_NOT}            {return OP_NOT;}

{OP_IGUAL}          {return OP_IGUAL;}
{OP_DIF}            {return OP_DIF;}
{OP_MENOR}          {return OP_MENOR;}
{OP_MAYOR}          {return OP_MAYOR;}
{OP_MENOR_I}        {return OP_MENOR_I;}
{OP_MAYOR_I}        {return OP_MAYOR_I;}

{PAR_A}             {return PAR_A;}
{PAR_C}             {return PAR_C;}
{COR_A}             {return COR_A;}
{COR_C}             {return COR_C;}
{LLAVE_A}           {return LLAVE_A;}
{LLAVE_C}           {return LLAVE_C;}

{DOS_PUNTOS}        {return DOS_PUNTOS;}
{COMA}              {return COMA;}
{PUNTO_COMA}        {return PUNTO_COMA;}

{CTE_INT}           { 
                        if(strtol(yytext, (char **)NULL, 10) < MININT || strtol(yytext, (char **)NULL, 10) > MAXINT){
                            sprintf(msg_error, "Constante INTEGER %s fuera de rango. Minimo permitido %d. Maximo permitido %d", yytext, MININT, MAXINT);
                            errorLexico(msg_error);
                        }
                        else{   
                            yylval.int_val=strtol(yytext, (char **)NULL, 10);
                            return CTE_INT;
                        }
                    }
{CTE_FLOAT}         {
                        if(atof(yytext) < MINFLOAT || atof(yytext) > MAXFLOAT){
                            sprintf(msg_error, "Constante FLAOT %s fuera de rango. Minimo permitido %f. Maximo permitido %f", yytext, MINFLOAT, MAXFLOAT);
                            errorLexico(msg_error);
                        }
                        else{
                            yylval.float_val=atof(yytext);
                            return CTE_FLOAT;
                        }
                    }
{CTE_STRING}        {
                        // Chequeamos la longitud del string descontando las comillas dobles 
                        if(strlen(yytext) - 2 > MAXSTRING) {
                            sprintf(msg_error, "Constante STRING %s excede la maxima longitud permitida. Maximo permitido: %d", yytext, MAXSTRING);
                            errorLexico(msg_error);
                        }
                        yylval.str_val=yytext;
                        return CTE_STRING;
                    }

{ID}                {
                        if(strlen(yytext) > MAXLEXEMA){
                            sprintf(msg_error, "Identificador de la variable %s excede la maxima longitud permitida. Maximo permitido: %d", yytext, MAXLEXEMA);
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
    printf("\n¡ERROR LEXICO!: %s\n", error);
    exit(2);
}
