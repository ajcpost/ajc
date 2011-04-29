#include "config_header.h"
#include "config_proto.h"
#include "config_extern.h"
#include "log_manager.h"

#define TAG_LCN_D_CONFIG_FILE "lcn_diambase_config_file"
#define TAG_CAPABILITIES "capabilities"
#define TAG_PRODUCT_NAME "product_name"
#define TAG_VENDOR_ID "vendor_id"
#define TAG_VSAI "vendor_specific_application_id"

tagEntry xmltags[] =
{
{ TAG_LCN_D_CONFIG_FILE, 1, NULL },
{ TAG_CAPABILITIES, 1, NULL },
{ TAG_CAPABILITIES TAG_PRODUCT_NAME, 0, addProductName },
{ TAG_CAPABILITIES TAG_VENDOR_ID, 0, addSupportedVendorId },
{ TAG_CAPABILITIES TAG_VSAI, 0, addSupportedVendorId },
{ TAG_CAPABILITIES TAG_VSAI TAG_VENDOR_ID, 0, addSupportedVendorId },
{ NULL, 1, NULL } };

char *catTags (int depth, char *tags, char *lastTag)
{
    int i = 0;
    char *p = NULL;
    for (i=0; i<depth; i++)
    {
        p = realloc (p, sizeof(tags[i]));
        strcat (p, tags[i]);
    }
    p = realloc (p, sizeof(lastTag));
    strcat (p, lastTag);
    return p;
}

tagEntry * getTagHandle (userData *ud, const char *name)
{
    if (ud->error)
    {
        return NULL;
    }

    int counter = -1;
    catTags (ud->depth, ud->tagFDN, name);
    logMsg (LOG_INFO, "%s%s%s%s\n", "Comparing input tag ", name);
    while (xmltags[++counter].tag != NULL)
    {
        tagEntry *te = &xmltags[counter];
        logMsg (LOG_DEBUG, "%s\n", " tag ", te->tag);
        if (0 == strcmp (te->tag, name))
        {
            int pc = -1;
            while (ud->te->path[++pc] != NULL)
            {

            }
            return te;
        }
    }
    logMsg (LOG_ERR, "%s%s\n", "Can not parse tag ", name);
    ud->error = 1;
    ud->errorString = malloc (sizeof(char) * 500);
    sprintf (ud->errorString, "%s%s%s", "Tag ", name, " can not be parsed");
    return NULL;
}

int parseXmlConfig (const char * const xmlFilePath)
{
    logFF();

    if (NULL == xmlFilePath)
    {
        logMsg (LOG_CRIT, "%s%s\n", "Null input xml config");
        return -1;
    }

    userData ud;
    memset (&ud, 0, sizeof(ud));
    ud.output = malloc (sizeof(DiameterConfig_t));
    memset (ud.output, 0, sizeof(ud.output));
    ud.te = &xmltags[0];

    // Set approriate handlers
    xmlSAXHandler saxh;
    memset (&saxh, 0, sizeof(saxh));
    saxh.startElement = startElementCallback;
    saxh.endElement = endElementCallback;
    saxh.characters = startDataCallback;

    xmlSAXUserParseFile (&saxh, &ud, xmlFilePath);
    if (ud.error)
    {
        logMsg (LOG_ERR, "%s%s\n", "Error parsing the XML file ",
                ud.errorString);
        return -1;
    }
    return 0;
}
