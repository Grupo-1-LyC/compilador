#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "pila_dinamica.h"
#include "polaca_inversa.h"
#include "tabla_simbolos.h"

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
    // Cargo en tabla de símbolos las variables auxiliares que voy a necesitar
    char auxiliar[100];
    for(int x=0; x<1000; x++){
        if(polaca_inversa[x].posicion_ocupada){
            if(strcmp("+", polaca_inversa[x].valor) == 0 || 
               strcmp("-", polaca_inversa[x].valor) == 0 || 
               strcmp("*", polaca_inversa[x].valor) == 0 ||
               strcmp("/", polaca_inversa[x].valor) == 0) {
               sprintf(auxiliar, "@aux%d", x);
               cargar_simbolo(auxiliar, "FLOAT");
            }
        }
        else
            break;
    }
    for(int x=0; x<100; x++){
        if(tabla_simbolos[x].posicion_ocupada == 1){
            if(strcmp("INT", tabla_simbolos[x].tipo) == 0){
                // Me fijo si es una constante para agregarle el índice
                if(tabla_simbolos[x].nombre[0] == '_'){
                    fprintf(fp, "@%s%d \tdd %.4f\n", tabla_simbolos[x].tipo, x, atof(tabla_simbolos[x].valor));
                }
                else{
                    fprintf(fp, "%s \tdd ?\n", tabla_simbolos[x].nombre);
                }
            }
            else if(strcmp("FLOAT", tabla_simbolos[x].tipo) == 0)
            {
                // Me fijo si es una constante para agregarle el índice
                if(tabla_simbolos[x].nombre[0] == '_'){
                    fprintf(fp, "@%s%d \tdd %.4f\n", tabla_simbolos[x].tipo, x, atof(tabla_simbolos[x].valor));
                }
                else{
                    fprintf(fp, "%s \tdd ?\n", tabla_simbolos[x].nombre);
                }
            }
            else if(strcmp("STRING", tabla_simbolos[x].tipo) == 0)
            {
                // Me fijo si es una constante para agregarle el índice
                if(tabla_simbolos[x].nombre[0] == '_'){
                    fprintf(fp, "@%s%d \tdb %s, \"$\", 30 dup (?)\n", tabla_simbolos[x].tipo, x, tabla_simbolos[x].valor);
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
}

void generar_codigo_assembler(FILE* fp){
    fprintf(fp, "\n.CODE\n\n");
    fprintf(fp, "START:\n");
    fprintf(fp, "MOV EAX, @DATA\n");
    fprintf(fp, "MOV DS, EAX\n");
    fprintf(fp, "MOV ES, EAX\n\n");
    t_cpila pila_operandos;
    crear_pila_char(&pila_operandos);
    int pos=0;
    char operando[100];
    char auxiliar[100];
    int pos_lexema;
    int saltos[1000] = {};
    while(polaca_inversa[pos].posicion_ocupada == 1){
        
        if(saltos[pos]){
            fprintf(fp, "_jump_%d:\n", pos);
        }

        // Si esta en la tabla de simbolos significa que es un operando
        pos_lexema = lexema_esta_en_tabla(polaca_inversa[pos].valor);
        if(pos_lexema != -1){
            if(polaca_inversa[pos].valor[0] == '_'){
                sprintf(auxiliar, "@%s%d", tabla_simbolos[pos_lexema].tipo, pos_lexema);
                apilar_char(&pila_operandos, auxiliar);
            }
            else{
                apilar_char(&pila_operandos, polaca_inversa[pos].valor);
            }
        }
        else if(strcmp("-", polaca_inversa[pos].valor) == 0){
            desapilar_char(&pila_operandos, operando);
            fprintf(fp, "fld %s\n", operando);
            desapilar_char(&pila_operandos, operando);
            fprintf(fp, "fld %s\n", operando);
            fprintf(fp, "fxch\n");
            fprintf(fp, "fsub\n");
            fprintf(fp, "fstp @aux%d\n", pos);
            sprintf(auxiliar, "@aux%d", pos);
            apilar_char(&pila_operandos, auxiliar);
            fprintf(fp, "ffree\n");
        }
        else if(strcmp("+", polaca_inversa[pos].valor) == 0){
            desapilar_char(&pila_operandos, operando);
            fprintf(fp, "fld %s\n", operando);
            desapilar_char(&pila_operandos, operando);
            fprintf(fp, "fld %s\n", operando);
            fprintf(fp, "fxch\n");
            fprintf(fp, "fadd\n");
            fprintf(fp, "fstp @aux%d\n", pos);
            sprintf(auxiliar, "@aux%d", pos);
            apilar_char(&pila_operandos, auxiliar);
            fprintf(fp, "ffree\n");
        }
        else if(strcmp("*", polaca_inversa[pos].valor) == 0){
            desapilar_char(&pila_operandos, operando);
            fprintf(fp, "fld %s\n", operando);
            desapilar_char(&pila_operandos, operando);
            fprintf(fp, "fld %s\n", operando);
            fprintf(fp, "fxch\n");
            fprintf(fp, "fmul\n");
            fprintf(fp, "fstp @aux%d\n", pos);
            sprintf(auxiliar, "@aux%d", pos);
            apilar_char(&pila_operandos, auxiliar);
            fprintf(fp, "ffree\n");
        }
        else if(strcmp("/", polaca_inversa[pos].valor) == 0){
            desapilar_char(&pila_operandos, operando);
            fprintf(fp, "fld %s\n", operando);
            desapilar_char(&pila_operandos, operando);
            fprintf(fp, "fld %s\n", operando);
            fprintf(fp, "fxch\n");
            fprintf(fp, "fdiv\n");
            fprintf(fp, "fstp @aux%d\n", pos);
            sprintf(auxiliar, "@aux%d", pos);
            apilar_char(&pila_operandos, auxiliar);
            fprintf(fp, "ffree\n");
        }
        else if(strcmp(":=", polaca_inversa[pos].valor) == 0){
            desapilar_char(&pila_operandos, operando);
            if(strstr(operando, "STRING")){
               fprintf(fp, "MOV  SI, OFFSET %s\n", operando);
               desapilar_char(&pila_operandos, operando);
               fprintf(fp, "MOV  DI, OFFSET %s\n", operando);
               fprintf(fp, "STRCPY\n");
            }
            else{
                fprintf(fp, "fld %s\n", operando);
                desapilar_char(&pila_operandos, operando);
                fprintf(fp, "fstp %s\n", operando);
            }
        }
        else if(strcmp("WRITE", polaca_inversa[pos].valor) == 0){
            desapilar_char(&pila_operandos, operando);
            if(strstr(operando, "STRING")){
               fprintf(fp, "displayString %s\n", operando);
            }
            else if(strstr(operando, "FLOAT")){
               fprintf(fp, "displayFloat %s,4\n", operando);
            }
            else if(strstr(operando, "INT")){
               fprintf(fp, "displayFloat %s,0\n", operando);
            }
            else if(lexema_es_del_tipo(operando, "STRING")){
               fprintf(fp, "displayString %s\n", operando);
            }
            else if(lexema_es_del_tipo(operando, "FLOAT")){
               fprintf(fp, "displayFloat %s,4\n", operando);
            }
            else if(lexema_es_del_tipo(operando, "INT")){
               fprintf(fp, "displayFloat %s,0\n", operando);
            }
            fprintf(fp, "newLine\n");
        }
        else if(strcmp("READ", polaca_inversa[pos].valor) == 0){
            desapilar_char(&pila_operandos, operando);
            if(strstr(operando, "STRING")){
               fprintf(fp, "getString %s\n", operando);
            }
            else if(strstr(operando, "FLOAT")){
               fprintf(fp, "getFloat %s,4\n", operando);
            }
            else if(strstr(operando, "INT")){
               fprintf(fp, "getFloat %s,0\n", operando);
            }
            else if(lexema_es_del_tipo(operando, "STRING")){
               fprintf(fp, "getString %s\n", operando);
            }
            else if(lexema_es_del_tipo(operando, "FLOAT")){
               fprintf(fp, "getFloat %s,4\n", operando);
            }
            else if(lexema_es_del_tipo(operando, "INT")){
               fprintf(fp, "getFloat %s,0\n", operando);
            }
        }
        else if(strcmp("_CMP", polaca_inversa[pos].valor) == 0){
            desapilar_char(&pila_operandos, operando);
            fprintf(fp, "fld %s\n", operando);
            desapilar_char(&pila_operandos, operando);
            fprintf(fp, "fld %s\n", operando);
            fprintf(fp, "fcomp\n");
        }
        else if(strcmp("_BNE", polaca_inversa[pos].valor) == 0){
            fprintf(fp, "fstsw ax\n");
            fprintf(fp, "sahf\n");
            fprintf(fp, "ffree\n");
            pos++;
            fprintf(fp, "jne _jump_%d\n", atoi(polaca_inversa[pos].valor));
            saltos[atoi(polaca_inversa[pos].valor)] = 1;
        }
        else if(strcmp("_BQE", polaca_inversa[pos].valor) == 0){
            fprintf(fp, "fstsw ax\n");
            fprintf(fp, "sahf\n");
            fprintf(fp, "ffree\n");
            pos++;
            fprintf(fp, "je _jump_%d\n", atoi(polaca_inversa[pos].valor));
            saltos[atoi(polaca_inversa[pos].valor)] = 1;
        }
        else if(strcmp("_BLE", polaca_inversa[pos].valor) == 0){
            fprintf(fp, "fstsw ax\n");
            fprintf(fp, "sahf\n");
            fprintf(fp, "ffree\n");
            pos++;
            fprintf(fp, "jna _jump_%d\n", atoi(polaca_inversa[pos].valor));
            saltos[atoi(polaca_inversa[pos].valor)] = 1;
        }
        else if(strcmp("_BLT", polaca_inversa[pos].valor) == 0){
            fprintf(fp, "fstsw ax\n");
            fprintf(fp, "sahf\n");
            fprintf(fp, "ffree\n");
            pos++;
            fprintf(fp, "jb _jump_%d\n", atoi(polaca_inversa[pos].valor));
            saltos[atoi(polaca_inversa[pos].valor)] = 1;
        }
        else if(strcmp("_BGE", polaca_inversa[pos].valor) == 0){
            fprintf(fp, "fstsw ax\n");
            fprintf(fp, "sahf\n");
            fprintf(fp, "ffree\n");
            pos++;
            fprintf(fp, "jae _jump_%d\n", atoi(polaca_inversa[pos].valor));
            saltos[atoi(polaca_inversa[pos].valor)] = 1;
        }
        else if(strcmp("_BGT", polaca_inversa[pos].valor) == 0){
            fprintf(fp, "fstsw ax\n");
            fprintf(fp, "sahf\n");
            fprintf(fp, "ffree\n");
            pos++;
            fprintf(fp, "ja _jump_%d\n", atoi(polaca_inversa[pos].valor));
            saltos[atoi(polaca_inversa[pos].valor)] = 1;
        }
        else if(strcmp("_BI", polaca_inversa[pos].valor) == 0){
            pos++;
            fprintf(fp, "jmp _jump_%d\n", atoi(polaca_inversa[pos].valor));
            saltos[atoi(polaca_inversa[pos].valor)] = 1;
        }
        else if(strcmp("_ET", polaca_inversa[pos].valor) == 0){
            fprintf(fp, "_jump_%d:\n", pos);
        }
        pos++;
    }
    if(saltos[pos]){
        fprintf(fp, "_jump_%d:\n", pos);
    }
    vaciar_pila_char(&pila_operandos);
}
