#!/bin/bash

# Скрипт для быстрого запуска системы локально

echo "🚀 Запуск Roblox Auto-Joiner HTTP API локально..."
echo "=================================================="

# Проверка Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 не установлен!"
    exit 1
fi

# Проверка виртуального окружения
if [ ! -d "venv" ]; then
    echo "📦 Создание виртуального окружения..."
    python3 -m venv venv
fi

# Активация виртуального окружения
echo "🔧 Активация виртуального окружения..."
source venv/bin/activate

# Установка зависимостей
echo "📚 Установка зависимостей..."
pip install -r requirements.txt

# Запуск системы
echo "🎯 Запуск HTTP API сервера..."
echo "🌐 Доступно по адресу: http://localhost:5000"
echo "📊 Веб-интерфейс: http://localhost:5000"
echo ""
echo "Для остановки нажмите Ctrl+C"
echo ""

python main.py
