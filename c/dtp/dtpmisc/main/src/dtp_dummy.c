#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"

/* Dummy function. Replaces previous value of pc, if any */
void addPeerTableEntry (userData *ud, PeerConfig_t *pc)
{
    logMsg (LOG_ERR, "%s\n", "Adding Peer config");
    ud->output->peerConfiguration = pc;
    ud->output->nPeerEntries = 1;
}
/* Dummy function. Replaces previous value of rc, if any */
void addRealmTableEntry (userData *ud, RealmConfig_t *rc)
{
    logMsg (LOG_ERR, "%s\n", "Adding Realm config");
    ud->output->realmConfiguration = rc;
    ud->output->nRealmEntries = 1;
}
