#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

void __attribute__((constructor)) my_ctor(void) {
    puts("---- DEBUG: my_ctor() ----");
}

static int (*orig_clearenv)(void) = NULL;

int clearenv(void) {
    puts("---- DEBUG: intercept clearenv() ----");

    if (!orig_clearenv) {
        // Our symbol is the first one because LD_PRELOAD,
        // the orignal symbol is the one after (ie. RTLD_NEXT).
        orig_clearenv = dlsym(RTLD_NEXT, "clearenv");
        if (!orig_clearenv) {
            fprintf(stderr, "%s\n", dlerror());
            abort();
        }
    }

    return orig_clearenv();
}
