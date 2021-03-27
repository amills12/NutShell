%{
    #include <stdio.h>    
    #include <stdlib.h>
    #include <string.h>

    int yylex();
    int yywrap();
    void yyerror(char *s);

%}

//%token WORD 
%token DOTDOT
%token LESSTHAN
%token GREATERTHAN
%token PIPE
%token DOUBLEQUOTES
%token BACKSLASH
%token AMPERSAND
 
%token SETENV
%token PRINTENV
%token UNSETENV
%token HOME
%token HOME_PATH
%token CD
%token UNALIAS
%token ALIAS /* alias w/o arguments lists all the current aliases w/ argument adds new alias command to the shell */
%token BYE

%union 
{
    int num;
    char* str;
}

/* %token <str> VARIABLE */
%token <str> WORD
%token <num> NUMBER

%%

inputs:
    | inputs input{printf("\n%s ", "%");};

input:
    C_META | C_CD | C_DOTDOT | C_WORD | C_SETENV | C_PRINTENV | C_UNSETENV | C_HOME | C_HOME_PATH | C_UNALIAS | C_ALIAS | C_BYE;
    
/* ===================================== START META CHARACTER CASE ======================================== */  
C_META:
    C_LESSTHAN | C_GREATERTHAN | C_PIPE | C_DOUBLEQUOTES | C_BACKSLASH | C_AMPERSAND;

C_LESSTHAN:
    LESSTHAN{printf("LESSTHAN");};
C_GREATERTHAN:
    GREATERTHAN{printf("GREATERTHAN");};
C_PIPE:
    PIPE{printf("PIPE");};
C_DOUBLEQUOTES:
    DOUBLEQUOTES{printf("DOUBLEQUOTES");};
C_BACKSLASH:
    BACKSLASH{printf("BACKSLASH");};
C_AMPERSAND:
    AMPERSAND{printf("AMPERSAND");};
/* ===================================== END META CHARACTER CASE ========================================== */  

/* ========================================= START CD CASE ================================================ */  
C_CD: /* need to word on "cd .. " implementation */
    CD{printf("CD");}; 
    
C_DOTDOT:    
    DOTDOT{printf("DOTDOT");}; /* not working atm: cd prints error and exits shell */
/* ========================================= END CD CASE ================================================== */   

C_WORD:
    WORD{printf("WORD");
    
    };
C_SETENV:
    SETENV WORD WORD{
        printf("SETENV\n");
        const char* variable = $2;
        const char* word = $3;
        printf("Environment Variable Set: %s == %s\n", variable, word);
        setenv(variable, word, 1);
    };
    
C_PRINTENV:
    PRINTENV WORD{
        const char* variable = $2;
        printf("PRINTENV\n");
        if(getenv(variable)==NULL){
            printf("Environment Variable \"%s\" Does Not Exist\n",variable);
        }
        else{
            printf("%s: %s\n",variable, getenv(variable));
        }
    };
C_UNSETENV:
    UNSETENV WORD{
        printf("UNSENTENV\n");    
        const char* variable = $2;
        unsetenv(variable);
        if(getenv(variable)==0){
            printf("Successfully Unset Environment Variable\n");   
        }
        else{
            printf("Environment Variable Does Not Exist\n");   
        }
    };
C_HOME:
    HOME{printf("HOME");};
C_HOME_PATH:
    HOME_PATH{printf("HOME_PATH");};
C_UNALIAS:
    UNALIAS{printf("UNALIAS");};
C_ALIAS:
    ALIAS{printf("ALIAS");};
C_BYE:
    BYE
    {
        printf("BYE\n");        
        exit(0);
    };
