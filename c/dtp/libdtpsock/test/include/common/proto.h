/* src/client/test_client.c */
int propertySetup (char *argv[]);
int logSetup ();
void communicate ();
int main (int argc, char *argv[]);

/* src/common/common.c */
void usage ();
dtpSockAddr ** createAddrs (char * value);
uint8_t * createDataPdu (const int size, const char * const v1,
        const char * const v2);
void displayDataPdu (uint8_t *data, long size);
void sendData (const int sockFd, const int size);
void recvData (const int sockFd, const int size);

/* src/server/test_server.c */
int propertySetup (char *argv[]);
int logSetup ();
void handleClient (int sockFd);
void communicate ();
int main (int argc, char *argv[]);

