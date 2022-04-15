%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

int yyerror();
int yylex();
%}

%token PR_IF
%token PR_ELSE
%token PR_WHILE
%token PR_BETWEEN
%token PR_TAKE
%token PR_READ
%token PR_PRINT

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

%token CTE_INT
%token CTE_FLOAT
%token CTE_STRING

%token ID

%%
sentencia:  	   
  {printf(" FIN\n");};
%%

int main(int argc, char *argv[])
{
  if((yyin = fopen(argv[1], "rt"))==NULL)
  {
    printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
  }
  else
  {       
    yyparse();
  }
	fclose(yyin);
  return 0;
}
int yyerror(void)
{
  printf("Error sintactico\n");
  exit(1);
}

