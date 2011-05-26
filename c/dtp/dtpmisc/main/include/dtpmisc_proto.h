/* src/dtp_logmgr.c */
void logMsg (const int msgLevel, const char * const format, ...);
void useSyslog (int facility);
void createLog (const char * const logPath, const char * const logLevel,
        const int size, const int rollOver);
static void setLogLevel (const char * const level);
static char *getBakLogPath (const char * const logPath);

/* src/dtp_propmgr.c */
const char * const getPropertyValue (const char * const propertyName);
int loadPropertiesFromFile (const char * const propertyFile);
static int getNoOfProperties ();
static int checkProperties ();
static void logPropertyValues ();

/* src/dtp_util.c */
void myfree (void *p);
const char * const filePathToName (const char * const filePath);
char * getTimeNoNewLine ();
char *getDate ();
const int getRandomNo (const int hwm);
void displayMemory(char *address, int length);
void logMemoryData (char *address, int length);

/* src/dtp_xmlcb.c */
void startTagCallback (void *udata, const xmlChar *name,
    const xmlChar **attrs);
void endTagCallback (void *udata, const xmlChar *name);
void dataCallback (void *udata, const xmlChar *ch, int len);
char *copyData (const xmlChar *ch, const int len);

/* src/dtp_xmlop.c */
void appendDataError (userData *ud, char *errString);
void handleCapProductName (userData *ud, char *data);
void handleCapRevision (userData *ud, char *data);
void handleCapVendorId (userData *ud, char *data);
void handleCapIPAddress (userData *ud, char *data);
void handleCapSupportedVendorId (userData *ud, char *data);
void handleCapAuthAppId (userData *ud, char *data);
void handleCapAcctAppId (userData *ud, char *data);
void handleCapVsaiVendorId (userData *ud, char *data);
void handleCapVsaiAuthAppId (userData *ud, char *data);
void handleCapVsaiAcctAppId (userData *ud, char *data);
void handleTransportNodeName (userData *ud, char *data);
void handleTransportNodeRealm (userData *ud, char *data);
void handleTransportAppPort (userData *ud, char *data);
void handleTransportProto (userData *ud, char *data);
void handleTransportTcpPort (userData *ud, char *data);
void handleTransportSctpPort (userData *ud, char *data);
void handleTransportUnknownPeerAction (userData *ud, char *data);
void handleTransportPTPeerHostname (userData *ud, char *data);
void handleTransportPTPeerSecurity (userData *ud, char *data);
void handleTransportPTPeerProto (userData *ud, char *data);
void handleTransportPTPeerTcpPort (userData *ud, char *data);
void handleTransportPTPeerSctpPort (userData *ud, char *data);
void handleTransportPTPeerIPAddress (userData *ud, char *data);
void handleTransportRTRouteRealm (userData *ud, char *data);
void handleTransportRTRouteAction (userData *ud, char *data);
void handleTransportRTRouteAppId (userData *ud, char *data);
void handleTransportRTRouteAppVendorId (userData *ud, char *data);
void handleTransportRTRouteAppPeerServer (userData *ud, char *data);
void handleTransportRTRouteAppPeerWeight (userData *ud, char *data);
void handleImplRole (userData *ud, char *data);
void handleImplNumOfThreads (userData *ud, char *data);
void handleImplTwinit (userData *ud, char *data);
void handleImplInactivity (userData *ud, char *data);
void handleImplReopenTimer (userData *ud, char *data);
void handleImplSmallPdu (userData *ud, char *data);
void handleImplBigPdu (userData *ud, char *data);
void handleImplPollingInterval (userData *ud, char *data);
void handleStartTagCapVsai (userData *ud);
void handleEndTagCapVsai (userData *ud);
void handleStartTagCapIPAddress (userData *ud);
void handleStartTagTransportPTPeer (userData *ud);
void handleEndTagTransportPTPeer (userData *ud);
void handleStartTagTransportPTPeerIPAddress (userData *ud);
void handleStartTagTransportRTRoute (userData *ud);
void handleEndTagTransportRTRoute (userData *ud);
void handleStartTagTransportRTRouteAppPeer (userData *ud);
void addPeerTableEntry (userData *ud, PeerConfig_t *pc);
void addRealmTableEntry (userData *ud, RealmConfig_t *rc);

/* src/dtp_xmlparse.c */
tagMetadata * getTagMetadata (userData *ud, char *tag);
int parseXmlConfig (const char * const xmlFilePath);
void printServerList (ServerListEntry_t *sle);
void printRealmConfig (RealmConfig_t *rc);
void printPeerConfig (PeerConfig_t *pc);
void printVSA (VendorSpecificAppId_t *vsa);
void printOutput (DiameterConfig_t *output);

