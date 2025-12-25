#!/usr/bin/env bash
set -euo pipefail

# install_ca.sh – подготовка сервера под удостоверяющий центр (CA)

LOG="/var/log/ca/install_ca.log"
CA_BASE="/etc/pki"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }
error_exit() { log "ERROR: $1"; exit 1; }

if [ -d "$CA_BASE" ] && [ -L "/usr/local/bin/easy-rsa" ]; then
    log "✅ CA окружение уже установлено. Пропуск."
    exit 0
fi

log "🚀 Начало установки CA окружения..."

[ "$EUID" -ne 0 ] && error_exit "Запуск от root обязателен"

apt update
apt install -y easy-rsa openssl ufw bash expect || error_exit "Ошибка установки пакетов"

mkdir -p "$CA_BASE"
chown root:root "$CA_BASE"
chmod 755 "$CA_BASE"

[ ! -L "/usr/local/bin/easy-rsa" ] && ln -sf /usr/share/easy-rsa/easyrsa /usr/local/bin/easy-rsa

mkdir -p /var/log/ca
touch "$LOG"
chmod 644 "$LOG"

log "✅ Установка CA окружения завершена"
exit 0