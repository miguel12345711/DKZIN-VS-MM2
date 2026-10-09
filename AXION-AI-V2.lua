--[[
    AXION AI v2 | MM2
    IA de Verdade (Groq API)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- ==================================================
-- CONFIG DA IA
-- ==================================================

local GROQ_API_KEY = "COLA_SUA_KEY_AQUI"
local GROQ_MODEL = "llama-3.1-8b-instant"

local HistoricoConversa = {}

local SystemPrompt = [[Você é o AXION, um assistente brasileiro que ajuda no jogo Murder Mystery 2 (MM2) do Roblox. 
Fale de forma descontraída, use gírias brasileiras (mano, veio, cara), seja direto e útil.
Se a pergunta for sobre MM2, dê dicas reais sobre Sheriff, Murderer e Innocent.
Se for sobre outras coisas, responda de forma simples.
Nunca use markdown, negrito ou asteriscos. Só texto puro.
Máximo 3 frases por resposta.]]

-- ==================================================
-- FUNÇÃO PRA CHAMAR A IA
-- ==================================================

local function PerguntarIA(pergunta)
    if GROQ_API_KEY == "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" then
        return "ERRO: Você não colou a API key no script!"
    end

    table.insert(HistoricoConversa, {role = "user", content = pergunta})

    if #HistoricoConversa > 10 then
        table.remove(HistoricoConversa, 1)
    end

    local mensagens = {{role = "system", content = SystemPrompt}}
    for _, msg in ipairs(HistoricoConversa) do
        table.insert(mensagens, msg)
    end

    local body = HttpService:JSONEncode({
        model = GROQ_MODEL,
        messages = mensagens,
        temperature = 0.8,
        max_tokens = 200,
    })

    local sucesso, resposta = pcall(function()
        return request({
            Url = "https://api.groq.com/openai/v1/chat/completions",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. GROQ_API_KEY,
            },
            Body = body,
        })
    end)

    if not sucesso then
        return "Erro de rede: não consegui conectar na IA. (" .. tostring(resposta) .. ")"
    end

    local ok, data = pcall(function()
        return HttpService:JSONDecode(resposta.Body)
    end)

    if not ok or not data.choices then
        return "Erro: resposta inválida da IA."
    end

    local respostaIA = data.choices[1].message.content
    table.insert(HistoricoConversa, {role = "assistant", content = respostaIA})

    return respostaIA
end

-- ==================================================
-- CORES
-- ==================================================

local C = {
    Fundo = Color3.fromRGB(18, 18, 24),
    Painel = Color3.fromRGB(26, 26, 34),
    Card = Color3.fromRGB(34, 34, 44),
    CardHover = Color3.fromRGB(46, 46, 58),
    Borda = Color3.fromRGB(58, 58, 72),
    Roxo = Color3.fromRGB(138, 92, 246),
    Ciano = Color3.fromRGB(56, 189, 248),
    Verde = Color3.fromRGB(74, 222, 128),
    Vermelho = Color3.fromRGB(248, 113, 113),
    Texto = Color3.fromRGB(240, 240, 250),
    SubTexto = Color3.fromRGB(150, 150, 170),
}

-- ==================================================
-- TELA
-- ==================================================

local Tela = Instance.new("ScreenGui")
Tela.Name = "AXION_AI_v2"
Tela.ResetOnSpawn = false
Tela.IgnoreGuiInset = true
Tela.Parent = PlayerGui

local Abrir = Instance.new("TextButton")
Abrir.Size = UDim2.new(0, 50, 0, 50)
Abrir.Position = UDim2.new(0.04, 0, 0.4, 0)
Abrir.BackgroundColor3 = C.Roxo
Abrir.Text = "AI"
Abrir.TextSize = 18
Abrir.Font = Enum.Font.GothamBold
Abrir.TextColor3 = C.Texto
Abrir.BorderSizePixel = 0
Abrir.Active = true
Abrir.Draggable = true
Abrir.Parent = Tela

local ac = Instance.new("UICorner")
ac.CornerRadius = UDim.new(1, 0)
ac.Parent = Abrir

local as = Instance.new("UIStroke")
as.Color = C.Ciano
as.Thickness = 2
as.Transparency = 0.3
as.Parent = Abrir

local Menu = Instance.new("Frame")
Menu.Size = UDim2.new(0, 520, 0, 400)
Menu.Position = UDim2.new(0.5, -260, 0.5, -200)
Menu.BackgroundColor3 = C.Fundo
Menu.BorderSizePixel = 0
Menu.Active = true
Menu.Draggable = true
Menu.Visible = false
Menu.Parent = Tela

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 14)
mc.Parent = Menu

local ms = Instance.new("UIStroke")
ms.Color = C.Borda
ms.Thickness = 1
ms.Parent = Menu

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = C.Painel
Header.BorderSizePixel = 0
Header.Parent = Menu

local hc = Instance.new("UICorner")
hc.CornerRadius = UDim.new(0, 14)
hc.Parent = Header

local hfix = Instance.new("Frame")
hfix.Size = UDim2.new(1, 0, 0, 14)
hfix.Position = UDim2.new(0, 0, 1, -14)
hfix.BackgroundColor3 = C.Painel
hfix.BorderSizePixel = 0
hfix.Parent = Header

local Titulo = Instance.new("TextLabel")
Titulo.Size = UDim2.new(1, -100, 1, 0)
Titulo.Position = UDim2.new(0, 20, 0, 0)
Titulo.BackgroundTransparency = 1
Titulo.Text = "AXION AI"
Titulo.TextColor3 = C.Texto
Titulo.Font = Enum.Font.GothamBold
Titulo.TextSize = 17
Titulo.TextXAlignment = Enum.TextXAlignment.Left
Titulo.Parent = Header

local Sub = Instance.new("TextLabel")
Sub.Size = UDim2.new(0, 150, 1, 0)
Sub.Position = UDim2.new(1, -180, 0, 0)
Sub.BackgroundTransparency = 1
Sub.Text = "IA Real • v2.0"
Sub.TextColor3 = C.SubTexto
Sub.Font = Enum.Font.GothamMedium
Sub.TextSize = 10
Sub.TextXAlignment = Enum.TextXAlignment.Right
Sub.Parent = Header

local Fechar = Instance.new("TextButton")
Fechar.Size = UDim2.new(0, 30, 0, 30)
Fechar.Position = UDim2.new(1, -40, 0, 11)
Fechar.BackgroundColor3 = C.Vermelho
Fechar.Text = "X"
Fechar.TextColor3 = C.Texto
Fechar.Font = Enum.Font.GothamBold
Fechar.TextSize = 13
Fechar.BorderSizePixel = 0
Fechar.Parent = Header

local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(1, 0)
fc.Parent = Fechar

Fechar.MouseButton1Click:Connect(function()
    Menu.Visible = false
end)

Abrir.MouseButton1Click:Connect(function()
    Menu.Visible = not Menu.Visible
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -52)
Sidebar.Position = UDim2.new(0, 0, 0, 52)
Sidebar.BackgroundColor3 = C.Painel
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Menu

local sl = Instance.new("UIListLayout")
sl.Padding = UDim.new(0, 6)
sl.SortOrder = Enum.SortOrder.LayoutOrder
sl.Parent = Sidebar

local sp = Instance.new("UIPadding")
sp.PaddingTop = UDim.new(0, 12)
sp.PaddingLeft = UDim.new(0, 10)
sp.PaddingRight = UDim.new(0, 10)
sp.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -140, 1, -64)
Content.Position = UDim2.new(0, 135, 0, 57)
Content.BackgroundTransparency = 1
Content.Parent = Menu

local Pages = {}
local Tabs = {}
local CurrentTab = nil

local function MostrarAba(nome)
    for tn, pg in pairs(Pages) do
        pg.Visible = (tn == nome)
    end
    for tn, btn in pairs(Tabs) do
        if tn == nome then
            btn.BackgroundColor3 = C.Roxo
            btn.TextColor3 = C.Texto
        else
            btn.BackgroundColor3 = C.Card
            btn.TextColor3 = C.SubTexto
        end
    end
    CurrentTab = nome
end

local function CriarAba(nome)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = C.Card
    btn.Text = "  " .. nome
    btn.TextColor3 = C.SubTexto
    btn.Font = Enum.Font.GothamSemibold
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
    page.Parent = Content

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page

    Pages[nome] = page
    Tabs[nome] = btn

    btn.MouseButton1Click:Connect(function()
        MostrarAba(nome)
    end)
end

CriarAba("Chat IA")
CriarAba("Funções")

-- ==================================================
-- CHAT IA
-- ==================================================

local ChatPage = Pages["Chat IA"]

local Historico = Instance.new("ScrollingFrame")
Historico.Size = UDim2.new(1, 0, 1, -60)
Historico.BackgroundTransparency = 1
Historico.BorderSizePixel = 0
Historico.ScrollBarThickness = 3
Historico.ScrollBarImageColor3 = C.Roxo
Historico.CanvasSize = UDim2.new(0, 0, 0, 0)
Historico.AutomaticCanvasSize = Enum.AutomaticSize.Y
Historico.Parent = ChatPage

local HistList = Instance.new("UIListLayout")
HistList.Padding = UDim.new(0, 6)
HistList.SortOrder = Enum.SortOrder.LayoutOrder
HistList.Parent = Historico

local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -80, 0, 40)
InputBox.Position = UDim2.new(0, 0, 1, -45)
InputBox.BackgroundColor3 = C.Card
InputBox.PlaceholderText = "Pergunte qualquer coisa..."
InputBox.Text = ""
InputBox.TextColor3 = C.Texto
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 12
InputBox.BorderSizePixel = 0
InputBox.ClearTextOnFocus = false
InputBox.Parent = ChatPage

local ic = Instance.new("UICorner")
ic.CornerRadius = UDim.new(0, 8)
ic.Parent = InputBox

local Enviar = Instance.new("TextButton")
Enviar.Size = UDim2.new(0, 70, 0, 40)
Enviar.Position = UDim2.new(1, -70, 1, -45)
Enviar.BackgroundColor3 = C.Roxo
Enviar.Text = "Enviar"
Enviar.TextColor3 = C.Texto
Enviar.Font = Enum.Font.GothamBold
Enviar.TextSize = 12
Enviar.BorderSizePixel = 0
Enviar.Parent = ChatPage

local ec = Instance.new("UICorner")
ec.CornerRadius = UDim.new(0, 8)
ec.Parent = Enviar

local function AdicionarMensagem(texto, ehIA)
    local msg = Instance.new("Frame")
    msg.Size = UDim2.new(1, 0, 0, 0)
    msg.AutomaticSize = Enum.AutomaticSize.Y
    msg.BackgroundColor3 = ehIA and C.Card or C.Roxo
    msg.BorderSizePixel = 0
    msg.Parent = Historico

    local mcc = Instance.new("UICorner")
    mcc.CornerRadius = UDim.new(0, 8)
    mcc.Parent = msg

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = msg

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = (ehIA and "AXION: " or "Você: ") .. texto
    label.TextColor3 = C.Texto
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = msg

    task.wait(0.1)
    Historico.CanvasPosition = Vector2.new(0, Historico.AbsoluteCanvasSize.Y)
end

local function EnviarMensagem()
    local texto = InputBox.Text
    if texto == "" then return end

    AdicionarMensagem(texto, false)
    InputBox.Text = ""

    AdicionarMensagem("Pensando...", true)

    task.spawn(function()
        local resposta = PerguntarIA(texto)

        local ultima = Historico:GetChildren()[#Historico:GetChildren()]
        if ultima and ultima:IsA("Frame") then
            ultima:Destroy()
        end

        AdicionarMensagem(resposta, true)
    end)
end

Enviar.MouseButton1Click:Connect(EnviarMensagem)

InputBox.FocusLost:Connect(function(enter)
    if enter then
        EnviarMensagem()
    end
end)

task.spawn(function()
    task.wait(0.5)
    AdicionarMensagem("E aí, mano! Sou o AXION, sua IA. Pergunta qualquer coisa sobre MM2 ou o que quiser.", true)
end)

-- ==================================================
-- FUNÇÕES (ESP, Auto Shoot, etc)
-- ==================================================

local FuncoesPage = Pages["Funções"]

local Config = {
    MurdererESP = true,
    SheriffESP = true,
    InnocentESP = false,
    AutoShoot = false,
    Freeze = false,
    Noclip = false,
    Speed = false,
    Fullbright = false,
    AntiAFK = true,
}

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

local function CriarToggle(parent, texto, key)
    local Card = Instance.new("TextButton")
    Card.Size = UDim2.new(1, 0, 0, 44)
    Card.BackgroundColor3 = C.Card
    Card.Text = ""
    Card.AutoButtonColor = false
    Card.BorderSizePixel = 0
    Card.Parent = parent

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 8)
    cc.Parent = Card

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.Borda
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = Card

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = texto
    Label.TextColor3 = C.Texto
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Card

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 40, 0, 22)
    Switch.Position = UDim2.new(1, -55, 0.5, -11)
    Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    Switch.BorderSizePixel = 0
    Switch.Parent = Card

    local swc = Instance.new("UICorner")
    swc.CornerRadius = UDim.new(1, 0)
    swc.Parent = Switch

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 16, 0, 16)
    Dot.Position = UDim2.new(0, 3, 0.5, -8)
    Dot.BackgroundColor3 = C.Texto
    Dot.BorderSizePixel = 0
    Dot.Parent = Switch

    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = Dot

    local function Atualizar()
        if Config[key] then
            Switch.BackgroundColor3 = C.Roxo
            Dot.Position = UDim2.new(1, -19, 0.5, -8)
            stroke.Color = C.Roxo
            stroke.Transparency = 0.2
        else
            Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
            Dot.Position = UDim2.new(0, 3, 0.5, -8)
            stroke.Color = C.Borda
            stroke.Transparency = 0.5
        end
    end

    Card.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        Atualizar()
    end)

    Atualizar()
end

CriarToggle(FuncoesPage, "ESP Assassino", "MurdererESP")
CriarToggle(FuncoesPage, "ESP Xerife", "SheriffESP")
CriarToggle(FuncoesPage, "ESP Inocente", "InnocentESP")
CriarToggle(FuncoesPage, "Auto Shoot", "AutoShoot")
CriarToggle(FuncoesPage, "Freeze Assassino", "Freeze")
CriarToggle(FuncoesPage, "Noclip", "Noclip")
CriarToggle(FuncoesPage, "Speed Boost", "Speed")
CriarToggle(FuncoesPage, "Fullbright", "Fullbright")
CriarToggle(FuncoesPage, "Anti-AFK", "AntiAFK")

-- ==================================================
-- LÓGICA DAS FUNÇÕES
-- ==================================================

local espCache = {}
local nomeCache = {}

local function CriarESP(player)
    if not player.Character then return end
    if espCache[player] and espCache[player].Parent then return end

    local h = Instance.new("Highlight")
    h.Name = "AXION_ESP"
    h.Adornee = player.Character
    h.FillTransparency = 0.6
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
        cor = C.Vermelho
    elseif role == "Sheriff" then
        ativo = Config.SheriffESP
        cor = C.Ciano
    else
        ativo = Config.InnocentESP
        cor = C.Verde
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

local function Fullbright()
    if Config.Fullbright then
        game.Lighting.Brightness = 3
        game.Lighting.ClockTime = 14
        game.Lighting.FogEnd = 100000
        game.Lighting.GlobalShadows = false
    end
end

task.spawn(function()
    while task.wait(60) do
        if Config.AntiAFK then
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end
    end
end)

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
    pcall(Fullbright)
end)

MostrarAba("Chat IA")

print("AXION AI v2 carregado!")
