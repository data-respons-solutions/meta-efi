#!/bin/bash

KEY_NAME=${1}
COMMON_NAME=${2}

openssl req -new -x509 -newkey rsa:2048 -subj "/CN=${COMMON_NAME}/" -keyout ${KEY_NAME}.key -out ${KEY_NAME}.crt -nodes -sha256
openssl x509 -in ${KEY_NAME}.crt -out ${KEY_NAME}.cer -outform DER