#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"

void startTagCallback (void *udata, const xmlChar *name,
    const xmlChar **attrs)
{
    logFF ();

    char *tag = (char *) name;
    userData *ud = (userData *) udata;
    logMsg (LOG_INFO, "%s%s%s%s\n", "Start input tag ", tag, " at path ",
        ((ud->curPath) ? ud->curPath : "null"));

    /* Find the matching tag metadata */
    ud->curTm = getTagMetadata (ud, tag);
    if (NULL == ud->curTm)
    {
        return;
    }

    /* Adjust the path to reflect the current hierarchy */
    int curLen = ((ud->curPath) ? strlen (ud->curPath) : 0);
    int incrementalLen = strlen (tag);
    ud->curPath = realloc (ud->curPath, curLen + incrementalLen + 1);
    strcpy (ud->curPath + curLen, tag);
    logMsg (LOG_DEBUG, "%s%s\n", "    Adjusted path ",
        ((ud->curPath) ? ud->curPath : "null"));

    /* Call the handler */
    if (NULL != ud->curTm->handleStartTagFunc)
    {
        ud->curTm->handleStartTagFunc (ud);
    }
}

void endTagCallback (void *udata, const xmlChar *name)
{
    logFF ();

    char *tag = (char *) name;
    userData *ud = (userData *) udata;
    logMsg (LOG_INFO, "%s%s%s%s\n", "End input tag ", tag, " at path ",
        ((ud->curPath) ? ud->curPath : "null"));

    /* Find the matching tag metadata, don't pass tag since it's already part of curPath */
    ud->curTm = getTagMetadata (ud, NULL);
    if (NULL == ud->curTm)
    {
        return;
    }

    /*
     * Adjust the path to reflect the current hierarchy.
     * Don't realloc but rather null terminate at appropriate position. The memory will eventually be
     * freed at the end of XML parsing.
     * */
    int curLen = ((ud->curPath) ? strlen (ud->curPath) : 0);
    int incrementalLen = strlen (tag);
    if (curLen >= incrementalLen)
    {
        *(ud->curPath + curLen - incrementalLen) = '\0';
    }
    logMsg (LOG_DEBUG, "%s%s\n", "    Adjusted path ",
        ((ud->curPath) ? ud->curPath : "null"));

    /* Call the handler */
    if (NULL != ud->curTm->handleEndTagFunc)
    {
        ud->curTm->handleEndTagFunc (ud);
    }
}

void dataCallback (void *udata, const xmlChar *ch, int len)
{
    logFF ();

    userData *ud = (userData *) udata;
    logMsg (LOG_DEBUG, "%s%s\n", "    Data callback at path ",
        ((ud->curPath) ? ud->curPath : "null"));

    if (NULL != ud->curTm && NULL != ud->curTm->handleDataFunc)
    {
        char *data = copyData (ch, len);
        logMsg (LOG_DEBUG, "%s%s\n", "    Data is ", (data ? data : "null"));
        if (NULL != data)
        {
            ud->curTm->handleDataFunc (ud, data);
            myfree (data);
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

    // ignore new lines or all whitespaces
    if (allSpace)
    {
        logMsg (LOG_WARNING, "%s\n",
            "    Data has only whitespace or newline, skipping");
        myfree (data);
        return NULL;
    }
    return data;
}
