#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

void crearArchivoTS(void);
int cargarEnTS(char*,int);
void asignarValorConstante(void);
//enum tipoDato {VACIO,INT,CTE_INT, REAL, CTE_REAL, STRING, CTE_STRING,ID};
char tipo[9][14]={"","ENTERO", "CTE ENTERA","REAL","CTE REAL","STRING","CTE STRING","ID", "CONST"};

typedef struct {
    char nombre[100]; // Nombre del token
    char tipo[14];  // Tipo de Dato
    int  tipoDato; // Manejo interno del tipo tipo[14]
    int flag;  // Para saber si el token fue almacenado o no en la TS
    char valor[100];
} tsimbolo; // tabla de simbolos


// Tabla de simbolos
tsimbolo simbolo[100];

// Funciones generales de la TS ------------------------------------------------------------------------

void crearArchivoTS(void) {
	FILE *fp;
	int x;
	fp = fopen ( "ts.txt", "w+" );
	if (fp == NULL) {
		fputs ("File error",stderr); 
		exit (1);
	}
	    
	for (x = 0; x < 100; x++)
    {
        if( simbolo[x].tipoDato != 0 )
            fprintf(fp, "%s\t%s\t%s\n", simbolo[x].nombre, simbolo[x].tipo, simbolo[x].valor);
        else
            break;
    		
	}
	fclose(fp);
	
    printf("\n\nSe ha cerrado el archivo y la Tabla de Simbolos fue cargada sin errores.\n");
        
 }

int cargarEnTS ( char *nombre, int val ){
    int x;
	int l_repetido=0;
    char nombreConGuion[strlen(nombre)+1];    

    for (x=0; x<100; x++ ){
        if (simbolo[x].flag==1){//para saber si el token ya esta en la tabla
            if (strcmp (nombre,simbolo[x].nombre)==0){
                return x;
                
            }
        }
    }
        
    for (x=0; x<100 ; x++){
        if(simbolo[x].flag==0){

            if(strstr(tipo[val],"CTE")){
                
                strcpy(nombreConGuion, "_");   
                strcat(nombreConGuion, nombre);
                strcpy(simbolo[x].nombre,nombreConGuion);
                strcpy(simbolo[x].valor,nombre);
            }else{
                strcpy(simbolo[x].nombre,nombre);
            }
            
            strcpy(simbolo[x].tipo,tipo[val]);
            simbolo[x].tipoDato=val;
            simbolo[x].flag=1;//para indicar que ya se almaceno en la tabla

            return x;
        }
    }
		
	return x;
 }//retorna posicion en la tabla de simbolos
 
 void asignarValorConstante()
 {
     int x;
     for (x=0; x<99; x++ ){
        if (simbolo[x].flag==1){//para saber si el token ya esta en la tabla
            if (simbolo[x].tipoDato==8){
                char *aux=simbolo[x+1].nombre;
                strcpy(simbolo[x].valor,++aux);//valor reconocido                
            }
        }
    }
 }


