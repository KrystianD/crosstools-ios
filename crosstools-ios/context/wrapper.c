// based on https://github.com/tpoechtrager/cctools-port/blob/master/usage_examples/ios_toolchain/wrapper.c

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stddef.h>
#include <unistd.h>
#include <limits.h>

#define OS_VER_MIN "8.0"

char *get_filename(char *str)
{
    char *p = strrchr(str, '/');
    return p ? &p[1] : str;
}

void target_info(char *argv[], char **triple, char **compiler)
{
    char *p = get_filename(argv[0]);
    char *x = strrchr(p, '-');
    if (!x) abort();
    *compiler = &x[1];
    *x = '\0';
    *triple = p;
}

int main(int argc, char *argv[])
{
    char sdkpath[PATH_MAX+1];
    char binpath[PATH_MAX+1];
    char includepath[PATH_MAX+1];
    char libpath[PATH_MAX+1];

    char *compiler;
    char *target;

    target_info(argv, &target, &compiler);
    snprintf(sdkpath, sizeof(sdkpath) - 1, "/usr/%s/sdk", target);
    snprintf(binpath, sizeof(binpath) - 1, "/usr/%s/bin", target);
    snprintf(includepath, sizeof(includepath) - 1, "/usr/%s/include", target);
    snprintf(libpath, sizeof(libpath) - 1, "/usr/%s/lib", target);

    char codesign_allocate[64];
    snprintf(codesign_allocate, sizeof(codesign_allocate), "%s-codesign_allocate", target);
    setenv("CODESIGN_ALLOCATE", codesign_allocate, 1);

    setenv("IOS_FAKE_CODE_SIGN", "1", 1);

    char **args = alloca(sizeof(char*) * (argc+12));
    int i = 0;

    args[i++] = compiler;
    args[i++] = "-target";
    args[i++] = target;
    args[i++] = "-isysroot";
    args[i++] = sdkpath;

    char osvermin[64];
    snprintf(osvermin, sizeof(osvermin), "-miphoneos-version-min=%s", OS_VER_MIN);
    args[i++] = osvermin;

    args[i++] = "-mlinker-version=450.3";

    for (int j = 1; j < argc; ++i, ++j)
        args[i] = argv[j];

    args[i] = NULL;

    setenv("COMPILER_PATH", binpath, 1);
    execvp(compiler, args);

    fprintf(stderr, "cannot invoke compiler!\n");
    return 1;
}
