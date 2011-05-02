#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"
#include "dtpxml_extern.h"
#include "dtp_logmgr.h"

#define TAG_LCN_D_CONFIG_FILE "lcn_diambase_config_file"
#define TAG_CAPABILITIES "capabilities"
#define TAG_PRODUCT_NAME "product_name"
#define TAG_VENDOR_ID "vendor_id"
#define TAG_VSAI "vendor_specific_application_id"

tagMetadata xmltags[] =
{
{ TAG_LCN_D_CONFIG_FILE, NULL, 1, 1, 0, NULL },
{ TAG_CAPABILITIES, NULL, 0, 1, 0, NULL },
{ TAG_PRODUCT_NAME, TAG_CAPABILITIES, 0, 0, 0, addProductName },
{ TAG_VENDOR_ID, TAG_CAPABILITIES, 0, 0, 0, addSupportedVendorId },
{ TAG_VSAI, TAG_CAPABILITIES, 0, 0, 0, addSupportedVendorId },
{ TAG_VENDOR_ID, TAG_CAPABILITIES TAG_VSAI, 0, 0, 0, addSupportedVendorId },
{ NULL, NULL, 1, 1, 0, NULL } };

tagMetadata * getTagMetadata (userData *ud, char *tag)
{
    logFF ();

    if (ud->error)
    {
        return NULL;
    }

    int counter = -1;
    logMsg (LOG_INFO, "%s%s%s%s\n", "Comparing input tag ", tag, " at fdn ",
        (ud->fdn) ? ud->fdn : "null");
    while (xmltags[++counter].tag != NULL)
    {
        tagMetadata *tm = &xmltags[counter];
        logMsg (LOG_DEBUG, "%s%s%s%s\n", " with tag ", tm->tag, " at fdn ",
            (tm->fdn) ? tm->fdn : "null");
        int match = 1;

        /* If tags don't match */
        if ((0 != strcmp (tm->tag, tag)))
        {
            match = 0;
        }
        /* If only one of fdn is null */
        if ((NULL == ud->fdn && NULL != tm->fdn) || (NULL != ud->fdn && NULL
            == tm->fdn))
        {
            match = 0;
        }
        /* If fdns don't match */
        if ((NULL != ud->fdn) && (NULL != tm->fdn) && (0 != strcmp (tm->fdn,
            ud->fdn)))
        {
            match = 0;
        }
        if (match)
        {
            return tm;
        }
    }
    logMsg (LOG_ERR, "%s%s%s%s\n", "Can not find tag ", tag, " at fdn ",
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

void printRealmConfig (RealmConfig_t *rc)
{
    if (NULL == rc)
    {
        logMsg (LOG_INFO, "%s\n", "realmConfig is Null");
        return;
    }
}

void printPeerConfig (PeerConfig_t *pc)
{
    if (NULL == pc)
    {
        logMsg (LOG_INFO, "%s\n", "peerConfig is Null");
        return;
    }
    logMsg (LOG_INFO, "%s%d\n", "peerTableIndex: ", pc->peerTableIndex);
    logMsg (LOG_INFO, "%s%d\n", "activePeerIndex: ", pc->activePeerIndex);
    logMsg (LOG_INFO, "%s%d\n", "isDynamic: ", pc->isDynamic);
    logMsg (LOG_INFO, "%s%d\n", "expirationTime: ", pc->expirationTime);
    logMsg (LOG_INFO, "%s%d\n", "security: ", pc->security);
    logMsg (LOG_INFO, "%s%d\n", "proto: ", pc->proto);
    logMsg (LOG_INFO, "%s%d\n", "port: ", pc->port);
    logMsg (LOG_INFO, "%s%d\n", "nIpAddresses: ", pc->nIpAddresses);
    for (i = 0; i < pc->nIpAddresses; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%s\n", "ipAddress", i, ": ",
            pc->ipAddresses[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "lastFailedConnectTime: ", pc->lastFailedConnectTime);
}

void printVSA (VendorSpecificAppId_t *vsa)
{
    logMsg (LOG_INFO, "%s%d\n", "nVendorIds: ", vsa->nVendorIds);
    int i = 0;
    for (i = 0; i < vsa->nVendorIds; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%s\n", "vendorIds", i, ": ", vsa->vendorIds[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "isAuth: ", vsa->isAuth);
    logMsg (LOG_INFO, "%s%d\n", "appId: ", vsa->appId);

}
void printOutput (DiameterConfig_t *output)
{
    if (NULL == output)
    {
        logMsg (LOG_INFO, "%s\n", "Output is Null");
        return;
    }
    logMsg (LOG_INFO, "%s%s\n", "nodeName: ",
        ((output->nodeName) ? output->nodeName : "null"));
    logMsg (LOG_INFO, "%s%s\n", "nodeRealm: ",
        ((output->nodeRealm) ? output->nodeRealm : "null"));
    logMsg (LOG_INFO, "%s%d\n", "nAddresses: ", output->nAddresses);
    int i = 0;
    for (i = 0; i < output->nAddresses; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%s\n", "ipAddress", i, ": ",
            output->ipAddresses[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "vendorId: ", output->vendorId);
    logMsg (LOG_INFO, "%s%s\n", "productName: ",
        ((output->productName) ? output->productName : "null"));
    logMsg (LOG_INFO, "%s%d\n", "firmwareRevistion: ", output->firmwareRevision);
    logMsg (LOG_INFO, "%s%d\n", "nVendorIds: ", output->nVendorIds);
    for (i = 0; i < output->nVendorIds; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%s\n", "supportedVendorId", i, ": ",
            output->supportedVendorId[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "nAuthAppIds: ", output->nAuthAppIds);
    for (i = 0; i < output->nAuthAppIds; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%s\n", "supportedAuthAppId", i, ": ",
            output->supportedAuthAppId[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "nAcctAppIds: ", output->nAcctAppIds);
    for (i = 0; i < output->supportedAcctAppId; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%s\n", "supportedAcctAppId", i, ": ",
            output->supportedAcctAppId[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "nVendorSpecificAppIds: ",
        output->nVendorSpecificAppIds);
    for (i = 0; i < output->nVendorSpecificAppIds; i++)
    {
        printVSA (output->supportedVendorSpecificAppId[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "appPort: ", output->appPort);
    logMsg (LOG_INFO, "%s%d\n", "proto: ", output->proto);
    logMsg (LOG_INFO, "%s%d\n", "diamTCPPort: ", output->diamTCPPort);
    logMsg (LOG_INFO, "%s%d\n", "diamSCTPPort: ", output->diamSCTPPort);
    logMsg (LOG_INFO, "%s%d\n", "security: ", output->security);
    logMsg (LOG_INFO, "%s%d\n", "role: ", output->role);
    logMsg (LOG_INFO, "%s%d\n", "numberOfThreads: ", output->numberOfThreads);
    logMsg (LOG_INFO, "%s%d\n", "Twinit: ", output->Twinit);
    logMsg (LOG_INFO, "%s%d\n", "reopenTimer: ", output->reopenTimer);
    logMsg (LOG_INFO, "%s%d\n", "smallPduSize: ", output->smallPduSize);
    logMsg (LOG_INFO, "%s%d\n", "bigPduSize: ", output->bigPduSize);
    logMsg (LOG_INFO, "%s%d\n", "pollingInterval: ", output->pollingInterval);
    logMsg (LOG_INFO, "%s%d\n", "unknownPeerAction: ",
        output->unknownPeerAction);
    logMsg (LOG_INFO, "%s%d\n", "nPeerEntries: ", output->nPeerEntries);
    printPeerConfig (output->peerConfiguration);
    logMsg (LOG_INFO, "%s%d\n", "nRealmEntries: ", output->nRealmEntries);
    printRealmConfig (output->realmConfiguration);
    logMsg (LOG_INFO, "%s%d\n", "nUnknownPeers: ", output->nUnknownPeers);
    for (i = 0; i < output->nUnknownPeers; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%s\n", "unknownPeers", i, ": ",
            output->unknownPeers[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "nodeStateId: ", output->nodeStateId);

}
