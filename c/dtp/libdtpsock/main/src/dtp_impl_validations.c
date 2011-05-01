#include "dtp_header.h"
#include "dtp_proto.h"


int val_checkProtocol (const int protocol)
{
    logFF();
    switch (protocol)
    {
    case IPPROTO_TCP:
        break;
    case IPPROTO_SCTP:
        break;
    default:
        logMsg (LOG_CRIT, "%s%d\n", "Invalid value for protocol ", protocol);
        return dtpError;
        break;
    }
    return dtpSuccess;
}

int val_checkAfamily (const int afamily)
{
    logFF();
    switch (afamily)
    {
    case AF_INET:
        break;
    case AF_INET6:
        break;
    default:
        logMsg (LOG_CRIT, "%s%d\n", "Invalid value for afamily ", afamily);
        return dtpError;
        break;
    }
    return dtpSuccess;
}
int val_checkInt (const int value, const char * const name, const int min,
        const int max)
{
    logFF();
    if (value > max || value < min)
    {
        logMsg (LOG_CRIT, "%s%d\n", "Invalid value ", value, " for ", name);
        return dtpError;
    }
    return dtpSuccess;
}
