#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"

int handleCapProductName (DiameterConfig_t *output, char *value)
{
    logFF();
    if (strlen (value) >= DC_MAX_NAME_LEN)
    {
        logMsg (LOG_ERR, "%s%d%s%s\n",
            "Value for product_name exceeds limit of ", DC_MAX_NAME_LEN,
            " chars; value is ", value);
        return -1;
    }
    strcpy (output->productName, value);
    return 0;
}

int handleCapRevision (DiameterConfig_t *output, char *value)
{
    logFF();
    output->firmwareRevision = strtol (value, NULL, 0);
    return 0;
}
int handleCapVendorId (DiameterConfig_t *output, char *value)
{
    logFF();
    output->vendorId = strtol (value, NULL, 0);
    return 0;
}
int handleCapSupportedVendorId (DiameterConfig_t *output, char *value)
{
    logFF();
    if (DC_MAX_SUPPORTED_ID == output->nVendorIds)
    {
        logMsg (LOG_ERR, "%s%d\n",
            "Number of supported_vendor_id exceeds limit of ",
            DC_MAX_SUPPORTED_ID);
        return -1;
    }
    output->supportedVendorId[output->nVendorIds] = strtol (value, NULL, 0);
    ++output->nVendorIds;
    return 0;
}
int handleCapAuthAppId (DiameterConfig_t *output, char *value)
{
    logFF();
    if (DC_MAX_SUPPORTED_ID == output->nAuthAppIds)
    {
        logMsg (LOG_ERR, "%s%d\n", "Number of auth_app_id exceeds limit of ",
            DC_MAX_SUPPORTED_ID);
        return -1;
    }
    output->supportedAuthAppId[output->nAuthAppIds] = strtol (value, NULL, 0);
    ++output->nAuthAppIds;
    return 0;
}
int handleCapAcctAppId (DiameterConfig_t *output, char *value)
{
    logFF();
    if (DC_MAX_SUPPORTED_ID == output->nAcctAppIds)
    {
        logMsg (LOG_ERR, "%s%d\n", "Number of acct_app_id exceeds limit of ",
            DC_MAX_SUPPORTED_ID);
        return -1;
    }
    output->supportedAcctAppId[output->nAcctAppIds] = strtol (value, NULL, 0);
    ++output->nAcctAppIds;
    return 0;
}

int handleCapVsaiVendorId (DiameterConfig_t *output, char *value)
{
    logFF();
    int curVsaPosition = (output->nVendorSpecificAppIds - 1);
    if (DC_MAX_SUPPORTED_ID
        == output->supportedVendorSpecificAppId[curVsaPosition].nVendorIds)
    {
        logMsg (LOG_ERR, "%s%d%s%d\n", "Number of vendor_id exceeds limit of ",
            DC_MAX_SUPPORTED_ID, " for VSA at position ", curVsaPosition);
        return -1;
    }
    ++(output->supportedVendorSpecificAppId[curVsaPosition].nVendorIds);
    int vendorPositionInCurVsa =
        (output->supportedVendorSpecificAppId[curVsaPosition].nVendorIds - 1);
    output->supportedVendorSpecificAppId[curVsaPosition].vendorIds[vendorPositionInCurVsa]
        = strtol (value, NULL, 0);
    return 0;
}

int handleCapVsaiAuthAppId (DiameterConfig_t *output, char *value)
{
    logFF();
    int curVsaPosition = (output->nVendorSpecificAppIds - 1);
    if (output->supportedVendorSpecificAppId[curVsaPosition].isAuth != -1)
    {
        logMsg (LOG_ERR, "%s\n", "Auth or Acct id is alredy set");
        return -1;
    }
    output->supportedVendorSpecificAppId[curVsaPosition].appId = strtol (value,
        NULL, 0);
    output->supportedVendorSpecificAppId[curVsaPosition].isAuth = 1;
}

int handleCapVsaiAcctAppId (DiameterConfig_t *output, char *value)
{
    logFF();
    int curVsaPosition = (output->nVendorSpecificAppIds - 1);
    if (output->supportedVendorSpecificAppId[curVsaPosition].isAuth != -1)
    {
        logMsg (LOG_ERR, "%s\n", "Auth or Acct id is alredy set");
        return -1;
    }
    output->supportedVendorSpecificAppId[curVsaPosition].appId = strtol (value,
        NULL, 0);
    output->supportedVendorSpecificAppId[curVsaPosition].isAuth = 0;
}

int handleTransportAppPort (DiameterConfig_t *output, char *value)
{
    logFF();
    output->appPort = strtol (value, NULL, 0);
    return 0;
}
int handleTransportProto (DiameterConfig_t *output, char *value)
{
    logFF();
    output->proto = strtol (value, NULL, 0);
    return 0;
}
int handleTransportTcpPort (DiameterConfig_t *output, char *value)
{
    logFF();
    output->diamTCPPort = strtol (value, NULL, 0);
    return 0;
}
int handleTransportSctpPort (DiameterConfig_t *output, char *value)
{
    logFF();
    output->diamSCTPPort = strtol (value, NULL, 0);
    return 0;
}

int handleTransportUnknownPeerAction (DiameterConfig_t *output, char *value)
{
    logFF();
    output->unknownPeerAction = strtol (value, NULL, 0);
    return 0;
}

int handleImplRole (DiameterConfig_t *output, char *value)
{
    logFF();
    output->role = strtol (value, NULL, 0);
    return 0;
}
int handleImplNumOfThreads (DiameterConfig_t *output, char *value)
{
    logFF();
    output->numberOfThreads = strtol (value, NULL, 0);
    return 0;
}
int handleImplTwinit (DiameterConfig_t *output, char *value)
{
    logFF();
    output->Twinit = strtol (value, NULL, 0);
    return 0;
}
int handleImplInactivity (DiameterConfig_t *output, char *value)
{
    logFF();
    output->inactivityTimer = strtol (value, NULL, 0);
    return 0;
}
int handleImplReopenTimer (DiameterConfig_t *output, char *value)
{
    logFF();
    output->reopenTimer = strtol (value, NULL, 0);
    return 0;
}
int handleImplSmallPdu (DiameterConfig_t *output, char *value)
{
    logFF();
    output->smallPduSize = strtol (value, NULL, 0);
    return 0;
}
int handleImplBigPdu (DiameterConfig_t *output, char *value)
{
    logFF();
    output->bigPduSize = strtol (value, NULL, 0);
    return 0;
}

int handleTagCapVsai (DiameterConfig_t *output)
{
    if (DC_MAX_SUPPORTED_ID == output->nVendorSpecificAppIds)
    {
        logMsg (LOG_ERR, "%s%d\n",
            "Number of vendor_specific_application_id exceeds limit of ",
            DC_MAX_SUPPORTED_ID);
        return -1;
    }
    ++(output->nVendorSpecificAppIds);
    output->supportedVendorSpecificAppId[output->nVendorSpecificAppIds].isAuth
        = -1;
}
int handleTagTransportPTPeer (DiameterConfig_t *output)
{
    /*if (DC_MAX_SUPPORTED_ID == output->nPeerEntries)
     {
     logMsg (LOG_ERR, "%s%d\n",
     "Number of peer configs exceeds limit of ",
     DC_MAX_SUPPORTED_ID);
     return -1;
     }*/
    ++(output->nPeerEntries);
    output->peerConfiguration = realloc (peerConfiguration,
        (output->nPeerEntries * sizeof(*(output->peerConfiguration))));
}
