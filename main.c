/*
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * $ ./a.out 'foo=bar or foo=baz' 'foo=bar'
 * expr: 'foo=bar or foo=baz' k/v: foo=bar: True
 * $ ./a.out 'foo=bar or foo=*' 'foo=foo'
 * expr: 'foo=bar or foo=*' k/v: foo=foo: True
 * $ ./a.out 'foo=bar or foo2=*' 'foo2=foo'
 * expr: 'foo=bar or foo2=*' k/v: foo2=foo: True
 * $ ./a.out 'foo=bar and foo2=baz' 'foo2=foo'
 * expr: 'foo=bar and foo2=baz' k/v: foo2=foo: False
 * $ ./a.out 'foo=bar and foo2=baz' 'foo2=baz foo=bar'
 * expr: 'foo=bar and foo2=baz' k/v: foo2=baz foo=bar: True
 * $ ./a.out 'foo=bar or foo=baz and foo2=baz' 'foo=bar'
 * expr: 'foo=bar or foo=baz and foo2=baz' k/v: foo=bar: True
 * $ ./a.out '(foo=bar or foo=baz) and foo2=baz' 'foo=bar'
 * expr: '(foo=bar or foo=baz) and foo2=baz' k/v: foo=bar: False
 *
 * Rule := (ExpectedKV | "(" Rule ")"),  { ' ', (AND|OR), ' ', Rule } ;
 * ExpectedKV := Key, "=", Value ;
 * Key := <string>
 * Value := <string> | '*' ;
 * AND := "and" | "AND" ;
 * OR := "or" | "OR" ;
 */

void usage()
{
    fprintf(stdout, "./a.out 'expr' 'k=v k=v [k=v..]'\n");
    exit(-1);
}

int acceptchar(char c, char **expr)
{
    if (c == **expr) {
        (*expr)++;
        return 1;
    }
    return 0;
}

int expectchar(char c, char **expr)
{
    if (acceptchar(c, expr)) {
        return 1;
    }
    fprintf(stdout, "expected \'%c\'\n", c);
    return 0;
}

int termchar(char c)
{
    return (c == ' ' || c == ')' || c == '\0');
}

int ExpectedKV(char **expr, char **keys, char **vals)
{
    int i, r = 0;
    char *k_end = NULL, *v_end = NULL, *val = NULL, *key = NULL;
    size_t v_len = 0, k_len = 0;

    k_end = key = *expr;
    while (*k_end != '=') {
        if (termchar(*k_end)) {
            fprintf(stdout, "key=value error\n");
            return -1;
        }
        k_end++;
    }

    k_len = k_end - key;
    if (k_len == 0) {
        fprintf(stdout, "key error\n");
        return -1;
    }

    v_end = k_end;
    val = ++v_end;
    while (!termchar(*v_end)) {
        v_end++;
    }

    v_len = v_end - val;
    if (v_len == 0) {
        fprintf(stdout, "value error\n");
        return -1;
    }

    for (i = 0; keys[i] != NULL && vals[i] != NULL; i++) {
        if (strncmp(key, keys[i], k_len) != 0) {
            continue;
        }
        if ((*val == '*') || (strncmp(val, vals[i], v_len) == 0)) {
            r = 1;
            break;
        }
    }
    *expr = v_end;
    return r;
}

int OR(char **expr)
{
    char *c = *expr;
    int r = ((c[0] != '\0' && (c[0] == 'o' || c[0] == 'O')) &&
             (c[1] != '\0' && (c[1] == 'r' || c[1] == 'R')));
    if (r) {
        *expr = c + 2;
    }
    return r;
}

int AND(char **expr)
{
    char *c = *expr;
    int r = ((c[0] != '\0' && (c[0] == 'a' || c[0] == 'A')) &&
             (c[1] != '\0' && (c[1] == 'n' || c[1] == 'N')) &&
             (c[2] != '\0' && (c[2] == 'd' || c[2] == 'D')));
    if (r) {
        *expr = c + 3;
    }
    return r;
}

int Rule(char **expr, char **keys, char **vals)
{
    int r = 0;

    if (acceptchar('(', expr)) {
        r = Rule(expr, keys, vals);
        if (!expectchar(')', expr)) {
            fprintf(stdout, "expected closing paren\n");
            return -1;
        }
    } else {
        r = ExpectedKV(expr, keys, vals);
        if (r == -1) {
            return r;
        }
    }

    /* Check for an ' OR|AND ' continuation.. */
    if (acceptchar(' ', expr)) {
        int r2 = 0;
        if (OR(expr)) {
            if (!expectchar(' ', expr)) {
                fprintf(stdout, "expected space after operator\n");
                return -1;
            }
            r2 = Rule(expr, keys, vals);
            if (r2 == -1) {
                return r2;
            }
            r = r2 || r;
        } else if (AND(expr)) {
            if (!expectchar(' ', expr)) {
                fprintf(stdout, "expected space after operator\n");
                return -1;
            }
            r2 = Rule(expr, keys, vals);
            if (r2 == -1) {
                return r2;
            }
            r = r2 && r;
        } else {
            fprintf(stdout, "expected OR/AND\n");
            return -1;
        }
    }
    return r;
}

int main(int argc, char *argv[])
{
    int ret = -1;
    int i = 0;
    char *expr, *keys[10] = { 0 }, *vals[10] = { 0 };
    char *kvs = NULL;

    if (argc < 3)
        usage();

    printf("expr: \'%s\' k/v: %s: ", argv[1], argv[2]);
    expr = argv[1];

    kvs = strtok(argv[2], " ");
    while (kvs && i < 10) {
        char *v = strchr(kvs, '=');
        if (v == NULL) {
            usage();
        }
        *v++ = '\0';
        keys[i] = kvs;
        vals[i++] = v;
        v = strchr(v, ' ');
        if (v != NULL) {
            *v = '\0';
        }

        kvs = strtok(NULL, " ");
    }

    ret = Rule(&expr, keys, vals);
    if (ret == 1) {
        printf("True\n");
        exit(0);
    } else if (ret == 0) {
        printf("False\n");
        exit(1);
    }
    if (ret == -1)
        ret = 44;
    exit(ret);
}
