#include "dtpxml_hdr.h"
#include "dtpxml_proto.h"

int main (int argc, char *argv[])
{
    DiameterConfig_t *output = malloc (sizeof(DiameterConfig_t));

    parseXmlConfig (argv[1], output);
}

