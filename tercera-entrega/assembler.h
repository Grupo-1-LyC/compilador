#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "tabla_simbolos.h"
#include "polaca_inversa.h"

void generar_assembler(void);
void cargar_data_assembler(FILE*);
void generar_codigo_assembler(FILE*);

void generar_assembler(void) {
	FILE *fp;
	int x, i;
	fp = fopen("Final.asm", "w+");
	if (fp == NULL) {
		fputs("File error", stderr); 
		exit(1);
	}
	
    fprintf(fp, "include macros2.asm\n");
    fprintf(fp, "include number.asm\n\n");          
    fprintf(fp, ".MODEL LARGE\n");
    fprintf(fp, ".386\n");
    fprintf(fp, ".STACK 200h\n");
    cargar_data_assembler(fp);
    generar_codigo_assembler(fp);
    fprintf(fp, "\n");
    fprintf(fp, "MOV EAX, 4C00h\n");
    fprintf(fp, "INT 21h\n\n");
    fprintf(fp, "END START");
    fprintf(fp, "\n");
	fclose(fp);
	
    printf("\n\nSe ha cerrado el archivo y Final.asm fue generado sin errores.\n");
}

void cargar_data_assembler(FILE* fp){
    fprintf(fp, ".DATA\n\n");

    for(int x=0; x<100; x++){
        if(tabla_simbolos[x].posicion_ocupada == 1){
            if(strcmp("INT", tabla_simbolos[x].tipo) == 0){
                // Me fijo si es una constante para agregarle el índice
                if(tabla_simbolos[x].nombre[0] == '_'){
                    fprintf(fp, "@int%d \tdd %.4f\n", x, atof(tabla_simbolos[x].valor));
                }
                else{
                    fprintf(fp, "%s \tdd ?\n", tabla_simbolos[x].nombre);
                }
            }
            else if(strcmp("FLOAT", tabla_simbolos[x].tipo) == 0)
            {
                // Me fijo si es una constante para agregarle el índice
                if(tabla_simbolos[x].nombre[0] == '_'){
                    fprintf(fp, "@float%d \tdd %.4f\n", x, atof(tabla_simbolos[x].valor));
                }
                else{
                    fprintf(fp, "%s \tdd ?\n", tabla_simbolos[x].nombre);
                }
            }
            else if(strcmp("STRING", tabla_simbolos[x].tipo) == 0)
            {
                // Me fijo si es una constante para agregarle el índice
                if(tabla_simbolos[x].nombre[0] == '_'){
                    fprintf(fp, "@string%d \tdb %s, \"$\", 30 dup (?)\n", x, tabla_simbolos[x].valor);
                }
                else{
                    fprintf(fp, "%s \tdb ?\n", tabla_simbolos[x].nombre, tabla_simbolos[x].valor);
                }
            }
        }
        else{
            break;
        }    		
	}
    for(int x=0; x<1000; x++){
        if(polaca_inversa[x].posicion_ocupada){
            if(strcmp("+", polaca_inversa[x].valor) == 0 || 
               strcmp("-", polaca_inversa[x].valor) == 0 || 
               strcmp("*", polaca_inversa[x].valor) == 0 ||
               strcmp("/", polaca_inversa[x].valor) == 0) {
               fprintf(fp, "@aux%d \tdd ?\n", x, polaca_inversa[x].valor);
            }
        }
        else
            break;
    }
}

void generar_codigo_assembler(FILE* fp){
    fprintf(fp, "\n.CODE\n\n");
    fprintf(fp, "START:\n");
    fprintf(fp, "MOV EAX, @DATA\n");
    fprintf(fp, "MOV DS, EAX\n");
    fprintf(fp, "MOV ES, EAX\n\n");
    /*
    int pos=0;
    while(polaca_inversa[pos].posicion_ocupada == 1){

        //Si esta en la tabla de simbolos significa que es un operando
        // Hay que ver la forma de solucionar el caso de claves que estan en el array de la polaca pero no son variables ej ET
        if(lexema_esta_en_tabla(polaca_inversa[pos].valor)){
            fprintf(fp,"fld %s", polaca_inversa[pos].valor)
        }
        else{
            if(polaca_inversa[pos].valor == '-')
                fprintf(fp,"fsub")
            if(polaca_inversa[pos].valor == '+')
                fprintf(fp,"fsum")
            if(polaca_inversa[pos].valor == '*')
                fprintf(fp,"fmul")
            if(polaca_inversa[pos].valor == '/')
                fprintf(fp,"fdiv")
            if(polaca_inversa[pos].valor == ':=')
                fprintf(fp,"fsub")
        }
        pos++;
    }*/
}

/*int es_operando(){
    char nombreConGuion[strlen(terceto.t1)+1];        
    strcpy(nombreConGuion, "_"); 
    strcat(nombreConGuion, terceto.t1);

    if ( strcmp(simbolo[x].nombre, terceto.t1) == 0 && simbolo[x].flag==1)
    {
        switch (simbolo[x].tipoDato)
            {
            case 5:
            case 6:
                return 20;
                break;
            
            default:
                return 1;
                break;
            }
    }else{
        if ( strcmp(simbolo[x].nombre, nombreConGuion) == 0 && simbolo[x].flag==1)
        {
            switch (simbolo[x].tipoDato)
            {
            case 5:
            case 6:
                return 19;
                break;
            
            default:
                return 2;
                break;
            }
        }
    }
}*/
