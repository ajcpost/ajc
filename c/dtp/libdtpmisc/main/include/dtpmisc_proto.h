/* src/asciiprop/dtp_propmgr.c */
const char * const getPropertyValue (const char * const propertyName);
int loadPropertiesFromFile (const char * const propertyFile);
static int getNoOfProperties ();
static int checkProperties ();
static void logPropertyValues ();

/* src/log/dtp_logmgr.c */
void logMsg (const int msgLevel, const char * const format, ...);
void useSyslog (int facility);
void createLog (const char * const logPath, const char * const logLevel,
        const int size, const int rollOver);
static void setLogLevel (const char * const level);
static char *getBakLogPath (const char * const logPath);

/* src/util/dtp_util.c */
void myfree (void *p);
const char * const filePathToName (const char * const filePath);
char * getTimeNoNewLine ();
char *getDate ();
const int getRandomNo (const int hwm);
void displayMemory(char *address, int length);
void logMemoryData (char *address, int length);

/* src/xmlprop/xmlcallbacks.c */
void startElementCallback (void *udata, const xmlChar *name,
                           const xmlChar **attrs);
void endElementCallback (void *udata, const xmlChar *name);
void startDataCallback (void *udata, const xmlChar *ch, int len);
int endTagMismatch (userData *ud, char *tag);
char *copyData (const xmlChar *ch, const int len);

/* src/xmlprop/xmloutput.c */
int validateProductName (DiameterConfig_t *output, const char *value);
void addProductName (DiameterConfig_t *output, const char *value);
int validateSupportedVendorId (DiameterConfig_t *output, const char *value);
void addSupportedVendorId (DiameterConfig_t *output, const char *value);

/* src/xmlprop/xmlparse.c */
tagMetadata * getTagMetadata (userData *ud, char *tag);
int parseXmlConfig (const char * const xmlFilePath);
void printServerList (ServerListEntry_t *sle);
void printRealmConfig (RealmConfig_t *rc);
void printPeerConfig (PeerConfig_t *pc);
void printVSA (VendorSpecificAppId_t *vsa);
void printOutput (DiameterConfig_t *output);

