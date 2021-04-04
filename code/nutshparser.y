%{
    #pragma GCC diagnostic ignored "-Wwrite-strings"
    #include <stdio.h>    
    #include <stdlib.h>
    #include <string.h>
    #include <unistd.h>
    #include <sys/wait.h>
    #include "nutshell.h"

    int yylex();
    int yyparse();
    int yyerror(char *s);

    typedef struct yy_buffer_state *YY_BUFFER_STATE;
    extern int yyparse();
    extern YY_BUFFER_STATE yy_scan_string(const char *str);
%}

//%token WORD
%token CD 
%token DOTDOT
%token LESSTHAN
%token GREATERTHAN
%token PIPE
%token BACKSLASH
%token AMPERSAND
%token EOFNL
%token ERROR
 
%token SETENV
%token PRINTENV
%token UNSETENV
%token HOME
%token HOME_PATH
%token UNALIAS
%token ALIAS
%token BYE

%union 
{
    int num;
    char* str;
}

/* %token <str> VARIABLE */
%token <str> WORD
%token <str> STRING

%%

inputs:
    | inputs input

input:
    C_META | C_CD | C_WORD | C_SETENV | C_PRINTENV | C_UNSETENV | C_UNALIAS | C_ALIAS | C_EOLN | C_STRING | C_ERROR |C_BYE;
    
/* ===================================== START META CHARACTER CASE ======================================== */  
C_META:
    C_LESSTHAN | C_GREATERTHAN | C_PIPE | C_BACKSLASH | C_AMPERSAND;

C_LESSTHAN:
    LESSTHAN
    {
        printf("LESSTHAN");
        printf("\n");
        return 1;
    };
C_GREATERTHAN:
    GREATERTHAN
    {
        printf("GREATERTHAN");
        printf("\n");
        return 1;
    };
C_PIPE:
    PIPE
    {
        printf("PIPE");
        printf("\n");
        return 1;
    };
C_BACKSLASH:
    BACKSLASH
    {
        printf("BACKSLASH");
        printf("\n");
        return 1;
    };
C_AMPERSAND:
    AMPERSAND
    {
        printf("AMPERSAND");
        printf("\n");
        return 1;
    };
/* ===================================== END META CHARACTER CASE ========================================== */  

/* ========================================= START CD CASE ================================================ */  
C_CD: /* need to word on "cd .. " implementation */
    CD EOFNL{
        printf("CD -- ");
        printf("Current Working Directory Is: %s ", getcwd(NULL,0));
        chdir(getenv("HOME"));    
        printf("-- Switching To: %s", getcwd(NULL,0));
        printf("\n");
        return 1;             
    };
    | CD HOME EOFNL{ 
        printf("CD HOME -- "); 
        printf("Current Working Directory Is: %s ", getcwd(NULL,0));
        chdir(getenv("HOME"));    
        printf("-- Switching To: %s", getcwd(NULL,0));
        printf("\n");
        return 1;
    };
    | CD DOTDOT EOFNL{ 
        printf("CD DOTDOT -- "); 
        printf("Current Working Directory Is: %s ", getcwd(NULL,0));
        chdir("..");
        printf("-- Switching To: %s", getcwd(NULL,0));
        printf("\n");
        return 1;
    };
    | CD WORD EOFNL{
        
        printf("CD WORD -- "); 
        const char* dir = $2;
        printf("Current Working Directory Is: %s ", getcwd(NULL,0));
        chdir(dir);
        printf("-- Switching To: %s", getcwd(NULL,0));
        printf("\n");
        return 1;
    };
    | CD ERROR{ return 0;};
/* ========================================= END CD CASE ================================================== */   

C_WORD:
    WORD EOFNL{
        printf("WORD -- ");
        const char* command = $1;
        if (isAlias(command) == true){
            findAliasCommand(command);
        }
        else if (strcmp(command, "ls") == 0){
            executeCommand(command);
        }
        else{
            printf("%s", command);
            printf("\n");
        }
        return 1;
    };
    
C_SETENV:
    SETENV WORD WORD EOFNL{
        printf("SETENV -- ");
        const char* variable = $2;
        const char* word = $3;
        printf("Environment Variable Set: %s == %s", variable, word);
        setenv(variable, word, 1);
        printf("\n");
        return 1;
    };    
C_PRINTENV:
    PRINTENV EOFNL{
        printf("PRINTENV\n");
        printenv();
        printf("\n");
        return 1;
        // Do they really want all the the environment variables? PS. ITS UGLY
    };
C_UNSETENV:
    UNSETENV WORD EOFNL{
        printf("UNSENTENV -- ");    
        const char* variable = $2;
        unsetenv(variable);
        if(getenv(variable)==0){
            printf("Successfully Unset Environment Variable");   
        }
        else{
            printf("Environment Variable Does Not Exist");   
        }
        printf("\n");
        return 1;
    };
C_UNALIAS:
    UNALIAS WORD EOFNL{
        printf("UNALIAS -- ");
        const char *aliasName = $2;
        printf("Deleting: %s", aliasName);
        removeAlias(aliasName);
        printf("\n");
        return 1;
        };
C_ALIAS:
    ALIAS EOFNL{
        printf("ALIAS PRINT -- Printing...\n");
        printAlias();
        printf("\n");
        return 1;
    };
    | ALIAS WORD WORD EOFNL{
        printf("ALIAS ADD -- ");
        const char *aliasName = $2;
        const char *aliasedCommand = $3;
        printf("Added: %s = %s", aliasName, aliasedCommand);
        addAlias(aliasName, aliasedCommand);
        printf("\n");
        return 1;
    };
    | ALIAS WORD STRING EOFNL{
        printf("ALIAS ADD -- ");
        const char *aliasName = $2;
        const char *aliasedCommand = $3;

        printf("Added: %s = %s", aliasName, aliasedCommand);
        addAlias(aliasName, aliasedCommand);
        printf("\n");
        return 1;
    };
C_EOLN:
    EOFNL{
        return 1;
    };

C_STRING:
    STRING EOFNL
    {
        printf("STRING");
        printf("\n");
        return 1;
    };

C_ERROR:
    ERROR { return 0; };

C_BYE:
    BYE EOFNL
    {
        printf("BYE\n");        
        exit(0);
    };

%%

int yyerror(char *s)
{
    printf("An Error has Occured: %s\n", s);
    yylex_destroy();
    return 0;
}
