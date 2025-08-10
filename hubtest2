-- Seguir modelos de listas ativas + UI com abas e status de "Seguindo"

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ===================== LISTAS =====================
local lists = {
    Secrets = {
        "La Vacca Saturno Saturnita", "Karkerkar Kurkur", "Chimpanzini Spiderini",
        "Agarrini la Palini", "Los Tralaleritos", "Las Tralaleritas",
        "Las Vaquitas Saturnitas", "Graipuss Medussi", "Chicleteira Bicicleteira",
        "La Grande Combinasion", "Los Combinasionas", "Nuclearo Dinossauro",
        "Los Hotspotsitos", "Garama and Madundung", "Dragon Cannelloni",
        "Secret Lucky Block", "Pot Hotspot", "Esok Sekolah"
    },
    BrainrotGods = {
        "Cocofanto Elefanto", "Girafa Celestre", "Gattatino Neonino",
        "Matteo", "Tralalero Tralala", "Los Crocodillitos", "Espresso Signora",
        "Odin Din Din Dun", "Statutino Libertino", "Tukanno Bananno",
        "Trenostruzzo Turbo 3000", "Trippi Troppi Troppa Trippa",
        "Ballerino Lololo", "Los Tungtungtungcitos", "Piccione Macchina",
        "Brainrot God Lucky Block", "Orcalero Orcala"
    },
    Test = { "Tung Tung Tung Sahur" }
}
local activeLists = { Secrets = false, BrainrotGods = false, Test = false }

-- ===================== CRIAR UI =====================
local old = PlayerGui:FindFirstChild("FollowUI")
if old then old:Destroy() end
local FollowUI = Instance.new("ScreenGui")
FollowUI.Name = "FollowUI"
FollowUI.ResetOnSpawn = false
FollowUI.Parent = PlayerGui

-- Main frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0, 50, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Parent = FollowUI

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 100, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Sidebar.Parent = MainFrame

-- Aba buttons
local tabs = {}
local function createTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, (order - 1) * 45 + 10)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = Sidebar
    tabs[name] = btn
    return btn
end
local AutoFarmTabBtn = createTabButton("Auto Farm", 1)
local MiscTabBtn = createTabButton("Misc", 2)

-- Content frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -100, 1, 0)
ContentFrame.Position = UDim2.new(0, 100, 0, 0)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentFrame.Parent = MainFrame

-- Subframes
local AutoFarmFrame = Instance.new("Frame")
AutoFarmFrame.Size = UDim2.new(1, 0, 1, 0)
AutoFarmFrame.BackgroundTransparency = 1
AutoFarmFrame.Parent = ContentFrame
local MiscFrame = Instance.new("Frame")
MiscFrame.Size = UDim2.new(1, 0, 1, 0)
MiscFrame.BackgroundTransparency = 1
MiscFrame.Visible = false
MiscFrame.Parent = ContentFrame

-- Checkboxes
local function createCheckbox(text, order, toggleVar)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 250, 0, 30)
    btn.Position = UDim2.new(0, 20, 0, (order - 1) * 40 + 20)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "[OFF] " .. text
    btn.Parent = AutoFarmFrame

    btn.MouseButton1Click:Connect(function()
        activeLists[toggleVar] = not activeLists[toggleVar]
        btn.Text = (activeLists[toggleVar] and "[ON] " or "[OFF] ") .. text
        btn.BackgroundColor3 = activeLists[toggleVar] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
    end)
end
createCheckbox("Auto Farm Secrets", 1, "Secrets")
createCheckbox("Auto Farm Brainrot Gods", 2, "BrainrotGods")
createCheckbox("Auto Farm Test", 3, "Test")

-- Tab switch
local function selectTab(tabName)
    for _, btn in pairs(tabs) do
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
    tabs[tabName].BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    AutoFarmFrame.Visible = (tabName == "Auto Farm")
    MiscFrame.Visible = (tabName == "Misc")
end
AutoFarmTabBtn.MouseButton1Click:Connect(function() selectTab("Auto Farm") end)
MiscTabBtn.MouseButton1Click:Connect(function() selectTab("Misc") end)
selectTab("Auto Farm")

-- Status label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 300, 0, 40)
StatusLabel.Position = UDim2.new(1, -320, 1, -60)
StatusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusLabel.BackgroundTransparency = 0.3
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 18
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.Text = ""
StatusLabel.Visible = false
StatusLabel.Parent = FollowUI

local function showFollowing(displayName)
    StatusLabel.Text = "Seguindo (" .. displayName .. ")"
    StatusLabel.Visible = true
end
local function hideFollowing()
    StatusLabel.Visible = false
end

-- ===================== LÓGICA DE FOLLOW =====================
local function waitForCharacterParts(timeout)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local ok = pcall(function() char:WaitForChild("Humanoid", timeout) end)
    local ok2 = pcall(function() char:WaitForChild("HumanoidRootPart", timeout) end)
    return char, (ok and char:FindFirstChildOfClass("Humanoid")), (ok2 and char:FindFirstChild("HumanoidRootPart"))
end

local firePromptFn = (typeof(fireproximityprompt) == "function" and fireproximityprompt)
    or (typeof(fireProximityPrompt) == "function" and fireProximityPrompt) or nil

local function safeFirePrompt(prompt, holdTime)
    holdTime = holdTime or 2
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    if firePromptFn then
        local ok = pcall(function() firePromptFn(prompt, holdTime) end)
        if ok then return true end
    end
    return false
end

local function acharPrompt(model)
    for _,desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            return desc
        end
    end
    return nil
end

local function acharParteAlvo(model)
    local try = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("RootPart") or model.PrimaryPart
    if try and try:IsA("BasePart") then return try end
    for _,v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then return v end
    end
end

local function seguirEInteragirAteSumir(model, displayName)
    local char, humanoid, hrp = waitForCharacterParts(5)
    if not char or not humanoid or not hrp then return end

    showFollowing(displayName)

    local tentativas, lastFireTime = 0, 0
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not model or not model.Parent then
            hideFollowing()
            connection:Disconnect()
            return
        end

        local targetPart = acharParteAlvo(model)
        if targetPart then
            if (hrp.Position - targetPart.Position).Magnitude > 2.2 then
                pcall(function() humanoid:MoveTo(targetPart.Position) end)
            end
        end

        local prompt = acharPrompt(model)
        if prompt and tentativas < 5 then
            if (hrp.Position - prompt.Parent.Position).Magnitude <= 10 then
                if tick() - lastFireTime >= 2 then
                    safeFirePrompt(prompt, 2)
                    tentativas += 1
                    lastFireTime = tick()
                end
            end
        end
    end)
end

-- Monitor
Workspace:WaitForChild("MovingAnimals").ChildAdded:Connect(function(model)
    task.wait(0.5)
    local infoFolder = model:FindFirstChild("HumanoidRootPart") and model.HumanoidRootPart:FindFirstChild("Info")
    if not infoFolder then return end

    local displayLabel = infoFolder:FindFirstChild("DisplayName", true)
    if not (displayLabel and displayLabel:IsA("TextLabel")) then return end

    local txt = displayLabel.Text
    for listName, names in pairs(lists) do
        if activeLists[listName] then
            for _, name in ipairs(names) do
                if txt == name then
                    seguirEInteragirAteSumir(model, txt)
                    return
                end
            end
        end
    end
end)
