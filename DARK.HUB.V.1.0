--[[
    DARK HUB | MM2
    Linoria Lib • Perfil do Jogador
]]

-- ===== LINORIA =====
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- ===== SERVIÇOS =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LP = Players.LocalPlayer

-- ===== CONFIG =====
local Config = {
    MurdererESP = true,
    SheriffESP = true,
    InnocentESP = false,
    AutoShoot = false,
    Freeze = false,
    Noclip = false,
    Speed = false,
}

-- ===== JANELA =====
local Window = Library:CreateWindow({
    Title = 'DARK HUB',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- ===== ABAS =====
local Tabs = {
    Perfil = Window:AddTab('Perfil'),
    Visual = Window:AddTab('Visual'),
    Combat = Window:AddTab('Combat'),
    Movement = Window:AddTab('Movement'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- ==================================================
-- ABA PERFIL
-- ==================================================

local PerfilBox = Tabs.Perfil:AddLeftGroupbox('Conta')

PerfilBox:AddImage('Avatar', {
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=420&h=420",
    Height = 150,
    Width = 150,
})

PerfilBox:AddLabel('Nome: ' .. LP.DisplayName)
PerfilBox:AddLabel('Apelido: @' .. LP.Name)
PerfilBox:AddLabel('ID: ' .. LP.UserId)
PerfilBox:AddLabel('Conta criada: ' .. LP.AccountAge .. ' dias atrás')
PerfilBox:AddDivider()

local PingLabel = PerfilBox:AddLabel('Ping: calculando...')
task.spawn(function()
    while task.wait(1) do
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        PingLabel:SetText('Ping: ' .. ping .. ' ms')
    end
end)

local FPSLabel = PerfilBox:AddLabel('FPS: calculando...')
task.spawn(function()
    local frames = 0
    local tempo = tick()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
    end)
    while task.wait(1) do
        local agora = tick()
        local fps = math.floor(frames / math.max(agora - tempo, 0.001))
        FPSLabel:SetText('FPS: ' .. fps)
        frames = 0
        tempo = agora
    end
end)

local StatsBox = Tabs.Perfil:AddRightGroupbox('Estatísticas')
local MemoryLabel = StatsBox:AddLabel('Memória: calculando...')
task.spawn(function()
    while task.wait(2) do
        local mb = 0
        pcall(function()
            mb = math.floor(Stats:GetTotalMemoryUsageMb())
        end)
        MemoryLabel:SetText('Memória: ' .. mb .. ' MB')
    end
end)

local PlayersLabel = StatsBox:AddLabel('Jogadores: calculando...')
task.spawn(function()
    while task.wait(1) do
        PlayersLabel:SetText('Jogadores: ' .. #Players:GetPlayers())
    end
end)

-- ==================================================
-- ABA VISUAL
-- ==================================================

local VisualBox = Tabs.Visual:AddLeftGroupbox('ESP')

VisualBox:AddToggle('MurdererESP', {
    Text = 'ESP Assassino', Default = true,
    Tooltip = 'Destaca o Murderer em vermelho',
    Callback = function(Value) Config.MurdererESP = Value end
})

VisualBox:AddToggle('SheriffESP', {
    Text = 'ESP Xerife', Default = true,
    Tooltip = 'Destaca o Sheriff em azul',
    Callback = function(Value) Config.SheriffESP = Value end
})

VisualBox:AddToggle('InnocentESP', {
    Text = 'ESP Inocente', Default = false,
    Tooltip = 'Destaca os Innocents em verde',
    Callback = function(Value) Config.InnocentESP = Value end
})

-- ==================================================
-- ABA COMBAT
-- ==================================================

local CombatBox = Tabs.Combat:AddLeftGroupbox('Combate')

CombatBox:AddToggle('AutoShoot', {
    Text = 'Auto Shoot', Default = false,
    Tooltip = 'Atira automaticamente no Murderer',
    Callback = function(Value) Config.AutoShoot = Value end
})

CombatBox:AddToggle('Freeze', {
    Text = 'Freeze Assassino', Default = false,
    Tooltip = 'Congela o Murderer no lugar',
    Callback = function(Value) Config.Freeze = Value end
})

-- ==================================================
-- ABA MOVEMENT
-- ==================================================

local MovementBox = Tabs.Movement:AddLeftGroupbox('Movimento')

MovementBox:AddToggle('Noclip', {
    Text = 'Noclip', Default = false,
    Tooltip = 'Atravessa paredes',
    Callback = function(Value) Config.Noclip = Value end
})

MovementBox:AddToggle('Speed', {
    Text = 'Speed Boost', Default = false,
    Tooltip = 'Aumenta a velocidade',
    Callback = function(Value) Config.Speed = Value end
})

-- ==================================================
-- LÓGICA
-- ==================================================

local espCache = {}
local nomeCache = {}

local function DetectarFuncao(player)
    local char = player.Character
    if not char then return "Innocent" end
    local function tem(n)
        if char:FindFirstChild(n) then return true end
        local bp = player:FindFirstChild("Backpack")
        if bp and bp:FindFirstChild(n) then return true end
        return false
    end
    if tem("Knife") or tem("MurdererKnife") then return "Murderer" end
    if tem("Gun") or tem("Revolver") then return "Sheriff" end
    return "Innocent"
end

local function CriarESP(player)
    if not player.Character then return end
    if espCache[player] and espCache[player].Parent then return end

    local h = Instance.new("Highlight")
    h.Name = "DARK_ESP"
    h.Adornee = player.Character
    h.FillTransparency = 0.6
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = player.Character
    espCache[player] = h

    local head = player.Character:FindFirstChild("Head")
    if head then
        local bb = Instance.new("BillboardGui")
        bb.Name = "DARK_Nome"
        bb.Size = UDim2.new(0, 100, 0, 20)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true
        bb.Parent = head

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = player.Name
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextStrokeTransparency = 0
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
        lbl.Parent = bb
        nomeCache[player] = bb
    end
end

local function AtualizarESP(player)
    if player == LP then return end
    local h = espCache[player]
    if not h or not h.Parent then
        CriarESP(player)
        h = espCache[player]
    end
    if not h then return end

    local role = DetectarFuncao(player)
    local ativo, cor
    if role == "Murderer" then
        ativo = Config.MurdererESP
        cor = Color3.fromRGB(255, 40, 40)
    elseif role == "Sheriff" then
        ativo = Config.SheriffESP
        cor = Color3.fromRGB(40, 120, 255)
    else
        ativo = Config.InnocentESP
        cor = Color3.fromRGB(40, 220, 80)
    end

    if ativo then
        h.FillColor = cor
        h.OutlineColor = cor
        h.Enabled = true
    else
        h.Enabled = false
    end

    local n = nomeCache[player]
    if n then
        n.Enabled = ativo
        local lbl = n:FindFirstChildOfClass("TextLabel")
        if lbl then
            lbl.Text = player.Name .. " [" .. role .. "]"
            lbl.TextColor3 = cor
        end
    end
end

local function GetMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and DetectarFuncao(p) == "Murderer" then
            return p
        end
    end
    return nil
end

local function AutoShoot()
    if not Config.AutoShoot then return end
    local m = GetMurderer()
    if not m or not m.Character then return end
    local myChar = LP.Character
    if not myChar then return end
    local gun = myChar:FindFirstChild("Gun")
    if not gun then return end
    local tHRP = m.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not tHRP or not myHRP then return end
    myHRP.CFrame = CFrame.new(myHRP.Position, tHRP.Position)
end

local function Freeze()
    if not Config.Freeze then return end
    local m = GetMurderer()
    if not m or not m.Character then return end
    local hrp = m.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
end

local function Noclip()
    if not Config.Noclip then return end
    local char = LP.Character
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") and obj.CanCollide then
            obj.CanCollide = false
        end
    end
end

local function Speed()
    if not Config.Speed then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 32 end
end

-- ==================================================
-- LOOPS
-- ==================================================

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        AtualizarESP(p)
    end)
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP and p.Character then
        AtualizarESP(p)
    end
end

RunService.Heartbeat:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            AtualizarESP(p)
        end
    end
    pcall(AutoShoot)
    pcall(Freeze)
    pcall(Noclip)
    pcall(Speed)
end)

-- ==================================================
-- UI SETTINGS
-- ==================================================

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function()
    Library:Unload()
end)

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'End',
    NoUI = true,
    Text = 'Menu keybind'
})

Library.ToggleKeybind = Options.MenuKeybind

-- ==================================================
-- THEME E SAVE
-- ==================================================

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('DARK-HUB')
SaveManager:SetFolder('DARK-HUB/configs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()

print("DARK HUB carregado!")
