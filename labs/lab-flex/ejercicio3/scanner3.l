%pointer
%option noyywrap

%{
#include <stdio.h>
#include "misfunciones.h"

/* Variable global para contar los tokens reconocidos */
int contadorTokens = 0;
%}

letra           [a-zA-Z_]
digito          [0-9]
identificador   {letra}({letra}|{digito})*

%%

{identificador}  {
    contadorTokens++;
    printf("identificador: %s\n", yytext);
}

[ \t\n]         { }

.               { printf("caracter no reconocido: %s\n", yytext); }

%%

int main(void) {
    yylex();

    printf("Tokens totales: %d\n", contadorTokens);
    printf("El doble es: %d\n", duplicar(contadorTokens));

    return 0;
}