%{
    #include "nutshparser.tab.h"
    void yyerror(char *s);   
%}

%%
setenv                 return SETENV;
printenv               return PRINTENV;
unsentenv              return UNSETENV;
cd                     return CD;
unalias                return UNALIAS;
alias                  return ALIAS; /* alias w/o arguments lists all the current aliases w/ argument adds new alias command to the shell */
bye|Bye                return BYE;
".."                   return DOTDOT; /* need to find a way to handle the current working directory */
[<]                    return LESSTHAN;
[>]                    return GREATERTHAN;
[|]                    return PIPE;
"\"\""                 return DOUBLEQUOTES;
[\\]                   return BACKSLASH;
[&]                    return AMPERSAND;               
[~]                    return HOME;
"~/"                   return HOME_PATH;


[ \t\r\n]              /* do nada */;
[a-zA-Z]+              { yylval.str = strdup(yytext); return WORD; }; /*[a-zA-Z]               { yylval.str = yytext[0]; return VARIABLE; }; */
[0-9]+                 { yylval.num = atoi(yytext); return NUMBER; }; 
.                      { yyerror("Unexpected character\n"); };
