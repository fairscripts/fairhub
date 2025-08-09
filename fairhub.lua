-- Serviços
local Workspace = game:GetService("Workspace")
local alvo = Workspace:WaitForChild("RenderedMovingAnimals")

print("[PromptScanner] Iniciado — monitorando:", alvo:GetFullName())

-- Função para logar um prompt
local function logPrompt(prompt)
    print("[PromptScanner] Encontrado:", prompt:GetFullName(), " | Parent:", prompt.Parent and prompt.Parent.Name or "nil")
end

-- Função para varrer todos os prompts dentro de um modelo
local function scanModel(model)
    for _,desc in ipairs(model:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            logPrompt(desc)
        end
    end
end

-- Monitorar prompts adicionados no futuro dentro de um modelo
local function monitorModel(model)
    -- Escutar novos objetos
    model.DescendantAdded:Connect(function(desc)
        if desc:IsA("ProximityPrompt") then
            logPrompt(desc)
        end
    end)
end

-- Escutar novos modelos adicionados em RenderedMovingAnimals
alvo.ChildAdded:Connect(function(model)
    if model:IsA("Model") then
        print("[PromptScanner] Novo modelo detectado:", model.Name)
        scanModel(model)      -- varre tudo imediatamente
        monitorModel(model)   -- continua escutando novos prompts
    end
end)

-- Também escanear os que já existem ao iniciar
for _,obj in ipairs(alvo:GetChildren()) do
    if obj:IsA("Model") then
        scanModel(obj)
        monitorModel(obj)
    end
end
