--[[
    ═══════════════════════════════════════════════════════
    MM2 Hub - Menu com Rayfield UI
    Funções: Shoot Murderer, Auto-Shoot, Aim-Bot, Knife Throw,
             ESP, Fling, Auto-Collect, Round Timer
    ═══════════════════════════════════════════════════════
    
    ⚠️  AVISO: Use por sua conta e risco. Viola ToS do Roblox.
--]]

-- ═══════════ CARREGAR LIBRARY ═══════════
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ═══════════ SERVIÇOS ═══════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ═══════════ CONFIGURAÇÕES ═══════════
local Config = {
    ShootOffset = 2.8,
    OffsetToPingMult = 1,
    AutoShootDelay = 0.15,
    AimSmoothness = 0.2,
    KnifeThrowDelay = 1.5,
    HideMyESP = false,
}

-- ═══════════ ESTADO ═══════════
local State = {
    AutoShoot = false,
    AimBot = false,
    KnifeLoop = false,
    PlayerESP = false,
    GunDropESP = false,
    TrapESP = false,
    RoundTimer = false,
    FlingMode = false,
}

local playerData = {}
local Connections = {}
local ESPObjects = {}

-- ═══════════ UTILITÁRIOS ═══════════

local function notify(title, text, duration)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = duration or 5,
    })
end

local function safeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[MM2 Hub] " .. tostring(err)) end
    return ok
end

-- ═══════════ DETECÇÃO DE ROLES ═══════════

local function findMurderer()
    -- Backpack
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Backpack:FindFirstChild("Knife") then return p end
    end
    -- Character
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Knife") then return p end
    end
    -- PlayerData (servidor)
    if playerData then
        for name, data in pairs(playerData) do
            if data.Role == "Murderer" then
                local plr = Players:FindFirstChild(name)
                if plr then return plr end
            end
        end
    end
    return nil
end

local function findSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Backpack:FindFirstChild("Gun") then return p end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("Gun") then return p end
    end
    if playerData then
        for name, data in pairs(playerData) do
            if data.Role == "Sheriff" then
                local plr = Players:FindFirstChild(name)
                if plr then return plr end
            end
        end
    end
    return nil
end

local function findSheriffNotMe()
    local s = findSheriff()
    if s and s ~= LocalPlayer then return s end
    return nil
end

-- ═══════════ PREDIÇÃO DE POSIÇÃO ═══════════

local function getPredictedPosition(player, offset)
    if not player or not player.Character then return nil end
    local char = player.Character
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not torso or not hum then return nil end

    local velocity = torso.AssemblyLinearVelocity
    local moveDir = hum.MoveDirection

    local predicted = torso.Position
        + (velocity * Vector3.new(0.75, 0.5, 0.75)) * (offset / 15)
        + moveDir * offset

    -- Ajuste por ping
    local ping = LocalPlayer:GetNetworkPing() * 1000
    local mult = (ping * ((Config.OffsetToPingMult - 1) * 0.01)) + 1
    predicted = predicted * mult

    return predicted
end

-- ═══════════ SHOOT MURDERER ═══════════

local function shootMurderer(silent)
    if findSheriff() ~= LocalPlayer then
        if not silent then notify("❌ Erro", "Você não é o Sheriff/Hero!", 3) end
        return false
    end

    local murderer = findMurderer()
    if not murderer then
        if not silent then notify("❌ Erro", "Murderer não encontrado!", 3) end
        return false
    end

    local char = LocalPlayer.Character
    if not char then return false end

    -- Equipar arma
    if not char:FindFirstChild("Gun") then
        local gun = LocalPlayer.Backpack:FindFirstChild("Gun")
        if gun then
            char:FindFirstChildOfClass("Humanoid"):EquipTool(gun)
            task.wait(0.1)
        else
            if not silent then notify("❌ Erro", "Você não tem a arma!", 3) end
            return false
        end
    end

    -- Prever posição
    local predicted = getPredictedPosition(murderer, Config.ShootOffset)
    if not predicted then return false end

    -- Disparar
    local gun = char:FindFirstChild("Gun")
    if gun and gun:FindFirstChild("Shoot") then
        safeCall(function()
            gun.Shoot:FireServer(
                CFrame.new(char.RightHand.Position),
                CFrame.new(predicted)
            )
        end)
        if not silent then
            notify("🔫 Tiro!", "Atirou em " .. murderer.Name, 2)
        end
        return true
    end
    return false
end

-- ═══════════ AIM-BOT (mira suave) ═══════════

local aimbotConnection = nil

local function startAimBot()
    if aimbotConnection then aimbotConnection:Disconnect() end
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not State.AimBot then return end
        local murderer = findMurderer() or findSheriffNotMe()
        if not murderer or not murderer.Character then return end
        
        local hrp = murderer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local targetPos = hrp.Position + Vector3.new(0, 1, 0)
        local camPos = Camera.CFrame.Position
        local newCFrame = CFrame.new(camPos, targetPos)
        
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, Config.AimSmoothness)
    end)
end

local function stopAimBot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

-- ═══════════ AUTO-SHOOT ═══════════

local autoShootTask = nil

local function startAutoShoot()
    if autoShootTask then task.cancel(autoShootTask) end
    autoShootTask = task.spawn(function()
        while State.AutoShoot do
            task.wait(Config.AutoShootDelay)
            if findSheriff() == LocalPlayer then
                safeCall(shootMurderer, true)
            end
        end
    end)
end

-- ═══════════ KNIFE THROW ═══════════

local function findNearestPlayer()
    local nearest, shortestDist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (myPos - hrp.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    nearest = p
                end
            end
        end
    end
    return nearest
end

local function knifeThrow(silent)
    if findMurderer() ~= LocalPlayer then
        if not silent then notify("❌ Erro", "Você não é o Murderer!", 3) end
        return false
    end

    local char = LocalPlayer.Character
    if not char then return false end

    -- Equipar faca
    if not char:FindFirstChild("Knife") then
        local knife = LocalPlayer.Backpack:FindFirstChild("Knife")
        if knife then
            char:FindFirstChildOfClass("Humanoid"):EquipTool(knife)
            task.wait(0.1)
        else
            if not silent then notify("❌ Erro", "Você não tem a faca!", 3) end
            return false
        end
    end

    local target = findNearestPlayer()
    if not target or not target.Character then
        if not silent then notify("❌ Erro", "Nenhum jogador próximo!", 3) end
        return false
    end

    local predicted = getPredictedPosition(target, Config.ShootOffset + 1)
    if not predicted then return false end

    local knife = char:FindFirstChild("Knife")
    if knife and knife:FindFirstChild("Events") then
        safeCall(function()
            knife.Events.KnifeThrown:FireServer(
                CFrame.new(char.RightHand.Position),
                CFrame.new(predicted)
            )
        end)
        if not silent then
            notify("🔪 Faca!", "Arremessou em " .. target.Name, 2)
        end
        return true
    end
    return false
end

-- ═══════════ ESP ═══════════

local function clearESP()
    for _, obj in pairs(ESPObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    ESPObjects = {}
end

local function addHighlight(character, color, labelText)
    if not character then return end
    local existing = character:FindFirstChild("MM2_ESP")
    if existing then existing:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Name = "MM2_ESP"
    hl.Adornee = character
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = game:GetService("CoreGui")
    table.insert(ESPObjects, hl)

    -- Billboard com nome
    if labelText then
        local head = character:FindFirstChild("Head")
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "MM2_Label"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = game:GetService("CoreGui")
            table.insert(ESPObjects, billboard)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = labelText
            label.TextColor3 = color
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.GothamBold
            label.TextScaled = true
            label.Parent = billboard
        end
    end
end

local function refreshPlayerESP()
    clearESP()
    if not State.PlayerESP then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer and Config.HideMyESP then continue end
        if not p.Character then continue end

        local color, label
        if p == findMurderer() then
            color = Color3.fromRGB(255, 0, 0)
            label = "🔪 MURDERER"
        elseif p == findSheriff() then
            color = Color3.fromRGB(0, 150, 255)
            label = "🔫 SHERIFF"
        else
            color = Color3.fromRGB(0, 255, 0)
            label = nil
        end

        addHighlight(p.Character, color, label)
    end
end

local function refreshGunESP()
    if not State.GunDropESP then return end
    -- Achar o mapa atual
    local map
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:FindFirstChild("CoinContainer") and obj:FindFirstChild("Spawns") then
            map = obj
            break
        end
    end
    if not map then return end
    local gunDrop = map:FindFirstChild("GunDrop")
    if gunDrop then
        addHighlight(gunDrop, Color3.fromRGB(255, 255, 0), "🔫 ARMA!")
    end
end

-- ═══════════ FLING ═══════════

local function flingPlayer(target)
    if not target or not target.Character then
        notify("❌ Erro", "Alvo inválido!", 3)
        return
    end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local tChar = target.Character
    local tHRP = tChar:FindFirstChild("HumanoidRootPart")
        or tChar:FindFirstChild("UpperTorso")
        or tChar:FindFirstChild("Torso")
    if not tHRP then
        notify("❌ Erro", "Não achei o corpo do alvo!", 3)
        return
    end

    notify("🌀 Fling", "Arremessando " .. target.Name .. "...", 3)

    -- Salva posição
    local myHRP = char.HumanoidRootPart
    local oldPos = myHRP.CFrame

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end

    for i = 1, 25 do
        if not target.Character or not tHRP.Parent then break end
        myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 1) * CFrame.Angles(math.rad(i * 90), 0, 0)
        myHRP.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        myHRP.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        task.wait()
    end

    -- Reset
    task.wait(0.5)
    if char and myHRP and myHRP.Parent then
        myHRP.Velocity = Vector3.zero
        myHRP.RotVelocity = Vector3.zero
        myHRP.CFrame = oldPos
    end
end

-- ═══════════ ROUND TIMER ═══════════

local timerLabel = nil
local timerConn = nil

local function secondsToMinutes(s)
    if not s or s < 0 then return "0:00" end
    return string.format("%d:%02d", math.floor(s / 60), s % 60)
end

local function startTimer()
    if timerLabel then timerLabel:Destroy() end
    timerLabel = Instance.new("TextLabel")
    timerLabel.Size = UDim2.new(0, 200, 0, 40)
    timerLabel.Position = UDim2.new(0.5, -100, 0.1, 0)
    timerLabel.BackgroundTransparency = 1
    timerLabel.TextColor3 = Color3.new(1, 1, 1)
    timerLabel.TextStrokeTransparency = 0
    timerLabel.Font = Enum.Font.GothamBold
    timerLabel.TextScaled = true
    timerLabel.Text = "--:--"
    timerLabel.Parent = game:GetService("CoreGui")

    timerConn = RunService.Heartbeat:Connect(function()
        local timerPart = workspace:FindFirstChild("RoundTimerPart")
        if timerPart then
            local t = timerPart:GetAttribute("Time")
            if t then timerLabel.Text = secondsToMinutes(t) end
        end
    end)
end

local function stopTimer()
    if timerConn then timerConn:Disconnect() timerConn = nil end
    if timerLabel then timerLabel:Destroy() timerLabel = nil end
end

-- ═══════════ WINDOW ═══════════

local Window = Rayfield:CreateWindow({
    Name = "🔪 MM2 Hub | Rayfield",
    LoadingTitle = "Carregando MM2 Hub...",
    LoadingSubtitle = "por seu amigo dev",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MM2Hub",
        FileName = "config"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- ═══════════ TABS ═══════════

local MainTab = Window:CreateTab("🎯 Principal", 4483362458)
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
local FunTab = Window:CreateTab("🎮 Diversão", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Config", 4483362458)

-- ═══════════ MAIN TAB ═══════════

MainTab:CreateSection("🔫 Sheriff / Hero")

MainTab:CreateButton({
    Name = "Disparar no Murderer",
    Description = "Atira uma vez no murderer com predição",
    Callback = function()
        shootMurderer()
    end,
})

MainTab:CreateToggle({
    Name = "Auto-Shoot (Automático)",
    CurrentValue = false,
    Flag = "AutoShootToggle",
    Description = "Atira sem parar quando você é o Sheriff",
    Callback = function(value)
        State.AutoShoot = value
        if value then
            notify("🔫 Auto-Shoot", "Ativado! Cuidado com o anti-cheat.", 4)
            startAutoShoot()
        else
            notify("🔫 Auto-Shoot", "Desativado.", 3)
        end
    end,
})

MainTab:CreateToggle({
    Name = "Aim-Bot (Mira automática)",
    CurrentValue = false,
    Flag = "AimBotToggle",
    Description = "Trava a câmera no murderer",
    Callback = function(value)
        State.AimBot = value
        if value then startAimBot() else stopAimBot() end
    end,
})

MainTab:CreateSlider({
    Name = "Velocidade da mira",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "smooth",
    CurrentValue = 0.2,
    Flag = "AimSmoothSlider",
    Callback = function(value)
        Config.AimSmoothness = value
    end,
})

MainTab:CreateSection("🔪 Murderer")

MainTab:CreateButton({
    Name = "Arremessar Faca (mais próximo)",
    Description = "Arremessa a faca no jogador mais perto",
    Callback = function()
        knifeThrow()
    end,
})

MainTab:CreateToggle({
    Name = "Loop Knife Throw",
    CurrentValue = false,
    Flag = "KnifeLoopToggle",
    Description = "Arremessa faca automaticamente a cada 1.5s",
    Callback = function(value)
        State.KnifeLoop = value
        if value then
            task.spawn(function()
                while State.KnifeLoop do
                    task.wait(Config.KnifeThrowDelay)
                    safeCall(knifeThrow, true)
                end
            end)
        end
    end,
})

MainTab:CreateSection("💀 Fling")

MainTab:CreateButton({
    Name = "Fling Sheriff",
    Description = "Arremessa o Sheriff",
    Callback = function()
        local s = findSheriff()
        if not s then notify("❌", "Sem sheriff!", 3) return end
        flingPlayer(s)
    end,
})

MainTab:CreateButton({
    Name = "Fling Murderer",
    Description = "Arremessa o Murderer",
    Callback = function()
        local m = findMurderer()
        if not m then notify("❌", "Sem murderer!", 3) return end
        flingPlayer(m)
    end,
})

-- ═══════════ ESP TAB ═══════════

ESPTab:CreateSection("👥 Jogadores")

ESPTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESPToggle",
    Description = "Mostra todos com cores: Vermelho=Murderer, Azul=Sheriff, Verde=Inocente",
    Callback = function(value)
        State.PlayerESP = value
        refreshPlayerESP()
    end,
})

ESPTab:CreateToggle({
    Name = "Esconder meu próprio ESP",
    CurrentValue = false,
    Flag = "HideMyESP",
    Callback = function(value)
        Config.HideMyESP = value
        refreshPlayerESP()
    end,
})

ESPTab:CreateSection("🎁 Objetos")

ESPTab:CreateToggle({
    Name = "Gun Drop ESP",
    CurrentValue = false,
    Flag = "GunDropESPToggle",
    Description = "Destaca a arma no chão em amarelo",
    Callback = function(value)
        State.GunDropESP = value
        if value then refreshGunESP() end
    end,
})

ESPTab:CreateButton({
    Name = "Recarregar ESP",
    Callback = function()
        refreshPlayerESP()
        refreshGunESP()
    end,
})

ESPTab:CreateSection("⏱️ Timer")

ESPTab:CreateToggle({
    Name = "Round Timer",
    CurrentValue = false,
    Flag = "RoundTimerToggle",
    Description = "Mostra quanto tempo falta pra rodada acabar",
    Callback = function(value)
        State.RoundTimer = value
        if value then startTimer() else stopTimer() end
    end,
})

-- ═══════════ FUN TAB ═══════════

FunTab:CreateSection("📋 Info")

FunTab:CreateButton({
    Name = "Copiar nome do Murderer",
    Callback = function()
        local m = findMurderer()
        if m then
            setclipboard(m.Name)
            notify("📋", "Copiado: " .. m.Name, 3)
        else
            notify("❌", "Sem murderer ainda.", 3)
        end
    end,
})

FunTab:CreateButton({
    Name = "Copiar nome do Sheriff",
    Callback = function()
        local s = findSheriff()
        if s then
            setclipboard(s.Name)
            notify("📋", "Copiado: " .. s.Name, 3)
        else
            notify("❌", "Sem sheriff ainda.", 3)
        end
    end,
})

FunTab:CreateSection("🏃 Teleporte")

FunTab:CreateButton({
    Name = "Teleportar para o Lobby",
    Callback = function()
        local lobby = workspace:FindFirstChild("Lobby")
        if lobby and LocalPlayer.Character then
            local sp = lobby:FindFirstChild("Spawns") and lobby.Spawns:FindFirstChildWhichIsA("SpawnLocation")
            if sp then LocalPlayer.Character:MoveTo(sp.Position) end
        end
    end,
})

FunTab:CreateButton({
    Name = "Teleportar para o Mapa",
    Callback = function()
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:FindFirstChild("CoinContainer") and obj:FindFirstChild("Spawns") then
                local spawns = obj.Spawns:GetChildren()
                if #spawns > 0 and LocalPlayer.Character then
                    LocalPlayer.Character:MoveTo(spawns[math.random(1, #spawns)].Position)
                end
                return
            end
        end
        notify("❌", "Mapa não encontrado.", 3)
    end,
})

FunTab:CreateSection("🎯 Instakill")

FunTab:CreateButton({
    Name = "Kill Everyone (Murderer)",
    Description = "Ancora todos e mata de uma vez",
    Callback = function()
        if findMurderer() ~= LocalPlayer then
            notify("❌", "Você não é o murderer!", 3)
            return
        end
        local char = LocalPlayer.Character
        if not char then return end
        if not char:FindFirstChild("Knife") then
            local k = LocalPlayer.Backpack:FindFirstChild("Knife")
            if k then char:FindFirstChildOfClass("Humanoid"):EquipTool(k) end
            task.wait(0.2)
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Anchored = true
                    hrp.CFrame = char.HumanoidRootPart.CFrame + char.HumanoidRootPart.CFrame.LookVector * 2
                end
            end
        end
        task.wait(0.3)
        char.Knife.Stab:FireServer("Slash")
        notify("💀", "Kill everyone disparado!", 3)
    end,
})

-- ═══════════ SETTINGS TAB ═══════════

SettingsTab:CreateSection("⚙️ Predição")

SettingsTab:CreateSlider({
    Name = "Shoot Offset",
    Range = {0, 6},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 2.8,
    Flag = "ShootOffsetSlider",
    Description = "Aumenta se estiver errando atrás",
    Callback = function(value)
        Config.ShootOffset = value
    end,
})

SettingsTab:CreateSlider({
    Name = "Offset-to-Ping Multiplier",
    Range = {0.5, 3},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "PingMultSlider",
    Description = "Compensa ping alto. Deixe em 1 se ping for baixo.",
    Callback = function(value)
        Config.OffsetToPingMult = value
    end,
})

SettingsTab:CreateSection("🔧 Outros")

SettingsTab:CreateButton({
    Name = "Anti-AFK",
    Description = "Impede o kick por inatividade",
    Callback = function()
        if getconnections then
            for _, c in pairs(getconnections(LocalPlayer.Idled)) do
                pcall(function() c:Disable() end)
            end
        else
            LocalPlayer.Idled:Connect(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton2(Vector2.new())
            end)
        end
        notify("✅", "Anti-AFK ativado!", 3)
    end,
})

SettingsTab:CreateButton({
    Name = "Limpar ESP",
    Callback = function()
        clearESP()
        notify("🧹", "ESP limpo.", 2)
    end,
})

SettingsTab:CreateButton({
    Name = "Descarregar Script",
    Callback = function()
        clearESP()
        stopTimer()
        stopAimBot()
        State.AutoShoot = false
        State.KnifeLoop = false
        for _, c in ipairs(Connections) do
            if c then c:Disconnect() end
        end
        Rayfield:Destroy()
        notify("👋", "Script descarregado.", 3)
    end,
})

-- ═══════════ EVENTOS ═══════════

-- Player data (roles)
safeCall(function()
    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 5)
    if remotes then
        local gameplay = remotes:WaitForChild("Gameplay", 5)
        if gameplay then
            local pdc = gameplay:WaitForChild("PlayerDataChanged", 5)
            if pdc then
                table.insert(Connections, pdc.OnClientEvent:Connect(function(data)
                    playerData = data
                    if State.PlayerESP then refreshPlayerESP() end
                end))
            end
        end
    end
end)

-- Auto-refresh ESP
table.insert(Connections, Players.PlayerAdded:Connect(function()
    task.wait(1)
    if State.PlayerESP then refreshPlayerESP() end
end))

table.insert(Connections, Players.PlayerRemoving:Connect(function()
    if State.PlayerESP then refreshPlayerESP() end
end))

-- Loop de refresh
task.spawn(function()
    while task.wait(3) do
        if State.PlayerESP then
            safeCall(refreshPlayerESP)
        end
        if State.GunDropESP then
            safeCall(refreshGunESP)
        end
    end
end)

-- Detectar nova rodada
safeCall(function()
    workspace.ChildAdded:Connect(function(obj)
        if obj:FindFirstChild("CoinContainer") and obj:FindFirstChild("Spawns") then
            -- Novo mapa
            task.wait(2)
            if State.PlayerESP then refreshPlayerESP() end
        end
    end)
    workspace.ChildRemoved:Connect(function(obj)
        if obj:FindFirstChild("CoinContainer") and obj:FindFirstChild("Spawns") then
            playerData = {}
            clearESP()
        end
    end)
end)

-- ═══════════ BOAS VINDAS ═══════════

notify("🔪 MM2 Hub", "Script carregado! Boa sorte.", 5)

-- Atalhos de teclado
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    -- F1 = shoot murderer
    if input.KeyCode == Enum.KeyCode.F1 then
        safeCall(shootMurderer)
    end
    -- F2 = knife throw
    if input.KeyCode == Enum.KeyCode.F2 then
        safeCall(knifeThrow)
    end
end)--[[
    ═══════════════════════════════════════════════════════
    MM2 Hub - PARTE 2 (Expansão)
    Novas funções: Silent Aim, Auto-Collect, Fullbright,
                   Walkspeed, JumpPower, Player Info, FOV,
                   Anti-Fling, No-Clip, Coins Farm
    ═══════════════════════════════════════════════════════
--]]

-- ═══════════ SERVIÇOS ADICIONAIS ═══════════
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ═══════════ ESTADO PARTE 2 ═══════════
local State2 = {
    SilentAim = false,
    AutoCollect = false,
    Fullbright = false,
    AntiFling = false,
    NoClip = false,
    Wallhack = false,
    TrapsESP = false,
}

local Config2 = {
    WalkSpeed = 16,
    JumpPower = 50,
    FOV = 70,
    SilentAimFOV = 150,
    CollectRadius = 30,
    FlySpeed = 50,
}

local Connections2 = {}
local originalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
}
local originalWalkSpeed = 16
local originalJumpPower = 50

-- ═══════════ UTILITÁRIOS PARTE 2 ═══════════

local function safeCall2(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[MM2 Hub P2] " .. tostring(err)) end
    return ok
end

local function getMap()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:FindFirstChild("CoinContainer") and obj:FindFirstChild("Spawns") then
            return obj
        end
    end
    return nil
end

local function distance(a, b)
    return (a - b).Magnitude
end

-- ═══════════ 1. SILENT AIM ═══════════

-- Silent Aim: redireciona o tiro SEM mover a câmera
-- Intercepta o __namecall (FireServer) do Shoot

local silentAimConnection = nil

local function startSilentAim()
    if silentAimConnection then return end

    -- Verificar se o executor suporta hookmetamethod
    if not hookmetamethod or not getnamecallmethod then
        notify("❌", "Seu executor não suporta Silent Aim!", 5)
        return
    end

    local oldNameCall
    oldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if State2.SilentAim 
           and method == "FireServer" 
           and self.Name == "Shoot" 
           and self.Parent 
           and self.Parent.Name == "Gun" then

            -- Achar murderer dentro do FOV
            local murderer = findMurderer()
            if murderer and murderer.Character then
                local hrp = murderer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local myChar = LocalPlayer.Character
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        -- Achar a posição prevista
                        local predicted = getPredictedPosition(murderer, Config.ShootOffset)
                        if predicted then
                            -- Substituir o segundo argumento (CFrame alvo)
                            if #args >= 2 then
                                args[2] = CFrame.new(predicted)
                            end
                            return oldNameCall(self, unpack(args))
                        end
                    end
                end
            end
        end

        return oldNameCall(self, ...)
    end)
    silentAimConnection = true
end

local function stopSilentAim()
    silentAimConnection = nil
    -- O hook fica permanentemente, mas checa State2.SilentAim
end

-- ═══════════ 2. AUTO-COLLECT COINS ═══════════

local autoCollectTask = nil

local function getNearestCoin()
    local map = getMap()
    if not map then return nil end
    local container = map:FindFirstChild("CoinContainer")
    if not container then return nil end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    local nearest, dist = nil, Config2.CollectRadius + 1
    for _, coin in ipairs(container:GetChildren()) do
        if coin:IsA("BasePart") then
            local d = distance(myPos, coin.Position)
            if d < dist then
                dist = d
                nearest = coin
            end
        end
    end
    return nearest
end

local function collectCoin(coin)
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local hrp = myChar:FindFirstChild("HumanoidRootPart")
    if not hrp or not coin.Parent then return end
    
    -- Tween rápido até a moeda
    local tween = TweenService:Create(hrp, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(coin.Position)
    })
    tween:Play()
    tween.Completed:Wait()
    
    -- Simular toque (touch interest)
    if firetouchinterest then
        pcall(function()
            firetouchinterest(hrp, coin, 0)
            task.wait()
            firetouchinterest(hrp, coin, 1)
        end)
    end
end

local function startAutoCollect()
    if autoCollectTask then task.cancel(autoCollectTask) end
    autoCollectTask = task.spawn(function()
        while State2.AutoCollect do
            task.wait(0.1)
            local coin = getNearestCoin()
            if coin then
                safeCall2(collectCoin, coin)
            end
        end
    end)
end

-- ═══════════ 3. FULLBRIGHT ═══════════

local function enableFullbright()
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    Lighting.Brightness = 2
    Lighting.ClockTime = 12
    Lighting.FogEnd = 1e9
    Lighting.GlobalShadows = false

    -- Desativar efeitos
    for _, v in ipairs(Lighting:GetDescendants()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect")
           or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect")
           or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
end

local function disableFullbright()
    Lighting.Ambient = originalLighting.Ambient
    Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    Lighting.Brightness = originalLighting.Brightness
    Lighting.ClockTime = originalLighting.ClockTime
    Lighting.FogEnd = originalLighting.FogEnd
    Lighting.GlobalShadows = true
end

-- ═══════════ 4. WALKSPEED & JUMPPOWER ═══════════

local function setWalkSpeed(speed)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = speed end
    end
    originalWalkSpeed = speed
end

local function setJumpPower(power)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = power
        end
    end
    originalJumpPower = power
end

-- Loop para manter velocidade
task.spawn(function()
    while task.wait(0.5) do
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if hum.WalkSpeed ~= Config2.WalkSpeed and Config2.WalkSpeed ~= 16 then
                    hum.WalkSpeed = Config2.WalkSpeed
                end
                if Config2.JumpPower ~= 50 then
                    hum.UseJumpPower = true
                    hum.JumpPower = Config2.JumpPower
                end
            end
        end
    end
end)

-- ═══════════ 5. FOV CHANGER ═══════════

local function setFOV(fov)
    Config2.FOV = fov
    if Camera then
        TweenService:Create(Camera, TweenInfo.new(0.5), {FieldOfView = fov}):Play()
    end
end

-- ═══════════ 6. ANTI-FLING ═══════════

local antiFlingTask = nil
local lastGoodPos = nil

local function startAntiFling()
    if antiFlingTask then task.cancel(antiFlingTask) end
    antiFlingTask = task.spawn(function()
        while State2.AntiFling do
            task.wait(0.05)
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local vel = hrp.AssemblyLinearVelocity
                    local rot = hrp.AssemblyAngularVelocity
                    if vel.Magnitude > 100 or rot.Magnitude > 100 then
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        if lastGoodPos then
                            hrp.CFrame = CFrame.new(lastGoodPos)
                        end
                    else
                        lastGoodPos = hrp.Position
                    end
                end
            end
        end
    end)
end

-- ═══════════ 7. NO-CLIP ═══════════

local noClipCon = nil

local function startNoClip()
    if noClipCon then noClipCon:Disconnect() end
    noClipCon = RunService.Stepped:Connect(function()
        if not State2.NoClip then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- ═══════════ 8. TRAPS ESP ═══════════

local trapObjects = {}

local function refreshTrapsESP()
    for _, obj in pairs(trapObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    trapObjects = {}

    if not State2.TrapsESP then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Trap" and (obj:IsA("Model") or obj:IsA("Folder")) then
            local mainPart = obj:FindFirstChildWhichIsA("BasePart") or (obj:IsA("BasePart") and obj)
            if mainPart then
                local hl = Instance.new("Highlight")
                hl.Adornee = mainPart
                hl.FillColor = Color3.fromRGB(255, 50, 0)
                hl.OutlineColor = Color3.fromRGB(255, 100, 0)
                hl.FillTransparency = 0.4
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = game:GetService("CoreGui")
                table.insert(trapObjects, hl)
            end
        end
    end
end

-- ═══════════ 9. PLAYER INFO PANEL ═══════════

local infoFrame = nil
local infoTask = nil

local function createPlayerInfoPanel()
    if infoFrame then infoFrame:Destroy() end

    infoFrame = Instance.new("Frame")
    infoFrame.Name = "MM2_InfoPanel"
    infoFrame.Size = UDim2.new(0, 250, 0, 180)
    infoFrame.Position = UDim2.new(0, 15, 0.5, -90)
    infoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    infoFrame.BackgroundTransparency = 0.15
    infoFrame.BorderSizePixel = 0
    infoFrame.Parent = game:GetService("CoreGui")

    local corner = Instance.new("UICorner", infoFrame)
    corner.CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", infoFrame)
    stroke.Color = Color3.fromRGB(255, 60, 60)
    stroke.Thickness = 1.5

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "📊 MM2 Info"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = infoFrame

    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -40)
    content.Position = UDim2.new(0, 10, 0, 35)
    content.BackgroundTransparency = 1
    content.Text = "Carregando..."
    content.TextColor3 = Color3.fromRGB(220, 220, 220)
    content.Font = Enum.Font.Gotham
    content.TextSize = 13
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.Parent = infoFrame

    -- Arrastável
    local dragging, dragStart, startPos
    infoFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = infoFrame.Position
        end
    end)
    infoFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            infoFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    infoTask = task.spawn(function()
        while infoFrame and infoFrame.Parent do
            task.wait(0.5)
            local murderer = findMurderer()
            local sheriff = findSheriff()
            local alive = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum.Health > 0 then alive = alive + 1 end
                end
            end

            local map = getMap()
            local coins = 0
            if map then
                local container = map:FindFirstChild("CoinContainer")
                if container then coins = #container:GetChildren() end
            end

            local txt = ""
            txt = txt .. "🔪 Murderer: " .. (murderer and murderer.Name or "???") .. "\n"
            txt = txt .. "🔫 Sheriff: " .. (sheriff and sheriff.Name or "???") .. "\n"
            txt = txt .. "👥 Vivos: " .. alive .. "/" .. #Players:GetPlayers() .. "\n"
            txt = txt .. "💰 Moedas no mapa: " .. coins .. "\n"
            txt = txt .. "📡 Ping: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms"

            infoFrame.Content.Text = txt
        end
    end)
end

local function destroyPlayerInfoPanel()
    if infoTask then task.cancel(infoTask) infoTask = nil end
    if infoFrame then infoFrame:Destroy() infoFrame = nil end
end

-- ═══════════ 10. SKIP ROUND (boss troll) ═══════════

-- Nota: não existe "skip round" real, mas podemos "forçar" situação
-- Aqui é só um exemplo de botão inofensivo

local function forceRoundEnd()
    notify("⏭️", "Não dá pra forçar fim de rodada em MM2 sem exploit pesado.", 4)
end

-- ═══════════ 11. GUN AUTO-PICKUP ═══════════

local autoPickupTask = nil

local function tryPickupGun()
    local map = getMap()
    if not map then return false end
    local gunDrop = map:FindFirstChild("GunDrop")
    if not gunDrop then return false end

    local myChar = LocalPlayer.Character
    if not myChar then return false end
    local hrp = myChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    -- Salvar posição
    local oldPos = hrp.CFrame

    -- Ir até a arma
    hrp.CFrame = CFrame.new(gunDrop.Position)
    task.wait(0.15)

    -- Voltar
    if hrp and hrp.Parent then
        hrp.CFrame = oldPos
    end
    return true
end

local function startAutoPickupGun()
    if autoPickupTask then task.cancel(autoPickupTask) end
    autoPickupTask = task.spawn(function()
        while State2.AutoPickupGun do
            task.wait(0.5)
            safeCall2(tryPickupGun)
        end
    end)
end

-- ═══════════ ADICIONAR NA UI (rayfield) ═══════════

-- Nova aba
local AdvancedTab = Window:CreateTab("⚡ Avançado", 4483362458)

-- ─── SEÇÃO: COMBATE ───
AdvancedTab:CreateSection("🎯 Combate Avançado")

AdvancedTab:CreateToggle({
    Name = "Silent Aim (Hook)",
    CurrentValue = false,
    Flag = "SilentAimToggle",
    Description = "Redireciona tiros pro murderer sem mover câmera",
    Callback = function(value)
        State2.SilentAim = value
        if value then
            startSilentAim()
            notify("🎯 Silent Aim", "Ativado! Requer executor com hookmetamethod.", 4)
        else
            notify("🎯 Silent Aim", "Desativado.", 3)
        end
    end,
})

-- ─── SEÇÃO: MOVIMENTO ───
AdvancedTab:CreateSection("🏃 Movimento")

AdvancedTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "spd",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(value)
        Config2.WalkSpeed = value
        setWalkSpeed(value)
    end,
})

AdvancedTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 5,
    Suffix = "pwr",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(value)
        Config2.JumpPower = value
        setJumpPower(value)
    end,
})

AdvancedTab:CreateToggle({
    Name = "No-Clip",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Description = "Atravessa paredes",
    Callback = function(value)
        State2.NoClip = value
        if value then startNoClip() end
    end,
})

AdvancedTab:CreateSlider({
    Name = "Camera FOV",
    Range = {70, 120},
    Increment = 5,
    Suffix = "fov",
    CurrentValue = 70,
    Flag = "FOVSlider",
    Callback = function(value)
        setFOV(value)
    end,
})

-- ─── SEÇÃO: VISUAL ───
AdvancedTab:CreateSection("🎨 Visual")

AdvancedTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "FullbrightToggle",
    Description = "Deixa o mapa claro, sem sombras",
    Callback = function(value)
        State2.Fullbright = value
        if value then enableFullbright() else disableFullbright() end
    end,
})

AdvancedTab:CreateToggle({
    Name = "Traps ESP",
    CurrentValue = false,
    Flag = "TrapsESPToggle",
    Description = "Destaca armadilhas do murderer em vermelho",
    Callback = function(value)
        State2.TrapsESP = value
        refreshTrapsESP()
    end,
})

AdvancedTab:CreateToggle({
    Name = "Player Info Panel",
    CurrentValue = false,
    Flag = "InfoPanelToggle",
    Description = "Painel no canto com roles, moedas, ping",
    Callback = function(value)
        if value then createPlayerInfoPanel() else destroyPlayerInfoPanel() end
    end,
})

-- ─── SEÇÃO: FARM ───
AdvancedTab:CreateSection("💰 Farm & Auto")

AdvancedTab:CreateToggle({
    Name = "Auto-Collect Coins",
    CurrentValue = false,
    Flag = "AutoCollectToggle",
    Description = "Vai atrás das moedas automaticamente",
    Callback = function(value)
        State2.AutoCollect = value
        if value then startAutoCollect() end
    end,
})

AdvancedTab:CreateSlider({
    Name = "Raio de coleta",
    Range = {5, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 30,
    Flag = "CollectRadiusSlider",
    Callback = function(value)
        Config2.CollectRadius = value
    end,
})

AdvancedTab:CreateToggle({
    Name = "Auto-Pickup Gun Drop",
    CurrentValue = false,
    Flag = "AutoPickupToggle",
    Description = "Pega a arma no chão automaticamente",
    Callback = function(value)
        State2.AutoPickupGun = value
        if value then startAutoPickupGun() end
    end,
})

-- ─── SEÇÃO: DEFESA ───
AdvancedTab:CreateSection("🛡️ Defesa")

AdvancedTab:CreateToggle({
    Name = "Anti-Fling",
    CurrentValue = false,
    Flag = "AntiFlingToggle",
    Description = "Neutraliza tentativa de fling contra você",
    Callback = function(value)
        State2.AntiFling = value
        if value then startAntiFling() end
    end,
})

AdvancedTab:CreateButton({
    Name = "Resetar Velocidade",
    Description = "Volta walkspeed e jump pra padrão",
    Callback = function()
        Config2.WalkSpeed = 16
        Config2.JumpPower = 50
        setWalkSpeed(16)
        setJumpPower(50)
        notify("🔄", "Velocidade resetada.", 2)
    end,
})

-- ═══════════ ATUALIZAR SETTINGS TAB ═══════════

SettingsTab:CreateSection("🧹 Limpeza")

SettingsTab:CreateButton({
    Name = "Limpar TUDO (ESP + Efeitos + Painéis)",
    Description = "Remove todos os efeitos visuais",
    Callback = function()
        clearESP()
        refreshTrapsESP()
        destroyPlayerInfoPanel()
        disableFullbright()
        setFOV(70)
        notify("🧹", "Tudo limpo.", 3)
    end,
})

-- ═══════════ HOTKEYS ADICIONAIS ═══════════

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    -- F3 = Silent Aim toggle
    if input.KeyCode == Enum.KeyCode.F3 then
        State2.SilentAim = not State2.SilentAim
        if State2.SilentAim then startSilentAim() end
        notify("🎯", "Silent Aim: " .. (State2.SilentAim and "ON" or "OFF"), 2)
    end
    -- F4 = Fullbright toggle
    if input.KeyCode == Enum.KeyCode.F4 then
        State2.Fullbright = not State2.Fullbright
        if State2.Fullbright then enableFullbright() else disableFullbright() end
        notify("💡", "Fullbright: " .. (State2.Fullbright and "ON" or "OFF"), 2)
    end
    -- F5 = Anti-fling toggle
    if input.KeyCode == Enum.KeyCode.F5 then
        State2.AntiFling = not State2.AntiFling
        if State2.AntiFling then startAntiFling() end
        notify("🛡️", "Anti-Fling: " .. (State2.AntiFling and "ON" or "OFF"), 2)
    end
end)

-- ═══════════ LIMPEZA FINAL ═══════════

-- Adicionar ao descarregamento (chamado no botão "Descarregar Script")
local oldUnload = function()
    State2.SilentAim = false
    State2.AutoCollect = false
    State2.Fullbright = false
    State2.AntiFling = false
    State2.NoClip = false
    State2.TrapsESP = false
    disableFullbright()
    destroyPlayerInfoPanel()
    refreshTrapsESP()
    setWalkSpeed(16)
    setJumpPower(50)
    setFOV(70)
end

-- ═══════════ NOTIFICAÇÃO ═══════════

notify("⚡ MM2 Hub - Parte 2", "Nova aba 'Avançado' desbloqueada!", 5)--[[
    ═══════════════════════════════════════════════════════
    MM2 Hub - PARTE 3 (Final)
    Funções: Server Hop, Chat Spammer, Auto-Puzzle, Role
             Revealer Visual, Sound Spam, Config Save/Load,
             Player Tracker, Coins Rain Alert, Anti-Trap,
             Auto-Grab Gun Melhorado, Server Stats
    ═══════════════════════════════════════════════════════
--]]

-- ═══════════ SERVIÇOS ═══════════
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextChatService = game:GetService("TextChatService")
local SoundService = game:GetService("SoundService")
local Stats = game:GetService("Stats")

local MM2_PLACE_ID = 142823291 -- Place ID do Murder Mystery 2

-- ═══════════ ESTADO PARTE 3 ═══════════
local State3 = {
    ChatSpammer = false,
    ServerHopAuto = false,
    AutoPuzzle = false,
    RoleRevealer = false,
    SoundSpam = false,
    AntiTrap = false,
    AutoGrabGun = false,
    ServerStats = false,
}

local Config3 = {
    SpamMessage = "YARHM on top! 🚀",
    SpamDelay = 3,
    AutoPuzzleDelay = 1,
    SoundVolume = 0.5,
    SoundId = "rbxassetid://1837879082", -- música padrão
}

local Connections3 = {}
local SpamTasks = {}
local VisualTags = {}

-- ═══════════ UTILS ═══════════

local function notify3(title, text, dur)
    Rayfield:Notify({ Title = title, Content = text, Duration = dur or 4 })
end

local function safeCall3(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[MM2 Hub P3] " .. tostring(err)) end
    return ok
end

local function getMap()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:FindFirstChild("CoinContainer") and obj:FindFirstChild("Spawns") then
            return obj
        end
    end
    return nil
end

-- ═══════════ 1. SERVER HOP ═══════════

local function serverHop()
    notify3("🌐 Server Hop", "Procurando servidor com poucos jogadores...", 4)

    task.spawn(function()
        local success = pcall(function()
            local url = string.format(
                "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
                MM2_PLACE_ID
            )
            local response = game:HttpGet(url)
            local data = HttpService:JSONDecode(response)

            local servers = {}
            local myJobId = game.JobId

            for _, server in ipairs(data.data) do
                if server.playing < server.maxPlayers 
                   and server.playing < 12
                   and server.id ~= myJobId then
                    table.insert(servers, server)
                end
            end

            if #servers == 0 then
                notify3("❌", "Nenhum servidor bom encontrado.", 3)
                return
            end

            -- Sortear um
            local chosen = servers[math.random(1, #servers)]
            notify3("🚀 Hop", string.format("Indo para servidor %d/%d", chosen.playing, chosen.maxPlayers), 3)
            task.wait(1)
            TeleportService:TeleportToPlaceInstance(MM2_PLACE_ID, chosen.id, LocalPlayer)
        end)

        if not success then
            notify3("❌ Erro", "Falha ao buscar servidores. Tente manualmente.", 3)
        end
    end)
end

local function hopUntilSmall(maxPlayers)
    maxPlayers = maxPlayers or 6
    State3.ServerHopAuto = true
    task.spawn(function()
        while State3.ServerHopAuto do
            if #Players:GetPlayers() <= maxPlayers then
                notify3("✅", "Servidor pequeno encontrado! (" .. #Players:GetPlayers() .. " jogadores)", 3)
                State3.ServerHopAuto = false
                break
            end
            serverHop()
            task.wait(15)
        end
    end)
end

-- ═══════════ 2. CHAT SPAMMER ═══════════

local function sendChatMessage(msg)
    pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            -- Novo sistema
            local channels = TextChatService:FindFirstChild("TextChannels")
            if channels then
                for _, channel in ipairs(channels:GetChildren()) do
                    if channel.Name == "RBXGeneral" then
                        channel:SendAsync(msg)
                        break
                    end
                end
            end
        else
            -- Legado
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                .SayMessageRequest:FireServer(msg, "All")
        end
    end)
end

local function startChatSpam()
    if SpamTasks.Chat then task.cancel(SpamTasks.Chat) end
    SpamTasks.Chat = task.spawn(function()
        while State3.ChatSpammer do
            safeCall3(sendChatMessage, Config3.SpamMessage)
            task.wait(Config3.SpamDelay)
        end
    end)
end

-- ═══════════ 3. AUTO-PUZZLE (resolve minigames) ═══════════

-- MM2 tem minigame de "coletar" pra virar sheriff
-- Aqui a gente tenta mandar o evento correto

local function trySolvePuzzle()
    local char = LocalPlayer.Character
    if not char then return end

    pcall(function()
        -- Procurar evento de puzzle
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local gameplay = remotes:FindFirstChild("Gameplay")
            if gameplay then
                local minigame = gameplay:FindFirstChild("MinigameResult")
                if minigame then
                    minigame:FireServer(true)
                end
            end
        end
    end)
end

-- ═══════════ 4. ROLE REVEALER VISUAL ═══════════

local function refreshRoleTags()
    -- Limpar antigos
    for _, tag in pairs(VisualTags) do
        if tag and tag.Parent then tag:Destroy() end
    end
    VisualTags = {}

    if not State3.RoleRevealer then return end

    local murderer = findMurderer()
    local sheriff = findSheriff()

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not p.Character then continue end
        local head = p.Character:FindFirstChild("Head")
        if not head then continue end

        local role, color
        if p == murderer then
            role = "🔪 MURDERER"
            color = Color3.fromRGB(255, 40, 40)
        elseif p == sheriff then
            role = "🔫 SHERIFF"
            color = Color3.fromRGB(50, 150, 255)
        else
            role = "😇 Inocente"
            color = Color3.fromRGB(80, 255, 80)
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MM2_RoleTag"
        billboard.Size = UDim2.new(0, 200, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 4, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.Parent = game:GetService("CoreGui")
        table.insert(VisualTags, billboard)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = role
        label.TextColor3 = color
        label.TextStrokeTransparency = 0
        label.Font = Enum.Font.GothamBlack
        label.TextScaled = true
        label.Parent = billboard
    end
end

-- ═══════════ 5. SOUND SPAM (client-side) ═══════════

local soundSpamObj = nil

local function startSoundSpam()
    if soundSpamObj then soundSpamObj:Destroy() end

    soundSpamObj = Instance.new("Sound")
    soundSpamObj.Name = "MM2_SoundSpam"
    soundSpamObj.SoundId = Config3.SoundId
    soundSpamObj.Volume = Config3.SoundVolume
    soundSpamObj.Looped = true
    soundSpamObj.Parent = SoundService

    soundSpamObj:Play()
    notify3("🔊 Sound", "Música tocando! (só você ouve)", 3)
end

local function stopSoundSpam()
    if soundSpamObj then
        soundSpamObj:Stop()
        soundSpamObj:Destroy()
        soundSpamObj = nil
    end
end

-- ═══════════ 6. ANTI-TRAP ═══════════

local antiTrapConn = nil
local lastSafePos = nil

local function startAntiTrap()
    if antiTrapConn then antiTrapConn:Disconnect() end
    antiTrapConn = RunService.Heartbeat:Connect(function()
        if not State3.AntiTrap then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Detectar trap por proximidade
        for _, trap in ipairs(workspace:GetDescendants()) do
            if trap.Name == "Trap" and trap:IsA("BasePart") then
                local dist = (hrp.Position - trap.Position).Magnitude
                if dist < 5 then
                    -- Voltar pra posição segura
                    if lastSafePos then
                        hrp.CFrame = CFrame.new(lastSafePos)
                        notify3("⚠️ Anti-Trap", "Armadilha detectada! Voltando...", 2)
                    end
                    return
                end
            end
        end

        lastSafePos = hrp.Position
    end)
end

-- ═══════════ 7. AUTO-GRAB GUN MELHORADO ═══════════

local gunGrabTask = nil

local function startAutoGrabGun()
    if gunGrabTask then task.cancel(gunGrabTask) end
    gunGrabTask = task.spawn(function()
        while State3.AutoGrabGun do
            task.wait(0.3)
            local map = getMap()
            if not map then continue end
            local gunDrop = map:FindFirstChild("GunDrop")
            if not gunDrop then continue end

            local myChar = LocalPlayer.Character
            if not myChar then continue end
            local hrp = myChar:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            -- Guardar posição
            local oldPos = hrp.CFrame

            -- Tentar pegar (método 1: teleporte direto)
            hrp.CFrame = CFrame.new(gunDrop.Position + Vector3.new(0, 2, 0))
            task.wait(0.15)

            -- Voltar
            if hrp and hrp.Parent then
                hrp.CFrame = oldPos
            end
        end
    end)
end

-- ═══════════ 8. SERVER STATS PANEL ═══════════

local statsFrame = nil
local statsTask = nil

local function createServerStats()
    if statsFrame then statsFrame:Destroy() end

    statsFrame = Instance.new("Frame")
    statsFrame.Name = "MM2_ServerStats"
    statsFrame.Size = UDim2.new(0, 220, 0, 200)
    statsFrame.Position = UDim2.new(1, -235, 0, 15)
    statsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    statsFrame.BackgroundTransparency = 0.15
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = game:GetService("CoreGui")

    Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", statsFrame)
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Thickness = 1.5

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.BackgroundTransparency = 1
    title.Text = "📡 Server Stats"
    title.TextColor3 = Color3.fromRGB(0, 220, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.Parent = statsFrame

    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -36)
    content.Position = UDim2.new(0, 10, 0, 32)
    content.BackgroundTransparency = 1
    content.Text = "..."
    content.TextColor3 = Color3.fromRGB(230, 230, 230)
    content.Font = Enum.Font.Code
    content.TextSize = 12
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.Parent = statsFrame

    -- Arrastável
    local drag, dragStart, startPos
    statsFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dragStart = inp.Position
            startPos = statsFrame.Position
        end
    end)
    statsFrame.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            statsFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)

    statsTask = task.spawn(function()
        while statsFrame and statsFrame.Parent do
            task.wait(1)
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            local fps = math.floor(1 / RunService.RenderStepped:Wait() * 60) -- fallback

            -- FPS melhor
            local frames = 0
            local start = tick()
            local conn
            conn = RunService.RenderStepped:Connect(function()
                frames = frames + 1
            end)
            task.wait(0.5)
            conn:Disconnect()
            fps = math.floor(frames / (tick() - start))

            local mem = math.floor(Stats:GetTotalMemoryUsageMb())
            local players = #Players:GetPlayers()

            local map = getMap()
            local coins = 0
            if map then
                local c = map:FindFirstChild("CoinContainer")
                if c then coins = #c:GetChildren() end
            end

            local txt = ""
            txt = txt .. "🌐 Job ID: " .. string.sub(game.JobId, 1, 8) .. "...\n"
            txt = txt .. "👥 Players: " .. players .. "\n"
            txt = txt .. "📡 Ping: " .. ping .. "ms\n"
            txt = txt .. "🎞️  FPS: " .. fps .. "\n"
            txt = txt .. "💾 Mem: " .. mem .. "MB\n"
            txt = txt .. "💰 Coins: " .. coins .. "\n"
            txt = txt .. "⏱️  Uptime: " .. math.floor(tick() - (game.Loaded and select(2, pcall(function() return game.Loaded end)) or tick())) .. "s"

            statsFrame.Content.Text = txt
        end
    end)
end

local function destroyServerStats()
    if statsTask then task.cancel(statsTask) statsTask = nil end
    if statsFrame then statsFrame:Destroy() statsFrame = nil end
end

-- ═══════════ 9. CONFIG SAVE/LOAD ═══════════

local CONFIG_FILE = "MM2Hub_Config.json"

local function saveConfig()
    local data = {
        WalkSpeed = Config2.WalkSpeed,
        JumpPower = Config2.JumpPower,
        FOV = Config2.FOV,
        ShootOffset = Config.ShootOffset,
        PingMult = Config.OffsetToPingMult,
        CollectRadius = Config2.CollectRadius,
        SpamMessage = Config3.SpamMessage,
        SpamDelay = Config3.SpamDelay,
        SoundId = Config3.SoundId,
        SoundVolume = Config3.SoundVolume,
    }

    local ok = pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(data))
        else
            -- Fallback
            getgenv().MM2Hub_Config = data
        end
    end)

    if ok then
        notify3("💾 Save", "Configuração salva!", 3)
    else
        notify3("❌", "Falha ao salvar (executor sem writefile)", 3)
    end
end

local function loadConfig()
    local data
    local ok = pcall(function()
        if readfile and isfile and isfile(CONFIG_FILE) then
            data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        elseif getgenv().MM2Hub_Config then
            data = getgenv().MM2Hub_Config
        end
    end)

    if not ok or not data then
        notify3("❌", "Nenhuma config salva encontrada.", 3)
        return
    end

    Config2.WalkSpeed = data.WalkSpeed or 16
    Config2.JumpPower = data.JumpPower or 50
    Config2.FOV = data.FOV or 70
    Config.ShootOffset = data.ShootOffset or 2.8
    Config.OffsetToPingMult = data.PingMult or 1
    Config2.CollectRadius = data.CollectRadius or 30
    Config3.SpamMessage = data.SpamMessage or "YARHM on top! 🚀"
    Config3.SpamDelay = data.SpamDelay or 3
    Config3.SoundId = data.SoundId or "rbxassetid://1837879082"
    Config3.SoundVolume = data.SoundVolume or 0.5

    setWalkSpeed(Config2.WalkSpeed)
    setJumpPower(Config2.JumpPower)
    setFOV(Config2.FOV)

    notify3("📂 Load", "Configuração carregada!", 3)
end

-- ═══════════ 10. PLAYER TRACKER (últimos jogadores vistos) ═══════════

local trackedPlayers = {}

local function trackPlayer(name, role)
    trackedPlayers[name] = {
        role = role,
        time = os.time(),
    }
end

-- Atualizar quando roles mudam
task.spawn(function()
    while task.wait(3) do
        local m = findMurderer()
        local s = findSheriff()
        if m then trackPlayer(m.Name, "Murderer") end
        if s then trackPlayer(s.Name, "Sheriff") end
    end
end)

local function showTracker()
    local txt = "🔍 Histórico:\n\n"
    local sorted = {}
    for name, data in pairs(trackedPlayers) do
        table.insert(sorted, {name = name, role = data.role, time = data.time})
    end
    table.sort(sorted, function(a, b) return a.time > b.time end)

    for i = 1, math.min(10, #sorted) do
        local d = sorted[i]
        local ago = os.time() - d.time
        txt = txt .. string.format("%s (%s) - %ds atrás\n", d.name, d.role, ago)
    end

    notify3("📋 Player Tracker", txt, 8)
end

-- ═══════════ 11. COIN RAIN ALERT (avisa quando muitas moedas spawnam) ═══════════

local coinAlertConn = nil
local lastCoinCount = 0

local function startCoinAlert()
    if coinAlertConn then coinAlertConn:Disconnect() end
    coinAlertConn = RunService.Heartbeat:Connect(function()
        local map = getMap()
        if not map then return end
        local container = map:FindFirstChild("CoinContainer")
        if not container then return end
        local count = #container:GetChildren()
        if count > lastCoinCount + 5 and lastCoinCount > 0 then
            notify3("💰 Coin Rain!", count .. " moedas novas no mapa!", 3)
        end
        lastCoinCount = count
    end)
end

-- ═══════════ 12. FAST RESPAWN ═══════════

local function fastRespawn()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
    end
    task.wait(0.5)
    LocalPlayer:LoadCharacter()
end

-- ═══════════ 13. HIGH JUMP (pulo automático com espaço segurado) ═══════════

local highJumpConn = nil
local highJumpEnabled = false

local function startHighJump()
    if highJumpConn then highJumpConn:Disconnect() end
    highJumpConn = RunService.Heartbeat:Connect(function()
        if not highJumpEnabled then return end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, 100, hrp.Velocity.Z)
                end
            end
        end
    end)
end

-- ═══════════ 14. TELEPORT TO PLAYER BY NAME ═══════════

local function teleportToPlayerByName(name)
    local target
    for _, p in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), string.lower(name)) 
           or string.find(string.lower(p.DisplayName), string.lower(name)) then
            target = p
            break
        end
    end

    if not target then
        notify3("❌", "Jogador não encontrado: " .. name, 3)
        return
    end

    if not target.Character then
        notify3("❌", "Jogador não tem personagem vivo.", 3)
        return
    end

    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then return end

    myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
    notify3("🚀", "Teleportado para " .. target.Name, 2)
end

-- ═══════════ 15. AUTO-TELEPORT TO MURDERER (auxiliar) ═══════════

local autoTPTask = nil

local function startAutoTPMurderer()
    if autoTPTask then task.cancel(autoTPTask) end
    autoTPTask = task.spawn(function()
        while true do
            task.wait(3)
            if not State3.AutoTPMurderer then break end
            local m = findMurderer()
            if m and m.Character then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local mHRP = m.Character:FindFirstChild("HumanoidRootPart")
                if hrp and mHRP then
                    hrp.CFrame = mHRP.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end)
end

-- ═══════════ ADICIONAR NA UI — NOVA ABA ═══════════

local NetworkTab = Window:CreateTab("🌐 Rede", 4483362458)
local UtilityTab = Window:CreateTab("🛠️ Utilidades", 4483362458)

-- ─── ABA REDE ───

NetworkTab:CreateSection("🌐 Server Hop")

NetworkTab:CreateButton({
    Name = "Server Hop (aleatório)",
    Description = "Troca de servidor automaticamente",
    Callback = function()
        serverHop()
    end,
})

NetworkTab:CreateSlider({
    Name = "Hop até ter X jogadores",
    Range = {2, 12},
    Increment = 1,
    Suffix = "players",
    CurrentValue = 6,
    Flag = "HopMaxPlayers",
    Description = "Fica trocando de server até achar um pequeno",
    Callback = function(value)
        if State3.ServerHopAuto then
            hopUntilSmall(value)
        end
    end,
})

NetworkTab:CreateToggle({
    Name = "Auto Hop até servidor pequeno",
    CurrentValue = false,
    Flag = "AutoHopToggle",
    Callback = function(value)
        if value then
            hopUntilSmall(6)
        else
            State3.ServerHopAuto = false
        end
    end,
})

NetworkTab:CreateSection("📊 Server Stats")

NetworkTab:CreateToggle({
    Name = "Server Stats Panel",
    CurrentValue = false,
    Flag = "ServerStatsToggle",
    Description = "Painel no canto com ping/FPS/memória/coins",
    Callback = function(value)
        State3.ServerStats = value
        if value then createServerStats() else destroyServerStats() end
    end,
})

NetworkTab:CreateSection("💬 Chat")

NetworkTab:CreateInput({
    Name = "Mensagem do Spam",
    CurrentValue = Config3.SpamMessage,
    PlaceholderText = "Digite a mensagem...",
    RemoveTextAfterFocusLost = false,
    Flag = "SpamMessageInput",
    Callback = function(text)
        Config3.SpamMessage = text
    end,
})

NetworkTab:CreateSlider({
    Name = "Delay do spam",
    Range = {1, 30},
    Increment = 1,
    Suffix = "s",
    CurrentValue = 3,
    Flag = "SpamDelaySlider",
    Callback = function(value)
        Config3.SpamDelay = value
    end,
})

NetworkTab:CreateToggle({
    Name = "Chat Spammer",
    CurrentValue = false,
    Flag = "ChatSpamToggle",
    Description = "⚠️ Pode te banir do chat do Roblox",
    Callback = function(value)
        State3.ChatSpammer = value
        if value then startChatSpam() end
    end,
})

NetworkTab:CreateButton({
    Name = "Enviar msg uma vez",
    Callback = function()
        sendChatMessage(Config3.SpamMessage)
        notify3("📤", "Mensagem enviada!", 2)
    end,
})

-- ─── ABA UTILIDADES ───

UtilityTab:CreateSection("🎭 Role Revealer")

UtilityTab:CreateToggle({
    Name = "Role Revealer Visual",
    CurrentValue = false,
    Flag = "RoleRevealerToggle",
    Description = "Mostra o papel de cada jogador com BillboardGui",
    Callback = function(value)
        State3.RoleRevealer = value
        refreshRoleTags()
        if value then
            task.spawn(function()
                while State3.RoleRevealer do
                    task.wait(3)
                    refreshRoleTags()
                end
            end)
        end
    end,
})

UtilityTab:CreateSection("🔊 Som")

UtilityTab:CreateInput({
    Name = "Sound ID",
    CurrentValue = Config3.SoundId,
    PlaceholderText = "rbxassetid://...",
    RemoveTextAfterFocusLost = false,
    Flag = "SoundIdInput",
    Callback = function(text)
        Config3.SoundId = text
    end,
})

UtilityTab:CreateSlider({
    Name = "Volume",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "vol",
    CurrentValue = 0.5,
    Flag = "SoundVolumeSlider",
    Callback = function(value)
        Config3.SoundVolume = value
        if soundSpamObj then soundSpamObj.Volume = value end
    end,
})

UtilityTab:CreateToggle({
    Name = "Sound Spam (client-side)",
    CurrentValue = false,
    Flag = "SoundSpamToggle",
    Description = "Música em loop só pra você",
    Callback = function(value)
        State3.SoundSpam = value
        if value then startSoundSpam() else stopSoundSpam() end
    end,
})

UtilityTab:CreateSection("🛡️ Auto-Defesa")

UtilityTab:CreateToggle({
    Name = "Anti-Trap",
    CurrentValue = false,
    Flag = "AntiTrapToggle",
    Description = "Volta se detectar trap por perto",
    Callback = function(value)
        State3.AntiTrap = value
        if value then startAntiTrap() end
    end,
})

UtilityTab:CreateToggle({
    Name = "Auto-Grab Gun Melhorado",
    CurrentValue = false,
    Flag = "AutoGrabGunToggle",
    Description = "Versão otimizada do auto-pickup",
    Callback = function(value)
        State3.AutoGrabGun = value
        if value then startAutoGrabGun() end
    end,
})

UtilityTab:CreateSection("🚀 Teleporte & Movimento")

UtilityTab:CreateInput({
    Name = "Teleportar para Jogador (nome)",
    PlaceholderText = "Digite o nome...",
    RemoveTextAfterFocusLost = true,
    Flag = "TPToPlayerInput",
    Callback = function(text)
        if text and text ~= "" then
            teleportToPlayerByName(text)
        end
    end,
})

UtilityTab:CreateToggle({
    Name = "Auto-TP no Murderer",
    CurrentValue = false,
    Flag = "AutoTPMurdererToggle",
    Description = "Segue o murderer automaticamente (3s delay)",
    Callback = function(value)
        State3.AutoTPMurderer = value
        if value then startAutoTPMurderer() end
    end,
})

UtilityTab:CreateToggle({
    Name = "High Jump (segurar ESPAÇO)",
    CurrentValue = false,
    Flag = "HighJumpToggle",
    Description = "Pula alto segurando espaço",
    Callback = function(value)
        highJumpEnabled = value
        if value then startHighJump() end
    end,
})

UtilityTab:CreateButton({
    Name = "Fast Respawn",
    Description = "Respawna na hora",
    Callback = function()
        fastRespawn()
    end,
})

UtilityTab:CreateSection("💰 Alerta")

UtilityTab:CreateToggle({
    Name = "Avisar quando moedas spawnarem",
    CurrentValue = false,
    Flag = "CoinAlertToggle",
    Description = "Notifica quando 5+ moedas aparecerem",
    Callback = function(value)
        if value then startCoinAlert() elseif coinAlertConn then coinAlertConn:Disconnect() end
    end,
})

UtilityTab:CreateSection("📋 Tracker")

UtilityTab:CreateButton({
    Name = "Ver histórico de roles",
    Description = "Mostra últimos murderer/sheriff vistos",
    Callback = function()
        showTracker()
    end,
})

UtilityTab:CreateButton({
    Name = "Limpar histórico",
    Callback = function()
        trackedPlayers = {}
        notify3("🧹", "Histórico limpo.", 2)
    end,
})

UtilityTab:CreateSection("💾 Config")

UtilityTab:CreateButton({
    Name = "Salvar Configuração",
    Description = "Salva todas as configs em arquivo",
    Callback = function()
        saveConfig()
    end,
})

UtilityTab:CreateButton({
    Name = "Carregar Configuração",
    Callback = function()
        loadConfig()
    end,
})

-- ═══════════ ADICIONAR AUTO-PUZZLE NA PRINCIPAL ═══════════

MainTab:CreateSection("🧩 Auto-Puzzle")

MainTab:CreateToggle({
    Name = "Auto-solve Puzzle",
    CurrentValue = false,
    Flag = "AutoPuzzleToggle",
    Description = "Tenta resolver puzzles automaticamente",
    Callback = function(value)
        State3.AutoPuzzle = value
        if value then
            task.spawn(function()
                while State3.AutoPuzzle do
                    task.wait(Config3.AutoPuzzleDelay)
                    safeCall3(trySolvePuzzle)
                end
            end)
        end
    end,
})

-- ═══════════ ADICIONAR NA ABA SETTINGS ═══════════

SettingsTab:CreateSection("🚨 Emergência")

SettingsTab:CreateButton({
    Name = "🚨 RESET TUDO (kill-switch)",
    Description = "Desativa TODAS as funções e limpa tudo",
    Callback = function()
        -- Parte 1
        State.AutoShoot = false
        State.AimBot = false
        State.KnifeLoop = false
        State.PlayerESP = false
        State.GunDropESP = false
        State.RoundTimer = false
        stopAimBot()
        stopTimer()
        clearESP()

        -- Parte 2
        State2.SilentAim = false
        State2.AutoCollect = false
        State2.Fullbright = false
        State2.AntiFling = false
        State2.NoClip = false
        State2.TrapsESP = false
        disableFullbright()
        destroyPlayerInfoPanel()
        refreshTrapsESP()
        setWalkSpeed(16)
        setJumpPower(50)
        setFOV(70)

        -- Parte 3
        State3.ChatSpammer = false
        State3.AutoPuzzle = false
        State3.RoleRevealer = false
        State3.SoundSpam = false
        State3.AntiTrap = false
        State3.AutoGrabGun = false
        State3.ServerStats = false
        State3.ServerHopAuto = false
        State3.AutoTPMurderer = false
        stopSoundSpam()
        destroyServerStats()
        for _, tag in pairs(VisualTags) do
            if tag and tag.Parent then tag:--[[
    ═══════════════════════════════════════════════════════
    MM2 Hub - PARTE 4 (Polish Final)
    Funções: Kill Sound Custom, Discord RPC, Kill Notification,
             Spectate Mode, Death Prediction, Skin Changer,
             Auto-Report Sniper, Timer Notify, Party System,
             Safe Mode, Auto-Dodge, Gun Reload Aviso,
             Murderer Radar 3D, Round Analytics, Custom Crosshair
    ═══════════════════════════════════════════════════════
--]]

-- ═══════════ SERVIÇOS ═══════════
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local SoundService4 = game:GetService("SoundService")
local Lighting4 = game:GetService("Lighting")

-- ═══════════ ESTADO PARTE 4 ═══════════
local State4 = {
    KillSound = false,
    DiscordRPC = false,
    KillNotifications = false,
    SpectateMode = false,
    DeathPrediction = false,
    SkinChanger = false,
    SafeMode = false,
    AutoDodge = false,
    GunReloadAlert = false,
    MurdererRadar3D = false,
    CustomCrosshair = false,
    PartySystem = false,
    RoundAnalytics = false,
}

local Config4 = {
    KillSoundId = "rbxassetid://6882409512", -- som de kill
    KillSoundVolume = 1.5,
    CrosshairColor = Color3.fromRGB(255, 50, 50),
    CrosshairSize = 20,
    RadarRange = 150,
    SafeModeHPThreshold = 30,
    DiscordAppId = "1190000000000000000",
    PartyKey = nil,
}

local Connections4 = {}
local KillCount = 0
local DeathCount = 0
local RoundHistory = {}
local SpectateIndex = 1
local myKillSound = nil
local crosshairGui = nil
local radarGui = nil
local radarTask = nil

-- ═══════════ UTILS ═══════════

local function notify4(title, text, dur)
    Rayfield:Notify({ Title = title, Content = text, Duration = dur or 4 })
end

local function safeCall4(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[MM2 Hub P4] " .. tostring(err)) end
    return ok
end

local function findMurdererSafe()
    return findMurderer and findMurderer() or nil
end

local function findSheriffSafe()
    return findSheriff and findSheriff() or nil
end

-- ═══════════ 1. KILL SOUND CUSTOM ═══════════

local function playKillSound()
    if not State4.KillSound then return end
    local s = Instance.new("Sound")
    s.SoundId = Config4.KillSoundId
    s.Volume = Config4.KillSoundVolume
    s.Parent = SoundService4
    s:Play()
    game:GetService("Debris"):AddItem(s, 5)
end

-- ═══════════ 2. KILL NOTIFICATION ═══════════

local lastMurderer = nil
local lastSheriff = nil
local lastAliveList = {}

local function checkKillsAndDeaths()
    local currentAlive = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum.Health > 0 then currentAlive[p.Name] = true end
        end
    end

    -- Detectar mortes
    for name, _ in pairs(lastAliveList) do
        if not currentAlive[name] then
            if name == LocalPlayer.Name then
                DeathCount = DeathCount + 1
                if State4.KillNotifications then
                    notify4("💀 Você morreu!", "Total de mortes: " .. DeathCount, 3)
                end
            else
                if State4.KillNotifications then
                    notify4("⚰️ " .. name, "Morreu", 2)
                end
            end
        end
    end

    lastAliveList = currentAlive
end

-- ═══════════ 3. DEATH PREDICTION ═══════════

local function predictDeathRisk()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local hp = hum.Health
    local murderer = findMurdererSafe()

    if murderer and murderer.Character then
        local mHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = char:FindFirstChild("HumanoidRootPart")
        if mHRP and myHRP then
            local dist = (mHRP.Position - myHRP.Position).Magnitude
            if dist < 15 and hp < Config4.SafeModeHPThreshold then
                notify4("⚠️ PERIGO", "Murderer a " .. math.floor(dist) .. " studs! HP: " .. hp, 2)
            end
        end
    end
end

-- ═══════════ 4. AUTO-DODGE (afastar do murderer) ═══════════

local autoDodgeTask = nil

local function startAutoDodge()
    if autoDodgeTask then task.cancel(autoDodgeTask) end
    autoDodgeTask = task.spawn(function()
        while State4.AutoDodge do
            task.wait(0.2)
            local char = LocalPlayer.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local murderer = findMurdererSafe()
            if not murderer or not murderer.Character then continue end
            local mHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
            if not mHRP then continue end

            local dist = (hrp.Position - mHRP.Position).Magnitude
            if dist < 25 then
                -- Foge na direção oposta
                local direction = (hrp.Position - mHRP.Position).Unit
                local targetPos = hrp.Position + direction * 20
                hrp.Velocity = direction * 60

                -- Avisa
                if State4.KillNotifications then
                    notify4("🏃 Auto-Dodge", "Fugindo! (" .. math.floor(dist) .. " studs)", 1)
                end
            end
        end
    end)
end

-- ═══════════ 5. SPECTATE MODE ═══════════

local spectateCon = nil

local function startSpectate()
    if spectateCon then spectateCon:Disconnect() end
    spectateCon = RunService.RenderStepped:Connect(function()
        if not State4.SpectateMode then return end
        local list = Players:GetPlayers()
        -- Filtrar
        local valid = {}
        for _, p in ipairs(list) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                table.insert(valid, p)
            end
        end
        if #valid == 0 then return end

        if SpectateIndex > #valid then SpectateIndex = 1 end
        local target = valid[SpectateIndex]
        local targetHead = target.Character and target.Character:FindFirstChild("Head")
        if targetHead then
            Camera.CameraSubject = targetHead
        end
    end)
end

local function nextSpectate()
    SpectateIndex = SpectateIndex + 1
    notify4("👁️", "Próximo alvo!", 1)
end

local function stopSpectate()
    if spectateCon then spectateCon:Disconnect() spectateCon = nil end
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then Camera.CameraSubject = hum end
    end
end

-- ═══════════ 6. SKIN CHANGER (visual local) ═══════════

local skinConns = {}

local function applySkinToPlayer(player, color)
    if not player.Character then return end
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Color = color
        end
    end
end

local function startSkinChanger()
    for _, conn in ipairs(skinConns) do conn:Disconnect() end
    skinConns = {}

    for _, p in ipairs(Players:GetPlayers()) do
        local color
        if p == findMurdererSafe() then
            color = Color3.fromRGB(120, 0, 0)
        elseif p == findSheriffSafe() then
            color = Color3.fromRGB(0, 50, 120)
        else
            color = Color3.fromRGB(0, 100, 30)
        end
        applySkinToPlayer(p, color)
    end
end

-- ═══════════ 7. CUSTOM CROSSHAIR ═══════════

local function createCrosshair()
    if crosshairGui then crosshairGui:Destroy() end

    crosshairGui = Instance.new("ScreenGui")
    crosshairGui.Name = "MM2_Crosshair"
    crosshairGui.IgnoreGuiInset = true
    crosshairGui.ResetOnSpawn = false
    crosshairGui.Parent = game:GetService("CoreGui")

    local dot = Instance.new("Frame")
    dot.Name = "Dot"
    dot.Size = UDim2.new(0, 4, 0, 4)
    dot.Position = UDim2.new(0.5, -2, 0.5, -2)
    dot.BackgroundColor3 = Config4.CrosshairColor
    dot.BorderSizePixel = 0
    dot.Parent = crosshairGui
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    -- Linhas
    local function makeLine(name, size, pos)
        local l = Instance.new("Frame")
        l.Name = name
        l.Size = size
        l.Position = pos
        l.BackgroundColor3 = Config4.CrosshairColor
        l.BorderSizePixel = 0
        l.Parent = crosshairGui
        return l
    end

    local gap = 6
    local len = 8
    makeLine("Top", UDim2.new(0, 2, 0, len), UDim2.new(0.5, -1, 0.5, -gap - len))
    makeLine("Bot", UDim2.new(0, 2, 0, len), UDim2.new(0.5, -1, 0.5, gap))
    makeLine("Left", UDim2.new(0, len, 0, 2), UDim2.new(0.5, -gap - len, 0.5, -1))
    makeLine("Right", UDim2.new(0, len, 0, 2), UDim2.new(0.5, gap, 0.5, -1))
end

local function removeCrosshair()
    if crosshairGui then crosshairGui:Destroy() crosshairGui = nil end
end

-- ═══════════ 8. 3D MURDERER RADAR ═══════════

local function createRadarGUI()
    if radarGui then radarGui:Destroy() end

    radarGui = Instance.new("ScreenGui")
    radarGui.Name = "MM2_Radar"
    radarGui.IgnoreGuiInset = true
    radarGui.ResetOnSpawn = false
    radarGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Name = "RadarFrame"
    frame.Size = UDim2.new(0, 150, 0, 150)
    frame.Position = UDim2.new(0.5, -75, 1, -165)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = radarGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0, 255, 100)
    stroke.Thickness = 2

    -- Círculos
    for i = 1, 3 do
        local ring = Instance.new("Frame")
        ring.Size = UDim2.new(i / 3, 0, i / 3, 0)
        ring.Position = UDim2.new(0.5 - i / 6, 0, 0.5 - i / 6, 0)
        ring.BackgroundTransparency = 1
        ring.Parent = frame
        local rs = Instance.new("UIStroke", ring)
        rs.Color = Color3.fromRGB(0, 255, 100)
        rs.Transparency = 0.7
        rs.Thickness = 1
        Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    end

    -- Pontos dos jogadores
    local dots = {}
    radarTask = task.spawn(function()
        while radarGui and radarGui.Parent do
            task.wait(0.15)

            -- Limpar pontos antigos
            for _, d in pairs(dots) do if d.Parent then d:Destroy() end end
            dots = {}

            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then continue end
            local myPos = myChar.HumanoidRootPart.Position
            local myLook = Camera.CFrame.LookVector

            for _, p in ipairs(Players:GetPlayers()) do
                if p == LocalPlayer then continue end
                if not p.Character then continue end
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end

                local relPos = hrp.Position - myPos
                local dist = relPos.Magnitude
                if dist > Config4.RadarRange then continue end

                -- Rotação pra caber no radar
                local angle = math.atan2(relPos.X, relPos.Z) - math.atan2(myLook.X, myLook.Z)
                local radius = (dist / Config4.RadarRange) * 70
                local x = math.sin(angle) * radius
                local y = math.cos(angle) * radius

                local dot = Instance.new("Frame")
                dot.Size = UDim2.new(0, 8, 0, 8)
                dot.Position = UDim2.new(0.5, x - 4, 0.5, y - 4)
                dot.BorderSizePixel = 0
                dot.Parent = frame
                Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

                if p == findMurdererSafe() then
                    dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                elseif p == findSheriffSafe() then
                    dot.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                else
                    dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                end

                dots[p.Name] = dot
            end

            -- Ponto central (você)
            local center = Instance.new("Frame")
            center.Size = UDim2.new(0, 6, 0, 6)
            center.Position = UDim2.new(0.5, -3, 0.5, -3)
            center.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            center.BorderSizePixel = 0
            center.Parent = frame
            Instance.new("UICorner", center).CornerRadius = UDim.new(1, 0)
            dots["__self"] = center
        end
    end)
end

local function destroyRadarGUI()
    if radarTask then task.cancel(radarTask) radarTask = nil end
    if radarGui then radarGui:Destroy() radarGui = nil end
end

-- ═══════════ 9. ROUND ANALYTICS ═══════════

local function trackRound(murderer, sheriff)
    table.insert(RoundHistory, {
        murderer = murderer and murderer.Name or "?",
        sheriff = sheriff and sheriff.Name or "?",
        time = os.time(),
        players = #Players:GetPlayers(),
    })
    if #RoundHistory > 20 then table.remove(RoundHistory, 1) end
end

local function showAnalytics()
    if #RoundHistory == 0 then
        notify4("📊 Analytics", "Nenhuma rodada registrada ainda.", 4)
        return
    end

    local txt = "📊 Últimas rodadas:\n\n"
    for i, r in ipairs(RoundHistory) do
        if i > 5 then break end
        local ago = os.time() - r.time
        txt = txt .. string.format("R%d: 🔪%s 🔫%s (%ds)\n",
            i, string.sub(r.murderer, 1, 8), string.sub(r.sheriff, 1, 8), ago)
    end

    notify4("📊 Round Analytics", txt, 8)
end

-- ═══════════ 10. GUN RELOAD ALERT ═══════════

local gunConn = nil

local function startGunReloadAlert()
    if gunConn then gunConn:Disconnect() end
    -- Monitora se o local player tem arma equipada
    local lastHadGun = false
    gunConn = RunService.Heartbeat:Connect(function()
        if not State4.GunReloadAlert then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hasGun = char:FindFirstChild("Gun") ~= nil
        if hasGun and not lastHadGun then
            notify4("🔫", "Você pegou a arma! Cuidado com murderer.", 3)
        end
        lastHadGun = hasGun
    end)
end

-- ═══════════ 11. DISCORD RPC (fake, só pra mostrar) ═══════════

local function startDiscordRPC()
    notify4("💬 Discord RPC", "Sua presença seria:\n\n🎮 Playing MM2 Hub\n🔪 Role: ???\n📍 Round ativo", 6)

    -- Loop pra atualizar o "status" (fake)
    task.spawn(function()
        while State4.DiscordRPC do
            task.wait(10)
            local role = "?"
            if findMurdererSafe() == LocalPlayer then role = "Murderer 🔪"
            elseif findSheriffSafe() == LocalPlayer then role = "Sheriff 🔫"
            else role = "Innocent 😇" end
            -- Aqui você pode chamar uma API externa se quiser
        end
    end)
end

-- ═══════════ 12. ROUND TIMER NOTIFY ═══════════

local lastTimerWarn = 0

local function startTimerWarn()
    task.spawn(function()
        while true do
            task.wait(5)
            local timerPart = workspace:FindFirstChild("RoundTimerPart")
            if timerPart then
                local t = timerPart:GetAttribute("Time")
                if t and t > 0 and t <= 30 and lastTimerWarn ~= math.floor(t / 10) then
                    lastTimerWarn = math.floor(t / 10)
                    notify4("⏰", "Faltam " .. t .. "s pra acabar a rodada!", 2)
                end
            end
        end
    end)
end

-- ═══════════ 13. PARTY SYSTEM (compartilhar roles) ═══════════

local function createParty(key)
    Config4.PartyKey = key
    notify4("🎉 Party", "Criada com chave: " .. key, 5)
    notify4("📤", "Compartilhe no Discord e as pessoas vão ver os roles!", 5)
end

local function sendPartyUpdate()
    if not Config4.PartyKey then return end
    -- Em uma implementação real, isso mandaria pra um servidor
    local m = findMurdererSafe()
    local s = findSheriffSafe()
    local msg = string.format("[%s] 🔪 %s | 🔫 %s",
        Config4.PartyKey,
        m and m.Name or "?",
        s and s.Name or "?")
    -- Coloca no chat interno
    print("[MM2 Party] " .. msg)
end

-- ═══════════ 14. AUTO-REPORT SNIPER (anti-fling) ═══════════

local reportedPlayers = {}

local function checkForFlingers()
    if not State4.SafeMode then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not p.Character then continue end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- Se algum player estiver com velocidade absurda e perto de você
        local vel = hrp.AssemblyLinearVelocity.Magnitude
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local dist = (hrp.Position - myHRP.Position).Magnitude

        if vel > 500 and dist < 50 and not reportedPlayers[p.Name] then
            reportedPlayers[p.Name] = true
            notify4("🚨 FLINGER DETECTADO", p.Name .. " (vel: " .. math.floor(vel) .. ")", 4)
        end
    end
end

-- ═══════════ 15. SAFE MODE ═══════════

local safeModeConn = nil
local lastSafeHP = 100

local function startSafeMode()
    if safeModeConn then safeModeConn:Disconnect() end
    safeModeConn = RunService.Heartbeat:Connect(function()
        if not State4.SafeMode then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        -- Se HP baixou drasticamente
        if lastSafeHP - hum.Health > 20 then
            notify4("💔 Safe Mode", "Dano detectado! HP: " .. hum.Health, 2)
        end
        lastSafeHP = hum.Health

        -- Se HP baixo, avisar
        if hum.Health < Config4.SafeModeHPThreshold and hum.Health > 0 then
            notify4("❤️ HP Baixo", hum.Health .. "/" .. hum.MaxHealth, 2)
        end
    end)
end

-- ═══════════ LOOP DE MONITORAMENTO GERAL ═══════════

task.spawn(function()
    while task.wait(1) do
        safeCall4(checkKillsAndDeaths)
        safeCall4(checkForFlingers)
        if State4.DeathPrediction then
            safeCall4(predictDeathRisk)
        end
        if State4.PartySystem then
            safeCall4(sendPartyUpdate)
        end
    end
end)

-- Detectar nova rodada (roles diferentes)
task.spawn(function()
    local lastM, lastS
    while task.wait(2) do
        local m = findMurdererSafe()
        local s = findSheriffSafe()
        if m and s and (m ~= lastM or s ~= lastS) then
            lastM, lastS = m, s
            if State4.RoundAnalytics then
                trackRound(m, s)
            end
            if State4.KillNotifications then
                notify4("🎬 Nova rodada", "🔪 " .. m.Name .. "\n🔫 " .. s.Name, 4)
            end
            if State4.RoleRevealer and refreshRoleTags then
                refreshRoleTags()
            end
        end
    end
end)

-- ═══════════ UI — NOVA ABA "EXTRAS" ═══════════

local ExtrasTab = Window:CreateTab("✨ Extras", 4483362458)
local VisualTab = Window:CreateTab("🎨 Visual", 4483362458)

-- ─── EXTRAS ───

ExtrasTab:CreateSection("🔊 Som & Notificações")

ExtrasTab:CreateToggle({
    Name = "Kill Sound Custom",
    CurrentValue = false,
    Flag = "KillSoundToggle",
    Description = "Toca um som quando alguém morre",
    Callback = function(value)
        State4.KillSound = value
        if value then notify4("🔊", "Kill sound ativado!", 2) end
    end,
})

ExtrasTab:CreateInput({
    Name = "Sound ID do Kill",
    CurrentValue = Config4.KillSoundId,
    PlaceholderText = "rbxassetid://...",
    RemoveTextAfterFocusLost = false,
    Flag = "KillSoundIdInput",
    Callback = function(text)
        Config4.KillSoundId = text
    end,
})

ExtrasTab:CreateSlider({
    Name = "Volume do Kill Sound",
    Range = {0, 3},
    Increment = 0.1,
    Suffix = "vol",
    CurrentValue = 1.5,
    Flag = "KillSoundVolSlider",
    Callback = function(value)
        Config4.KillSoundVolume = value
    end,
})

ExtrasTab:CreateButton({
    Name = "Testar som de kill",
    Callback = function()
        local s = Instance.new("Sound")
        s.SoundId = Config4.KillSoundId
        s.Volume = Config4.KillSoundVolume
        s.Parent = SoundService4
        s:Play()
        game:GetService("Debris"):AddItem(s, 5)
        notify4("🔊", "Tocando!", 2)
    end,
})

ExtrasTab:CreateToggle({
    Name = "Kill/Death Notifications",
    CurrentValue = false,
    Flag = "KillNotifToggle",
    Description = "Notifica quando alguém morre",
    Callback = function(value)
        State4.KillNotifications = value
    end,
})

ExtrasTab:CreateToggle({
    Name = "Round Timer Warning (30s)",
    CurrentValue = false,
    Flag = "TimerWarnToggle",
    Description = "Avisa quando faltar 30s pra rodada acabar",
    Callback = function(value)
        if value then startTimerWarn() end
    end,
})

ExtrasTab:CreateSection("🛡️ Segurança")

ExtrasTab:CreateToggle({
    Name = "Safe Mode",
    CurrentValue = false,
    Flag = "SafeModeToggle",
    Description = "Detecta dano, HP baixo e flingers",
    Callback = function(value)
        State4.SafeMode = value
        if value then startSafeMode() end
    end,
})

ExtrasTab:CreateSlider({
    Name = "HP mínimo de alerta",
    Range = {10, 80},
    Increment = 5,
    Suffix = "hp",
    CurrentValue = 30,
    Flag = "SafeModeHP",
    Callback = function(value)
        Config4.SafeModeHPThreshold = value
    end,
})

ExtrasTab:CreateToggle({
    Name = "Death Prediction",
    CurrentValue = false,
    Flag = "DeathPredToggle",
    Description = "Avisa quando murderer está perto com HP baixo",
    Callback = function(value)
        State4.DeathPrediction = value
    end,
})

ExtrasTab:CreateToggle({
    Name = "Auto-Dodge (fugir do murderer)",
    CurrentValue = false,
    Flag = "AutoDodgeToggle",
    Description = "⚠️ Detectável! Foge automaticamente",
    Callback = function(value)
        State4.AutoDodge = value
        if value then startAutoDodge() end
    end,
})

ExtrasTab:CreateToggle({
    Name = "Gun Reload Alert",
    CurrentValue = false,
    Flag = "GunAlertToggle",
    Description = "Avisa quando você pega uma arma",
    Callback = function(value)
        State4.GunReloadAlert = value
        if value then startGunReloadAlert() end
    end,
})

ExtrasTab:CreateSection("👁️ Spectate")

ExtrasTab:CreateToggle({
    Name = "Spectate Mode",
    CurrentValue = false,
    Flag = "SpectateToggle",
    Description = "Fica assistindo outros jogadores",
    Callback = function(value)
        State4.SpectateMode = value
        if value then startSpectate() else stopSpectate() end
    end,
})

ExtrasTab:CreateButton({
    Name = "Próximo alvo (Spectate)",
    Callback = function()
        nextSpectate()
    end,
})

ExtrasTab:CreateSection("📊 Analytics & Party")

ExtrasTab:CreateToggle({
    Name = "Round Analytics",
    CurrentValue = false,
    Flag = "RoundAnalyticsToggle",
    Description = "Registra histórico das últimas rodadas",
    Callback = function(value)
        State4.RoundAnalytics = value
    end,
})

ExtrasTab:CreateButton({
    Name = "Ver Analytics",
    Callback = function()
        showAnalytics()
    end,
})

ExtrasTab:CreateButton({
    Name = "Limpar Analytics",
    Callback = function()
        RoundHistory = {}
        notify4("🧹", "Analytics limpo.", 2)
    end,
})

ExtrasTab:CreateToggle({
    Name = "Party System",
    CurrentValue = false,
    Flag = "PartyToggle",
    Description = "Compartilhe roles com amigos via chave",
    Callback = function(value)
        State4.PartySystem = value
        if value then
            Config4.PartyKey = tostring(math.random(1000, 9999))
            createParty(Config4.PartyKey)
        else
            Config4.PartyKey = nil
        end
    end,
})

ExtrasTab:CreateInput({
    Name = "Entrar em Party (chave)",
    PlaceholderText = "Digite a chave...",
    RemoveTextAfterFocusLost = true,
    Flag = "JoinPartyInput",
    Callback = function(text)
        if text and #text >= 3 then
            Config4.PartyKey = text
            State4.PartySystem = true
            notify4("🎉 Party", "Entrou na party: " .. text, 3)
        end
    end,
})

-- ─── VISUAL ───

VisualTab:CreateSection("🎨 Crosshair")

VisualTab:CreateToggle({
    Name = "Custom Crosshair",
    CurrentValue = false,
    Flag = "CrosshairToggle",
    Description = "Substitui a mira padrão por uma customizada",
    Callback = function(value)
        State4.CustomCrosshair = value
        if value then createCrosshair() else removeCrosshair() end
    end,
})

VisualTab:CreateButton({
    Name = "Crosshair Vermelho",
    Callback = function()
        Config4.CrosshairColor = Color3.fromRGB(255, 50, 50)
        if crosshairGui then removeCrosshair() createCrosshair() end
    end,
})

VisualTab:CreateButton({
    Name = "Crosshair Verde",
    Callback = function()
        Config4.CrosshairColor = Color3.fromRGB(0, 255, 100)
        if crosshairGui then removeCrosshair() createCrosshair() end
    end,
})

VisualTab:CreateButton({
    Name = "Crosshair Ciano",
    Callback = function()
        Config4.CrosshairColor = Color3.fromRGB(0, 220, 255)
        if crosshairGui then removeCrosshair() createCrosshair() end
    end,
})

VisualTab:CreateSection("📡 Radar")

VisualTab:CreateToggle({
    Name = "3D Murderer Radar",
    CurrentValue = false,
    Flag = "RadarToggle",
    Description = "Radar no rodapé mostrando posição de todos",
    Callback = function(value)
        State4.MurdererRadar3D = value
        if value then createRadarGUI() else destroyRadarGUI() end
    end,
})

VisualTab:CreateSlider({
    Name = "Alcance do radar",
    Range = {50, 500},
    Increment = 25,
    Suffix = "studs",
    CurrentValue = 150,
    Flag = "RadarRangeSlider",
    Callback = function(value)
        Config4.RadarRange = value
    end,
})

VisualTab:CreateSection("🎭 Skins")

VisualTab:CreateToggle({
    Name = "Skin Changer Visual",
    CurrentValue = false,
    Flag = "SkinChangerToggle",
    Description = "Colore os personagens: Murderer=vermelho, Sheriff=azul",
    Callback = function(value)
        State4.SkinChanger = value
        if value then
            startSkinChanger()
            task.spawn(function()
                while State4.SkinChanger do
                    task.wait(2)
                    startSkinChanger()
                end
            end)
        end
    end,
})

VisualTab:CreateSection("🖼️ Extra")

VisualTab:CreateButton({
    Name = "Screenshot (hide UI)",
    Description = "Esconde todos os painéis por 3s pra tirar print",
    Callback = function()
        local frames = {}
        for _, obj in ipairs(game:GetService("CoreGui"):GetDescendants()) do
            if obj:IsA("Frame") and obj.Name:match("MM2_") then
                table.insert(frames, {obj = obj, old = obj.Visible})
                obj.Visible = false
            end
        end
        notify4("📸", "3 segundos pra printar!", 3)
        task.wait(3)
        for _, f in ipairs(frames) do
            if f.obj and f.obj.Parent then f.obj.Visible = f.old end
        end
    end,
})

-- ═══════════ ADICIONAR NA SETTINGS ═══════════

SettingsTab:CreateSection("🎮 Hotkeys Info")

SettingsTab:CreateParagraph({
    Title = "Atalhos de Teclado",
    Content = [[
F1 = Shoot Murderer
F2 = Knife Throw
F3 = Silent Aim
F4 = Fullbright
F5 = Anti-Fling
F6 = Spectate próximo
F7 = Emergency Stop

⚠️ Alguns hotkeys podem conflitar com o jogo.
    ]],
})

-- ═══════════ HOTKEYS ═══════════

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if--[[
    ═══════════════════════════════════════════════════════
    MM2 Hub - PARTE 5 (Adaptação MOBILE)
    Funções: Detecção de plataforma, Floating Buttons,
             Touch-friendly UI, Auto-Hide hotkeys
    ═══════════════════════════════════════════════════════
--]]

-- ═══════════ DETECÇÃO DE PLATAFORMA ═══════════

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isTablet = UserInputService.TouchEnabled and UserInputService.KeyboardEnabled
local isPC = UserInputService.KeyboardEnabled and UserInputService.MouseEnabled

print("[MM2 Hub] Plataforma detectada: " .. (isMobile and "📱 Mobile" or isTablet and "📱 Tablet" or "💻 PC"))

-- ═══════════ UI MOBILE — FLOATING BUTTONS ═══════════

local MobileUI = {
    Gui = nil,
    Buttons = {},
    Draggable = true,
}

local function createMobileUI()
    if MobileUI.Gui then MobileUI.Gui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MM2_MobileUI"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    MobileUI.Gui = screenGui

    -- Container principal (onde ficam os botões)
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 60, 0, 60)
    container.Position = UDim2.new(0, 15, 0, 100)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.Parent = screenGui
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", container)
    stroke.Color = Color3.fromRGB(255, 60, 60)
    stroke.Thickness = 2

    -- Ícone principal
    local mainBtn = Instance.new("TextButton")
    mainBtn.Name = "MainBtn"
    mainBtn.Size = UDim2.new(1, 0, 1, 0)
    mainBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    mainBtn.BackgroundTransparency = 1
    mainBtn.Text = "🔪"
    mainBtn.TextSize = 28
    mainBtn.Font = Enum.Font.GothamBold
    mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainBtn.Parent = container

    -- Container de botões (expandido)
    local expanded = Instance.new("Frame")
    expanded.Name = "Expanded"
    expanded.Size = UDim2.new(0, 60, 0, 0)
    expanded.Position = UDim2.new(0, 0, 1, 5)
    expanded.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    expanded.BackgroundTransparency = 0.2
    expanded.BorderSizePixel = 0
    expanded.ClipsDescendants = true
    expanded.Parent = container
    Instance.new("UICorner", expanded).CornerRadius = UDim.new(0, 12)

    local stroke2 = Instance.new("UIStroke", expanded)
    stroke2.Color = Color3.fromRGB(255, 60, 60)
    stroke2.Thickness = 2

    -- Lista de botões (nome, emoji, callback)
    local buttonList = {
        { Name = "Shoot", Emoji = "🔫", Callback = function() safeCall(shootMurderer) end },
        { Name = "Knife", Emoji = "🗡️", Callback = function() safeCall(knifeThrow) end },
        { Name = "AutoShoot", Emoji = "🎯", Callback = function()
            State.AutoShoot = not State.AutoShoot
            if State.AutoShoot then startAutoShoot() end
            notify("🎯", "Auto-Shoot: " .. (State.AutoShoot and "ON" or "OFF"), 2)
        end },
        { Name = "ESP", Emoji = "👁️", Callback = function()
            State.PlayerESP = not State.PlayerESP
            refreshPlayerESP()
            notify("👁️", "ESP: " .. (State.PlayerESP and "ON" or "OFF"), 2)
        end },
        { Name = "Fullbright", Emoji = "💡", Callback = function()
            State2.Fullbright = not State2.Fullbright
            if State2.Fullbright then enableFullbright() else disableFullbright() end
        end },
        { Name = "AntiFling", Emoji = "🛡️", Callback = function()
            State2.AntiFling = not State2.AntiFling
            if State2.AntiFling then startAntiFling() end
            notify("🛡️", "Anti-Fling: " .. (State2.AntiFling and "ON" or "OFF"), 2)
        end },
        { Name = "TP Murder", Emoji = "🚀", Callback = function()
            local m = findMurderer()
            if m and m.Character then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local mHRP = m.Character:FindFirstChild("HumanoidRootPart")
                if hrp and mHRP then hrp.CFrame = mHRP.CFrame + Vector3.new(0, 5, 0) end
            end
        end },
        { Name = "Radar", Emoji = "📡", Callback = function()
            State4.MurdererRadar3D = not State4.MurdererRadar3D
            if State4.MurdererRadar3D then createRadarGUI() else destroyRadarGUI() end
        end },
        { Name = "STOP", Emoji = "🛑", Callback = function()
            -- Emergency stop
            State.AutoShoot = false
            State.AimBot = false
            State.KnifeLoop = false
            State2.SilentAim = false
            State2.AutoCollect = false
            State2.AntiFling = false
            State2.NoClip = false
            State4.AutoDodge = false
            stopAimBot()
            setWalkSpeed(16)
            setJumpPower(50)
            setFOV(70)
            notify("🛑", "Tudo desativado!", 2)
        end },
    }

    local btnHeight = 55
    local currentY = 0

    for _, btnData in ipairs(buttonList) do
        local btn = Instance.new("TextButton")
        btn.Name = btnData.Name
        btn.Size = UDim2.new(1, 0, 0, btnHeight)
        btn.Position = UDim2.new(0, 0, 0, currentY)
        btn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        btn.BackgroundTransparency = 0.15
        btn.Text = btnData.Emoji
        btn.TextSize = 24
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Parent = expanded

        -- Efeito visual de toque
        btn.MouseButton1Down:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.5
            }):Play()
        end)
        btn.MouseButton1Up:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.15
            }):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            safeCall(btnData.Callback)
        end)

        currentY = currentY + btnHeight + 2
    end

    -- Ajustar altura do expanded baseado nos botões
    expanded.Size = UDim2.new(0, 60, 0, currentY)

    -- Estado de abrir/fechar
    local isOpen = false

    mainBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetHeight = isOpen and currentY or 0
        local tween = TweenService:Create(expanded, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 60, 0, targetHeight)
        })
        tween:Play()
        mainBtn.Text = isOpen and "❌" or "🔪"
    end)

    -- ═══════════ DRAG (Touch-friendly) ═══════════

    local dragging, dragStart, startPos

    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = container.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    container.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                container.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
end

local function destroyMobileUI()
    if MobileUI.Gui then MobileUI.Gui:Destroy() MobileUI.Gui = nil end
end

-- ═══════════ ESCALA DE UI (touch-friendly) ═══════════

local function applyMobileScaling()
    -- Se for mobile, aumenta o Rayfield
    if isMobile or isTablet then
        -- Aumenta a escala global da UI
        pcall(function()
            if Rayfield and Rayfield.SetScale then
                Rayfield:SetScale(1.2)
            end
        end)
    end
end

-- ═══════════ BOTÃO VOLTAR (mobile) ═══════════

-- Em mobile, às vezes o jogador fica preso — botão de emergência
local function createEmergencyButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MM2_Emergency"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(1, -65, 0, 15)
    btn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    btn.BackgroundTransparency = 0.15
    btn.Text = "🛑"
    btn.TextSize = 24
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = screenGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255, 100, 100)
    stroke.Thickness = 2

    btn.MouseButton1Click:Connect(function()
        -- Emergency stop global
        State.AutoShoot = false
        State.AimBot = false
        State.KnifeLoop = false
        State.PlayerESP = false
        State2.SilentAim = false
        State2.AutoCollect = false
        State2.Fullbright = false
        State2.AntiFling = false
        State2.NoClip = false
        State2.TrapsESP = false
        State4.AutoDodge = false
        stopAimBot()
        stopTimer()
        clearESP()
        disableFullbright()
        setWalkSpeed(16)
        setJumpPower(50)
        setFOV(70)
        notify("🛑", "Emergency Stop ativado!", 3)
    end)

    -- Arrastar
    local dragging, dragStart, startPos
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and dragging then
            local d = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ═══════════ AJUSTES DE PERFORMANCE MOBILE ═══════════

local function applyMobilePerformance()
    if not (isMobile or isTablet) then return end

    -- Reduzir FPS das animações
    pcall(function()
        -- Desativar sombras
        Lighting.GlobalShadows = false
        -- Reduzir qualidade de renderização
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    -- Reduzir número de ESPs visíveis
    -- (pode causar lag)
    if Config2 and Config2.CollectRadius then
        Config2.CollectRadius = math.min(Config2.CollectRadius, 20)
    end

    notify("📱", "Modo Mobile ativado! UI adaptada.", 4)
end

-- ═══════════ UI ESPECÍFICA MOBILE ═══════════

if isMobile or isTablet then
    -- Criar UI mobile
    createMobileUI()
    createEmergencyButton()
    applyMobilePerformance()

    -- Reduzir efeitos visuais
    task.spawn(function()
        task.wait(1)
        applyMobileScaling()
    end)
end

-- ═══════════ ADICIONAR NA ABA SETTINGS ═══════════

SettingsTab:CreateSection("📱 Mobile")

SettingsTab:CreateToggle({
    Name = "Mostrar Floating Buttons (mobile)",
    CurrentValue = isMobile or isTablet,
    Flag = "MobileUIToggle",
    Description = "Botões flutuantes touch-friendly",
    Callback = function(value)
        if value then createMobileUI() else destroyMobileUI() end
    end,
})

SettingsTab:CreateButton({
    Name = "Recriar Floating Buttons",
    Description = "Se os botões sumirem, clique aqui",
    Callback = function()
        destroyMobileUI()
        task.wait(0.2)
        createMobileUI()
        notify("📱", "Botões recriados!", 2)
    end,
})

SettingsTab:CreateButton({
    Name = "Ativar Modo Performance",
    Description = "Reduz qualidade gráfica pra não lagar",
    Callback = function()
        applyMobilePerformance()
    end,
})

SettingsTab:CreateParagraph({
    Title = "📱 Dicas para Mobile",
    Content = [[
• Use executor Delta ou Arceus (melhor suporte)
• Ative "Performance Mode" se estiver lagando
• Não use Silent Aim (não funciona em mobile)
• Use os Floating Buttons no lugar das hotkeys
• Evite Auto-Collect com 10+ jogadores (lag)
• O botão 🛑 no canto direito é o Emergency Stop

⚠️  Mobile tem mais risco de ban — use conta alt!
    ]],
})

-- ═══════════ AVISO DE PLATAFORMA ═══════════

task.wait(1)
if isMobile then
    notify("📱 Mobile Detectado", "UI mobile ativada! Use os botões flutuantes.", 6)
elseif isTablet then
    notify("📱 Tablet Detectado", "UI mobile + teclado ativados.", 5)
end

print("[MM2 Hub] ✅ Parte 5 (Mobile) carregada com sucesso!")
