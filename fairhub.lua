-- Logger + Interação para ProximityPrompts em Workspace.RenderedMovingAnimals
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PPS = game:GetService("ProximityPromptService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

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
    pcall(function()
        prompt.Triggered:Connect(function(...)
            local args = {...}
            if #args == 0 then
                log("Prompt.Triggered (no args) -> %s", prompt)
            else
                local s = ""
                for i=1,#args do s = s .. tostring(args[i]) .. (i<#args and ", " or "") end
                log("Prompt.Triggered -> %s (args=%s)", prompt, s)
            end
        end)
    end)
    log("Attached to prompt: %s", prompt)
end

-- funções do serviço
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

-- varre um ancestor (ex: model/pasta) em busca de ProximityPrompts
local function scanForPrompts(root)
    for _, desc in ipairs(root:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            attachPrompt(desc)
        end
    end
end

log("Iniciando scan inicial em %s", getPath(alvo))
scanForPrompts(alvo)

alvo.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") then
        attachPrompt(desc)
    elseif desc:IsA("Model") or desc:IsA("Folder") or desc:IsA("BasePart") then
        task.defer(function()
            scanForPrompts(desc)
        end)
    end
end)

-- encontra o prompt mais próximo do jogador
local function findNearestPrompt(maxDist)
    local char = LocalPlayer.Character
    local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    if not hrp then return nil, math.huge end
    local best, bestDist = nil, math.huge
    for promptObj,_ in pairs(monitored) do
        if promptObj and promptObj.Parent then
            local parent = promptObj.Parent
            local pos
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

-- função para interagir com prompt
local function interagirPrompt(prompt, holdTime)
    holdTime = holdTime or 2
    if not prompt or not prompt:IsA("ProximityPrompt") then
        log("Prompt inválido para interação.")
        return
    end

    -- mover até prompt
    local parent = prompt.Parent
    local pos
    if parent:IsA("BasePart") then
        pos = parent.Position
    elseif parent:IsA("Model") and parent.PrimaryPart then
        pos = parent.PrimaryPart.Position
    else
        local bp = parent:FindFirstChildWhichIsA("BasePart", true)
        if bp then pos = bp.Position end
    end
    if pos then
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:MoveTo(pos)
            humanoid.MoveToFinished:Wait(holdTime)
        end
    end

    -- tentar interação
    local firePrompt = (typeof(fireproximityprompt) == "function" and fireproximityprompt)
        or (typeof(fireProximityPrompt) == "function" and fireProximityPrompt)

    if firePrompt then
        pcall(function() firePrompt(prompt, holdTime) end)
    elseif game:GetService("VirtualInputManager") then
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(holdTime)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    else
        log("Nenhum método de interação disponível para %s", prompt)
    end
end

-- interagir ao apertar E
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.E then
        local prompt, dist = findNearestPrompt(12)
        if prompt then
            interagirPrompt(prompt, 5)
        else
            log("Nenhum prompt próximo (dist mais próxima = %.2f)", dist)
        end
    end
end)

-- interagir automaticamente quando prompt novo aparecer
alvo.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") then
        task.delay(0.5, function()
            local prompt, dist = findNearestPrompt(12)
            if prompt then
                interagirPrompt(prompt, 5)
            end
        end)
    end
end)

log("Atualmente monitorando prompts: %d", (function() local c=0; for _ in pairs(monitored) do c=c+1 end; return c end)())
