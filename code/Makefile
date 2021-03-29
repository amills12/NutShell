# Simple Makefile

CC=/usr/bin/cc

all:  flex-config bison-config nutshparser nutshscanner nutshell nutshell-out

flex-config:
	flex --header-file nutshlexer.l

bison-config:
	bison -d nutshparser.y

nutshscanner:  lex.yy.c
	g++ -c lex.yy.c -o nutshscanner.lex.o

nutshparser:  nutshparser.tab.c 
	g++ -c nutshparser.tab.c -o nutshparser.y.o

nutshell:  nutshell.cpp
	g++ -g -c nutshell.cpp -o nutshell.o 

nutshell-out: 
	g++ -o nutshell nutshell.o nutshscanner.lex.o nutshparser.y.o

clean:
	rm -f nutshell nutshparser.tab.c nutshparser.tab.h lex.yy.c *.o
