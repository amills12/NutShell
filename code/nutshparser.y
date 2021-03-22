%{
    #include <stdio.h>    
    #include <stdlib.h>

    int yylex();
    int yywrap();
    void yyerror(char *s);

%}

%union 
{
    int num;
    char *str;
}

%token WORD 
%token DOTDOT
%token LESSTHAN
%token GREATERTHAN
%token PIPE
%token DOUBLEQUOTES
%token BACKSLASH
%token AMPERSAND
 
%token SETENV
%token PRINTENV
%token UNSENTENV
%token HOME
%token HOME_PATH
%token CD
%token UNALIAS
%token ALIAS /* alias w/o arguments lists all the current aliases w/ argument adds new alias command to the shell */
%token BYE

%%

inputs:
    | inputs input{printf("\n%s ", "%");};

input:
    C_META | C_CD | C_WORD | C_SETENV | C_PRINTENV | C_UNSENTENV | C_HOME | C_HOME_PATH | C_UNALIAS | C_ALIAS | C_BYE;
    
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
C_CD:
    C_DOTDOT;
    
C_DOTDOT:    
    DOTDOT{printf("DOTDOT");}; /* not working atm: cd prints error and exits shell */
/* ========================================= END CD CASE ================================================== */   

C_WORD:
    WORD{printf("WORD");};
C_SETENV:
    SETENV{printf("SETENV");};
C_PRINTENV:
    PRINTENV{printf("PRINTENV");};
C_UNSENTENV:
    UNSENTENV{printf("UNSENTENV");};
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
        printf("BYE");
        exit(0);
    };
