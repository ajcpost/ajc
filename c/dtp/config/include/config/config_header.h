
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <time.h>
#include <sys/stat.h>
#include <syslog.h>
#include <libxml2/libxml/tree.h>
#include <libxml2/libxml/parser.h>
#include <libxml2/libxml/parserInternals.h>
#include "db_config.h"

typedef struct tag_handle {
    char *tag;
    char *fdn;
    int ignoreTag;
    int ignoreData;
    void (*handleData) (DiameterConfig_t *output, const char *data);
}tagHandle;

typedef struct user_data {
    tagHandle *th;
    char *fdn;
    int error;
    char *errorString;
    DiameterConfig_t *output;
} userData;
