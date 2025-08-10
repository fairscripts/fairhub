--[[
UI de Auto Farm + Misc com abas
Mostra no canto inferior direito "Seguindo (DisplayName)" quando seguir
Usa PlayerGui (seguro para LocalScripts)
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove se já existir
local old = PlayerGui:FindFirstChild("FollowUI")
if old then old:Destroy() end

-- ======== LISTA DE ESTADOS ========
local activeLists = {
    Secrets = false,
    BrainrotGods = false,
    Test = false
}

-- ======== FUNÇÃO CRIAR UI ========
local FollowUI = Instance.new("ScreenGui")
FollowUI.Name = "FollowUI"
FollowUI.ResetOnSpawn = false
FollowUI.Parent = PlayerGui

-- Container principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0, 50, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Parent = FollowUI

-- ======== Aba lateral ========
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

-- ======== Área de conteúdo ========
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -100, 1, 0)
ContentFrame.Position = UDim2.new(0, 100, 0, 0)
ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentFrame.Parent = MainFrame

-- Subframes de conteúdo
local AutoFarmFrame = Instance.new("Frame")
AutoFarmFrame.Size = UDim2.new(1, 0, 1, 0)
AutoFarmFrame.BackgroundTransparency = 1
AutoFarmFrame.Parent = ContentFrame

local MiscFrame = Instance.new("Frame")
MiscFrame.Size = UDim2.new(1, 0, 1, 0)
MiscFrame.BackgroundTransparency = 1
MiscFrame.Visible = false
MiscFrame.Parent = ContentFrame

-- ======== Checkboxes para Auto Farm ========
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

-- ======== Alternar abas ========
local function selectTab(tabName)
    -- reset cores
    for name, btn in pairs(tabs) do
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
    tabs[tabName].BackgroundColor3 = Color3.fromRGB(0, 170, 255)

    -- mostrar frame certo
    AutoFarmFrame.Visible = (tabName == "Auto Farm")
    MiscFrame.Visible = (tabName == "Misc")
end

AutoFarmTabBtn.MouseButton1Click:Connect(function() selectTab("Auto Farm") end)
MiscTabBtn.MouseButton1Click:Connect(function() selectTab("Misc") end)

-- seleciona Auto Farm como padrão
selectTab("Auto Farm")

-- ======== Painel de status (Seguindo ...) ========
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

-- função para exibir quando começar a seguir
local function showFollowing(displayName)
    StatusLabel.Text = "Seguindo (" .. displayName .. ")"
    StatusLabel.Visible = true
end

local function hideFollowing()
    StatusLabel.Visible = false
end

-- Exemplo de uso:
-- showFollowing("Tung Tung Tung Sahur")
-- task.wait(5)
-- hideFollowing()

print("[FollowUI] Interface criada com abas e painel de status prontos.")
