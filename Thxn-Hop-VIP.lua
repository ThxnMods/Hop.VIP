   --[[ 🛡️ WHITELIST POR NOMBRE DE USUARIO ]]--
local Players = game:GetService("Players")
local allowedUsernames = {
    "memes17827",
    "Elmasv3rgud04",
    "ocpa38090",
    "ArmandoPuentes1904"
}
local allowedUserIds = {}

for _, username in ipairs(allowedUsernames) do
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    if success then
        allowedUserIds[userId] = true
    else
        warn("No se pudo obtener UserId de:", username)
    end
end

local LocalPlayer = Players.LocalPlayer
if not allowedUserIds[LocalPlayer.UserId] then
    LocalPlayer:Kick("No estás autorizado para usar este script 😈")
    return
end

--[[ 🎯 CONFIGURACIÓN ]]--
local TARGET_NAMES = {
    "La Vacca Saturno Saturnita", "Chimpanzini Spiderini", "Los Tralaleritos",
    "Las Tralaleritas", "Graipuss Medussi", "La Grande Combinasion",
    "Nuclearo Dinossauro", "Garama and Madundung", "Torrtuginni Dragonfrutini",
    "Pot Hotspot", "Las Vaquitas Saturnitas"
}

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local PlaceId = game.PlaceId
local triedServers = {}
local running = false

-- UI principal
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "THXNModsGUI"

-- 🔊 Sonido de alerta cuando se encuentra un objetivo
local Sound = Instance.new("Sound", ScreenGui)
Sound.SoundId = "rbxassetid://3165700530"
Sound.Volume = 1
Sound.Name = "TargetFoundSound"

local DraggableButton = Instance.new("TextButton", ScreenGui)
DraggableButton.Size = UDim2.new(0, 220, 0, 50)
DraggableButton.Position = UDim2.new(1, -240, 0, 120)
DraggableButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
DraggableButton.BackgroundTransparency = 0.2
DraggableButton.Text = "Iniciar THXN Hop 😈"
DraggableButton.TextSize = 20
DraggableButton.TextColor3 = Color3.new(1, 0, 0)
DraggableButton.Font = Enum.Font.GothamBold
DraggableButton.BorderSizePixel = 0
DraggableButton.AutoButtonColor = false
DraggableButton.Active = true
DraggableButton.Draggable = true
DraggableButton.ClipsDescendants = true

Instance.new("UICorner", DraggableButton).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", DraggableButton).Color = Color3.fromRGB(0, 255, 255)

task.spawn(function()
    while true do
        for hue = 0, 1, 0.01 do
            DraggableButton.TextColor3 = Color3.fromHSV(hue, 1, 1)
            task.wait(0.03)
        end
    end
end)

-- Función para colocar billboard a todos los targets encontrados
local function markTarget(target)
    if target:IsA("Model") and target:FindFirstChildWhichIsA("BasePart") then
        local gui = Instance.new("BillboardGui", target)
        gui.Size = UDim2.new(0, 100, 0, 30)
        gui.AlwaysOnTop = true
        gui.Adornee = target:FindFirstChildWhichIsA("BasePart")

        local label = Instance.new("TextLabel", gui)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = target.Name .. " 🎯"
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
    end
end

local function getTargets()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and table.find(TARGET_NAMES, obj.Name) then
            table.insert(found, obj)
        end
    end
    return found
end

-- UI para preguntar si continuar
local function askToContinue(callback)
    local frame = Instance.new("Frame", ScreenGui)
    frame.Size = UDim2.new(0.4, 0, 0.2, 0)
    frame.Position = UDim2.new(0.3, 0, 0.4, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.2
    frame.ZIndex = 20
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(0, 255, 255)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "🎯 Se encontró un objetivo 😘\n¿Deseas seguir buscando?"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    local yesBtn = Instance.new("TextButton", frame)
    yesBtn.Size = UDim2.new(0.45, 0, 0.3, 0)
    yesBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
    yesBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    yesBtn.Text = "Sí"
    yesBtn.TextColor3 = Color3.new(1, 1, 1)
    yesBtn.Font = Enum.Font.GothamBold
    yesBtn.TextScaled = true
    Instance.new("UICorner", yesBtn)

    local noBtn = Instance.new("TextButton", frame)
    noBtn.Size = UDim2.new(0.45, 0, 0.3, 0)
    noBtn.Position = UDim2.new(0.5, 0, 0.6, 0)
    noBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    noBtn.Text = "No"
    noBtn.TextColor3 = Color3.new(1, 1, 1)
    noBtn.Font = Enum.Font.GothamBold
    noBtn.TextScaled = true
    Instance.new("UICorner", noBtn)

    yesBtn.MouseButton1Click:Connect(function()
        frame:Destroy()
        callback(true)
    end)
    noBtn.MouseButton1Click:Connect(function()
        frame:Destroy()
        callback(false)
    end)
end

-- Server hop
local function hop()
    local cursor = ""
    while running do
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId and not triedServers[server.id] then
                    triedServers[server.id] = true
                    local successTP, err = pcall(function()
                        TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer, { _fromTHXN = true })
                    end)
                    if not successTP then
                        warn("Error al teletransportar:", err)
                        task.wait(2)
                    end
                    return
                end
            end
            cursor = result.nextPageCursor or ""
            if cursor == "" then break end
        else
            warn("Fallo al obtener servidores")
            break
        end
        task.wait(1)
    end
end

-- Loop principal
local function runSearch()
    while running do
        local targets = getTargets()
        if #targets > 0 then
            for _, target in pairs(targets) do
                markTarget(target)
            end

            -- 🔊 Reproduce sonido al encontrar objetivo
            Sound:Play()
            DraggableButton.Text = "🎯 Objetivo encontrado"

            askToContinue(function(shouldContinue)
                if shouldContinue then
                    running = true
                    hop()
                else
                    running = false
                    DraggableButton.Text = "Iniciar THXN Hop 😈"
                end
            end)

            break
        else
            hop()
        end
        task.wait(1)
    end
end

DraggableButton.MouseButton1Click:Connect(function()
    running = not running
    if running then
        DraggableButton.Text = "⛔ Detener búsqueda"
        task.spawn(runSearch)
    else
        DraggableButton.Text = "IniciarTHXN Hop 😈"
    end
end)

-- Auto-ejecución tras hop
local TeleportData = TeleportService:GetLocalPlayerTeleportData()
if TeleportData and TeleportData["_fromTHXN"] then
    running = true
    DraggableButton.Text = "⛔ Detener búsqueda"
    task.delay(2, runSearch)
end

-- Inicio automático si no viene de teleport
if not running then
    running = true
    task.spawn(runSearch)
end
