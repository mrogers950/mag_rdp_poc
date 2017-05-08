An example of a recursive descent parser for evaluating a set of key=value pairs
against a boolean logic expression.  The EBNF for this expression is:

```
  Rule := (ExpectedKV | "(" Rule ")"),  { ' ', (AND|OR), ' ', Rule } ;
  ExpectedKV := Key, "=", Value ;
  Key := <string>
  Value := <string> | '*' ;
  AND := "and" | "AND" ;
  OR := "or" | "OR" ;
```
To run the tests:
```
$ make
```
