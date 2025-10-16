#!/bin/bash

# Быстрая загрузка проекта на Ubuntu сервер
# Использование: bash upload-to-server.sh USER@SERVER_IP

if [ -z "$1" ]; then
    echo "Использование: bash upload-to-server.sh USER@SERVER_IP"
    echo "Пример: bash upload-to-server.sh root@78.153.130.35"
    exit 1
fi

SERVER=$1
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "📦 Создание архива проекта..."
cd $PROJECT_ROOT
tar -czf /tmp/roblox-auto-joiner.tar.gz \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    --exclude='.pythonlibs' \
    --exclude='.upm' \
    --exclude='venv' \
    --exclude='node_modules' \
    --exclude='.replit' \
    --exclude='attached_assets' \
    .

echo "📤 Загрузка на сервер $SERVER..."
scp /tmp/roblox-auto-joiner.tar.gz $SERVER:/tmp/

echo "🚀 Запуск установки на сервере..."
ssh $SERVER << 'ENDSSH'
cd /tmp
mkdir -p roblox-auto-joiner
tar -xzf roblox-auto-joiner.tar.gz -C roblox-auto-joiner
cd roblox-auto-joiner
sudo bash deployment/bootstrap.sh
ENDSSH

echo ""
echo "✅ Установка завершена!"
echo ""
echo "🌐 Откройте в браузере: http://$(ssh $SERVER 'hostname -I | awk "{print \$1}"')"
echo ""

# Очистка
rm /tmp/roblox-auto-joiner.tar.gz
