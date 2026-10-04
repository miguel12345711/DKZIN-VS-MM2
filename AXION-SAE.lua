-- ============================================
-- 「 AXION HUB 」 — Steal An Egg Edition
-- UI Ultra Avançada • PC + Mobile
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- ===== CONFIG =====
local Config = {
    -- Auto Steal
    AutoSteal = false,
    AntiGuard = false,
    AutoHatch = false,
    AutoSell = false,
    -- Filtros
    Areas = {},
    Raridades = {},
    -- Movimento
    Speed = false,
    SpeedValor = 100,
    Fly = false,
    -- Visual
    ESPOvos = false,
    ESPGuards = false,
    Fullbright = false,
}

-- ===== GUI PRINCIPAL =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AXION_SAE"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LP:WaitForChild("PlayerGui")

-- Botão flutuante com gradiente
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.03, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(88, 40, 180)
toggleBtn.Text = "A"
toggleBtn.TextSize = 24
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
main.Size = UDim2.new(0, 290, 0, 360)
main.Position = UDim2.new(0.5, -145, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui
main.Visible = false

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
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -50, 0, 14)
subtitle.Position = UDim2.new(0, 15, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Steal An Egg  •  v1.0"
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
end

local function criarAba(nome)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 24)
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
    btn.Size = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3 = Config[key] and cor or Color3.fromRGB(38, 38, 52)
    btn.Text = "   " .. nome .. (Config[key] and "    ON" or "    OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
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
criarAba("Steal")
criarAba("Farming")
criarAba("Movimento")
criarAba("Visual")

-- Aba STEAL
criarToggle(pages["Steal"], "Auto Steal", "AutoSteal", Color3.fromRGB(200, 60, 100))
criarToggle(pages["Steal"], "Anti Guard", "AntiGuard", Color3.fromRGB(100, 180, 255))

-- Aba FARMING
criarToggle(pages["Farming"], "Auto Hatch", "AutoHatch", Color3.fromRGB(255, 180, 50))
criarToggle(pages["Farming"], "Auto Sell", "AutoSell", Color3.fromRGB(100, 220, 120))

-- Aba MOVIMENTO
criarToggle(pages["Movimento"], "Speed", "Speed", Color3.fromRGB(150, 100, 220))
criarToggle(pages["Movimento"], "Fly", "Fly", Color3.fromRGB(80, 180, 220))

-- Aba VISUAL
criarToggle(pages["Visual"], "ESP Ovos", "ESPOvos", Color3.fromRGB(255, 220, 100))
criarToggle(pages["Visual"], "ESP Guardas", "ESPGuards", Color3.fromRGB(255, 80, 80))
criarToggle(pages["Visual"], "Fullbright", "Fullbright", Color3.fromRGB(255, 200, 120))

mostrarAba("Steal")

-- ===== LÓGICA: AUTO STEAL =====
local function acharOvo()
    local guardAreas = workspace:FindFirstChild("GuardAreas")
    if not guardAreas then return nil end
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local maisProximo = nil
    local menorDist = math.huge

    for _, area in ipairs(guardAreas:GetChildren()) do
        local nests = area:FindFirstChild("Nests")
        if nests then
            for _, ovo in ipairs(nests:GetDescendants()) do
                if ovo:IsA("Model") or ovo:IsA("BasePart") then
                    local pos = ovo:IsA("BasePart") and ovo.Position or ovo:GetPivot().Position
                    local dist = (pos - hrp.Position).Magnitude
                    if dist < menorDist then
                        menorDist = dist
                        maisProximo = ovo
                    end
                end
            end
        end
    end
    return maisProximo
end

local function autoSteal()
    if not Config.AutoSteal then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local ovo = acharOvo()
    if not ovo then return end

    local pos = ovo:IsA("BasePart") and ovo.Position or ovo:GetPivot().Position
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    task.wait(0.1)

    local prompt = ovo:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        fireproximityprompt(prompt)
    end
end

-- ===== ANTI GUARD =====
local function antiGuard()
    if not Config.AntiGuard then return end
    local guardAreas = workspace:FindFirstChild("GuardAreas")
    if not guardAreas then return end
    for _, area in ipairs(guardAreas:GetChildren()) do
        local guard = area:FindFirstChild("Guard")
        if guard and guard:IsA("Model") then
            local gHrp = guard:FindFirstChild("HumanoidRootPart")
            if gHrp then
                gHrp.Anchored = true
            end
        end
    end
end

-- ===== SPEED =====
local function aplicarSpeed()
    if not Config.Speed then return end
    local char = LP.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = Config.SpeedValor
    end
end

-- ===== FULLBRIGHT =====
local function aplicarFullbright()
    if Config.Fullbright then
        game.Lighting.Brightness = 3
        game.Lighting.ClockTime = 14
        game.Lighting.FogEnd = 100000
        game.Lighting.GlobalShadows = false
    end
end

-- ===== LOOP PRINCIPAL =====
task.spawn(function()
    while task.wait(0.5) do
        pcall(autoSteal)
        pcall(antiGuard)
        pcall(aplicarSpeed)
        pcall(aplicarFullbright)
    end
end)

print("「 AXION HUB 」— Steal An Egg carregado!")
