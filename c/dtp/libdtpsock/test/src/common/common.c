#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <syslog.h>

#include "dtpsock_hdr.h"
#include "dtpsock_extern.h"
#include "dtpsock_proto.h"
#include "dtpmisc_proto.h"
#include "dtp_logmgr.h"
#include "dtp_propmgr.h"
#include "dtpsocktest_proto.h"

void usage ()
{
    printf ("Exiting... ");
    exit (-1);
}

dtpSockAddr ** createAddrs (char * value)
{
    int port;
    int afamily;
    char *addr;

    dtpSockAddr **addrs = malloc (sizeof(*addrs) * (g_maxAddrs + 1));
    memset (addrs, 0, (sizeof(*addrs) * (g_maxAddrs + 1)));
    char *token = strtok (value, " ");

    int addrCount = 0;
    int tokenCount = 0;
    while (NULL != token)
    {
        if (addrCount == g_maxAddrs)
        {
            break;
        }
        logMsg (LOG_DEBUG, "%s%s\n", "Token:", token);
        switch (tokenCount)
        {
        case 0:
            port = strtol (token, NULL, 0);
            break;
        case 1:
            afamily = strtol (token, NULL, 0);
            break;
        case 2:
            addr = token;
            addrs[addrCount] = malloc (sizeof(**addrs));
            addrs[addrCount]->port = port;
            addrs[addrCount]->afamily = afamily;
            addrs[addrCount]->astring = addr;
            tokenCount = -1;
            logMsg (LOG_DEBUG, "%s%d%s%d%s%d%s%s\n", "Address, count ",
                    addrCount, " port ", port, " afamily ", afamily,
                    " astring ", addr);
            ++addrCount;
            break;
        }
        token = strtok (NULL, " ");
        ++tokenCount;
    }
    return addrs;
}

uint8_t * createDataPdu (const int size, const char * const v1,
        const char * const v2)
{
    int i;
    uint8_t *data = malloc (sizeof(*data) * size);
    memset (data, 0, (sizeof(uint8_t) * size));

    for (i = 0; i < 10; i++)
    {
        data[i] = *v1;
    }

    for (i = size - 1; i > size - 11; i--)
    {
        data[i] = *v2;
    }

    return data;
}

void displayDataPdu (uint8_t *data, long size)
{
    int i;
    char buf[100];

    memset (&buf, 0, sizeof(buf));
    for (i = 0; i < 10; i++)
    {
        buf[i] = data[i];
    }
    logMsg (LOG_DEBUG, "%s\n", buf);

    memset (&buf, 0, sizeof(buf));
    int j = 0;
    for (i = size - 1; i > size - 11; i--)
    {
        buf[j++] = data[i];
    }
    logMsg (LOG_DEBUG, "%s\n", buf);
}

void sendData (const int sockFd, const int size)
{
    logFF();

    logMsg (LOG_DEBUG, "%s%d\n", "Sending PDU of size ", size);

    uint8_t *sendPdu = createDataPdu (size, "y", "z");
    int sentSize = 0;
    while (1)
    {
        int chunkSize = dtp_send (sockFd, (sendPdu + sentSize),
                (size - sentSize));
        logMsg (LOG_DEBUG, "%s%d%s%d\n", " Sent chunk ", chunkSize, " sent total ", sentSize+chunkSize);
        if (chunkSize < 0)
        {
            usage ();
        }
        sentSize += chunkSize;
        if (sentSize == size)
        {
            break;
        }
    }
}

void recvData (const int sockFd, const int size)
{
    logFF();

    logMsg (LOG_DEBUG, "%s%d\n", "Receiving PDU of size ", size);

    uint8_t *recvPdu = NULL;
    uint8_t *chunkPdu = NULL;
    int recvSize = 0;
    int chunkSize = 0;
    while (1)
    {
        chunkSize = dtp_recv (sockFd, &chunkPdu, (size-recvSize));
        logMsg (LOG_DEBUG, "%s%d%s%d\n", " Received chunk ", chunkSize, " received total ", recvSize+chunkSize);
        if (chunkSize <= 0)
        {
            /* <0 error
             * 0 peer closed the connection in TCP case
             */
            usage ();
        }
        recvPdu = realloc (recvPdu, recvSize + chunkSize);
        memcpy (recvPdu + recvSize, chunkPdu, chunkSize);
        recvSize += chunkSize;
        if (recvSize == size)
        {
            break;
        }
    }

    logMsg (LOG_DEBUG, "%s\n", "Portions of received data: ");
    displayDataPdu (recvPdu, recvSize);
}
