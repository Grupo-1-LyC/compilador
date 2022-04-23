%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

int yyerror();
int yylex();
%}

%union {
    int int_val;
    double float_val;
    char *str_val;
}

%type <int_val> CTE_INT
%type <float_val> CTE_FLOAT
%type <str_val> ID CTE_STRING

%token PR_IF
%token PR_ELSE
%token PR_WHILE
%token PR_BETWEEN
%token PR_TAKE
%token PR_READ
%token PR_WRITE
%token PR_DECVAR
%token PR_ENDDEC

%token PR_INTEGER
%token PR_FLOAT
%token PR_STRING

%token OP_ASIGN

%token OP_SUM
%token OP_MUL
%token OP_RES
%token OP_DIV

%token OP_AND
%token OP_OR
%token OP_NOT

%token OP_IGUAL
%token OP_DIF
%token OP_MENOR
%token OP_MAYOR
%token OP_MENOR_I
%token OP_MAYOR_I

%token PAR_A
%token PAR_C
%token COR_A
%token COR_C
%token LLAVE_A
%token LLAVE_C

%token DOS_PUNTOS
%token COMA
%token PUNTO_COMA

%token CTE_INT
%token CTE_FLOAT
%token CTE_STRING

%token ID

%%
p:
    /* Establecemos que al principio del archivo se debe hacer la declaración de variables*/
    decvar programa {printf("\nRegla 'decvar programa' detectada");} |
    programa {printf("\nRegla 'programa' detectada");};

decvar:
    PR_DECVAR declaracion_variables PR_ENDDEC {printf("\nRegla 'PR_DECVAR declaracion_variables PR_ENDDEC' detectada");};

declaracion_variables:
    lista_variables DOS_PUNTOS tipo_dato {printf("\nRegla 'lista_variables DOS_PUNTOS tipo_dato' detectada");} |
    declaracion_variables lista_variables DOS_PUNTOS tipo_dato {printf("\nRegla 'declaracion_variables lista_variables DOS_PUNTOS tipo_dato' detectada");};

lista_variables:
    ID |
    lista_variables COMA ID {printf("\nRegla 'lista_variables COMA ID' detectada");};

tipo_dato:
    PR_INTEGER | 
    PR_FLOAT | 
    PR_STRING;

programa: 
    bloque;

bloque:
    sentencia |
    bloque sentencia;

sentencia:
	asignacion PUNTO_COMA |
    iteracion |
    seleccion |
    salida PUNTO_COMA |
    entrada PUNTO_COMA;

asignacion:
    ID OP_ASIGN expresion {printf("\nRegla 'ID OP_ASIGN expresion' detectada");} |
    /* Solo permitimos asignación de constantes string, no permitimos operaciones */
    ID OP_ASIGN CTE_STRING {printf("\nRegla 'ID OP_ASIGN CTE_STRING' detectada");};

expresion:
    expresion OP_SUM termino {printf("\nRegla 'expresion OP_SUM termino' detectada");} |
    expresion OP_RES termino {printf("\nRegla 'expresion OP_RES termino' detectada");} |
    termino;

termino:
    termino OP_MUL factor {printf("\nRegla 'termino OP_MUL factor' detectada");} |
    termino OP_DIV factor {printf("\nRegla 'termino OP_DIV factor' detectada");} |
    factor;

factor:
    /* Según la sintaxis CTE_INT podría ser un número mayor o igual a la cantidad de constantes numericas de la lista pero consideramos que eso es un problema semántico */
    PR_TAKE PAR_A operador_matematico PUNTO_COMA CTE_INT PUNTO_COMA array PAR_C {printf("\nRegla 'PR_TAKE PAR_A operador_matematico PUNTO_COMA CTE_INT PUNTO_COMA array PAR_C' detectada");} |
    PAR_A expresion PAR_C {printf("\nRegla 'PAR_A expresion PAR_C' detectada");} |
    /* Según la sintaxis ID podría ser un string pero consideramos que eso es un problema semántico */
    ID |
    constante_numerica;

operador_matematico:
    OP_SUM |
    OP_RES |
    OP_MUL |
    OP_DIV;

array:
    COR_A COR_C {printf("\nRegla 'COR_A COR_C' detectada");} |
    COR_A lista COR_C {printf("\nRegla 'COR_A lista COR_C' detectada");};

lista:
    constante_numerica |
    lista PUNTO_COMA constante_numerica {printf("\nRegla 'lista PUNTO_COMA constante_numerica' detectada");};

constante_numerica:
    CTE_INT |
    CTE_FLOAT;

iteracion:
    PR_WHILE PAR_A condicion PAR_C LLAVE_A programa LLAVE_C {printf("\nRegla 'PR_WHILE PAR_A condicion PAR_C LLAVE_A programa LLAVE_C' detectada");};

seleccion:
    PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C {printf("\nRegla 'PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C' detectada");} |
    PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C PR_ELSE LLAVE_A programa LLAVE_C {printf("\nRegla 'PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C PR_ELSE LLAVE_A programa LLAVE_C' detectada");};

condicion:
    condicion_simple |
    condicion_multiple;

condicion_multiple:
    condicion_simple OP_AND condicion_simple {printf("\nRegla 'condicion_simple OP_AND condicion_simple' detectada");} |
    condicion_simple OP_OR condicion_simple {printf("\nRegla 'condicion_simple OP_OR condicion_simple' detectada");};

condicion_simple:
    /* Según la sintaxis ID podría ser un string pero consideramos que eso es un problema semántico */
    PR_BETWEEN PAR_A ID COMA COR_A expresion PUNTO_COMA expresion COR_C PAR_C {printf("\nRegla 'PR_BETWEEN PAR_A ID COMA COR_A expresion PUNTO_COMA expresion COR_C PAR_C' detectada");} |
    /* Hacemos recursividad a derecha porque el NOT tiene que estar a la derecha de la condición y permitimos múltiples negaciones */
    OP_NOT condicion_simple {printf("\nRegla 'OP_NOT condicion_simple' detectada");} |
    expresion operador_comparacion expresion {printf("\nRegla 'expresion operador_comparacion expresion' detectada");};

operador_comparacion:
    OP_IGUAL |
    OP_DIF |
    OP_MAYOR |
    OP_MAYOR_I |
    OP_MENOR |
    OP_MENOR_I;

salida:
    PR_WRITE mensaje {printf("\nRegla 'PR_WRITE mensaje' detectada");};

entrada:   
    PR_READ ID {printf("\nRegla 'PR_READ ID' detectada");};

mensaje:
    ID |
    constante_numerica |
    CTE_STRING;

%%

int main(int argc, char *argv[]){

    if((yyin = fopen(argv[1], "rt"))==NULL){
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else{
        yyparse();
    }
    fclose(yyin);
    return 0;
}

int yyerror(void){
  printf("\nError sintactico\n");
  exit(1);
}

