/* src/ds/core_hashMap.c */
static unsigned long hashCode (const char *str);
map * createMap (unsigned long capacity);
void deleteMap (map *mp);
char *getFromMap (map *mp, const char *key);
char * putInMap (map *mp, char *key, char *value);

/* src/mgr/core_logmgr.c */
void logMsg (const int msgLevel, const char * const format, ...);
void useSyslog (int facility);
void createLog (const char * const logPath, const char * const logLevel,
        const int size, const int rollOver);
static void setLogLevel (const char * const level);
static char *getBakLogPath (const char * const logPath);

/* src/mgr/core_propmgr.c */
const char * const getPropertyValue (const char * const propertyName);
int loadPropertiesFromFile (const char * const propertyFile, const int expectedNumProperties);

/* src/util/core_util.c */
void myfree (void *p);
const char * const filePathToName (const char * const filePath);
char * getTimeNoNewLine ();
char *getDate ();
const int getRandomNo (const int hwm);
void displayMemory(char *address, int length);
void logMemoryData (char *address, int length);
long hash (const char *str);

