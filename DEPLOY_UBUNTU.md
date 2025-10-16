# 🚀 Развертывание на Ubuntu 22.04+ через Shell NG

## Быстрый старт (1 команда)

Подключитесь к вашему Ubuntu серверу через [app.shellngn.com](https://app.shellngn.com) и выполните:

```bash
git clone <ваш-репозиторий-url> roblox-auto-joiner
cd roblox-auto-joiner
sudo bash deployment/bootstrap.sh
```

**Готово!** Сервер автоматически установится и запустится.

---

## 📋 Что делает автоматическая установка

Скрипт `bootstrap.sh` автоматически:

1. ✅ Обновляет систему и устанавливает необходимые пакеты (Python 3.11, Nginx, UFW)
2. ✅ Создает системного пользователя `roblox` для безопасности
3. ✅ Устанавливает проект в `/opt/roblox-auto-joiner`
4. ✅ Создает Python виртуальное окружение и устанавливает зависимости
5. ✅ Настраивает переменные окружения (.env файл)
6. ✅ Регистрирует systemd сервисы для автозапуска
7. ✅ Настраивает Nginx как reverse proxy
8. ✅ Настраивает файрвол (UFW)
9. ✅ Запускает все сервисы

---

## 🔧 Ручная установка (пошагово)

### Шаг 1: Загрузка проекта

Подключитесь к серверу через [app.shellngn.com](https://app.shellngn.com):

```bash
# Клонирование репозитория
git clone <ваш-репозиторий-url> roblox-auto-joiner
cd roblox-auto-joiner
```

Или загрузите архив через SFTP в app.shellngn.com и распакуйте:

```bash
unzip roblox-auto-joiner.zip
cd roblox-auto-joiner
```

### Шаг 2: Запуск установки

```bash
sudo bash deployment/bootstrap.sh
```

### Шаг 3: Настройка (опционально)

Отредактируйте переменные окружения:

```bash
sudo nano /opt/roblox-auto-joiner/.env
```

Важные параметры:
- `DISCORD_TOKEN` - токен Discord бота (если используете мониторинг Discord)
- `API_URL` - публичный URL вашего сервера (автоматически определяется)

После изменений перезапустите сервисы:

```bash
sudo systemctl restart roblox.target
```

---

## 🌐 Доступ к веб-интерфейсу

После установки веб-интерфейс доступен по адресу:

```
http://ВАШ_IP_АДРЕС
```

Найдите ваш IP адрес:

```bash
hostname -I
```

Или просто откройте в браузере:
```
http://78.153.130.35  # Замените на ваш IP
```

---

## 📊 Управление сервисами

### Просмотр статуса

```bash
# Все сервисы
sudo systemctl status roblox.target

# Flask API
sudo systemctl status roblox-flask.service

# WebSocket сервер
sudo systemctl status roblox-websocket.service
```

### Просмотр логов

```bash
# Flask API (реального времени)
sudo journalctl -u roblox-flask.service -f

# WebSocket сервер
sudo journalctl -u roblox-websocket.service -f

# Все логи
sudo journalctl -u roblox.target -f
```

### Управление

```bash
# Перезапуск всех сервисов
sudo systemctl restart roblox.target

# Остановка
sudo systemctl stop roblox.target

# Запуск
sudo systemctl start roblox.target

# Отключить автозапуск
sudo systemctl disable roblox.target

# Включить автозапуск
sudo systemctl enable roblox.target
```

---

## 🔒 Настройка HTTPS (SSL сертификат)

### Установка Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx -y
```

### Получение сертификата

Замените `your-domain.com` на ваш домен:

```bash
sudo certbot --nginx -d your-domain.com
```

Certbot автоматически:
- Получит SSL сертификат
- Настроит Nginx для HTTPS
- Настроит автоматическое обновление

### Проверка автообновления

```bash
sudo certbot renew --dry-run
```

---

## 🔥 Настройка файрвола (UFW)

Скрипт автоматически настраивает файрвол. Для ручной настройки:

```bash
# Включить файрвол
sudo ufw enable

# Разрешить SSH
sudo ufw allow 22/tcp

# Разрешить HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Разрешить прямой доступ к Flask (опционально)
sudo ufw allow 5000/tcp

# Разрешить прямой доступ к WebSocket (опционально)
sudo ufw allow 8765/tcp

# Проверить статус
sudo ufw status
```

---

## 🐛 Устранение неполадок

### Сервисы не запускаются

```bash
# Проверить логи ошибок
sudo journalctl -u roblox-flask.service -n 50 --no-pager
sudo journalctl -u roblox-websocket.service -n 50 --no-pager

# Проверить права доступа
sudo ls -la /opt/roblox-auto-joiner

# Проверить Python окружение
sudo -u roblox /opt/roblox-auto-joiner/venv/bin/python --version
```

### Nginx ошибки

```bash
# Проверить конфигурацию
sudo nginx -t

# Проверить логи Nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Порты заняты

```bash
# Проверить какие процессы используют порты
sudo netstat -tulpn | grep :5000
sudo netstat -tulpn | grep :8765
sudo netstat -tulpn | grep :80
```

### Python версия

Скрипт использует **Python 3.10** (стандартный для Ubuntu 22.04). Если нужна другая версия Python:

```bash
# Для Python 3.11+ добавить PPA deadsnakes
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.11 python3.11-venv -y

# Изменить в deployment/bootstrap.sh:
# python3 -> python3.11
```

### Переустановка

```bash
# Остановить и удалить сервисы
sudo systemctl stop roblox.target
sudo systemctl disable roblox.target
sudo rm /etc/systemd/system/roblox*.service
sudo rm /etc/systemd/system/roblox.target
sudo systemctl daemon-reload

# Удалить проект
sudo rm -rf /opt/roblox-auto-joiner

# Запустить установку заново
cd ~/roblox-auto-joiner
sudo bash deployment/bootstrap.sh
```

---

## 📱 Discord Bot (опционально)

Discord бот используется для мониторинга каналов Discord. Он опционален.

### Настройка Discord токена

1. Получите токен Discord бота на [Discord Developer Portal](https://discord.com/developers/applications)
2. Добавьте токен в `.env`:

```bash
sudo nano /opt/roblox-auto-joiner/.env
# Найдите строку DISCORD_TOKEN и вставьте ваш токен
```

3. Перезапустите сервисы:

```bash
sudo systemctl restart roblox.target
```

### Запуск Discord бота отдельно

Discord бот также можно запустить отдельно:

```bash
sudo -u roblox /opt/roblox-auto-joiner/venv/bin/python /opt/roblox-auto-joiner/discord_bot_http.py
```

---

## 🔄 Обновление проекта

```bash
# Остановить сервисы
sudo systemctl stop roblox.target

# Обновить код
cd ~/roblox-auto-joiner
git pull

# Скопировать новые файлы
sudo cp -r * /opt/roblox-auto-joiner/

# Установить новые зависимости (если есть)
sudo -u roblox /opt/roblox-auto-joiner/venv/bin/pip install -r /opt/roblox-auto-joiner/requirements.txt

# Запустить сервисы
sudo systemctl start roblox.target
```

---

## 📁 Структура установки

```
/opt/roblox-auto-joiner/          # Главная директория
├── venv/                          # Python виртуальное окружение
├── main.py                        # Flask HTTP API
├── websocket_server.py            # WebSocket сервер
├── discord_bot_http.py            # Discord бот (опционально)
├── config.py                      # Конфигурация
├── index.html                     # Веб-интерфейс
├── .env                           # Переменные окружения (секреты)
└── logs/                          # Логи

/etc/systemd/system/               # Systemd сервисы
├── roblox-flask.service           # Flask сервис
├── roblox-websocket.service       # WebSocket сервис
└── roblox.target                  # Группа сервисов

/etc/nginx/sites-available/        # Nginx конфигурация
└── roblox                         # Reverse proxy config
```

---

## 🎯 API Endpoints

После установки доступны следующие endpoints:

- `GET /` - Веб-интерфейс dashboard
- `GET /api/status` - Статус системы
- `POST /api/server/push` - Добавить сервер в очередь
- `GET /api/server/pull` - Получить сервер из очереди
- `POST /api/ping` - Ping endpoint
- `GET /api/logs` - Логи системы

Пример использования:

```bash
# Проверить статус
curl http://localhost:5000/api/status

# Добавить сервер
curl -X POST http://localhost:5000/api/server/push \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Server","money":5.5,"players":"10/18"}'

# Получить сервер
curl http://localhost:5000/api/server/pull
```

---

## 💡 Советы по производительности

### Увеличение количества workers для Gunicorn

Отредактируйте `/etc/systemd/system/roblox-flask.service`:

```ini
ExecStart=/opt/roblox-auto-joiner/venv/bin/gunicorn main:app --bind 0.0.0.0:5000 --workers 4 --timeout 120
```

Затем:

```bash
sudo systemctl daemon-reload
sudo systemctl restart roblox-flask.service
```

### Мониторинг ресурсов

```bash
# CPU и память
htop

# Использование диска
df -h

# Сетевая активность
sudo iftop
```

---

## 📞 Поддержка

При возникновении проблем проверьте:

1. **Логи сервисов**: `journalctl -u roblox.target -f`
2. **Логи Nginx**: `/var/log/nginx/error.log`
3. **Статус сервисов**: `systemctl status roblox.target`
4. **Права доступа**: `ls -la /opt/roblox-auto-joiner`
5. **Файрвол**: `sudo ufw status`

---

**Готово!** Ваш Roblox Auto-Joiner работает на Ubuntu через Shell NG 🚀
