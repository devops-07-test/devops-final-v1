#!/bin/bash
set -euo pipefail

LOG="/var/log/ca/sign_csr.log"
CA_DIR="/etc/pki/pki"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }
error_exit() { log "ERROR: $1" >&2; exit 1; }

CSR_FILE="${1:?CSR файл обязателен}"
TYPE="${2:?Тип: server или client}"
OUT_CRT="${3:-${CSR_FILE%.csr}.crt}"

[ "$EUID" -ne 0 ] && error_exit "Запуск от root"
[ ! -f "$CSR_FILE" ] && error_exit "CSR не найден: $CSR_FILE"
[ ! -f "$CA_DIR/private/ca.key" ] && error_exit "Root CA не инициализирован"

case "$TYPE" in server) EXT="server";; client) EXT="client";; *) error_exit "Тип: server или client";; esac

log "🚀 Подпись CSR БЕЗ пароля: $CSR_FILE -> $OUT_CRT ($TYPE)"

cd /etc/pki
expect -c "
    spawn easy-rsa sign-req $EXT $CSR_FILE
    expect {
        \"Enter pass phrase\" { send \"\r\"; exp_continue }
        \"Sign the certificate?\" { send \"yes\r\" }
        eof
    }
"

[ -f "$OUT_CRT" ] || error_exit "Сертификат не создан"
cp "$OUT_CRT" /etc/pki/issued/
chmod 644 /etc/pki/issued/"$(basename "$OUT_CRT")"

log "✅ Сертификат выдан: $OUT_CRT"
log "Chain: cat $CA_DIR/ca.crt $OUT_CRT > chain.pem"
exit 0
