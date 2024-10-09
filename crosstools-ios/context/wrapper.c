// based on https://github.com/tpoechtrager/cctools-port/blob/master/usage_examples/ios_toolchain/wrapper.c

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stddef.h>
#include <unistd.h>
#include <limits.h>

#define str(s) #s
#define xstr(s) str(s)

#define OS_VER_MIN "12.0"
#define OS_VER_MIN_NUMBER "120000"

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

    char **args = alloca(sizeof(char*) * (argc+50));
    int i = 0;

    args[i++] = compiler;
    args[i++] = "-target";
    args[i++] = target;
    args[i++] = "-isysroot";
    args[i++] = sdkpath;

    args[i++] = "-arch"; // must be space-separated
    args[i++] = xstr(ARCH);

    args[i++] = "-miphoneos-version-min=" OS_VER_MIN;
    args[i++] = "-D__IPHONE_OS_VERSION_MIN_REQUIRED=" OS_VER_MIN_NUMBER;
    args[i++] = "-DTARGET_OS_IPHONE=1";
    args[i++] = "-mios-version-min=" OS_VER_MIN;
    args[i++] = "-mios-simulator-version-min=" OS_VER_MIN;

    args[i++] = "-mlinker-version=907";
    args[i++] = "-Wl,-adhoc_codesign";
    args[i++] = "-Wno-unused-command-line-argument";
    args[i++] = "-stdlib=libc++";

    for (int j = 1; j < argc; ++i, ++j)
        args[i] = argv[j];

    args[i] = NULL;

    if (getenv("WRAPPER_DEBUG") != NULL) {
        for (int j = 0; args[j]; ++j)
            fprintf(stderr, "%s ", args[j]);
        fprintf(stderr, "\n");
    }

    setenv("COMPILER_PATH", binpath, 1);
    execvp(compiler, args);

    fprintf(stderr, "cannot invoke compiler!\n");
    return 1;
}
