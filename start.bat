@echo off
REM Скрипт для быстрого запуска системы локально (Windows)

echo 🚀 Запуск Roblox Auto-Joiner HTTP API локально...
echo ==================================================

REM Проверка Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python не установлен!
    pause
    exit /b 1
)

REM Проверка виртуального окружения
if not exist "venv" (
    echo 📦 Создание виртуального окружения...
    python -m venv venv
)

REM Активация виртуального окружения
echo 🔧 Активация виртуального окружения...
call venv\Scripts\activate.bat

REM Установка зависимостей
echo 📚 Установка зависимостей...
pip install -r requirements.txt

REM Запуск системы
echo 🎯 Запуск HTTP API сервера...
echo 🌐 Доступно по адресу: http://localhost:5000
echo 📊 Веб-интерфейс: http://localhost:5000
echo.
echo Для остановки нажмите Ctrl+C
echo.

python main.py

pause
