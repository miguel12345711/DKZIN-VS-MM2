--[[
    AXION HUB | MM2
    Versão corrigida — UI / Key System / Abas / Painel
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

--==================================================
-- CONFIGURAÇÃO
--==================================================

local KEY_ETAPA1 = "boobnoob197e"
local KEY_PAINEL = "boobnoob197_102"

local Info = {
    Nome = "",
    Idade = "",
    Verificado = false
}

local Config = {
    MurdererESP = false,
    SheriffESP = false,
    InnocentESP = false,
    DroppedGunESP = false,
    AntiAFK = false,
    Speed = false
}

local C = {
    Fundo = Color3.fromRGB(15, 15, 22),
    Painel = Color3.fromRGB(22, 22, 32),
    Card = Color3.fromRGB(30, 30, 42),
    CardHover = Color3.fromRGB(45, 45, 62),

    Roxo = Color3.fromRGB(130, 70, 230),
    Ciano = Color3.fromRGB(70, 190, 240),
    Verde = Color3.fromRGB(60, 200, 100),
    Vermelho = Color3.fromRGB(230, 70, 70),
    Amarelo = Color3.fromRGB(240, 200, 60),

    Texto = Color3.fromRGB(240, 240, 250),
    SubTexto = Color3.fromRGB(150, 150, 175)
}

--==================================================
-- SCREEN GUI
--==================================================

local Tela = Instance.new("ScreenGui")
Tela.Name = "AXION_V50"
Tela.ResetOnSpawn = false
Tela.IgnoreGuiInset = true
Tela.Parent = PlayerGui

--==================================================
-- FUNÇÕES DE UI
--==================================================

local function CriarCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
    return corner
end

local function CriarStroke(obj, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Parent = obj
    return stroke
end

local function CriarBotao(parent, text, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = C.Texto
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = parent

    CriarCorner(button, 8)

    return button
end

--==================================================
-- KEY SYSTEM
--==================================================

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 420, 0, 320)
KeyFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
KeyFrame.BackgroundColor3 = C.Fundo
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = Tela

CriarCorner(KeyFrame, 14)
CriarStroke(KeyFrame, C.Roxo, 2)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = C.Painel
Header.BorderSizePixel = 0
Header.Parent = KeyFrame

CriarCorner(Header, 14)

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 14)
HeaderFix.Position = UDim2.new(0, 0, 1, -14)
HeaderFix.BackgroundColor3 = C.Painel
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "AXION HUB - Key System"
Title.TextColor3 = C.Texto
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Conteudo = Instance.new("Frame")
Conteudo.Size = UDim2.new(1, -30, 1, -75)
Conteudo.Position = UDim2.new(0, 15, 0, 60)
Conteudo.BackgroundTransparency = 1
Conteudo.Parent = KeyFrame

--==================================================
-- ETAPA 1
--==================================================

local Etapa1 = Instance.new("Frame")
Etapa1.Size = UDim2.new(1, 0, 1, 0)
Etapa1.BackgroundTransparency = 1
Etapa1.Parent = Conteudo

local E1Label = Instance.new("TextLabel")
E1Label.Size = UDim2.new(1, 0, 0, 25)
E1Label.BackgroundTransparency = 1
E1Label.Text = "Etapa 1 - Digite a Key:"
E1Label.TextColor3 = C.Ciano
E1Label.Font = Enum.Font.GothamBold
E1Label.TextSize = 14
E1Label.TextXAlignment = Enum.TextXAlignment.Left
E1Label.Parent = Etapa1

local E1Input = Instance.new("TextBox")
E1Input.Size = UDim2.new(1, 0, 0, 40)
E1Input.Position = UDim2.new(0, 0, 0, 35)
E1Input.BackgroundColor3 = C.Card
E1Input.PlaceholderText = "Digite a key..."
E1Input.Text = ""
E1Input.TextColor3 = C.Texto
E1Input.Font = Enum.Font.Gotham
E1Input.TextSize = 13
E1Input.BorderSizePixel = 0
E1Input.ClearTextOnFocus = false
E1Input.Parent = Etapa1

CriarCorner(E1Input, 8)

local E1Btn = CriarBotao(
    Etapa1,
    "VERIFICAR ETAPA 1",
    C.Roxo
)

E1Btn.Position = UDim2.new(0, 0, 0, 90)

local E1Status = Instance.new("TextLabel")
E1Status.Size = UDim2.new(1, 0, 0, 20)
E1Status.Position = UDim2.new(0, 0, 0, 140)
E1Status.BackgroundTransparency = 1
E1Status.Text = ""
E1Status.TextColor3 = C.Vermelho
E1Status.Font = Enum.Font.GothamMedium
E1Status.TextSize = 11
E1Status.Parent = Etapa1

--==================================================
-- ETAPA 2
--==================================================

local Etapa2 = Instance.new("Frame")
Etapa2.Size = UDim2.new(1, 0, 1, 0)
Etapa2.BackgroundTransparency = 1
Etapa2.Visible = false
Etapa2.Parent = Conteudo

local E2Label = Instance.new("TextLabel")
E2Label.Size = UDim2.new(1, 0, 0, 25)
E2Label.BackgroundTransparency = 1
E2Label.Text = "Etapa 2 - Preencha seus dados:"
E2Label.TextColor3 = C.Verde
E2Label.Font = Enum.Font.GothamBold
E2Label.TextSize = 14
E2Label.TextXAlignment = Enum.TextXAlignment.Left
E2Label.Parent = Etapa2

local E2Nome = Instance.new("TextBox")
E2Nome.Size = UDim2.new(1, 0, 0, 36)
E2Nome.Position = UDim2.new(0, 0, 0, 30)
E2Nome.BackgroundColor3 = C.Card
E2Nome.PlaceholderText = "Seu nome..."
E2Nome.Text = ""
E2Nome.TextColor3 = C.Texto
E2Nome.Font = Enum.Font.Gotham
E2Nome.TextSize = 12
E2Nome.BorderSizePixel = 0
E2Nome.ClearTextOnFocus = false
E2Nome.Parent = Etapa2

CriarCorner(E2Nome, 8)

local E2Idade = Instance.new("TextBox")
E2Idade.Size = UDim2.new(1, 0, 0, 36)
E2Idade.Position = UDim2.new(0, 0, 0, 72)
E2Idade.BackgroundColor3 = C.Card
E2Idade.PlaceholderText = "Sua idade..."
E2Idade.Text = ""
E2Idade.TextColor3 = C.Texto
E2Idade.Font = Enum.Font.Gotham
E2Idade.TextSize = 12
E2Idade.BorderSizePixel = 0
E2Idade.ClearTextOnFocus = false
E2Idade.Parent = Etapa2

CriarCorner(E2Idade, 8)

local E2Btn = CriarBotao(
    Etapa2,
    "FINALIZAR VERIFICACAO",
    C.Verde
)

E2Btn.Position = UDim2.new(0, 0, 0, 120)

local E2Status = Instance.new("TextLabel")
E2Status.Size = UDim2.new(1, 0, 0, 20)
E2Status.Position = UDim2.new(0, 0, 0, 170)
E2Status.BackgroundTransparency = 1
E2Status.Text = ""
E2Status.TextColor3 = C.Amarelo
E2Status.Font = Enum.Font.GothamMedium
E2Status.TextSize = 11
E2Status.Parent = Etapa2

--==================================================
-- VALIDAÇÃO
--==================================================

E1Btn.MouseButton1Click:Connect(function()

    if E1Input.Text == KEY_ETAPA1 then

        E1Status.Text = "Key correta! Avançando..."
        E1Status.TextColor3 = C.Verde

        task.wait(0.5)

        Etapa1.Visible = false
        Etapa2.Visible = true

    else

        E1Status.Text = "Key incorreta!"
        E1Status.TextColor3 = C.Vermelho

    end

end)

E2Btn.MouseButton1Click:Connect(function()

    local nome = E2Nome.Text:gsub("^%s+", ""):gsub("%s+$", "")
    local idade = tonumber(E2Idade.Text)

    if #nome < 2 then
        E2Status.Text = "Digite um nome válido."
        E2Status.TextColor3 = C.Vermelho
        return
    end

    if not idade or idade < 5 or idade > 100 then
        E2Status.Text = "Digite uma idade válida."
        E2Status.TextColor3 = C.Vermelho
        return
    end

    Info.Nome = nome
    Info.Idade = tostring(math.floor(idade))
    Info.Verificado = true

    E2Status.Text = "Verificação concluída!"
    E2Status.TextColor3 = C.Verde

    task.wait(0.5)

    KeyFrame.Visible = false

    if _G.AXION_ABRIR_MENU then
        _G.AXION_ABRIR_MENU()
    end

end)

--==================================================
-- MENU
--==================================================

local Menu = Instance.new("Frame")
Menu.Size = UDim2.new(0, 580, 0, 420)
Menu.Position = UDim2.new(0.5, -290, 0.5, -210)
Menu.BackgroundColor3 = C.Fundo
Menu.BorderSizePixel = 0
Menu.Active = true
Menu.Draggable = true
Menu.Visible = false
Menu.Parent = Tela

CriarCorner(Menu, 12)
CriarStroke(Menu, C.Roxo, 1.5)

local MenuHeader = Instance.new("Frame")
MenuHeader.Size = UDim2.new(1, 0, 0, 50)
MenuHeader.BackgroundColor3 = C.Painel
MenuHeader.BorderSizePixel = 0
MenuHeader.Parent = Menu

CriarCorner(MenuHeader, 12)

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(1, -100, 1, 0)
MenuTitle.Position = UDim2.new(0, 18, 0, 0)
MenuTitle.BackgroundTransparency = 1
MenuTitle.Text = "AXION HUB"
MenuTitle.TextColor3 = C.Texto
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextSize = 15
MenuTitle.TextXAlignment = Enum.TextXAlignment.Left
MenuTitle.Parent = MenuHeader

local UserInfo = Instance.new("TextLabel")
UserInfo.Size = UDim2.new(0, 180, 1, 0)
UserInfo.Position = UDim2.new(1, -260, 0, 0)
UserInfo.BackgroundTransparency = 1
UserInfo.TextColor3 = C.Ciano
UserInfo.Font = Enum.Font.GothamMedium
UserInfo.TextSize = 10
UserInfo.TextXAlignment = Enum.TextXAlignment.Right
UserInfo.Parent = MenuHeader

local Fechar = Instance.new("TextButton")
Fechar.Size = UDim2.new(0, 28, 0, 28)
Fechar.Position = UDim2.new(1, -36, 0, 11)
Fechar.BackgroundColor3 = C.Vermelho
Fechar.Text = "X"
Fechar.TextColor3 = C.Texto
Fechar.Font = Enum.Font.GothamBold
Fechar.TextSize = 12
Fechar.BorderSizePixel = 0
Fechar.Parent = MenuHeader

CriarCorner(Fechar, 14)

Fechar.MouseButton1Click:Connect(function()
    Menu.Visible = false
end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = C.Painel
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Menu

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 5)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

--==================================================
-- CONTEÚDO
--==================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, -60)
Content.Position = UDim2.new(0, 145, 0, 55)
Content.BackgroundTransparency = 1
Content.Parent = Menu

local Pages = {}
local Tabs = {}
local CurrentTab = nil

local function MostrarAba(nome)

    for nomePagina, pagina in pairs(Pages) do
        pagina.Visible = nomePagina == nome
    end

    for nomeBotao, botao in pairs(Tabs) do

        if nomeBotao == nome then
            botao.BackgroundColor3 = C.Roxo
            botao.TextColor3 = C.Texto
        else
            botao.BackgroundColor3 = C.Card
            botao.TextColor3 = C.SubTexto
        end

    end

    CurrentTab = nome
end

local function CriarAba(nome, icone)

    local botao = Instance.new("TextButton")
    botao.Size = UDim2.new(1, 0, 0, 34)
    botao.BackgroundColor3 = C.Card
    botao.Text = "  " .. icone .. "  " .. nome
    botao.TextColor3 = C.SubTexto
    botao.Font = Enum.Font.GothamSemibold
    botao.TextSize = 11
    botao.TextXAlignment = Enum.TextXAlignment.Left
    botao.BorderSizePixel = 0
    botao.AutoButtonColor = false
    botao.Parent = Sidebar

    CriarCorner(botao, 6)

    local pagina = Instance.new("ScrollingFrame")
    pagina.Size = UDim2.new(1, 0, 1, 0)
    pagina.BackgroundTransparency = 1
    pagina.BorderSizePixel = 0
    pagina.ScrollBarThickness = 3
    pagina.ScrollBarImageColor3 = C.Roxo
    pagina.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pagina.CanvasSize = UDim2.new(0, 0, 0, 0)
    pagina.Visible = false
    pagina.Parent = Content

    local lista = Instance.new("UIListLayout")
    lista.Padding = UDim.new(0, 6)
    lista.SortOrder = Enum.SortOrder.LayoutOrder
    lista.Parent = pagina

    Pages[nome] = pagina
    Tabs[nome] = botao

    botao.MouseButton1Click:Connect(function()
        MostrarAba(nome)
    end)

    botao.MouseEnter:Connect(function()
        if CurrentTab ~= nome then
            botao.BackgroundColor3 = C.CardHover
        end
    end)

    botao.MouseLeave:Connect(function()
        if CurrentTab ~= nome then
            botao.BackgroundColor3 = C.Card
        end
    end)

    return pagina
end

--==================================================
-- TOGGLE
--==================================================

local function CriarToggle(parent, texto, key)

    local card = Instance.new("TextButton")
    card.Size = UDim2.new(1, 0, 0, 40)
    card.BackgroundColor3 = C.Card
    card.Text = ""
    card.AutoButtonColor = false
    card.BorderSizePixel = 0
    card.Parent = parent

    CriarCorner(card, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = texto
    label.TextColor3 = C.Texto
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = card

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 32, 0, 18)
    switch.Position = UDim2.new(1, -42, 0.5, -9)
    switch.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    switch.BorderSizePixel = 0
    switch.Parent = card

    CriarCorner(switch, 20)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(0, 2, 0.5, -7)
    dot.BackgroundColor3 = C.Texto
    dot.BorderSizePixel = 0
    dot.Parent = switch

    CriarCorner(dot, 20)

    local function Atualizar()

        if Config[key] then
            switch.BackgroundColor3 = C.Verde
            dot.Position = UDim2.new(1, -16, 0.5, -7)
        else
            switch.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
            dot.Position = UDim2.new(0, 2, 0.5, -7)
        end

    end

    card.MouseButton1Click:Connect(function()

        Config[key] = not Config[key]

        Atualizar()

    end)

    Atualizar()

    return card
end

--==================================================
-- ABAS
--==================================================

CriarAba("ESP", "E")
CriarAba("Farm", "F")
CriarAba("Combat", "C")
CriarAba("Misc", "M")

CriarToggle(Pages.ESP, "ESP Assassino", "MurdererESP")
CriarToggle(Pages.ESP, "ESP Xerife", "SheriffESP")
CriarToggle(Pages.ESP, "ESP Inocente", "InnocentESP")
CriarToggle(Pages.ESP, "ESP Arma Caída", "DroppedGunESP")

CriarToggle(Pages.Farm, "Auto Coins", "AutoCoins")
CriarToggle(Pages.Farm, "Anti-AFK", "AntiAFK")

CriarToggle(Pages.Combat, "Kill All", "KillAll")

CriarToggle(Pages.Misc, "Noclip", "Noclip")
CriarToggle(Pages.Misc, "Speed", "Speed")

MostrarAba("ESP")

--==================================================
-- PAINEL RÁPIDO
--==================================================

local Painel = Instance.new("Frame")
Painel.Size = UDim2.new(0, 200, 0, 290)
Painel.Position = UDim2.new(1, -210, 0, 80)
Painel.BackgroundColor3 = C.Painel
Painel.BorderSizePixel = 0
Painel.Active = true
Painel.Draggable = true
Painel.Visible = false
Painel.Parent = Tela

CriarCorner(Painel, 10)
CriarStroke(Painel, C.Ciano, 1.5)

local PainelHeader = Instance.new("TextLabel")
PainelHeader.Size = UDim2.new(1, 0, 0, 32)
PainelHeader.BackgroundColor3 = C.Ciano
PainelHeader.Text = "PAINEL RÁPIDO"
PainelHeader.TextColor3 = C.Texto
PainelHeader.Font = Enum.Font.GothamBold
PainelHeader.TextSize = 11
PainelHeader.BorderSizePixel = 0
PainelHeader.Parent = Painel

CriarCorner(PainelHeader, 10)

local PainelList = Instance.new("UIListLayout")
PainelList.Padding = UDim.new(0, 4)
PainelList.Parent = Painel
PainelList.SortOrder = Enum.SortOrder.LayoutOrder

local PainelPad = Instance.new("UIPadding")
PainelPad.PaddingTop = UDim.new(0, 38)
PainelPad.PaddingLeft = UDim.new(0, 6)
PainelPad.PaddingRight = UDim.new(0, 6)
PainelPad.Parent = Painel

local function CriarQuickToggle(texto, key)

    local botao = Instance.new("TextButton")
    botao.Size = UDim2.new(1, 0, 0, 30)
    botao.BackgroundColor3 = C.Card
    botao.Text = texto
    botao.TextColor3 = C.Texto
    botao.Font = Enum.Font.GothamMedium
    botao.TextSize = 10
    botao.BorderSizePixel = 0
    botao.AutoButtonColor = false
    botao.Parent = Painel

    CriarCorner(botao, 5)

    local function Atualizar()
        botao.BackgroundColor3 =
            Config[key] and C.Verde or C.Card
    end

    botao.MouseButton1Click:Connect(function()

        Config[key] = not Config[key]

        Atualizar()

    end)

    Atualizar()

    return botao
end

CriarQuickToggle("ESP Murderer", "MurdererESP")
CriarQuickToggle("ESP Sheriff", "SheriffESP")
CriarQuickToggle("ESP Innocent", "InnocentESP")
CriarQuickToggle("ESP Dropped Gun", "DroppedGunESP")
CriarQuickToggle("Auto Coins", "AutoCoins")
CriarQuickToggle("Kill All", "KillAll")
CriarQuickToggle("Noclip", "Noclip")

--==================================================
-- KEY DO PAINEL
--==================================================

local PKFrame = Instance.new("Frame")
PKFrame.Size = UDim2.new(0, 260, 0, 140)
PKFrame.Position = UDim2.new(0.5, -130, 0.5, -70)
PKFrame.BackgroundColor3 = C.Fundo
PKFrame.BorderSizePixel = 0
PKFrame.Active = true
PKFrame.Draggable = true
PKFrame.Visible = false
PKFrame.Parent = Tela

CriarCorner(PKFrame, 10)
CriarStroke(PKFrame, C.Ciano, 1.5)

local PKTitle = Instance.new("TextLabel")
PKTitle.Size = UDim2.new(1, 0, 0, 30)
PKTitle.BackgroundTransparency = 1
PKTitle.Text = "KEY DO PAINEL"
PKTitle.TextColor3 = C.Ciano
PKTitle.Font = Enum.Font.GothamBold
PKTitle.TextSize = 13
PKTitle.Parent = PKFrame

local PKInput = Instance.new("TextBox")
PKInput.Size = UDim2.new(1, -20, 0, 36)
PKInput.Position = UDim2.new(0, 10, 0, 40)
PKInput.BackgroundColor3 = C.Card
PKInput.PlaceholderText = "Digite a key..."
PKInput.Text = ""
PKInput.TextColor3 = C.Texto
PKInput.Font = Enum.Font.Gotham
PKInput.TextSize = 12
PKInput.BorderSizePixel = 0
PKInput.ClearTextOnFocus = false
PKInput.Parent = PKFrame

CriarCorner(PKInput, 8)

local PKBtn = CriarBotao(
    PKFrame,
    "ABRIR PAINEL",
    C.Ciano
)

PKBtn.Size = UDim2.new(1, -20, 0, 32)
PKBtn.Position = UDim2.new(0, 10, 0, 85)

local PKStatus = Instance.new("TextLabel")
PKStatus.Size = UDim2.new(1, 0, 0, 15)
PKStatus.Position = UDim2.new(0, 0, 0, 120)
PKStatus.BackgroundTransparency = 1
PKStatus.Text = ""
PKStatus.TextColor3 = C.Vermelho
PKStatus.Font = Enum.Font.GothamMedium
PKStatus.TextSize = 10
PKStatus.Parent = PKFrame

--==================================================
-- BOTÃO DO PAINEL
--==================================================

local BtnPainel = Instance.new("TextButton")
BtnPainel.Size = UDim2.new(0, 30, 0, 30)
BtnPainel.Position = UDim2.new(1, -72, 0, 10)
BtnPainel.BackgroundColor3 = C.Ciano
BtnPainel.Text = "P"
BtnPainel.TextColor3 = C.Texto
BtnPainel.Font = Enum.Font.GothamBold
BtnPainel.TextSize = 12
BtnPainel.BorderSizePixel = 0
BtnPainel.Parent = MenuHeader

CriarCorner(BtnPainel, 15)

BtnPainel.MouseButton1Click:Connect(function()

    if Painel.Visible then
        Painel.Visible = false
        return
    end

    PKFrame.Visible = true

end)

PKBtn.MouseButton1Click:Connect(function()

    if PKInput.Text == KEY_PAINEL then

        PKStatus.Text = "Correto!"
        PKStatus.TextColor3 = C.Verde

        task.wait(0.4)

        PKFrame.Visible = false
        Painel.Visible = true

    else

        PKStatus.Text = "Key incorreta!"
        PKStatus.TextColor3 = C.Vermelho

    end

end)

--==================================================
-- BOTÃO FLUTUANTE
--==================================================

local AbrirBtn = Instance.new("TextButton")
AbrirBtn.Size = UDim2.new(0, 48, 0, 48)
AbrirBtn.Position = UDim2.new(0.03, 0, 0.4, 0)
AbrirBtn.BackgroundColor3 = C.Roxo
AbrirBtn.Text = "A"
AbrirBtn.TextSize = 22
AbrirBtn.Font = Enum.Font.GothamBold
AbrirBtn.TextColor3 = C.Texto
AbrirBtn.BorderSizePixel = 0
AbrirBtn.Active = true
AbrirBtn.Draggable = true
AbrirBtn.Visible = false
AbrirBtn.Parent = Tela

CriarCorner(AbrirBtn, 24)
CriarStroke(AbrirBtn, C.Ciano, 2)

AbrirBtn.MouseButton1Click:Connect(function()
    Menu.Visible = not Menu.Visible
end)

--==================================================
-- ABERTURA DO MENU
--==================================================

_G.AXION_ABRIR_MENU = function()

    if not Info.Verificado then
        return
    end

    Menu.Visible = true

    UserInfo.Text =
        Info.Nome .. " - " .. Info.Idade .. " anos"

end

task.spawn(function()

    while not Info.Verificado do
        task.wait(0.5)
    end

    AbrirBtn.Visible = true

end)

--==================================================
-- TECLA P
--==================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)

    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.P then

        if Painel.Visible then
            Painel.Visible = false
            return
        end

        PKFrame.Visible = not PKFrame.Visible

    end

end)

print("AXION HUB — interface carregada.")
