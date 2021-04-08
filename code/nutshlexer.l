%{
    #pragma GCC diagnostic ignored "-Wwrite-strings"
    #include "nutshparser.tab.h"
    void yyerror(char *s);
%}

%option noyywrap

%%
setenv                 return SETENV;
printenv               return PRINTENV;
unsetenv               return UNSETENV;
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
[a-zA-Z\/.]+           { yylval.str = strdup(yytext); return WORD; };
[*.a-zA-Z]+            { yylval.str = strdup(yytext); return WILDCARD; };
[0-9]+                 { yylval.num = atoi(yytext); return NUMBER; };
.                      { yyerror("Unexpected character\n"); };
