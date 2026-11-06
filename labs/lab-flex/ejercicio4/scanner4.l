%pointer
%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>

/* Definición de tokens */
enum yytokentype {
    NUMBER = 258,
    IDENT = 259
};

int yylval;
%}

digito          [0-9]
letra           [a-zA-Z_]
identificador   {letra}({letra}|{digito})*

%%

{digito}+  {
    yylval = atoi(yytext);
    printf("TOKEN NUMBER (%d) valor=%d\n", NUMBER, yylval);
    return NUMBER;
}

"+"  { printf("TOKEN '+'\n"); return '+'; }
"-"  { printf("TOKEN '-'\n"); return '-'; }
"*"  { printf("TOKEN '*'\n"); return '*'; }
"/"  { printf("TOKEN '/'\n"); return '/'; }

{identificador} {
    printf("TOKEN IDENT (%d) lexema=%s\n", IDENT, yytext);
    return IDENT;
}

[ \t\n]  { }

.  { printf("caracter no reconocido: %s\n", yytext); }

%%

int main(void) {
    int token;
    while ((token = yylex()) != 0) { }
    return 0;
}