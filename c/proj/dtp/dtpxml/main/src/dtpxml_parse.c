#include "dtpxml_hdr.h"
#include "dtpxml_proto.h"

#define MAX_FULLTAG_LEN 500

tagMetadata * findTagMetadata (userData *ud, char *tag)
{
    logFF ();

    if (NULL != ud->tagErrString)
    {
        logMsg (LOG_WARNING, "%s\n",
            "    Parser in error state, skipping further handling.");
        return NULL;
    }

    int counter = -1;
    char fromMeta[MAX_FULLTAG_LEN];
    char fromUd[MAX_FULLTAG_LEN];
    strcpy (fromUd, ud->curPath ? ud->curPath : "");
    strcat (fromUd, tag ? tag : "");
    while (xmltags[++counter].tag != NULL)
    {
        tagMetadata *tm = &xmltags[counter];
        strcpy (fromMeta, tm->parentPath ? tm->parentPath : "");
        strcat (fromMeta, tm->tag);
        /*logMsg (LOG_DEBUG, "%s%s%s%s\n", "    comparing from meta ", fromMeta,
         " with from ud ", fromUd);*/
        if (0 == strcmp (fromMeta, fromUd))
        {
            return tm;
        }
    }
    ud->tagErrString = malloc (sizeof(char) * 500);
    sprintf (ud->tagErrString, "%s%s%s%s\n", "Can not find tag ", tag,
        " at path ", ((ud->curPath) ? ud->curPath : "null"));
    logMsg (LOG_ERR, "%s\n", ud->tagErrString);
    return NULL;
}

void startTagCallback (void *udata, const xmlChar *name, const xmlChar **attrs)
{
    logFF ();

    char *tag = (char *) name;
    userData *ud = (userData *) udata;
    logMsg (LOG_INFO, "%s%s%s%s\n", "Start input tag ", tag, " at path ",
        ((ud->curPath) ? ud->curPath : "null"));

    /* Find the matching tag metadata */
    ud->curTm = findTagMetadata (ud, tag);
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
    ud->curTm = findTagMetadata (ud, NULL);
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

void logDetails (userData *ud)
{
    logMsg (LOG_INFO, "%s%s\n", "Error in tag ",
        (ud->tagErrString ? ud->tagErrString : "none"));
    logMsg (LOG_INFO, "%s%s\n", "Errors in data \n",
        (ud->dataErrString ? ud->dataErrString : "none"));

    if (NULL == ud->tagErrString && NULL == ud->dataErrString)
    {
        printOutput (ud->output);
    }
}

int parseXmlConfig (const char * const xmlFilePath, DiameterConfig_t *output)
{
    logFF();

    if (NULL == xmlFilePath || NULL == output)
    {
        logMsg (LOG_CRIT, "%s%s\n",
            "Null input xml config or output data holder");
        return -1;
    }

    userData ud;
    memset (&ud, 0, sizeof(ud));
    ud.output = output;
    memset (ud.output, 0, sizeof(ud.output));

    // Set approriate handlers
    xmlSAXHandler saxh;
    memset (&saxh, 0, sizeof(saxh));
    saxh.startElement = startTagCallback;
    saxh.endElement = endTagCallback;
    saxh.characters = dataCallback;

    xmlSAXUserParseFile (&saxh, &ud, xmlFilePath);
    logDetails (&ud);

    /* Free up memory */
    myfree (ud.curPath);
    myfree (ud.dataErrString);
    myfree (ud.tagErrString);

    if (NULL == ud.tagErrString && NULL == ud.dataErrString)
    {
        return 0;
    }
    return -1;
}
