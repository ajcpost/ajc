#include "core_hdr.h"
#include "core_proto.h"
#include "core_hashMap.h"

static unsigned long s_maxCapacity = 10000000;

static unsigned long hashCode (const char *str)
{
    unsigned long hashCode = 0;
    int len = strlen (str);

    int i;
    for (i = 0; i < len; i++)
    {
        hashCode = 31 * hashCode + str[i];
    }

    return hashCode;
}

map * createMap (unsigned long capacity)
{
    logFF();

    if (capacity > s_maxCapacity)
    {
        logMsg (LOG_ERR, "%s%lu%s%lu\n", "Max capacity for the map is ", s_maxCapacity, " requested capacity is ", capacity);
        return NULL;
    }
    logMsg (LOG_DEBUG, "%s%lu\n", "Creating hashMap of size ", capacity);
    map *mp = malloc (sizeof(map));
    if (NULL == mp)
    {
        return NULL;
    }
    memset (mp, 0, sizeof(mp));
    mp->numSlots = capacity;
    mp->slots = malloc (mp->numSlots * sizeof(mapSlot));
    if (NULL == mp->slots)
    {
        myfree (mp);
        return NULL;
    }
    memset (mp->slots, 0, (mp->numSlots * sizeof(mapSlot)));
    return mp;
}

void deleteMap (map *mp)
{
    logFF();
    if (NULL == mp)
    {
        return;
    }

    /* Remove all slots and all entries in each slot */
    unsigned long slotCount = -1;
    while (++slotCount < mp->numSlots)
    {
        mapSlot *ms = mp->slots + slotCount;
        myfree (ms->entries);
    }
    myfree (mp->slots);
    myfree (mp);
}

char *getFromMap (map *mp, const char *key)
{
    logFF();
    if (NULL == mp || NULL == key)
    {
        return NULL;
    }

    unsigned long slot = (hashCode (key) % mp->numSlots);
    mapSlot *ms = mp->slots + slot;

    logMsg (LOG_DEBUG, "%s%s%s%p%s%lu%s%lu%s%lu\n", "Searching for key ", key,
        " in map ", mp, " of size ", mp->numSlots, " at slot ", slot,
        " with total entries ", ms->numEntries);

    unsigned long entryCount = -1;
    while (++entryCount < ms->numEntries)
    {
        slotEntry *se = ms->entries + entryCount;
        if (NULL != se && NULL != se->key)
        {
            logMsg (LOG_DEBUG, "%s%lu%s%s\n", "Key at entry ", entryCount,
                " is ", se->key);
            if (strcmp (se->key, key) == 0)
            {
                return se->value;
            }
        }
    }
    return NULL;
}

char * putInMap (map *mp, char *key, char *value)
{
    if (NULL == mp || NULL == key || NULL == value)
    {
        return NULL;
    }

    unsigned long slot = hashCode (key) % mp->numSlots;
    mapSlot *ms = mp->slots + slot;
    logMsg (LOG_DEBUG, "%s%s%s%s%s%p%s%lu%s%lu%s%lu\n", "Putting key ", key,
        " and value ", value, " in map ", mp, " of size ", mp->numSlots,
        " at slot ", slot, " with total entries ", ms->numEntries);

    unsigned long entryCount = -1;
    while (++entryCount < ms->numEntries)
    {
        slotEntry *se = ms->entries + entryCount;
        if (NULL != se && NULL != se->key)
        {
            logMsg (LOG_DEBUG, "%s%lu%s%s\n", "Key at entry ", entryCount,
                " is ", se->key);
            if (strcmp (se->key, key) == 0)
            {
                /* Match, replace existing value. Caller should free old value */
                logMsg (LOG_DEBUG, "%s%s%s\n", key,
                    " already exists in map with old value of ", se->value);
                se->value = value;
                return;
            }
        }
    }

    /* No matching entry, add new */
    ++ms->numEntries;
    ms->entries = realloc (ms->entries, (ms->numEntries) * sizeof(slotEntry));
    slotEntry *ne = ms->entries + (ms->numEntries - 1);
    ne->key = key;
    ne->value = value;

    logMsg (LOG_DEBUG, "%s%s%s%s%s%lu\n", "Added key ", key, " with value ",
        value, " at position ", ms->numEntries);
}
