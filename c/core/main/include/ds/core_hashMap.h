#ifndef CORE_HASHMAP_H_
#define CORE_HASHMAP_H_

typedef struct slotEntry {
    char *key;
    char *value;
}slotEntry;

typedef struct mapSlot {
    unsigned long numEntries;
    slotEntry *entries;
}mapSlot;

typedef struct map {
    unsigned long numSlots;
    mapSlot *slots;
}map;

#endif /* CORE_HASHMAP_H_ */

