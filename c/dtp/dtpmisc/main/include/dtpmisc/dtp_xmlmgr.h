#ifndef DTP_XMLMGR_H_
#define DTP_XMLMGR_H_

#include <libxml2/libxml/tree.h>
#include <libxml2/libxml/parser.h>
#include <libxml2/libxml/parserInternals.h>
#include "changed_db_config.h"

typedef struct user_data {
    char *curPath;
    struct tag_metadata *curTm;
    char *dataErrString;  /* processing continues even in error case */
    char *tagErrString;   /* No further processing, if error in tag handling */
    DiameterConfig_t *output;
    void *op;
} userData;

typedef struct tag_metadata {
    char *tag;
    char *parentPath;
    void (*handleStartTagFunc) (struct user_data *ud);
    void (*handleEndTagFunc) (struct user_data *ud);
    void (*handleDataFunc) (struct user_data *ud, char *data);
}tagMetadata;


extern tagMetadata xmltags[];

#endif /* DTP_XMLMGR_H_ */
