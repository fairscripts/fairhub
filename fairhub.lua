-- UI + seguir modelo + tentativa robusta de interação com ProximityPrompt (hold = 5s)
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local PPS = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- tentar pegar VirtualInputManager (nem sempre disponível)
local VIM
pcall(function() VIM = game:GetService("VirtualInputManager") end)

local camera = workspace.CurrentCamera

-- pasta alvo
local alvo = Workspace:WaitForChild("RenderedMovingAnimals")

-- listas (use suas listas)
local groups = {
    Secrets = {
        "La Vacca Saturno Saturnita","Chimpanzini Spiderini","Agarrini la Palini",
        "Los Tralaleritos","Las Tralaleritas","Las Vaquitas Saturnitas",
        "Graipuss Medussi","Chicleteira Bicicleteira","La Grande Combinasion",
        "Los Combinasionas","Nuclearo Dinossauro","Garama and Madundung",
        "Dragon Cannelloni","Secret Lucky Block","Pot Hotspot"
    },
    BrainrotGods = {
        "Cocofanto Elefanto","Girafa Celestre","Gattatino Neonino","Matteo",
        "Tralalero Tralala","Los Crocodillitos","Espresso Signora",
        "Odin Din Din Dun","Statutino Libertino","Tukanno Bananno",
        "Trenostruzzo Turbo 3000","Trippi Troppi Troppa Trippa","Ballerino Lololo",
        "Los Tungtungtungcitos","Piccione Macchina","Brainrot God Lucky Block",
        "Orcalero Orcala"
    },
    Test = { "Tung Tung Tung Sahur" }
}

local nameToGroup = {}
for g,list in pairs(groups) do
    for _,n in ipairs(list) do nameToGroup[n] = g end
end

local state = { Secrets = false, BrainrotGods = false, Test = false }

-- UI simples (garante PlayerGui)
local function createGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DetectorUI_"..tostring(math.random(1000,9999))
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui or game:GetService("CoreGui")
    return gui
end
local gui = createGui()

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 170)
frame.Position = UDim2.new(0, 10, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,34); title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold; title.Text = "RNG Detector"
title.TextColor3 = Color3.fromRGB(255,255,255); title.TextSize = 18

local function makeToggle(text, y, key)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Position = UDim2.new(0, 10, 0, 34 + y)
    b.BackgroundColor3 = Color3.fromRGB(170,0,0)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold; b.TextSize = 15
    b.Text = text.." : OFF"
    b.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        if state[key] then
            b.BackgroundColor3 = Color3.fromRGB(0,170,0); b.Text = text.." : ON"
        else
            b.BackgroundColor3 = Color3.fromRGB(170,0,0); b.Text = text.." : OFF"
        end
    end)
end

makeToggle("Secrets", 6, "Secrets")
makeToggle("BrainrotGods", 46, "BrainrotGods")
makeToggle("Test", 86, "Test")

local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = "Detector", Text = msg, Duration = 4})
    end)
    print("[Detector] "..msg)
end

-- util: posição mundial do prompt (Attachment -> BasePart -> Model.PrimaryPart)
local function getPromptWorldPosition(prompt)
    if not prompt or not prompt.Parent then return nil end
    local parent = prompt.Parent
    if parent:IsA("BasePart") then return parent.Position end
    if parent:IsA("Attachment") then
        local p = parent.Parent
        if p and p:IsA("BasePart") then
            return (p.CFrame * CFrame.new(parent.Position)).p
        end
    end
    if parent:IsA("Model") and parent.PrimaryPart then return parent.PrimaryPart.Position end
    local bp = parent:FindFirstChildWhichIsA("BasePart", true)
    if bp then return bp.Position end
    return nil
end

-- função que tenta interagir com retry; holdDuration definido para 5s
local function tryInteractPrompt(prompt, holdDuration)
    holdDuration = holdDuration or 5 -- <-- segurando 5 segundos
    if not prompt then return false end
    print("[Detector] Tentando interagir com prompt:", tostring(prompt))
    local success = false
    local triggeredConn
    pcall(function()
        if prompt.Triggered then
            triggeredConn = prompt.Triggered:Connect(function(...)
                success = true
                print("[Detector] Prompt.Triggered local fired.")
            end)
        end
    end)

    -- 1) Tentar fireproximityprompt com hold longo (uma vez pode bastar)
    pcall(function()
        prompt.Enabled = true
    end)
    pcall(function()
        -- chama uma vez com holdDuration grande
        fireproximityprompt(prompt, holdDuration)
    end)
    -- aguardar até holdDuration + um buffer para ver se Triggered ocorreu
    local waitUntil = tick() + holdDuration + 0.6
    while tick() < waitUntil do
        if success then break end
        task.wait(0.08)
    end

    -- 2) se não teve sucesso, tentar repetir fire algumas vezes mais (curtos)
    if not success then
        for i=1,3 do
            pcall(function() fireproximityprompt(prompt, math.min(holdDuration,2)) end)
            local deadline = tick() + 0.4
            while tick() < deadline do
                if success then break end
                task.wait(0.05)
            end
            if success then break end
        end
    end

    -- 3) fallback: simular tecla E via VIM (se disponível)
    if not success and VIM then
        print("[Detector] fireproximityprompt não funcionou — tentando VirtualInputManager (E).")
        pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game) end)
        task.wait(0.12)
        pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
        local deadline = tick() + 0.6
        while tick() < deadline do
            if success then break end
            task.wait(0.05)
        end
    end

    -- 4) fallback: clicar na tela na posição do prompt (se VIM + camera disponíveis)
    if not success and VIM and camera then
        local worldPos = getPromptWorldPosition(prompt)
        if worldPos then
            local sx, sy, onScreen = camera:WorldToViewportPoint(worldPos)
