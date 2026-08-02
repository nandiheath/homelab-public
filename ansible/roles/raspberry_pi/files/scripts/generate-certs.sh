#!/bin/bash

# Usage: ./generate-certs.sh
# Generates intermediate CA and k3s certs using an existing root CA.

set -euo pipefail

CERT_DIR="credentials/certs"
ROOT_CA_DIR="$CERT_DIR/root-ca"
INTERMEDIATE_DIR="$CERT_DIR/intermediate"
K3S_DIR="$CERT_DIR/k3s"

INTERMEDIATE_KEY="$INTERMEDIATE_DIR/key.pem"
INTERMEDIATE_CERT="$INTERMEDIATE_DIR/cert.pem"
INTERMEDIATE_CSR="$INTERMEDIATE_DIR/cert.csr"
OPENSSL_CNF="$INTERMEDIATE_DIR/openssl.cnf"

# Check for root CA
if [[ ! -d "$ROOT_CA_DIR" ]] || [[ ! -f "$ROOT_CA_DIR/cert.pem" ]] || [[ ! -f "$ROOT_CA_DIR/key.pem" ]]; then
  echo "Error: Root CA directory or files missing in $ROOT_CA_DIR"
  exit 1
fi

# Generate intermediate CA if not exists
if [[ ! -f "$INTERMEDIATE_CERT" ]]; then
  echo 
  echo "Generating private key and CSR for intermediate CA..."
  openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -sha256 \
    -subj "/C=CA/ST=Toronto/L=Springfield/O=Nandi/CN=nandi.sh" \
    -keyout "$INTERMEDIATE_KEY" \
    -out "$INTERMEDIATE_CSR"

  touch "$INTERMEDIATE_DIR/index.txt"
  echo '01' > "$INTERMEDIATE_DIR/serial.txt"

  openssl req -text -noout -verify -in "$INTERMEDIATE_CSR"

  # Minimal OpenSSL config for signing
  cat > "$OPENSSL_CNF" <<EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir               = $INTERMEDIATE_DIR
database          = \$dir/index.txt
serial            = \$dir/serial.txt
default_md        = sha256
policy            = signing_policy
new_certs_dir     = $CERT_DIR/intermediate              # Location for new certs after signing

default_days      = 365          # How long to certify for

[ signing_policy ]
commonName        = supplied

[ signing_req ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
EOF

  echo "Signing intermediate CSR with root CA..."
  openssl ca -create_serial \
    -config "$OPENSSL_CNF" \
    -policy signing_policy \
    -extensions signing_req \
    -cert "$ROOT_CA_DIR/cert.pem" \
    -keyfile "$ROOT_CA_DIR/key.pem" \
    -in "$INTERMEDIATE_CSR" \
    -out "$INTERMEDIATE_CERT" \
    -batch

  openssl x509 -purpose -in "$INTERMEDIATE_CERT" -text -noout
else
  echo "Intermediate CA already exists at $INTERMEDIATE_DIR. Skipping generation."
fi

# TODO: generate and rotate k3s certs
# Generate k3s certs if not exists
#if [[ ! -d "$K3S_DIR" ]]; then
#  echo "Generating certs for k3s..."
#  mkdir -p "$K3S_DIR"
#  cp "$ROOT_CA_DIR/cert.pem" "$INTERMEDIATE_KEY" "$INTERMEDIATE_CERT" "$K3S_DIR"
#
#  curl -sL https://github.com/k3s-io/k3s/raw/master/contrib/util/generate-custom-ca-certs.sh | DATA_DIR="$K3S_DIR" bash -
#  sudo rm -rf /var/lib/rancher
#else
#  echo "k3s certs already exist at $K3S_DIR. Skipping generation."
#fi