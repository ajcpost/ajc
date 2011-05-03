#ifndef DTP_XMLMGR_H_
#define DTP_XMLMGR_H_

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
    int (*handleTagFunc) (DiameterConfig_t *output);
    int (*handleDataFunc) (DiameterConfig_t *output, const char *data);
}tagMetadata;

typedef struct user_data {
    tagMetadata *tm;
    char *fdn;
    int error;
    char *errorString;
    DiameterConfig_t *output;
} userData;

extern tagMetadata xmltags[];

#endif /* DTP_XMLMGR_H_ */
