#!/bin/bash
set -euo pipefail

# ✅ СОЗДАЕМ ЛОГИ ПЕРЕД ВСЕМ!
mkdir -p /var/log/ca
LOG="/var/log/ca/install_ca.log"
CA_BASE="/etc/pki"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }
error_exit() { log "❌ ERROR: $1"; exit 1; }

# Идемпотентность
if [ -d "$CA_BASE" ] && [ -L "/usr/local/bin/easy-rsa" ]; then
    log "✅ CA окружение уже установлено"
    exit 0
fi

log "🚀 Начало установки CA окружения..."

[ "$EUID" -ne 0 ] && error_exit "Требуется sudo/root"

apt update
apt install -y easy-rsa openssl ufw bash expect || error_exit "Ошибка установки пакетов"

mkdir -p "$CA_BASE"
chown root:root "$CA_BASE"
chmod 755 "$CA_BASE"

ln -sf /usr/share/easy-rsa/easyrsa /usr/local/bin/easy-rsa

log "✅ Установка завершена!"
log "Структура: $CA_BASE"
exit 0
