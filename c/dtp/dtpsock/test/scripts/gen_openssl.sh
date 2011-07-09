#!/bin/sh

openssl genrsa -out /tmp/clientKey.pem 2048
openssl req -new -x509 -key /tmp/clientKey.pem -out /tmp/clientCert.pem -days 1095

openssl genrsa -out /tmp/serverKey.pem 2048
openssl req -new -x509 -key /tmp/serverKey.pem -out /tmp/serverCert.pem -days 1095
