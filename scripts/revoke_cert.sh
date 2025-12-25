#!/bin/bash
set -euo pipefail

LOG="/var/log/ca/revoke_cert.log"
CA_DIR="/etc/pki/pki"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }
error_exit() { log "ERROR: $1" >&2; exit 1; }

CERT_FILE="${1:?Сертификат обязателен}"
[ "$EUID" -ne 0 ] && error_exit "Запуск от root"
[ ! -f "$CERT_FILE" ] && error_exit "Сертификат не найден"
[ ! -f "$CA_DIR/private/ca.key" ] && error_exit "Root CA не инициализирован"

log "🚀 Отзыв сертификата БЕЗ пароля: $CERT_FILE"

cd /etc/pki
expect -c "
    spawn easy-rsa revoke \"$CERT_FILE\"
    expect {
        \"Enter pass phrase\" { send \"\r\"; exp_continue }
        \"Revoke anyway?\" { send \"yes\r\" }
        eof
"
easy-rsa gen-crl

log "✅ Сертификат отозван"
log "✅ CRL: $CA_DIR/crl/crl.pem"
openssl crl -in "$CA_DIR/crl/crl.pem" -text -noout | head -20 | tee -a "$LOG"
exit 0
