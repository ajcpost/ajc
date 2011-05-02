#ifndef DTPSOCK_HDR_H
#define DTPSOCK_HDR_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/sctp.h>
#include <netdb.h>
#include <fcntl.h>

#include "dtpsock_extern.h"
#include "dtpmisc_proto.h"
#include "dtp_logmgr.h"


/* Structure to hold IPv4 or IPv6 address.*/
typedef struct dtp_sockaddr {
	int port;
	int afamily;
	char *astring;
} dtpSockAddr;

/* Structure to hold input configuration information about the DTP socket */
typedef struct dtp_sockConfig {
	int afamily;                      /* Per the enum def above */
	int ipv6Only;                     /* Support ipv4 on ipv6? */
	int protocol;                     /* Per the socket protocol types */
	int blocking;                     /* Blocking or Non-blocking */
	int maxPduSize;                   /* Maximum PDU size, must be between g_minPduSize to g_maxPduSize */
	int serverListenQLen;             /* Backlog size for server listen socket */
	int reqSctpInStreams;             /* Requested no. of input sctp streams, may not necessarily get accepted */
	int reqSctpOutStreams;            /* Requested no. of output sctp streams, may not necessarily get accepted */
	int sharedBindPort;               /* Shared bind port across all the addresses below */
	dtpSockAddr **addrs;              /* List of addresses for use in bind or connect */
} dtpSockConfig;


/*
 * -----------------------------------------------------------------------------------------
 *  Implementation related
 * -----------------------------------------------------------------------------------------
 */

typedef enum dtp_sockState {
	dtpCreated = 0,
	dtpClientConnectInProgress = 1,
	dtpClientConnected = 2,
	dtpServerListen = 3,
	dtpServerAccept = 4,
	dtpAborted = 5
} dtpSockState;

typedef struct dtp_sockData {
	dtpSockState sockState;
	int confirmedSctpInStreams;
	int confirmedSctpOutStreams;
} dtpSockData;

typedef struct dtp_SockInfo {
	int sockFd;
	dtpSockConfig *sockConfig;
	dtpSockData *sockData;
} dtpSockInfo;


#endif /* DTPSOCK_HDR_H */
