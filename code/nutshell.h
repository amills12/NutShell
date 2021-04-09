// This file holds all the proto types for nutshell.cpp
#pragma once

void printenv();
void addAlias(const char *name, const char *command);
void removeAlias(const char *name);
bool isAlias(const char *name);
void findAliasCommand(const char *name);
void executeCommand(const char *command);
//Colors
void printAlias();
void black();
void red();
void green();
void yellow();
void blue();
void purple();
void cyan();
void white();
//Terminal color theme
void nutshellTerminalPrint();

void wildCarding(const char *name);
void tildeExpansion(const char *name);

int yylex_destroy ( void );
