-- UI + seguir modelo + tentativa robusta de interação com ProximityPrompt
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local PPS = game:GetService("ProximityPromptService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- try get VirtualInputManager (nem sempre disponível)
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

-- util: posição "mundo" do prompt (tenta Attachment -> BasePart -> Model.PrimaryPart)
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

-- rotina robusta: tenta vários métodos até detectar Triggered
local function tryInteractPrompt(prompt, timeout)
    timeout = timeout or 3
    if not prompt then return false end
    print("[Detector] Tentando interagir com prompt:", prompt:GetFullName and prompt:GetFullName() or tostring(prompt))
    local success = false
    local triggeredConn
    -- tenta conectar Triggered local para detectar sucesso
    pcall(function()
        if prompt.Triggered then
            triggeredConn = prompt.Triggered:Connect(function(...)
                success = true
                print("[Detector] Prompt.Triggered local fired.")
            end)
        end
    end)
    local start = tick()

    -- 1) tentar fireproximityprompt algumas vezes
    for i=1,4 do
        if success then break end
        pcall(function() fireproximityprompt(prompt, 1) end)
        task.wait(0.18)
        if success then break end
    end

    -- 2) se não funcionou, tentar VirtualInputManager tecla E
    if not success and VIM then
        print("[Detector] fireproximityprompt não funcionou — tentando VirtualInputManager (E).")
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        end)
        task.wait(0.12)
        pcall(function()
            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        end)
        -- aguarda um pouco por Triggered
        local waitUntil = tick() + 0.4
        while tick() < waitUntil do
            if success then break end
            task.wait(0.05)
        end
    end

    -- 3) se ainda não, tentar clique
