#include "dtpsock_hdr.h"
#include "dtpsock_proto.h"

static SSL_CTX *s_ctx = NULL;
static int s_enableSSLClientAuth = 0;

static int verifyCallback (int preverify_ok, X509_STORE_CTX *ctx)
{
    return 1;
}

int ssl_init (const char * const certStore, const char * const certFile,
        const char * const keyFile, const int enableSSLClientAuth)
{
    logFF ();

    s_enableSSLClientAuth = enableSSLClientAuth;
    logMsg (LOG_INFO, "%s%s%s%s%s%s\n", "Initializing SSL with store: ",
            certStore, " cert file: ", certFile, " key file: ", keyFile);
    if (NULL != s_ctx)
    {
        logMsg (LOG_WARNING, "%s\n",
                "SSL already initialized, ignoring the call");
        return dtpSuccess;
    }

    SSL_METHOD *method;
    SSL_library_init ();
    OpenSSL_add_all_algorithms();
    SSL_load_error_strings ();
    method = TLSv1_method ();
    s_ctx = SSL_CTX_new (method);
    if (s_ctx == NULL)
    {
        logMsg (LOG_CRIT, "%s%s\n", "Failed to create SSL context, error is ",
                ERR_reason_error_string (ERR_get_error ()));
        return dtpError;
    }

    if (s_enableSSLClientAuth)
    {
        SSL_CTX_set_verify (s_ctx, SSL_VERIFY_PEER | SSL_VERIFY_CLIENT_ONCE,
                verifyCallback);
    }

    if (SSL_CTX_load_verify_locations (s_ctx, certStore, NULL) != 1)
    {
        logMsg (LOG_CRIT, "%s%s%s%s\n", "Failed to load trust store  ",
                certStore, " error is ", ERR_reason_error_string (
                        ERR_get_error ()));
        return dtpError;
    }

    if (SSL_CTX_use_certificate_file (s_ctx, certFile, SSL_FILETYPE_PEM) != 1)
    {
        logMsg (LOG_CRIT, "%s%s%s%s\n", "Failed to load certificate file ",
                certFile, " error is ", ERR_reason_error_string (
                        ERR_get_error ()));
        return dtpError;
    }
    if (SSL_CTX_use_PrivateKey_file (s_ctx, keyFile, SSL_FILETYPE_PEM) != 1)
    {
        logMsg (LOG_CRIT, "%s%s%s%s\n", "Failed to load key file ", keyFile,
                " error is", ERR_reason_error_string (ERR_get_error ()));
        return dtpError;
    }
    if (SSL_CTX_check_private_key (s_ctx) != 1)
    {
        logMsg (LOG_CRIT, "%s\n", "Key does not match public certificate");
        return dtpError;
    }

    logMsg (LOG_INFO, "%s\n", "SSL initialized");
    return dtpSuccess;
}

int ssl_validateCerts (SSL *ssl)
{
    logFF ();

    X509 *peerCert;

    if (SSL_get_verify_result (ssl) != X509_V_OK)
    {
        logMsg (LOG_CRIT, "%s%s\n", "Certificate invalid, error is ",
                ERR_reason_error_string (ERR_get_error ()));
        return dtpError;
    }
    peerCert = SSL_get_peer_certificate (ssl);
    if (NULL == peerCert)
    {
        logMsg (LOG_CRIT, "%s%s\n", "No peer certificate");
        return dtpError;
    }

    char *txt;
    logMsg (LOG_DEBUG, "%s\n", "Peer certificate details...");
    txt = X509_NAME_oneline (X509_get_subject_name (peerCert), 0, 0);
    logMsg (LOG_INFO, "%s%s\n", "Subject: ", txt);
    free (txt);
    txt = X509_NAME_oneline (X509_get_issuer_name (peerCert), 0, 0);
    logMsg (LOG_INFO, "%s%s\n", "Issuer: ", txt);
    free (txt);
    X509_free (peerCert);

    return dtpSuccess;
}

int ssl_doOnConnect (const dtpSockInfo * sockInfo)
{
    logFF ();

    sockInfo->sockData->ssl = SSL_new (s_ctx);
    SSL_set_fd (sockInfo->sockData->ssl, sockInfo->sockFd);
    if (SSL_connect (sockInfo->sockData->ssl) != 1)
    {
        logMsg (LOG_CRIT, "%s%s\n", "Can't do secure connect, error is ",
                ERR_reason_error_string (ERR_get_error ()));
        return dtpError;
    }
    return (ssl_validateCerts (sockInfo->sockData->ssl));
}
int ssl_doOnAccept (const dtpSockInfo * newSockInfo)
{
    logFF ();

    newSockInfo->sockData->ssl = SSL_new (s_ctx);
    SSL_set_fd (newSockInfo->sockData->ssl, newSockInfo->sockFd);
    if (SSL_accept (newSockInfo->sockData->ssl) != 1)
    {
        logMsg (LOG_CRIT, "%s%s\n", "Can't do secure accept, error is ",
                ERR_reason_error_string (ERR_get_error ()));
        return dtpError;
    }
    if (s_enableSSLClientAuth)
    {
        return (ssl_validateCerts (newSockInfo->sockData->ssl));
    }
    return dtpSuccess;
}
