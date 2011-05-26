#include "dtpmisc_hdr.h"
#include "dtpmisc_proto.h"

int main (int argc, char *argv[])
{
    DiameterConfig_t *output = malloc (sizeof(DiameterConfig_t));

    parseXmlConfig (argv[1], output);
}

