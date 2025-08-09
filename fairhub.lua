-- Serviços
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local PPS = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Pasta alvo
local alvo = Workspace:WaitForChild("RenderedMovingAnimals")

-- Listas de RNGs
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
    Test = {
        "Tung Tung Tung Sahur"
    }
}

-- Lookup rápido
local nameToGroup = {}
for g, list in pairs(groups) do
    for _, n in ipairs(list) do
        nameToGroup[n] = g
    end
end

-- Estado dos botões
local state = { Secrets = false, BrainrotGods = false, Test = false }

-- Criar UI
local function createGuiContainer()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DetectorUI_"..tostring(math.random(1000,9999))
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui or game:GetService("CoreGui")
    return gui
end

local gui = createGuiContainer()

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 170)
frame.Position = UDim2.new(0, 10, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,34)
title.BackgroundTransparency = 1
title.Text = "RNG Detector"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,255,255)

-- Criar botões
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

-- Notificação
local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Detector",
            Text = msg,
            Duration = 4
        })
    end)
end

-- Seguir modelo
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

-- Quando prompt aparecer, tentar interagir várias vezes
PPS.PromptShown:Connect(function(prompt)
    if prompt:IsDescendantOf(alvo) then
        task.spawn(function()
            prompt.Enabled = true
            for i = 1, 5 do
                pcall(function()
                    fireproximityprompt(prompt, 1)
                end)
                task.wait(0.2)
            end
        end)
    end
end)

-- Detectar novos modelos e seguir se ativo
alvo.ChildAdded:Connect(function(obj)
    local g = nameToGroup[obj.Name]
    if g and state[g] then
        notify("["..g.."] "..obj.Name)
        seguirModelo(obj)
    end
end)
