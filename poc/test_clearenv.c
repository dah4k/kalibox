#include <stdio.h>
#include <stdlib.h>

extern char **environ;

void printenv(char **environ)
{
    while (environ && NULL != *environ) {
        printf("%s\n", *environ++);
    }
}

int main(int argc, char *argv[], char *envp[])
{
    puts("---- PRE clearenv() ----");
    printenv(environ);

    clearenv();

    puts("---- POST clearenv() ----");
    printenv(environ);
    return 0;
}
