# Roblox Auto-Joiner HTTP API

## Overview
A Roblox server auto-joiner system with authentication and key management that monitors Discord channels for server information and automatically joins profitable servers. The system consists of:

1. **HTTP API Server** (main.py) - Flask-based REST API on port 5000 with admin authentication
2. **WebSocket Server** (websocket_server.py) - WebSocket server for real-time Roblox client communication
3. **Discord Bot** (discord_bot_http.py) - Monitors Discord channels for server information
4. **Roblox Client** (roblox_client.lua) - Lua script with key activation system that runs in Roblox
5. **Admin Panel** (index.html) - Web interface for key management and system monitoring
6. **Database** (database.py + SQLite) - Key storage and player authentication

## Architecture
```
Discord → Discord Bot → HTTP API ← Admin Panel (Authentication)
                           ↓              ↓
                    SQLite Database ← Key Management
                           ↓
                    WebSocket Server → Roblox Client (Lua + Key System)
```

## Authentication & Key System

### Admin Panel Access
- **URL**: Open the main page of your deployment
- **Login**: admin
- **Password**: maus123pass
- **Features**:
  - Generate new access keys for Roblox clients
  - View all keys with status (active/inactive/frozen)
  - Freeze/unfreeze keys
  - Delete keys
  - Real-time statistics

### Roblox Client Key System
The Lua script now includes a key activation system:

1. **First Launch**: GUI prompts for key input
2. **Key Activation**: Key binds to player's Roblox username
3. **One Key Per Account**: Each key can only be used by one player
4. **Automatic Login**: Returns players automatically logged in on subsequent launches
5. **Key States**:
   - **Inactive**: Newly generated, not yet activated
   - **Active**: Activated and bound to a player
   - **Frozen**: Deactivated by admin, cannot be used

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
2. **API_URL is automatically updated**: `https://a5bb1dd5-c49a-4928-a843-42e92dbee496-00-1x1b83mdq47q6.worf.replit.dev`
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

### Public Endpoints (No Authentication)
- **GET /** - Admin panel login page
- **POST /api/server/push** - Push server data to queue
- **GET /api/server/pull** - Pull next server from queue
- **GET /api/status** - Get system status
- **POST /api/ping** - Health check endpoint
- **GET /api/logs** - Get ping logs

### Admin Endpoints (Requires Authentication)
- **POST /api/admin/login** - Login to admin panel
- **POST /api/admin/logout** - Logout from admin panel
- **GET /api/admin/check** - Check login status
- **GET /api/admin/keys** - Get all keys
- **POST /api/admin/keys/generate** - Generate new key
- **DELETE /api/admin/keys/{key}/delete** - Delete a key
- **PUT /api/admin/keys/{key}/freeze** - Freeze a key
- **PUT /api/admin/keys/{key}/unfreeze** - Unfreeze a key

### Roblox Client Endpoints (For Lua Script)
- **POST /api/keys/activate** - Activate a key for a player
- **POST /api/keys/verify** - Verify if key is valid for player
- **POST /api/keys/check_player** - Check if player has an active key

## Project Structure
- `main.py` - Main HTTP API server with authentication (Flask)
- `database.py` - SQLite database module for key management
- `websocket_server.py` - WebSocket server for real-time communication
- `discord_bot_http.py` - Discord bot that monitors channels
- `roblox_client.lua` - Roblox executor script with key system
- `index.html` - Admin panel web interface
- `config.py` - Configuration file with all settings
- `requirements.txt` - Python dependencies
- `api_keys.db` - SQLite database (auto-created, gitignored)

## Deployment

### Replit Deployment Notes
The HTTP API runs on port 5000 and is configured for 0.0.0.0 to work with Replit's proxy system.

**Deployment Configuration:**
- **Deployment Type**: VM (always running)
- **Run Command**: `python main.py`
- **Important Limitation**: The WebSocket server (port 8765) will NOT be externally accessible in Replit deployments because Replit only exposes one port. The core HTTP API functionality (server queue, key management, admin panel) works perfectly. Roblox clients should use the REST API endpoints (`/api/server/pull`) instead of WebSocket for polling servers.
- **Discord Bot**: Optional component. Add `DISCORD_TOKEN` to Secrets to enable Discord channel monitoring.

### Production Deployment (Ubuntu/VPS)
For full functionality including WebSocket server on a separate port, deploy to a VPS where both ports can be exposed. See deployment/ folder for automated Ubuntu setup scripts.

## Ubuntu/VPS Deployment
Проект полностью подготовлен для развертывания на Ubuntu 22.04+ сервере:

### Быстрая установка
```bash
git clone <repo-url> roblox-auto-joiner
cd roblox-auto-joiner
sudo bash deployment/bootstrap.sh
```

### Документация
- **[QUICKSTART_UBUNTU.md](QUICKSTART_UBUNTU.md)** - Быстрый старт (1 команда)
- **[DEPLOY_UBUNTU.md](DEPLOY_UBUNTU.md)** - Подробная инструкция по развертыванию
- **[deployment/README.md](deployment/README.md)** - Описание файлов развертывания

### Что включено
- ✅ Автоматическая установка всех зависимостей
- ✅ Systemd сервисы для автозапуска (Flask + WebSocket)
- ✅ Nginx reverse proxy конфигурация
- ✅ UFW файрвол настройка
- ✅ Поддержка HTTPS/SSL (Let's Encrypt)
- ✅ Автоматическое управление процессами
- ✅ Подробные инструкции на русском языке

## Recent Changes
- 2025-10-08: Successfully configured for Replit environment
  - Installed Python 3.11 with all required dependencies
  - Installed packages: Flask 3.0.0, flask-cors 4.0.0, websockets 12.0, colorama 0.4.6, requests 2.31.0, gunicorn 23.0.0, keyboard 0.13.5
  - Created .gitignore file for Python project with database exclusions
  - Configured "Server" workflow to run Flask on port 5000 with webview output
  - Configured VM deployment with `python main.py` for always-running server
  - Both HTTP API (port 5000) and WebSocket server (port 8765) running successfully
  - Frontend admin panel verified working at root URL
  - Database initialization successful
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

- 2025-10-08: Successfully configured for Replit environment
  - Installed all Python dependencies (Flask, flask-cors, websockets, colorama, requests, gunicorn, keyboard)
  - Created .gitignore for Python project with database file exclusions
  - Configured "Server" workflow to run Flask HTTP API on port 5000
  - Set up VM deployment configuration with `python main.py`
  - Documented Replit deployment limitation: WebSocket server on port 8765 not externally accessible (use REST API instead)
  - Both HTTP API (port 5000) and WebSocket server (port 8765) running successfully in development
  - Admin panel web interface verified working
  - Core functionality (server queue, key management, admin authentication) fully operational

- 2025-10-08: Added complete authentication and key management system
  - **NEW: Admin Panel Authentication** - Login system with credentials (admin/maus123pass)
  - **NEW: Key Management System** - SQLite database for storing and managing access keys
  - **NEW: Roblox Key Activation** - Lua script now requires key activation before use
  - **NEW: Player Binding** - Each key binds to one Roblox username permanently
  - **NEW: Key States** - Support for inactive, active, and frozen key states
  - **NEW: Admin Controls** - Generate, freeze, unfreeze, and delete keys via web interface
  - Created `database.py` module with SQLite integration
  - Added 9 new API endpoints for key management
  - Completely redesigned `index.html` with login page and key management UI
  - Updated `roblox_client.lua` with key activation GUI and logic
  - Updated `main.py` with session-based authentication and key endpoints
  - All features tested and working: login, key generation, activation, freezing, player binding
  - Database file (api_keys.db) automatically created and gitignored
  
- 2025-10-08: Fresh GitHub import successfully configured for Replit environment
  - Python 3.12 already installed in Replit environment
  - Installed all Python dependencies via packager: Flask 3.0.0, flask-cors 4.0.0, websockets 12.0, colorama 0.4.6, requests 2.31.0, keyboard 0.13.5, gunicorn 23.0.0
  - Created comprehensive .gitignore for Python project
  - Configured workflow "Server" to run Flask HTTP API on port 5000 with webview output
  - Configured VM deployment with `python main.py` for always-running server (required for WebSocket support)
  - Both HTTP API (Flask on port 5000) and WebSocket server (port 8765) running successfully
  - System ready for use: HTTP API and WebSocket server fully operational
  - Note: Discord bot monitoring is optional and requires DISCORD_TOKEN to be added to Secrets
  - Project includes complete Ubuntu/VPS deployment automation in deployment/ folder

## User Preferences
None specified yet.
