#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"

#define MAX_ERROR_LENGTH 200
char errString[MAX_ERROR_LENGTH];

void appendDataError (userData *ud, char *errString)
{
    logMsg (LOG_ERR, "%s\n", errString);
    int curLen = ud->dataErrString ? (strlen (ud->dataErrString)) : 0;
    int incrementalLen = strlen (errString);
    ud->dataErrString = realloc (ud->dataErrString, (curLen + incrementalLen
        + 2));
    strcpy ((ud->dataErrString + curLen), "\n");
    strcpy ((ud->dataErrString + curLen + 1), errString);
}
void handleCapProductName (userData *ud, char *data)
{
    logFF();
    if (strlen (data) >= DC_MAX_NAME_LEN)
    {
        sprintf (errString, "%s%d%s%s\n",
            "Value for product_name exceeds limit of ", DC_MAX_NAME_LEN,
            " chars; data is ", data);
        appendDataError (ud, errString);
        return;
    }
    strcpy (ud->output->productName, data);
}

void handleCapRevision (userData *ud, char *data)
{
    logFF();
    ud->output->firmwareRevision = strtol (data, NULL, 0);
}
void handleCapVendorId (userData *ud, char *data)
{
    logFF();
    ud->output->vendorId = strtol (data, NULL, 0);
}
void handleCapIPAddress (userData *ud, char *data)
{
    logFF();
    int curIPAddrPosition = (ud->output->nAddresses - 1);

    if (strlen (data) >= DC_MAX_HOSTNAME_LEN) /* todo, use correct max size */
    {
        sprintf (errString, "%s%d%s%s\n",
            "Value for capability ipaddress exceeds limit of ",
            DC_MAX_HOSTNAME_LEN, " chars; data is ", data);
        appendDataError (ud, errString);
        return;
    }
    strcpy (ud->output->ipAddresses[curIPAddrPosition], data);
}
void handleCapSupportedVendorId (userData *ud, char *data)
{
    logFF();
    if (DC_MAX_SUPPORTED_ID == ud->output->nVendorIds)
    {
        sprintf (errString, "%s%d\n",
            "Number of supported_vendor_id exceeds limit of ",
            DC_MAX_SUPPORTED_ID);
        appendDataError (ud, errString);
        return;
    }
    ud->output->supportedVendorId[ud->output->nVendorIds] = strtol (data, NULL,
        0);
    ++ud->output->nVendorIds;
}
void handleCapAuthAppId (userData *ud, char *data)
{
    logFF();
    if (DC_MAX_SUPPORTED_ID == ud->output->nAuthAppIds)
    {
        sprintf (errString, "%s%d\n",
            "Number of auth_app_id exceeds limit of ", DC_MAX_SUPPORTED_ID);
        appendDataError (ud, errString);
        return;
    }
    ud->output->supportedAuthAppId[ud->output->nAuthAppIds] = strtol (data,
        NULL, 0);
    ++ud->output->nAuthAppIds;
}
void handleCapAcctAppId (userData *ud, char *data)
{
    logFF();
    if (DC_MAX_SUPPORTED_ID == ud->output->nAcctAppIds)
    {
        sprintf (errString, "%s%d\n",
            "Number of acct_app_id exceeds limit of ", DC_MAX_SUPPORTED_ID);
        appendDataError (ud, errString);
        return;
    }
    ud->output->supportedAcctAppId[ud->output->nAcctAppIds] = strtol (data,
        NULL, 0);
    ++ud->output->nAcctAppIds;
}

void handleCapVsaiVendorId (userData *ud, char *data)
{
    logFF();
    int curVsaPosition = (ud->output->nVendorSpecificAppIds - 1);
    if (DC_MAX_SUPPORTED_ID
        == ud->output->supportedVendorSpecificAppId[curVsaPosition].nVendorIds)
    {
        sprintf (errString, "%s%d%s%d\n",
            "Number of vendor_id exceeds limit of ", DC_MAX_SUPPORTED_ID,
            " for VSA at position ", curVsaPosition);
        appendDataError (ud, errString);
        return;
    }
    ++(ud->output->supportedVendorSpecificAppId[curVsaPosition].nVendorIds);
    int vendorPositionInCurVsa =
        (ud->output->supportedVendorSpecificAppId[curVsaPosition].nVendorIds
            - 1);
    ud->output->supportedVendorSpecificAppId[curVsaPosition].vendorIds[vendorPositionInCurVsa]
        = strtol (data, NULL, 0);
}

void handleCapVsaiAuthAppId (userData *ud, char *data)
{
    logFF();
    int curVsaPosition = (ud->output->nVendorSpecificAppIds - 1);
    if (ud->output->supportedVendorSpecificAppId[curVsaPosition].isAuth != -1)
    {
        sprintf (errString, "%s\n", "Auth or Acct id is alredy set");
        appendDataError (ud, errString);
        return;
    }
    ud->output->supportedVendorSpecificAppId[curVsaPosition].appId = strtol (
        data, NULL, 0);
    ud->output->supportedVendorSpecificAppId[curVsaPosition].isAuth = 1;
}

void handleCapVsaiAcctAppId (userData *ud, char *data)
{
    logFF();
    int curVsaPosition = (ud->output->nVendorSpecificAppIds - 1);
    if (ud->output->supportedVendorSpecificAppId[curVsaPosition].isAuth != -1)
    {
        sprintf (errString, "%s\n", "Auth or Acct id is alredy set");
        appendDataError (ud, errString);
        return;
    }
    ud->output->supportedVendorSpecificAppId[curVsaPosition].appId = strtol (
        data, NULL, 0);
    ud->output->supportedVendorSpecificAppId[curVsaPosition].isAuth = 0;
}

void handleTransportNodeName (userData *ud, char *data)
{
    logFF();
    if (strlen (data) >= DC_MAX_NAME_LEN) /* todo use correct MAX */
    {
        sprintf (errString, "%s%d%s%s\n",
            "Value for nodename exceeds limit of ", DC_MAX_NAME_LEN,
            " chars; data is ", data);
        appendDataError (ud, errString);
        return;
    }
    strcpy ((char *) ud->output->nodeName, data);
}
void handleTransportNodeRealm (userData *ud, char *data)
{
    logFF();
    if (strlen (data) >= DC_MAX_NAME_LEN) /* todo use correct MAX */
    {
        sprintf (errString, "%s%d%s%s\n",
            "Value for realmname exceeds limit of ", DC_MAX_NAME_LEN,
            " chars; data is ", data);
        appendDataError (ud, errString);
        return;
    }
    strcpy ((char *) ud->output->nodeRealm, data);
}
void handleTransportAppPort (userData *ud, char *data)
{
    logFF();
    ud->output->appPort = strtol (data, NULL, 0);
}
void handleTransportProto (userData *ud, char *data)
{
    logFF();
    ud->output->proto = strtol (data, NULL, 0);
}
void handleTransportTcpPort (userData *ud, char *data)
{
    logFF();
    ud->output->diamTCPPort = strtol (data, NULL, 0);
}
void handleTransportSctpPort (userData *ud, char *data)
{
    logFF();
    ud->output->diamSCTPPort = strtol (data, NULL, 0);
}

void handleTransportUnknownPeerAction (userData *ud, char *data)
{
    logFF();
    ud->output->unknownPeerAction = strtol (data, NULL, 0);
}

void handleTransportPTPeerHostname (userData *ud, char *data)
{
    logFF();
    if (strlen (data) >= DC_MAX_NAME_LEN)
    {
        sprintf (errString, "%s%d%s%s\n",
            "Value for peer hostname exceeds limit of ", DC_MAX_NAME_LEN,
            " chars; data is ", data);
        appendDataError (ud, errString);
        return;
    }
    PeerConfig_t *pc = (PeerConfig_t *) ud->op;
    strcpy (pc->hostName, data);
}
void handleTransportPTPeerSecurity (userData *ud, char *data)
{
    logFF();
    PeerConfig_t *pc = (PeerConfig_t *) ud->op;
    pc->security = strtol (data, NULL, 0);
}
void handleTransportPTPeerProto (userData *ud, char *data)
{
    logFF();
    PeerConfig_t *pc = (PeerConfig_t *) ud->op;
    pc->proto = strtol (data, NULL, 0);
}
void handleTransportPTPeerTcpPort (userData *ud, char *data)
{
    logFF();
    PeerConfig_t *pc = (PeerConfig_t *) ud->op;
    pc->tcp_port = strtol (data, NULL, 0);
}
void handleTransportPTPeerSctpPort (userData *ud, char *data)
{
    logFF();
    PeerConfig_t *pc = (PeerConfig_t *) ud->op;
    pc->sctp_port = strtol (data, NULL, 0);
}
void handleTransportPTPeerIPAddress (userData *ud, char *data)
{
    logFF();
    PeerConfig_t *pc = (PeerConfig_t *) ud->op;
    int curIPAddrPosition = (pc->nIpAddresses - 1);

    if (strlen (data) >= DC_MAX_HOSTNAME_LEN) /* todo, use correct max size */
    {
        sprintf (errString, "%s%d%s%s\n",
            "Value for peer ipaddress exceeds limit of ", DC_MAX_HOSTNAME_LEN,
            " chars; data is ", data);
        appendDataError (ud, errString);
        return;
    }
    strcpy (pc->ipAddresses[curIPAddrPosition], data);
}

void handleTransportRTRouteRealm (userData *ud, char *data)
{
    logFF();
    if (strlen (data) >= DC_MAX_NAME_LEN) /*todo correct MAX */
    {
        sprintf (errString, "%s%d%s%s\n",
            "Value for peer realmname exceeds limit of ", DC_MAX_NAME_LEN,
            " chars; data is ", data);
        appendDataError (ud, errString);
        return;
    }
    RealmConfig_t *rc = (RealmConfig_t *) ud->op;
    strcpy (rc->realmName, data);
}
void handleTransportRTRouteAction (userData *ud, char *data)
{
    logFF();
    RealmConfig_t *rc = (RealmConfig_t *) ud->op;
    rc->action = strtol (data, NULL, 0);
}
void handleTransportRTRouteAppId (userData *ud, char *data)
{
    logFF();
    RealmConfig_t *rc = (RealmConfig_t *) ud->op;
    rc->appIdentifier = strtol (data, NULL, 0);
}
void handleTransportRTRouteAppVendorId (userData *ud, char *data)
{
    logFF();
    RealmConfig_t *rc = (RealmConfig_t *) ud->op;
    rc->vendorId = strtol (data, NULL, 0);
}

void handleTransportRTRouteAppPeerServer (userData *ud, char *data)
{
    logFF();
    RealmConfig_t *rc = (RealmConfig_t *) ud->op;
    int curServerPosition = (rc->nServers - 1);

    if (strlen (data) >= DC_MAX_HOSTNAME_LEN) /* todo, use correct max size */
    {
        sprintf (errString, "%s%d%s%s\n",
            "Value for route peer server exceeds limit of ", DC_MAX_HOSTNAME_LEN,
            " chars; data is ", data);
        appendDataError (ud, errString);
        return;
    }
    strcpy (rc->serverList[curServerPosition].serverName, data);
}
void handleTransportRTRouteAppPeerWeight (userData *ud, char *data)
{
    logFF();
    RealmConfig_t *rc = (RealmConfig_t *) ud->op;
    int curServerPosition = (rc->nServers - 1);
    rc->serverList[curServerPosition].weight = strtol (data, NULL, 0);
}


void handleImplRole (userData *ud, char *data)
{
    logFF();
    ud->output->role = strtol (data, NULL, 0);
}
void handleImplNumOfThreads (userData *ud, char *data)
{
    logFF();
    ud->output->numberOfThreads = strtol (data, NULL, 0);
}
void handleImplTwinit (userData *ud, char *data)
{
    logFF();
    ud->output->Twinit = strtol (data, NULL, 0);
}
void handleImplInactivity (userData *ud, char *data)
{
    logFF();
    ud->output->inactivityTimer = strtol (data, NULL, 0);
}
void handleImplReopenTimer (userData *ud, char *data)
{
    logFF();
    ud->output->reopenTimer = strtol (data, NULL, 0);
}
void handleImplSmallPdu (userData *ud, char *data)
{
    logFF();
    ud->output->smallPduSize = strtol (data, NULL, 0);
}
void handleImplBigPdu (userData *ud, char *data)
{
    logFF();
    ud->output->bigPduSize = strtol (data, NULL, 0);
}
void handleImplPollingInterval (userData *ud, char *data)
{
    logFF();
    ud->output->pollingInterval = strtol (data, NULL, 0);
}

void handleStartTagCapVsai (userData *ud)
{
    logFF();
    if (DC_MAX_SUPPORTED_ID == ud->output->nVendorSpecificAppIds)
    {
        sprintf (errString, "%s%d\n",
            "Number of vendor_specific_application_id exceeds limit of ",
            DC_MAX_SUPPORTED_ID);
        appendDataError (ud, errString);
        return;
    }
    ud->output->supportedVendorSpecificAppId[ud->output->nVendorSpecificAppIds].isAuth
        = -1;
    ++(ud->output->nVendorSpecificAppIds);
}
void handleEndTagCapVsai (userData *ud)
{
    logFF();
    int curVsaPos = (ud->output->nVendorSpecificAppIds-1);
    if (-1 == ud->output->supportedVendorSpecificAppId[curVsaPos].isAuth)
    {
        sprintf (errString, "%s%d\n",
            "None of acct or auth id set for VSA position ", curVsaPos);
        appendDataError (ud, errString);
    }
}
void handleStartTagCapIPAddress (userData *ud)
{
    logFF();
    if (DC_MAX_IP_ADDRESSES_PER_PEER == ud->output->nAddresses) /*todo use correct MAX */
    {
        sprintf (errString, "%s%d\n",
            "Number of ipaddress for capability exceeds limit of ",
            DC_MAX_IP_ADDRESSES_PER_PEER);
        appendDataError (ud, errString);
        return;
    }
    ++(ud->output->nAddresses);
}
void handleStartTagTransportPTPeer (userData *ud)
{
    logFF();
    PeerConfig_t *pc = malloc (sizeof(*pc));
    ud->op = (void*) pc;
}
void handleEndTagTransportPTPeer (userData *ud)
{
    logFF();
    PeerConfig_t *pc = (void *) ud->op;
    ud->op = NULL;
    addPeerTableEntry (ud, pc);
}
void handleStartTagTransportPTPeerIPAddress (userData *ud)
{
    logFF();
    PeerConfig_t *pc = (void *) ud->op;
    if (DC_MAX_IP_ADDRESSES_PER_PEER == pc->nIpAddresses)
    {
        sprintf (errString, "%s%d\n",
            "Number of ipaddress for peer exceeds limit of ",
            DC_MAX_IP_ADDRESSES_PER_PEER);
        appendDataError (ud, errString);
        return;
    }
    ++(pc->nIpAddresses);
}

void handleStartTagTransportRTRoute (userData *ud)
{
    logFF();
    RealmConfig_t *rc = malloc (sizeof(*rc));
    ud->op = (void*) rc;
}
void handleEndTagTransportRTRoute (userData *ud)
{
    logFF();
    RealmConfig_t *rc = (void *) ud->op;
    ud->op = NULL;
    addRealmTableEntry (ud, rc);
}

void handleStartTagTransportRTRouteAppPeer (userData *ud)
{
    logFF();
    RealmConfig_t *rc = (void *) ud->op;
    if (DC_MAX_IP_ADDRESSES_PER_PEER == rc->nServers) /* todo use correct MAX */
    {
        sprintf (errString, "%s%d\n",
            "Number of peer for route exceeds limit of ",
            DC_MAX_IP_ADDRESSES_PER_PEER);
        appendDataError (ud, errString);
        return;
    }
    ++(rc->nServers);
}









/* Dummy function. Replaces previous value of pc, if any */
void addPeerTableEntry (userData *ud, PeerConfig_t *pc)
{
    logMsg (LOG_ERR, "%s\n", "Adding Peer config");
    ud->output->peerConfiguration = pc;
}
/* Dummy function. Replaces previous value of rc, if any */
void addRealmTableEntry (userData *ud, RealmConfig_t *rc)
{
    logMsg (LOG_ERR, "%s\n", "Adding Realm config");
    ud->output->realmConfiguration = rc;
}
