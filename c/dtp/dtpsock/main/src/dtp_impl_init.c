#include "dtpsock_hdr.h"
#include "dtpsock_proto.h"

int init_createSocket (int *sockFd, const dtpSockConfig * const sockConfig)
{
    logFF ();

    if (NULL == sockConfig)
    {
        logMsg (LOG_CRIT, "%s\n",
                "Failed to create socket, null input properties");
        return dtpError;
    }

    const int afamily = sockConfig->afamily;
    const int protocol = sockConfig->protocol;
    logMsg (LOG_DEBUG, "%s%s%s%s\n", "Creating socket for address family ",
            util_afamilyToString (afamily), " and protocol type ",
            util_protocolToString (protocol));

    if ((*sockFd = socket (afamily, SOCK_STREAM, protocol)) < 0)
    {
        logMsg (LOG_CRIT, "%s%s\n", "Failed to create socket, error is ",
                strerror (errno));
        return dtpError;
    }
    int on = 1;
    if (setsockopt (*sockFd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)
            < 0))
    {
        logMsg (LOG_WARNING, "%s%s\n",
                "Failed to set socket option SO_REUSEADDR, error is", strerror (errno));
    }

    /* If IPv4, all done. */
    if (AF_INET == sockConfig->afamily)
    {
        return dtpSuccess;
    }
    /* If IPv6, should it accept IPv4 clients? */
    int ipv6On = sockConfig->ipv6Only;
    if (setsockopt (*sockFd, IPPROTO_IPV6, IPV6_V6ONLY, &ipv6On, sizeof(ipv6On)
            < 0))
    {
        logMsg (LOG_WARNING, "%s%d%s%s\n",
                "Failed to set socket option IPV6_V6ONLY to ", ipv6On,
                ", error is ", strerror (errno));
    }
    else
    {
        logMsg (LOG_DEBUG, "%s%d\n", "Set socket option IPV6_V6ONLY to ",
                ipv6On);
    }

    logMsg (LOG_INFO, "%s%d\n", "Created socket ", *sockFd);
    return dtpSuccess;
}

int init_setNonBlocking (const int sockFd)
{
    logFF ();
    int flags;
    flags = fcntl (sockFd, F_GETFL, 0);
    if (-1 == flags)
    {
        logMsg (LOG_ERR, "%s%s\n", "Couldn't retrieve socket flags, error is ",
                strerror (errno));
        return dtpError;
    }
    if (-1 == fcntl (sockFd, F_SETFL, flags | O_NONBLOCK))
    {
        logMsg (LOG_ERR, "%s%s\n",
                "Couldn't set socket to nonblocking, error is ", strerror (
                        errno));
        return dtpError;
    }
    return dtpSuccess;
}

int init_defaultBind (const dtpSockInfo * const sockInfo)
{
    logFF ();

    const int port = sockInfo->sockConfig->sharedPort;
    const int aifamily = sockInfo->sockConfig->afamily;

    struct addrinfo * defaultAddr = util_getAddrInfo (NULL, aifamily,
            sockInfo->sockConfig->protocol, port, 0);
    if (NULL == defaultAddr)
    {
        return dtpError;
    }
    logMsg (LOG_DEBUG, "%s \n", util_aiToString (defaultAddr));

    struct addrinfo *p;
    for (p = defaultAddr; p != NULL; p = p->ai_next)
    {
        if (bind (sockInfo->sockFd, defaultAddr->ai_addr,
                defaultAddr->ai_addrlen) < 0)
        {
            logMsg (LOG_DEBUG, "%s%s%s\n", "Default bind error ",
                    strerror (errno), " trying next address, if any");
        }
    }
    freeaddrinfo (defaultAddr);
    if (NULL == p)
    {
        logMsg (LOG_INFO, "%s\n", "Default bind failed");
        return dtpError;
    }
    logMsg (LOG_INFO, "%s\n", "Default bind successful");
    return dtpSuccess;
}

int init_bind (const dtpSockInfo * const sockInfo, const int packedCount,
        const struct sockaddr_storage * const packedAddrs)
{
    logFF ();

    logMsg (LOG_DEBUG, "%s%d\n", "Binding socket ", sockInfo->sockFd);
    int bound = 0;
    int counter = 0;
    int addrPosition = 0;
    int size = 0;
    const struct sockaddr_storage *p = packedAddrs;
    for (counter = 0; counter < packedCount; counter++)
    {
        p = ((char *) packedAddrs + addrPosition);
        logMsg (LOG_DEBUG, "%s%d%s%p%s \n", "Loop no ", counter, " at memory ",
                p, util_ssToString (p));

        switch (p->ss_family)
        {
        case AF_INET:
            addrPosition += sizeof(struct sockaddr_in);
            size = sizeof(struct sockaddr_in);
            break;
        case AF_INET6:
            addrPosition += sizeof(struct sockaddr_in6);
            size = sizeof(struct sockaddr_in6);
            break;
        default:
            /* Should never happen. Can't increment addrPosition, loop will eventually terminate. */
            break;
        }

        if (bind (sockInfo->sockFd, (struct sockaddr *) p, size) == 0)
        {
            bound = 1;
            if (IPPROTO_TCP == sockInfo->sockConfig->protocol)
            {
                break;
            }
        }
        else
        {
            logMsg (LOG_DEBUG, "%s%s%s\n", "Bind error is ", strerror (errno),
                    " trying next address, if any");
        }
    }
    if (0 == bound)
    {
        logMsg (LOG_INFO, "%s\n", "Bind failed");
        return dtpError;
    }
    logMsg (LOG_INFO, "%s\n", "Bind successful");
    return dtpSuccess;
}

int init_connect (const dtpSockInfo * const sockInfo, const int packedCount,
        const struct sockaddr_storage * const packedAddrs)
{
    logFF ();

    logMsg (LOG_DEBUG, "%s%d\n", "Connecting socket ", sockInfo->sockFd);
    int connected = 0;
    int counter = 0;
    int addrPosition = 0;
    int size = 0;
    const struct sockaddr_storage *p = packedAddrs;
    for (counter = 0; counter < packedCount; counter++)
    {
        p = ((char *) packedAddrs + addrPosition);
        logMsg (LOG_DEBUG, "%s%d%s%p%s \n", "Loop no ", counter, " at memory ",
                p, util_ssToString (p));

        switch (p->ss_family)
        {
        case AF_INET:
            size = sizeof(struct sockaddr_in);
            addrPosition += sizeof(struct sockaddr_in);
            break;
        case AF_INET6:
            size = sizeof(struct sockaddr_in6);
            addrPosition += sizeof(struct sockaddr_in6);
            break;
        default:
            /* Should never happen. Can't increment addrPosition, loop will eventually terminate. */
            break;
        }

        if (connect (sockInfo->sockFd, (struct sockaddr *) p, size) == 0)
        {
            connected = 1;
            if (IPPROTO_TCP == sockInfo->sockConfig->protocol)
            {
                break;
            }
        }
        else
        {
            logMsg (LOG_DEBUG, "%s%s%s\n", "Connect error is ",
                    strerror (errno), " trying next address, if any");
        }

    }

    if (0 == connected)
    {
        logMsg (LOG_INFO, "%s\n", "Connect failed");
        return dtpError;
    }
    logMsg (LOG_INFO, "%s\n", "Connect successful");
    return dtpSuccess;
}

int init_tcpListen (const dtpSockInfo * const sockInfo)
{
    logFF ();

    if (listen (sockInfo->sockFd, sockInfo->sockConfig->serverListenQLen) < 0)
    {
        logMsg (LOG_CRIT, "%s%d%s%s\n", "TCP listen failed for ",
                sockInfo->sockFd, ", error is", strerror (errno));
        return dtpError;
    }

    logMsg (LOG_DEBUG, "%s%d%s%d\n", "TCP listen successful on socket ",
            sockInfo->sockFd, " with Q len of ",
            sockInfo->sockConfig->serverListenQLen);

    return dtpSuccess;
}

int init_sctpListen (const dtpSockInfo * const sockInfo)
{
    logFF ();

    init_setSctpStreams (sockInfo);
    if (listen (sockInfo->sockFd, sockInfo->sockConfig->serverListenQLen) < 0)
    {
        logMsg (LOG_CRIT, "%s%d%s%s\n", "SCTP listen failed for ",
                sockInfo->sockFd, ", error is", strerror (errno));
        return dtpError;
    }

    logMsg (LOG_DEBUG, "%s%d%s%d\n", "SCTP listen successful on socket ",
            sockInfo->sockFd, " with Q len of ",
            sockInfo->sockConfig->serverListenQLen);

    return dtpSuccess;
}

const dtpSockInfo * init_addAcceptSockToStore (const int newSockFd,
        const dtpSockInfo * const sockInfo)
{
    logFF ();

    dtpSockConfig *newSockConfig = util_copySockConfig (sockInfo->sockConfig);
    if (NULL == newSockConfig)
    {
        /* Should actually never happen */
        logMsg (LOG_CRIT, "%s\n", "Failed to initialize accept dtp socket");
        return NULL;
    }
    const dtpSockInfo *newSockInfo = store_add (newSockFd, newSockConfig);
    if (NULL == newSockInfo)
    {
        /* Couldn't store */
        logMsg (LOG_CRIT, "%s\n",
                "Failed to initialize accept dtp socket, reached maximum no. of open sockets");
        util_freeDtpSockConfig (newSockConfig);
        return NULL;
    }
    newSockInfo->sockData->sockState = dtpServerAccept;
    return newSockInfo;
}

char * init_getPeerAddress (const dtpSockInfo * const sockInfo)
{
    logFF ();

    struct sockaddr_in ca;
    struct sockaddr_in6 ca6;
    socklen_t caLen;
    char *str = malloc (sizeof(*str) * (INET_ADDRSTRLEN + INET6_ADDRSTRLEN));

    switch (sockInfo->sockConfig->afamily)
    {
    case AF_INET:
        caLen = sizeof(ca);
        getpeername (sockInfo->sockFd, (struct sockaddr *) &ca, &caLen);
        inet_ntop (AF_INET, &ca.sin_addr, str, INET_ADDRSTRLEN);
        break;
    case AF_INET6:
        caLen = sizeof(ca6);
        getpeername (sockInfo->sockFd, (struct sockaddr *) &ca6, &caLen);
        inet_ntop (AF_INET6, &ca6.sin6_addr, str, INET6_ADDRSTRLEN);
        break;
    default:
        /* Should never happen */
        logMsg (LOG_CRIT, "%s%d\n",
                "Unrecognized afamily in init_getPeerAddress ",
                sockInfo->sockConfig->afamily);
        strcpy (str, "invalid");
        break;
    }
    return str;
}

int init_tcpAccept (const dtpSockInfo * const sockInfo, int *newSockFd)
{
    logFF ();

    if ((*newSockFd = accept (sockInfo->sockFd, NULL, NULL)) < 0)
    {
        logMsg (LOG_ERR, "%s%s\n", "Accept failed, error is ", strerror (errno));
        return dtpError;
    }
    const dtpSockInfo * const newSockInfo = init_addAcceptSockToStore (
            *newSockFd, sockInfo);
    if (NULL == newSockInfo)
    {
        close (*newSockFd);
        *newSockFd = -1;
        return dtpError;
    }
    logMsg (LOG_INFO, "%s%s%s%d\n", "Connect request by IP ",
            init_getPeerAddress (newSockInfo), " accepted on socket ",
            newSockInfo->sockFd);
    return dtpSuccess;
}

int init_sctpAccept (const dtpSockInfo * const sockInfo, int *newSockFd)
{
    logFF ();

    if ((*newSockFd = accept (sockInfo->sockFd, NULL, NULL)) < 0)
    {
        logMsg (LOG_ERR, "%s%s\n", "Accept failed, error is ", strerror (errno));
        return dtpError;
    }
    const dtpSockInfo * const newSockInfo = init_addAcceptSockToStore (
            *newSockFd, sockInfo);
    if (NULL == newSockInfo)
    {
        close (*newSockFd);
        *newSockFd = -1;
        return dtpError;
    }
    logMsg (LOG_INFO, "%s%s%s%d\n", "Connect request by IP ",
            init_getPeerAddress (newSockInfo), " accepted on socket ",
            newSockInfo->sockFd);

    init_getSctpStreams (newSockInfo);
    init_registerSctpEvents (newSockInfo);
    return dtpSuccess;
}

void init_setSctpStreams (const dtpSockInfo * const sockInfo)
{
    logFF ();
    struct sctp_initmsg si;
    memset (&si, 0, sizeof(si));
    si.sinit_max_instreams = sockInfo->sockConfig->reqSctpInStreams;
    si.sinit_num_ostreams = sockInfo->sockConfig->reqSctpOutStreams;
    if (setsockopt (sockInfo->sockFd, IPPROTO_SCTP, SCTP_INITMSG, &si,
            sizeof(si)) < 0)
    {
        logMsg (LOG_WARNING, "%s%s\n",
                "Failed to set number of streams, error is", strerror (errno));
    }
}

void init_getSctpStreams (const dtpSockInfo *sockInfo)
{
    logFF ();
    struct sctp_status ss;
    socklen_t ssLen = sizeof(ss);
    memset (&ss, 0, sizeof(ss));
    if (getsockopt (sockInfo->sockFd, IPPROTO_SCTP, SCTP_STATUS, &ss, &ssLen)
            < 0)
    {
        logMsg (LOG_WARNING, "%s%s\n",
                "Failed to retrieve number of streams, error is", strerror (
                        errno));
        /* Use single stream */
        sockInfo->sockData->confirmedSctpInStreams = 1;
        sockInfo->sockData->confirmedSctpOutStreams = 1;
    }
    else
    {
        sockInfo->sockData->confirmedSctpInStreams = ss.sstat_instrms;
        sockInfo->sockData->confirmedSctpOutStreams = ss.sstat_outstrms;
    }
    logMsg (LOG_INFO, "%s%d%s%d\n", "SCTP instreams ",
            sockInfo->sockData->confirmedSctpInStreams, " outstreams ",
            sockInfo->sockData->confirmedSctpOutStreams);
}

void init_registerSctpEvents (const dtpSockInfo * const sockInfo)
{
    logFF ();
    struct sctp_event_subscribe ses;
    memset (&ses, 0, sizeof(ses));
    ses.sctp_data_io_event = 1;
    ses.sctp_shutdown_event = 1;
    if (setsockopt (sockInfo->sockFd, IPPROTO_SCTP, SCTP_EVENTS, &ses,
            sizeof(ses)) < 0)
    {
        logMsg (LOG_WARNING, "%s%d%s%s\n",
                "Failed to register for events for socket ", sockInfo->sockFd,
                ", error is ", strerror (errno));
    }
    logMsg (LOG_INFO, "%s\n", "Registered for sctp events");

}

