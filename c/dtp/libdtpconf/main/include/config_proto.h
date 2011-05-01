/* src/config/callbacks.c */
void startElementCallback (void *udata, const xmlChar *name,
                           const xmlChar **attrs);
void endElementCallback (void *udata, const xmlChar *name);
void startDataCallback (void *udata, const xmlChar *ch, int len);
int endTagMismatch (userData *ud, char *tag);
char *copyData (const xmlChar *ch, const int len);

/* src/config/main.c */
int main (int argc, char *argv[]);

/* src/config/output.c */
int validateProductName (DiameterConfig_t *output, const char *value);
void addProductName (DiameterConfig_t *output, const char *value);
int validateSupportedVendorId (DiameterConfig_t *output, const char *value);
void addSupportedVendorId (DiameterConfig_t *output, const char *value);

/* src/config/parse.c */
tagMetadata * getTagMetadata (userData *ud, char *tag);
int parseXmlConfig (const char * const xmlFilePath);

