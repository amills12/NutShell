%{
    #include "nutshell.h"   
%}

%%
setenv                 return SETENV;
printenv               return PRINTENV;
unsentenv              return UNSENTENV;
cd                     return CD;
unalias                return UNALIAS;
alias                  return ALIAS; /* alias w/o arguments lists all the current aliases w/ argument adds new alias command to the shell */
bye|Bye                return BYE;
/* need to find a way to handle the current working directory */
[..]                   return DOTDOT;
[<]                    return LESSTHAN;
[>]                    return GREATERTHAN;
[|]                    return PIPE;
[\"]                   return DOUBLEQUOTES;
[\\]                   return BACKSLASH;
[&]                    return AMPERSAND;               
[~]                    return HOME;
[~/]                   return HOME_PATH;


[ \t\r\n]              /* do nada */;
[a-z]+                 printf("You Said A Word\n");/*return WORD;*/
.                      printf("Unexpected character\n");

%%

int yywrap(void)
{
    return 1;
}
