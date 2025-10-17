# Roblox Auto-Joiner HTTP API

## Overview
A Roblox server auto-joiner system that monitors Discord channels for server information and automatically joins profitable servers. The system consists of:

1. **HTTP API Server** (main.py) - Flask-based REST API on port 5000
2. **WebSocket Server** (websocket_server.py) - WebSocket server for real-time Roblox client communication
3. **Discord Bot** (discord_bot_http.py) - Monitors Discord channels for server information
4. **Roblox Client** (roblox_client.lua) - Lua script that runs in Roblox
5. **Monitoring Dashboard** (index.html) - Web interface for system monitoring

## Architecture
```
Discord → Discord Bot → HTTP API ← Monitoring Dashboard
                           ↓
                    WebSocket Server → Roblox Client (Lua)
```

## Setup Instructions

### 1. Configure Settings
Edit `config.py` to set up your configuration:

- **DISCORD_TOKEN**: Your Discord bot token
- **MONITORED_CHANNELS**: List of Discord channel IDs to monitor
- **MONEY_THRESHOLD**: Min/max money per second filter
- **PLAYER_THRESHOLD**: Maximum number of players
- **ICE_HUB_FILTER**: Special filters for Ice Hub messages
- **FILTER_BY_NAME**: Whitelist specific server names

### 2. Set Up Discord Bot (Optional)
If you want to monitor Discord channels:

1. Create a Discord bot at https://discord.com/developers/applications
2. Add the bot token to `config.py`
3. Add channel IDs to `MONITORED_CHANNELS` in `config.py`
4. Run: `python discord_bot_http.py`

### 3. Run the HTTP API
The main server is automatically started on port 5000 when you run the Repl.

### 4. Configure Roblox Client
1. Open `roblox_client.lua`
2. Update the **API_URL** to your Replit deployment URL
3. Copy the entire script and execute it in Roblox through an executor

### 5. Set Up Discord Bot (Optional)
The Discord bot **automatically detects the API URL** from Replit environment variables:
1. Add your Discord bot token to Secrets (key: DISCORD_TOKEN)
2. Update channel IDs in `MONITORED_CHANNELS` in `config.py` to monitor your Discord channels
3. Run the bot: `python discord_bot_http.py`
4. The bot will automatically display the API URL it's using on startup

## Environment Variables
This project uses environment variables for security:
- **DISCORD_TOKEN**: Your Discord bot token (required only if using the Discord monitoring feature)
  - Add this to Replit Secrets for security
  - Never commit this to your repository

## API Endpoints

### Public Endpoints
- **GET /** - Monitoring dashboard
- **POST /api/server/push** - Push server data to queue
- **GET /api/server/pull** - Pull next server from queue
- **GET /api/status** - Get system status
- **POST /api/ping** - Health check endpoint
- **GET /api/logs** - Get ping logs
- **GET /api/discord/stats** - Get Discord bot statistics
- **GET /api/discord/queue** - Get server queue with timers

## Project Structure
- `main.py` - Main HTTP API server (Flask)
- `websocket_server.py` - WebSocket server for real-time communication
- `discord_bot_http.py` - Discord bot that monitors channels
- `roblox_client.lua` - Roblox executor script
- `index.html` - Monitoring dashboard web interface
- `config.py` - Configuration file with all settings
- `requirements.txt` - Python dependencies

## Deployment

### Replit Deployment Notes
The HTTP API runs on port 5000 and is configured for 0.0.0.0 to work with Replit's proxy system.

**Deployment Configuration:**
- **Deployment Type**: VM (always running)
- **Run Command**: `python main.py`
- **Important Limitation**: The WebSocket server (port 8765) will NOT be externally accessible in Replit deployments because Replit only exposes one port. The core HTTP API functionality (server queue, monitoring dashboard) works perfectly. Roblox clients should use the REST API endpoints (`/api/server/pull`) instead of WebSocket for polling servers.
- **Discord Bot**: Optional component. Add `DISCORD_TOKEN` to Secrets to enable Discord channel monitoring.

### Production Deployment (Ubuntu/VPS)
For full functionality including WebSocket server on a separate port, deploy to a VPS where both ports can be exposed.

## Recent Changes
- 2025-10-16: **Complete Code Cleanup**
  - Удалены все комментарии из всех Python файлов (main.py, config.py, websocket_server.py)
  - Удалены все комментарии из roblox_client.lua
  - Удалены все ненужные файлы:
    - Документация (DEPLOY_*.md, QUICKSTART_*.md, KEY_SYSTEM_GUIDE.md, ИНСТРУКЦИЯ.md, README.md)
    - Deployment скрипты (Procfile, render.yaml, start.bat, start.sh, deployment/)
    - Тесты и примеры (test_*.py, test_*.sh, webhook_example.lua, google_apps_script.js)
    - Старые файлы (api_keys.db, attached_assets/)
  - Проект теперь содержит только необходимые файлы для работы
  - Код остался полностью функциональным, все сервисы работают

- 2025-10-16: **Removed Key Authentication System**
  - Удалена полностью система ключей и аутентификации
  - Удалены все endpoints для управления ключами (/api/admin/*, /api/keys/*)
  - Удален файл database.py и база данных api_keys.db
  - Упрощен index.html - теперь только мониторинг Discord бота и очереди серверов
  - Упрощен roblox_client.lua - убрана вся логика активации и проверки ключей
  - Убрана система сессий и аутентификации из Flask
  - Проект стал более простым и доступным для использования

- 2025-10-08: Successfully configured for Replit environment
  - Installed Python 3.11 with all required dependencies
  - Installed packages: Flask 3.0.0, flask-cors 4.0.0, websockets 12.0, colorama 0.4.6, requests 2.31.0, gunicorn 23.0.0
  - Created .gitignore file for Python project with database exclusions
  - Configured "Server" workflow to run Flask on port 5000 with webview output
  - Configured VM deployment with `python main.py` for always-running server
  - Both HTTP API (port 5000) and WebSocket server (port 8765) running successfully
  - Frontend monitoring dashboard verified working at root URL
  - Discord bot monitoring disabled (requires DISCORD_TOKEN in Secrets to enable)
  - Note: In Replit deployment, WebSocket server on port 8765 is not externally accessible (only one port exposed). Use REST API endpoints instead for Roblox clients.

- 2025-10-08: Discord Bot Integration Complete
  - **Discord Bot Auto-Start**: Discord бот теперь автоматически запускается вместе с основным сервером
  - **Real-time Monitoring Dashboard**: Добавлен раздел Discord мониторинга в админ-панель
  - **Live Statistics**: Отображение статистики Discord бота (подключение, обработано серверов, уникальные серверы)
  - **Server Queue Display**: Динамическая очередь серверов Brainrot с таймерами обратного отсчета
  - **Progress Bars**: Визуальные индикаторы времени до удаления сервера из очереди
  - **Auto-refresh**: Данные обновляются каждые 2 секунды автоматически
  - **New API Endpoints**:
    - `/api/discord/stats` - статистика Discord бота
    - `/api/discord/queue` - текущая очередь серверов с таймерами
  - **Optional Keyboard Support**: Discord бот работает без keyboard в headless режиме
  - **Global Stats Tracking**: Глобальное хранилище статистики для мониторинга активности
  - Discord токен безопасно хранится в Replit Secrets

## User Preferences
None specified yet.
