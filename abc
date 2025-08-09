-- Logger para testar ProximityPrompts em Workspace.RenderedMovingAnimals
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PPS = game:GetService("ProximityPromptService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- pasta alvo
local alvo = Workspace:WaitForChild("RenderedMovingAnimals")

-- util: monta o caminho completo do objeto
local function getPath(obj)
    if not obj then return "nil" end
    local parts = {}
    local cur = obj
    while cur and cur ~= game do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return table.concat(parts, ".")
end

-- util: print formatado (timestamp + caminho + detalhes)
local function log(fmt, ...)
    local ts = os.date("%H:%M:%S")
    local args = {...}
    for i=1,#args do
        if typeof(args[i]) == "Instance" then
            args[i] = getPath(args[i])
        else
            args[i] = tostring(args[i])
        end
    end
    print(string.format("[%s] %s", ts, string.format(fmt, unpack(args))))
end

-- tabela pra guardar prompts que já estamos monitorando
local monitored = {}

local function attachPrompt(prompt)
    if not prompt or monitored[prompt] then return end
    monitored[prompt] = true
    pcall(function()
        prompt.PromptShown:Connect(function(inputType)
            log("PromptShown -> %s (inputType=%s)", prompt, tostring(inputType))
        end)
    end)
    pcall(function()
        prompt.PromptHidden:Connect(function(inputType)
            log("PromptHidden -> %s (inputType=%s)", prompt, tostring(inputType))
        end)
    end)
    -- alguns jogos/versões expõem Triggered no client; tentamos ligar também
    pcall(function()
        prompt.Triggered:Connect(function(...)
            local args = {...}
            if #args == 0 then
                log("Prompt.Triggered (no args) -> %s", prompt)
            else
                -- geralmente servidor passa player, client pode passar inputType
                local s = ""
                for i=1,#args do s = s .. tostring(args[i]) .. (i<#args and ", " or "") end
                log("Prompt.Triggered -> %s (args=%s)", prompt, s)
            end
        end)
    end)
    log("Attached to prompt: %s", prompt)
end

-- Funções do serviço (global)
pcall(function()
    PPS.PromptShown:Connect(function(prompt, inputType)
        log("Service.PromptShown -> %s (inputType=%s)", prompt, tostring(inputType))
    end)
end)
pcall(function()
    PPS.PromptHidden:Connect(function(prompt, inputType)
        log("Service.PromptHidden -> %s (inputType=%s)", prompt, tostring(inputType))
    end)
end)
pcall(function()
    PPS.PromptTriggered:Connect(function(prompt, player)
        log("Service.PromptTriggered -> %s (player=%s)", prompt, player and player.Name or "nil")
    end)
end)

-- varre um ancestor (ex: model/pasta) em busca de ProximityPrompts e anexa listeners
local function scanForPrompts(root)
    for _, desc in ipairs(root:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            attachPrompt(desc)
        end
    end
end

-- inicial: escaneia tudo na pasta alvo
log("Iniciando scan inicial em %s", getPath(alvo))
scanForPrompts(alvo)

-- quando novos objetos aparecem dentro da pasta alvo, escaneia-os
alvo.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") then
        attachPrompt(desc)
    elseif desc:IsA("Model") or desc:IsA("Folder") or desc:IsA("BasePart") then
        -- se um modelo/subpasta foi adicionado, checa se contém prompts
        -- delay pequeno para dar tempo de hierarquia terminar de montar
        task.defer(function()
            scanForPrompts(desc)
        end)
    end
end)

-- Helper: encontra o prompt monitorado mais próximo do jogador (dentro de maxDist studs)
local function findNearestPrompt(maxDist)
    local char = LocalPlayer.Character
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    if not hrp then return nil, math.huge end
    local best, bestDist = nil, math.huge
    for promptObj,_ in pairs(monitored) do
        if promptObj and promptObj.Parent then
            -- tenta achar posição do prompt via parent/basepart
            local parent = promptObj.Parent
            local pos = nil
            if parent:IsA("BasePart") then
                pos = parent.Position
            elseif parent:IsA("Model") and parent.PrimaryPart then
                pos = parent.PrimaryPart.Position
            else
                local bp = parent:FindFirstChildWhichIsA("BasePart", true)
                if bp then pos = bp.Position end
            end
            if pos then
                local d = (hrp.Position - pos).Magnitude
                if d < bestDist then
                    bestDist = d
                    best = promptObj
                end
            end
        end
    end
    if bestDist <= (maxDist or 10) then
        return best, bestDist
    else
        return nil, bestDist
    end
end

-- captura tecla E (PC) e tenta identificar qual prompt estava mais perto na hora
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.E then
        local prompt, dist = findNearestPrompt(12) -- raio de 12 studs
        if prompt then
            log("Input E pressed -> nearest prompt: %s (dist=%.2f)", prompt, dist)
        else
            log("Input E pressed -> no prompt within range (closestDist=%.2f)", dist)
        end
    end
    -- para mobile: registrar qualquer toque (útil se você tocar na própria UI do prompt)
    if input.UserInputType == Enum.UserInputType.Touch then
        local prompt, dist = findNearestPrompt(12)
        if prompt then
            log("Touch input -> nearest prompt: %s (dist=%.2f)", prompt, dist)
        else
            log("Touch input -> no prompt within range (closestDist=%.2f)", dist)
        end
    end
end)

-- comando simples para listar todos prompts monitorados agora
log("Atualmente monitorando prompts (count): %d", (function() local c=0; for _ in pairs(monitored) do c=c+1 end; return c end)())

-- Sugestão para teste (imprima isto no console)
log("TESTE: aproxime-se de um prompt na pasta RenderedMovingAnimals, espere 'PromptShown' e então pressione E / interaja. Observe as linhas do console.")
