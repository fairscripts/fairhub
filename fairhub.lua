-- Detectar função de interação disponível
local firePrompt
if typeof(fireproximityprompt) == "function" then
    firePrompt = fireproximityprompt
elseif typeof(fireProximityPrompt) == "function" then
    firePrompt = fireProximityPrompt
else
    firePrompt = nil
    warn("[Detector] Nenhuma função fireproximityprompt encontrada no executor — usando apenas métodos de simulação.")
end

-- Serviços
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local PPS = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local VIM
pcall(function() VIM = game:GetService("VirtualInputManager") end)
local camera = workspace.CurrentCamera

-- Pasta alvo
local alvo = Workspace:WaitForChild("RenderedMovingAnimals")

-- Listas
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

-- Criar UI
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
title.Size = UDim2.new(1,0,0,34)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "RNG Detector"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextSize = 18

local function makeToggle(text, y, key)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Position = UDim2.new(0, 10, 0, 34 + y)
    b.BackgroundColor3 = Color3.fromRGB(170,0,0)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.Text = text.." : OFF"
    b.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        if state[key] then
            b.BackgroundColor3 = Color3.fromRGB(0,170,0)
            b.Text = text.." : ON"
        else
            b.BackgroundColor3 = Color3.fromRGB(170,0,0)
            b.Text = text.." : OFF"
        end
    end)
end

makeToggle("Secrets", 6, "Secrets")
makeToggle("BrainrotGods", 46, "BrainrotGods")
makeToggle("Test", 86, "Test")

local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Detector",
            Text = msg,
            Duration = 4
        })
    end)
    print("[Detector] "..msg)
end

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

local function tryInteractPrompt(prompt, holdDuration)
    holdDuration = holdDuration or 5
    print("[Detector] Tentando interagir com prompt:", tostring(prompt))
    local success = false
    local triggeredConn
    pcall(function()
        if prompt.Triggered then
            triggeredConn = prompt.Triggered:Connect(function()
                success = true
                print("[Detector] Prompt.Triggered local fired.")
            end)
        end
    end)

    -- 1) fireproximityprompt (se disponível)
    if firePrompt then
        pcall(function() prompt.Enabled = true end)
        pcall(function() firePrompt(prompt, holdDuration) end)
        local deadline = tick() + holdDuration + 0.5
        while tick() < deadline do
            if success then break end
            task.wait(0.05)
        end
    else
        warn("[Detector] fireproximityprompt indisponível — pulando para fallback.")
    end

    -- 2) Fallback VirtualInputManager
    if not success and VIM then
        print("[Detector] Tentando VirtualInputManager (E).")
        pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game) end)
        task.wait(0.12)
        pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
        local deadline = tick() + 0.5
        while tick() < deadline do
            if success then break end
            task.wait(0.05)
        end
    end

    -- 3) Fallback clique na tela
    if not success and VIM and camera then
        local worldPos = getPromptWorldPosition(prompt)
        if worldPos then
            local sx, sy, onScreen = camera:WorldToViewportPoint(worldPos)
            if onScreen then
                print("[Detector] Tentando clique na tela em:", sx, sy)
                pcall(function() VIM:SendMouseButtonEvent(sx, sy, true, game) end)
                task.wait(0.06)
                pcall(function() VIM:SendMouseButtonEvent(sx, sy, false, game) end)
            end
        end
    end

    if triggeredConn then pcall(function() triggeredConn:Disconnect() end) end
    print("[Detector] Resultado da interação:", success and "SUCESSO" or "FALHOU")
    return success
end

local function seguirModelo(obj)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent then
            conn:Disconnect()
            return
        end
        local targetPart
        if obj:IsA("Model") and obj.PrimaryPart then
            targetPart = obj.PrimaryPart
        elseif obj:IsA("BasePart") then
            targetPart = obj
        else
            targetPart = obj:FindFirstChildWhichIsA("BasePart", true)
        end
        if targetPart then
            humanoid:MoveTo(targetPart.Position)
        end
    end)
end

PPS.PromptShown:Connect(function(prompt)
    if prompt and prompt:IsDescendantOf(alvo) then
        task.spawn(function()
            task.wait(0.08)
            tryInteractPrompt(prompt, 5)
        end)
    end
end)

alvo.ChildAdded:Connect(function(obj)
    local g = nameToGroup[obj.Name]
    if g and state[g] then
        notify("["..g.."] "..obj.Name)
        seguirModelo(obj)
        task.defer(function()
            for _,desc in ipairs(obj:GetDescendants()) do
                if desc:IsA("ProximityPrompt") then
                    tryInteractPrompt(desc, 5)
                end
            end
        end)
    end
end)
