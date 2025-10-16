# 🤖 Roblox Auto-Joiner HTTP API

Комплексная система автоматического поиска и присоединения к прибыльным серверам Roblox через мониторинг Discord каналов.

## ✨ Новые возможности

- 🌐 **Веб-интерфейс** для мониторинга системы в реальном времени
- 📡 **Автоматический пинг** через Google Apps Script
- 🔄 **Динамическое определение URL** для легкого деплоя
- ☁️ **Оптимизация для Render.com** с автоматическим развертыванием

## 🚀 Быстрый запуск

### Локальная разработка

```bash
pip install -r requirements.txt
python main.py
```

### Деплой на Render.com

Смотрите подробную инструкцию в [`DEPLOY_RENDER.md`](DEPLOY_RENDER.md)

## 📊 Веб-интерфейс

После запуска откройте в браузере:
```
http://localhost:5000
```
или ваш Render.com URL для просмотра дашборда с:
- Мониторингом статуса системы
- Очередью серверов
- Активными Roblox клиентами
- Логами активности

## 🤖 Google Apps Script интеграция

Создайте новый проект в [Google Apps Script](https://script.google.com):

1. Скопируйте содержимое [`google_apps_script.js`](google_apps_script.js)
2. Обновите URL на ваш Render.com домен
3. Создайте триггер на каждые 5 минут для функции `pingWebsite()`

## 🔧 Обновление URL в скриптах

После деплоя на Render.com обновите следующие файлы:

### Roblox клиент (`roblox_client.lua`)
```lua
local API_URL = "https://your-app.onrender.com"  -- Ваш реальный URL
```

### Google Apps Script (`google_apps_script.js`)
```javascript
var url = "https://your-app.onrender.com/api/ping";
```

## 🔗 API Endpoints

- `GET /` - Веб-интерфейс дашборда
- `GET /api/status` - Статус системы
- `POST /api/server/push` - Отправка данных сервера
- `GET /api/server/pull` - Получение сервера из очереди
- `POST /api/ping` - Пинг от Google Apps Script
- `GET /api/logs` - Логи пингов

## ⚙️ Конфигурация

Все настройки в [`config.py`](config.py):
- Автоматическое определение API URL
- Фильтры серверов
- Настройки Discord каналов
- Параметры мониторинга

## 📁 Структура проекта

- `main.py` - HTTP API сервер с веб-интерфейсом
- `discord_bot_http.py` - Discord мониторинг бот
- `websocket_server.py` - WebSocket сервер для Roblox клиентов
- `roblox_client.lua` - Roblox исполнитель скрипт
- `config.py` - Конфигурация с динамическим URL
- `index.html` - Веб-интерфейс дашборда
- `google_apps_script.js` - Скрипт для Google Apps Script
- `test_deployment.sh` - Скрипт тестирования деплоя

## 🛠 Разработка

### Тестирование
```bash
python discord_bot_http.py test  # Тестирование парсера
./test_deployment.sh https://your-app.onrender.com  # Тестирование деплоя
```

### Мониторинг
- Веб-интерфейс: ваш домен
- Логи: Render.com Dashboard
- Пинги: Google Apps Script logs

## 🌟 Возможности

- 🔍 Мониторинг Discord каналов
- 🎯 Парсинг различных форматов сообщений
- 📊 Фильтрация по доходности и игрокам
- 🌐 Веб-интерфейс для мониторинга
- 📱 Автопинг через Google Apps Script
- 🔄 Автоматическое присоединение к серверам
- ⚡ Реал-тайм обновления через WebSocket

## 📝 Лицензия

Проект создан для образовательных целей. Используйте ответственно.

---

**Готов к деплою на Render.com!** 🚀
