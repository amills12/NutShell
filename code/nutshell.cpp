#pragma GCC diagnostic ignored "-Wwrite-strings" // This supresses const char warning

#define AUTO 1 //1 for auto testing, 0 for manual.

// C header files
#include <stdio.h>
#include <stdlib.h>
#include "nutshparser.tab.h"

// C++ header files
#include <map>
#include <iterator>
#include <string>
#include "nutshell.h"
using namespace std; 

// Import from C
typedef struct yy_buffer_state *YY_BUFFER_STATE;
extern int yyparse(); 
extern YY_BUFFER_STATE yy_scan_string(const char *str);
extern void yy_delete_buffer(YY_BUFFER_STATE buffer);
extern char **environ;

// Global Variables
map<string, string> aliasMap;

// Lex Functions
void yyerror(char *s)
{
    fprintf(stderr, "An Error Has Occured: %s", s);
}

int yywrap(void)
{
    return 1;
}

// Bison Helper Functions
void printenv()
{
    int id = 0;
    while (environ[id] != NULL)
    {
        printf("%s\n", environ[id++]);
    }
}

void addAlias(const char* name, const char* command)
{
    aliasMap.insert(pair<string, string>(name, command));
}

void removeAlias(const char* name)
{
    aliasMap.erase(name);
}

void printAlias()
{
    // Make an iterator to print through all alias
    map<string,string>::iterator itr;

    for(itr = aliasMap.begin(); itr != aliasMap.end(); itr++)
    {
        printf("%s = %s\n", itr->first.c_str(), itr->second.c_str());
    }
}

// Main Program execution
int main()
{
    printf("Welcome to the NUTSHELL\n");
    printf("%s ", "%");

#if AUTO //If AUTO is 1 this code will run
    char* testArr[] = { "alias beetle \"beetle juice\"", "alias ya yeet", "alias test \"test 3\"", "alias", "unalias beetle", "alias", "bye"};
                    //    "\"nutshell/nutshell/nutshell/nutshell\"" /*This should print quote word quote*/,
                    //    "setenv beetle juice", "printenv beetle", "unsentenv beetle", "printenv beetle",
                    //    "..", "<", ">", "|", "\"\"", "&", "~", "~/", "cd", "("/*this should throw an error*/,
                    //    "bye", "Bye"};

    for (int i = 0; i < sizeof(testArr); i++)
    {
        YY_BUFFER_STATE buffer = yy_scan_string(testArr[i]);
        yyparse();
        yy_delete_buffer(buffer);
    }
    return 0;
#else //If AUTO is 0 this code will run
    return yyparse();
#endif
}
