#include "dtpxml_hdr.h"
#include "dtpxml_proto.h"

#define MAX_ERROR_LENGTH 500
char errString[MAX_ERROR_LENGTH];

#define TAG_LCN_D "lcn_diambase_config_file"
#define TAG_CAPABILITIES "capabilities"
#define TAG_PRODUCT_NAME "product_name"
#define TAG_REVISION "revision"
#define TAG_IPADDRESS "ipaddress"
#define TAG_VENDOR_ID "vendor_id"
#define TAG_SUPPORTED_VENDOR_ID "supported_vendor_id"
#define TAG_AUTH_APP_ID "auth_application_id"
#define TAG_ACCT_APP_ID "acct_application_id"
#define TAG_VSAI "vendor_specific_application_id"
#define TAG_TRANSPORT "transport"
#define TAG_NODENAME "nodename"
#define TAG_REALM "realm"
#define TAG_PROTO "proto"
#define TAG_APP_PORT "app_port"
#define TAG_TCP_PORT "tcp_port"
#define TAG_SCTP_PORT "sctp_port"
#define TAG_UNKNOWN_PEER_ACTION "unknown_peer_action"
#define TAG_PEER_TABLE "peer_table"
#define TAG_PEER "peer"
#define TAG_HOSTNAME "hostname"
#define TAG_SECURITY "security"
#define TAG_ROUTE_TABLE "route_table"
#define TAG_ROUTE "route"
#define TAG_ACTION "action"
#define TAG_ROLE "role"
#define TAG_APP "application"
#define TAG_APP_ID "application_id"
#define TAG_SERVER "server"
#define TAG_WEIGHT "weight"
#define TAG_ID "id"
#define TAG_TYPE "type"
#define TAG_PEER_ENTRY "peer_entry"
#define TAG_METRIC "metric"
#define TAG_IMPL "implementation"
#define TAG_TWINIT "twinit"
#define TAG_INACTIVITY "inactivity"
#define TAG_ROLE "role"
#define TAG_NUM_THREADS "num_threads"
#define TAG_REOPEN_TIMER "reopen_timer"
#define TAG_POLLING_INTERVAL "polling_interval"
#define TAG_DUP_WATCH "duplicate_watch"
#define TAG_SMALL_PDU "small_pdu_size"
#define TAG_BIG_PDU "big_pdu_size"

tagMetadata
    xmltags[] =
        {
        { TAG_LCN_D, NULL, NULL, NULL, NULL },
        { TAG_CAPABILITIES, TAG_LCN_D, NULL, NULL, NULL },
        { TAG_PRODUCT_NAME, TAG_LCN_D TAG_CAPABILITIES, NULL, NULL, handleCapProductName },
        { TAG_REVISION, TAG_LCN_D TAG_CAPABILITIES, NULL, NULL, handleCapRevision },
        { TAG_IPADDRESS, TAG_LCN_D TAG_CAPABILITIES, handleStartTagCapIPAddress, NULL, handleCapIPAddress },
        { TAG_VENDOR_ID, TAG_LCN_D TAG_CAPABILITIES, NULL, NULL, handleCapVendorId },
        { TAG_SUPPORTED_VENDOR_ID, TAG_LCN_D TAG_CAPABILITIES, NULL, NULL, handleCapSupportedVendorId },
        { TAG_AUTH_APP_ID, TAG_LCN_D TAG_CAPABILITIES, NULL, NULL, handleCapAuthAppId },
        { TAG_ACCT_APP_ID, TAG_LCN_D TAG_CAPABILITIES, NULL, NULL, handleCapAcctAppId },
        { TAG_VSAI, TAG_LCN_D TAG_CAPABILITIES, handleStartTagCapVsai, handleEndTagCapVsai, NULL },
        { TAG_VENDOR_ID, TAG_LCN_D TAG_CAPABILITIES TAG_VSAI, NULL, NULL, handleCapVsaiVendorId },
        { TAG_AUTH_APP_ID, TAG_LCN_D TAG_CAPABILITIES TAG_VSAI, NULL, NULL, handleCapVsaiAuthAppId },
        { TAG_ACCT_APP_ID, TAG_LCN_D TAG_CAPABILITIES TAG_VSAI, NULL, NULL, handleCapVsaiAcctAppId },
        { TAG_TRANSPORT, TAG_LCN_D, NULL, NULL, NULL },
        { TAG_NODENAME, TAG_LCN_D TAG_TRANSPORT, NULL, NULL, handleTransportNodeName },
        { TAG_REALM, TAG_LCN_D TAG_TRANSPORT, NULL, NULL, handleTransportNodeRealm },
        { TAG_PROTO, TAG_LCN_D TAG_TRANSPORT, NULL, NULL, handleTransportProto },
        { TAG_APP_PORT, TAG_LCN_D TAG_TRANSPORT, NULL, NULL, handleTransportAppPort },
        { TAG_TCP_PORT, TAG_LCN_D TAG_TRANSPORT, NULL, NULL, handleTransportTcpPort },
        { TAG_SCTP_PORT, TAG_LCN_D TAG_TRANSPORT, NULL, NULL, handleTransportSctpPort },
        { TAG_UNKNOWN_PEER_ACTION, TAG_LCN_D TAG_TRANSPORT, NULL, NULL, handleTransportUnknownPeerAction },
        { TAG_PEER_TABLE, TAG_LCN_D TAG_TRANSPORT, NULL, NULL, NULL },
        { TAG_PEER, TAG_LCN_D TAG_TRANSPORT TAG_PEER_TABLE, handleStartTagTransportPTPeer, handleEndTagTransportPTPeer, NULL },
        { TAG_HOSTNAME, TAG_LCN_D TAG_TRANSPORT TAG_PEER_TABLE TAG_PEER, NULL, NULL, handleTransportPTPeerHostname },
        { TAG_PROTO, TAG_LCN_D TAG_TRANSPORT TAG_PEER_TABLE TAG_PEER, NULL, NULL, handleTransportPTPeerProto },
        { TAG_TCP_PORT, TAG_LCN_D TAG_TRANSPORT TAG_PEER_TABLE TAG_PEER, NULL, NULL, handleTransportPTPeerTcpPort },
        { TAG_SCTP_PORT, TAG_LCN_D TAG_TRANSPORT TAG_PEER_TABLE TAG_PEER, NULL, NULL, handleTransportPTPeerSctpPort },
        { TAG_SECURITY, TAG_LCN_D TAG_TRANSPORT TAG_PEER_TABLE TAG_PEER, NULL, NULL, handleTransportPTPeerSecurity },
        { TAG_IPADDRESS, TAG_LCN_D TAG_TRANSPORT TAG_PEER_TABLE TAG_PEER, handleStartTagTransportPTPeerIPAddress, NULL, handleTransportPTPeerIPAddress },
        { TAG_ROUTE_TABLE, TAG_LCN_D TAG_TRANSPORT, NULL, NULL, NULL },
        { TAG_ROUTE, TAG_LCN_D TAG_TRANSPORT TAG_ROUTE_TABLE, handleStartTagTransportRTRoute, handleEndTagTransportRTRoute, NULL },
        { TAG_REALM, TAG_LCN_D TAG_TRANSPORT TAG_ROUTE_TABLE TAG_ROUTE, NULL, NULL, handleTransportRTRouteRealm },
        { TAG_ACTION, TAG_LCN_D TAG_TRANSPORT TAG_ROUTE_TABLE TAG_ROUTE, NULL, NULL, handleTransportRTRouteAction },
        { TAG_APP, TAG_LCN_D TAG_TRANSPORT TAG_ROUTE_TABLE TAG_ROUTE, NULL, NULL, NULL },
        { TAG_APP_ID, TAG_LCN_D TAG_TRANSPORT TAG_ROUTE_TABLE TAG_ROUTE TAG_APP, NULL, NULL, handleTransportRTRouteAppId },
        { TAG_VENDOR_ID, TAG_LCN_D TAG_TRANSPORT TAG_ROUTE_TABLE TAG_ROUTE TAG_APP, NULL, NULL, handleTransportRTRouteAppVendorId },
        { TAG_PEER, TAG_LCN_D TAG_TRANSPORT TAG_ROUTE_TABLE TAG_ROUTE TAG_APP, handleStartTagTransportRTRouteAppPeer, NULL, NULL },
        { TAG_SERVER, TAG_LCN_D TAG_TRANSPORT TAG_ROUTE_TABLE TAG_ROUTE TAG_APP TAG_PEER, NULL, NULL, handleTransportRTRouteAppPeerServer },
        { TAG_WEIGHT, TAG_LCN_D TAG_TRANSPORT TAG_ROUTE_TABLE TAG_ROUTE TAG_APP TAG_PEER, NULL, NULL, handleTransportRTRouteAppPeerWeight },
        { TAG_IMPL, TAG_LCN_D, NULL, NULL, NULL },
        { TAG_TWINIT, TAG_LCN_D TAG_IMPL, NULL, NULL, handleImplTwinit },
        { TAG_INACTIVITY, TAG_LCN_D TAG_IMPL, NULL, NULL, handleImplInactivity },
        { TAG_ROLE, TAG_LCN_D TAG_IMPL, NULL, NULL, handleImplRole },
        { TAG_NUM_THREADS, TAG_LCN_D TAG_IMPL, NULL, NULL, handleImplNumOfThreads },
        { TAG_REOPEN_TIMER, TAG_LCN_D TAG_IMPL, NULL, NULL, handleImplReopenTimer },
        { TAG_POLLING_INTERVAL, TAG_LCN_D TAG_IMPL, NULL, NULL, handleImplPollingInterval },
        /*{ TAG_DUP_WATCH, TAG_LCN_D TAG_IMPL, NULL, NULL, handleImplDupWatch },*/
        { TAG_SMALL_PDU, TAG_LCN_D TAG_IMPL, NULL, NULL, handleImplSmallPdu },
        { TAG_BIG_PDU, TAG_LCN_D TAG_IMPL, NULL, NULL, handleImplBigPdu },
        { NULL, NULL, NULL, NULL } };














void appendDataError (userData *ud, char *errString)
{
    logMsg (LOG_ERR, "%s\n", errString);
    int curLen = ud->dataErrString ? (strlen (ud->dataErrString)) : 0;
    int incrementalLen = strlen (errString);
    ud->dataErrString = realloc (ud->dataErrString, (curLen + incrementalLen
        + 1));
    strcpy ((ud->dataErrString + curLen), errString);
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

    if (strlen (data) >= DC_MAX_HOSTNAME_LEN)
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
    if (strlen (data) >= DC_MAX_HOSTNAME_LEN)
    {
        sprintf (errString, "%s%d%s%s\n",
            "Value for nodename exceeds limit of ", DC_MAX_HOSTNAME_LEN,
            " chars; data is ", data);
        appendDataError (ud, errString);
        return;
    }
    strcpy ((char *) ud->output->nodeName, data);
}
void handleTransportNodeRealm (userData *ud, char *data)
{
    logFF();
    if (strlen (data) >= DC_MAX_HOSTNAME_LEN)
    {
        sprintf (errString, "%s%d%s%s\n",
            "Value for realmname exceeds limit of ", DC_MAX_HOSTNAME_LEN,
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
    if (strlen (data) >= DC_MAX_HOSTNAME_LEN)
    {
        sprintf (errString, "%s%d%s%s\n",
            "Value for peer hostname exceeds limit of ", DC_MAX_HOSTNAME_LEN,
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
    int curIPAddrPosition = (pc->nIpAddresses) - 1;

    if (strlen (data) >= DC_MAX_HOSTNAME_LEN)
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
    if (strlen (data) >= DC_MAX_HOSTNAME_LEN)
    {
        sprintf (errString, "%s%d%s%s\n",
            "Value for peer realmname exceeds limit of ", DC_MAX_HOSTNAME_LEN,
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

    if (strlen (data) >= DC_MAX_HOSTNAME_LEN)
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
    if (DC_MAX_IP_ADDRESSES_PER_PEER == ud->output->nAddresses)
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
    memset (pc, 0, sizeof(*pc));
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
    memset (rc, 0, sizeof(*rc));
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
    if (DC_MAX_SERVERS_PER_APP == rc->nServers)
    {
        sprintf (errString, "%s%d\n",
            "Number of peer for route exceeds limit of ",
            DC_MAX_SERVERS_PER_APP);
        appendDataError (ud, errString);
        return;
    }
    ++(rc->nServers);
}
