-- ============================================
-- 「 AXION HUB 」 — MM2 Edition
-- Fluent Style • PC + Mobile • v2.0
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- ===== CONFIG =====
local Config = {
    MurdererESP = true,
    SheriffESP = true,
    InnocentESP = false,
    MostrarNomes = true,
    AutoShoot = false,
    Previsao = 0.15,
    FreezeMurderer = false,
    AutoGrabGun = false,
    Fullbright = false,
    AntiAFK = true,
    Speed = false,
    SpeedValor = 25,
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

-- ===== UI PRINCIPAL =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AXION_MM2"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LP:WaitForChild("PlayerGui")

-- Botão flutuante
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "AXION_Toggle"
toggleBtn.Size = UDim2.new(0, 48, 0, 48)
toggleBtn.Position = UDim2.new(0.04, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(88, 40, 180)
toggleBtn.Text = "A"
toggleBtn.TextSize = 22
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
main.Name = "AXION_Main"
main.Size = UDim2.new(0, 480, 0, 320)
main.Position = UDim2.new(0.5, -240, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui
main.Visible = false

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 12)
mc.Parent = main

local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(88, 40, 180)
ms.Thickness = 1.5
ms.Parent = main

-- Sidebar (esquerda)
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 130, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sc = Instance.new("UICorner")
sc.CornerRadius = UDim.new(0, 12)
sc.Parent = sidebar

local sFix = Instance.new("Frame")
sFix.Size = UDim2.new(0, 12, 1, 0)
sFix.Position = UDim2.new(1, -12, 0, 0)
sFix.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
sFix.BorderSizePixel = 0
sFix.Parent = sidebar

-- Logo/título
local logo = Instance.new("Frame")
logo.Size = UDim2.new(1, 0, 0, 55)
logo.BackgroundColor3 = Color3.fromRGB(88, 40, 180)
logo.BorderSizePixel = 0
logo.Parent = sidebar

local lc = Instance.new("UICorner")
lc.CornerRadius = UDim.new(0, 12)
lc.Parent = logo

local lFix = Instance.new("Frame")
lFix.Size = UDim2.new(1, 0, 0, 15)
lFix.Position = UDim2.new(0, 0, 1, -15)
lFix.BackgroundColor3 = Color3.fromRGB(88, 40, 180)
lFix.BorderSizePixel = 0
lFix.Parent = logo

local lGrad = Instance.new("UIGradient")
lGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 40, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 60, 140)),
})
lGrad.Rotation = 45
lGrad.Parent = logo

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "「 AXION 」"
logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
logoText.Font = Enum.Font.GothamBold
logoText.TextSize = 16
logoText.Parent = logo

local logoSub = Instance.new("TextLabel")
logoSub.Size = UDim2.new(1, 0, 0, 14)
logoSub.Position = UDim2.new(0, 0, 1, -22)
logoSub.BackgroundTransparency = 1
logoSub.Text = "MM2 • v2.0"
logoSub.TextColor3 = Color3.fromRGB(220, 200, 255)
logoSub.Font = Enum.Font.Gotham
logoSub.TextSize = 9
logoSub.Parent = logo

-- Botões de aba na sidebar
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -16, 1, -70)
tabContainer.Position = UDim2.new(0, 8, 0, 62)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = sidebar

local tabList = Instance.new("UIListLayout")
tabList.Padding = UDim.new(0, 6)
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Parent = tabContainer

-- Área de conteúdo (direita)
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -140, 1, 0)
content.Position = UDim2.new(0, 138, 0, 0)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}
local tabButtons = {}
local currentTab = nil

local function mostrarAba(nome)
    for tabNome, page in pairs(pages) do
        page.Visible = (tabNome == nome)
    end
    for tabNome, btn in pairs(tabButtons) do
        if tabNome == nome then
            btn.BackgroundColor3 = Color3.fromRGB(88, 40, 180)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
            btn.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
    end
    currentTab = nome
end

local function criarAba(nome, icone)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    btn.Text = "  " .. icone .. "  " .. nome
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = tabContainer

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -16, 1, -20)
    page.Position = UDim2.new(0, 8, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(88, 40, 180)
    page.Visible = false
    page.Parent = content

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page

    pages[nome] = page
    tabButtons[nome] = btn

    btn.MouseButton1Click:Connect(function()
        mostrarAba(nome)
    end)
end

-- ===== CRIAR TOGGLE (Fluent Style) =====
local function criarToggle(parent, nome, key, cor)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    container.BorderSizePixel = 0
    container.Parent = parent

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 8)
    cc.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = nome
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    -- Switch
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 44, 0, 22)
    switch.Position = UDim2.new(1, -54, 0.5, -11)
    switch.BackgroundColor3 = Config[key] and cor or Color3.fromRGB(45, 45, 60)
    switch.Text = ""
    switch.BorderSizePixel = 0
    switch.Parent = container

    local swc = Instance.new("UICorner")
    swc.CornerRadius = UDim.new(1, 0)
    swc.Parent = switch

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = Config[key] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = switch

    local dotc = Instance.new("UICorner")
    dotc.CornerRadius = UDim.new(1, 0)
    dotc.Parent = dot

    switch.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        if Config[key] then
            switch.BackgroundColor3 = cor
            dot.Position = UDim2.new(1, -18, 0.5, -8)
        else
            switch.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            dot.Position = UDim2.new(0, 2, 0.5, -8)
        end
    end)
end

-- ===== CRIAR ABAS =====
criarAba("Visual", "👁")
criarAba("Combate", "⚔")
criarAba("Utilidades", "⚙")

-- Aba Visual
criarToggle(pages["Visual"], "ESP Assassino", "MurdererESP", Color3.fromRGB(200, 50, 50))
criarToggle(pages["Visual"], "ESP Xerife", "SheriffESP", Color3.fromRGB(50, 120, 220))
criarToggle(pages["Visual"], "ESP Inocente", "InnocentESP", Color3.fromRGB(50, 200, 90))
criarToggle(pages["Visual"], "Mostrar Nomes", "MostrarNomes", Color3.fromRGB(150, 100, 220))
criarToggle(pages["Visual"], "Fullbright", "Fullbright", Color3.fromRGB(255, 220, 100))

-- Aba Combate
criarToggle(pages["Combate"], "Auto Shoot", "AutoShoot", Color3.fromRGB(200, 50, 50))
criarToggle(pages["Combate"], "Freeze Assassino", "FreezeMurderer", Color3.fromRGB(100, 180, 255))

-- Aba Utilidades
criarToggle(pages["Utilidades"], "Auto Grab Gun", "AutoGrabGun", Color3.fromRGB(255, 180, 50))
criarToggle(pages["Utilidades"], "Anti AFK", "AntiAFK", Color3.fromRGB(100, 200, 120))
criarToggle(pages["Utilidades"], "Speed (25)", "Speed", Color3.fromRGB(150, 100, 220))

-- Botão de fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 5
closeBtn.Parent = main

local cbc = Instance.new("UICorner")
cbc.CornerRadius = UDim.new(1, 0)
cbc.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
end)

toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

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
        local bb = Instance.new("BillboardGui")
        bb.Name = "AXION_Nome"
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
    if role == "Murderer" then ativo = Config.MurdererESP; cor = Color3.fromRGB(255, 40, 40)
    elseif role == "Sheriff" then ativo = Config.SheriffESP; cor = Color3.fromRGB(40, 120, 255)
    else ativo = Config.InnocentESP; cor = Color3.fromRGB(40, 220, 80) end

    if ativo then
        h.FillColor = cor
        h.OutlineColor = cor
        h.Enabled = true
    else
        h.Enabled = false
    end

    local n = nomeCache[player]
    if n then
        n.Enabled = Config.MostrarNomes and ativo
        local lbl = n:FindFirstChildOfClass("TextLabel")
        if lbl then
            lbl.Text = player.Name .. " [" .. role .. "]"
            lbl.TextColor3 = cor
        end
    end
end

-- ===== AUTO SHOOT =====
local function getMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and detectarFuncao(p) == "Murderer" then return p end
    end
    return nil
end

local function autoShoot()
    if not Config.AutoShoot then return end
    local m = getMurderer()
    if not m or not m.Character then return end
    local myChar = LP.Character
    if not myChar then return end
    local gun = myChar:FindFirstChild("Gun")
    if not gun then return end
    local tHRP = m.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not tHRP or not myHRP then return end
    local vel = tHRP.Velocity
    local posPrev = tHRP.Position + (vel * Config.Previsao)
    local dir = (posPrev - myHRP.Position).Unit
    myHRP.CFrame = CFrame.new(myHRP.Position, myHRP.Position + dir)
end

-- ===== FREEZE =====
local function freezeMurderer()
    if not Config.FreezeMurderer then return end
    local m = getMurderer()
    if not m or not m.Character then return end
    local hrp = m.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
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

-- ===== SPEED =====
local function aplicarSpeed()
    if not Config.Speed then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Config.SpeedValor end
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

-- ===== LOOPS =====
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
    pcall(aplicarSpeed)
    pcall(aplicarFullbright)
end)

print("「 AXION HUB 」 MM2 v2.0 carregado!")
