-- Serviços
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Função para inserir UI no lugar certo
local function criarScreenGui()
    local parentGui
    if gethui then
        parentGui = gethui() -- Preferido em executores
    else
        parentGui = game:GetService("CoreGui")
    end
    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.Name = "DetectorUI"
    gui.Parent = parentGui
    return gui
end

-- Configuração dos grupos e nomes
local grupos = {
    Secrets = {
        "La Vacca Saturno Saturnita",
        "Chimpanzini Spiderini",
        "Agarrini la Palini",
        "Los Tralaleritos",
        "Las Tralaleritas",
        "Las Vaquitas Saturnitas",
        "Graipuss Medussi",
        "Chicleteira Bicicleteira",
        "La Grande Combinasion",
        "Los Combinasionas",
        "Nuclearo Dinossauro",
        "Garama and Madundung",
        "Dragon Cannelloni",
        "Secret Lucky Block",
        "Pot Hotspot"
    },
    BrainrotGods = {
        "Cocofanto Elefanto",
        "Girafa Celestre",
        "Gattatino Neonino",
        "Matteo",
        "Tralalero Tralala",
        "Los Crocodillitos",
        "Espresso Signora",
        "Odin Din Din Dun",
        "Statutino Libertino",
        "Tukanno Bananno",
        "Trenostruzzo Turbo 3000",
        "Trippi Troppi Troppa Trippa",
        "Ballerino Lololo",
        "Los Tungtungtungcitos",
        "Piccione Macchina",
        "Brainrot God Lucky Block",
        "Orcalero Orcala"
    },
    Test = {
        "Tung Tung Tung Sahur"
    }
}

-- Estado dos botões
local estado = {
    Secrets = false,
    BrainrotGods = false,
    Test = false
}

-- Função de notificação na tela
local function notificar(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🚨 Objeto detectado!",
            Text = msg,
            Duration = 5
        })
    end)
end

-- Monitorar Workspace
Workspace.ChildAdded:Connect(function(obj)
    for grupo, lista in pairs(grupos) do
        if estado[grupo] then
            for _, nome in ipairs(lista) do
                if obj.Name == nome then
                    notificar("[" .. grupo .. "] " .. nome)
                end
            end
        end
    end
end)

-- Criar UI
local ScreenGui = criarScreenGui()

local function criarBotao(texto, ordem, chave)
    local botao = Instance.new("TextButton")
    botao.Size = UDim2.new(0, 200, 0, 50)
    botao.Position = UDim2.new(0, 20, 0, 20 + (ordem * 60))
    botao.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    botao.TextColor3 = Color3.fromRGB(255, 255, 255)
    botao.Font = Enum.Font.GothamBold
    botao.TextSize = 16
    botao.Text = texto .. ": OFF"
    botao.Parent = ScreenGui

    botao.MouseButton1Click:Connect(function()
        estado[chave] = not estado[chave]
        if estado[chave] then
            botao.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            botao.Text = texto .. ": ON"
        else
            botao.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
            botao.Text = texto .. ": OFF"
        end
    end)
end

-- Criar botões
criarBotao("Secrets", 0, "Secrets")
criarBotao("BrainrotGods", 1, "BrainrotGods")
criarBotao("Test", 2, "Test")
