all:
	bison -d parser.y
	flex parser.l
	cc parser.tab.c lex.yy.c -lfl -o parser
	./test.sh
