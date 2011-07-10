#include "dtpsock_hdr.h"
#include "dtpsock_proto.h"

/*
 * todo
 * If this is made static, it results in following errors during compile time.
 * /var/folders/0v/0vZHa098GwG5hNqYY535P+++SFY/-Tmp-//cc3Hw1ZP.s:49:non-relocatable subtraction expression, "_s_openSocks" minus "L00000000001$pb"
 * /var/folders/0v/0vZHa098GwG5hNqYY535P+++SFY/-Tmp-//cc3Hw1ZP.s:49:symbol: "_s_openSocks" can't be undefined in a subtraction expression
 *
 */
dtpSockInfo **s_openSocks;

int store_getSockCount ()
{
    logFF();
    if (NULL == s_openSocks)
    {
        return 0;
    }
    int occupancyCount = 0;
    int i = 0;
    for (i = 0; i < g_maxOpenSocks; i++)
    {
        if (NULL != s_openSocks[i])
        {
            ++occupancyCount;
        }
    }
    return occupancyCount;
}

dtpSockInfo * store_getSockInfo (const int sockFd)
{
    int slot = store_getSlot (sockFd);
    if (-1 == slot)
    {
        logMsg (LOG_CRIT, "%s%d%s\n", "Socket  ", sockFd, " is not initialized");
        return NULL;
    }
    return s_openSocks[slot];
}

const int store_getEmptySlot ()
{
    logFF();

    if (NULL == s_openSocks)
    {
        s_openSocks = malloc (sizeof(*s_openSocks) * g_maxOpenSocks);
        memset (s_openSocks, 0, sizeof(*s_openSocks) * g_maxOpenSocks);
        return 0;
    }
    int i = 0;
    for (i = 0; i < g_maxOpenSocks; i++)
    {
        if (NULL == s_openSocks[i])
        {
            return i;
        }
    }
    return -1;
}

const int store_getSlot (const int sockFd)
{
    if (NULL == s_openSocks)
    {
        return -1;
    }
    int i = 0;
    for (i = 0; i < g_maxOpenSocks; i++)
    {
        if ((NULL != s_openSocks[i]) && (sockFd == s_openSocks[i]->sockFd))
        {
            return i;
        }
    }
    return -1;
}

/* Add makes sure that config and data are always allocated */
dtpSockInfo * store_add (const int sockFd, dtpSockConfig * config)
{
    logFF();

    if (NULL == config)
    {
        logMsg (LOG_CRIT, "%s%d%s\n", "Failed to add socket ", sockFd,
                " to the list, null input properties");
        return NULL;
    }
    if (-1 != store_getSlot (sockFd))
    {
        logMsg (LOG_CRIT, "%s%d%s\n", "Failed to add socket ", sockFd,
                " to the list since it's already added");
        return NULL;
    }

    int slot = store_getEmptySlot ();
    if (-1 == slot)
    {
        logMsg (LOG_CRIT, "%s%d%s\n", "Failed to add socket ", sockFd,
                " to the list since it's full");
        return NULL;
    }
    logMsg (LOG_DEBUG, "%s%d\n", "Got slot ", slot);

    s_openSocks[slot] = malloc (sizeof(**s_openSocks));
    s_openSocks[slot]->sockData = malloc (sizeof(dtpSockData));

    s_openSocks[slot]->sockFd = sockFd;
    s_openSocks[slot]->sockConfig = config;
    s_openSocks[slot]->sockData->sockState = dtpCreated;
    return s_openSocks[slot];
}
int store_remove (const int sockFd)
{
    logFF();

    const int slot = store_getSlot (sockFd);
    if (-1 == slot)
    {
        logMsg (LOG_CRIT, "%s%d%s\n", "Failed to remove socket ", sockFd,
                " from the list since it could not be found");
        return dtpError;
    }
    logMsg (LOG_DEBUG, "%s%d\n", "Removing socket at slot ", slot);
    dtpSockInfo *sockInfo = s_openSocks[slot];
    s_openSocks[slot] = NULL;
    util_freeDtpSockInfo (sockInfo);
    return dtpSuccess;
}
