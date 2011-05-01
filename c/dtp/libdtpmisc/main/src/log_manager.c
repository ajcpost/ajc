#include "misc_header.h"
#include "misc_proto.h"
#include "log_manager.h"

/* position must match with log levels defined in syslog */
static const char * const s_logLevels[] = { "emergency", "alert", "critical",
        "error", "warning", "notice", "info", "debug", NULL };

/* Min 1MB, Max 10MB, Default 5MB */
static int s_minLogSize = 1 * 1024 * 1024;
static int s_maxLogSize = 10 * 1024 * 1024;
static int s_defaultLogSize = 5 * 1024 * 1024;
static int s_supportRollover = 0;
static int s_logLevel = LOG_DEBUG;
static const char *s_logPath = NULL;
static FILE *s_logFP = NULL;
static int s_logSize;
static int s_useSyslog = 0;
static int s_syslogFacility = 1;

void logMsg (const int msgLevel, const char * const format, ...)
{
    va_list args;
    char *timeString = getTimeNoNewLine ();

    if (msgLevel < 0 || msgLevel > s_logLevel)
    {
        return;
    }

    va_start (args, format);
    FILE *fp;
    switch (s_useSyslog)
    {
    case 0:
        fp = (NULL == s_logFP) ? stderr : s_logFP;
        fprintf (fp, "%s", timeString);
        myfree (timeString);

        const char * const level = s_logLevels[msgLevel];
        fprintf (fp, "_%s_ ", level);
        vfprintf (fp, format, args);
        fflush (fp);

        /* Roll the log, if necessary */
        if (NULL != s_logPath && 0 != s_supportRollover)
        {
            struct stat st;
            unsigned int fileSize;

            stat (s_logPath, &st);
            fileSize = st.st_size;
            if (fileSize >= s_logSize)
            {
                fclose (s_logFP);
                char *bakLogPath = getBakLogPath (s_logPath);
                rename (s_logPath, bakLogPath);
                createLog (s_logPath, s_logLevels[s_logLevel], s_logSize,
                        s_supportRollover);
                myfree (bakLogPath);
            }
        }
        break;
    case 1:
        vsyslog (msgLevel, format, args); /* todo use mapping */
        break;
    default:
        /* should not happen, do nothing */
        break;
    }
    va_end (args);
}

void useSyslog (int facility)
{
    s_useSyslog = 1;
    s_syslogFacility = facility;
}

void createLog (const char * const logPath, const char * const logLevel,
        const int size, const int rollOver)
{
    logFF();
    if (NULL != logPath)
    {
        if (NULL != s_logFP)
        {
            logMsg (LOG_WARNING, "%s\n",
                    "Log is already created, closing old log");
            fclose (s_logFP);
        }

        s_logPath = (char *) logPath;
        s_logFP = fopen (s_logPath, "a+");
        if (NULL == s_logFP)
        {
            logMsg (LOG_NOTICE, "%s%s%s\n", "Can't open log file ", s_logPath,
                    ", Logs will be sent to stderr.");
            s_logPath = NULL;
        }
    }

    s_logSize = size;
    if (size < s_minLogSize || size > s_maxLogSize)
    {
        logMsg (LOG_NOTICE, "%s%d%s%d\n", "Incorrect logSize value (", size,
                ") supplied, using default value of ", s_defaultLogSize);
        s_logSize = s_defaultLogSize;
    }
    s_supportRollover = rollOver;
    if (rollOver != 0 && rollOver != 1)
    {
        logMsg (LOG_NOTICE, "%s%d%s\n", "Incorrect rollOver value (", rollOver,
                ") supplied; logs will not be rolled");
        s_supportRollover = 0;
    }

    setLogLevel (logLevel);
    return;
}

static void setLogLevel (const char * const level)
{
    logFF();

    if (NULL == level)
    {
        logMsg (LOG_NOTICE, "%s%s\n",
                "Log level is not set. Using current log level of ",
                s_logLevels[s_logLevel]);
        return;
    }

    int i = -1;
    while (NULL != s_logLevels[++i])
    {
        if (0 == strcmp (level, s_logLevels[i]))
        {
            s_logLevel = i;
            logMsg (LOG_NOTICE, "%s%s\n", "Property log level set to ",
                    s_logLevels[s_logLevel]);
            return;
        }
    }
}

/* Caller to free memory */
static char *getBakLogPath (const char * const logPath)
{
    char *today = getDate ();
    char *bakLogPath = malloc (sizeof (*bakLogPath) * (strlen (logPath) + 1 + strlen (today) + 1));
    strcpy (bakLogPath, logPath);
    strcpy (bakLogPath, ".");
    strcpy (bakLogPath, today);
    myfree (today);
    return bakLogPath;
}
