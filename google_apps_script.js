function pingWebsite() {
  // URL вашего сайта на Render.com (замените на реальный)
  var url = "https://givescript.onrender.com/api/ping";

  var payload = {
    "source": "google_apps_script",
    "timestamp": new Date().toISOString(),
    "uptime_seconds": getUptimeSeconds()
  };

  var options = {
    "method": "post",
    "contentType": "application/json",
    "payload": JSON.stringify(payload),
    "muteHttpExceptions": true
  };

  try {
    var response = UrlFetchApp.fetch(url, options);
    Logger.log("✅ Пинг успешен: " + response.getResponseCode());

    if (response.getResponseCode() === 200) {
      var responseData = JSON.parse(response.getContentText());
      Logger.log("📡 Ответ сервера: " + JSON.stringify(responseData));
      return true;
    } else {
      Logger.log("❌ Ошибка HTTP: " + response.getResponseCode());
      return false;
    }
  } catch (error) {
    Logger.log("❌ Ошибка сети: " + error.toString());
    return false;
  }
}

function getUptimeSeconds() {
  // Пример расчета uptime (может потребоваться доработка)
  var scriptStartTime = new Date("2024-01-01T00:00:00Z"); // Замените на время запуска скрипта
  var now = new Date();
  return Math.floor((now - scriptStartTime) / 1000);
}

// Функция для создания триггера (запускается автоматически)
function createTrigger() {
  // Удаляем существующие триггеры
  deleteTriggers();

  // Создаем новый триггер на каждые 5 минут
  ScriptApp.newTrigger("pingWebsite")
    .timeBased()
    .everyMinutes(5)
    .create();

  Logger.log("✅ Триггер создан - пинг каждые 5 минут");
}

function deleteTriggers() {
  var triggers = ScriptApp.getProjectTriggers();
  for (var i = 0; i < triggers.length; i++) {
    ScriptApp.deleteTrigger(triggers[i]);
  }
}

// Функция для ручного запуска пинга
function manualPing() {
  Logger.log("🔄 Запуск ручного пинга...");
  return pingWebsite();
}

// Функция для проверки статуса сайта
function checkWebsiteStatus() {
  var url = "https://givescript.onrender.com/api/status"; // Замените на реальный URL

  try {
    var response = UrlFetchApp.fetch(url);
    if (response.getResponseCode() === 200) {
      var data = JSON.parse(response.getContentText());
      Logger.log("🌐 Статус сайта: " + JSON.stringify(data));
      return data;
    }
  } catch (error) {
    Logger.log("❌ Не удалось получить статус сайта: " + error.toString());
  }
  return null;
}
