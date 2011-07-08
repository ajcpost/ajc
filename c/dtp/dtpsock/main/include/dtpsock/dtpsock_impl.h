#ifndef DTPSOCK_IMPL_H
#define DTPSOCK_IMPL_H

/* Structure to hold IPv4 or IPv6 address.*/
typedef struct dtp_sockaddr {
	int isHost;
    int afamily;
	char *astring;
} dtpSockAddr;

/* Structure to hold input configuration information about the DTP socket */
typedef struct dtp_sockConfig {
	int afamily;                      /* Per the enum def above */
	int ipv6Only;                     /* Support ipv4 on ipv6? */
	int protocol;                     /* Per the socket protocol types */
	int blocking;                     /* Blocking or Non-blocking */
	int enableSSL;                    /* Enable secure socket */
	int maxPduSize;                   /* Maximum PDU size, must be between g_minPduSize to g_maxPduSize */
	int serverListenQLen;             /* Backlog size for server listen socket */
	int reqSctpInStreams;             /* Requested no. of input sctp streams, may not necessarily get accepted */
	int reqSctpOutStreams;            /* Requested no. of output sctp streams, may not necessarily get accepted */
	int sharedPort;                   /* Shared port across all the addresses below */
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
	SSL *ssl;
	int confirmedSctpInStreams;
	int confirmedSctpOutStreams;
} dtpSockData;

typedef struct dtp_SockInfo {
	int sockFd;
	dtpSockConfig *sockConfig;
	dtpSockData *sockData;
} dtpSockInfo;



extern const int dtpSuccess;
extern const int dtpError;

extern const int g_maxAddrs;
extern const int g_maxOpenSocks;

extern const int g_defaultNonBlocking;

extern const int g_defaultIPv6Only;

extern const int g_minPduSize;
extern const int g_maxPduSize;
extern const int g_defaultPduSize;

extern const int g_minServerListenQLen;
extern const int g_maxServerListenQLen;
extern const int g_defaultServerListenQLen;

extern const int g_minSctpInStreams;
extern const int g_maxSctpInStreams;
extern const int g_defaultSctpInStreams;

extern const int g_minSctpOutStreams;
extern const int g_maxSctpOutStreams;
extern const int g_defaultSctpOutStreams;

extern const int g_minPort;
extern const int g_maxPort;

#endif /* DTPSOCK_IMPL_H */
