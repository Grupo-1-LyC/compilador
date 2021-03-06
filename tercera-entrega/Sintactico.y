%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include "assembler.h"

int yystopparser=0;
FILE  *yyin;

//Array para almacenar el comparador a usar en una condición, ya que
//la regla del comparador se evalúa antes que las expresiones haciendo
//que el operador quede antes que el segundo operando en la notación polaca
char op_comparacion[4];

char op_matematico[2];

//Variable global para guardar la posicion de una condicion en el array de polaca
//y usarla en cada implementacion de una condicion (seleccion o iteracion)
int pos_condicion;

//Pila donde guardaremos las posiciones donde aplicar saltos en selecciones
t_pila pila;

//Pila para asignar los tipos a las variables
t_cpila pila_tipos;

//Defino una variable para guardar el lexema que voy a desapilar de pila_tipos
char lexema_guardado[100];

int cantidad_op;
int cantidad_cte;
int contador_take;

char msg_error[100];

char cte_polaca[32];

int yyerror();
int yylex();
char* conv_int_string(int);
char* conv_float_string(double);
void errorSemantico(char*);
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
    decvar programa {
        printf("\nRegla 'decvar programa' detectada\n"); 
        crear_archivo_ts(); 
        crear_archivo_intermedia(); 
        generar_assembler();
    } |
    programa {
        printf("\nRegla 'programa' detectada\n"); 
        crear_archivo_ts(); 
        crear_archivo_intermedia(); 
        generar_assembler();
    };

decvar:
    PR_DECVAR declaracion_variables PR_ENDDEC {printf("\nRegla 'PR_DECVAR declaracion_variables PR_ENDDEC' detectada");};

declaracion_variables:
    lista_variables DOS_PUNTOS tipo_dato {printf("\nRegla 'lista_variables DOS_PUNTOS tipo_dato' detectada");} |
    declaracion_variables lista_variables DOS_PUNTOS tipo_dato {printf("\nRegla 'declaracion_variables lista_variables DOS_PUNTOS tipo_dato' detectada");};

lista_variables:
    ID {
        if(lexema_esta_en_tabla($1) != -1){
            sprintf(msg_error, "La variable %s que esta queriendo declarar ya se encuentra declarada", $1);
            errorSemantico(msg_error);
        };
        cargar_simbolo($1, "ID"); 
        apilar_char(&pila_tipos, $1);} |
    lista_variables COMA ID {
        printf("\nRegla 'lista_variables COMA ID' detectada"); 
        if(lexema_esta_en_tabla($3) != -1){
            sprintf(msg_error, "La variable %s que esta queriendo declarar ya se encuentra declarada", $3);
            errorSemantico(msg_error);
        };
        cargar_simbolo($3, "ID"); 
        apilar_char(&pila_tipos, $3);};

tipo_dato:
    // Cuando se detecta algun tipo de dato entonces actualizo los IDs de la tabla de simbolos
    // que tenga apilados con el tipo de dato detectado
    PR_INTEGER {
        while(desapilar_char(&pila_tipos, lexema_guardado)){
            actualizar_tipo(lexema_guardado, "INT");
        };
    } | 
    PR_FLOAT {
        while(desapilar_char(&pila_tipos, lexema_guardado)){
            actualizar_tipo(lexema_guardado, "FLOAT");
        };
    } | 
    PR_STRING {        
        while(desapilar_char(&pila_tipos, lexema_guardado)){
            actualizar_tipo(lexema_guardado, "STRING");
        };
    };

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

id_op_asign:
    ID OP_ASIGN {
        if(lexema_esta_en_tabla($1) == -1){
            sprintf(msg_error, "La variable %s que esta queriendo usar no se encuentra declarada", $1);
            errorSemantico(msg_error);
        }
        cargar_simbolo($1, "ID"); 
        insertar_en_polaca($1); 
        strcpy(lexema_guardado, $1);
};

asignacion:
    id_op_asign expresion {
        printf("\nRegla 'ID OP_ASIGN expresion' detectada");
        /* Me fijo si el tipo es diferente a INT o FLOAT*/
        if(!lexema_es_del_tipo(lexema_guardado, "INT") && !lexema_es_del_tipo(lexema_guardado, "FLOAT")){
            errorSemantico("No se permiten asignaciones entre strings y int/float");
        }
        insertar_en_polaca(":=");
    } |
    /* Solo permitimos asignación de constantes string, no permitimos operaciones */
    id_op_asign CTE_STRING {
        printf("\nRegla 'ID OP_ASIGN CTE_STRING' detectada");
        /* Si lexema_es_del_tipo es 0 entonces significa que el lexama es de un tipo diferente a STRING*/
        if(!lexema_es_del_tipo(lexema_guardado, "STRING")){
            errorSemantico("No se permiten asignaciones entre int/float y strings");
        }
        cargar_simbolo($2, "CTE_STRING");
        sprintf(cte_polaca, "_%s", $2); 
        insertar_en_polaca(cte_polaca); 
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

constante_take:
    CTE_INT {
        cantidad_op = $1;
        contador_take = $1;
        cantidad_cte = 0;
        // Cast a string
        cargar_simbolo(conv_int_string($1), "CTE_INT");
        if(contador_take == 0){
            insertar_en_polaca("0");
        }
    };

factor:
    /* Según la sintaxis CTE_INT podría ser un número mayor o igual a la cantidad de constantes numericas de la lista pero consideramos que eso es un problema semántico */
    PR_TAKE PAR_A operador_matematico PUNTO_COMA constante_take PUNTO_COMA array PAR_C {
        printf("\nRegla 'PR_TAKE PAR_A operador_matematico PUNTO_COMA CTE_INT PUNTO_COMA array PAR_C' detectada");
        // Si el contador_take es positivo significa que la cantidad de constantes que me pasaron son menores a constante_take, por lo que hay que tirar error
        if(contador_take > 0 && cantidad_cte != 0){
            errorSemantico("La cantidad de elementos en la lista de constantes del take es menor a la cantidad de elementos que se quiere procesar");
        }
    } |
    PAR_A expresion PAR_C {printf("\nRegla 'PAR_A expresion PAR_C' detectada");} |
    /* Según la sintaxis ID podría ser un string pero consideramos que eso es un problema semántico */
    ID {
        if(lexema_esta_en_tabla($1) == -1){
            sprintf(msg_error, "La variable %s que esta queriendo usar no se encuentra declarada", $1);
            errorSemantico(msg_error);
        }
        /* Me fijo si el tipo es diferente a INT o FLOAT*/
        if(!lexema_es_del_tipo($1, "INT") && !lexema_es_del_tipo($1, "FLOAT")){
            errorSemantico("No se permiten asignaciones entre int/float y strings");
        }
        cargar_simbolo($1, "ID"); 
        insertar_en_polaca($1);         
    } |
    constante_numerica;

operador_matematico:
    OP_SUM {strcpy(op_matematico, "+");}|
    OP_RES {strcpy(op_matematico, "-");}|
    OP_MUL {strcpy(op_matematico, "*");}|
    OP_DIV {strcpy(op_matematico, "/");};

array:
    COR_A COR_C {printf("\nRegla 'COR_A COR_C' detectada");} |
    COR_A lista COR_C {printf("\nRegla 'COR_A lista COR_C' detectada");};

lista:
    constante_numerica_take |
    lista PUNTO_COMA constante_numerica_take {
        printf("\nRegla 'lista PUNTO_COMA constante_numerica' detectada");
        if(cantidad_op > 1){
            insertar_en_polaca(op_matematico);
            cantidad_op--;
        }
    };

constante_numerica:
    CTE_INT {
        // Cast a string
        cargar_simbolo(conv_int_string($1), "CTE_INT");
        sprintf(cte_polaca, "_%s", conv_int_string($1)); 
        insertar_en_polaca(cte_polaca);
    } |
    CTE_FLOAT {
        // Cast a string
        cargar_simbolo(conv_float_string($1), "CTE_FLOAT");
        sprintf(cte_polaca, "_%s", conv_float_string($1));
        insertar_en_polaca(cte_polaca);
    };

constante_numerica_take:
    CTE_INT {
        // Cast a string
        if(contador_take != 0){
            cargar_simbolo(conv_int_string($1), "CTE_INT");
            sprintf(cte_polaca, "_%s", conv_int_string($1)); 
            insertar_en_polaca(cte_polaca);
            contador_take--;
        }
        cantidad_cte++;
    } |
    CTE_FLOAT {
        // Cast a string
        if(contador_take != 0){
            cargar_simbolo(conv_float_string($1), "CTE_FLOAT");
            sprintf(cte_polaca, "_%s", conv_float_string($1));
            insertar_en_polaca(cte_polaca);
            contador_take--;
        }
        cantidad_cte++;
    };

while:
    PR_WHILE {
        printf("\nRegla 'PR_WHILE PAR_A condicion PAR_C LLAVE_A programa LLAVE_C' detectada");
        int pos = posicion_actual();
        apilar(&pila, &pos);
        insertar_en_polaca("_ET");
    };

iteracion:
    while PAR_A condicion_simple PAR_C LLAVE_A programa LLAVE_C {
        insertar_en_polaca("_BI");
        int tope_pila;
        desapilar(&pila, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
        desapilar(&pila, &tope_pila);
        insertar_en_polaca_posicion(pos, conv_int_string(tope_pila));
    } |
    while PAR_A condicion_simple OP_AND condicion_simple PAR_C LLAVE_A programa LLAVE_C {
        insertar_en_polaca("_BI");
        int tope_pila;
        desapilar(&pila, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
        desapilar(&pila, &tope_pila);
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
        desapilar(&pila, &tope_pila);
        insertar_en_polaca_posicion(pos, conv_int_string(tope_pila));
    } |
    while PAR_A condicion_simple OP_OR condicion_simple PAR_C LLAVE_A programa LLAVE_C {
        insertar_en_polaca("_BI");
        int tope_pila_izq;
        int tope_pila_der;
        int tope_pila;
        desapilar(&pila, &tope_pila_der);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila_der, conv_int_string(pos + 1));
        desapilar(&pila, &tope_pila_izq);
        negar_comparador(tope_pila_izq);
        insertar_en_polaca_posicion(tope_pila_izq, conv_int_string(tope_pila_der + 1));
        desapilar(&pila, &tope_pila);
        insertar_en_polaca_posicion(pos, conv_int_string(tope_pila));
    } |
    while PAR_A between PAR_C LLAVE_A programa LLAVE_C {
        insertar_en_polaca("_BI");
        int tope_pila;
        desapilar(&pila, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
        desapilar(&pila, &tope_pila);
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
        desapilar(&pila, &tope_pila);
        insertar_en_polaca_posicion(pos, conv_int_string(tope_pila));
    };

seleccion:
    PR_IF PAR_A condicion_simple PAR_C LLAVE_A programa LLAVE_C {
        printf("\nRegla 'PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C' detectada");
        int tope_pila;
        desapilar(&pila, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos));
    } |
    PR_IF PAR_A condicion_simple OP_AND condicion_simple PAR_C LLAVE_A programa LLAVE_C
    {
        printf("\nRegla 'PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C PR_ELSE LLAVE_A programa LLAVE_C' detectada");
        int tope_pila;
        desapilar(&pila, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos));
        desapilar(&pila, &tope_pila);
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos));
    } |
    PR_IF PAR_A condicion_simple OP_OR condicion_simple PAR_C LLAVE_A programa LLAVE_C
    {
        printf("\nRegla 'PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C PR_ELSE LLAVE_A programa LLAVE_C' detectada");
        int tope_pila_izq;
        int tope_pila_der;
        desapilar(&pila, &tope_pila_der);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila_der, conv_int_string(pos));
        desapilar(&pila, &tope_pila_izq);
        negar_comparador(tope_pila_izq);
        insertar_en_polaca_posicion(tope_pila_izq, conv_int_string(tope_pila_der + 1));
    } |
    PR_IF PAR_A between PAR_C LLAVE_A programa LLAVE_C
    {
        printf("\nRegla 'PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C PR_ELSE LLAVE_A programa LLAVE_C' detectada");
        int tope_pila;
        desapilar(&pila, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos));
        desapilar(&pila, &tope_pila);
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos));
    } |
    PR_IF PAR_A condicion_simple PAR_C LLAVE_A programa LLAVE_C
    {
        printf("\nRegla 'PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C PR_ELSE LLAVE_A programa LLAVE_C' detectada");
        insertar_en_polaca("_BI");
        int tope_pila;
        desapilar(&pila, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
        apilar(&pila, &pos);
        insertar_en_polaca("");
    }
    bloque_else |
    PR_IF PAR_A condicion_simple OP_AND condicion_simple PAR_C LLAVE_A programa LLAVE_C
    {
        printf("\nRegla 'PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C PR_ELSE LLAVE_A programa LLAVE_C' detectada");
        insertar_en_polaca("_BI");
        int tope_pila;
        desapilar(&pila, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
        desapilar(&pila, &tope_pila);
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
        apilar(&pila, &pos);
        insertar_en_polaca("");
    }
    bloque_else |
    PR_IF PAR_A condicion_simple OP_OR condicion_simple PAR_C LLAVE_A programa LLAVE_C
    {
        printf("\nRegla 'PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C PR_ELSE LLAVE_A programa LLAVE_C' detectada");
        insertar_en_polaca("_BI");
        int tope_pila_izq;
        int tope_pila_der;
        desapilar(&pila, &tope_pila_der);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila_der, conv_int_string(pos + 1));
        desapilar(&pila, &tope_pila_izq);
        negar_comparador(tope_pila_izq);
        insertar_en_polaca_posicion(tope_pila_izq, conv_int_string(tope_pila_der + 1));
        apilar(&pila, &pos);
        insertar_en_polaca("");
    }
    bloque_else |
    PR_IF PAR_A between PAR_C LLAVE_A programa LLAVE_C
    {
        printf("\nRegla 'PR_IF PAR_A condicion PAR_C LLAVE_A programa LLAVE_C PR_ELSE LLAVE_A programa LLAVE_C' detectada");
        insertar_en_polaca("_BI");
        int tope_pila;
        desapilar(&pila, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
        desapilar(&pila, &tope_pila);
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos + 1));
        apilar(&pila, &pos);
        insertar_en_polaca("");
    }
    bloque_else;

// El else se pone en una regla gramática aparte de la seleccion por limitaciones de Bison
// Bison da error si se tiene más de una acción semántica en una regla
bloque_else: 
    PR_ELSE LLAVE_A programa LLAVE_C { 
        int tope_pila;
        desapilar(&pila, &tope_pila);
        int pos = posicion_actual();
        insertar_en_polaca_posicion(tope_pila, conv_int_string(pos));
    };

id_between:
    ID {
        if(lexema_esta_en_tabla($1) == -1){
            sprintf(msg_error, "La variable %s que esta queriendo usar no se encuentra declarada", $1);
            errorSemantico(msg_error);
        }     
        // Si la variable no es del tipo INT y no es del tipo FLOAT entonces es un error semantico
        if(!lexema_es_del_tipo(lexema_guardado, "INT") && !lexema_es_del_tipo($1, "FLOAT")){
            errorSemantico("La variable del metodo BETWEEN tiene que ser una variable del tipo INT o FLOAT");
        }
        strcpy(lexema_guardado, $1);
    };

limite_inferior_between:
    expresion {
        insertar_en_polaca(lexema_guardado);
        insertar_en_polaca("_CMP");
        insertar_en_polaca("_BGT");
        pos_condicion = posicion_actual();
        apilar(&pila, &pos_condicion);
        insertar_en_polaca("");
    };

limite_superior_between:
    expresion {
        insertar_en_polaca(lexema_guardado);
        insertar_en_polaca("_CMP");
        insertar_en_polaca("_BLT");
        pos_condicion = posicion_actual();
        apilar(&pila, &pos_condicion);
        insertar_en_polaca("");
    };

between:
    /* Según la sintaxis ID podría ser un string pero consideramos que eso es un problema semántico */
    PR_BETWEEN PAR_A id_between COMA COR_A limite_inferior_between PUNTO_COMA limite_superior_between COR_C PAR_C {
        printf("\nRegla 'PR_BETWEEN PAR_A ID COMA COR_A expresion PUNTO_COMA expresion COR_C PAR_C' detectada");
    };

condicion_simple:
    OP_NOT expresion operador_comparacion expresion {
        printf("\nRegla 'OP_NOT condicion_simple' detectada");
        insertar_en_polaca("_CMP");
        insertar_en_polaca(op_comparacion);
        pos_condicion = posicion_actual();
        apilar(&pila, &pos_condicion);
        negar_comparador(pos_condicion - 1);
        insertar_en_polaca("");
    } |
    expresion operador_comparacion expresion {
        printf("\nRegla 'expresion operador_comparacion expresion' detectada");
        insertar_en_polaca("_CMP");
        insertar_en_polaca(op_comparacion);
        pos_condicion = posicion_actual();
        apilar(&pila, &pos_condicion);
        insertar_en_polaca("");
    };

operador_comparacion:
    OP_IGUAL {strcpy(op_comparacion, "_BNE");} |
    OP_DIF {strcpy(op_comparacion, "_BQE");} |
    OP_MAYOR {strcpy(op_comparacion, "_BLE");} |
    OP_MAYOR_I {strcpy(op_comparacion, "_BLT");} |
    OP_MENOR {strcpy(op_comparacion, "_BGE");} |
    OP_MENOR_I {strcpy(op_comparacion, "_BGT");};

salida:
    PR_WRITE mensaje {printf("\nRegla 'PR_WRITE mensaje' detectada"); insertar_en_polaca("WRITE");};

entrada:   
    PR_READ ID {
        if(lexema_esta_en_tabla($2) == -1){
            sprintf(msg_error, "La variable %s que esta queriendo usar no se encuentra declarada", $2);
            errorSemantico(msg_error);
        }
        printf("\nRegla 'PR_READ ID' detectada"); 
        cargar_simbolo($2, "ID"); 
        insertar_en_polaca($2); 
        insertar_en_polaca("READ");
    };

mensaje:
    ID {
        if(lexema_esta_en_tabla($1) == -1){
            sprintf(msg_error, "La variable %s que esta queriendo usar no se encuentra declarada", $1);
            errorSemantico(msg_error);
        }
        cargar_simbolo($1, "ID"); 
        insertar_en_polaca($1);
    } |
    constante_numerica |
    CTE_STRING {
        cargar_simbolo($1, "CTE_STRING"); 
        sprintf(cte_polaca, "_%s", $1); 
        insertar_en_polaca(cte_polaca);
    };

%%

int main(int argc, char *argv[]){

    if((yyin = fopen(argv[1], "rt"))==NULL){
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else{
        //Inicializamos las pilas donde guardaremos las posiciones donde aplicar saltos
        crear_pila(&pila);
        crear_pila_char(&pila_tipos);
        yyparse();
    }
    vaciar_pila(&pila);
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

char* conv_float_string(double n) {
    char *str = malloc(100 * sizeof(char));
    str[0] = '\0'; 
    sprintf(str, "%lf", n);
    return str;
}

void errorSemantico(char *error) {
    printf("\n¡ERROR SEMANTICO!: %s\n", error);
    exit(2);
}
