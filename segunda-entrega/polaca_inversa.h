#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdio.h>

typedef struct {
    char valor[100];
    int posicion_ocupada; // Bandera que identifica un registro del array como ocupado
} t_polaca;

t_polaca polaca_inversa[1000];

void crear_archivo_intermedia(void) {
	FILE *fp;
	int x;
	fp = fopen("intermedia.txt", "w+");
	if(fp == NULL){
		fputs ("File error",stderr); 
		exit (1);
	}
	// Escribimos el contenido del array en polaca inversa a un archivo con separador por comas
	for(x=0; x<1000; x++){
        if(x == 0)
            fprintf(fp, "%s", polaca_inversa[x].valor);
        else if(polaca_inversa[x].posicion_ocupada)
            fprintf(fp, ",%s", polaca_inversa[x].valor);
        else
            break;
	}
	fclose(fp);
	
    printf("\n\nSe ha cerrado el archivo y la Notacion Intermedia Polaca Inversa fue cargada sin errores.\n");
        
}

void insertar_en_polaca(char *valor) {
    for(int x=0; x<1000; x++){
        if(!polaca_inversa[x].posicion_ocupada){
            strcpy(polaca_inversa[x].valor, valor);
            polaca_inversa[x].posicion_ocupada = 1;
            break;
        }
    }
}