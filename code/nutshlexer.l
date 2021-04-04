%{
    #pragma GCC diagnostic ignored "-Wwrite-strings"
    #include "nutshparser.tab.h"
    void yyerror(char *s);
%}

%option noyywrap

%%
setenv                 return SETENV;
printenv               return PRINTENV;
unsentenv              return UNSETENV;
cd                     return CD;
unalias                return UNALIAS;
alias                  return ALIAS;
bye|Bye                return BYE;
".."                   return DOTDOT; /* need to find a way to handle the current working directory */
"<"                    return LESSTHAN;
[>]                    return GREATERTHAN;
[|]                    return PIPE;
["]                    return QUOTE;
[\\]                   return BACKSLASH;
[&]                    return AMPERSAND;               
[~]                    return HOME;
\n                     return EOFNL;
"~/"                   return HOME_PATH;

[ \t\r\n]              /* do nada */;
\"([^'\n]|\'\')+\"     { yylval.str = strdup(yytext); return STRING; };
[a-zA-Z\/.0-9]+        { yylval.str = strdup(yytext); return WORD; };
.                      { yyerror("Unexpected character\n"); };
