#include "dtpxml_hdr.h"
#include "dtpxml_proto.h"

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

#define MAX_FULLTAG_LEN 300

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

tagMetadata * findTagMetadata (userData *ud, char *tag)
{
    logFF ();

    if (NULL != ud->tagErrString)
    {
        logMsg (LOG_WARNING, "%s\n",
            "    Parser in error state, skipping further handling.");
        return NULL;
    }

    int counter = -1;
    char fromMeta[MAX_FULLTAG_LEN];
    char fromUd[MAX_FULLTAG_LEN];
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

void startTagCallback (void *udata, const xmlChar *name, const xmlChar **attrs)
{
    logFF ();

    char *tag = (char *) name;
    userData *ud = (userData *) udata;
    logMsg (LOG_INFO, "%s%s%s%s\n", "Start input tag ", tag, " at path ",
        ((ud->curPath) ? ud->curPath : "null"));

    /* Find the matching tag metadata */
    ud->curTm = findTagMetadata (ud, tag);
    if (NULL == ud->curTm)
    {
        return;
    }

    /* Adjust the path to reflect the current hierarchy */
    int curLen = ((ud->curPath) ? strlen (ud->curPath) : 0);
    int incrementalLen = strlen (tag);
    ud->curPath = realloc (ud->curPath, curLen + incrementalLen + 1);
    strcpy (ud->curPath + curLen, tag);
    logMsg (LOG_DEBUG, "%s%s\n", "    Adjusted path ",
        ((ud->curPath) ? ud->curPath : "null"));

    /* Call the handler */
    if (NULL != ud->curTm->handleStartTagFunc)
    {
        ud->curTm->handleStartTagFunc (ud);
    }
}

void endTagCallback (void *udata, const xmlChar *name)
{
    logFF ();

    char *tag = (char *) name;
    userData *ud = (userData *) udata;
    logMsg (LOG_INFO, "%s%s%s%s\n", "End input tag ", tag, " at path ",
        ((ud->curPath) ? ud->curPath : "null"));

    /* Find the matching tag metadata, don't pass tag since it's already part of curPath */
    ud->curTm = findTagMetadata (ud, NULL);
    if (NULL == ud->curTm)
    {
        return;
    }

    /*
     * Adjust the path to reflect the current hierarchy.
     * Don't realloc but rather null terminate at appropriate position. The memory will eventually be
     * freed at the end of XML parsing.
     * */
    int curLen = ((ud->curPath) ? strlen (ud->curPath) : 0);
    int incrementalLen = strlen (tag);
    if (curLen >= incrementalLen)
    {
        *(ud->curPath + curLen - incrementalLen) = '\0';
    }
    logMsg (LOG_DEBUG, "%s%s\n", "    Adjusted path ",
        ((ud->curPath) ? ud->curPath : "null"));

    /* Call the handler */
    if (NULL != ud->curTm->handleEndTagFunc)
    {
        ud->curTm->handleEndTagFunc (ud);
    }
}

void dataCallback (void *udata, const xmlChar *ch, int len)
{
    logFF ();

    userData *ud = (userData *) udata;
    logMsg (LOG_DEBUG, "%s%s\n", "    Data callback at path ",
        ((ud->curPath) ? ud->curPath : "null"));

    if (NULL != ud->curTm && NULL != ud->curTm->handleDataFunc)
    {
        char *data = copyData (ch, len);
        logMsg (LOG_DEBUG, "%s%s\n", "    Data is ", (data ? data : "null"));
        if (NULL != data)
        {
            ud->curTm->handleDataFunc (ud, data);
            myfree (data);
        }
    }
}

char *copyData (const xmlChar *ch, const int len)
{
    logFF();
    int allSpace = 1;

    char *data = malloc (sizeof(char) * (len + 1));
    char *p = data;
    int i = 0;
    for (i = 0; i < len; i++)
    {
        if (*ch != ' ' && *ch != '\n')
        {
            allSpace = 0;
        }
        *p++ = *ch++;
    }
    *p = '\0';

    // ignore new lines or all whitespaces
    if (allSpace)
    {
        logMsg (LOG_WARNING, "%s\n",
            "    Data has only whitespace or newline, skipping");
        myfree (data);
        return NULL;
    }
    return data;
}

void logDetails (userData *ud)
{
    logMsg (LOG_INFO, "%s%s\n", "Error in tag ",
        (ud->tagErrString ? ud->tagErrString : "none"));
    logMsg (LOG_INFO, "%s%s\n", "Errors in data \n",
        (ud->dataErrString ? ud->dataErrString : "none"));

    if (NULL == ud->tagErrString && NULL == ud->dataErrString)
    {
        printOutput (ud->output);
    }
}

int parseXmlConfig (const char * const xmlFilePath, DiameterConfig_t *output)
{
    logFF();

    if (NULL == xmlFilePath || NULL == output)
    {
        logMsg (LOG_CRIT, "%s%s\n",
            "Null input xml config or output data holder");
        return -1;
    }

    userData ud;
    memset (&ud, 0, sizeof(ud));
    ud.output = output;
    memset (ud.output, 0, sizeof(ud.output));

    // Set approriate handlers
    xmlSAXHandler saxh;
    memset (&saxh, 0, sizeof(saxh));
    saxh.startElement = startTagCallback;
    saxh.endElement = endTagCallback;
    saxh.characters = dataCallback;

    xmlSAXUserParseFile (&saxh, &ud, xmlFilePath);
    logDetails (&ud);

    /* Free up memory */
    myfree (ud.curPath);
    myfree (ud.dataErrString);
    myfree (ud.tagErrString);

    if (NULL == ud.tagErrString && NULL == ud.dataErrString)
    {
        return 0;
    }
    return -1;
}
