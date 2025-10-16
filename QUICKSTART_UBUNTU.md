# ⚡ Быстрый старт - Ubuntu развертывание

## 🎯 Один шаг до запуска!

### Через Shell NG (app.shellngn.com)

1. Подключитесь к вашему Ubuntu серверу через [app.shellngn.com](https://app.shellngn.com)
2. Выполните:

```bash
git clone <ваш-репозиторий-url> roblox-auto-joiner
cd roblox-auto-joiner
sudo bash deployment/bootstrap.sh
```

**Готово!** Сервер установлен и работает.

---

## 🌐 Доступ

Откройте в браузере:
```
http://ВАШ_IP_АДРЕС
```

Узнать IP:
```bash
hostname -I
```

---

## 📊 Быстрые команды

```bash
# Статус
sudo systemctl status roblox.target

# Логи
sudo journalctl -u roblox.target -f

# Перезапуск
sudo systemctl restart roblox.target

# Настройка
sudo nano /opt/roblox-auto-joiner/.env
```

---

## 📖 Полная документация

- **[DEPLOY_UBUNTU.md](DEPLOY_UBUNTU.md)** - Подробная инструкция
- **[deployment/README.md](deployment/README.md)** - О файлах развертывания

---

**IP вашего сервера:** `78.153.130.35`

Просто вставьте команды выше в терминал Shell NG! 🚀
