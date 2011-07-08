/*
 * todo
 *  Tests with IPv6 global address.
 *  Linux doesn't fill stream info on recvmsg
 *  Thread support, esp around store apis
 *
 */

#include "dtpsock_hdr.h"
#include "dtpsock_proto.h"

/*
 * (dtp_init) Initializes a socket (create, bind) as per the properties in sockConfig. All successfully
 * initialized sockets are maintained in an internal store along with the associated properties for
 * later use. The socket is removed from the store after a dtp_close call.
 *
 * (Parameter, int *sockFd) Pointer to the newly created socket. Set to negative value in case of errors.
 * (Parameter, dtpSockConfig *sockConfig) Pointer to a structure holding properties of the socket to be
 * created. Caller can reclaim the allocated memory once the call returns.
 *
 * (Return) dtpSuccess if successful completion, else dtpError
 */
int dtp_init (int *sockFd, const dtpSockConfig * const sockConfig)
{
    logFF ();

    /* Validate and deep copy */
    dtpSockConfig *copiedSockConfig = util_copySockConfig (sockConfig);
    if (NULL == copiedSockConfig)
    {
        logMsg (LOG_CRIT, "%s\n",
                "Failed to initialize dtp socket, invalid input config");
        return dtpError;
    }

    if (dtpSuccess != init_createSocket (sockFd, copiedSockConfig))
    {
        logMsg (LOG_CRIT, "%s\n",
                "Failed to initialize dtp socket, could not create it");
        util_freeDtpSockConfig (copiedSockConfig);
        return dtpError;
    }

    /* Store the newly created socket in an internal structure */
    const dtpSockInfo * const sockInfo = store_add (*sockFd, copiedSockConfig);
    if (NULL == sockInfo)
    {
        /* Couldn't store */
        logMsg (LOG_CRIT, "%s\n",
                "Failed to initialize socket, couldn't store it");
        close (*sockFd);
        *sockFd = -1;
        util_freeDtpSockConfig (copiedSockConfig);
        return dtpError;
    }

    if (dtpSuccess != dtp_bind (sockInfo))
    {
        logMsg (LOG_CRIT, "%s\n",
                "Failed to initialize socket, could not bind it");
        close (*sockFd);
        *sockFd = -1;
        util_freeDtpSockConfig (copiedSockConfig);
        return dtpError;
    }
    logMsg (LOG_INFO, "%s%d\n", "Initialized DTP socket ", *sockFd);

    if (g_defaultNonBlocking == copiedSockConfig->blocking)
    {
        if (dtpSuccess != init_setNonBlocking (*sockFd))
        {
            logMsg (LOG_CRIT, "%s\n",
                    "Failed to initialize socket, couldn't make it non-blocking");
            close (*sockFd);
            *sockFd = -1;
            util_freeDtpSockConfig (copiedSockConfig);
            return dtpError;
        }
    }

    return dtpSuccess;
}

/* Called during dtp_init. Not to be used directly */
int dtp_bind (const dtpSockInfo * const sockInfo)
{
    logFF ();

    if (NULL == sockInfo)
    {
        logMsg (LOG_CRIT, "%s\n",
                "Failed to bind socket, socket is not initialized");
        return dtpError;
    }

    /* If no addresses given, bind to the default */
    if (NULL == sockInfo->sockConfig->addrs || NULL
            == sockInfo->sockConfig->addrs[0])
    {
        return (init_defaultBind (sockInfo));
    }

    int packedCount;
    struct sockaddr_storage *packedAddrs = NULL;
    packedCount = util_packAddrsForBind (sockInfo, &packedAddrs);
    if (NULL == packedAddrs)
    {
        logMsg (LOG_CRIT, "%s\n", "Could not pack addresses for bind ");
        return dtpError;
    }

    int retValue;
    switch (sockInfo->sockConfig->protocol)
    {
    case IPPROTO_TCP:
        retValue = init_bind (sockInfo, packedCount, packedAddrs);
        break;
    case IPPROTO_SCTP:
        retValue = init_bind (sockInfo, packedCount, packedAddrs);
        break;
    default:
        /* Should never happen */
        logMsg (LOG_CRIT, "%s%d\n", "Unrecognized prototype in bind socket ",
                sockInfo->sockConfig->protocol);
        retValue = dtpError;
        break;
    }
    util_freePackAddrs (packedAddrs);
    return retValue;
}


/*
 * (dtp_connect) Connects previously initialized dtp socket to the input addresses. If the socket is of
 * type TCP, it loops through the addresses until one of them is successful. If the socket is of type SCTP,
 * it connects to all addresses possible.
 *
 * (Parameter, int sockFd) The dtp socket id. The socket must have been initialized using dtp_init.
 * (Parameter, int sharedPort) The server port.
 * (Parameter, dtpSockAddr **connectAddrs) Pointer to a structure holding addresses to be connected to.
 * Caller can reclaim the allocated memory after the call returns.
 *
 * (Return) dtpSuccess if successful completion, else dtpError
 */
int dtp_connect (const int sockFd, const int sharedPort, const dtpSockAddr ** const connectAddrs)
{
    logFF ();

    if (NULL == connectAddrs)
    {
        logMsg (LOG_CRIT, "%s\n", "Can't connect to null server address ");
        return dtpError;
    }
    const dtpSockInfo * const sockInfo = store_getSockInfo (sockFd);
    if (NULL == sockInfo)
    {
        return dtpError;
    }
    if (dtpCreated != sockInfo->sockData->sockState)
    {
        logMsg (LOG_CRIT, "%s%s%s\n", "Socket state is ",
                util_dtpSockStateToString (sockInfo->sockData->sockState),
                " can not connect");
        return dtpError;
    }
    sockInfo->sockData->sockState = dtpClientConnectInProgress;

    /* Pack the incoming IPv4/IPv6 addresses into sockaddr_storage.*/
    int packedCount;
    struct sockaddr_storage *packedAddrs = NULL;
    packedCount = util_packAddrsForConnect (sockInfo, sharedPort, connectAddrs,
            &packedAddrs);
    if (NULL == packedAddrs)
    {
        logMsg (LOG_CRIT, "%s\n", "Could not pack addresses for connect");
        return dtpError;
    }

    int retValue;
    switch (sockInfo->sockConfig->protocol)
    {
    case IPPROTO_TCP:
        retValue = init_connect (sockInfo, packedCount, packedAddrs);
        break;
    case IPPROTO_SCTP:
        init_setSctpStreams (sockInfo);
        retValue = init_connect (sockInfo, packedCount, packedAddrs);
        init_getSctpStreams (sockInfo);
        init_registerSctpEvents (sockInfo);
        break;
    default:
        /* Should never happen */
        logMsg (LOG_CRIT, "%s%d\n", "Unrecognized protocol in connect ",
                sockInfo->sockConfig->protocol);
        retValue = dtpError;
        break;
    }
    util_freePackAddrs (packedAddrs);
    if (dtpSuccess == retValue)
    {
        sockInfo->sockData->sockState = dtpClientConnected;
    }
    if (errno == EWOULDBLOCK)
    {
        logMsg (LOG_INFO, "%s\n", "Non-blocking connect");
    }
    return retValue;
}

/*
 * (dtp_listen) Starts listening on a previously initialized dtp socket. It uses the serverListenQLen
 * value set during initialization as the listen backlog size. Additionally, in SCTP case, it sets socket
 * options such as sinit_max_instreams, sinit_max_outstreams using the values set during initialization.
 *
 * (Parameter, int sockFd) The dtp socket id. The socket must have been initialized using dtp_init.
 *
 * (Return) dtpSuccess if successful completion, else dtpError
 */
int dtp_listen (const int sockFd)
{
    logFF ();

    const dtpSockInfo * const sockInfo = store_getSockInfo (sockFd);
    if (NULL == sockInfo)
    {
        return dtpError;
    }
    if (dtpCreated != sockInfo->sockData->sockState)
    {
        logMsg (LOG_CRIT, "%s%s%s", "Socket state is ",
                util_dtpSockStateToString (sockInfo->sockData->sockState),
                " can not listen");
        return dtpError;
    }

    int retValue;
    switch (sockInfo->sockConfig->protocol)
    {
    case IPPROTO_TCP:
        retValue = init_tcpListen (sockInfo);
        break;
    case IPPROTO_SCTP:
        retValue = init_sctpListen (sockInfo);
        break;
    default:
        logMsg (LOG_CRIT, "%s%d", "Unrecognized protocol in listen ",
                sockInfo->sockConfig->protocol);
        retValue = dtpError;
        break;
    }

    if (dtpSuccess == retValue)
    {
        sockInfo->sockData->sockState = dtpServerListen;
    }

    return retValue;
}

/*
 * (dtp_accept) Blocks on accept on a previously initialized dtp socket. If the socket is of type
 * SCTP, it retrieves the agreed values for sstat_instrms, sstat_oustrms and records it for future
 * use.
 *
 * (Parameter, int sockFd) The dtp socket id. The socket must have been initialized using dtp_init.
 * (Parameter, int *newSockFd) Pointer to the newly created socket after accept.
 *
 * (Return) dtpSuccess if successful completion, else dtpError
 */
int dtp_accept (int sockFd, int *newSockFd)
{
    logFF ();

    const dtpSockInfo * const sockInfo = store_getSockInfo (sockFd);
    if (NULL == sockInfo)
    {
        return dtpError;
    }
    if (dtpServerListen != sockInfo->sockData->sockState)
    {
        logMsg (LOG_CRIT, "%s%s%s\n", "Socket state is ",
                util_dtpSockStateToString (sockInfo->sockData->sockState),
                " can not accept new connections");
        return dtpError;
    }

    int retValue;
    switch (sockInfo->sockConfig->protocol)
    {
    case IPPROTO_TCP:
        retValue = init_tcpAccept (sockInfo, newSockFd);
        break;
    case IPPROTO_SCTP:
        retValue = init_sctpAccept (sockInfo, newSockFd);
        break;
    default:
        logMsg (LOG_CRIT, "%s%d\n", "Unrecognized protocol in accept ",
                sockInfo->sockConfig->protocol);
        retValue = dtpError;
        break;
    }
    if (errno == EWOULDBLOCK)
    {
        logMsg (LOG_INFO, "%s\n", "Non-blocking accept");
    }
    return retValue;
}

/*
 * (dtp_close) Closes the socket. The internal data structures associated with the socket are removed.
 *
 * (Parameter, int sockFd) The dtp socket id. The socket must have been initialized using dtp_init.
 *
 * (Return) void
 */
void dtp_close (const int sockFd)
{
    store_remove (sockFd);
    close (sockFd);
}

/*
 * (dtp_send) Send data on a previously initialized dtp socket.
 *
 * (Parameter, int sockFd) The dtp socket id. The socket must have been initialized using dtp_init.
 * (Parameter, uint8_t* payLoad) The data to be sent.
 * (Parameter, long size) Size of the data to be sent.
 *
 * (Return) size of data sent if successful completion, else -1
 */
int dtp_send (const int sockFd, const uint8_t * const payLoad, const long size)
{
    logFF ();

    const dtpSockInfo * const sockInfo = store_getSockInfo (sockFd);
    if (NULL == sockInfo)
    {
        return -1;
    }

    if (NULL == payLoad)
    {
        logMsg (LOG_WARNING, "%s\n", "Null paylogd, ignoring");
        return -1;
    }
    if (size > sockInfo->sockConfig->maxPduSize)
    {
        logMsg (LOG_ERR, "%s%d%s%d\n", "Paylod size ", size,
                " larger than max allowed size ",
                sockInfo->sockConfig->maxPduSize);
        return -1;
    }

    int retSize;
    int stream;
    switch (sockInfo->sockConfig->protocol)
    {
    case IPPROTO_TCP:
        retSize = transport_tcpSend (sockInfo, payLoad, size);
        break;
    case IPPROTO_SCTP:
        stream = util_getSctpStream (
                sockInfo->sockData->confirmedSctpOutStreams);
        retSize = transport_sctpSend (sockInfo, stream, payLoad, size);
        break;
    default:
        logMsg (LOG_CRIT, "%s%d\n", "Unrecognized prototype in send ",
                sockInfo->sockConfig->protocol);
        retSize = -1;
        break;
    }

    if (retSize != size)
    {
        logMsg (LOG_ERR, "%s%s\n", "Failed to send data, error is ", strerror (
                errno));
    }
    else
    {
        logMsg (LOG_INFO, "%s%d\n", "Sent data of size ", retSize);
    }
    return retSize;
}

/*
 * (dtp_recv) Receive data on a previously initialized dtp socket.
 *
 * (Parameter, int sockFd) The dtp socket id. The socket must have been initialized using dtp_init.
 * (Parameter, uint8_t** buf) Buffer to hold the received data. Memory is allocated as necessary.
 * (Parameter, long maxBytes) Maximum bytes expected during recv.
 *
 * (Return) size of data sent if successful completion, else -1
 */
int dtp_recv (const int sockFd, uint8_t *buf, const long maxBytes)
{
    logFF ();

    const dtpSockInfo * const sockInfo = store_getSockInfo (sockFd);
    if (NULL == sockInfo)
    {
        return -1;
    }

    if (maxBytes > sockInfo->sockConfig->maxPduSize)
    {
        logMsg (LOG_ERR, "%s%d%s%d\n", "Expected paylod size ", maxBytes,
                " larger than max allowed size ",
                sockInfo->sockConfig->maxPduSize);
        return -1;
    }

    int retSize;
    switch (sockInfo->sockConfig->protocol)
    {
    case IPPROTO_TCP:
        retSize = transport_tcpRecv (sockInfo, buf, maxBytes);
        break;
    case IPPROTO_SCTP:
        retSize = transport_sctpRecv (sockInfo, buf, maxBytes);
        break;
    default:
        logMsg (LOG_CRIT, "%s%d\n", "Unrecognized prototype in recv ",
                sockInfo->sockConfig->protocol);
        retSize = -1;
        break;
    }
    if (retSize < 0)
    {
        logMsg (LOG_ERR, "%s%s\n", "Failed to recv data, error is ", strerror (
                errno));
    }
    else
    {
        logMsg (LOG_INFO, "%s%d\n", "Received data of size ", retSize);
    }
    return retSize;
}
