-- Roblox Auto-Joiner - HTTP Edition with Key System
-- by IceHub, RabbitCore

-- Configuration
local API_URL = "https://4bda1b43-c044-412e-aa60-c920e3a5210c-00-tf46e32wscpo.spock.replit.dev"
local POLL_INTERVAL = 2
local JOIN_TIMEOUT = 5

-- Services
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

-- State
local isJoining = false
local autoJoinEnabled = true
local lastJobId = nil
local isRunning = true
local isAuthenticated = false
local currentKey = nil
local playerUsername = Players.LocalPlayer.Name

-- GUI References
local gui = nil
local keyFrame = nil
local mainFrame = nil
local statusLabel = nil
local nameLabel = nil
local moneyLabel = nil
local playersLabel = nil
local autoJoinButton = nil

-- Colors
local ACCENT_COLOR = Color3.fromRGB(88, 101, 242)
local BG_COLOR = Color3.fromRGB(32, 34, 37)
local SECONDARY_BG = Color3.fromRGB(47, 49, 54)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local SUCCESS_COLOR = Color3.fromRGB(87, 242, 135)
local ERROR_COLOR = Color3.fromRGB(237, 66, 69)
local WARNING_COLOR = Color3.fromRGB(254, 231, 92)

-- Utility Functions
local function httpRequest(url, method, body)
    local success, response = pcall(function()
        if request then
            -- Используем кастомный HTTP клиент (для эксплоитов)
            local httpResponse = request({
                Url = url,
                Method = method or "GET",
                Headers = {["Content-Type"] = "application/json"},
                Body = body and HttpService:JSONEncode(body) or nil
            })
            if httpResponse.StatusCode == 200 or httpResponse.StatusCode == "200" then
                return httpResponse.Body
            else
                print("[HTTP ERROR] Status Code: " .. tostring(httpResponse.StatusCode))
                print("[HTTP ERROR] URL: " .. url)
                error("HTTP Error: " .. tostring(httpResponse.StatusCode))
            end
        else
            -- Используем встроенный HttpService
            if method == "POST" then
                return HttpService:PostAsync(url, HttpService:JSONEncode(body), Enum.HttpContentType.ApplicationJson)
            else
                return HttpService:GetAsync(url)
            end
        end
    end)

    if success and response then
        local parseSuccess, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        if parseSuccess and data then
            return data
        else
            print("[JSON ERROR] Failed to parse response")
            print("[JSON ERROR] Response: " .. tostring(response))
        end
    else
        print("[REQUEST ERROR] " .. tostring(response))
    end

    return nil
end

local function log(message, color)
    print("[" .. os.date("%H:%M:%S") .. "] " .. message)
    if statusLabel then
        statusLabel.Text = message
        statusLabel.TextColor3 = color or TEXT_COLOR
    end
end

local function tweenSize(object, endSize, duration)
    local TweenService = game:GetService("TweenService")
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {Size = endSize}
    )
    tween:Play()
end

local function tweenBackgroundColor(object, endColor, duration)
    local TweenService = game:GetService("TweenService")
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Linear),
        {BackgroundColor3 = endColor}
    )
    tween:Play()
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function createGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(137, 87, 229))
    })
    gradient.Rotation = 45
    gradient.Parent = parent
    return gradient
end

local function makeDraggable(frame)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function checkPlayerKey()
    local data = httpRequest(API_URL .. "/api/keys/check_player", "POST", {
        player_username = playerUsername
    })

    if data and data.has_key and data.key then
        currentKey = data.key
        print("[" .. os.date("%H:%M:%S") .. "] ✅ Ключ найден: " .. data.key:sub(1, 8) .. "...")
        return true
    end

    print("[" .. os.date("%H:%M:%S") .. "] ❌ Ключ не найден для игрока: " .. playerUsername)
    return false
end

local function activateKey(key)
    print("[ACTIVATE] Attempting to activate key: " .. key:sub(1, 8) .. "...")
    print("[ACTIVATE] Player: " .. playerUsername)
    print("[ACTIVATE] API URL: " .. API_URL)
    
    local data = httpRequest(API_URL .. "/api/keys/activate", "POST", {
        key = key,
        player_username = playerUsername
    })

    if not data then
        print("[ACTIVATE] No response from server!")
        return false, "Ошибка подключения к серверу. Проверьте:\n1. Интернет соединение\n2. API URL правильный\n3. HttpService включен"
    end

    print("[ACTIVATE] Response: " .. HttpService:JSONEncode(data))

    if data.success then
        if data.message == "KEY_ACTIVATED" then
            print("[ACTIVATE] Key activated successfully!")
            return true, "Ключ успешно активирован!"
        elseif data.message == "KEY_ALREADY_OWNED" then
            print("[ACTIVATE] Welcome back!")
            return true, "Добро пожаловать обратно!"
        end
    else
        if data.error == "KEY_NOT_FOUND" then
            print("[ACTIVATE] Key not found!")
            return false, "КЛЮЧ НЕВЕРНЫЙ"
        elseif data.error == "KEY_FROZEN" then
            print("[ACTIVATE] Key is frozen!")
            return false, "КЛЮЧ ЗАМОРОЖЕН"
        elseif data.error == "KEY_ALREADY_ACTIVATED" then
            print("[ACTIVATE] Key already activated by another player!")
            return false, "КЛЮЧ УЖЕ АКТИВИРОВАН ДРУГИМ ИГРОКОМ!"
        else
            print("[ACTIVATE] Unknown error: " .. tostring(data.error))
            return false, "Ошибка: " .. tostring(data.error)
        end
    end

    return false, "Неизвестная ошибка"
end

local function updateGUI(serverData)
    if not gui then return end

    if nameLabel then
        nameLabel.Text = serverData.name or "Unknown Server"
    end

    if moneyLabel then
        local moneyValue = tonumber(serverData.money) or 0
        moneyLabel.Text = string.format("%.1fM/s", moneyValue)
        
        if serverData.is_10m_plus then
            moneyLabel.TextColor3 = WARNING_COLOR
        else
            moneyLabel.TextColor3 = SUCCESS_COLOR
        end
    end

    if playersLabel then
        playersLabel.Text = serverData.players or "0/0"
    end
end

local function joinServer(serverData)
    if not isAuthenticated then
        return
    end

    if not autoJoinEnabled then
        log("Auto-join is disabled", WARNING_COLOR)
        return
    end

    if isJoining then
        log("Already attempting to join...", WARNING_COLOR)
        return
    end

    if not serverData.job_id or serverData.job_id == "" then
        log("No job ID available", ERROR_COLOR)
        return
    end

    if serverData.job_id == lastJobId then
        log("Skipping duplicate server", WARNING_COLOR)
        return
    end

    lastJobId = serverData.job_id
    isJoining = true
    
    log("Attempting to join: " .. (serverData.name or "Unknown"), ACCENT_COLOR)

    local teleportConnection
    teleportConnection = TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        if player == Players.LocalPlayer then
            log("Teleport failed: " .. errorMessage, ERROR_COLOR)
            log("Moving to next server...", WARNING_COLOR)

            isJoining = false
            lastJobId = nil

            if teleportConnection then
                teleportConnection:Disconnect()
            end
        end
    end)

    task.spawn(function()
        local success, errorMessage = pcall(function()
            local placeId = 109983668079237
            local jobId = serverData.job_id
            
            TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
        end)

        if not success then
            log("Join failed: " .. tostring(errorMessage), ERROR_COLOR)
            log("Moving to next server...", WARNING_COLOR)

            isJoining = false
            lastJobId = nil

            if teleportConnection then
                teleportConnection:Disconnect()
            end
        else
            log("Teleport initiated...", SUCCESS_COLOR)
        end
    end)
end

local function fetchServerData()
    if not isAuthenticated then
        return nil
    end

    local data = httpRequest(API_URL .. "/api/server/pull")

    if data and data.status == "success" and data.data then
        return data.data
    end

    return nil
end

local function startPolling()
    task.spawn(function()
        log("Starting HTTP polling...", SUCCESS_COLOR)
        
        while isRunning do
            if isAuthenticated and autoJoinEnabled and not isJoining then
                local serverData = fetchServerData()
                
                if serverData and serverData.job_id and serverData.job_id ~= "" then
                    log("New server data received!", SUCCESS_COLOR)
                    updateGUI(serverData)
                    joinServer(serverData)
                end
            end
            
            task.wait(POLL_INTERVAL)
        end
    end)
end

local function createKeyGUI()
    gui = Instance.new("ScreenGui")
    gui.Name = "RobloxAutoJoiner"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(0, 450, 0, 0)
    keyFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    keyFrame.BackgroundColor3 = BG_COLOR
    keyFrame.BorderSizePixel = 0
    keyFrame.Parent = gui
    createCorner(keyFrame, 12)
    
    makeDraggable(keyFrame)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 70)
    header.BackgroundColor3 = ACCENT_COLOR
    header.BorderSizePixel = 0
    header.Parent = keyFrame
    createCorner(header, 12)
    createGradient(header)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 35)
    titleLabel.Position = UDim2.new(0, 10, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔐 АКТИВАЦИЯ КЛЮЧА"
    titleLabel.TextColor3 = TEXT_COLOR
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 22
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = header

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1, -20, 0, 20)
    subtitleLabel.Position = UDim2.new(0, 10, 0, 45)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "Введите ключ доступа для использования авто-джойнера"
    subtitleLabel.TextColor3 = TEXT_COLOR
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextSize = 12
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    subtitleLabel.TextTransparency = 0.3
    subtitleLabel.Parent = header

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -40, 1, -100)
    content.Position = UDim2.new(0, 20, 0, 80)
    content.BackgroundTransparency = 1
    content.Parent = keyFrame

    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(1, 0, 0, 50)
    keyInput.Position = UDim2.new(0, 0, 0, 20)
    keyInput.BackgroundColor3 = SECONDARY_BG
    keyInput.BorderSizePixel = 0
    keyInput.PlaceholderText = "Вставьте ваш ключ доступа..."
    keyInput.Text = ""
    keyInput.TextColor3 = TEXT_COLOR
    keyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    keyInput.Font = Enum.Font.GothamMedium
    keyInput.TextSize = 14
    keyInput.ClearTextOnFocus = false
    keyInput.Parent = content
    createCorner(keyInput, 10)

    local keyStatusLabel = Instance.new("TextLabel")
    keyStatusLabel.Size = UDim2.new(1, 0, 0, 30)
    keyStatusLabel.Position = UDim2.new(0, 0, 0, 80)
    keyStatusLabel.BackgroundTransparency = 1
    keyStatusLabel.Text = ""
    keyStatusLabel.TextColor3 = TEXT_COLOR
    keyStatusLabel.Font = Enum.Font.Gotham
    keyStatusLabel.TextSize = 13
    keyStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
    keyStatusLabel.Parent = content

    local activateButton = Instance.new("TextButton")
    activateButton.Size = UDim2.new(1, 0, 0, 50)
    activateButton.Position = UDim2.new(0, 0, 0, 120)
    activateButton.BackgroundColor3 = SUCCESS_COLOR
    activateButton.Text = "✅ АКТИВИРОВАТЬ КЛЮЧ"
    activateButton.TextColor3 = TEXT_COLOR
    activateButton.Font = Enum.Font.GothamBold
    activateButton.TextSize = 16
    activateButton.BorderSizePixel = 0
    activateButton.Parent = content
    createCorner(activateButton, 10)

    activateButton.MouseButton1Click:Connect(function()
        local key = keyInput.Text

        if key == "" or #key < 10 then
            keyStatusLabel.Text = "⚠️ Введите действительный ключ"
            keyStatusLabel.TextColor3 = WARNING_COLOR
            return
        end

        activateButton.Text = "⏳ Проверка ключа..."
        activateButton.BackgroundColor3 = WARNING_COLOR
        
        task.wait(0.5)
        
        local success, message = activateKey(key)

        if success then
            keyStatusLabel.Text = "✅ " .. message
            keyStatusLabel.TextColor3 = SUCCESS_COLOR
            currentKey = key
            isAuthenticated = true

            task.wait(1)
            
            tweenSize(keyFrame, UDim2.new(0, 450, 0, 0), 0.3)
            task.wait(0.3)
            keyFrame:Destroy()
            createMainGUI()
            startPolling()
        else
            keyStatusLabel.Text = "❌ " .. message
            keyStatusLabel.TextColor3 = ERROR_COLOR
            activateButton.Text = "✅ АКТИВИРОВАТЬ КЛЮЧ"
            activateButton.BackgroundColor3 = SUCCESS_COLOR
        end
    end)

    gui.Parent = game:GetService("CoreGui")

    tweenSize(keyFrame, UDim2.new(0, 450, 0, 230), 0.5)
end

function createMainGUI()
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 0)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
    mainFrame.BackgroundColor3 = BG_COLOR
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    createCorner(mainFrame, 12)
    
    makeDraggable(mainFrame)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = ACCENT_COLOR
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    createCorner(header, 12)
    createGradient(header)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "AUTO-JOINER (ACTIVE)"
    titleLabel.TextColor3 = TEXT_COLOR
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Size = UDim2.new(1, -20, 0, 20)
    subtitleLabel.Position = UDim2.new(0, 10, 0, 35)
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Text = "by IceHub, RabbitCore | " .. playerUsername
    subtitleLabel.TextColor3 = TEXT_COLOR
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextSize = 12
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    subtitleLabel.TextTransparency = 0.3
    subtitleLabel.Parent = header

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundTransparency = 0.9
    closeButton.Text = "X"
    closeButton.TextColor3 = TEXT_COLOR
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.BorderSizePixel = 0
    closeButton.Parent = header
    createCorner(closeButton, 8)

    closeButton.MouseEnter:Connect(function()
        tweenBackgroundColor(closeButton, Color3.fromRGB(237, 66, 69), 0.2)
    end)

    closeButton.MouseLeave:Connect(function()
        tweenBackgroundColor(closeButton, Color3.fromRGB(255, 255, 255), 0.2)
        closeButton.BackgroundTransparency = 0.9
    end)

    closeButton.MouseButton1Click:Connect(function()
        isRunning = false
        tweenSize(mainFrame, UDim2.new(0, 400, 0, 0), 0.3)
        task.wait(0.3)
        gui:Destroy()
    end)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -40, 1, -100)
    content.Position = UDim2.new(0, 20, 0, 70)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame

    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, 0, 0, 120)
    infoCard.BackgroundColor3 = SECONDARY_BG
    infoCard.BorderSizePixel = 0
    infoCard.Parent = content
    createCorner(infoCard, 10)

    local nameContainer = Instance.new("Frame")
    nameContainer.Size = UDim2.new(1, -20, 0, 30)
    nameContainer.Position = UDim2.new(0, 10, 0, 10)
    nameContainer.BackgroundTransparency = 1
    nameContainer.Parent = infoCard

    local nameTitle = Instance.new("TextLabel")
    nameTitle.Size = UDim2.new(0, 100, 1, 0)
    nameTitle.BackgroundTransparency = 1
    nameTitle.Text = "SERVER NAME"
    nameTitle.TextColor3 = TEXT_COLOR
    nameTitle.Font = Enum.Font.GothamBold
    nameTitle.TextSize = 11
    nameTitle.TextXAlignment = Enum.TextXAlignment.Left
    nameTitle.TextTransparency = 0.5
    nameTitle.Parent = nameContainer

    nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -110, 1, 0)
    nameLabel.Position = UDim2.new(0, 110, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Waiting for data..."
    nameLabel.TextColor3 = TEXT_COLOR
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Right
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = nameContainer

    local moneyContainer = Instance.new("Frame")
    moneyContainer.Size = UDim2.new(1, -20, 0, 30)
    moneyContainer.Position = UDim2.new(0, 10, 0, 45)
    moneyContainer.BackgroundTransparency = 1
    moneyContainer.Parent = infoCard

    local moneyTitle = Instance.new("TextLabel")
    moneyTitle.Size = UDim2.new(0, 100, 1, 0)
    moneyTitle.BackgroundTransparency = 1
    moneyTitle.Text = "MONEY/SEC"
    moneyTitle.TextColor3 = TEXT_COLOR
    moneyTitle.Font = Enum.Font.GothamBold
    moneyTitle.TextSize = 11
    moneyTitle.TextXAlignment = Enum.TextXAlignment.Left
    moneyTitle.TextTransparency = 0.5
    moneyTitle.Parent = moneyContainer

    moneyLabel = Instance.new("TextLabel")
    moneyLabel.Size = UDim2.new(1, -110, 1, 0)
    moneyLabel.Position = UDim2.new(0, 110, 0, 0)
    moneyLabel.BackgroundTransparency = 1
    moneyLabel.Text = "0.0M/s"
    moneyLabel.TextColor3 = SUCCESS_COLOR
    moneyLabel.Font = Enum.Font.GothamBold
    moneyLabel.TextSize = 16
    moneyLabel.TextXAlignment = Enum.TextXAlignment.Right
    moneyLabel.Parent = moneyContainer

    local playersContainer = Instance.new("Frame")
    playersContainer.Size = UDim2.new(1, -20, 0, 30)
    playersContainer.Position = UDim2.new(0, 10, 0, 80)
    playersContainer.BackgroundTransparency = 1
    playersContainer.Parent = infoCard

    local playersTitle = Instance.new("TextLabel")
    playersTitle.Size = UDim2.new(0, 100, 1, 0)
    playersTitle.BackgroundTransparency = 1
    playersTitle.Text = "PLAYERS"
    playersTitle.TextColor3 = TEXT_COLOR
    playersTitle.Font = Enum.Font.GothamBold
    playersTitle.TextSize = 11
    playersTitle.TextXAlignment = Enum.TextXAlignment.Left
    playersTitle.TextTransparency = 0.5
    playersTitle.Parent = playersContainer

    playersLabel = Instance.new("TextLabel")
    playersLabel.Size = UDim2.new(1, -110, 1, 0)
    playersLabel.Position = UDim2.new(0, 110, 0, 0)
    playersLabel.BackgroundTransparency = 1
    playersLabel.Text = "0/0"
    playersLabel.TextColor3 = TEXT_COLOR
    playersLabel.Font = Enum.Font.Gotham
    playersLabel.TextSize = 13
    playersLabel.TextXAlignment = Enum.TextXAlignment.Right
    playersLabel.Parent = playersContainer

    autoJoinButton = Instance.new("TextButton")
    autoJoinButton.Size = UDim2.new(1, 0, 0, 45)
    autoJoinButton.Position = UDim2.new(0, 0, 0, 135)
    autoJoinButton.BackgroundColor3 = SUCCESS_COLOR
    autoJoinButton.Text = "AUTO-JOIN: ON"
    autoJoinButton.TextColor3 = TEXT_COLOR
    autoJoinButton.Font = Enum.Font.GothamBold
    autoJoinButton.TextSize = 14
    autoJoinButton.BorderSizePixel = 0
    autoJoinButton.Parent = content
    createCorner(autoJoinButton, 10)

    autoJoinButton.MouseButton1Click:Connect(function()
        autoJoinEnabled = not autoJoinEnabled
        if autoJoinEnabled then
            autoJoinButton.Text = "AUTO-JOIN: ON"
            tweenBackgroundColor(autoJoinButton, SUCCESS_COLOR, 0.2)
            log("Auto-join enabled", SUCCESS_COLOR)
        else
            autoJoinButton.Text = "AUTO-JOIN: OFF"
            tweenBackgroundColor(autoJoinButton, ERROR_COLOR, 0.2)
            log("Auto-join disabled", ERROR_COLOR)
        end
    end)

    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, 0, 0, 40)
    statusBar.Position = UDim2.new(0, 0, 0, 195)
    statusBar.BackgroundColor3 = SECONDARY_BG
    statusBar.BorderSizePixel = 0
    statusBar.Parent = content
    createCorner(statusBar, 10)

    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 1, 0)
    statusLabel.Position = UDim2.new(0, 10, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Connected to API!"
    statusLabel.TextColor3 = SUCCESS_COLOR
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusBar

    tweenSize(mainFrame, UDim2.new(0, 400, 0, 280), 0.5)

    log("GUI created successfully", SUCCESS_COLOR)
end

-- Main execution
print("[" .. os.date("%H:%M:%S") .. "] Starting Roblox Auto-Joiner with Key System...")
print("[" .. os.date("%H:%M:%S") .. "] API URL: " .. API_URL)
print("[" .. os.date("%H:%M:%S") .. "] Player: " .. playerUsername)

if checkPlayerKey() then
    print("[" .. os.date("%H:%M:%S") .. "] Player already has an active key!")
    isAuthenticated = true
    gui = Instance.new("ScreenGui")
    gui.Name = "RobloxAutoJoiner"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game:GetService("CoreGui")
    createMainGUI()
    task.wait(0.5)
    startPolling()
else
    print("[" .. os.date("%H:%M:%S") .. "] No key found. Opening key activation GUI...")
    createKeyGUI()
end
