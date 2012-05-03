#include "core_hdr.h"
#include "core_proto.h"
#include "core_hashMap.h"

int main (void)
{
    map *mp = createMap (2);

    int i = 0;
    char *buf;
    for (i = 0; i < 10; i++)
    {
        buf = malloc (50);
        sprintf (buf, "%s%d", "key", i);
        putInMap (mp, buf, buf);

    }
    for (i = 0; i < 10; i++)
    {
        buf = malloc (50);
        sprintf (buf, "%s%d", "key", i);
        printf ("%s%s%s\n", buf, " is ", getFromMap (mp, buf));
    }
}
