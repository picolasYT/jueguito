-- // PICOLAS HUB 🧠 by PicolasYT
-- Movable GUI + 5 funciones (Noclip, Fly, TP, TP2, ESP)

-- Anti-detección básica
pcall(function()
    getgenv().PicolasHubLoaded = true
end)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("HumanoidRootPart")

local tpSavePos = nil
local flying = false
local noclip = false

-- // GUI Setup
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Size = UDim2.new(0, 250, 0, 250)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -125)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Name = "PicolasHub"

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "🧠 PICOLAS HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Size = UDim2.new(1, 0, 0, 30)

-- Función auxiliar para crear botones
local function makeButton(name, yPos, func)
    local b = Instance.new("TextButton", MainFrame)
    b.Text = name
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Position = UDim2.new(0, 10, 0, yPos)
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 16
    b.MouseButton1Click:Connect(func)
end

-- // 1. Noclip
makeButton("Noclip", 40, function()
    noclip = not noclip
    game:GetService("RunService").Stepped:Connect(function()
        if noclip then
            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
end)

-- // 2. Fly
makeButton("Fly", 80, function()
    flying = not flying
    local hrp = humanoid
    local UIS = game:GetService("UserInputService")
    local speed = 60
    local flyVel = Instance.new("BodyVelocity", hrp)
    local flyGyro = Instance.new("BodyGyro", hrp)
    flyGyro.P = 9e4
    flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyVel.Velocity = Vector3.zero

    task.spawn(function()
        while flying do
            task.wait()
            local cam = workspace.CurrentCamera
            flyGyro.CFrame = cam.CFrame
            local moveDir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
            flyVel.Velocity = moveDir * speed
        end
        flyVel:Destroy()
        flyGyro:Destroy()
    end)
end)

-- // 3. TP Save
makeButton("Guardar TP", 120, function()
    tpSavePos = humanoid.Position
    game.StarterGui:SetCore("SendNotification", {Title="Picolas Hub", Text="📍 Posición guardada"})
end)

-- // 4. TP Go
makeButton("Ir al TP", 160, function()
    if tpSavePos then
        humanoid.CFrame = CFrame.new(tpSavePos)
        game.StarterGui:SetCore("SendNotification", {Title="Picolas Hub", Text="⚡ Teletransportado"})
    else
        game.StarterGui:SetCore("SendNotification", {Title="Picolas Hub", Text="❌ No hay posición guardada"})
    end
end)

-- // 5. ESP Players
makeButton("ESP Players", 200, function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local BillboardGui = Instance.new("BillboardGui", p.Character.Head)
            BillboardGui.Size = UDim2.new(0, 100, 0, 30)
            BillboardGui.AlwaysOnTop = true
            local Name = Instance.new("TextLabel", BillboardGui)
            Name.Text = p.Name
            Name.TextColor3 = Color3.new(1, 1, 1)
            Name.BackgroundTransparency = 1
            Name.Font = Enum.Font.GothamBold
            Name.TextSize = 14
            Name.Size = UDim2.new(1, 0, 1, 0)
        end
    end
end)