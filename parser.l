%{
#include <string.h>
#include "parser.tab.h"
%}

%%

"(" { return LPAREN; }
")" { return RPAREN; }
" " { return SPACE; }
"or" { return OR; }
"OR" { return OR; }
"and" { return AND; }
"AND" { return AND; }
"=" { return EQUAL; }
"*" { return AST; }
[A-Za-z_\-0-9]+ {
	yylval.sval = strdup(yytext);
	return STRING;
}

%%
