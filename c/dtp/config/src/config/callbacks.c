#include "config_header.h"
#include "config_proto.h"
#include "config_extern.h"
#include "log_manager.h"

void startElementCallback (void *udata, const xmlChar *name,
                           const xmlChar **attrs)
{
    logFF ();

    userData *ud = (userData *) udata;
    char *tag = (char *) name;
    logMsg (LOG_DEBUG, "%s%s%s%s\n", "Start input tag ", tag, " at fdn ",
            ((ud->fdn) ? ud->fdn : "null"));

    tagHandle *th = getTagHandle (ud, tag);
    ud->th = th;
    if (NULL == th)
    {
        /* Will happen in error case, return; */
        return;
    }
    if (th->ignoreTag)
    {
        logMsg (LOG_DEBUG, "%s\n", "Ignoring the tag");
        return;
    }

    /* The fdn in user_data is to be adjusted in start/end calls */
    if (NULL == ud->fdn)
    {
        ud->fdn = malloc (sizeof(char) * (strlen (tag) + 1));
        strcpy (ud->fdn, tag);
    }
    else
    {
        ud->fdn = realloc (ud->fdn, strlen (ud->fdn) + strlen (tag) + 1);
        strcat (ud->fdn, tag);
    }
}

void endElementCallback (void *udata, const xmlChar *name)
{
    logFF ();
    userData *ud = (userData *) udata;
    char *tag = (char *) name;

    if (NULL == ud->fdn || (strlen (ud->fdn) < strlen (tag)))
    {
        logMsg (LOG_DEBUG, "%s%s%s%s\n", "Null or incorrect fdn ",
                ((ud->fdn) ? ud->fdn : "null"), " can't adjust ", tag);
        return;
    }
    char *p1 = ud->fdn + strlen (ud->fdn);
    char *p2 = (p1 - strlen (tag));
    if (0 != strcmp (p2, tag))
    {
        logMsg (LOG_DEBUG, "%s%s%s%s\n", " fdn ", ud->fdn,
                " doesn't have tag ", tag);
        return;
    }

    /* The fdn in user_data is to be adjusted in start/end calls */
    logMsg (LOG_DEBUG, "%s%s%s%s\n", "Adjusting fdn ", ud->fdn,
            " to remove tag ", tag);
    char *p = malloc (strlen (ud->fdn) - strlen (tag) + 1);
    strncpy (p, ud->fdn, (strlen (ud->fdn) - strlen (tag)));
    myfree (ud->fdn);
    ud->fdn = p;
    logMsg (LOG_DEBUG, "%s%s%s%s\n", "End input tag ", tag, " at fdn ",
            ((ud->fdn) ? ud->fdn : "null"));

    ud->th = NULL;
}

void startDataCallback (void *udata, const xmlChar *ch, int len)
{
    logFF ();

    userData *ud = (userData *) udata;
    if (NULL == ud->th || ud->th->ignoreData)
    {
        logMsg (LOG_DEBUG, "%s\n", "Ignoring the data");
        return;
    }

    if (NULL != ud->th->handleData)
    {
        char *data = copyData (ch, len);
        if (NULL != data)
        {
            logMsg (LOG_DEBUG, "%s%s\n", "Data ", data);
            ud->th->handleData (ud->output, data);
        }
    }
}

char *copyData (const xmlChar *ch, const int len)
{
    logFF();
    int allSpace = 1;

    char *data = malloc (sizeof(char) * (len + 1));
    char *p = data;
    int i = 0;
    for (i = 0; i < len; i++)
    {
        if (*ch != ' ' && *ch != '\n')
        {
            allSpace = 0;
        }
        *p++ = *ch++;
    }
    *p = '\0';

    // ignore new lines or all whithspaces
    if (allSpace)
    {
        logMsg (LOG_DEBUG, "%s\n",
                "Data has only whitespace or newline, skipping");
        myfree (data);
        return NULL;
    }
    return data;
}
