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

    // Global Variables
    // char * cmdTable[100][100];
    // int i = 0;
    // int j = 0;

    std::vector<CommandType> cmdTable;
    std::vector<std::string> tmpArgs;
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
%token HOME
%token HOME_PATH
%token SETENV
%token PRINTENV
%token UNSETENV
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
%token <str> WILDCARD 
%token <str> TILDE_EXPANSION
/* %define parse.error verbose */
%%

inputs:
    | inputs input

input:
    C_META | C_CD | C_COMMAND | C_SETENV | C_PRINTENV | C_UNSETENV | C_UNALIAS | C_ALIAS | C_STRING | C_HOME | C_ERROR | C_WILDCARD |C_BYE;
    
/* ===================================== START META CHARACTER CASE ======================================== */  
C_META:
    C_LESSTHAN | C_GREATERTHAN | C_BACKSLASH | C_AMPERSAND;

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
        // printf("CD -- ");
        // printf("Current Working Directory Is: %s ", getcwd(NULL,0));
        chdir(getenv("HOME"));    
        // printf("-- Switching To: %s", getcwd(NULL,0));
        // printf("\n");
        return 1;             
    };
    | CD HOME EOFNL{ 
        // printf("CD HOME -- "); 
        // printf("Current Working Directory Is: %s ", getcwd(NULL,0));
        chdir(getenv("HOME"));    
        // printf("-- Switching To: %s", getcwd(NULL,0));
        // printf("\n");
        return 1;
    };
    | CD DOTDOT EOFNL{ 
        // printf("CD DOTDOT -- "); 
        // printf("Current Working Directory Is: %s ", getcwd(NULL,0));
        chdir("..");
        // printf("-- Switching To: %s", getcwd(NULL,0));
        // printf("\n");
        return 1;
    };
    | CD WORD EOFNL{
        
        // printf("CD WORD -- "); 
        const char* dir = $2;
        // printf("Current Working Directory Is: %s ", getcwd(NULL,0));
        chdir(dir);
        // printf("-- Switching To: %s", getcwd(NULL,0));
        // printf("\n");
        return 1;
    };
    | CD ERROR{ return 0;};
/* ========================================= END CD CASE ================================================== */   

C_COMMAND:
    subcmd pipedcmd EOFNL{

        if (isAlias(cmdTable[0].commandName.c_str()) == true){
            findAliasCommand(cmdTable[0].commandName.c_str());
            printf("\n");
        }
        else {
            for (int i = 0; i < cmdTable.size(); i++)
            {
                // Create a an array of arguments using what we have
                char ** args;

                // Allocating Space for new args array
                args = (char **)malloc(100*sizeof(char*));
                args[0] = (char *)malloc(100*sizeof(char*));

                // Copy over command name
                strcpy(args[0], cmdTable[i].commandName.c_str());

                for (int temp = 1; temp <= cmdTable[i].args.size(); temp++)
                {
                    args[temp] = (char *)malloc(100*sizeof(char*));
                    strcpy(args[temp],cmdTable[i].args[temp-1].c_str());
                }

                // Call execute command
                executeCommand(args[0], args);

                // Free Dynamic memory
                free(args);
            }
            cmdTable.clear();
        }

        return 1;
    };

args: 
    | args arg

subcmd:
    | WORD args {
        CommandType tmpCmdType;
        tmpCmdType.commandName = $1;
        tmpCmdType.args = tmpArgs;
        cmdTable.push_back(tmpCmdType);
        tmpArgs.clear();
    }

pipedcmd:
    | PIPE subcmd

arg:
    WORD {
        // Add args to command table
        tmpArgs.push_back($1);
        // cmdTable[i][j] = $1;
        // j++;

        // printf("ARG: %s ", word);
    };
    | STRING {
        tmpArgs.push_back($1);
        // cmdTable[i][j] = $1;
        // j++;
    };
    
C_SETENV:
    SETENV WORD WORD EOFNL{
        // printf("SETENV -- ");
        const char* variable = $2;
        const char* word = $3;
        // printf("Environment Variable Set: %s == %s", variable, word);
        setenv(variable, word, 1);
        // printf("\n");
        return 1;
    };    
C_PRINTENV:
    PRINTENV EOFNL{
        // printf("PRINTENV\n");
        printenv();
        // printf("\n");
        return 1;
        // Do they really want all the the environment variables? PS. ITS UGLY
    };
C_UNSETENV:
    UNSETENV WORD EOFNL{
        // printf("UNSENTENV -- ");    
        const char* variable = $2;
        unsetenv(variable);
        if(getenv(variable)==0){
            printf("Successfully Unset Environment Variable");   
        }
        else{
            printf("Environment Variable Does Not Exist");   
        }
        // printf("\n");
        return 1;
    };
C_UNALIAS:
    UNALIAS WORD EOFNL{
        const char *aliasName = $2;
        // printf("UNALIAS -- ");
        // printf("Deleting: %s", aliasName);
        removeAlias(aliasName);
        // printf("\n");
        return 1;
        };
C_ALIAS:
    ALIAS EOFNL{
        // printf("ALIAS PRINT -- Printing...\n");
        printAlias();
        // printf("\n");
        return 1;
    };
    | ALIAS WORD WORD EOFNL{
        const char *aliasName = $2;
        const char *aliasedCommand = $3;
        // printf("ALIAS ADD -- ");
        // printf("Added: %s = %s", aliasName, aliasedCommand);
        addAlias(aliasName, aliasedCommand);
        // printf("\n");
        return 1;
    };
    | ALIAS WORD STRING EOFNL{        
        const char *aliasName = $2;
        const char *aliasedCommand = $3;
        // printf("ALIAS ADD -- ");
        // printf("Added: %s = %s", aliasName, aliasedCommand);
        addAlias(aliasName, aliasedCommand);
        // printf("\n");
        return 1;
    };
C_WILDCARD:
    WILDCARD EOFNL{
        const char *fileExt = $1;   
        wildCarding(fileExt);
        return 1;
    };
/* C_EOLN:
    EOFNL{
        return 1;
    }; */

C_STRING:
    STRING EOFNL
    {
        printf("STRING");
        printf("\n");
        return 1;
    };
C_HOME:
    HOME EOFNL{  
        tildeExpansion("~");
        return 1;
    }
    | HOME_PATH EOFNL{
        tildeExpansion("~/");
        return 1;
    }
    | TILDE_EXPANSION EOFNL{
        const char *tildeExp = $1;   
        tildeExpansion(tildeExp);
        return 1;
    }

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

