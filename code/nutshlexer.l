%{
    #include "nutshparser.tab.h"
    void yyerror(char *s);   
%}

%x expect_string

QUOTE    ["]    /* We have to use these because without it thinks we're making a string */
NOTQUOTE [^"]

%%
{QUOTE}                     { BEGIN(expect_string); return HOME; }
<expect_string>{NOTQUOTE}*   return STRING;
<expect_string>{QUOTE}      { BEGIN(inital); return HOME; }
setenv                 return SETENV;
printenv               return PRINTENV;
unsentenv              return UNSETENV;
cd                     return CD;
unalias                return UNALIAS;
alias                  return ALIAS;
bye|Bye                return BYE;
".."                   return DOTDOT; /* need to find a way to handle the current working directory */
[<]                    return LESSTHAN;
[>]                    return GREATERTHAN;
[|]                    return PIPE;
["]                    return QUOTE;
[\\]                   return BACKSLASH;
[&]                    return AMPERSAND;               
[~]                    return HOME;
"~/"                   return HOME_PATH;

[ \t\r\n]              /* do nada */;
[a-zA-Z\/.]+           { yylval.str = strdup(yytext); return WORD; };
[0-9]+                 { yylval.num = atoi(yytext); return NUMBER; };
.                      { yyerror("Unexpected character\n"); };
