#include "config_header.h"
#include "config_proto.h"
#include "config_extern.h"
#include "log_manager.h"

#define TAG_LCN_D_CONFIG_FILE "lcn_diambase_config_file"
#define TAG_CAPABILITIES "capabilities"
#define TAG_PRODUCT_NAME "product_name"
#define TAG_VENDOR_ID "vendor_id"
#define TAG_VSAI "vendor_specific_application_id"

tagHandle xmltags[] =
{
{ TAG_LCN_D_CONFIG_FILE, NULL, 1, 1, NULL },
{ TAG_CAPABILITIES, NULL, 0, 1, NULL },
{ TAG_PRODUCT_NAME, TAG_CAPABILITIES, 0, 0, addProductName },
{ TAG_VENDOR_ID, TAG_CAPABILITIES, 0, 0, addSupportedVendorId },
{ TAG_VSAI, TAG_CAPABILITIES, 0, 0, addSupportedVendorId },
{ TAG_VENDOR_ID, TAG_CAPABILITIES TAG_VSAI, 0, 0, addSupportedVendorId },
{ NULL, NULL, 1, 1, NULL } };

tagHandle * getTagHandle (userData *ud, char *tag)
{
    logFF ();

    if (ud->error)
    {
        logMsg (LOG_WARNING, "%s\n",
                "Parser state in error condition, skipping further handling.");
        return NULL;
    }

    int counter = -1;
    logMsg (LOG_INFO, "%s%s%s%s\n", "Comparing input tag ", tag, " at fdn ",
            (ud->fdn) ? ud->fdn : "null");
    while (xmltags[++counter].tag != NULL)
    {
        tagHandle *th = &xmltags[counter];
        logMsg (LOG_DEBUG, "%s%s%s%s\n", " with tag ", th->tag, " at fdn ",
                (th->fdn) ? th->fdn : "null");
        int match = 1;

        /* If tags don't match */
        if ((0 != strcmp (th->tag, tag)))
        {
            match = 0;
        }
        /* If only one of fdn is null */
        if ((NULL == ud->fdn && NULL != th->fdn) || (NULL != ud->fdn && NULL
            == th->fdn))
        {
            match = 0;
        }
        /* If fdns don't match */
        if ((NULL != ud->fdn) && (NULL != th->fdn) && (0 != strcmp (th->fdn,
                                                                    ud->fdn)))
        {
            match = 0;
        }
        if (match)
        {
            return th;
        }
    }
    logMsg (LOG_ERR, "%s%s%s%s\n", "Can not find tag tag ", tag, " at fdn ",
            ((ud->fdn) ? ud->fdn : "null"));
    ud->error = 1;
    ud->errorString = malloc (sizeof(char) * 500);
    sprintf (ud->errorString, "%s%s%s%s\n", "Can not find tag ", tag,
             " at fdn ", ((ud->fdn) ? ud->fdn : "null"));
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
