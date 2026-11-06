%pointer
%option noyywrap

%%

0[0-7]*         { printf("constante octal: %s\n", yytext); }

[1-9][0-9]*     { printf("constante decimal: %s\n", yytext); }

0[xX][0-9a-fA-F]+ { printf("constante hexadecimal: %s\n", yytext); }

[a-zA-Z_][a-zA-Z0-9_]* { printf("identificador: %s\n", yytext); }

[ \t\n]         { }

.               { printf("caracter no reconocido: %s\n", yytext); }

%%

int main(void) {
    yylex();
    return 0;
}