%{
    #pragma GCC diagnostic ignored "-Wwrite-strings"
    #include "nutshparser.tab.h"
    void yyerror(char *s);
%}

%option noyywrap
%x string_cond
%x env_cond

NOTEQUOTE [^"]
WORD      [a-zA-Z\/.0-9]
%%
<string_cond>{NOTEQUOTE}+   { yylval.str = strdup(yytext); return STRING; };
<string_cond>[\"]           { BEGIN(INITIAL); };

<env_cond>{WORD}+           { 
                                if(getenv(strdup(yytext))){
                                    yylval.str = getenv(strdup(yytext));
                                    return WORD; 
                                }
                                else{
                                    yyerror("incorrect environment variable");
                                    return ERROR;
                                }
                            };
<env_cond>"}"               { BEGIN(INITIAL); };

setenv|SETENV          return SETENV;
printenv|PRINTENV      return PRINTENV;
unsetenv|UNSETENV     return UNSETENV;
cd|CD                  return CD;
unalias|UNALIAS        return UNALIAS;
alias|ALIAS            return ALIAS;
bye|Bye|BYE            return BYE;
".."                   return DOTDOT; /* need to find a way to handle the current working directory */
"<"                    return LESSTHAN;
[>]                    return GREATERTHAN;
[|]                    return PIPE;
[\"]                   { BEGIN(string_cond); };
"${"                   { BEGIN(env_cond); };
[\\]                   return BACKSLASH;
[&]                    return AMPERSAND;               
[~]                    return HOME;
\n                     return EOFNL;
"~/"                   return HOME_PATH;
[~a-zA-Z]+             return TILDE_EXPANSION;

[ \t\r]                /* do nada */;
{WORD}+                { yylval.str = strdup(yytext); return WORD; };
[*.a-zA-Z]+            { yylval.str = strdup(yytext); return WILDCARD; };
.                      { yyerror("Unexpected character"); return ERROR; };
