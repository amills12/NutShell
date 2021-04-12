// This file holds all the proto types for nutshell.cpp
#pragma once

#include <string>
#include <vector>

//Global Variables
class CommandType {
    public:
        std::string commandName;
        std::vector<std::string> args;
};

extern std::string infile;
extern std::string outfile;
extern std::vector<CommandType> cmdTable;
extern std::vector<std::string> tmpArgs;
extern bool appendFlag;

// Global Functions
void printenv();
void addAlias(const char *name, const char *command);
void removeAlias(const char *name);
bool isAlias(const char *name);
void findAliasCommand(const char *name);
void executeCommand(char *command, char **args);
void executePipedCommand(char *command, char **args, int pipeFlag);

// Colors 
void printAlias();
void black();
void red();
void green();
void yellow();
void blue();
void purple();
void cyan();
void white();

// Terminal color theme
void nutshellTerminalPrint();
void wildCarding(const char *name);
void tildeExpansion(const char *name);

int yylex_destroy( void );
