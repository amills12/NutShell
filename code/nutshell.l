%{
    #include "y.tab.h"
    void yyerror(char *s);   
%}

%%
setenv                 return SETENV;
printenv               return PRINTENV;
unsentenv              return UNSENTENV;
cd                     return CD;
unalias                return UNALIAS;
alias                  return ALIAS; /* alias w/o arguments lists all the current aliases w/ argument adds new alias command to the shell */
bye|Bye                return BYE;

[..]                   return DOTDOT; /* need to find a way to handle the current working directory */
[<]                    return LESSTHAN;
[>]                    return GREATERTHAN;
[|]                    return PIPE;
[\"]                   return DOUBLEQUOTES;
[\\]                   return BACKSLASH;
[&]                    return AMPERSAND;               
[~]                    return HOME;
[~/]                   return HOME_PATH;


[ \t\r\n]              /* do nada */;
[a-z]+                 return WORD;/*return WORD;*/
.                      {yyerror("Unexpected character\n");};
