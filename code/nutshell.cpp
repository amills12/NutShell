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
#include <fstream>
#include "nutshell.h"
using namespace std;

// Import from C
typedef struct yy_buffer_state *YY_BUFFER_STATE;
extern int yyparse();
extern YY_BUFFER_STATE yy_scan_string(const char *str);
extern char **environ;

int yyerror(char *s);

// Global Variables
map<string, string> aliasMap;
map<string, string> envMap;

// Bison Helper Functions
void printEnv()
{
    // Make an iterator to print through all env
    map<string, string>::iterator itr;

    for (itr = envMap.begin(); itr != envMap.end(); itr++)
    {
        if (next(itr) != envMap.end())
            printf("%s = %s\n", itr->first.c_str(), itr->second.c_str());
        else
            printf("%s = %s\n", itr->first.c_str(), itr->second.c_str());
    }
}

void addEnv(const char *variable, const char *word)
{
    string envCheck(variable);
    string pathCheck(word);

    if (envCheck != pathCheck)
    {
        envMap[variable] = word;
    }
    else
    {
        yyerror("Add env failed, this would cause a infinite loop!");
    }
}

const char * getEnvVar(const char *variable)
{
    auto itr = envMap.find(variable);
    if (itr == envMap.end())
    {
        return NULL;
    }
    else
    {
        return itr->second.c_str();
    }
}

void removeEnv(const char *variable)
{
    string homeOrPath(variable);
    auto itr = envMap.find(variable);
    if (itr == envMap.end())
    {
        printf("env Does Not Exist\n");
    }
    else if(homeOrPath != "HOME" && homeOrPath != "PATH")
    {
        envMap.erase(variable);
    }
    else
    {
        printf("Cannot unset HOME or PATH env\n");
    }
}

bool isAlias(const char *name)
{
    auto itr = aliasMap.find(name);
    if (itr == aliasMap.end())
    {
        //printf("ALIAS NOT FOUND: ");
        return false;
    }
    else
    {
        //printf("ALIAS WAS FOUND: ");
        return true;
    }
}

bool addAlias(const char *name, const char *command)
{
    string nameCheck(name);
    string commandCheck(command);

    auto itr = aliasMap.find(command);

    if(nameCheck.compare(commandCheck) == 0)
    {
        return false;
    }

    while (itr != aliasMap.end())
    {
        if(itr->second == nameCheck)
        {
            return false;
        }
        itr = aliasMap.find(itr->second);
    }

    aliasMap.insert(pair<string, string>(name, command));
    return true;
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

void findAliasCommand(const char *name)
{
    string aliasCommand(name);
    aliasCommand = aliasMap.find(name)->second;
    // printf("ALIAS COMMAND: %s", aliasCommand.c_str());
    aliasCommand += "\n";
    cmdTable.clear();
    yy_scan_string(aliasCommand.c_str());
    yyparse();
    yylex_destroy();
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

vector<string> getPaths(){
    vector<string> tempVector;
    string paths(getEnvVar("PATH"));
    size_t i = 0;
    string path;

    // If there's just one path add it
    if(paths.find(":") == std::string::npos)
    {
        tempVector.push_back(paths);
    }
    else
    {
        while((i = paths.find(":")) != std::string::npos)
        {
            path = paths.substr(0, i);
            tempVector.push_back(path);
            paths.erase(0, i + 1);
        }
    }
    
    return tempVector;
}

void executeCommand(char *command, char **args)
{
    string comString(command);
    vector<string> paths = getPaths();

    pid_t p = fork();
    if (p < 0)
    {
        perror("Fork Failed");
    }
    else if (p == 0)
    {
        errorPiping();

        if (infile != "")
        {
            FILE *f = fopen(infile.c_str(), "r");
            dup2(fileno(f), 0);
            fclose(f);
        }
        if (outfile != "")
        {
            FILE *f = fopen(outfile.c_str(), appendFlag ? "a" : "w");
            dup2(fileno(f), 1);
            fclose(f);
        }

        // Loop Paths
        for (int i = 0; i < paths.size(); i++)
        {
            string tempStr = paths[i] + "/" + comString; 
            execv(tempStr.c_str(), args);
        }

        // If it's not an actual command print and exit
        printf("Could not find command: %s\n", comString.c_str());
        exit(0);
    }
    else
        wait(0);
}

void executeBGCommand(char *command, char **args)
{
    pid_t p = fork();
    if (p < 0)
    {
        perror("Fork Failed");
    }
    else if (p == 0)
    {
        executeCommand(command, args);
        printf("\nBG Process %s has ended\n", command);
        nutshellTerminalPrint();
        exit(0);
    }
    else
    {
        printf("[1] %d\n", p);
    }
}

void executePipedCommand(char *command, char **args, int pipeFlag)
{
    string comString(command);
    std::vector<std::string> paths = getPaths();

    pid_t p;
    p = fork();
    if (p < 0)
    {
        perror("Fork Failed");
    }
    else if (p == 0)
    {
        errorPiping();

        if (pipeFlag == 0)
        {
            // If it's the first command, and no in file then just write out
            if (infile == "")
            {
                // Open a file and write standard output
                FILE *f = fopen("pipe", "w");
                dup2(fileno(f), 1);
                fclose(f);
            }
            // If it's the first command and there is an in file
            else
            {
                FILE *f1 = fopen(infile.c_str(), "r");
                FILE *f2 = fopen("pipe", "w");
                dup2(fileno(f1), 0);
                dup2(fileno(f2), 1);
                fclose(f1);
                fclose(f2);
            }
        }
        else if (pipeFlag == 2)
        {
            // If it's last command and no output file, just read from path
            if (outfile == "")
            {
                //Last command of the pipe only reads
                FILE *f = fopen("pipe", "r");
                dup2(fileno(f), 0);
                fclose(f);
            }
            // If it's last command and there is and output file, output to that
            else
            {
                FILE *f1 = fopen("pipe", "r");
                FILE *f2 = fopen(outfile.c_str(), appendFlag ? "a" : "w");
                dup2(fileno(f1), 0);
                dup2(fileno(f2), 1);
                fclose(f1);
                fclose(f2);
            }
        }
        else
        {
            // Pipe is inbetween
            FILE *f = fopen("pipe", "rw");
            dup2(fileno(f), 1);
            dup2(fileno(f), 0);
            fclose(f);
        }

        // Loop Paths
        for (int i = 0; i < paths.size(); i++)
        {
            string tempStr = paths[i] + "/" + comString; 
            execv(tempStr.c_str(), args);
        }

        // If it's not an actual command print and exit
        printf("Could not find command: %s\n", comString.c_str());
        exit(0);
    }
    else
        wait(0);
}

void executePipes()
{
    //We can assume that these are piped commands
    for (int i = 0; i < cmdTable.size(); i++)
    {
        char ** args = generateCArgs(cmdTable[i].args, cmdTable[i].commandName.c_str());
        int argFlag;

        if(i == 0) 
            argFlag = 0;
        else if(i == cmdTable.size() - 1)
            argFlag = 2;
        else
            argFlag = 1;

        // Call execute command
        executePipedCommand(args[0], args, argFlag);

        // Free Dynamic memory
        free(args);
    }
    
    //Delete the pipe
    remove("pipe");
}

void executeBGPipes()
{
    pid_t p = fork();
    if (p < 0)
    {
        perror("Fork Failed");
    }
    else if (p == 0)
    {
        executePipes();
        printf("\nBG Process has ended\n");
        nutshellTerminalPrint();
        exit(0);
    }
    else
    {
        printf("[1] %d\n", p);
    }
}

void errorPiping()
{
    if (errfile != "")
    {
        if (errfile == "&1")
        {
            dup2(1, 2);
        }
        else
        {
            FILE *f = fopen(errfile.c_str(), "a");
            dup2(fileno(f), 2);
            fclose(f);
        }
    }
}

void cleanGlobals()
{
    appendFlag = false;
    backgroundFlag = false;
    cmdTable.clear();
    infile = "";
    outfile = "";
}

void globExpand(char * name, vector<string> &args)
{
    glob_t globbuf = {0};
    glob(name, GLOB_DOOFFS, NULL, &globbuf);
    for (size_t i = 0; i != globbuf.gl_pathc; ++i)
    {
        // printf("%s\n", globbuf.gl_pathv[i]);
        args.push_back(globbuf.gl_pathv[i]);
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

    addEnv("HOME", getenv("HOME"));
    addEnv("PATH", ".:/bin:/usr/bin:/usr/local/bin"); // May have to change this later
    white();

#if AUTO //If AUTO is 1 this code will run
    string testArr[] = {"alias beetle \"beetle juice\"", "alias ya yeet", "alias test \"cd ..\"", "alias", "unalias beetle", "alias",
                        "beetle", "test", "cd", "cd ..", "ls", "*.c", "*.h", "cd /NutShell/code", "cd ..", "cd ..",
                        "Yeet", "alias beetle \"beetle juice\"",
                        "\"nutshell/nutshell/nutshell/nutshell\"" /*This should print quote word quote*/,
                        "setenv beetle juice", "printenv", "unsetenv beetle", "printenv beetle",
                        "..", "<", ">", "|", "&", "~", "~/", "cd", "(" /*this should throw an error*/,
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
