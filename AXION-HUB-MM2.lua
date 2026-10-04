-- ============================================
-- 「 AXION HUB 」 — MM2 Edition
-- ESP • Auto Shoot • Auto Grab Gun • Freeze
-- Fullbright • Anti AFK • Coin Farm
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

-- ===== CONFIG =====
local Config = {
    -- ESP
    MurdererESP = true,
    SheriffESP = true,
    InnocentESP = false,
    -- Combate
    AutoShoot = false,
    Previsao = 0.15,
    -- Utilidades
    AutoGrabGun = false,
    FreezeMurderer = false,
    Fullbright = false,
    AntiAFK = true,
    -- Visual
    MostrarNomes = true,
}

local espCache = {}
local nomeCache = {}

-- ===== DETECÇÃO DE FUNÇÃO =====
local function detectarFuncao(player)
    local char = player.Character
    if not char then return "Innocent" end

    local function temItem(nome)
        if char:FindFirstChild(nome) then return true end
        local bp = player:FindFirstChild("Backpack")
        if bp and bp:FindFirstChild(nome) then return true end
        return false
    end

    if temItem("Knife") or temItem("MurdererKnife") or temItem("KnifeLocal") then
        return "Murderer"
    end
    if temItem("Gun") or temItem("Revolver") or temItem("GunLocal") then
        return "Sheriff"
    end
    return "Innocent"
end

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AXION_HUB"
screenGui.ResetOnSpawn = false
screenGui.Parent = LP:WaitForChild("PlayerGui")

-- Botão flutuante
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 55, 0, 55)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(88, 40, 180)
toggleBtn.Text = "A"
toggleBtn.TextSize = 26
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.BorderSizePixel = 0
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = screenGui

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(1, 0)
tc.Parent = toggleBtn

local tGrad = Instance.new("UIGradient")
tGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 40, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 60, 140)),
})
tGrad.Rotation = 45
tGrad.Parent = toggleBtn

-- Menu principal
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 340)
main.Position = UDim2.new(0.15, 0, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 14)
mc.Parent = main

local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(88, 40, 180)
ms.Thickness = 1.5
ms.Parent = main

local mGrad = Instance.new("UIGradient")
mGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 40, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 90, 200)),
})
mGrad.Rotation = 90
mGrad.Parent = ms

-- Cabeçalho
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Color3.fromRGB(88, 40, 180)
header.BorderSizePixel = 0
header.Parent = main

local hc = Instance.new("UICorner")
hc.CornerRadius = UDim.new(0, 14)
hc.Parent = header

local hFix = Instance.new("Frame")
hFix.Size = UDim2.new(1, 0, 0, 14)
hFix.Position = UDim2.new(0, 0, 1, -14)
hFix.BackgroundColor3 = Color3.fromRGB(88, 40, 180)
hFix.BorderSizePixel = 0
hFix.Parent = header

local hGrad = Instance.new("UIGradient")
hGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 40, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 60, 140)),
})
hGrad.Rotation = 45
hGrad.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "「 AXION HUB 」"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -50, 0, 14)
subtitle.Position = UDim2.new(0, 15, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "MM2 Edition  •  v1.0"
subtitle.TextColor3 = Color3.fromRGB(220, 200, 255)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 11)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(1, 0)
cc.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
end)

toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- ===== SISTEMA DE ABAS =====
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 32)
tabFrame.Position = UDim2.new(0, 10, 0, 58)
tabFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
tabFrame.BorderSizePixel = 0
tabFrame.Parent = main

local tfc = Instance.new("UICorner")
tfc.CornerRadius = UDim.new(0, 8)
tfc.Parent = tabFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Parent = tabFrame

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -105)
contentFrame.Position = UDim2.new(0, 10, 0, 98)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = main

local pages = {}
local tabs = {}
local currentTab = nil

local function mostrarAba(nome)
    for tabNome, page in pairs(pages) do
        page.Visible = (tabNome == nome)
    end
    for tabNome, btn in pairs(tabs) do
        if tabNome == nome then
            btn.BackgroundColor3 = Color3.fromRGB(88, 40, 180)
        else
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        end
    end
    currentTab = nome
end

local function criarAba(nome)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 78, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.Text = nome
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = tabFrame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(88, 40, 180)
    page.Visible = false
    page.Parent = contentFrame

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page

    pages[nome] = page
    tabs[nome] = btn

    btn.MouseButton1Click:Connect(function()
        mostrarAba(nome)
    end)
end

-- ===== CRIAR TOGGLE =====
local function criarToggle(parent, nome, key, cor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 34)
    btn.BackgroundColor3 = Config[key] and cor or Color3.fromRGB(38, 38, 52)
    btn.Text = "   " .. nome .. (Config[key] and "    ON" or "    OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        if Config[key] then
            btn.BackgroundColor3 = cor
            btn.Text = "   " .. nome .. "    ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
            btn.Text = "   " .. nome .. "    OFF"
        end
    end)
end

-- ===== CRIAR ABAS =====
criarAba("Visual")
criarAba("Combate")
criarAba("Utils")

-- Aba VISUAL
criarToggle(pages["Visual"], "ESP Assassino", "MurdererESP", Color3.fromRGB(200, 50, 50))
criarToggle(pages["Visual"], "ESP Xerife", "SheriffESP", Color3.fromRGB(50, 120, 220))
criarToggle(pages["Visual"], "ESP Inocente", "InnocentESP", Color3.fromRGB(50, 200, 90))
criarToggle(pages["Visual"], "Mostrar Nomes", "MostrarNomes", Color3.fromRGB(150, 100, 220))
criarToggle(pages["Visual"], "Fullbright", "Fullbright", Color3.fromRGB(255, 220, 100))

-- Aba COMBATE
criarToggle(pages["Combate"], "Auto Shoot", "AutoShoot", Color3.fromRGB(200, 50, 50))
criarToggle(pages["Combate"], "Freeze Assassino", "FreezeMurderer", Color3.fromRGB(100, 180, 255))

-- Aba UTILS
criarToggle(pages["Utils"], "Auto Grab Gun", "AutoGrabGun", Color3.fromRGB(255, 180, 50))
criarToggle(pages["Utils"], "Anti AFK", "AntiAFK", Color3.fromRGB(100, 200, 120))

mostrarAba("Visual")

-- ===== ESP =====
local function criarESP(player)
    if not player.Character then return end

    local h = Instance.new("Highlight")
    h.Name = "AXION_ESP"
    h.Adornee = player.Character
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = player.Character
    espCache[player] = h

    local head = player.Character:FindFirstChild("Head")
    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "AXION_Nome"
        billboard.Size = UDim2.new(0, 100, 0, 20)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local nomeLabel = Instance.new("TextLabel")
        nomeLabel.Size = UDim2.new(1, 0, 1, 0)
        nomeLabel.BackgroundTransparency = 1
        nomeLabel.Text = player.Name
        nomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nomeLabel.TextStrokeTransparency = 0
        nomeLabel.Font = Enum.Font.GothamBold
        nomeLabel.TextScaled = true
        nomeLabel.Parent = billboard

        nomeCache[player] = billboard
    end
end

local function atualizarESP(player)
    if player == LP then return end
    local h = espCache[player]
    if not h or not h.Parent then
        criarESP(player)
        h = espCache[player]
    end
    if not h then return end

    local role = detectarFuncao(player)
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

    -- Nome
    local nomeGui = nomeCache[player]
    if nomeGui then
        nomeGui.Enabled = Config.MostrarNomes and ativo
        if nomeGui:FindFirstChildOfClass("TextLabel") then
            nomeGui:FindFirstChildOfClass("TextLabel").Text = player.Name .. " [" .. role .. "]"
            nomeGui:FindFirstChildOfClass("TextLabel").TextColor3 = cor
        end
    end
end

-- ===== AUTO SHOOT =====
local function getMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and detectarFuncao(p) == "Murderer" then
            return p
        end
    end
    return nil
end

local function autoShoot()
    if not Config.AutoShoot then return end
    local murderer = getMurderer()
    if not murderer or not murderer.Character then return end
    local myChar = LP.Character
    if not myChar then return end
    local gun = myChar:FindFirstChild("Gun")
    if not gun then return end
    local targetHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then return end

    local vel = targetHRP.Velocity
    local posPrevista = targetHRP.Position + (vel * Config.Previsao)
    local direction = (posPrevista - myHRP.Position).Unit
    myHRP.CFrame = CFrame.new(myHRP.Position, myHRP.Position + direction)
end

-- ===== FREEZE MURDERER =====
local function freezeMurderer()
    if not Config.FreezeMurderer then return end
    local murderer = getMurderer()
    if not murderer or not murderer.Character then return end
    local hrp = murderer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = true
    end
end

-- ===== AUTO GRAB GUN =====
local function autoGrabGun()
    if not Config.AutoGrabGun then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj.Name == "Gun" or obj.Name == "Revolver") and (obj:IsA("Tool") or obj:IsA("Model")) then
            local pos = obj:IsA("BasePart") and obj.Position or obj:GetPivot().Position
            if (hrp.Position - pos).Magnitude > 3 then
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
        end
    end
end

-- ===== FULLBRIGHT =====
local function aplicarFullbright()
    if Config.Fullbright then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then v.Density = 0 end
        end
    end
end

-- ===== ANTI AFK =====
task.spawn(function()
    while task.wait(60) do
        if Config.AntiAFK then
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end
    end
end)

-- ===== LOOPS PRINCIPAIS =====
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        atualizarESP(p)
    end)
end)

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LP and p.Character then atualizarESP(p) end
end

RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then atualizarESP(p) end
    end
    pcall(autoShoot)
    pcall(freezeMurderer)
    pcall(autoGrabGun)
    pcall(aplicarFullbright)
end)

print("「 AXION HUB 」 MM2 Edition carregado!")
