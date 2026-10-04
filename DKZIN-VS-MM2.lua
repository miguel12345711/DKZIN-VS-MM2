-- ============================================
-- ☆♧DKZIN VS♧☆ — MM2 Edition
-- ESP + Auto Shoot Murderer
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

-- ===== CONFIG =====
local Config = {
    MurdererESP = true,
    SheriffESP = true,
    InnocentESP = true,
    AutoShoot = false,
    Previsao = 0.15,
    MostrarNome = true,
}

local espCache = {}

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
screenGui.Name = "DKZIN_VS"
screenGui.ResetOnSpawn = false
screenGui.Parent = LP:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 180)
toggleBtn.Text = "D"
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

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 230, 0, 260)
main.Position = UDim2.new(0.15, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 12)
mc.Parent = main

local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(120, 20, 180)
ms.Thickness = 1.5
ms.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(120, 20, 180)
title.Text = "  ☆♧DKZIN VS♧☆"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.BorderSizePixel = 0
title.Parent = main

local tcorner = Instance.new("UICorner")
tcorner.CornerRadius = UDim.new(0, 12)
tcorner.Parent = title

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -34, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = main

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(1, 0)
cc.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
end)

toggleBtn.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- ===== TOGGLES =====
local function criarToggle(nome, yPos, key, cor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Config[key] and cor or Color3.fromRGB(55, 55, 65)
    btn.Text = "  " .. nome .. (Config[key] and "  ON" or "  OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = main

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        if Config[key] then
            btn.BackgroundColor3 = cor
            btn.Text = "  " .. nome .. "  ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            btn.Text = "  " .. nome .. "  OFF"
        end
    end)
end

criarToggle("Assassino", 50, "MurdererESP", Color3.fromRGB(255, 40, 40))
criarToggle("Xerife", 88, "SheriffESP", Color3.fromRGB(40, 120, 255))
criarToggle("Inocente", 126, "InnocentESP", Color3.fromRGB(40, 220, 80))
criarToggle("Auto Shoot", 164, "AutoShoot", Color3.fromRGB(255, 40, 40))
criarToggle("Nome", 202, "MostrarNome", Color3.fromRGB(180, 120, 255))

-- ===== ESP =====
local function criarESP(player)
    if not player.Character then return end
    local h = Instance.new("Highlight")
    h.Name = "DKZIN_ESP"
    h.Adornee = player.Character
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = player.Character
    espCache[player] = h
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

    if gun:FindFirstChild("KnifeLocal") then
        local remote = gun.KnifeLocal:FindFirstChild("CreateBeam")
        if remote then
            remote:InvokeServer()
        end
    end
end

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
    autoShoot()
end)

print("☆♧DKZIN VS♧☆ MM2 Edition carregado!")
