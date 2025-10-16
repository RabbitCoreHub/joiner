--[[ ❄️ Ice Hub Servers ❄️ ]]
-- Full Pet Sniper + ESP + Webhook A + Webhook B + Auto Server Hop + Auto Restart + 👥 Players
-- Steal a Brainrot — Script Completo con Traits y Mutaciones actualizados (Agosto 2025)

--// 🎯 Targeted Pet Configuration
getgenv().WebhookATargets = {
    'Chicleteira Bicicleteira',
    'Dragon Cannelloni',
    'La Grande Combinasion',
    'Garama and Madundung',
    'Nuclearo Dinossauro',
    'Los Combinasionas',
    'Esok Sekolah',
    'Los Hotspotitos',
    'Pot Hostpot',
}

getgenv().WebhookBTargets = {
    'La Vacca Saturno Saturnita',
    'Chimpanzini Spiderini',
    'Los Tralaleritos',
    'Tortuginni Dragonfrutini',
    'Las Vaquitas Saturnitas',
    'Graipuss Medussi',
    'Las Tralaleritas',
}

--// 🌐 Webhooks
local webhookA_Temprana =
    'https://discord.com/api/webhooks/1422271004217966683/tyIL3yfzm1VcnDZZy61S38S7GgXoTV7Xb510NugrlxBxhA6RDSympevHREryJklqx5CJ'
local webhookA =
    'https://discord.com/api/webhooks/1422271004217966683/tyIL3yfzm1VcnDZZy61S38S7GgXoTV7Xb510NugrlxBxhA6RDSympevHREryJklqx5CJ'
local webhookB =
    'https://discord.com/api/webhooks/1422271004217966683/tyIL3yfzm1VcnDZZy61S38S7GgXoTV7Xb510NugrlxBxhA6RDSympevHREryJklqx5CJ'

--// 🔧 Services
local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')
local TeleportService = game:GetService('TeleportService')
local LocalPlayer = Players.LocalPlayer

--// 📦 State
local visitedJobIds = { [game.JobId] = true }
local hops = 0
local maxHopsBeforeReset = 500
local maxTeleportRetries = 15

--// 🧠 Brainrot Data (base values)
local brainrotData = {
    ['Dragon Cannelloni'] = { baseValue = 100000000 },
    ['Chicleteira Bicicleteira'] = { baseValue = 3500000 },
    ['Los Combinasionas'] = { baseValue = 15000000 },
    ['La Grande Combinasion'] = { baseValue = 10000000 },
    ['Garama and Madundung'] = { baseValue = 50000000 },
    ['Nuclearo Dinossauro'] = { baseValue = 15000000 },
    ['Esok Sekolah'] = { baseValue = 30000000 },
    ['Los Hotspotitos'] = { baseValue = 20000000 },
    ['Pot Hostpot'] = { baseValue = 2500000 },

    ['La Vacca Saturno Saturnita'] = { baseValue = 250000 },
    ['Chimpanzini Spiderini'] = { baseValue = 325000 },
    ['Los Tralaleritos'] = { baseValue = 500000 },
    ['Tortuginni Dragonfrutini'] = { baseValue = 350000 },
    ['Las Vaquitas Saturnitas'] = { baseValue = 750000 },
    ['Graipuss Medussi'] = { baseValue = 1000000 },
    ['Las Tralaleritas'] = { baseValue = 650000 },
}

--// Trait y Mutación multipliers (Steal a Brainrot)
local traitMultipliers = {
    -- Traits
    Taco = 3,
    ['Nyan'] = 6,
    ['Claws'] = 5,
    ['Tung Tung Attack'] = 4,
    Bubblegum = 4,
    Cometstruck = 4,
    Glitched = 5,
    ['Fire (Solar Flare)'] = 5,
    Concert = 5,
    Shark = 4,
    ['10B Visits'] = 4,
    Rain = 4,
    Snowy = 3,
    Starfall = 6,
    ['Brazil'] = 6,
    ["Matteo's Hat"] = 4,
    Galactic = 4,
    Asteroid = 4,
    Firework = 6,

    -- Mutaciones
    Rainbow = 10,
    Gold = 1.25,
    Diamond = 1.5,
    ['Blood Root'] = 2,
    Candy = 5,
}

--// Función para obtener owner del pet - ИСПРАВЛЕННАЯ
local function getPetOwner(petModel)
    -- Ищем в StringValue с разными вариантами названий
    for _, child in ipairs(petModel:GetDescendants()) do
        if child:IsA('StringValue') then
            local nameLower = string.lower(child.Name)
            if
                nameLower == 'owner'
                or nameLower == 'playername'
                or nameLower == 'username'
            then
                if child.Value and child.Value ~= '' then
                    return child.Value
                end
            end
        end
    end

    -- Ищем в ObjectValue (часто используется для связи с игроком)
    for _, child in ipairs(petModel:GetDescendants()) do
        if child:IsA('ObjectValue') then
            local nameLower = string.lower(child.Name)
            if
                (nameLower == 'owner' or nameLower == 'player') and child.Value
            then
                if child.Value:IsA('Player') then
                    return child.Value.Name
                end
            end
        end
    end

    -- Ищем в атрибутах
    for attrName, attrValue in pairs(petModel:GetAttributes()) do
        local nameLower = string.lower(tostring(attrName))
        if nameLower == 'owner' or nameLower == 'playername' then
            if attrValue and attrValue ~= '' then
                return tostring(attrValue)
            end
        end
    end

    -- Проверяем родительскую структуру (часто питомцы находятся в папке игрока)
    local parent = petModel.Parent
    if parent then
        -- Если родитель - игрок
        for _, player in ipairs(Players:GetPlayers()) do
            if parent.Name == player.Name then
                return player.Name
            end
        end

        -- Если родительская папка называется как игрок
        for _, player in ipairs(Players:GetPlayers()) do
            if string.find(parent.Name, player.Name) then
                return player.Name
            end
        end
    end

    -- Проверяем близость к игрокам (последний вариант)
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local playerRoot =
                player.Character:FindFirstChild('HumanoidRootPart')
            local petRoot = petModel:FindFirstChild('HumanoidRootPart')
                or petModel:FindFirstChildWhichIsA('Part')

            if playerRoot and petRoot then
                local distance = (playerRoot.Position - petRoot.Position).Magnitude
                if distance < 30 and distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player.Name
                end
            end
        end
    end

    if closestPlayer then
        return closestPlayer
    end

    -- Проверяем Script внутри питомца который может содержать информацию о владельце
    for _, child in ipairs(petModel:GetDescendants()) do
        if child:IsA('Script') then
            local source = child.Source
            if source then
                -- Ищем упоминания игроков в коде
                for _, player in ipairs(Players:GetPlayers()) do
                    if string.find(source, player.Name) then
                        return player.Name
                    end
                end
            end
        end
    end

    return 'Unknown'
end

--// Función para obtener traits
local function getTraits(petModel)
    local traits = {}
    for _, child in ipairs(petModel:GetDescendants()) do
        if
            child:IsA('StringValue')
            or child:IsA('IntValue')
            or child:IsA('NumberValue')
        then
            local nameLower = string.lower(child.Name)
            if
                string.find(nameLower, 'trait')
                or string.find(nameLower, 'mutation')
                or string.find(nameLower, 'effect')
            then
                table.insert(traits, tostring(child.Value))
            end
        end
    end
    for attrName, attrValue in pairs(petModel:GetAttributes()) do
        local nameLower = string.lower(attrName)
        if
            string.find(nameLower, 'trait')
            or string.find(nameLower, 'mutation')
            or string.find(nameLower, 'effect')
        then
            table.insert(traits, tostring(attrValue))
        end
    end
    if #traits == 0 then
        return 'None'
    else
        return table.concat(traits, ', ')
    end
end

--// Formatear dinero corto
local function formatMoney(money)
    if money >= 1000000 then
        return string.format('%.1fM/s', money / 1000000)
    elseif money >= 1000 then
        return string.format('%.0fk/s', money / 1000)
    else
        return money .. '/s'
    end
end

--// Calcular dinero con traits y mutaciones
local function calculateMoneyPerSecond(petModel)
    local data = brainrotData[petModel.Name]
    if not data then
        return 0
    end
    local total = data.baseValue
    local detectedTraits = getTraits(petModel)
    if detectedTraits ~= 'None' then
        for trait in string.gmatch(detectedTraits, '[^,]+') do
            trait = trait:match('^%s*(.-)%s*$')
            local mult = traitMultipliers[trait]
            if mult then
                total = total * mult
            end
        end
    end
    return total
end

--// ESP
local function addESP(targetModel)
    if targetModel:FindFirstChild('PetESP') then
        return
    end
    local Billboard = Instance.new('BillboardGui')
    Billboard.Name = 'PetESP'
    Billboard.Adornee = targetModel
    Billboard.Size = UDim2.new(0, 150, 0, 40)
    Billboard.StudsOffset = Vector3.new(0, 3, 0)
    Billboard.AlwaysOnTop = true
    Billboard.Parent = targetModel

    local Label = Instance.new('TextLabel')
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = '🎯 Ice Hub Target\n💰 '
        .. formatMoney(calculateMoneyPerSecond(targetModel))
    Label.TextColor3 = Color3.fromRGB(0, 200, 255)
    Label.TextStrokeTransparency = 0.5
    Label.Font = Enum.Font.SourceSansBold
    Label.TextScaled = true
    Label.Parent = Billboard
end

--// Webhook Sender - КРАСИВОЕ СООБЩЕНИЕ
local function sendWebhook(foundPets, jobId, url)
    local formattedPets = {}
    local totalIncome = 0
    local petOwner = 'Unknown'

    for _, pet in ipairs(foundPets) do
        local traits = getTraits(pet)
        local moneyPerSec = calculateMoneyPerSecond(pet)
        local formattedMoney = formatMoney(moneyPerSec)
        totalIncome = totalIncome + moneyPerSec
        petOwner = getPetOwner(pet)

        table.insert(
            formattedPets,
            '**'
                .. pet.Name
                .. '**\n'
                .. '💰 **Income:** '
                .. formattedMoney
                .. '\n'
                .. '⭐ **Traits/Mutations:** '
                .. traits
                .. '\n'
                .. '👤 **Owner:** '
                .. petOwner
        )
    end

    local playersCount = #Players:GetPlayers()
    local formattedTotalIncome = formatMoney(totalIncome)

    -- Scripts для разных платформ
    local pcScript = "game:GetService('TeleportService'):TeleportToPlaceInstance("
        .. game.PlaceId
        .. ", '"
        .. jobId
        .. "')"
    local mobileScript = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()\n"
        .. 'Teleport('
        .. game.PlaceId
        .. ", '"
        .. jobId
        .. "')"

    local joinerUrl = 'https://testing5312.github.io/joiner/?placeId='
        .. tostring(game.PlaceId)
        .. '&gameInstanceId='
        .. jobId

    local jsonData = HttpService:JSONEncode({
        ['content'] = (url == webhookA or url == webhookA_Temprana)
                and '@everyone 🎯 **BRAINROT FOUND!**'
            or '',
        ['embeds'] = {
            {
                ['title'] = '❄️ Ice Hub Servers - Brainrot Found! 🎯',
                ['description'] = '**✨ Exclusive Brainrot Pet Detected!**',
                ['color'] = 0x00BFFF,
                ['thumbnail'] = {
                    ['url'] = 'https://cdn.discordapp.com/attachments/1149288002252001290/1245832768973508658/standard.gif',
                },
                ['fields'] = {
                    {
                        ['name'] = '👤 Pet Owner',
                        ['value'] = '```' .. petOwner .. '```',
                        ['inline'] = true,
                    },
                    {
                        ['name'] = '🤖 Scanner',
                        ['value'] = '```' .. LocalPlayer.Name .. '```',
                        ['inline'] = true,
                    },
                    {
                        ['name'] = '💰 Total Income',
                        ['value'] = '```' .. formattedTotalIncome .. '```',
                        ['inline'] = true,
                    },
                    {
                        ['name'] = '🎯 Found Pet(s)',
                        ['value'] = table.concat(formattedPets, '\n\n'),
                        ['inline'] = false,
                    },
                    {
                        ['name'] = '🌐 Server Info',
                        ['value'] = '**Job ID:** ```'
                            .. jobId
                            .. '```\n**Players:** ```'
                            .. playersCount
                            .. '```',
                        ['inline'] = false,
                    },
                    {
                        ['name'] = '🖥️ PC Injectors',
                        ['value'] = '```lua\n' .. pcScript .. '\n```',
                        ['inline'] = false,
                    },
                    {
                        ['name'] = '📱 Mobile Injectors',
                        ['value'] = '```lua\n' .. mobileScript .. '\n```',
                        ['inline'] = false,
                    },
                    {
                        ['name'] = '🔗 Quick Join',
                        ['value'] = '[**Click Here to Join Server**]('
                            .. joinerUrl
                            .. ')',
                        ['inline'] = true,
                    },
                },
                ['footer'] = {
                    ['text'] = '❄️ Ice Hub Servers • '
                        .. os.date('%Y-%m-%d %H:%M:%S'),
                },
                ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            },
        },
    })

    local req = http_request or request or (syn and syn.request)
    if req then
        pcall(function()
            req({
                Url = url,
                Method = 'POST',
                Headers = { ['Content-Type'] = 'application/json' },
                Body = jsonData,
            })
        end)
    end
end

--// Detectar Pets
local function checkForPets()
    local foundA, foundB = {}, {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA('Model') and not obj:FindFirstChild('PetESP') then
            local nameLower = string.lower(obj.Name)
            for _, target in pairs(getgenv().WebhookATargets) do
                if string.find(nameLower, string.lower(target)) then
                    addESP(obj)
                    table.insert(foundA, obj)
                end
            end
            for _, target in pairs(getgenv().WebhookBTargets) do
                if string.find(nameLower, string.lower(target)) then
                    addESP(obj)
                    table.insert(foundB, obj)
                end
            end
        end
    end
    return foundA, foundB
end

--// УЛУЧШЕННЫЙ Server Hop
local function serverHop(delayTime)
    hops += 1
    if hops >= maxHopsBeforeReset then
        visitedJobIds = { [game.JobId] = true }
        hops = 0
        print('❄️ Ice Hub: Reset visited servers list')
    end

    task.wait(delayTime or 2)

    local function findGoodServer()
        local cursor = nil
        local attempts = 0

        while attempts < maxTeleportRetries do
            local url = 'https://games.roblox.com/v1/games/'
                .. game.PlaceId
                .. '/servers/Public?sortOrder=Asc&limit=100'
            if cursor then
                url = url .. '&cursor=' .. cursor
            end

            local success, result = pcall(function()
                return game:HttpGetAsync(url)
            end)

            if success then
                local data = HttpService:JSONDecode(result)
                local servers = {}

                for _, server in ipairs(data.data) do
                    if
                        server.playing
                        and server.playing > 0
                        and server.playing <= 12
                        and server.id ~= game.JobId
                        and not visitedJobIds[server.id]
                    then
                        table.insert(servers, server)
                    end
                end

                if #servers > 0 then
                    local selectedServer = servers[math.random(1, #servers)]
                    visitedJobIds[selectedServer.id] = true
                    return selectedServer.id
                end

                cursor = data.nextPageCursor
                if not cursor then
                    break
                end
            else
                attempts += 1
                task.wait(0.5)
            end
        end
        return nil
    end

    local goodServerId = findGoodServer()
    if goodServerId then
        print('❄️ Ice Hub: Teleporting to server ' .. goodServerId)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, goodServerId)
    else
        print('❄️ Ice Hub: No good servers found, using random teleport')
        TeleportService:Teleport(game.PlaceId)
    end
end

--// Sniping Loop
local function startSniper()
    while true do
        local foundA, foundB = checkForPets()

        if #foundA > 0 then
            print('🎯 Ice Hub: Found Webhook A pets: ' .. #foundA)
            sendWebhook(foundA, game.JobId, webhookA_Temprana)
            task.delay(3, function()
                sendWebhook(foundA, game.JobId, webhookA)
            end)
            task.delay(8, function()
                serverHop(3)
            end)
            return
        elseif #foundB > 0 then
            print('🎯 Ice Hub: Found Webhook B pets: ' .. #foundB)
            sendWebhook(foundB, game.JobId, webhookB)
            task.delay(5, function()
                serverHop(3)
            end)
            return
        else
            print('🔄 Ice Hub: No target pets found, server hopping...')
            serverHop(1)
            return
        end

        task.wait(2)
    end
end

--// Auto-restart system
local function initializeSniper()
    while true do
        local success, err = pcall(startSniper)
        if not success then
            print('❄️ Ice Hub Error: ' .. tostring(err))
            print('🔄 Restarting sniper in 3 seconds...')
            task.wait(3)
        else
            break
        end
    end
end

--// Start
print('❄️ Ice Hub Servers - Brainrot Sniper Started!')
print('📊 Tracking ' .. #getgenv().WebhookATargets .. ' Webhook A pets')
print('📊 Tracking ' .. #getgenv().WebhookBTargets .. ' Webhook B pets')
print('🔄 Auto-restart system active')

task.spawn(initializeSniper)
