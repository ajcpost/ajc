#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <limits.h>
#include <inttypes.h>

#include "dtpsock_hdr.h"
#include "dtpsock_proto.h"
#include "dtpsocktest_proto.h"

/* Test program; will use globals to speed up */
dtpSockConfig g_sockConfig;
int g_transferDataSize;
char *g_logPath;
int g_logSize;
char *g_logLevel;
char *g_bAddr;
int g_enableSslClientAuth;
char *g_keyFile;
char *g_certFile;
char *g_certStore;


int propertySetup (char *argv[])
{
    logFF ();

    /* Test program; no validations done on the properties */
    loadPropertiesFromFile (argv[1]);
    logMsg (LOG_DEBUG, "%s%s\n", "Loaded properties from the file", argv[1]);

    memset (&g_sockConfig, 0, sizeof(g_sockConfig));
    g_logPath = getPropertyValue (propServerLogFilePath);
    g_logSize = strtol (getPropertyValue (propServerMaxLogSize), NULL, 10);
    g_logLevel = getPropertyValue (propServerLogLevel);

    g_sockConfig.maxPduSize = strtol (getPropertyValue (propMaxPduSize), NULL,
            10);
    g_sockConfig.afamily = strtol (getPropertyValue (propAfamily), NULL, 0);
    g_sockConfig.ipv6Only = strtol (getPropertyValue (propIPv6Only), NULL, 0);
    g_sockConfig.blocking = strtol (getPropertyValue (propBlocking), NULL, 0);
    g_sockConfig.protocol = strtol (getPropertyValue (propProtocol), NULL, 10);
    g_sockConfig.sharedPort = strtol (getPropertyValue (propServerSharedPort),
            NULL, 10);
    g_transferDataSize = strtol (getPropertyValue (propTransferDataSize), NULL,
            10);
    g_sockConfig.serverListenQLen = strtol (getPropertyValue (
            propServerSocketQLen), NULL, 10);
    g_bAddr = getPropertyValue (propServerBindAddr);
    g_sockConfig.enableSSL = strtol (getPropertyValue (propEnableSsl), NULL, 0);
    g_enableSslClientAuth = strtol (getPropertyValue (
            propEnableSslClientAuth), NULL, 10);
    g_keyFile = (char *) getPropertyValue (propServerKeyFile);
    g_certFile = (char *) getPropertyValue (propServerCertFile);
    g_certStore = (char *) getPropertyValue (propServerCertStore);


    logMsg (LOG_DEBUG, "%s\n", "Converted the read properties");
    g_sockConfig.addrs = createAddrs ((char *) g_bAddr);
    logMsg (LOG_DEBUG, "%s\n", "Converted the addresses");
}

int logSetup ()
{
    logFF ();

    createLog (g_logPath, g_logLevel, g_logSize, 0);
    /*openlog ("TestClient", LOG_NDELAY, LOG_USER);*/
    /*useSyslog (LOG_USER);*/
}

void handleClient (int sockFd)
{
    logFF ();
    recvData (sockFd, g_transferDataSize);
    sendData (sockFd, g_transferDataSize);
}

void communicate ()
{
    logFF ();

    if (dtpSuccess != dtp_ssl (g_certStore, g_certFile, g_keyFile, g_enableSslClientAuth))
    {
        usage  ();
    }
    if (dtpSuccess != dtp_ssl (g_certStore, g_certFile, g_keyFile, g_enableSslClientAuth))
    {
        usage  ();
    }

    int sockFd;
    if (dtpSuccess != dtp_init (&sockFd, &g_sockConfig))
    {
        usage ();
    }
    logMsg (LOG_DEBUG, "%s%d\n", "Initialized DTP socket ", sockFd);
    if (dtpSuccess != dtp_listen (sockFd))
    {
        usage ();
    }
    logMsg (LOG_DEBUG, "%s\n", "Server listening");

    int clientSockFd;
    while (1)
    {
        logMsg (LOG_INFO, "%s\n", "Waiting for incoming requests");
        if (dtpSuccess != dtp_accept (sockFd, &clientSockFd) < 0)
        {
            usage ();
        }
        handleClient (clientSockFd);
    }
}

int main (int argc, char *argv[])
{
    int retValue;
    if (argc < 2)
    {
        logMsg (LOG_CRIT, "%s\n", "Incorrect arguments");
        usage ();
    }
    propertySetup (argv);
    logSetup ();
    communicate ();
}
