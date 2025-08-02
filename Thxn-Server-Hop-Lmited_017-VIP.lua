 --[[ 🛡️ WHITELIST POR NOMBRE DE USUARIO ]]--
local Players = game:GetService("Players")
local allowedUsernames = {
    "Lmited_017"
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
    "La Vacca Saturno Saturnita", "Los Tralaleritos",
    "Las Tralaleritas", "Graipuss Medussi", "La Grande Combinasion",
    "Nuclearo Dinossauro", "Garama and Madundung", "Torrtuginni Dragonfrutini",
    "Pot Hotspot", "Las Vaquitas Saturnitas", "Las Combinasionas"
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
        label.TextColor3 = Color3.new(0, 255, 255)
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

... (128 líneas restantes)
