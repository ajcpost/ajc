#include "hdr.h"
#include "proto.h"

void myfree (void *p)
{
    if (NULL != p)
    {
        free (p);
    }
}

/* todo will require changes for windows */
const char * const filePathToName (const char * const filePath)
{
    if (NULL == filePath)
    {
        return NULL;
    }

    const char *p = filePath;
    char separator = '/';

    /* Go to the end */
    while (*p)
    {
        p++;
    }

    /* reverse till first separator or head */
    while (*p != separator)
    {
        p--;
        if (p == filePath)
        {
            break;
        }
    }
    return p;
}

/* Caller to free memory */
char * getTimeNoNewLine ()
{
    time_t cur_time;
    time (&cur_time);
    char *t = ctime (&cur_time);

    char *timeString = malloc (sizeof(*timeString) * (strlen (t) + 10));
    strcpy (timeString, "::");
    strcat (timeString, t);

    /*Replace the end newline with markers and a null*/
    char *p = timeString;
    while (*p++)
        ;
    p = p - 2;
    strcpy (p, ":: ");
    return timeString;
}

/* Caller to free memory */
char *getDate ()
{
    time_t t;
    struct tm *date;

    time (&t);
    date = localtime (&t);

    char *dateString = malloc (sizeof(*dateString) * 200);
    sprintf (dateString, "%s%s%s%s%s", date->tm_mday, "-", (date->tm_mon + 1),
            "-", (date->tm_year + 1900));
    return dateString;
}

const int getRandomNo (const int hwm)
{
    srand (time (NULL));
    return (rand () % hwm + 1);
}

void displayMemory(char *address, int length) {
        int i = 0; //used to keep track of line lengths
        char *line = (char*)address; //used to print char version of data
        unsigned char ch; // also used to print char version of data
        printf("%08X | ", (int)address); //Print the address we are pulling from
        while (length-- > 0) {
                printf("%02X ", (unsigned char)*address++); //Print each char
                if (!(++i % 16) || (length == 0 && i % 16)) { //If we come to the end of a line...
                        //If this is the last line, print some fillers.
                        if (length == 0) { while (i++ % 16) { printf("__ "); } }
                        printf("| ");
                        while (line < address) {  // Print the character version
                                ch = *line++;
                                printf("%c", (ch < 33 || ch == 255) ? 0x2E : ch);
                        }
                        // If we are not on the last line, prefix the next line with the address.
                        if (length > 0) { printf("\n%08X | ", (int)address); }
                }
        }
        puts("");
}

/*
 * Given a memory address, dump the contents in following format
 *
 * (memory location) | 16 Characters of Hex dump  | Corresponding  Ascii dump
 * 001005E0 | 48 65 6C 6C 6F __ __ __ __ __ __ __ __ __ __ __ | Hello
 */
void logMemoryData (char *address, int length)
{
    char *hexP = address;
    char *asciiP = address;
    unsigned char ch;
    char logBuf [500];
    char tmpBuf [50];

    int newLine = 1;
    int numChar = 0;
    while (length-- > 0)
    {
        if (newLine)
        {
            newLine = 0;
            memset (&logBuf, 0, sizeof(logBuf));
            sprintf (tmpBuf, "@%08X |", (int) hexP);
            strcpy (logBuf, tmpBuf);
        }
        sprintf (tmpBuf, "%02X ",(unsigned char) *hexP);
        strcat (logBuf, tmpBuf);
        hexP++;
        numChar++;
        if (!(numChar % 16) || ((length == 0) && numChar % 16))
        {
            if (length == 0)
            {
                while (numChar++ % 16)
                {
                    /* Filler */
                    sprintf (tmpBuf, "%s", "__");
                    strcat (logBuf, tmpBuf);
                }
            }
            sprintf (tmpBuf, "%s", "|");
            strcat (logBuf, tmpBuf);
            while (asciiP < hexP)
            {
                ch = *asciiP++;
                sprintf (tmpBuf, "%c", (ch < 33 || ch == 255) ? 0x2E : ch);
                strcat (logBuf, tmpBuf);
            }
            newLine = 1;
            logMsg (LOG_DEBUG, "%s\n", logBuf);
        }
    }
}

