#!/bin/bash

# Roblox Auto-Joiner - Скрипт автоматической установки для Ubuntu 22.04+
# Этот скрипт автоматически настраивает все необходимое для работы сервера

set -e  # Остановка при ошибке

echo "======================================================"
echo "  Roblox Auto-Joiner - Автоматическая установка"
echo "======================================================"
echo ""

# Проверка прав root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Пожалуйста, запустите скрипт с правами root: sudo bash bootstrap.sh"
    exit 1
fi

# Переменные
INSTALL_DIR="/opt/roblox-auto-joiner"
SERVICE_USER="roblox"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "📦 Обновление системных пакетов..."
apt update -qq

echo "📦 Установка необходимых пакетов..."
# Ubuntu 22.04 поставляется с Python 3.10 по умолчанию
apt install -y python3 python3-venv python3-pip nginx ufw curl git

echo "👤 Создание пользователя $SERVICE_USER..."
if ! id -u $SERVICE_USER > /dev/null 2>&1; then
    useradd -r -s /bin/bash -d $INSTALL_DIR -m $SERVICE_USER
    echo "✅ Пользователь $SERVICE_USER создан"
else
    echo "ℹ️  Пользователь $SERVICE_USER уже существует"
fi

echo "📁 Создание директории проекта..."
mkdir -p $INSTALL_DIR
mkdir -p $INSTALL_DIR/logs

echo "📋 Копирование файлов проекта..."
cp -r $PROJECT_ROOT/* $INSTALL_DIR/
chown -R $SERVICE_USER:$SERVICE_USER $INSTALL_DIR

echo "🐍 Создание виртуального окружения Python..."
sudo -u $SERVICE_USER python3 -m venv $INSTALL_DIR/venv

echo "📦 Установка Python зависимостей..."
sudo -u $SERVICE_USER $INSTALL_DIR/venv/bin/pip install --no-cache-dir --upgrade pip
sudo -u $SERVICE_USER $INSTALL_DIR/venv/bin/pip install --no-cache-dir -r $INSTALL_DIR/requirements.txt

echo "⚙️  Настройка переменных окружения..."
if [ ! -f "$INSTALL_DIR/.env" ]; then
    cp $INSTALL_DIR/deployment/.env.template $INSTALL_DIR/.env
    # Генерация случайного SECRET_KEY
    SECRET_KEY=$(openssl rand -hex 32)
    sed -i "s/SECRET_KEY=измените_на_случайную_строку/SECRET_KEY=$SECRET_KEY/" $INSTALL_DIR/.env
    
    # Автоматическое определение IP адреса
    SERVER_IP=$(hostname -I | awk '{print $1}')
    sed -i "s|# API_URL=http://your-server-ip:5000|API_URL=http://$SERVER_IP|" $INSTALL_DIR/.env
    
    echo "✅ Файл .env создан. Отредактируйте $INSTALL_DIR/.env для настройки Discord токена и других параметров"
    chown $SERVICE_USER:$SERVICE_USER $INSTALL_DIR/.env
    chmod 600 $INSTALL_DIR/.env
else
    echo "ℹ️  Файл .env уже существует, пропускаем"
fi

echo "🔧 Установка systemd сервисов..."
cp $INSTALL_DIR/deployment/roblox-flask.service /etc/systemd/system/
cp $INSTALL_DIR/deployment/roblox-websocket.service /etc/systemd/system/
cp $INSTALL_DIR/deployment/roblox.target /etc/systemd/system/

systemctl daemon-reload

echo "🌐 Настройка Nginx..."
cp $INSTALL_DIR/deployment/nginx-roblox.conf /etc/nginx/sites-available/roblox
ln -sf /etc/nginx/sites-available/roblox /etc/nginx/sites-enabled/roblox

# Удаление дефолтного сайта
rm -f /etc/nginx/sites-enabled/default

# Проверка конфигурации Nginx
nginx -t

echo "🔥 Настройка файрвола..."
ufw --force enable
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 5000/tcp  # Flask (опционально, для прямого доступа)
ufw allow 8765/tcp  # WebSocket (опционально, для прямого доступа)
ufw reload

echo "🚀 Запуск сервисов..."
systemctl enable roblox.target
systemctl start roblox.target
systemctl restart nginx

echo ""
echo "======================================================"
echo "✅ Установка завершена успешно!"
echo "======================================================"
echo ""
echo "📊 Статус сервисов:"
systemctl status roblox-flask.service --no-pager -l || true
systemctl status roblox-websocket.service --no-pager -l || true
echo ""
echo "🌐 Веб-интерфейс доступен по адресу:"
echo "   http://$SERVER_IP"
echo "   или http://$(hostname -f)"
echo ""
echo "📝 Полезные команды:"
echo "   Просмотр логов Flask:     journalctl -u roblox-flask.service -f"
echo "   Просмотр логов WebSocket: journalctl -u roblox-websocket.service -f"
echo "   Перезапуск сервисов:      systemctl restart roblox.target"
echo "   Остановка сервисов:       systemctl stop roblox.target"
echo "   Статус сервисов:          systemctl status roblox.target"
echo ""
echo "⚙️  Настройка:"
echo "   Конфигурация:             nano $INSTALL_DIR/.env"
echo "   После изменений:          systemctl restart roblox.target"
echo ""
echo "🔒 Для настройки HTTPS сертификата (Let's Encrypt):"
echo "   apt install certbot python3-certbot-nginx"
echo "   certbot --nginx -d your-domain.com"
echo ""
echo "======================================================"
