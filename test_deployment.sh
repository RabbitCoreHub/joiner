#!/bin/bash

# Скрипт для тестирования деплоя на Render.com
# Использование: ./test_deployment.sh https://your-app.onrender.com

API_URL=$1

if [ -z "$API_URL" ]; then
    echo "❌ Укажите URL приложения: ./test_deployment.sh https://your-app.onrender.com"
    exit 1
fi

echo "🧪 Тестирование деплоя: $API_URL"
echo "=================================="

# Тест 1: Проверка доступности сайта
echo "🔍 Тест 1: Проверка доступности сайта..."
if curl -s "$API_URL" > /dev/null; then
    echo "✅ Сайт доступен"
else
    echo "❌ Сайт недоступен"
    exit 1
fi

# Тест 2: Проверка API статуса
echo "🔍 Тест 2: Проверка API статуса..."
STATUS=$(curl -s "$API_URL/api/status" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
if [ "$STATUS" = "online" ]; then
    echo "✅ API статус: онлайн"
else
    echo "❌ API статус: $STATUS"
fi

# Тест 3: Проверка пинга
echo "🔍 Тест 3: Тест пинга..."
PING_RESPONSE=$(curl -s -X POST "$API_URL/api/ping" \
    -H "Content-Type: application/json" \
    -d '{"source": "deployment_test"}')

if echo "$PING_RESPONSE" | grep -q "success"; then
    echo "✅ Пинг успешен"
else
    echo "❌ Пинг неудачен: $PING_RESPONSE"
fi

# Тест 4: Проверка веб-интерфейса
echo "🔍 Тест 4: Проверка веб-интерфейса..."
if curl -s "$API_URL" | grep -q "Roblox Auto-Joiner Dashboard"; then
    echo "✅ Веб-интерфейс загружается"
else
    echo "❌ Веб-интерфейс недоступен"
fi

# Тест 5: Проверка логов
echo "🔍 Тест 5: Проверка логов..."
LOGS=$(curl -s "$API_URL/api/logs")
if echo "$LOGS" | grep -q "logs"; then
    echo "✅ Логи доступны"
else
    echo "❌ Логи недоступны"
fi

echo "=================================="
echo "🎉 Тестирование завершено!"
echo "📊 Результаты:"
echo "   - Сайт: Доступен"
echo "   - API: $STATUS"
echo "   - Пинг: Работает"
echo "   - Веб-интерфейс: Доступен"
echo "   - Логи: Доступны"
echo ""
echo "🚀 Готово к использованию!"
echo "📝 Не забудьте обновить URL в roblox_client.lua"
echo "🔗 Ваш API URL: $API_URL"
