%{
    #pragma GCC diagnostic ignored "-Wwrite-strings"
    #include "nutshparser.tab.h"
    void yyerror(char *s);
    const char * getEnvVar(const char *variable);
    char tempStr[100];
%}

%option noyywrap
%x string_cond
%x env_cond
%x envstring_expand

STRING   [a-zA-Z\/.0-9\-&*.?: ~!@#%()_]
WORD     [a-zA-Z\/.0-9\-&*.?:~_!@#%()]
%%
<string_cond>{STRING}+      { strcat(tempStr, yytext);};
<string_cond>"${"           { BEGIN(envstring_expand);};
<string_cond>[\"]           { BEGIN(INITIAL); yylval.str = strdup(tempStr); return STRING;};

<envstring_expand>{WORD}+   {
                                if(getEnvVar(yytext)){
                                    strcat(tempStr, getEnvVar(strdup(yytext)));
                                }
                            };
<envstring_expand>[}]       { BEGIN(string_cond); };
<env_cond>{WORD}*           { 
                                if(getEnvVar(strdup(yytext))){
                                    char *yycopy = strdup(getEnvVar(yytext));
                                    for ( int i = strlen(getEnvVar(yytext)) - 1; i >= 0; --i )
                                        unput( yycopy[i] );
                                    free(yycopy);
                                    BEGIN(INITIAL);
                                }
                                else{
                                    yyerror("incorrect environment variable");
                                    return ERROR;
                                }
                            };
<env_cond>"}"               { BEGIN(INITIAL); };

setenv|SETENV          return SETENV;
printenv|PRINTENV      return PRINTENV;
unsetenv|UNSETENV      return UNSETENV;
cd|CD                  return CD;
unalias|UNALIAS        return UNALIAS;
alias|ALIAS            return ALIAS;
bye|Bye|BYE            return BYE;
".."                   return DOTDOT;
"<"                    return LESSTHAN;
">"                    return GREATERTHAN;
"2>"                   return ERRORDIRECT;
"&"                    return AMPERSAND;
[|]                    return PIPE;
[\"]                   { strcpy(tempStr, ""); BEGIN(string_cond); };
"${"                   { BEGIN(env_cond); };
[~]                    return HOME;
\n                     return EOFNL;
"~/"                   return HOME_PATH;
[~][a-zA-Z]+           return TILDE_EXPANSION;

[ \t\r]+                /* do nada */;
{WORD}+                { yylval.str = strdup(yytext); return WORD; };
.                      {};
