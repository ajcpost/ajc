/* src/dtp_impl_globals.c */

/* src/dtp_impl_init.c */
int init_createSocket (int *sockFd, const dtpSockConfig * const sockConfig);
int init_setNonBlocking (const int sockFd);
int init_defaultBind (const dtpSockInfo * const sockInfo);
int init_bind (const dtpSockInfo * const sockInfo, const int packedCount,
        const struct sockaddr_storage * const packedAddrs);
int init_connect (const dtpSockInfo * const sockInfo, const int packedCount,
        const struct sockaddr_storage * const packedAddrs);
int init_tcpListen (const dtpSockInfo * const sockInfo);
int init_sctpListen (const dtpSockInfo * const sockInfo);
const dtpSockInfo * init_addAcceptSockToStore (const int newSockFd,
        const dtpSockInfo * const sockInfo);
char * init_getPeerAddress (const dtpSockInfo * const sockInfo);
int init_tcpAccept (const dtpSockInfo * const sockInfo, int *newSockFd);
int init_sctpAccept (const dtpSockInfo * const sockInfo, int *newSockFd);
void init_setSctpStreams (const dtpSockInfo * const sockInfo);
void init_getSctpStreams (const dtpSockInfo *sockInfo);
void init_registerSctpEvents (const dtpSockInfo * const sockInfo);

/* src/dtp_impl_store.c */
int store_getSockCount ();
dtpSockInfo * store_getSockInfo (const int sockFd);
const int store_getEmptySlot ();
const int store_getSlot (const int sockFd);
dtpSockInfo * store_add (const int sockFd, dtpSockConfig * config);
int store_remove (const int sockFd);

/* src/dtp_impl_transport.c */
int transport_tcpSend (const dtpSockInfo * const sockInfo,
        const uint8_t * const sendPdu, const long transferSize);
int transport_tcpRecv (const dtpSockInfo * const sockInfo, uint8_t *recvPdu,
        const long transferSize);
int transport_sctpSend (const dtpSockInfo * const sockInfo, const int stream,
        const uint8_t * const sendPdu, const long transferSize);
int transport_sctpRecv (const dtpSockInfo * const sockInfo, uint8_t **recvPdu,
        const int transferSize);
int transport_handleSctpEvent (const int sockFd, const uint8_t * const buf);

/* src/dtp_impl_util.c */
char *util_protocolToString (const int protocol);
char *util_afamilyToString (const int afamily);
char *util_dtpSockStateToString (const dtpSockState sockState);
struct addrinfo * util_getAddrInfo (const char * const address,
        const int afamily, const int aiprotocol, const int port,
        const int forConnect);
const char *util_saToString (const struct sockaddr_in *sa);
const char *util_sa6ToString (const struct sockaddr_in6 *sa6);
const char * util_ssToString (const struct sockaddr_storage * addr);
const char * util_aiToString (const struct addrinfo * addr);
int util_packAddrs (const dtpSockInfo * const sockInfo, const int sharedPort,
        const int forConnect, const dtpSockAddr ** const addrs,
        struct sockaddr_storage ** packedAddrs);
int util_packAddrsForBind (const dtpSockInfo * const sockInfo,
        struct sockaddr_storage ** packedAddrs);
int util_packAddrsForConnect (const dtpSockInfo * const sockInfo,
        const int sharedPort,
        const dtpSockAddr ** const addrs,
        struct sockaddr_storage ** packedAddrs);
int util_freePackAddrs (struct sockaddr_storage *packedAddrs);
void util_freeDtpSockConfig (dtpSockConfig *dsp);
void util_freeDtpSockData (dtpSockData *dsd);
void util_freeDtpSockInfo (dtpSockInfo *dsi);
dtpSockConfig * util_copySockConfig (const dtpSockConfig * const inSockConfig);
int util_getSctpStream (int maxLimit);

/* src/dtp_impl_validations.c */
int val_checkProtocol (const int protocol);
int val_checkAfamily (const int afamily);
int val_checkInt (const int value, const char * const name, const int min,
        const int max);

/* src/dtp_interface.c */
int dtp_init (int *sockFd, const dtpSockConfig * const sockConfig);
int dtp_bind (const dtpSockInfo * const sockInfo);
int dtp_connect (const int sockFd, const int sharedPort, const dtpSockAddr ** const connectAddrs);
int dtp_listen (const int sockFd);
int dtp_accept (int sockFd, int *newSockFd);
void dtp_close (const int sockFd);
int dtp_send (const int sockFd, const uint8_t * const payLoad, const long size);
int dtp_recv (const int sockFd, uint8_t **buf, const long maxBytes);

