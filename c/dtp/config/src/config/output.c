#include "config_header.h"
#include "config_proto.h"
#include "config_extern.h"
#include "log_manager.h"

int validateProductName (DiameterConfig_t *output, const char *value)
{
    if (NULL == value)
    {
        return dtpError;
    }
    return dtpSuccess;
}
void addProductName (DiameterConfig_t *output, const char *value)
{
    if (dtpSuccess == validateProductName (output, value))
    {
        strcpy (output->productName, value);
        freeAndNull (value);
    }
}

int validateSupportedVendorId (DiameterConfig_t *output, const char *value)
{
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
    if (dtpSuccess == validateSupportedVendorId (output, value))
    {
        output->supportedVendorId[output->nVendorIds] = strtol (value, NULL, 0);
        output->nVendorIds++;
        freeAndNull (value);
    }
}
