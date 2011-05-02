#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"
#include "dtpxml_extern.h"
#include "dtp_logmgr.h"

int handleCapProductName (DiameterConfig_t *output, const char *value)
{
    logFF();
    if (NULL == value)
    {
        logMsg (LOG_ERR, "%s\n", "Null value for product_name");
        return -1;
    }
    if (strlen (value) >= DC_MAX_NAME_LEN)
    {
        logMsg (LOG_ERR, "%s%d%s%s\n",
            "Value for product_name exceeds limit of ", DC_MAX_NAME_LEN,
            " chars, actual value is", value);
        return -1;
    }

    strcpy (output->productName, value);
    myfree (value);
    return 0;
}

int handleCapRevision (DiameterConfig_t *output, const char *value)
{
    logFF();
    if (NULL == value)
    {
        logMsg (LOG_ERR, "%s\n", "Null value for revision");
        return -1;
    }
    output->firmwareRevision = strtol (value, 0, NULL);
    myfree (value);
    return 0;
}
