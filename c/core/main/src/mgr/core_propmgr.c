#include "core_hdr.h"
#include "core_proto.h"

/* Must be in sync with s_propertyNames/propertyValues below */
const char * const propServerLogFilePath = "serverLogFilePath";
const char * const propServerMaxLogSize = "serverMaxLogSize";
const char * const propServerLogLevel = "serverLogLevel";
const char * const propClientLogFilePath = "clientLogFilePath";
const char * const propClientMaxLogSize = "clientMaxLogSize";
const char * const propClientLogLevel = "clientLogLevel";
const char * const propAfamily = "afamily";
const char * const propIPv6Only = "ipv6Only";
const char * const propProtocol = "protocol";
const char * const propBlocking = "blocking";
const char * const propMaxPduSize = "maxPduSize";
const char * const propServerSocketQLen = "serverSocketQLen";
const char * const propClientSharedPort = "clientSharedPort";
const char * const propClientBindAddr = "clientBindAddr";
const char * const propServerSharedPort = "serverSharedPort";
const char * const propServerBindAddr = "serverBindAddr";
const char * const propClientConnectAddr = "clientConnectAddr";
const char * const propTransferDataSize = "transferDataSize";
const char * const propEnableSsl = "enableSsl";
const char * const propEnableSslClientAuth = "enableSslClientAuth";
const char * const propClientKeyFile = "clientKeyFile";
const char * const propClientCertFile = "clientCertFile";
const char * const propClientCertStore = "clientCertStore";
const char * const propServerKeyFile = "serverKeyFile";
const char * const propServerCertFile = "serverCertFile";
const char * const propServerCertStore = "serverCertStore";

/* All expected properties and corresponding value holder */
static const char
    * const s_propertyNames[] =
        { "serverLogFilePath", "serverMaxLogSize", "serverLogLevel", "clientLogFilePath",
            "clientMaxLogSize", "clientLogLevel", "afamily", "ipv6Only", "protocol", "blocking",
            "maxPduSize", "serverSocketQLen", "clientSharedPort", "clientBindAddr", "serverSharedPort",
            "serverBindAddr", "clientConnectAddr", "transferDataSize", "enableSsl", "enableSslClientAuth",
            "clientKeyFile", "clientCertFile", "clientCertStore","serverKeyFile", "serverCertFile",
            "serverCertStore",NULL };
char **propertyValues;

static int s_propertiesInitialized = 0;
static const int s_propertyMaxSize = 1024;
static const char * const s_propertyDelimiter = "=\n";

const char * const getPropertyValue (const char * const propertyName)
{
    logFF();

    if (0 == s_propertiesInitialized)
    {
        logMsg (LOG_ERR, "%s\n", "Properties are not initialized yet");
        return NULL;
    }
    if (NULL == propertyName)
    {
        logMsg (LOG_WARNING, "%s\n", "No values stored for a NULL property");
        return NULL;
    }

    char *value = NULL;
    int i = -1;
    while (NULL != s_propertyNames[++i])
    {
        if (0 == strcmp (propertyName, s_propertyNames[i]))
        {
            value = propertyValues[i];
            break;
        }
    }
    logMsg (LOG_DEBUG, "%s%s%s%s\n", "Input property ", propertyName,
        " is set to ", ((!value) ? "null" : value));
    return value;
}

int loadPropertiesFromFile (const char * const propertyFile)
{
    logFF ();

    FILE *fp = fopen (propertyFile, "r");
    if (NULL == fp)
    {
        logMsg (LOG_ERR, "%s%s\n", "Could not open property file ",
            filePathToName (propertyFile));
        return -1;
    }

    /* Initialize the array to hold values */
    int expectedPropertyCount = getNoOfProperties ();
    propertyValues = malloc (sizeof(*propertyValues) * expectedPropertyCount);
    memset (propertyValues, 0,
        (sizeof(*propertyValues) * expectedPropertyCount));

    char readLine[s_propertyMaxSize];
    int lineCount = 0;
    fgets (readLine, s_propertyMaxSize, fp);
    while (!feof (fp))
    {
        ++lineCount;
        if ('#' == *readLine)
        {
            /* Ignore comments */
            fgets (readLine, s_propertyMaxSize, fp);
            continue;
        }
        /* If processing continues for more than 10 times (allows for comments) expected noOfProperties, halt */
        if (lineCount > (expectedPropertyCount * 10))
        {
            logMsg (LOG_CRIT, "%s%s%s%d\n",
                "Too many properties in the property file ", filePathToName (
                    propertyFile), " expect only ", expectedPropertyCount);
            fclose (fp);
            return -1;
        }

        char *property = strtok (readLine, s_propertyDelimiter);
        char *value = strtok (NULL, s_propertyDelimiter);
        logMsg (LOG_DEBUG, "%s%d%s%s%s%s\n", "Line number ", lineCount,
            ", Input property is ", property, ", value is ",
            ((!value) ? "null" : value));

        if (NULL != property && NULL != value)
        {
            int i = -1;
            while (NULL != s_propertyNames[++i])
            {
                if (0 == strcmp (s_propertyNames[i], property))
                {
                    if (NULL != propertyValues[i])
                    {
                        /* Property is repeated. Warn and pick the latest */
                        logMsg (LOG_WARNING, "%s%s%s\n", "Input property ",
                            property, " is repeated, ignoring previous value");
                        myfree (propertyValues[i]);
                    }
                    propertyValues[i] = malloc (sizeof(**propertyValues)
                        * (strlen (value) + 1));
                    strcpy (propertyValues[i], value);
                    break;
                }
            }
        }
        fgets (readLine, s_propertyMaxSize, fp);
    }

    s_propertiesInitialized = 1;
    fclose (fp);
    return (checkProperties ());
}

static int getNoOfProperties ()
{
    logFF();

    int i = -1;
    while (NULL != s_propertyNames[++i])
    {
        ;
    }
    logMsg (LOG_DEBUG, "%s%d\n", "Expected number of properties: ", i);
    return i;
}

static int checkProperties ()
{
    logFF();

    int allSet = 0;
    int i = -1;
    while (NULL != s_propertyNames[++i])
    {
        if (NULL == propertyValues[i])
        {
            logMsg (LOG_ERR, "%s%s%s\n", "Property ", s_propertyNames[i],
                " is not set");
            allSet = -1;
        }
    }
    return allSet;
}

static void logPropertyValues ()
{
    logFF();

    char logLine[s_propertyMaxSize * 2];
    strcpy (logLine, "Input property values are:");
    logMsg (LOG_NOTICE, "%s\n", logLine);
    int i = -1;
    while (NULL != s_propertyNames[++i])
    {
        strcpy (logLine, "Property ");
        strcat (logLine, s_propertyNames[i]);
        strcat (logLine, " has value ");
        char * val = ((!propertyValues[i]) ? "null" : propertyValues[i]);
        strcat (logLine, val);
        logMsg (LOG_NOTICE, "%s\n", logLine);
    }
}
