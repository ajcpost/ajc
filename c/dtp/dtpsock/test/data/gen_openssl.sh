#!/bin/sh

openssl genrsa -out /tmp/key.pem 2048
openssl req -new -x509 -key /tmp/key.pem -out /tmp/cert.pem -days 1095
