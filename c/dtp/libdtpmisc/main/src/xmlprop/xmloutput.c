#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"
#include "dtpxml_extern.h"
#include "dtp_logmgr.h"


int validateProductName (DiameterConfig_t *output, const char *value)
{
    logFF();

    if (NULL == value)
    {
        return dtpError;
    }
    return dtpSuccess;
}
void addProductName (DiameterConfig_t *output, const char *value)
{
    logFF();

    if (dtpSuccess == validateProductName (output, value))
    {
        strcpy (output->productName, value);
        myfree (value);
    }
}

int validateSupportedVendorId (DiameterConfig_t *output, const char *value)
{
    logFF();

    if (output->nVendorIds >= DC_MAX_SUPPORTED_ID)
    {
        return dtpError;
    }
    if (NULL == value)
    {
        return dtpError;
    }
    return dtpSuccess;
}

void addSupportedVendorId (DiameterConfig_t *output, const char *value)
{
    logFF();

    if (dtpSuccess == validateSupportedVendorId (output, value))
    {
        output->supportedVendorId[output->nVendorIds] = strtol (value, NULL, 0);
        output->nVendorIds++;
        myfree (value);
    }
}
