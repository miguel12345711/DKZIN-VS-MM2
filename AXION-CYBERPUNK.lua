--[[
    🔮 AXION HUB — CYBERPUNK EDITION
    Visual: Neon Roxo/Ciano | Menu Numerado
    Roda em: PC + Mobile
    Cole no executor e execute!
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- ===== CORES NEON =====
local C = {
    Fundo = Color3.fromRGB(8, 8, 15),
    Painel = Color3.fromRGB(15, 15, 25),
    Card = Color3.fromRGB(22, 22, 35),
    CardHover = Color3.fromRGB(35, 35, 55),
    Roxo = Color3.fromRGB(140, 60, 255),
    Ciano = Color3.fromRGB(60, 200, 255),
    Rosa = Color3.fromRGB(220, 60, 180),
    Texto = Color3.fromRGB(255, 255, 255),
    SubTexto = Color3.fromRGB(160, 160, 200),
    Verde = Color3.fromRGB(50, 220, 100),
    Vermelho = Color3.fromRGB(255, 60, 60),
}

-- ===== TELA =====
local Tela = Instance.new("ScreenGui")
Tela.Name = "AXION_Cyberpunk"
Tela.ResetOnSpawn = false
Tela.IgnoreGuiInset = true
Tela.Parent = PlayerGui

-- Botão flutuante (abre o menu)
local Abrir = Instance.new("TextButton")
Abrir.Size = UDim2.new(0, 50, 0, 50)
Abrir.Position = UDim2.new(0.03, 0, 0.4, 0)
Abrir.BackgroundColor3 = C.Roxo
Abrir.Text = "🔮"
Abrir.TextSize = 24
Abrir.Font = Enum.Font.GothamBold
Abrir.TextColor3 = C.Texto
Abrir.BorderSizePixel = 0
Abrir.Active = true
Abrir.Draggable = true
Abrir.Parent = Tela

local AbrirCorner = Instance.new("UICorner")
AbrirCorner.CornerRadius = UDim.new(1, 0)
AbrirCorner.Parent = Abrir

local AbrirStroke = Instance.new("UIStroke")
AbrirStroke.Color = C.Ciano
AbrirStroke.Thickness = 2
AbrirStroke.Transparency = 0.3
AbrirStroke.Parent = Abrir

-- ===== MENU PRINCIPAL =====
local Menu = Instance.new("Frame")
Menu.Name = "MenuPrincipal"
Menu.Size = UDim2.new(0, 520, 0, 380)
Menu.Position = UDim2.new(0.5, -260, 0.5, -190)
Menu.BackgroundColor3 = C.Fundo
Menu.BorderSizePixel = 0
Menu.Active = true
Menu.Draggable = true
Menu.Visible = false
Menu.Parent = Tela

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 14)
MenuCorner.Parent = Menu

-- Borda neon dupla
local Borda1 = Instance.new("UIStroke")
Borda1.Color = C.Roxo
Borda1.Thickness = 2
Borda1.Parent = Menu

local Borda2 = Instance.new("UIStroke")
Borda2.Color = C.Ciano
Borda2.Thickness = 1
Borda2.Transparency = 0.5
Borda2.Parent = Menu

-- Gradiente de fundo sutil
local FundoGrad = Instance.new("UIGradient")
FundoGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 8, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 8, 15)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 15, 30)),
})
FundoGrad.Rotation = 135
FundoGrad.Parent = Menu

-- ===== CABEÇALHO =====
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 55)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
Header.BorderSizePixel = 0
Header.Parent = Menu

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 15)
HeaderFix.Position = UDim2.new(0, 0, 1, -15)
HeaderFix.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local HeaderGrad = Instance.new("UIGradient")
HeaderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 60, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 200, 255)),
})
HeaderGrad.Rotation = 45
HeaderGrad.Parent = Header

-- Título com efeito neon
local Titulo = Instance.new("TextLabel")
Titulo.Size = UDim2.new(1, -100, 1, 0)
Titulo.Position = UDim2.new(0, 20, 0, 0)
Titulo.BackgroundTransparency = 1
Titulo.Text = "🔮 AXION HUB"
Titulo.TextColor3 = C.Texto
Titulo.Font = Enum.Font.GothamBold
Titulo.TextSize = 20
Titulo.TextXAlignment = Enum.TextXAlignment.Left
Titulo.Parent = Header

-- Linhas decorativas (///)
local Decor = Instance.new("TextLabel")
Decor.Size = UDim2.new(0, 200, 1, 0)
Decor.Position = UDim2.new(1, -220, 0, 0)
Decor.BackgroundTransparency = 1
Decor.Text = "◇◇◇◇◇◇◇◇◇◇"
Decor.TextColor3 = C.Ciano
Decor.Font = Enum.Font.GothamBold
Decor.TextSize = 14
Decor.TextTransparency = 0.4
Decor.TextXAlignment = Enum.TextXAlignment.Right
Decor.Parent = Header

-- Botão fechar
local Fechar = Instance.new("TextButton")
Fechar.Size = UDim2.new(0, 26, 0, 26)
Fechar.Position = UDim2.new(1, -34, 0, 14)
Fechar.BackgroundColor3 = C.Vermelho
Fechar.Text = "✕"
Fechar.TextColor3 = C.Texto
Fechar.Font = Enum.Font.GothamBold
Fechar.TextSize = 14
Fechar.BorderSizePixel = 0
Fechar.ZIndex = 5
Fechar.Parent = Header

local FecharCorner = Instance.new("UICorner")
FecharCorner.CornerRadius = UDim.new(1, 0)
FecharCorner.Parent = Fechar

Fechar.MouseButton1Click:Connect(function()
    Menu.Visible = false
end)

Abrir.MouseButton1Click:Connect(function()
    Menu.Visible = not Menu.Visible
end)

-- ===== SIDEBAR (abas) =====
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -55)
Sidebar.Position = UDim2.new(0, 0, 0, 55)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Menu

local SidebarFix = Instance.new("Frame")
SidebarFix.Size = UDim2.new(0, 1, 1, 0)
SidebarFix.Position = UDim2.new(1, -1, 0, 0)
SidebarFix.BackgroundColor3 = C.Roxo
SidebarFix.BorderSizePixel = 0
SidebarFix.BackgroundTransparency = 0.5
SidebarFix.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 6)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

-- ===== ÁREA DE CONTEÚDO =====
local Conteudo = Instance.new("Frame")
Conteudo.Size = UDim2.new(1, -160, 1, -65)
Conteudo.Position = UDim2.new(0, 155, 0, 60)
Conteudo.BackgroundTransparency = 1
Conteudo.Parent = Menu

local Pages = {}
local TabButtons = {}
local CurrentTab = nil

local function MostrarAba(nome)
    for tabNome, page in pairs(Pages) do
        page.Visible = (tabNome == nome)
    end
    for tabNome, btn in pairs(TabButtons) do
        if tabNome == nome then
            btn.BackgroundColor3 = C.Roxo
            btn.TextColor3 = C.Texto
        else
            btn.BackgroundColor3 = C.Card
            btn.TextColor3 = C.SubTexto
        end
    end
    CurrentTab = nome
end

local function CriarAba(nome, icone)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = C.Card
    btn.Text = "  " .. icone .. "  " .. nome
    btn.TextColor3 = C.SubTexto
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = Sidebar

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.Roxo
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Conteudo

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page

    Pages[nome] = page
    TabButtons[nome] = btn

    btn.MouseButton1Click:Connect(function()
        MostrarAba(nome)
    end)

    btn.MouseEnter:Connect(function()
        if CurrentTab ~= nome then
            btn.BackgroundColor3 = C.CardHover
        end
    end)
    btn.MouseLeave:Connect(function()
        if CurrentTab ~= nome then
            btn.BackgroundColor3 = C.Card
        end
    end)
end

-- ===== FUNÇÃO: CRIAR CARD NUMERADO (estilo cyberpunk) =====
local contadorGlobal = 0

local function CriarCard(parent, numero, texto, callback, tipo)
    tipo = tipo or "toggle"

    local Card = Instance.new("TextButton")
    Card.Size = UDim2.new(1, 0, 0, 46)
    Card.BackgroundColor3 = C.Card
    Card.Text = ""
    Card.AutoButtonColor = false
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 8)
    cc.Parent = Card

    local cs = Instance.new("UIStroke")
    cs.Color = C.Roxo
    cs.Thickness = 1
    cs.Transparency = 0.7
    cs.Parent = Card

    -- Número (01, 02, 03)
    local Numero = Instance.new("TextLabel")
    Numero.Size = UDim2.new(0, 40, 1, 0)
    Numero.Position = UDim2.new(0, 8, 0, 0)
    Numero.BackgroundTransparency = 1
    Numero.Text = string.format("%02d", numero)
    Numero.TextColor3 = C.Ciano
    Numero.Font = Enum.Font.GothamBold
    Numero.TextSize = 14
    Numero.Parent = Card

    -- Ícone decorativo
    local Icone = Instance.new("TextLabel")
    Icone.Size = UDim2.new(0, 24, 1, 0)
    Icone.Position = UDim2.new(0, 50, 0, 0)
    Icone.BackgroundTransparency = 1
    Icone.Text = "◆"
    Icone.TextColor3 = C.Rosa
    Icone.Font = Enum.Font.GothamBold
    Icone.TextSize = 12
    Icone.Parent = Card

    -- Texto
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -140, 1, 0)
    Label.Position = UDim2.new(0, 80, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = texto
    Label.TextColor3 = C.Texto
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card

    -- Indicador de estado (só pra toggle)
    local Indicador = Instance.new("Frame")
    Indicador.Size = UDim2.new(0, 36, 0, 20)
    Indicador.Position = UDim2.new(1, -46, 0.5, -10)
    Indicador.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    Indicador.BorderSizePixel = 0
    Indicador.Parent = Card

    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(1, 0)
    ic.Parent = Indicador

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = UDim2.new(0, 2, 0.5, -8)
    Dot.BackgroundColor3 = C.Texto
    Dot.BorderSizePixel = 0
    Dot.Parent = Indicador

    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = Dot

    -- Hover
    Card.MouseEnter:Connect(function()
        Card.BackgroundColor3 = C.CardHover
        cs.Transparency = 0.3
    end)
    Card.MouseLeave:Connect(function()
        Card.BackgroundColor3 = C.Card
        cs.Transparency = 0.7
    end)

    if tipo == "toggle" then
        local Estado = false
        Card.MouseButton1Click:Connect(function()
            Estado = not Estado
            if Estado then
                Indicador.BackgroundColor3 = C.Verde
                Dot.Position = UDim2.new(1, -18, 0.5, -8)
                cs.Color = C.Verde
            else
                Indicador.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
                Dot.Position = UDim2.new(0, 2, 0.5, -8)
                cs.Color = C.Roxo
            end
            if callback then callback(Estado) end
        end)
    else
        -- Botão normal
        Card.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    return Card
end

-- ===== CRIAR ABAS =====
CriarAba("Visual", "👁")
CriarAba("Combate", "⚔")
CriarAba("Utilidades", "⚙")

-- ===== VARIÁVEIS DE ESTADO =====
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
    Speed = false,
}

-- ===== ABA VISUAL =====
local numV = 0
numV = numV + 1
CriarCard(Pages["Visual"], numV, "ESP Assassino", function(v)
    Config.MurdererESP = v
end, "toggle")

numV = numV + 1
CriarCard(Pages["Visual"], numV, "ESP Xerife", function(v)
    Config.SheriffESP = v
end, "toggle")

numV = numV + 1
CriarCard(Pages["Visual"], numV, "ESP Inocente", function(v)
    Config.InnocentESP = v
end, "toggle")

numV = numV + 1
CriarCard(Pages["Visual"], numV, "Mostrar Nomes", function(v)
    Config.MostrarNomes = v
end, "toggle")

numV = numV + 1
CriarCard(Pages["Visual"], numV, "Fullbright", function(v)
    Config.Fullbright = v
end, "toggle")

-- ===== ABA COMBATE =====
local numC = 0
numC = numC + 1
CriarCard(Pages["Combate"], numC, "Auto Shoot", function(v)
    Config.AutoShoot = v
end, "toggle")

numC = numC + 1
CriarCard(Pages["Combate"], numC, "Freeze Assassino", function(v)
    Config.FreezeMurderer = v
end, "toggle")

-- ===== ABA UTILIDADES =====
local numU = 0
numU = numU + 1
CriarCard(Pages["Utilidades"], numU, "Auto Grab Gun", function(v)
    Config.AutoGrabGun = v
end, "toggle")

numU = numU + 1
CriarCard(Pages["Utilidades"], numU, "Speed Boost", function(v)
    Config.Speed = v
end, "toggle")

numU = numU + 1
CriarCard(Pages["Utilidades"], numU, "Fechar Menu", function()
    Menu.Visible = false
end, "button")

MostrarAba("Visual")

-- ===== LÓGICA DAS FUNÇÕES =====

-- Detecta função do player
local function DetectarFuncao(player)
    local char = player.Character
    if not char then return "Innocent" end
    local function tem(n)
        if char:FindFirstChild(n) then return true end
        local bp = player:FindFirstChild("Backpack")
        if bp and bp:FindFirstChild(n) then return true end
        return false
    end
    if tem("Knife") or tem("MurdererKnife") or tem("KnifeLocal") then return "Murderer" end
    if tem("Gun") or tem("Revolver") or tem("GunLocal") then return "Sheriff" end
    return "Innocent"
end

-- ESP
local espCache = {}
local nomeCache = {}

local function CriarESP(player)
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
        lbl.TextColor3 = C.Texto
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
        n.Enabled = Config.MostrarNomes and ativo
        local lbl = n:FindFirstChildOfClass("TextLabel")
        if lbl then
            lbl.Text = player.Name .. " [" .. role .. "]"
            lbl.TextColor3 = cor
        end
    end
end

-- Auto Shoot
local function GetMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and DetectarFuncao(p) == "Murderer" then return p end
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
    local vel = tHRP.Velocity
    local posPrev = tHRP.Position + (vel * Config.Previsao)
    local dir = (posPrev - myHRP.Position).Unit
    myHRP.CFrame = CFrame.new(myHRP.Position, myHRP.Position + dir)
end

-- Freeze
local function FreezeMurderer()
    if not Config.FreezeMurderer then return end
    local m = GetMurderer()
    if not m or not m.Character then return end
    local hrp = m.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
end

-- Auto Grab Gun
local function AutoGrabGun()
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

-- Speed
local function AplicarSpeed()
    if not Config.Speed then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 32 end
end

-- Fullbright
local function AplicarFullbright()
    if Config.Fullbright then
        game.Lighting.Brightness = 3
        game.Lighting.ClockTime = 14
        game.Lighting.FogEnd = 100000
        game.Lighting.GlobalShadows = false
    end
end

-- Loop principal
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        AtualizarESP(p)
    end)
end)

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LP and p.Character then AtualizarESP(p) end
end

RunService.Heartbeat:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then AtualizarESP(p) end
    end
    pcall(AutoShoot)
    pcall(FreezeMurderer)
    pcall(AutoGrabGun)
    pcall(AplicarSpeed)
    pcall(AplicarFullbright)
end)

print("🔮 AXION HUB — Cyberpunk Edition carregado!")
