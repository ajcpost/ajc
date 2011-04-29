#include "config_header.h"
#include "config_proto.h"
#include "config_extern.h"
#include "log_manager.h"

void startElementCallback (void *udata, const xmlChar *name,
                           const xmlChar **attrs)
{
    logFF ();
    logMsg (LOG_DEBUG, "Tag: %s\n", name);
    userData *ud = (userData *) udata;
    tagEntry *te = getTagEntry (ud, (char *) name);
    if (NULL != te)
    {
        ud->te = te;
        /*logMsg (LOG_DEBUG, "%s%s\n", "State changed to ", ud->te->moveForwardState);*/
        return;
    }
}

void endElementCallback (void *udata, const xmlChar *name)
{
    logFF ();

    userData *ud = (userData *) udata;
    /* todo */
}

void startDataCallback (void *udata, const xmlChar *ch, int len)
{
    logFF ();

    userData *ud = (userData *) udata;
    /*if (ud->te->ignore)
    {
        return;
    }*/
    // ignore new lines or whitespaces, todo

    if (NULL != ud->te->handleData)
    {
        char *data = copyData (ch, len);
        logMsg (LOG_DEBUG, "%s%s\n", "Data ", data);
        ud->te->handleData (ud->output, data);
    }
}

char *copyData (const xmlChar *ch, const int len)
{
    logFF();

    char *data = malloc (sizeof(char) * (len + 1));
    char *p = data;
    int i = 0;
    for (i = 0; i < len; i++)
    {
        *p++ = *ch++;
    }
    *p = '\0';
    return data;
}
