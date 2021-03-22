#include <stdio.h>    
#include <stdlib.h>
#include <string.h>
#include "nutshparser.tab.h"

void yyerror(char *s)
{
    fprintf(stderr, "An Error Has Occured: %s", s);
}    

int yywrap(void)
{
    return 1;
}

int main()
{
    printf("Welcome to the NUTSHELL\n");
    printf("%s ", "%");
    return yyparse();
}
