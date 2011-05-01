
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

typedef struct tag_metadata {
    char *tag;
    char *fdn;
    int ignoreTag;
    int ignoreData;
    int dataProcessed;
    void (*handleDataFunc) (DiameterConfig_t *output, const char *data);
}tagMetadata;

typedef struct user_data {
    tagMetadata *tm;
    char *fdn;
    int error;
    char *errorString;
    DiameterConfig_t *output;
} userData;
