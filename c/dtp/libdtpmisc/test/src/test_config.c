#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"

const int dtpSuccess = 0;
const int dtpError = -1;

int main (int argc, char *argv[])
{
    parseXmlConfig (argv[1]);
}

