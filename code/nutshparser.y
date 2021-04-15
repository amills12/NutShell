%{
    #pragma GCC diagnostic ignored "-Wwrite-strings"
    #include <stdio.h>    
    #include <stdlib.h>
    #include <string.h>
    
    #include <unistd.h>
    #include <sys/wait.h>
    #include "nutshell.h"

    // Funciton Headers
    int yylex();
    int yyparse();
    extern int yyerror(char *s);
    char ** generateCArgs(std::vector<std::string> arguments, const char* name);

    typedef struct yy_buffer_state *YY_BUFFER_STATE;
    extern int yyparse();
    extern YY_BUFFER_STATE yy_scan_string(const char *str);

    std::vector<CommandType> cmdTable;
    std::vector<std::string> tmpArgs;
    std::vector<std::string> ioFiles;

    std::string infile = "";
    std::string outfile = "";
    std::string errfile = "";

    bool appendFlag = false;
    bool backgroundFlag = false;
%}

//%token WORD
%token CD 
%token DOTDOT

%token PIPE
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

%token <str> WORD
%token <str> STRING
%token <str> TILDE_EXPANSION
%token <str> LESSTHAN
%token <str> GREATERTHAN
%token <str> ERRORDIRECT
%token <str> AMPERSAND
%%

inputs:
    | inputs input

input:
    C_CD | C_COMMAND | C_SETENV | C_PRINTENV | C_UNSETENV | C_UNALIAS | C_ALIAS | C_STRING | C_HOME | C_ERROR |C_BYE;

/* ========================================= START CD CASE ================================================ */  
C_CD:
    CD EOFNL{
        chdir(getEnvVar("HOME"));    
        return 1;             
    };
    | CD HOME EOFNL{ 
        chdir(getEnvVar("HOME"));    
        return 1;
    };
    | CD DOTDOT EOFNL{ 
        chdir("..");
        return 1;
    };
    | CD WORD EOFNL{
        std::string word($2);
        std::string dir;       
        std::vector<std::string> temp;
        
        if((word.find("*") != std::string::npos) || (word.find("?") != std::string::npos))
        {   
            globExpand($2, temp);
            dir = temp[0].c_str();
        }
        else
        {
           dir = $2;
        }
        if(chdir(dir.c_str()) != 0)
        {
            printf("Error incorrect directory\n");
        }
        
        
        return 1;
    };
    | CD ERROR{ return 0;};
/* ========================================= END CD CASE ================================================== */   

C_COMMAND:
    subcommand piped io_redirect_in io_redirect_out error_redirect background EOFNL{

        if (cmdTable.size() > 0 && isAlias(cmdTable[0].commandName.c_str()) == true){
            findAliasCommand(cmdTable[0].commandName.c_str());
        }
        else {
            if(cmdTable.size() == 1)
            {
                char ** args = generateCArgs(cmdTable[0].args, cmdTable[0].commandName.c_str());
                
                // Call execute command
                backgroundFlag ? executeBGCommand(args[0], args) : executeCommand(args[0], args);

                // Free Dynamic memory
                free(args);
            }
            else if(cmdTable.size() > 1)
            {
                backgroundFlag ? executeBGPipes() : executePipes();
            }

            cleanGlobals();
        }
        return 1;
    };

subcommand:
    | WORD arguments {
        CommandType tmpCmdType;
        tmpCmdType.commandName = $1;
        tmpCmdType.args = tmpArgs;
        cmdTable.push_back(tmpCmdType);
        tmpArgs.clear();
    }

arguments: 
    | arguments argument

argument:
    WORD {
        std::string word($1);

        // If the word contain special characters we need to expand it
        if ((word.find("*") != std::string::npos) || (word.find("?") != std::string::npos))
        {
            globExpand($1, tmpArgs);
        }
        else
        {
            // Add args to command table
            tmpArgs.push_back($1);
        }
    };
    | STRING {
        // Add args but with strings
        tmpArgs.push_back($1);
    };

piped:
    | piped pipedcommands
    
pipedcommands:
    PIPE subcommand 

io_redirect_out:
    | GREATERTHAN WORD {
        // Set the file to the input
        outfile = $2;
    };
    | GREATERTHAN GREATERTHAN WORD {
        outfile = $3;
        appendFlag = true;
    }

io_redirect_in:
    | LESSTHAN WORD {
        // Set the file to the last output
        infile = $2;
    };

error_redirect:
    | ERRORDIRECT WORD {
        errfile = $2;
    };

background:
    | AMPERSAND {
        backgroundFlag = true;
    }

C_SETENV:
    SETENV WORD WORD EOFNL{
        const char* variable = $2;
        const char* word = $3;
        addEnv(variable, word);
        return 1;
    };
    | SETENV WORD STRING EOFNL{
        addEnv($2, $3);
        return 1;
    }    
C_PRINTENV:
    PRINTENV io_redirect_out EOFNL{
        if(outfile != "")
        {
            int temp = dup(1);
            FILE *f = fopen(outfile.c_str(), appendFlag ? "a" : "w");

            //Open stdout
            dup2(fileno(f), 1);

            // Print out to file
            printEnv();

            fclose(f);
            
            //Close stdout
            dup2(temp, 1);
            close(temp);

            outfile = "";
        }
        else
        {
            printEnv();
        }
        return 1;
    };
C_UNSETENV:
    UNSETENV WORD EOFNL{
        const char* variable = $2;
        removeEnv(variable);
        return 1;
    };
C_UNALIAS:
    UNALIAS WORD EOFNL{
        const char *aliasName = $2;
        removeAlias(aliasName);
        return 1;
        };
C_ALIAS:
    ALIAS io_redirect_out EOFNL{
        if(outfile != "")
        {
            int temp = dup(1);
            FILE *f = fopen(outfile.c_str(), appendFlag ? "a" : "w");

            //Open stdout
            dup2(fileno(f), 1);

            // Print out to file
            printAlias();

            fclose(f);
            
            //Close stdout
            dup2(temp, 1);
            close(temp);

            outfile = "";
        }
        else
        {
            printAlias();
        }
        return 1;
    };
    | ALIAS WORD WORD EOFNL{
        const char *aliasName = $2;
        const char *aliasedCommand = $3;
        if (addAlias(aliasName, aliasedCommand)){}
        else
            printf("Cannot add alias: %s = %s as it would lead to infinite loop.\n", $2, $3);

        return 1;
    };
    | ALIAS WORD STRING EOFNL{        
        const char *aliasName = $2;
        const char *aliasedCommand = $3;
        addAlias(aliasName, aliasedCommand);
        return 1;
    };

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
    fprintf(stderr, "An Error has Occured: %s\n", s);
    yylex_destroy();
    return 0;
}

char** generateCArgs(std::vector<std::string> arguments, const char * name)
{
    // Create a an array of arguments using what we have
    char ** args;
    
    // Allocating Space for new args array
    args = (char **)malloc((arguments.size() + strlen(name) + 1) * sizeof(char*));
    args[0] = (char *)malloc(strlen(name) + 1 *sizeof(char*));

    // Copy over command name
    strcpy(args[0], name);

    for (int temp = 1; temp <= arguments.size(); temp++)
    {
        args[temp] = (char *)malloc((strlen(arguments[temp-1].c_str()) + 1) * sizeof(char*));
        strcpy(args[temp],arguments[temp-1].c_str());
    }

    // Remember to null terminate
    args[arguments.size() + 1] = NULL;

    return args;
}

