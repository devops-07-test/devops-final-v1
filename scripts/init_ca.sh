#!/bin/bash
set -euo pipefail

mkdir -p /var/log/ca
LOG="/var/log/ca/init_ca.log"
CA_DIR="/etc/pki/pki"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }
error_exit() { log "❌ ERROR: $1"; exit 1; }

# Идемпотентность
if [ -f "$CA_DIR/ca.crt" ] && [ -f "$CA_DIR/private/ca.key" ]; then
    log "✅ Root CA уже существует"
    openssl x509 -in "$CA_DIR/ca.crt" -noout -dates | tee -a "$LOG"
    exit 0
fi

log "🚀 Инициализация Root CA (БЕЗ пароля)..."

[ "$EUID" -ne 0 ] && error_exit "Требуется sudo/root"
[ ! -d /etc/pki ] && error_exit "Сначала запустите install_ca.sh"

# Структура PKI
mkdir -p "$CA_DIR"/{private,issued,certs,crls,newcerts}
touch "$CA_DIR/index.txt"
echo 1000 > "$CA_DIR/serial"
chown -R root:root "$CA_DIR"
chmod 700 "$CA_DIR/private"
chmod 755 "$CA_DIR"

cd /etc/pki

# ✅ ФИКС: используем полный путь к easyrsa
/usr/share/easy-rsa/easyrsa init-pki

cat > vars << 'EOF'
export EASY_RSA="$(pwd)"
export KEY_COUNTRY="RU"
export KEY_PROVINCE="Moscow Oblast"
export KEY_CITY="Khimki"
export KEY_ORG="DevOpsCA"
export KEY_EMAIL="admin@devops.local"
export KEY_OU="CA"
export KEY_NAME="RootCA"
export KEY_ALTNAMES="DNS:ca.devops.local"
EOF

source vars
/usr/share/easy-rsa/easyrsa build-ca nopass

chmod 600 "$CA_DIR/private/ca.key"

log "✅ Root CA создан!"
openssl x509 -in "$CA_DIR/ca.crt" -noout -subject -dates | tee -a "$LOG"
exit 0
