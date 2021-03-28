# Simple Makefile

CC=/usr/bin/cc

all:  flex-config bison-config nutshparser nutshscanner nutshell nutshell-out

flex-config:
	flex nutshlexer.l

bison-config:
	bison -d nutshparser.y

nutshscanner:  lex.yy.c
	$(CC) -c lex.yy.c -o nutshscanner.lex.o

nutshparser:  nutshparser.tab.c 
	$(CC) -c nutshparser.tab.c -o nutshparser.y.o

nutshell:  nutshell.c
	$(CC) -g -c nutshell.c -o nutshell.o 

nutshell-out: 
	$(CC) -o nutshell nutshell.o nutshscanner.lex.o nutshparser.y.o -ll -lm -lfl

clean:
	rm -f nutshell nutshparser.tab.c nutshparser.tab.h lex.yy.c *.o
