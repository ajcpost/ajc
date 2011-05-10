#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"

void startElementCallback (void *udata, const xmlChar *name,
    const xmlChar **attrs)
{
    logFF ();

    char *tag = (char *) name;
    userData *ud = (userData *) udata;
    if (ud->error)
    {
        logMsg (LOG_WARNING, "%s\n",
            "Parser in error state, skipping further handling.");
        return;
    }
    logMsg (LOG_INFO, "%s%s%s%s\n", "Start input tag ", tag, " at fdn ",
        ((ud->fdn) ? ud->fdn : "null"));

    ud->tm = getTagMetadata (ud, tag);
    if (NULL != ud->tm)
    {
        if (ud->tm->ignoreTag)
        {
            logMsg (LOG_DEBUG, "%s\n", "    Ignoring the tag");
            return;
        }

        /* The fdn in user_data is to be adjusted in start/end calls */
        int totallen = ((ud->fdn) ? strlen (ud->fdn) : 0) + (strlen (tag) + 1);
        char *fdn = malloc (sizeof(char) * totallen);
        strcpy (fdn, ((ud->fdn) ? (ud->fdn) : ""));
        strcat (fdn, tag);
        myfree (ud->fdn);
        ud->fdn = fdn;
        if (NULL != ud->tm->handleTagFunc)
        {
            ud->tm->handleTagFunc (ud->output);
        }
    }
}

void endElementCallback (void *udata, const xmlChar *name)
{
    logFF ();

    char *tag = (char *) name;
    userData *ud = (userData *) udata;
    if (ud->error)
    {
        logMsg (LOG_WARNING, "%s\n",
            "Parser in error state, skipping further handling.");
        return;
    }
    logMsg (LOG_INFO, "%s%s%s%s\n", "End input tag ", tag, " at fdn ",
        ((ud->fdn) ? ud->fdn : "null"));

    ud->tm = NULL;

    /* The fdn in user_data is to be adjusted in start/end calls */
    if (endTagMismatch (ud, tag))
    {
        return;
    }
    logMsg (LOG_DEBUG, "%s%s%s%s\n", "    Adjusting fdn ", ud->fdn,
        " to remove tag ", tag);
    if (0 == strcmp (ud->fdn, tag))
    {
        myfree (ud->fdn);
        ud->fdn = NULL;
    }
    else
    {
        int cutAt = strlen (ud->fdn) - strlen (tag);
        char *p = malloc ( sizeof(char) *(cutAt + 1));
        strncpy (p, ud->fdn, cutAt);
        *(p+cutAt) = '\0';
        myfree (ud->fdn);
        ud->fdn = p;
    }
    logMsg (LOG_DEBUG, "%s%s\n", "    Adjusted fdn ",
        ((ud->fdn) ? ud->fdn : "null"));

}

void startDataCallback (void *udata, const xmlChar *ch, int len)
{
    logFF ();

    userData *ud = (userData *) udata;
    if (ud->error)
    {
        logMsg (LOG_WARNING, "%s\n",
            "Parser in error state, skipping further handling.");
        return;
    }
    logMsg (LOG_DEBUG, "%s%s\n", "    Data callback at fdn ",
        ((ud->fdn) ? ud->fdn : "null"));

    if (NULL == ud->tm || ud->tm->ignoreData)
    {
        logMsg (LOG_DEBUG, "%s\n", "    Ignoring the data");
        return;
    }

    if (NULL != ud->tm->handleDataFunc)
    {
        char *data = copyData (ch, len);
        if (NULL != data)
        {
            logMsg (LOG_DEBUG, "%s%s\n", "    Data ", data);
            if (0 == ud->tm->handleDataFunc (ud->output, data))
            {
                ud->tm->dataProcessed = 1;
            }
        }
    }
}

int endTagMismatch (userData *ud, char *tag)
{
    if (NULL == ud->fdn || (strlen (ud->fdn) < strlen (tag)))
    {
        logMsg (LOG_WARNING, "%s%s%s%s\n", "Null or incorrect fdn ",
            ((ud->fdn) ? ud->fdn : "null"), " can't remove ", tag);
        return 1;
    }
    char *p1 = ud->fdn + strlen (ud->fdn);
    char *p2 = (p1 - strlen (tag));
    if (0 != strcmp (p2, tag))
    {
        logMsg (LOG_WARNING, "%s%s%s%s\n", " fdn ", ud->fdn,
            " doesn't end with tag ", tag);
        return 1;
    }
    return 0;
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
        logMsg (LOG_WARNING, "%s\n",
            "    Data has only whitespace or newline, skipping");
        myfree (data);
        return NULL;
    }
    return data;
}
