# 📦 Deployment Files - Файлы для развертывания

Эта папка содержит все необходимые файлы для автоматического развертывания проекта на Ubuntu 22.04+ сервере.

## 🚀 Быстрый старт

### Метод 1: Прямая установка на сервере (через Shell NG)

Подключитесь к серверу через [app.shellngn.com](https://app.shellngn.com) и выполните:

```bash
# Клонировать проект
git clone <ваш-репозиторий-url> roblox-auto-joiner
cd roblox-auto-joiner

# Запустить автоматическую установку
sudo bash deployment/bootstrap.sh
```

### Метод 2: Загрузка с локального компьютера

С вашего локального компьютера:

```bash
# Загрузить и установить на удаленный сервер
bash deployment/upload-to-server.sh root@78.153.130.35
```

Замените `root@78.153.130.35` на ваш сервер.

## 📁 Файлы в этой папке

- **bootstrap.sh** - Главный скрипт автоматической установки
- **upload-to-server.sh** - Скрипт загрузки проекта на сервер
- **.env.template** - Шаблон переменных окружения
- **roblox-flask.service** - Systemd сервис для Flask API
- **roblox-websocket.service** - Systemd сервис для WebSocket
- **roblox.target** - Systemd target для управления всеми сервисами
- **nginx-roblox.conf** - Конфигурация Nginx reverse proxy

## 🔧 Что делает bootstrap.sh

1. ✅ Устанавливает Python 3.11, Nginx, UFW
2. ✅ Создает пользователя `roblox`
3. ✅ Устанавливает проект в `/opt/roblox-auto-joiner`
4. ✅ Создает Python venv и устанавливает зависимости
5. ✅ Настраивает systemd сервисы
6. ✅ Настраивает Nginx
7. ✅ Настраивает файрвол
8. ✅ Запускает все сервисы

## 📊 После установки

### Доступ к веб-интерфейсу
```
http://ВАШ_IP_АДРЕС
```

### Управление сервисами
```bash
# Статус
sudo systemctl status roblox.target

# Перезапуск
sudo systemctl restart roblox.target

# Логи
sudo journalctl -u roblox.target -f
```

### Настройка
```bash
# Редактировать конфигурацию
sudo nano /opt/roblox-auto-joiner/.env

# Перезапустить после изменений
sudo systemctl restart roblox.target
```

## 📖 Подробная документация

Смотрите [DEPLOY_UBUNTU.md](../DEPLOY_UBUNTU.md) для полной инструкции.

## 🔒 HTTPS (SSL)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 🐛 Устранение неполадок

```bash
# Проверить логи
sudo journalctl -u roblox-flask.service -n 50
sudo journalctl -u roblox-websocket.service -n 50

# Проверить Nginx
sudo nginx -t
sudo tail -f /var/log/nginx/error.log

# Проверить порты
sudo netstat -tulpn | grep -E ':(5000|8765|80)'
```

## ⚡ Требования

- Ubuntu 22.04+ (или Debian 11+)
- Права root или sudo
- Минимум 1GB RAM
- Минимум 10GB свободного места

---

**Все готово!** Просто запустите `bootstrap.sh` и сервер заработает автоматически 🚀
