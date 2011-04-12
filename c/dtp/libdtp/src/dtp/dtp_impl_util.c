#include "dtp_header.h"
#include "dtp_proto.h"

char *util_protocolToString (const int protocol)
{
    logFF ();

    char *name = "NULL";
    switch (protocol)
    {
    case IPPROTO_TCP:
        name = "TCP";
        break;
    case IPPROTO_SCTP:
        name = "SCTP";
        break;
    default:
        break;
    }
    return name;
}

char *util_afamilyToString (const int afamily)
{
    logFF ();

    char *name = "NULL";
    switch (afamily)
    {
    case AF_INET:
        name = "AF_INET";
        break;
    case AF_INET6:
        name = "AF_INET6";
        break;
    default:
        break;
    }
    return name;
}

char *util_dtpSockStateToString (const dtpSockState sockState)
{
    logFF ();

    char *name = "NULL";
    switch (sockState)
    {
    case dtpCreated:
        name = "DTP_CREATED";
        break;
    case dtpClientConnectInProgress:
        name = "DTP_CLIENTCONNECTINPROGRESS";
        break;
    case dtpClientConnected:
        name = "DTP_CLIENTCONNECTED";
        break;
    case dtpServerListen:
        name = "DTP_SERVERLISTEN";
        break;
    case dtpServerAccept:
        name = "DTP_SERVERACCEPT";
        break;
    case dtpAborted:
        name = "DTP_ABORTED";
        break;
    default:
        break;
    }
    return name;
}

struct addrinfo * util_getAddrInfo (const char * const address,
        const int afamily, const int aiprotocol, const int port,
        const int forConnect)
{
    logFF ();
    struct addrinfo hints, *hintresult;

    memset (&hints, 0, sizeof(hints));
    hints.ai_family = afamily;
    /* always TCP for the time being, SCTP support todo */
    /*hints.ai_protocol = aiprotocol;*/
    hints.ai_protocol = 6;
    hints.ai_socktype = SOCK_STREAM;
    switch (forConnect)
    {
    case 1:
        hints.ai_flags = 0;
        break;
    default:
        /* set for bind in all other cases */
        hints.ai_flags = AI_PASSIVE;
        break;
    }

    char portBuf[100];
    sprintf (portBuf, "%d", port);
    int retValue = getaddrinfo (address, portBuf, &hints, &hintresult);
    if (retValue != 0)
    {
        logMsg (LOG_CRIT, "%s%s\n", "Can not do getaddrinfo, error is ",
                gai_strerror (retValue));
        return NULL;
    }
    return hintresult;
}

const char *util_saToString (const struct sockaddr_in *sa)
{
    char buf[INET_ADDRSTRLEN];
    char *str = malloc (sizeof(*str) * (INET_ADDRSTRLEN + 500));

    inet_ntop (AF_INET, &(sa->sin_addr), buf, INET_ADDRSTRLEN);
    strcpy (str, "addr-family ");
    strcat (str, util_afamilyToString (AF_INET));
    strcat (str, " addr-string ");
    strcat (str, buf);
    /*strcat (str, " addr-length ");
     sprintf (buf, "%d", sa->sin_len);
     strcat (str, buf);no len support in linux */
    return str;
}

const char *util_sa6ToString (const struct sockaddr_in6 *sa6)
{
    char buf[INET6_ADDRSTRLEN];
    char *str = malloc (sizeof(*str) * (INET6_ADDRSTRLEN + 500));

    inet_ntop (AF_INET6, &(sa6->sin6_addr), buf, INET6_ADDRSTRLEN);
    strcpy (str, "addr-family ");
    strcat (str, util_afamilyToString (AF_INET6));
    strcat (str, " addr-string ");
    strcat (str, buf);
    /*strcat (str, " addr-length ");
     sprintf (buf, "%d", sa6->sin6_len);
     strcat (str, buf);no len support in linux */
    sprintf (buf, "%d", sa6->sin6_scope_id);
    strcat (str, " addr-scope ");
    strcat (str, buf);
    return str;
}

const char * util_ssToString (const struct sockaddr_storage * addr)
{
    logFF ();

    switch (addr->ss_family)
    {
    case AF_INET:
        return util_saToString ((struct sockaddr_in *) addr);
        break;
    case AF_INET6:
        return util_sa6ToString ((struct sockaddr_in6 *) addr);
        break;
    default:
        break;
    }
    return "invalid";
}

const char * util_aiToString (const struct addrinfo * addr)
{
    logFF ();

    switch (addr->ai_family)
    {
    case AF_INET:
        return util_saToString ((struct sockaddr_in *) (addr->ai_addr));
        break;
    case AF_INET6:
        return util_sa6ToString ((struct sockaddr_in6 *) (addr->ai_addr));
        break;
    default:
        break;
    }
    return "invalid";
}

int util_packAddrs (const dtpSockInfo * const sockInfo,
        const int sharedBindPort, const int forConnect,
        const dtpSockAddr ** const addrs,
        struct sockaddr_storage ** packedAddrs)
{
    logFF ();

    int counter = -1;
    int packedCount = 0;
    int addrPosition = 0;
    while (NULL != addrs[++counter])
    {
        /* If looped through more than max count, ignore rest */
        if (counter >= g_maxAddrs)
        {
            logMsg (LOG_WARNING, "%s%d%s\n",
                    "Reached maximum address count of ", g_maxAddrs,
                    " skipping remaining addresses");
            break;
        }

        const dtpSockAddr * const addr = addrs[counter];
        logMsg (LOG_DEBUG, "%s%d%s%s%s%s%s%d%s%d%s%d\n", "Loop no ", counter,
                ", packing addr-string ", addr->astring, " addr-family ",
                util_afamilyToString (addr->afamily), "for-protocol ",
                sockInfo->sockConfig->protocol, " connect port ", addr->port,
                " shared bind port", sharedBindPort);

        int port = (sharedBindPort < 0) ? addr->port : sharedBindPort;
        struct addrinfo * ai = util_getAddrInfo (addr->astring, addr->afamily,
                sockInfo->sockConfig->protocol, port, forConnect);
        if (NULL != ai)
        {
            logMsg (LOG_DEBUG, "%s%d%s \n", "Packing at position  ",
                    addrPosition, util_aiToString (ai));
            *packedAddrs
                    = realloc (*packedAddrs, addrPosition + ai->ai_addrlen);
            memcpy (((char *) *packedAddrs) + addrPosition, ai->ai_addr,
                    ai->ai_addrlen);
            ++packedCount;
            addrPosition += ai->ai_addrlen;
            freeaddrinfo (ai);
            displayMemory ((char*) *packedAddrs, addrPosition); /* todo, remove */
            logMemoryData ((char*) *packedAddrs, addrPosition);
        }
    }

    return packedCount;
}

int util_packAddrsForBind (const dtpSockInfo * const sockInfo,
        struct sockaddr_storage ** packedAddrs)
{
    return (util_packAddrs (sockInfo, sockInfo->sockConfig->sharedBindPort, 0,
            sockInfo->sockConfig->addrs, packedAddrs));
}

int util_packAddrsForConnect (const dtpSockInfo * const sockInfo,
        const dtpSockAddr ** const addrs,
        struct sockaddr_storage ** packedAddrs)
{
    return (util_packAddrs (sockInfo, -1, 1, addrs, packedAddrs));
}

int util_freePackAddrs (struct sockaddr_storage *packedAddrs)
{
    /* Though used as an array, it's a single chunk of memory allocated using realloc. Free in one shot */
    freeAndNull (packedAddrs);
}

void util_freeDtpSockConfig (dtpSockConfig *dsp)
{
    if (NULL == dsp)
    {
        return;
    }
    if (NULL == dsp->addrs)
    {
        freeAndNull (dsp);
        return;
    }
    int counter = -1;
    while (NULL != dsp->addrs[++counter])
    {
        if (NULL != dsp->addrs[counter]->astring)
        {
            freeAndNull (dsp->addrs[counter]->astring);
        }
    }
    freeAndNull (dsp->addrs);
    freeAndNull (dsp);
}

void util_freeDtpSockData (dtpSockData *dsd)
{
    if (NULL == dsd)
    {
        return;
    }
    freeAndNull (dsd);
}

void util_freeDtpSockInfo (dtpSockInfo *dsi)
{
    if (NULL == dsi)
    {
        return;
    }
    util_freeDtpSockConfig (dsi->sockConfig);
    util_freeDtpSockData (dsi->sockData);
    freeAndNull (dsi);
}

dtpSockConfig * util_copySockConfig (const dtpSockConfig * const inSockConfig)
{
    dtpSockConfig *outSockConfig = malloc (sizeof(*outSockConfig));

    if (dtpSuccess != val_checkAfamily (inSockConfig->afamily))
    {
        util_freeDtpSockConfig (outSockConfig);
        return NULL;
    }
    outSockConfig->afamily = inSockConfig->afamily;

    if (dtpSuccess != val_checkInt (inSockConfig->ipv6Only, "IPv6Only", 0, 1))
    {
        outSockConfig->ipv6Only = g_defaultIPv6Only;
    }
    else
    {
        outSockConfig->ipv6Only = inSockConfig->ipv6Only;
    }

    if (dtpSuccess != val_checkProtocol (inSockConfig->protocol))
    {
        util_freeDtpSockConfig (outSockConfig);
        return NULL;
    }
    outSockConfig->protocol = inSockConfig->protocol;

    if (dtpSuccess != val_checkInt (inSockConfig->blocking, "Blocking", 0, 1))
    {
        outSockConfig->blocking = g_defaultNonBlocking;
    }
    else
    {
        outSockConfig->blocking = inSockConfig->blocking;
    }

    if (dtpSuccess != val_checkInt (inSockConfig->maxPduSize, "PDU Size",
            g_minPduSize, g_maxPduSize))
    {
        outSockConfig->maxPduSize = g_defaultPduSize;
    }
    else
    {
        outSockConfig->maxPduSize = inSockConfig->maxPduSize;
    }

    if (dtpSuccess != val_checkInt (inSockConfig->serverListenQLen, "Q Len",
            g_minServerListenQLen, g_maxServerListenQLen))
    {
        outSockConfig->serverListenQLen = g_defaultServerListenQLen;
    }
    else
    {
        outSockConfig->serverListenQLen = inSockConfig->serverListenQLen;
    }

    if (dtpSuccess != val_checkInt (inSockConfig->reqSctpInStreams,
            "In Stream", g_minSctpInStreams, g_maxSctpInStreams))
    {
        outSockConfig->reqSctpInStreams = g_defaultSctpInStreams;
    }
    else
    {
        outSockConfig->reqSctpInStreams = inSockConfig->reqSctpInStreams;
    }

    if (dtpSuccess != val_checkInt (inSockConfig->reqSctpOutStreams,
            "Out Stream", g_minSctpOutStreams, g_maxSctpOutStreams))
    {
        outSockConfig->reqSctpOutStreams = g_defaultSctpOutStreams;
    }
    else
    {
        outSockConfig->reqSctpOutStreams = inSockConfig->reqSctpOutStreams;
    }

    if (dtpSuccess != val_checkInt (inSockConfig->sharedBindPort, "Bind Port",
            g_minPort, g_maxPort))
    {
        util_freeDtpSockConfig (outSockConfig);
        return NULL;
    }
    outSockConfig->sharedBindPort = inSockConfig->sharedBindPort;

    if (NULL != inSockConfig->addrs)
    {
        logMsg (LOG_DEBUG, "%s\n", "Copying addresses");

        outSockConfig->addrs = malloc (sizeof(*(outSockConfig->addrs))
                * (g_maxAddrs + 1));
        memset (outSockConfig->addrs, 0, (sizeof(*(outSockConfig->addrs))
                * (g_maxAddrs + 1)));
        int counter = -1;
        while (NULL != inSockConfig->addrs[++counter])
        {
            logMsg (LOG_DEBUG, "%s%d%s%s\n", "Address ", counter, " string",
                    inSockConfig->addrs[counter]->astring);

            outSockConfig->addrs[counter] = malloc (
                    sizeof(**(outSockConfig->addrs)));
            if (dtpSuccess != val_checkAfamily (
                    inSockConfig->addrs[counter]->afamily))
            {
                util_freeDtpSockConfig (outSockConfig);
                return NULL;
            }
            outSockConfig->addrs[counter]->afamily
                    = inSockConfig->addrs[counter]->afamily;

            if (dtpSuccess != val_checkInt (inSockConfig->addrs[counter]->port,
                    "Connect Port", g_minPort, g_maxPort))
            {
                util_freeDtpSockConfig (outSockConfig);
                return NULL;
            }
            outSockConfig->addrs[counter]->port
                    = inSockConfig->addrs[counter]->port;

            if (NULL != inSockConfig->addrs[counter]->astring)
            {
                outSockConfig->addrs[counter]->astring = malloc (sizeof(char)
                        * (strlen (inSockConfig->addrs[counter]->astring) + 1));
                strcpy (outSockConfig->addrs[counter]->astring,
                        inSockConfig->addrs[counter]->astring);
            }
        }
    }
    return outSockConfig;
}

int util_getSctpStream (int maxLimit)
{
    return getRandomNo (maxLimit);
}
