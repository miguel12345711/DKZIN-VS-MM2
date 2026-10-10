--[[
    ╔══════════════════════════════════════════════════╗
    ║           Ruan MM2 ESP — Mobile Edition          ║
    ║                                                  ║
    ║   ESP Sheriff (azul)                             ║
    ║   ESP Inocente (verde)                           ║
    ║   ESP Assassino (vermelho)                       ║
    ║                                                  ║
    ║   Compatível com: Delta, Arceus X, Hydrogen      ║
    ╚══════════════════════════════════════════════════╝
--]]

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Tabela global que guarda os highlights
local esp = {
    sheriff = {},
    innocent = {},
    murderer = {},
    enabled = true
}

--==============================================================
-- DETECÇÃO DE ROLES
--==============================================================
local function getRole(player)
    if not player or not player.Character then return nil end
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character

    -- Verifica se está segurando ou tem na mochila
    if (char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife")) then
        return "Murderer"
    end
    if (char:FindFirstChild("Gun")) or (backpack and backpack:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

--==============================================================
-- CRIA HIGHLIGHT
--==============================================================
local function createHighlight(player, color)
    local char = player.Character
    if not char then return end

    local old = char:FindFirstChild("RuanESP")
    if old then old:Destroy() end

    local h = Instance.new("Highlight")
    h.Name = "RuanESP"
    h.Adornee = char
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.5
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = char

    return h
end

--==============================================================
-- APLICA ESP EM TODOS OS JOGADORES
--==============================================================
local function refreshESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        if not esp.enabled then continue end

        local role = getRole(player)
        local color

        if role == "Murderer" then
            color = Color3.fromRGB(255, 0, 0)      -- Vermelho
        elseif role == "Sheriff" then
            color = Color3.fromRGB(0, 150, 255)    -- Azul
        else
            color = Color3.fromRGB(0, 255, 0)      -- Verde
        end

        createHighlight(player, color)
    end
end

--==============================================================
-- LOOP PRINCIPAL
--==============================================================
task.spawn(function()
    while task.wait(0.5) do
        if esp.enabled then
            refreshESP()
        end
    end
end)

--==============================================================
-- QUANDO UM JOGADOR ENTRA/SAI
--==============================================================
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        refreshESP()
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character and player.Character:FindFirstChild("RuanESP") then
        player.Character.RuanESP:Destroy()
    end
end)

--==============================================================
-- LIMPA HIGHLIGHTS QUANDO O JOGADOR MORRE
--==============================================================
local function watchCharacter(player)
    player.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid", 5)
        char.Humanoid.Died:Connect(function()
            local h = char:FindFirstChild("RuanESP")
            if h then h:Destroy() end
        end)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    watchCharacter(p)
end
Players.PlayerAdded:Connect(watchCharacter)

--==============================================================
-- NOTIFICAÇÃO DE CARREGAMENTO
--==============================================================
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Ruan MM2 ESP",
    Text = "ESP ativado! Sheriff (azul) | Inocente (verde) | Assassino (vermelho)",
    Duration = 5
})

print("[Ruan ESP] Carregado com sucesso!")
