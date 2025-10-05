-- // 🧠 PICOLAS HUB by PicolasYT
-- Movable GUI + Borde RGB + Noclip, Fly, TP, TP2, ESP

-- Anti-reload
if getgenv().PicolasHubLoaded then return end
getgenv().PicolasHubLoaded = true

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRoot = character:WaitForChild("HumanoidRootPart")

local tpSavePos = nil
local flying = false
local noclip = false

-- // GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PicolasHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 250, 0, 250)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -125)
MainFrame.Active = true
MainFrame.Draggable = true

-- 🌈 Borde RGB animado
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 3
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

task.spawn(function()
    local hue = 0
    while task.wait(0.02) do
        hue = (hue + 1) % 360
        UIStroke.Color = Color3.fromHSV(hue / 360, 1, 1)
    end
end)

-- Título
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "🧠 PICOLAS HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Size = UDim2.new(1, 0, 0, 30)

-- Creador de botones
local function makeButton(name, yPos, func)
    local b = Instance.new("TextButton", MainFrame)
    b.Text = name
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Position = UDim2.new(0, 10, 0, yPos)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 16
    b.AutoButtonColor = true
    b.MouseButton1Click:Connect(func)
end

---------------------------------------------------------
-- 1️⃣ Noclip
---------------------------------------------------------
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
    game.StarterGui:SetCore("SendNotification", {
        Title = "Picolas Hub",
        Text = noclip and "🚫 Noclip ACTIVADO" or "✅ Noclip DESACTIVADO"
    })
end)

---------------------------------------------------------
-- 2️⃣ Fly (con cámara y joystick)
---------------------------------------------------------
makeButton("Fly", 80, function()
    flying = not flying
    local hrp = humanoidRoot
    local cam = workspace.CurrentCamera
    local UIS = game:GetService("UserInputService")

    local flyVel = Instance.new("BodyVelocity", hrp)
    flyVel.Velocity = Vector3.zero
    flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    local flyGyro = Instance.new("BodyGyro", hrp)
    flyGyro.P = 9e4
    flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyGyro.CFrame = cam.CFrame

    local speed = 70

    task.spawn(function()
        while flying and task.wait() do
            flyGyro.CFrame = cam.CFrame
            local moveDir = Vector3.zero

            -- Movimiento con teclado o joystick
            if UIS:IsKeyDown(Enum.KeyCode.W) then
                moveDir += cam.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.S) then
                moveDir -= cam.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.A) then
                moveDir -= cam.CFrame.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.D) then
                moveDir += cam.CFrame.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                moveDir += Vector3.new(0, 1, 0)
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDir -= Vector3.new(0, 1, 0)
            end

            -- Joystick móvil
            local moveVec = UIS:GetGamepadState(Enum.UserInputType.Gamepad1)[1]
            if moveVec then
                local joy = moveVec.Position
                moveDir += (cam.CFrame.RightVector * joy.X) + (cam.CFrame.LookVector * joy.Y)
            end

            flyVel.Velocity = moveDir * speed
        end

        flyVel:Destroy()
        flyGyro:Destroy()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Picolas Hub",
            Text = "🕊️ Fly desactivado"
        })
    end)

    if flying then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Picolas Hub",
            Text = "🕊️ Fly activado"
        })
    end
end)

---------------------------------------------------------
-- 3️⃣ Guardar TP
---------------------------------------------------------
makeButton("Guardar TP", 120, function()
    tpSavePos = humanoidRoot.Position
    game.StarterGui:SetCore("SendNotification", {
        Title = "Picolas Hub",
        Text = "📍 Posición guardada!"
    })
end)

---------------------------------------------------------
-- 4️⃣ Ir al TP
---------------------------------------------------------
makeButton("Ir al TP", 160, function()
    if tpSavePos then
        humanoidRoot.CFrame = CFrame.new(tpSavePos)
        game.StarterGui:SetCore("SendNotification", {
            Title = "Picolas Hub",
            Text = "⚡ Teletransportado!"
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Picolas Hub",
            Text = "❌ No hay posición guardada"
        })
    end
end)

---------------------------------------------------------
-- 5️⃣ ESP Jugadores
---------------------------------------------------------
makeButton("ESP Players", 200, function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            if not p.Character.Head:FindFirstChild("PicolasESP") then
                local BillboardGui = Instance.new("BillboardGui", p.Character.Head)
                BillboardGui.Name = "PicolasESP"
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
    end
    game.StarterGui:SetCore("SendNotification", {
        Title = "Picolas Hub",
        Text = "👁️ ESP Activado"
    })
end)