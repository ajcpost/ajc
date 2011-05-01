#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <syslog.h>

#include "dtp_header.h"
#include "dtp_extern.h"
#include "dtp_proto.h"
#include "misc_proto.h"
#include "log_manager.h"
#include "property_manager.h"
#include "proto.h"

/* Test program; will use globals to speed up */
dtpSockConfig g_sockConfig;
int g_transferDataSize;
const char *g_logPath;
int g_logSize;
const char *g_logLevel;
const char *g_bAddr;
const char *g_cAddr;
dtpSockAddr **g_connectAddrs;


int propertySetup (char *argv[])
{
    logFF();

    /* Test program; no validations done on the properties */
    loadPropertiesFromFile (argv[1]);
    logMsg (LOG_DEBUG, "%s%s\n", "Loaded properties from the file", argv[1]);

    g_logPath = (char *) getPropertyValue (propClientLogFilePath);
    g_logSize = atol (getPropertyValue (propClientMaxLogSize));
    g_logLevel = (char *) getPropertyValue (propClientLogLevel);

    memset (&g_sockConfig, 0, sizeof(g_sockConfig));
    g_sockConfig.afamily = strtol (getPropertyValue (propAfamily), NULL, 0);
    g_sockConfig.ipv6Only = strtol (getPropertyValue (propIPv6Only), NULL, 0);
    g_sockConfig.blocking = strtol (getPropertyValue (propBlocking), NULL, 0);
    g_sockConfig.protocol = strtol (getPropertyValue (propProtocol), NULL, 0);
    g_sockConfig.maxPduSize = strtol (getPropertyValue (propMaxPduSize), NULL, 0);
    g_sockConfig.sharedBindPort = strtol (getPropertyValue (
            propClientSharedBindPort), NULL, 0);
    g_bAddr = (char *) getPropertyValue (propClientBindAddr);
    g_cAddr = (char *) getPropertyValue (propClientConnectAddr);
    g_transferDataSize = strtol (getPropertyValue (propTransferDataSize), NULL, 0);


    logMsg (LOG_DEBUG, "%s\n", "Converted the read properties");
    g_sockConfig.addrs = createAddrs ((char *) g_bAddr);
    g_connectAddrs = createAddrs ((char *) g_cAddr);
    logMsg (LOG_DEBUG, "%s\n", "Converted the addresses");
}

int logSetup ()
{
    logFF();

    createLog (g_logPath, g_logLevel, g_logSize, 0);
    /*openlog ("TestClient", LOG_NDELAY, LOG_USER);*/
    /*useSyslog (LOG_USER);*/
}

void communicate ()
{
    logFF ();

    int sockFd;
    if (dtpSuccess != dtp_init (&sockFd, &g_sockConfig))
    {
        usage ();
    }
    logMsg (LOG_DEBUG, "%s%d\n", "Initialized DTP socket ", sockFd);

    if (dtpSuccess != dtp_connect (sockFd, g_connectAddrs))
    {
        usage ();
    }
    logMsg (LOG_DEBUG, "%s\n", "Connected to the server");
    logMsg (LOG_DEBUG, "%s%d\n", "Sending data of size ", g_transferDataSize);

    sendData (sockFd, g_transferDataSize);
    recvData (sockFd, g_transferDataSize);
    dtp_close (sockFd);
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
