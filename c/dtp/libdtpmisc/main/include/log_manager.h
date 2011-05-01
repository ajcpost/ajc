#ifndef LOGMANAGER_H_
#define LOGMANAGER_H_

#include <syslog.h>
#define logFF() logMsg (LOG_DEBUG, "%s%s%s\n",  __FUNCTION__, " in file ", filePathToName (__FILE__))

#endif /* LOGMANAGER_H_ */
