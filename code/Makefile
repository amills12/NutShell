# Simple Makefile

all: lex-config bison-config nutshell-out

lex-config:
	lex nutshell.l

bison-config:
	yacc -d nutshell.y

nutshell-out:
	gcc lex.yy.c y.tab.c -o nutshell

clean:
	rm y.tab.c y.tab.h lex.yy.c nutshell

# CC=/usr/bin/cc

# all:  flex-config bison-config nutshparser nutshscanner nutshell nutshell-out

# flex-config:
# 	flex FLEX_FILE_NAME

# bison-config:
# 	bison -d nutshparser.y

# nutshscanner:  lex.yy.c
# 	$(CC) -c lex.yy.c -o nutshscanner.lex.o

# nutshparser:  nutshparser.tab.c 
# 	$(CC) -c nutshparser.tab.c -o nutshparser.y.o

# nutshell:  nutshell.c
# 	$(CC) -g -c nutshell.c -o nutshell.o 

# nutshell-out: 
# 	$(CC) -o nutshell nutshell.o nutshscanner.lex.o nutshparser.y.o -ll -lm -lfl
