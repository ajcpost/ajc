
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

typedef struct tag_entry {
    char *tagFDN;
    int ignore;
    void (*handleData) (DiameterConfig_t *output, const char *data);
}tagEntry;

typedef struct user_data {
    int depth;
    char *tagFDN;
    int error;
    char *errorString;
    DiameterConfig_t *output;
} userData;
