-- Função para interagir com o prompt encontrado
local function interagirPrompt(prompt, holdTime)
    holdTime = holdTime or 2 -- segundos de "segurar"
    if not prompt or not prompt:IsA("ProximityPrompt") then
        log("Prompt inválido para interação.")
        return
    end

    -- Mover até a posição do prompt
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

    log("Interagindo com prompt: %s", prompt)

    -- Tenta usar fireproximityprompt
    local firePrompt = (typeof(fireproximityprompt) == "function" and fireproximityprompt)
        or (typeof(fireProximityPrompt) == "function" and fireProximityPrompt)

    if firePrompt then
        pcall(function() firePrompt(prompt, holdTime) end)
    elseif game:GetService("VirtualInputManager") then
        -- Fallback: segura tecla E
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(holdTime)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    else
        log("Nenhum método de interação disponível para %s", prompt)
    end
end

-- Atalho: sempre que encontrar um novo prompt próximo, interagir automaticamente
alvo.DescendantAdded:Connect(function(desc)
    if desc:IsA("ProximityPrompt") then
        task.delay(0.5, function()
            local prompt, dist = findNearestPrompt(12)
            if prompt then
                interagirPrompt(prompt, 5) -- tenta interagir segurando 5s
            end
        end)
    end
end)

-- Também pode interagir quando você apertar E (força pelo script)
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.E then
        local prompt, dist = findNearestPrompt(12)
        if prompt then
            interagirPrompt(prompt, 5)
        end
    end
end)
