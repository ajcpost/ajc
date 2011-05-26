

/** @file db_config.h
 * Configuration data structure definitions for base Diameterer implementation. 
 * The data is read from config file. In addition, these in-memory structures 
 * also have some state information to speed up search - especially the 
 * most common search for a server based on realm and app Id.
 *
 *
 * @date <$DATE$>
 * @version $Header$
 *
 * (C) 2011: LiteCore Networks India Pvt Ltd. All rights reserved.
 * History: $Log$
 *
 */ 

#ifndef _DB_CONFIG_H
#define _DB_CONFIG_H 1

/* ajc, Added */
# define DC_MAX_HOSTNAME_LEN 50
typedef unsigned char lcn_u8_t;
typedef unsigned char lcn_u16_t;
typedef unsigned char lcn_u32_t;

/* for sundry names like product name */
#define DC_MAX_NAME_LEN 128

/* For SCTP */
#define DC_MAX_IP_ADDRESSES_PER_PEER 5

/* Maximum number of servers for a given realm+application */
#define DC_MAX_SERVERS_PER_APP 5 

/* Maximum number of peers per node*/
#define DC_MAX_PEERS 1024

/* Any type of Application Ids supported on a node - though typically
 * it would be one or two, on the server side we may have to support
 * many
 */
#define DC_MAX_SUPPORTED_ID  10

#define DC_MAX_THREADS  20
  /* Maximum number of PSM threads supported. Used for validation of
 * command line argument, increase this if it makes sense. Note that
 * there will be additional  forwarding  threads (3), one for connection
 * setting up, one main thread that handles sockets*/

/* Max unknown peers we will accept */
#define DC_MAX_UNKNOWN_PEERS 10

#define DC_DUPLICATEWATCH_INTERVAL 60
/* in secs. Duplicate watch is performed for this interval AFTER the last
 * 'T' flag set message is received on this connection
 */

#define DC_DIAM_TCP_PORT 3868
#define DC_DIAM_SCTP_PORT 3868

/* Action on receing CER from unknown peer */
#define DC_UNKNOWNPEER_REJECT 0
#define DC_UNKNOWNPEER_ACCEPT 1

/* Firmware revision. Change it for significant revisions */
#define DC_FIRMWARE_REVISION  1

/* Names of environment variables - just to make it easy to change */

/* Root of LCN Diameter installation */
#define LCNDIAM_ROOT_EV "LCNDIAM_ROOT"

/* Config file path */
#define LCNDIAM_CONFIG_EV "LCNDIAM_CONFIG"

/* Syslog Config file path */
#define LCNDIAM_SYSLOG_CONFIG_EV "LCNDIAM_SYSLOG_CONFIG"

/*Default locations */
#define DEF_LCNDIAM_ROOT "/opt/lcndiam"
#define DEF_LCNDIAM_CONFIG "/etc/lcndiam/lcndiam.conf"
#define DEF_LCNDIAM_SYSLOG_CONFIG "/etc/lcndiam/syslog.conf"

/* Path for archiving the transactions and PDUs */
#define LCNDIAM_TXARCHIVE_PATH_EV "LCNDIAM_TXARCHIVE_PATH"

#define DEF_LCNDIAM_TX_ARCHIVE_PATH "/var/lcndiam/txstore/"
#define DEF_LCNDIAM_TX_ARCHIVE_FILE "txarchive.dat"

/* Name of the product */
#define LCN_PRODUCT_NAME "LCN Base Diameter"

/*enum Security_t { DC_SEC_INVALID=0, DC_SEC_NONE, DC_SEC_TLS,DC_SEC_IPSEC,
                   DC_SEC_BOTH } ;
enum Protocol_t { DC_PROTO_INVALID=0,DC_PROTO_TCP, DC_PROTO_SCTP,
                   DC_PROTO_BOTH } ;
enum Role_t {DC_ROLE_INVALID=0, DC_ROLE_CLIENT, DC_ROLE_SERVER,
                   DC_ROLE_CLIENTSERVER};
enum LocalAction_t {DC_LA_LOCAL=1, DC_LA_RELAY, DC_LA_REDIRECT, DC_LA_PROXY,
                   DC_LA_NOT_FOUND};

 For marking the servers in the realm table
enum ConnectStatus_t {DC_NOT_CONNECTED=0, DC_CONNECTED, DC_APP_NOT_SUPPORTED };*/


/*
#define 3gpp_vendor_id  10415
#define etsi_vendor_id  13019
*/

typedef lcn_u8_t lcn_Address_t[DC_MAX_HOSTNAME_LEN];
typedef lcn_u8_t HostName_t[DC_MAX_HOSTNAME_LEN];
typedef lcn_u8_t RealmName_t[DC_MAX_HOSTNAME_LEN];

typedef struct {
  int nVendorIds ;
  lcn_u32_t vendorIds[DC_MAX_SUPPORTED_ID];
  int isAuth; /*Auth or Accting? TRUE for Auth */
  lcn_u32_t appId ;
} VendorSpecificAppId_t ;


typedef struct PeerConfigEntry {
  HostName_t  hostName; /* FQDN */

  /* Peer Table index remains invariant and is based on peer table in config
   * file. ActivePeerIndex may change during the lifetime of the process, say
   * if a transport connection fails and is re-established.
   */

  int  peerTableIndex ; /* Initialized during config read, starting with 0 */  /*(no tag)*/
  int  activePeerIndex ; /* Initialized when transport connection   /*(no tag)*/
       /* is established- maintained here for easy reference
       * -1 indicates not connected */
  int isDynamic ; /* False if statically configured, true otherwise */ /*(no tag)*/
  time_t expirationTime ; /* for dynamically configured entry */ /*(no tag)*/
  int security ; /* TLS/IPSec/BOTH/NONE */
  int proto ; /*SCTP/TCP/BOTH */ /*(add proto tag under peer)*/
  unsigned int   tcp_port ; /* If different from the standard port */ /*(remove port, add tcp_port/sctp_port tags under peer)*/
  unsigned int   sctp_port ; /* If different from the standard port */ /*(remove port, add tcp_port/sctp_port tags under peer)*/
  /* If IP address(es) is not specified, gethostbyname() will be used */
  int nIpAddresses; /* SCTP will support more than one */
  lcn_Address_t  ipAddresses[DC_MAX_IP_ADDRESSES_PER_PEER];  /*(add ipaddress tag under peer)*/
  time_t  lastFailedConnectTime ; /* When was last connection failed*/ /*(no tag)*/
} PeerConfig_t ;


typedef struct {
  HostName_t serverName;
  int weight; /*(change priority tag to weight)*/
  int cStatus ; /* CONNECTED/NOT-CONNECTED/APP-NOT-SUPPORTED */ /*(no tag)*/
  /* Realm entry may indicate APP-NOT-SUPPORTED even if peer is connected, if
   * CEA didn't have the required appId. This may indicate a config error */
} ServerListEntry_t ;

/* Remove default_route tag from xml*/
/* add field for vendor id in the c structure */ 
typedef struct RealmConfigEntry {
  HostName_t realmName; /*To be indexed by both realName AND appIdentifier*/
  lcn_u32_t  appIdentifier; /*we don't use vendor id for routing*/
  lcn_u32_t vendorId;
  int action; /*(change role tag to action)*/
  int nServers; /* Number of servers for this realm/appId */
  ServerListEntry_t  serverList[DC_MAX_SERVERS_PER_APP]; /* has name and weight*/
  int isDynamic ; /* False if statically configured, true otherwise */ /*(no tag)*/
  time_t expirationTime ; /* for dynamically configured entry */ /*(no tag)*/
  /* The following fields are state information for quick lookup, and are
   * not part of configuration */
  int isConnected ; /* Set when a peer is connected */ /*(no tag)*/
  int activePeerIndex1; /* Will be a valid index if connected */ /*(no tag)*/
  int activePeerIndex2; /* -1 if not valid, valid if two peers are connected*/ /*(no tag)*/
} RealmConfig_t ;

/* This structure represents in-memory Diameter configuration information. 
 * This is read from config file or set by command line arguments
 */

typedef struct DiameterConfig {
  HostName_t  nodeName ; /* Name of this diameter node */
  RealmName_t  nodeRealm ; /* realm of this diameter node */
  int nAddresses;
  lcn_Address_t ipAddresses[DC_MAX_IP_ADDRESSES_PER_PEER] ;  /* (add ipaddress tag under capabilities */
  lcn_u32_t       vendorId ;
  lcn_u8_t        productName[DC_MAX_NAME_LEN];
  lcn_u32_t       firmwareRevision ; 
  int             nVendorIds;
  lcn_u32_t       supportedVendorId[DC_MAX_SUPPORTED_ID];
  int             nAuthAppIds;
  lcn_u32_t       supportedAuthAppId[DC_MAX_SUPPORTED_ID];
  int             nAcctAppIds;
  lcn_u32_t       supportedAcctAppId[DC_MAX_SUPPORTED_ID];
  int             nVendorSpecificAppIds;
  VendorSpecificAppId_t       supportedVendorSpecificAppId[DC_MAX_SUPPORTED_ID];

  unsigned int  appPort;   /* (add tag under transport) */
  /* Listening Port used by application to communicate with Diameter Daemon */

  int proto; /* TCP/SCTP/BOTH: Protocols supported by this node */   /* (add tag under transport) */
  unsigned int  diamTCPPort ; 
  /* TCP Port used for listening to Peer connections */

  unsigned int  diamSCTPPort ; /* (add tag under transport) */
  /* SCTP Port used for listening to Peer connections */

  int security;  /* TLS/IPSEC/NONE, enumerated value */ /* (no tag) */
  int  role ;  /* If "client only" , node doesn't 'listen' for Peer */  /* (add tag under implementation) */
  int  numberOfThreads; /* Number of worker threads to be created */  /* (add tag under implementation */
  int  Twinit ; /* Initial value of Heartbeat timer */
  int  inactivityTimer ; /* Connections are closed if idle for this long*/
  int  reopenTimer ; /* To reopen closed connections*/  /* (add tag under implementation) */
  int smallPduSize ; /* size of buffer for 'small' PDUs */
  int bigPduSize ; /* size of buffer for 'big' PDUs */
  int pollingInterval ; /* in msecs */  /* (add tag under implementation) */
  int unknownPeerAction; /*accept/reject*/   /* (add tag under transport */
  int  nPeerEntries;
  PeerConfig_t  *peerConfiguration;
  int nRealmEntries;
  RealmConfig_t *realmConfiguration;
  int nUnknownPeers ; /* Not used */
  HostName_t unknownPeers[DC_MAX_UNKNOWN_PEERS] ; /* Not used */
  lcn_u32_t nodeStateId ; /* A unique value set everytime node boots */ /* Not used */

} DiameterConfig_t ;


#endif
