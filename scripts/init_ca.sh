#!/usr/bin/env bash
set -euo pipefail

# init_ca.sh – инициализация PKI и создание Root CA
# Обработчик ошибок для вывода понятного сообщения
trap 'echo "[FATAL] Ошибка в строке $LINENO. Скрипт завершен." >&2; exit 1' ERR

PKI_BASE="/etc/pki"
PKI_DIR="$PKI_BASE/pki"
VARS_FILE="$PKI_BASE/vars"

# Проверка прав
if [[ "$(id -u)" -ne 0 ]]; then
  echo "[ERROR] Этот скрипт нужно запускать от root или через sudo." >&2
  exit 1
fi

# Более надежная проверка наличия easy-rsa
if ! command -v easy-rsa &> /dev/null; then
  echo "[ERROR] Команда easy-rsa не найдена. Сначала запусти install_ca.sh." >&2
  exit 1
fi

mkdir -p "$PKI_BASE"
cd "$PKI_BASE" || { echo "[ERROR] Не удалось перейти в $PKI_BASE" >&2; exit 1; }

# Улучшенная проверка идемпотентности: проверяем именно валидный CA
if [[ -d "$PKI_DIR" ]]; then
    if [[ -f "$PKI_DIR/ca.crt" ]]; then
        echo "[INFO] PKI уже инициализирована, CA-сертификат найден: $PKI_DIR/ca.crt"
        # Опционально: можно добавить быструю проверку валидности сертификата
        if openssl x509 -in "$PKI_DIR/ca.crt" -noout &> /dev/null; then
            echo "[INFO] Сертификат имеет корректный формат."
        else
            echo "[WARN] Файл ca.crt существует, но имеет неверный формат." >&2
        fi
        exit 0
    else
        echo "[WARN] Директория PKI существует, но ca.crt не найден. Будет создан заново." >&2
        # По желанию: можно удалить старую директорию rm -rf "$PKI_DIR"
    fi
fi

echo "[INFO] Инициализирую PKI в $PKI_DIR ..."
if ! easy-rsa init-pki; then
    echo "[ERROR] Не удалось инициализировать PKI." >&2
    exit 1
fi

# vars – политика PKI
if [[ ! -f "$VARS_FILE" ]]; then
  echo "[INFO] Создаю файл vars..."
  cat > "$VARS_FILE" << 'EOF'
set_var EASYRSA_REQ_COUNTRY    "RU"
set_var EASYRSA_REQ_PROVINCE   "Moscow"
set_var EASYRSA_REQ_CITY       "Moscow"
set_var EASYRSA_REQ_ORG        "DevOps-Final-Project"
set_var EASYRSA_REQ_EMAIL      "admin@devops.local"
set_var EASYRSA_REQ_OU         "Infrastructure"

set_var EASYRSA_ALGO           "ec"
set_var EASYRSA_DIGEST         "sha512"

set_var EASYRSA_CA_EXPIRE      3650
set_var EASYRSA_CERT_EXPIRE    825
EOF
else
  echo "[INFO] Файл vars уже существует, не перезаписываю."
fi

echo "[INFO] Создаю Root CA (build-ca)..."
echo "[INFO] Введи пароль для ключа CA (минимум 4 символа) и CN: DevOps-Final-Root-CA"

if ! easy-rsa build-ca; then
    echo "[ERROR] Не удалось создать Root CA. Проверь ввод." >&2
    exit 1
fi

echo "[SUCCESS] Root CA создан."
echo "    Сертификат: $PKI_DIR/ca.crt"
echo "    Ключ:       $PKI_DIR/private/ca.key"

# Финальная проверка
if [[ -f "$PKI_DIR/ca.crt" ]]; then
    echo "[INFO] Проверка созданного сертификата:"
    openssl x509 -in "$PKI_DIR/ca.crt" -subject -noout
fi