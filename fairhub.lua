-- Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local alvo = Workspace:WaitForChild("RenderedMovingAnimals")

-- Listas de nomes
local SecretsList = {
    "La Vacca Saturno Saturnita","Chimpanzini Spiderini","Agarrini la Palini",
    "Los Tralaleritos","Las Tralaleritas","Las Vaquitas Saturnitas",
    "Graipuss Medussi","Chicleteira Bicicleteira","La Grande Combinasion",
    "Los Combinasionas","Nuclearo Dinossauro","Garama and Madundung",
    "Dragon Cannelloni","Secret Lucky Block","Pot Hotspot"
}

local BrainrotGodsList = {
    "Cocofanto Elefanto","Girafa Celestre","Gattatino Neonino","Matteo",
    "Tralalero Tralala","Los Crocodillitos","Espresso Signora","Odin Din Din Dun",
    "Statutino Libertino","Tukanno Bananno","Trenostruzzo Turbo 3000",
    "Trippi Troppi Troppa Trippa","Ballerino Lololo","Los Tungtungtungcitos",
    "Piccione Macchina","Brainrot God Lucky Block","Orcalero Orcala"
}

local TestList = {
    "Tung Tung Tung Sahur"
}

-- Estado de ativação
local activeCategories = {
    Secrets = false,
    BrainrotGods = false,
    Test = false
}

-- Criar GUI simples
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))

local function createButton(name, position)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = position
    btn.Text = name.." [OFF]"
    btn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = ScreenGui
    btn.MouseButton1Click:Connect(function()
        activeCategories[name] = not activeCategories[name]
        if activeCategories[name] then
            btn.Text = name.." [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        else
            btn.Text = name.." [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        end
    end)
end

createButton("Secrets", UDim2.new(0, 20, 0, 50))
createButton("BrainrotGods", UDim2.new(0, 20, 0, 100))
createButton("Test", UDim2.new(0, 20, 0, 150))

-- Função para buscar prompt recursivamente
local function acharPrompt(model)
    for _,desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            return desc
        end
    end
    return nil
end

-- Função para seguir modelo e interagir
local function seguirEInteragir(model)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local firePrompt = (typeof(fireproximityprompt) == "function" and fireproximityprompt)
        or (typeof(fireProximityPrompt) == "function" and fireProximityPrompt)

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not model or not model.Parent then
            connection:Disconnect()
            return
        end
        -- Seguir modelo
        local targetPos
        if model.PrimaryPart then
            targetPos = model.PrimaryPart.Position
        else
            local rootPart = model:FindFirstChild("RootPart") or model:FindFirstChild("FakeRootPart")
            if rootPart then targetPos = rootPart.Position end
        end
        if targetPos then
            humanoid:MoveTo(targetPos)
        end

        -- Procurar prompt
        local prompt = acharPrompt(model)
        if prompt then
            if firePrompt then
                pcall(function() firePrompt(prompt, 2) end)
            else
                local VIM = game:GetService("VirtualInputManager")
                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(2)
                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end
            connection:Disconnect()
        end
    end)
end

-- Checar se nome está numa lista ativada
local function nomeSelecionado(nome)
    if activeCategories.Secrets then
        for _,v in ipairs(SecretsList) do
            if v == nome then return true end
        end
    end
    if activeCategories.BrainrotGods then
        for _,v in ipairs(BrainrotGodsList) do
            if v == nome then return true end
        end
    end
    if activeCategories.Test then
        for _,v in ipairs(TestList) do
            if v == nome then return true end
        end
    end
    return false
end

-- Quando um modelo novo aparecer
alvo.ChildAdded:Connect(function(model)
    if model:IsA("Model") then
        task.spawn(function()
            if nomeSelecionado(model.Name) then
                seguirEInteragir(model)
            end
        end)
    end
end)
