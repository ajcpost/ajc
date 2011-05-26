#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"

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

tagMetadata * getTagMetadata (userData *ud, char *tag)
{
    logFF ();

    if (NULL != ud->tagErrString)
    {
        logMsg (LOG_WARNING, "%s\n",
            "    Parser in error state, skipping further handling.");
        return NULL;
    }

    int counter = -1;
    char fromMeta[200];
    char fromUd[200];
    strcpy (fromUd, ud->curPath ? ud->curPath : "");
    strcat (fromUd, tag ? tag : "");
    while (xmltags[++counter].tag != NULL)
    {
        tagMetadata *tm = &xmltags[counter];
        strcpy (fromMeta, tm->parentPath ? tm->parentPath : "");
        strcat (fromMeta, tm->tag);
        /*logMsg (LOG_DEBUG, "%s%s%s%s\n", "    comparing from meta ", fromMeta,
            " with from ud ", fromUd);*/
        if (0 == strcmp (fromMeta, fromUd))
        {
            return tm;
        }
    }
    ud->tagErrString = malloc (sizeof(char) * 500);
    sprintf (ud->tagErrString, "%s%s%s%s\n", "Can not find tag ", tag,
        " at path ", ((ud->curPath) ? ud->curPath : "null"));
    logMsg (LOG_ERR, "%s\n", ud->tagErrString);
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
    saxh.startElement = startTagCallback;
    saxh.endElement = endTagCallback;
    saxh.characters = dataCallback;

    xmlSAXUserParseFile (&saxh, &ud, xmlFilePath);
    if (NULL != ud.tagErrString)
    {
        logMsg (LOG_ERR, "%s%s\n", "Error in tag ", ud.tagErrString);
        return -1;
    }
    if (NULL != ud.dataErrString)
    {
        logMsg (LOG_ERR, "%s%s\n", "Errors while processing tag data ",
            ud.dataErrString);
        return -1;
    }

    printOutput (ud.output);
    return 0;
}

void printServerList (ServerListEntry_t *sle)
{
    if (NULL == sle)
    {
        logMsg (LOG_INFO, "%s\n", "        serverList is Null");
        return;
    }
    logMsg (LOG_INFO, "%s%s\n", "        serverName: ",
        ((sle->serverName) ? sle->serverName : "null"));
    logMsg (LOG_INFO, "%s%d\n", "        weight: ", sle->weight);
    logMsg (LOG_INFO, "%s%d\n", "        cStatus: ", sle->cStatus);

}
void printRealmConfig (RealmConfig_t *rc)
{
    if (NULL == rc)
    {
        logMsg (LOG_INFO, "%s\n", "    realmConfig is Null");
        return;
    }
    logMsg (LOG_INFO, "%s%s\n", "    realmName: ",
        ((rc->realmName) ? rc->realmName : "null"));
    logMsg (LOG_INFO, "%s%d\n", "    appIdentifier: ", rc->appIdentifier);
    logMsg (LOG_INFO, "%s%d\n", "    action: ", rc->action);
    logMsg (LOG_INFO, "%s%d\n", "    nServers: ", rc->nServers);
    int i;
    for (i = 0; i < rc->nServers; i++)
    {
        printServerList (&rc->serverList[i]);
    }

    logMsg (LOG_INFO, "%s%d\n", "    isDynamic: ", rc->isDynamic);
    logMsg (LOG_INFO, "%s%d\n", "    expirationTime: ", rc->expirationTime);
    logMsg (LOG_INFO, "%s%d\n", "    isConnected: ", rc->isConnected);
    logMsg (LOG_INFO, "%s%d\n", "    activePeerIndex1: ", rc->activePeerIndex1);
    logMsg (LOG_INFO, "%s%d\n", "    activePeerIndex2: ", rc->activePeerIndex2);
}

void printPeerConfig (PeerConfig_t *pc)
{
    if (NULL == pc)
    {
        logMsg (LOG_INFO, "%s\n", "    peerConfig is Null");
        return;
    }
    logMsg (LOG_INFO, "%s%d\n", "    peerTableIndex: ", pc->peerTableIndex);
    logMsg (LOG_INFO, "%s%d\n", "    activePeerIndex: ", pc->activePeerIndex);
    logMsg (LOG_INFO, "%s%d\n", "    isDynamic: ", pc->isDynamic);
    logMsg (LOG_INFO, "%s%d\n", "    expirationTime: ", pc->expirationTime);
    logMsg (LOG_INFO, "%s%d\n", "    security: ", pc->security);
    logMsg (LOG_INFO, "%s%d\n", "    proto: ", pc->proto);
    logMsg (LOG_INFO, "%s%d\n", "    tcp_port: ", pc->tcp_port);
    logMsg (LOG_INFO, "%s%d\n", "    sctp_port: ", pc->sctp_port);
    logMsg (LOG_INFO, "%s%d\n", "    nIpAddresses: ", pc->nIpAddresses);
    int i;
    for (i = 0; i < pc->nIpAddresses; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%s\n", "    ipAddress", i, ": ",
            pc->ipAddresses[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "    lastFailedConnectTime: ",
        pc->lastFailedConnectTime);
}

void printVSA (VendorSpecificAppId_t *vsa)
{
    logMsg (LOG_INFO, "%s%d\n", "    nVendorIds: ", vsa->nVendorIds);
    int i = 0;
    for (i = 0; i < vsa->nVendorIds; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%d\n", "    vendorIds", i, ": ",
            vsa->vendorIds[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "    isAuth: ", vsa->isAuth);
    logMsg (LOG_INFO, "%s%d\n", "    appId: ", vsa->appId);

}
void printOutput (DiameterConfig_t *output)
{
    logMsg (LOG_INFO, "%s\n", "------- Output -------");
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
        logMsg (LOG_INFO, "%s%d%s%d\n", "supportedVendorId", i, ": ",
            output->supportedVendorId[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "nAuthAppIds: ", output->nAuthAppIds);
    for (i = 0; i < output->nAuthAppIds; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%d\n", "supportedAuthAppId", i, ": ",
            output->supportedAuthAppId[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "nAcctAppIds: ", output->nAcctAppIds);
    for (i = 0; i < output->nAcctAppIds; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%d\n", "supportedAcctAppId", i, ": ",
            output->supportedAcctAppId[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "nVendorSpecificAppIds: ",
        output->nVendorSpecificAppIds);
    for (i = 0; i < output->nVendorSpecificAppIds; i++)
    {
        printVSA (&output->supportedVendorSpecificAppId[i]);
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
    logMsg (LOG_INFO, "%s\n", "-------  -------");

}
