# 🚀 Деплой на Render.com

## Быстрый старт

### 1. Создайте аккаунт на Render.com
- Перейдите на [render.com](https://render.com)
- Зарегистрируйтесь или войдите в аккаунт

### 2. Подключите репозиторий GitHub
- Создайте новый репозиторий на GitHub с вашим проектом
- На Render.com выберите "New" → "Web Service"
- Выберите "Build and deploy from a Git repository"
- Подключите ваш GitHub репозиторий

### 3. Настройте Web Service

**Name:** `givescript-roblox-autojoiner` (или любое другое имя)

**Runtime:** `Python 3`

**Build Command:**
```bash
pip install -r requirements.txt
```

**Start Command:**
```bash
gunicorn --bind 0.0.0.0:5000 main:app
```

### 4. Настройте переменные окружения

В разделе "Environment" добавьте:

```bash
DISCORD_TOKEN=ВАШ_DISCORD_БОТ_ТОКЕН
API_URL=https://givescript.onrender.com  # Будет сгенерировано автоматически
```

### 5. Деплой

Нажмите "Create Web Service" и дождитесь завершения деплоя.

## 🌐 После деплоя

### Получение API URL
После успешного деплоя Render автоматически сгенерирует URL вроде:
```
https://givescript.onrender.com
```

### Обновление скриптов

#### 1. Обновите Roblox клиент (`roblox_client.lua`)
```lua
-- Измените эту строку:
local API_URL = "https://givescript.onrender.com"  -- Ваш реальный URL
```

#### 2. Обновите Google Apps Script (`google_apps_script.js`)
```javascript
var url = "https://givescript.onrender.com/api/ping";  // Ваш реальный URL
```

#### 3. Discord бот обновится автоматически
Discord бот автоматически определит новый URL через переменную окружения.

## 🔧 Настройка Google Apps Script

### 1. Создайте новый проект
- Перейдите в [Google Apps Script](https://script.google.com)
- Создайте новый проект
- Скопируйте содержимое `google_apps_script.js`

### 2. Настройте триггер
- В редакторе нажмите на часы (Triggers)
- Добавьте триггер для функции `pingWebsite()`
- Установите интервал: каждые 5 минут

### 3. Обновите URL в скрипте
Замените `https://givescript.onrender.com` на ваш реальный URL.

## 📊 Мониторинг

### Веб-интерфейс
Откройте ваш URL в браузере для просмотра дашборда:
```
https://givescript.onrender.com
```

### API Endpoints
- `GET /` - Статус API
- `GET /api/status` - Детальный статус системы
- `POST /api/ping` - Пинг от Google Apps Script
- `GET /api/logs` - Последние пинги

### Проверка работоспособности
```bash
# Пинг сайта
curl https://givescript.onrender.com/api/ping \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"source": "manual_test"}'
```

## 🛠 Устранение проблем

### Проблема: Discord бот не подключается
- Убедитесь, что `DISCORD_TOKEN` указан правильно в переменных окружения
- Проверьте логи в Render Dashboard

### Проблема: Roblox клиент не получает данные
- Убедитесь, что URL в `roblox_client.lua` обновлен
- Проверьте, что API отвечает на `/api/status`

### Проблема: Google Apps Script не пингует
- Убедитесь, что URL в скрипте обновлен
- Проверьте права доступа в Google Apps Script

## 🔄 Автоматическое управление

### Автопинг от Google Apps Script
- Создает триггер на каждые 5 минут
- Мониторит доступность сайта
- Логирует все взаимодействия

### Автоматическое определение URL
- Discord бот: через переменную окружения `API_URL`
- Веб-интерфейс: автоматически определяет домен
- Roblox клиент: требует ручного обновления после деплоя

## 📈 Масштабирование

### Бесплатный тариф Render.com
- 512 MB RAM
- Бесплатный домен *.onrender.com
- Автоматическое засыпание после бездействия

### Про тариф
- Больше ресурсов
- Кастомный домен
- Постоянная работа

## 🔐 Безопасность

- Используйте сильный Discord токен
- Не коммитте токены в публичный репозиторий
- Используйте переменные окружения в Render

---

## 🎯 Быстрая проверка после деплоя

1. **Проверьте статус:** `GET https://your-app.onrender.com/api/status`
2. **Протестируйте пинг:** `POST https://your-app.onrender.com/api/ping`
3. **Откройте дашборд:** `https://your-app.onrender.com`
4. **Обновите Roblox скрипт** с новым URL
5. **Настройте Google Apps Script** с новым URL

Готово! Ваш проект теперь работает на Render.com с автоматическим мониторингом через Google Apps Script! 🤖✨
