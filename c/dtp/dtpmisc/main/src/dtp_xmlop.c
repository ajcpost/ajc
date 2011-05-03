#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"

int handleCapProductName (DiameterConfig_t *output, const char *value)
{
    logFF();
    if (NULL == value)
    {
        logMsg (LOG_ERR, "%s\n", "Null value for capabilities/product_name");
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
        logMsg (LOG_ERR, "%s\n", "Null value for capabilities/revision");
        return -1;
    }
    output->firmwareRevision = strtol (value, NULL, 0);
    myfree (value);
    return 0;
}
int handleCapVendorId (DiameterConfig_t *output, const char *value)
{
    logFF();
    if (NULL == value)
    {
        logMsg (LOG_ERR, "%s\n", "Null value for capabilities/vendor_id");
        return -1;
    }
    output->vendorId = strtol (value, NULL, 0);
    myfree (value);
    return 0;
}
int handleCapSupportedVendorId (DiameterConfig_t *output, const char *value)
{
    logFF();
    if (NULL == value)
    {
        logMsg (LOG_ERR, "%s\n",
            "Null value for capabilities/supported_vendor_id");
        return -1;
    }
    if (DC_MAX_SUPPORTED_ID == output->nVendorIds)
    {
        logMsg (LOG_ERR, "%s%d\n",
            "Number of supported_vendor_id exceeds limit of ",
            DC_MAX_SUPPORTED_ID);
        return -1;
    }
    output->supportedVendorId[output->nVendorIds] = strtol (value, NULL, 0);
    ++output->nVendorIds;
    myfree (value);
    return 0;
}
int handleCapAuthAppId (DiameterConfig_t *output, const char *value)
{
    logFF();
    if (NULL == value)
    {
        logMsg (LOG_ERR, "%s\n", "Null value for capabilities/auth_app_id");
        return -1;
    }
    if (DC_MAX_SUPPORTED_ID == output->nAuthAppIds)
    {
        logMsg (LOG_ERR, "%s%d\n", "Number of auth_app_id exceeds limit of ",
            DC_MAX_SUPPORTED_ID);
        return -1;
    }
    output->supportedAuthAppId[output->nAuthAppIds] = strtol (value, NULL, 0);
    ++output->nAuthAppIds;
    myfree (value);
    return 0;
}
int handleCapAcctAppId (DiameterConfig_t *output, const char *value)
{
    logFF();
    if (NULL == value)
    {
        logMsg (LOG_ERR, "%s\n", "Null value for capabilities/acct_app_id");
        return -1;
    }
    if (DC_MAX_SUPPORTED_ID == output->nAcctAppIds)
    {
        logMsg (LOG_ERR, "%s%d\n", "Number of acct_app_id exceeds limit of ",
            DC_MAX_SUPPORTED_ID);
        return -1;
    }
    output->supportedAcctAppId[output->nAcctAppIds] = strtol (value, NULL, 0);
    ++output->nAcctAppIds;
    myfree (value);
    return 0;
}

int handleCapVsai (DiameterConfig_t *output)
{
    if (DC_MAX_SUPPORTED_ID == output->nVendorSpecificAppIds)
    {
        logMsg (LOG_ERR, "%s%d\n",
            "Number of vendor_specific_application_id exceeds limit of ",
            DC_MAX_SUPPORTED_ID);
        return -1;
    }
    ++(output->nVendorSpecificAppIds);
}

int handleCapVsaiVendorId (DiameterConfig_t *output, const char *value)
{
    logFF();
    if (NULL == value)
    {
        logMsg (LOG_ERR, "%s\n", "Null value for capabilities/Vsai/vendor_id");
        return -1;
    }
    if (DC_MAX_SUPPORTED_ID == output->nVendorSpecificAppIds
        || DC_MAX_SUPPORTED_ID
            == output->supportedVendorSpecificAppId[output->nVendorSpecificAppIds].nVendorIds)
    {
        logMsg (LOG_ERR, "%s%d\n", "Number of vendor_id exceeds limit of ",
            DC_MAX_SUPPORTED_ID);
        return -1;
    }

    int e1 = (output->nVendorSpecificAppIds-1); /*todo */
    int e2 = output->supportedVendorSpecificAppId[e1].nVendorIds;
    output->supportedVendorSpecificAppId[e1].vendorIds[e2] = strtol (value,
        NULL, 0);
    ++(output->supportedVendorSpecificAppId[e1].nVendorIds);
    myfree (value);
    return 0;
}
