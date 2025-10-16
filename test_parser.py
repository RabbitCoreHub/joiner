#!/usr/bin/env python3
"""
Тестовый файл для проверки улучшенного парсера сообщений Discord
"""

import asyncio
import sys
import os

# Добавляем путь к проекту в sys.path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from discord_bot_http import DiscordMonitor

def test_parsing():
    """Тестовая функция для проверки парсинга сообщений"""
    # Пример сообщения от пользователя
    test_message = """Brainrot Notify | Chilli Hub
🏷️ Name
La Karkerkar Combinasion
💰 Money per sec
$600K/s
👥 Players
5/8
🆔 Job ID (Mobile)
8f4eee40-8091-45fd-86a2-14820a64c502
🆔 Job ID (PC)
8f4eee40-8091-45fd-86a2-14820a64c502
🌐 Join Link
Click to Join
📜 Join Script (PC)
game:GetService("TeleportService"):TeleportToPlaceInstance(109983668079237,"8f4eee40-8091-45fd-86a2-14820a64c502",game.Players.LocalPlayer)
Made by Chilli Hub•Сегодня, в 23:39, бот мог легко достать например 🆔 Job ID (PC)
8f4eee40-8091-45fd-86a2-14820a64c502 записать его как 8f4eee40-8091-45fd-86a2-14820a64c502 и отправить через апи в луа скрипт"""

    # Создаем мок объект сообщения
    mock_message_data = {
        'content': test_message,
        'embeds': []
    }

    # Создаем монитор для тестирования
    monitor = DiscordMonitor("http://test-api.com")

    # Тестируем парсинг
    async def run_test():
        print("🧪 Тестируем парсинг сообщения...")
        print("=" * 80)

        parsed_data = await monitor.parse_message_data(mock_message_data)

        print("📊 РЕЗУЛЬТАТ ПАРСИНГА:")
        print("=" * 50)
        print(f"📛 Название: {parsed_data['name'] or 'Не найдено'}")
        print(f"💰 Деньги: {parsed_data['money']}M/s (сырые: {parsed_data['money_raw']})" if parsed_data['money'] else "💰 Деньги: Не найдено")
        print(f"👥 Игроки: {parsed_data['players'] or 'Не найдено'}")
        print(f"🆔 Job ID: {parsed_data['job_id'] or 'Не найдено'}")
        print(f"📜 Скрипт: {parsed_data['script'] or 'Не найдено'}")
        print(f"🌐 Ссылка: {parsed_data['join_link'] or 'Не найдено'}")
        print(f"💎 10M+: {parsed_data['is_10m_plus']}")
        print(f"🏷️ Источник: {parsed_data.get('source', 'discord')}")

        print("\n" + "=" * 80)
        print("✅ Тест завершен!")

        # Проверяем, что все важные поля найдены
        success = True
        if not parsed_data['job_id']:
            print("❌ Job ID не найден!")
            success = False
        if not parsed_data['name']:
            print("❌ Название не найдено!")
            success = False
        if not parsed_data['money']:
            print("❌ Деньги не найдены!")
            success = False

        if success:
            print("🎉 Все важные поля успешно распарсены!")
        else:
            print("⚠️ Некоторые поля не удалось распарсить")

        return success

    # Запускаем тест
    return asyncio.run(run_test())

if __name__ == "__main__":
    success = test_parsing()
    print(f"\n{'🎉 ТЕСТ ПРОЙДЕН!' if success else '❌ ТЕСТ ПРОВАЛЕН!'}")
