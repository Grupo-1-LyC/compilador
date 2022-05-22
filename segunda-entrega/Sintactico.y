%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include "tabla_simbolos.h"
#include "polaca_inversa.h"
#include "PILAdinamica.h"

int yystopparser=0;
FILE  *yyin;

//Array para almacenar el comparador a usar en una condición, ya que
//la regla del comparador se evalúa antes que las expresiones haciendo
//que el operador quede antes que el segundo operando en la notación polaca
char op_comparacion[4];

//Variable global para guardar la posicion de una condicion en el array de polaca
//y usarla en cada implementacion de una condicion (seleccion o iteracion)
int pos_condicion;

//Pila donde guardaremos las posiciones donde aplicar saltos en selecciones
t_pila pila_seleccion;
//Pila donde guardaremos las posiciones donde aplicar saltos en iteraciones
t_pila pila_iteracion;

int yyerror();
int yylex();
char* conv_int_string(int);
%}

%union {
    int int_val;
    double float_val;
    char *str_val;
}

%type <int_val> CTE_INT
%type <float_val> CTE_FLOAT
%type <str_val> ID CTE_STRING

/*=====Palabras reservadas=====*/
%token PR_IF
%token PR_ELSE
%token PR_WHILE
%token PR_BETWEEN
%token PR_TAKE
%token PR_READ
%token PR_WRITE
%token PR_DECVAR
%token PR_ENDDEC

/*=====Tipos de datos=====*/
%token PR_INTEGER
%token PR_FLOAT
%token PR_STRING

/*======Operador asignación======*/
%token OP_ASIGN
/*======Operadores matemáticos======*/
%token OP_SUM
%token OP_MUL
%token OP_RES
%token OP_DIV
/*======Operadores lógicos======*/
%token OP_AND
%token OP_OR
%token OP_NOT
/*======Operadores comparación======*/
%token OP_IGUAL
%token OP_DIF
%token OP_MENOR
%token OP_MAYOR
%token OP_MENOR_I
%token OP_MAYOR_I

/*======Agrupadores======*/
%token PAR_A
%token PAR_C
%token COR_A
%token COR_C
%token LLAVE_A
%token LLAVE_C

/*======Caracteres especiales======*/
%token DOS_PUNTOS
%token COMA
%token PUNTO_COMA

/*======Constantes======*/
%token CTE_INT
%token CTE_FLOAT
%token CTE_STRING

/*======Identificador======*/
%token ID

%%
p:
    /* Establecemos que al principio del archivo se debe hacer la declaración de variables*/
    decvar programa {printf("\nRegla 'decvar programa' detectada\n"); crear_archivo_ts(); crear_archivo_intermedia();} |
    programa {printf("\nRegla 'programa' detectada\n"); crear_archivo_ts(); crear_archivo_intermedia();};

decvar:
    PR_DECVAR declaracion_variables PR_ENDDEC {printf("\nRegla 'PR_DECVAR declaracion_variables PR_ENDDEC' detectada");};

declaracion_variables:
    lista_variables DOS_PUNTOS tipo_dato {printf("\nRegla 'lista_variables DOS_PUNTOS tipo_dato' detectada");} |
    declaracion_variables lista_variables DOS_PUNTOS tipo_dato {printf("\nRegla 'declaracion_variables lista_variables DOS_PUNTOS tipo_dato' detectada");};

lista_variables:
    ID {cargar_simbolo($1, "ID");} |
    lista_variables COMA ID {printf("\nRegla 'lista_variables COMA ID' detectada"); cargar_simbolo($3, "ID");};

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
    ID OP_ASIGN expresion {
        printf("\nRegla 'ID OP_ASIGN expresion' detectada"); 
        cargar_simbolo($1, "ID"); 
        insertar_en_polaca($1); 
        insertar_en_polaca(":=");
    } |
    /* Solo permitimos asignación de constantes string, no permitimos operaciones */
    ID OP_ASIGN CTE_STRING {
        printf("\nRegla 'ID OP_ASIGN CTE_STRING' detectada"); 
        cargar_simbolo($1, "ID"); 
        cargar_simbolo($3, "CTE_STRING"); 
        insertar_en_polaca($1); 
        insertar_en_polaca(":=");
    };

expresion:
    expresion OP_SUM termino {printf("\nRegla 'expresion OP_SUM termino' detectada"); insertar_en_polaca("+");} |
    expresion OP_RES termino {printf("\nRegla 'expresion OP_RES termino' detectada"); insertar_en_polaca("-");} |
    termino;

termino:
    termino OP_MUL factor {printf("\nRegla 'termino OP_MUL factor' detectada"); insertar_en_polaca("*");} |
    termino OP_DIV factor {printf("\nRegla 'termino OP_DIV factor' detectada"); insertar_en_polaca("/");} |
    factor;

factor:
    /* Según la sintaxis CTE_INT podría ser un número mayor o igual a la cantidad de constantes numericas de la lista pero consideramos que eso es un problema semántico */
    PR_TAKE PAR_A operador_matematico PUNTO_COMA CTE_INT PUNTO_COMA array PAR_C {
        printf("\nRegla 'PR_TAKE PAR_A operador_matematico PUNTO_COMA CTE_INT PUNTO_COMA array PAR_C' detectada");
        // Cast a string
        char valorString[100];
        sprintf(valorString, "%d", $5);
        cargar_simbolo(valorString, "CTE_INT");
    } |
    PAR_A expresion PAR_C {printf("\nRegla 'PAR_A expresion PAR_C' detectada");} |
    /* Según la sintaxis ID podría ser un string pero consideramos que eso es un problema semántico */
    ID {cargar_simbolo($1, "ID"); insertar_en_polaca($1);} |
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
    CTE_INT {
        // Cast a string
        char valorString[100];
        sprintf(valorString, "%d", $1);
        cargar_simbolo(valorString, "CTE_INT");
        insertar_en_polaca(valorString);
    } |
    CTE_FLOAT {
        // Cast a string
        char valorString[100];
        sprintf(valorString, "%lf", $1);
        cargar_simbolo(valorString, "CTE_FLOAT");
        insertar_en_polaca(valorString);
    };

iteracion:
    PR_WHILE {
        printf("\nRegla 'PR_WHILE PAR_A condicion PAR_C LLAVE_A programa LLAVE_C' detectada");
        int pos = posicion_actual();
        apilar(&pila_iteracion, &pos);
        insertar_en_polaca("ET");
    } PAR_A condicion_iteracion PAR_C cuerpo_iteracion;

// El cuerpo de la iteracion se pone en una regla gramática aparte de la iteracion por limitaciones de Bison
// Bison da error si se tiene más de una acción semántica en una regla
cuerpo_iteracion:
    LLAVE_A programa LLAVE_C {
        insertar_en_polaca("BI");
        int tope_pila;
        desapilar(&pila_iteracion, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
        desapilar(&pila_iteracion, &tope_pila);
        insertar_en_polaca_posicion(pos, conv_int_string(tope_pila));
    };

seleccion:
    PR_IF PAR_A condicion_seleccion PAR_C LLAVE_A programa LLAVE_C {
        printf("\nRegla 'PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C' detectada");
        int tope_pila;
        desapilar(&pila_seleccion, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
    } |
    PR_IF PAR_A condicion_seleccion PAR_C LLAVE_A programa LLAVE_C
    {
        printf("\nRegla 'PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C PR_ELSE LLAVE_A programa LLAVE_C' detectada");
        insertar_en_polaca("BI");
        int tope_pila;
        desapilar(&pila_seleccion, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
        apilar(&pila_seleccion, &pos);
        insertar_en_polaca("");
    }
    bloque_else;

// El else se pone en una regla gramática aparte de la seleccion por limitaciones de Bison
// Bison da error si se tiene más de una acción semántica en una regla
bloque_else: 
    PR_ELSE LLAVE_A programa LLAVE_C { 
        int tope_pila;
        desapilar(&pila_seleccion, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
    };

// Separamos condiciones de seleccion de las de iteracion porque manejarán pilas distintas
condicion_seleccion:
    condicion {
        apilar(&pila_seleccion, &pos_condicion);
    };

condicion_iteracion:
    condicion {
        apilar(&pila_iteracion, &pos_condicion);
    };

condicion:
    condicion_simple |
    condicion_multiple;

condicion_multiple:
    condicion_simple OP_AND condicion_simple {printf("\nRegla 'condicion_simple OP_AND condicion_simple' detectada");} |
    condicion_simple OP_OR condicion_simple {printf("\nRegla 'condicion_simple OP_OR condicion_simple' detectada");};

condicion_simple:
    /* Según la sintaxis ID podría ser un string pero consideramos que eso es un problema semántico */
    PR_BETWEEN PAR_A ID COMA COR_A expresion PUNTO_COMA expresion COR_C PAR_C {
        printf("\nRegla 'PR_BETWEEN PAR_A ID COMA COR_A expresion PUNTO_COMA expresion COR_C PAR_C' detectada"); 
        cargar_simbolo($3, "ID");
    } |
    /* Hacemos recursividad a derecha porque el NOT tiene que estar a la derecha de la condición y permitimos múltiples negaciones */
    OP_NOT condicion_simple {printf("\nRegla 'OP_NOT condicion_simple' detectada");} |
    expresion operador_comparacion expresion {
        printf("\nRegla 'expresion operador_comparacion expresion' detectada");
        insertar_en_polaca("CMP");
        insertar_en_polaca(op_comparacion);
        pos_condicion = posicion_actual();
        insertar_en_polaca("");
    };

operador_comparacion:
    OP_IGUAL {strcpy(op_comparacion, "BNE");} |
    OP_DIF {strcpy(op_comparacion, "BQE");} |
    OP_MAYOR {strcpy(op_comparacion, "BLE");} |
    OP_MAYOR_I {strcpy(op_comparacion, "BLT");} |
    OP_MENOR {strcpy(op_comparacion, "BGE");} |
    OP_MENOR_I {strcpy(op_comparacion, "BGT");};

salida:
    PR_WRITE mensaje {printf("\nRegla 'PR_WRITE mensaje' detectada"); insertar_en_polaca("WRITE");};

entrada:   
    PR_READ ID {printf("\nRegla 'PR_READ ID' detectada"); cargar_simbolo($2, "ID"); insertar_en_polaca($2); insertar_en_polaca("READ");};

mensaje:
    ID {cargar_simbolo($1, "ID"); insertar_en_polaca($1);} |
    constante_numerica |
    CTE_STRING {cargar_simbolo($1, "CTE_STRING"); insertar_en_polaca($1);};

%%

int main(int argc, char *argv[]){

    if((yyin = fopen(argv[1], "rt"))==NULL){
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else{
        //Inicializamos las pilas donde guardaremos las posiciones donde aplicar saltos
        crear_pila(&pila_seleccion);
        crear_pila(&pila_iteracion);
        yyparse();
    }
    vaciar_pila(&pila_seleccion);
    vaciar_pila(&pila_iteracion);
    fclose(yyin);
    return 0;
}

int yyerror(void){
  printf("\n¡ERROR SINTACTICO!\n");
  exit(1);
}

char* conv_int_string(int ent) {
    char *str = malloc(100 * sizeof(char));
    str[0] = '\0'; 
    sprintf(str, "%d", ent);
    return str;
}

