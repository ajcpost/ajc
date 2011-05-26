#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"

void printServerList (ServerListEntry_t *sle)
{
    if (NULL == sle)
    {
        logMsg (LOG_INFO, "%s\n", "        serverList is Null");
        return;
    }
    logMsg (LOG_INFO, "%s%s\n", "        serverName: ",
        ((sle->serverName) ? sle->serverName : "null"));
    logMsg (LOG_INFO, "%s%d\n", "        weight: ", sle->weight);
    logMsg (LOG_INFO, "%s%d\n", "        cStatus: ", sle->cStatus);

}
void printRealmConfig (RealmConfig_t *rc)
{
    if (NULL == rc)
    {
        logMsg (LOG_INFO, "%s\n", "    realmConfig is Null");
        return;
    }
    logMsg (LOG_INFO, "%s%s\n", "    realmName: ",
        ((rc->realmName) ? rc->realmName : "null"));
    logMsg (LOG_INFO, "%s%d\n", "    appIdentifier: ", rc->appIdentifier);
    logMsg (LOG_INFO, "%s%d\n", "    action: ", rc->action);
    logMsg (LOG_INFO, "%s%d\n", "    nServers: ", rc->nServers);
    int i;
    for (i = 0; i < rc->nServers; i++)
    {
        printServerList (&rc->serverList[i]);
    }

    logMsg (LOG_INFO, "%s%d\n", "    isDynamic: ", rc->isDynamic);
    logMsg (LOG_INFO, "%s%d\n", "    expirationTime: ", rc->expirationTime);
    logMsg (LOG_INFO, "%s%d\n", "    isConnected: ", rc->isConnected);
    logMsg (LOG_INFO, "%s%d\n", "    activePeerIndex1: ", rc->activePeerIndex1);
    logMsg (LOG_INFO, "%s%d\n", "    activePeerIndex2: ", rc->activePeerIndex2);
}

void printPeerConfig (PeerConfig_t *pc)
{
    if (NULL == pc)
    {
        logMsg (LOG_INFO, "%s\n", "    peerConfig is Null");
        return;
    }
    logMsg (LOG_INFO, "%s%d\n", "    peerTableIndex: ", pc->peerTableIndex);
    logMsg (LOG_INFO, "%s%d\n", "    activePeerIndex: ", pc->activePeerIndex);
    logMsg (LOG_INFO, "%s%d\n", "    isDynamic: ", pc->isDynamic);
    logMsg (LOG_INFO, "%s%d\n", "    expirationTime: ", pc->expirationTime);
    logMsg (LOG_INFO, "%s%d\n", "    security: ", pc->security);
    logMsg (LOG_INFO, "%s%d\n", "    proto: ", pc->proto);
    logMsg (LOG_INFO, "%s%d\n", "    tcp_port: ", pc->tcp_port);
    logMsg (LOG_INFO, "%s%d\n", "    sctp_port: ", pc->sctp_port);
    logMsg (LOG_INFO, "%s%d\n", "    nIpAddresses: ", pc->nIpAddresses);
    int i;
    for (i = 0; i < pc->nIpAddresses; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%s\n", "    ipAddress", i, ": ",
            pc->ipAddresses[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "    lastFailedConnectTime: ",
        pc->lastFailedConnectTime);
}

void printVSA (VendorSpecificAppId_t *vsa)
{
    logMsg (LOG_INFO, "%s%d\n", "    nVendorIds: ", vsa->nVendorIds);
    int i = 0;
    for (i = 0; i < vsa->nVendorIds; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%d\n", "    vendorIds", i, ": ",
            vsa->vendorIds[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "    isAuth: ", vsa->isAuth);
    logMsg (LOG_INFO, "%s%d\n", "    appId: ", vsa->appId);

}
void printOutput (DiameterConfig_t *output)
{
    logMsg (LOG_INFO, "%s\n", "------- Output -------");
    if (NULL == output)
    {
        logMsg (LOG_INFO, "%s\n", "Output is Null");
        return;
    }
    logMsg (LOG_INFO, "%s%s\n", "nodeName: ",
        ((output->nodeName) ? output->nodeName : "null"));
    logMsg (LOG_INFO, "%s%s\n", "nodeRealm: ",
        ((output->nodeRealm) ? output->nodeRealm : "null"));
    logMsg (LOG_INFO, "%s%d\n", "nAddresses: ", output->nAddresses);
    int i = 0;
    for (i = 0; i < output->nAddresses; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%s\n", "ipAddress", i, ": ",
            output->ipAddresses[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "vendorId: ", output->vendorId);
    logMsg (LOG_INFO, "%s%s\n", "productName: ",
        ((output->productName) ? output->productName : "null"));
    logMsg (LOG_INFO, "%s%d\n", "firmwareRevistion: ", output->firmwareRevision);
    logMsg (LOG_INFO, "%s%d\n", "nVendorIds: ", output->nVendorIds);
    for (i = 0; i < output->nVendorIds; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%d\n", "supportedVendorId", i, ": ",
            output->supportedVendorId[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "nAuthAppIds: ", output->nAuthAppIds);
    for (i = 0; i < output->nAuthAppIds; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%d\n", "supportedAuthAppId", i, ": ",
            output->supportedAuthAppId[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "nAcctAppIds: ", output->nAcctAppIds);
    for (i = 0; i < output->nAcctAppIds; i++)
    {
        logMsg (LOG_INFO, "%s%d%s%d\n", "supportedAcctAppId", i, ": ",
            output->supportedAcctAppId[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "nVendorSpecificAppIds: ",
        output->nVendorSpecificAppIds);
    for (i = 0; i < output->nVendorSpecificAppIds; i++)
    {
        printVSA (&output->supportedVendorSpecificAppId[i]);
    }
    logMsg (LOG_INFO, "%s%d\n", "appPort: ", output->appPort);
    logMsg (LOG_INFO, "%s%d\n", "proto: ", output->proto);
    logMsg (LOG_INFO, "%s%d\n", "diamTCPPort: ", output->diamTCPPort);
    logMsg (LOG_INFO, "%s%d\n", "diamSCTPPort: ", output->diamSCTPPort);
    logMsg (LOG_INFO, "%s%d\n", "role: ", output->role);
    logMsg (LOG_INFO, "%s%d\n", "numberOfThreads: ", output->numberOfThreads);
    logMsg (LOG_INFO, "%s%d\n", "Twinit: ", output->Twinit);
    logMsg (LOG_INFO, "%s%d\n", "reopenTimer: ", output->reopenTimer);
    logMsg (LOG_INFO, "%s%d\n", "smallPduSize: ", output->smallPduSize);
    logMsg (LOG_INFO, "%s%d\n", "bigPduSize: ", output->bigPduSize);
    logMsg (LOG_INFO, "%s%d\n", "pollingInterval: ", output->pollingInterval);
    logMsg (LOG_INFO, "%s%d\n", "unknownPeerAction: ",
        output->unknownPeerAction);

    logMsg (LOG_INFO, "%s%d\n", "nPeerEntries: ", output->nPeerEntries);
    for (i = 0; i < output->nPeerEntries; i++)
    {
        printPeerConfig (output->peerConfiguration + i);
    }
    logMsg (LOG_INFO, "%s%d\n", "nRealmEntries: ", output->nRealmEntries);
    for (i = 0; i < output->nRealmEntries; i++)
    {
        printRealmConfig (output->realmConfiguration + i);
    }
    logMsg (LOG_INFO, "%s\n", "-------  -------");

}
