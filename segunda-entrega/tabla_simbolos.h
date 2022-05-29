#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

int cargar_simbolo(char*, char*);

typedef struct {
    char nombre[100]; // Lexema que identifica el token
    char tipo[14]; // Tipo de dato del token
    int posicion_ocupada; // Bandera que identifica un registro de la tabla como ocupado
    int longitud; // Cantidad de caracteres de una constante string
    char valor[100];
} t_simbolo;

t_simbolo tabla_simbolos[100];

void crear_archivo_ts(void) {
	FILE *fp;
	int x;
	fp = fopen("ts.txt", "w+");
	if(fp == NULL){
		fputs ("File error",stderr); 
		exit (1);
	}
	fprintf(fp, "NOMBRE\t|\tTIPO\t|\tVALOR\t|\tLONGITUD\n");
	for(x=0; x<100; x++){
        if(tabla_simbolos[x].posicion_ocupada)
            fprintf(fp, "%s\t|\t%s\t|\t%s\t|\t%d\n", tabla_simbolos[x].nombre, tabla_simbolos[x].tipo, tabla_simbolos[x].valor, tabla_simbolos[x].longitud);
        else
            break;
	}
	fclose(fp);
	
    printf("\n\nSe ha cerrado el archivo y la Tabla de Simbolos fue cargada sin errores.\n");
        
}

int cargar_simbolo(char *nombre, char *val){
    // Retorna la posición del símbolo en la tabla
    int x;
    // Declaro un array que contenga el nombre más un guión
    char nombreConGuion[strlen(nombre)+2];    

    for(x=0; x<100; x++){
        // Primero determino si el registro en la tabla está ocupado con un símbolo
        // Para de estar forma solo trabajar con los registros válidos
        if(tabla_simbolos[x].posicion_ocupada==1){
            if(strcmp(nombre, tabla_simbolos[x].nombre)==0){
                return x;
            }
        }
    }
        
    for(x=0; x<100; x++){
        // Primero determino si el registro en la tabla está vacío (no tiene un símbolo)
        if(tabla_simbolos[x].posicion_ocupada==0){
            // Determino si CTE está dentro de val para cubrir los 3 casos de constantes
            // CTE_INT, CTE_FLOAT, CTE_STRING
            if(strstr(val, "CTE")){
                strcpy(nombreConGuion, "_");
                // Agrego el guión al principio del nombre 
                strcat(nombreConGuion, nombre);
                strcpy(tabla_simbolos[x].nombre, nombreConGuion);
                strcpy(tabla_simbolos[x].valor, nombre);
                // Si es constante string guardo su longitud
                if(strstr(val, "STRING")){
                    tabla_simbolos[x].longitud = strlen(nombre) - 2; // Se resta dos para descartar las comillas
                }
            }
            else{
                strcpy(tabla_simbolos[x].nombre, nombre);
            }
            strcpy(tabla_simbolos[x].tipo, val);
            tabla_simbolos[x].posicion_ocupada = 1;

            return x;
        }
    }
		
	return x;
 }

int actualizar_tipo(char *nombre, char *val){

    for(int x=0; x<100; x++){
        // Me fijo si el 'nombre' que me pasaron ya esta en la tabla.
        // En caso de estar en la tabla le acambio el tipo por el tipo que me pasaron
        if(tabla_simbolos[x].posicion_ocupada==1){
            if(strcmp(nombre, tabla_simbolos[x].nombre)==0){
                strcpy(tabla_simbolos[x].tipo, val);
                return x;
            }
        }
    }

    return -1;
}