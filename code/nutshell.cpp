#pragma GCC diagnostic ignored "-Wwrite-strings" // This supresses const char warning

#define AUTO 0 //1 for auto testing, 0 for manual.

// C header files
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <glob.h>
#include <sys/wait.h>

#include "nutshparser.tab.h"

// C++ header files
#include <map>
#include <iterator>
#include <string>
#include "nutshell.h"
using namespace std;

// Import from C
typedef struct yy_buffer_state *YY_BUFFER_STATE;
extern int yyparse();
extern YY_BUFFER_STATE yy_scan_string(const char *str);
extern char **environ;

// Global Variables
map<string, string> aliasMap;

// Bison Helper Functions
void printenv()
{
    int id = 0;
    while (environ[id] != NULL)
    {
        printf("%s\n", environ[id++]);
    }
}

void addAlias(const char *name, const char *command)
{
    string nameCheck(name);
    string commandCheck(command);

    auto itr = aliasMap.find(name);
    if (itr == aliasMap.end() && nameCheck != commandCheck){
        aliasMap.insert(pair<string, string>(name, command));
        //printf("Alias Added"); 
    }
    else
    {
        printf("Add alias failed.\n"); 
    }
    
}

void removeAlias(const char *name)
{
    auto itr = aliasMap.find(name);
    if (itr == aliasMap.end())
    {
        printf("Alias Does Not Exist\n"); 
    }
    else
    {
        aliasMap.erase(name);
        
    }
    
}

void executeCommand(const char *command)
{
    // execl or exce
    pid_t p;
    p = fork();
    if (p < 0)
    {
        perror("Fork Failed");
    }
    else if (p == 0)
    {
        execl("/bin/ls", command, NULL);
    }
    else
        wait(0);
}

bool isAlias(const char *name)
{
    auto itr = aliasMap.find(name);
    if (itr == aliasMap.end()){
        //printf("ALIAS NOT FOUND: "); 
        return false;
    }
    else{
        //printf("ALIAS WAS FOUND: "); 
        return true;
    }
}

void findAliasCommand(const char *name)
{
    string aliasCommand(name);
    aliasCommand = aliasMap.find(name)->second;
    // printf("ALIAS COMMAND: %s", aliasCommand.c_str());
    aliasCommand += "\n";
    yy_scan_string(aliasCommand.c_str());
    yyparse();
    yylex_destroy();
}

void wildCarding(const char *name)
{
        glob_t globbuf = {0};
        glob(name, GLOB_DOOFFS, NULL, &globbuf);
        for (size_t i = 0; i != globbuf.gl_pathc; ++i)
        {
            printf("%s\n", globbuf.gl_pathv[i]);
        }
        globfree(&globbuf);
}

void tildeExpansion(const char *name)
{
        glob_t globbuf = {0};
        glob(name, GLOB_TILDE, NULL, &globbuf);
        for (size_t i = 0; i != globbuf.gl_pathc; ++i)
        {
            printf("%s\n", globbuf.gl_pathv[i]);
        }
        globfree(&globbuf);
}

void printAlias()
{
    // Make an iterator to print through all alias
    map<string, string>::iterator itr;

    for (itr = aliasMap.begin(); itr != aliasMap.end(); itr++)
    {
        if (next(itr) != aliasMap.end())
            printf("%s = %s\n", itr->first.c_str(), itr->second.c_str());
        else
            printf("%s = %s\n", itr->first.c_str(), itr->second.c_str());
    }
}

void black() { printf("\033[0;30m"); }
void red() { printf("\033[0;31m"); }
void green() { printf("\033[0;32m"); }
void yellow() { printf("\033[0;33m"); }
void blue() { printf("\033[0;34m"); }
void purple() { printf("\033[0;35m"); }
void cyan() { printf("\033[0;36m"); }
void white() { printf("\033[0;37m"); }

void nutshellTerminalPrint()
{
    purple();
    printf("Nutshell@localhost:");
    yellow();
    printf("%s", getcwd(NULL, 0));
    cyan();
    printf("%s ", "$");
    white();
}

// Main Program execution
int main()
{
    red();
    printf(" /$$   /$$ /$$   /$$ /$$$$$$$$ /$$$$$$  /$$   /$$ /$$$$$$$$ /$$       /$$\n");     
    printf("| $$$ | $$| $$  | $$|__  $$__//$$__  $$| $$  | $$| $$_____/| $$      | $$\n");       
    printf("| $$$$| $$| $$  | $$   | $$  | $$  \\__/| $$  | $$| $$      | $$      | $$\n");      
    printf("| $$ $$ $$| $$  | $$   | $$  |  $$$$$$ | $$$$$$$$| $$$$$   | $$      | $$\n");       
    printf("| $$  $$$$| $$  | $$   | $$   \\____  $$| $$__  $$| $$__/   | $$      | $$\n");       
    printf("| $$\\  $$$| $$  | $$   | $$   /$$  \\ $$| $$  | $$| $$      | $$      | $$\n");       
    printf("| $$ \\  $$|  $$$$$$/   | $$  |  $$$$$$/| $$  | $$| $$$$$$$$| $$$$$$$$| $$$$$$$$\n"); 
    printf("|__/  \\__/ \\______/    |__/   \\______/ |__/  |__/|________/|________/|________/\n");                                                                          

    //printf("**** Welcome to the NUTSHELL ****\n");
    white();

#if AUTO //If AUTO is 1 this code will run
    string testArr[] = { "alias beetle \"beetle juice\"", "alias ya yeet", "alias test \"cd ..\"", "alias", "unalias beetle", "alias",
                        "beetle","test", "cd", "cd ..","ls", "*.c", "*.h", "cd /NutShell/code", "cd ..", "cd ..",
                       "Yeet", "alias beetle \"beetle juice\"",
                       "\"nutshell/nutshell/nutshell/nutshell\"" /*This should print quote word quote*/,
                       "setenv beetle juice", "printenv", "unsetenv beetle", "printenv beetle",
                       "..", "<", ">", "|", "&", "~", "~/", "cd", "("/*this should throw an error*/,
                       "ls", "bye"};

    for (int i = 0; i < sizeof(testArr); i++)
    {
        nutshellTerminalPrint();
        string tempStr = testArr[i] + "\n";
        yy_scan_string(tempStr.c_str());
        yyparse();
        yylex_destroy();
    }
#else //If AUTO is 0 this code will run
    while (1)
    {
        nutshellTerminalPrint();
        yyparse();
    }
#endif
    return 0;
}
