#include "dtpsock_hdr.h"
#include "dtpsock_proto.h"

int transport_tcpSend (const dtpSockInfo * const sockInfo,
        const uint8_t * const sendPdu, const long transferSize)
{
    logMsg (LOG_DEBUG, "%s%d%s%d\n", "Sending TCP data over socket ",
            sockInfo->sockFd, ", size is ", transferSize);

    int sentSize = send (sockInfo->sockFd, sendPdu, transferSize, 0);
    return sentSize;
}

int transport_tcpRecv (const dtpSockInfo * const sockInfo, uint8_t **recvPdu,
        const long transferSize)
{
    struct msghdr mh;

    logMsg (LOG_DEBUG, "%s%d%s%d\n", "Receiving TCP data over socket ",
            sockInfo->sockFd, ", expected size is ", transferSize);

    *recvPdu = NULL;
    uint8_t *chunkPdu = malloc (sizeof(*chunkPdu) * (transferSize));
    int recvSize = recv (sockInfo->sockFd, chunkPdu, transferSize, 0);
    if (recvSize > 0)
    {
        *recvPdu = realloc (chunkPdu, recvSize);
    }
    return recvSize;
}

/* Add event support in send/receive */
/*todo nonblocking sctp_send */
int transport_sctpSend (const dtpSockInfo * const sockInfo, const int stream,
        const uint8_t * const sendPdu, const long transferSize)
{
    logFF();

    if (stream > sockInfo->sockData->confirmedSctpOutStreams)
    {
        logMsg (LOG_ERR, "%s%d%s%d\n", "Specified stream ", stream,
                " greater than agreed max ",
                sockInfo->sockData->confirmedSctpOutStreams);
        return -1;
    }
    logMsg (LOG_DEBUG, "%s%d%s%d%s%d\n", "Sending SCTP data over socket ",
            sockInfo->sockFd, " on stream ", stream, " size is ", transferSize);

    struct sctp_sndrcvinfo *ssr;
    char cbuf[CMSG_SPACE(sizeof(*ssr))];
    memset (cbuf, 0, CMSG_SPACE(sizeof(*ssr)));

    struct msghdr mh;
    memset (&mh, 0, sizeof(mh));
    mh.msg_control = cbuf;
    mh.msg_controllen = CMSG_SPACE(sizeof(*ssr));
    mh.msg_flags = 0;

    struct cmsghdr *cmsg;
    cmsg = CMSG_FIRSTHDR(&mh);
    cmsg->cmsg_len = CMSG_LEN(sizeof(*ssr));
    cmsg->cmsg_level = IPPROTO_SCTP;
    cmsg->cmsg_type = SCTP_SNDRCV;
    ssr = (struct sctp_sndrcvinfo*) CMSG_DATA(cmsg);
    ssr->sinfo_stream = stream;
    ssr->sinfo_ssn = 0;
    ssr->sinfo_flags = 0;

    struct iovec iov;
    iov.iov_base = (void *) sendPdu;
    iov.iov_len = transferSize;
    mh.msg_iov = &iov;
    mh.msg_iovlen = 1;

    int sentSize = 0;
    int chunkSize = 0;
    while (1)
    {
        chunkSize = sendmsg (sockInfo->sockFd, &mh, 0);
        if (chunkSize < 0)
        {
            /* Error, return */
            sentSize = -1;
            break;
        }
        logMsg (LOG_DEBUG, "%s%d%s%d%s%d%s%d%s%d\n",
                "Sent SCTP data over socket ", sockInfo->sockFd, " on stream ",
                ssr->sinfo_stream, "chunk size: ", chunkSize,
                " total sent size: ", sentSize, " PDU size ", transferSize);

        sentSize += chunkSize;
        if (sentSize >= transferSize)
        {
            break;
        }
        iov.iov_base = ((char *) sendPdu) + sentSize;
        iov.iov_len = transferSize - sentSize;
    }
    return sentSize;
}

/*todo nonblocking sctp_recv */
int transport_sctpRecv (const dtpSockInfo * const sockInfo, uint8_t **recvPdu,
        const int transferSize)
{
    logMsg (LOG_DEBUG, "%s%d%s%d\n", "Receiving SCTP data over socket ",
            sockInfo->sockFd, ", expected size is ", transferSize);

    struct sctp_sndrcvinfo *ssr;
    char cbuf[CMSG_SPACE(sizeof(*ssr))];
    memset (cbuf, 0, CMSG_SPACE(sizeof(*ssr)));

    struct msghdr mh;
    memset (&mh, 0, sizeof(mh));
    mh.msg_control = cbuf;
    mh.msg_controllen = CMSG_SPACE(sizeof(*ssr));
    mh.msg_flags = 0;

    struct cmsghdr *cmsg;
    cmsg = CMSG_FIRSTHDR(&mh);
    cmsg->cmsg_len = CMSG_LEN(sizeof(*ssr));
    cmsg->cmsg_level = IPPROTO_SCTP;
    cmsg->cmsg_type = SCTP_SNDRCV;
    ssr = CMSG_DATA(cmsg);

    *recvPdu = NULL;
    uint8_t *chunkPdu = malloc (sizeof(*chunkPdu) * (transferSize));
    memset (chunkPdu, 0, (sizeof(*chunkPdu) * (transferSize)));

    struct iovec iov;
    iov.iov_base = chunkPdu;
    iov.iov_len = transferSize;
    mh.msg_iov = &iov;
    mh.msg_iovlen = 1;

    int recvSize = 0;
    int chunkSize = 0;
    while (1)
    {
        chunkSize = recvmsg (sockInfo->sockFd, &mh, 0);
        if (chunkSize < 0)
        {
            /* Error, return NULL */
            *recvPdu = NULL;
            recvSize = -1;
            break;
        }
        if (mh.msg_flags & MSG_NOTIFICATION)
        {
            logMsg (LOG_DEBUG, "%s%d%s%d\n",
                    "Received SCTP message over socket ", sockInfo->sockFd,
                    " chunk size: ", chunkSize);
            if (transport_handleSctpEvent (sockInfo->sockFd, chunkPdu) < 0)
            {
                /* Shutdown, return NULL */
                *recvPdu = NULL;
                recvSize = -1;
                break;
            }
        }
        logMsg (LOG_DEBUG, "%s%d%s%d%s%d%s%d%s%d\n",
                "Received SCTP data over socket ", sockInfo->sockFd,
                " chunk size: ", chunkSize, " stream ", ssr->sinfo_stream,
                " total recv size: ", recvSize, " PDU size ", transferSize);

        recvSize += chunkSize;
        if ((mh.msg_flags & MSG_EOR) || (recvSize >= transferSize))
        {
            logMsg (LOG_DEBUG, "%s\n", "Received complete PDU");
            *recvPdu = chunkPdu;
            break;
        }
        iov.iov_base = (char *) chunkPdu + recvSize;
        iov.iov_len = transferSize - recvSize;
    }
    return recvSize;
}

int transport_handleSctpEvent (const int sockFd, const uint8_t * const buf)
{
    logFF();

    if (NULL == buf)
    {
        logMsg (LOG_WARNING, "%s\n", "Null input for sctp event handler");
        return;
    }

    union sctp_notification *notification = (union sctp_notification *) buf;
    switch ((notification->sn_header).sn_type)
    {
    case SCTP_SHUTDOWN_EVENT:
    {
        struct sctp_shutdown_event *shut;
        shut = (struct sctp_shutdown_event *) buf;
        logMsg (LOG_WARNING, "%s%d%s%d\n", "Shutdown on socket ", sockFd,
                " assoc id", shut->sse_assoc_id);
        return -1;
    }
    default:
        logMsg (LOG_WARNING, "%s%d\n", "Unhandled event type ",
                (notification->sn_header).sn_type);
        break;
    }
    return 0;
}