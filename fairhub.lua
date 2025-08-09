-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Detecta função de interação disponível
local firePrompt
if typeof(fireproximityprompt) == "function" then
    firePrompt = fireproximityprompt
elseif typeof(fireProximityPrompt) == "function" then
    firePrompt = fireProximityPrompt
end

-- VirtualInputManager para fallback
local VIM
pcall(function() VIM = game:GetService("VirtualInputManager") end)

-- Pasta onde ficam os modelos
local alvo = Workspace:WaitForChild("RenderedMovingAnimals")

-- Função para mover o jogador até uma posição
local function moverAte(pos)
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:MoveTo(pos)
    end
end

-- Função para buscar prompt recursivamente
local function acharPrompt(base)
    for _,obj in ipairs(base:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            return obj
        end
    end
    return nil
end

-- Função para tentar interagir com o prompt
local function interagirPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then
        warn("Prompt inválido")
        return
    end

    -- Mover até o prompt
    local part = prompt.Parent
    if part:IsA("Attachment") then
        part = part.Parent
    end
    if part:IsA("BasePart") then
        moverAte(part.Position)
    end

    task.wait(0.5) -- esperar chegar perto

    print("[Interagir] Tentando com:", prompt:GetFullName())

    if firePrompt then
        pcall(function()
            firePrompt(prompt, 5) -- segurar por 5 segundos
        end)
    elseif VIM then
        -- Fallback: segurar tecla E
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(5)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    else
        warn("Nenhum método de interação disponível!")
    end
end

-- Detectar novos modelos e interagir
alvo.ChildAdded:Connect(function(model)
    if model:IsA("Model") then
        task.spawn(function()
            local prompt = nil
            local start = tick()

            -- Tentar achar o prompt por até 2 segundos
            while tick() - start < 2 and not prompt do
                local rootPart = model:FindFirstChild("RootPart")
                local fakeRoot = model:FindFirstChild("FakeRootPart")

                if rootPart then
                    prompt = acharPrompt(rootPart)
                end
                if not prompt and fakeRoot then
                    prompt = acharPrompt(fakeRoot)
                end

                if not prompt then
                    task.wait(0.1)
                end
            end

            if prompt then
                print("[Info] Prompt encontrado em", model.Name)
                interagirPrompt(prompt)
            else
                print("[Info] Nenhum ProximityPrompt encontrado em", model.Name)
            end
        end)
    end
end)
