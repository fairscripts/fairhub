-- Versão resiliente e compacta (cole no Delta)
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- listas (compactas)
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
    Test = {"Tung Tung Tung Sahur"}
}

-- transforma em lookup por nome para checagem rápida
local nameToGroup = {}
for g, list in pairs(groups) do
    for _, n in ipairs(list) do
        nameToGroup[n] = g
    end
end

-- estado
local state = { Secrets = false, BrainrotGods = false, Test = false }

-- criar ScreenGui em local seguro (tenta gethui, senão PlayerGui)
local function createGuiContainer()
    local ok, container
    if type(gethui) == "function" then
        ok, container = pcall(gethui)
        if ok and typeof(container) == "Instance" then
            -- good
        else
            container = nil
        end
    end
    container = container or PlayerGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "DetectorUI_"..tostring(math.random(1000,9999)) -- nome único
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = container
    return gui
end

local gui = createGuiContainer()

-- simples frame + botões
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 170)
frame.Position = UDim2.new(0, 10, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.02

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,34)
title.BackgroundTransparency = 1
title.Text = "RNG Detector"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,255,255)

local function makeToggle(text, y, key)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Position = UDim2.new(0, 10, 0, 34 + y)
    b.BackgroundColor3 = Color3.fromRGB(170,0,0)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.Text = text.." : OFF"
    local on = false
    b.MouseButton1Click:Connect(function()
        on = not on
        state[key] = on
        if on then
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

-- função de notificação (tenta SetCore; se falhar, cria label temporário)
local function notify(msg)
    local success = pcall(function()
        StarterGui:SetCore("SendNotification", {Title = "Detector", Text = msg, Duration = 4})
    end)
    if success then return end
    -- fallback UI
    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(0.6,0,0,40)
    label.Position = UDim2.new(0.2,0,0.02,0)
    label.BackgroundColor3 = Color3.fromRGB(25,25,25)
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Text = msg
    label.BorderSizePixel = 0
    task.delay(4, function() if label then label:Destroy() end end)
end

-- monitorar Workspace (ChildAdded)
Workspace.ChildAdded:Connect(function(obj)
    local name = obj.Name
    local g = nameToGroup[name]
    if g and state[g] then
        notify("["..g.."] "..name)
    end
end)

-- também checar se algum dos nomes já existe quando o script começa
for _, obj in ipairs(Workspace:GetChildren()) do
    local g = nameToGroup[obj.Name]
    if g and state[g] then
        notify("["..g.."] "..obj.Name)
    end
end
