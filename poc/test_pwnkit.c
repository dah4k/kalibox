#include <stdlib.h>
#include <unistd.h>

int main()
{
    char const *executable = "/usr/bin/pkexec";

    char *const bad_argv[] = {
        "fake_executable_name",
        "id",
        NULL
    };

    char *const bad_envp[] = {
        "PATH=/usr/bin:/usr/sbin",
        NULL
    };

    return execve(executable, bad_argv, bad_envp);
}
