%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex(void);
typedef struct yy_buffer_state * YY_BUFFER_STATE;
extern void yyerror(const char **keys, const char **vals,
		    int *status, const char *s);
extern int yyparse(const char **keys, const char **vals, int *status);
extern YY_BUFFER_STATE yy_scan_string(char * str);
extern void yy_delete_buffer(YY_BUFFER_STATE buffer);
%}

%union {
	char *sval;
	int ival;
}

%token LPAREN
%token RPAREN
%token SPACE
%token OR
%token AND
%token EQUAL
%token AST
%token STRING
%token INT

%type <sval> STRING
%type <ival> INT rule rule_start expectedkv

%parse-param {const char **keys} {const char **vals} {int *status}

%%

expr: rule {
    *status = $1;
    }
    ;

rule: rule_start
    | rule_start SPACE AND SPACE rule {
      $$ = $1 && $5;
      }
    | rule_start SPACE OR SPACE rule {
      $$ = $1 || $5;
      }
    ;

rule_start: LPAREN rule RPAREN {
	    $$ = $2;
	    }
	  | expectedkv { 
	    $$ = $1;
            }
	  ;

expectedkv: STRING EQUAL STRING {
	    int i, ret = 0;
	    for (i = 0; keys[i] != NULL && vals[i] != NULL; i++) {
                if (strcmp($1, keys[i]) != 0) {
		    continue;
		}
		if (strcmp($3, vals[i]) == 0) {
		    ret = 1;
	            break;
                }
	    }
	    $$ = ret;
	    }
	  | STRING EQUAL AST {
	    int i, ret = 0;
	    for (i = 0; keys[i] != NULL && vals[i] != NULL; i++) {
                if (strcmp($1, keys[i]) == 0) {
		    ret = 1;
		    break;
		}
	    }
	    $$ = ret;
	    }
	  ;

%%

void usage(void)
{
    fprintf(stdout, "./a.out 'expr' 'k=v k=v [k=v..]'\n");
    exit(-1);
}

int parse_expected_na_expr(const char *expr, const char **name_attrs,
			   const char **attr_vals, int *status)
{
	int ret;
	YY_BUFFER_STATE buffer = yy_scan_string((char *)expr);
	ret = yyparse(name_attrs, attr_vals, status);
	yy_delete_buffer(buffer);
	return ret;
}

int main(int argc, char *argv[])
{
	int ret, status = -1, j = 0;
	char *kvs = NULL;
	const char *keys[10] = { 0 };
	const char *vals[10] = { 0 };

	if (argc < 3) {
		usage();
	}

	printf("expr: %s, attrs: %s\n", argv[1], argv[2]);
	kvs = strtok(argv[2], " ");
	while (kvs && j < 10) {
		char *v = strchr(kvs, '=');
		if (v == NULL) {
		    usage();
		}
		*v++ = '\0';
		keys[j] = kvs;
		vals[j++] = v;
		v = strchr(v, ' ');
		if (v != NULL) {
		    *v = '\0';
		}

		kvs = strtok(NULL, " ");
	}
	ret = parse_expected_na_expr(argv[1], keys, vals, &status);
	if (ret == 0) {
		if (status == 0) {
			printf("False\n");
			ret = 1;
		} else if (status == 1) {
			printf("True\n");
			ret = 0;
		} else {
			printf("return err!\n");
			ret = 44;
		}

	} else {
		printf("yyparse err %d\n", ret);
		ret = 1;
	}
	exit(ret);
}

void yyerror(const char **keys, const char **vals, int *status,
	     const char *s)
{
	fprintf(stdout, "parse error message: %s\n", s);
	exit(1);
}
