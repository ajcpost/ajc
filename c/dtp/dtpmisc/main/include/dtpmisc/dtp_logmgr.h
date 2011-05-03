#ifndef DTP_LOGMGR_H_
#define DTP_LOGMGR_H_

#include <syslog.h>
#define logFF() logMsg (LOG_DEBUG, "%s%s%s\n",  __FUNCTION__, " in file ", filePathToName (__FILE__))

#endif /* DTP_LOGMGR_H_ */
