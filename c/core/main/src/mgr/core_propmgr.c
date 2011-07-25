#include "core_hdr.h"
#include "core_proto.h"


/* Hashmap of property key and values */
static map *s_properties = NULL;
static int s_maxNumProperties = 1000;
static const int s_propertyMaxSize = 1024;
static const char * const s_propertyDelimiter = "=\n";

const char * const getPropertyValue (const char * const propertyName)
{
    logFF();

    if (NULL == s_properties)
    {
        logMsg (LOG_ERR, "%s\n", "Properties are not initialized yet");
        return NULL;
    }
    return (getFromMap(s_properties, propertyName));
}

int loadPropertiesFromFile (const char * const propertyFile, const int expectedNumProperties)
{
    logFF ();

    if (expectedNumProperties > s_maxNumProperties)
    {
        logMsg (LOG_ERR, "%s%d%s\n", "Can't load more than ", s_maxNumProperties, " properties");
        return -1;

    }
    FILE *fp = fopen (propertyFile, "r");
    if (NULL == fp)
    {
        logMsg (LOG_ERR, "%s%s\n", "Could not open property file ",
            filePathToName (propertyFile));
        return -1;
    }

    /* Initialize the map to hold values */
    s_properties = createMap (expectedNumProperties*2);

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
        if (lineCount > (expectedNumProperties * 10))
        {
            logMsg (LOG_CRIT, "%s%s%s%d\n",
                "Too many properties in the property file ", filePathToName (
                    propertyFile), " expect only ", expectedNumProperties);
            deleteMap(s_properties);
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
            char *prop = malloc (strlen(property)+1);
            strcpy (prop, property);
            char *val = malloc (strlen(value)+1);
            strcpy (val, value);
            putInMap (s_properties, prop, val);
        }
        fgets (readLine, s_propertyMaxSize, fp);
    }

    fclose (fp);
    return (0);
}
