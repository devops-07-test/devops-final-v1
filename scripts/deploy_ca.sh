#!/bin/bash
set -euo pipefail

echo "🚀 АВТОМАТИЧЕСКОЕ РАЗВЁРТЫВАНИЕ PKI/CA (ЭТАП 1)"
echo "=============================================================="

cd "$(dirname "$0")"

echo "📦 Шаг 1/2: Установка окружения..."
sudo ./install_ca.sh

echo "🔑 Шаг 2/2: Создание Root CA..."
sudo ./init_ca.sh

echo ""
echo "✅ ✅ ✅ ПОВНАЯ АВТОМАТИЗАЦИЯ ЗАВЕРШЕНА! ✅ ✅ ✅"
echo "📁 PKI: /etc/pki/pki/"
echo "🔑 Root CA: /etc/pki/pki/ca.crt (БЕЗ пароля)"
echo "📜 Логи: /var/log/ca/"
echo ""
echo "🧪 ПРОВЕРКА:"
echo "sudo ls -la /etc/pki/pki/"
echo "sudo openssl x509 -in /etc/pki/pki/ca.crt -noout -dates"
echo ""
echo "➡️ Готово для VPN-сертификатов!"