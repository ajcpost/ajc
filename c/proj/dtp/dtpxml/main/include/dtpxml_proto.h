/* src//dtp_xmldummy.c */
void addPeerTableEntry (userData *ud, PeerConfig_t *pc);
void addRealmTableEntry (userData *ud, RealmConfig_t *rc);

/* src//dtp_xmlop.c */
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

/* src//dtp_xmlop_print.c */
void printServerList (ServerListEntry_t *sle);
void printRealmConfig (RealmConfig_t *rc);
void printPeerConfig (PeerConfig_t *pc);
void printVSA (VendorSpecificAppId_t *vsa);
void printOutput (DiameterConfig_t *output);

/* src//dtp_xmlparse.c */
tagMetadata * findTagMetadata (userData *ud, char *tag);
void startTagCallback (void *udata, const xmlChar *name, const xmlChar **attrs);
void endTagCallback (void *udata, const xmlChar *name);
void dataCallback (void *udata, const xmlChar *ch, int len);
char *copyData (const xmlChar *ch, const int len);
void logDetails (userData *ud);
int parseXmlConfig (const char * const xmlFilePath, DiameterConfig_t *output);

