#include <stdio.h>    
#include <stdlib.h>
#include <string.h>
#include "nutshparser.tab.h"

//1 for auto testing 0 for manual
#define AUTO 1

typedef struct yy_buffer_state * YY_BUFFER_STATE;
extern int yyparse();
extern YY_BUFFER_STATE yy_scan_string(char * str);
extern void yy_delete_buffer(YY_BUFFER_STATE buffer);
extern char **environ;

void yyerror(char *s)
{
    fprintf(stderr, "An Error Has Occured: %s", s);
}    

int yywrap(void)
{
    return 1;
}

void printenv()
{
    int id = 0;
    while(environ[id] != NULL)
    {
        printf("%s\n", environ[id++]);
    }
}

int main()
{
    printf("Welcome to the NUTSHELL\n");
    printf("%s ", "%");

#if AUTO //If auto is 1 run this code
    char* testArr[] = { "Yeet", "alias beetle \"beetle juice\"", "bye" };
                    //    "\"nutshell/nutshell/nutshell/nutshell\"" /*This should print quote word quote*/,
                    //    "setenv beetle juice", "printenv beetle", "unsentenv beetle", "printenv beetle",
                    //    "unalias", "alias",
                    //    "..", "<", ">", "|", "\"\"", "&", "~", "~/", "cd", "("/*this should throw an error*/,
                    //    "bye", "Bye"};

    for (int i = 0; i < sizeof(testArr); i++)
    {	
	    YY_BUFFER_STATE buffer = yy_scan_string(testArr[i]);
        yyparse();
        yy_delete_buffer(buffer);
    }
    return 0;
#else
    return yyparse();
#endif
}
