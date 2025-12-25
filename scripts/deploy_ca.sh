#!/bin/bash
set -euo pipefail

echo "🚀 АВТОМАТИЧЕСКОЕ РАЗВЁРТЫВАНИЕ PKI/CA (ЭТАП 1)"
echo "=============================================================="

cd "$(dirname "$0")"
sudo ./install_ca.sh
sudo ./init_ca.sh

echo ""
echo "✅ ПОЛНАЯ АВТОМАТИЗАЦИЯ ЗАВЕРШЕНА!"
echo "📁 Структура PKI: /etc/pki/pki/"
echo "🔑 Root CA: /etc/pki/pki/ca.crt (БЕЗ пароля)"
echo "📜 Логи: /var/log/ca/*.log"
echo ""
echo "📋 ТЕСТЫ:"
echo "sudo openssl x509 -in /etc/pki/pki/ca.crt -noout -text"
echo "ls -la /etc/pki/pki/private/"
echo ""
echo "➡️ Следующий шаг: генерация CSR для VPN-сервера"