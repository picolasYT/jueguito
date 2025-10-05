-- // 🧠 PICOLAS HUB (fix v2)
-- GUI movable + borde RGB + Fly móvil natural + Noclip estable + TP/TP2 + ESP

if getgenv().PicolasHubLoaded then return end
getgenv().PicolasHubLoaded = true

-- Servicios y refs
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Estado
local tpSavePos = nil
local flying = false
local flyConn: RBXScriptConnection? = nil
local noclip = false
local noclipConn: RBXScriptConnection? = nil
local originalCollide = {} -- partes que cambiamos para restaurar

-- Helpers
local function notify(txt)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title="Picolas Hub", Text=txt})
    end)
end

local function bindCharacter(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(function(newChar)
    -- Al respawn, apagamos toggles y limpiamos
    if flyConn then flyConn:Disconnect() flyConn=nil end
    flying = false
    if noclipConn then noclipConn:Disconnect() noclipConn=nil end
    -- Restaurar colisiones si quedó algo
    for part,_ in pairs(originalCollide) do
        if part and part.Parent then part.CanCollide = true end
    end
    originalCollide = {}
    bindCharacter(newChar)
end)

----------------------------------------------------------------
-- GUI
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PicolasHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 260, 0, 270)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -135)
MainFrame.Active = true
MainFrame.Draggable = true

-- Borde RGB animado 🌈
local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Thickness = 3
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
task.spawn(function()
    local h=0
    while task.wait(0.02) do
        h=(h+1)%360
        UIStroke.Color = Color3.fromHSV(h/360,1,1)
    end
end)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1,0,0,34)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.Text = "🧠 PICOLAS HUB"

local function makeButton(text, y, cb)
    local b = Instance.new("TextButton")
    b.Parent = MainFrame
    b.Size = UDim2.new(1, -20, 0, 32)
    b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = Color3.fromRGB(45,45,45)
    b.AutoButtonColor = true
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 16
    b.Text = text
    b.MouseButton1Click:Connect(cb)
    return b
end

----------------------------------------------------------------
-- 1) Noclip (estable, con restauración)
----------------------------------------------------------------
local function setNoclip(on)
    if on then
        if noclipConn then noclipConn:Disconnect() noclipConn=nil end
        -- Guardamos qué partes tenían CanCollide=true para restaurarlas luego
        originalCollide = {}
        for _,v in ipairs(character:GetDescendants()) do
            if v:IsA("BasePart") then
                if v.CanCollide then originalCollide[v] = true end
                v.CanCollide = false
            end
        end
        noclipConn = RS.Stepped:Connect(function()
            for _,v in ipairs(character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
        notify("🚫 Noclip ACTIVADO")
    else
        if noclipConn then noclipConn:Disconnect() noclipConn=nil end
        -- Restaurar sólo las que cambiamos
        for part,_ in pairs(originalCollide) do
            if part and part.Parent then part.CanCollide = true end
        end
        originalCollide = {}
        notify("✅ Noclip DESACTIVADO")
    end
end

makeButton("Noclip (toggle)", 42, function()
    noclip = not noclip
    setNoclip(noclip)
end)

----------------------------------------------------------------
-- 2) Fly móvil natural (cámara + joystick) SIN BodyMovers
----------------------------------------------------------------
local speed = 70

local function setFly(on)
    if on then
        if flyConn then flyConn:Disconnect() flyConn=nil end
        flying = true
        humanoid.PlatformStand = true -- evita animaciones/choques raros
        flyConn = RS.Heartbeat:Connect(function(dt)
            if not character or not hrp or not humanoid then return end
            local cam = workspace.CurrentCamera
            if not cam then return end

            -- Dirección horizontal desde el joystick/teclas (world space)
            local move = humanoid.MoveDirection
            local horiz = Vector3.new(move.X, 0, move.Z)

            -- Vertical según pitch de la cámara y cuánto te movés
            local pitchY = cam.CFrame.LookVector.Y
            local mag = math.clamp(horiz.Magnitude, 0, 1)
            local vertical = pitchY * mag

            -- Dirección final
            local dir = Vector3.new(0,0,0)
            local combined = Vector3.new(horiz.X, vertical, horiz.Z)
            local m = combined.Magnitude
            if m > 0 then
                dir = combined / m
            end

            -- Velocidad final
            hrp.AssemblyLinearVelocity = dir * speed
            -- Mirar en la dirección de la cámara (opcional):
            -- hrp.AssemblyAngularVelocity = Vector3.new()
            -- hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z))
        end)
        notify("🕊️ Fly ACTIVADO")
    else
        flying = false
        if flyConn then flyConn:Disconnect() flyConn=nil end
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
        if humanoid then humanoid.PlatformStand = false end
        notify("🕊️ Fly DESACTIVADO")
    end
end

makeButton("Fly (toggle)", 80, function()
    setFly(not flying)
end)

----------------------------------------------------------------
-- 3) Guardar TP
----------------------------------------------------------------
makeButton("Guardar TP", 118, function()
    if hrp then
        tpSavePos = hrp.Position
        notify("📍 Posición guardada")
    end
end)

----------------------------------------------------------------
-- 4) Ir al TP
----------------------------------------------------------------
makeButton("Ir al TP", 156, function()
    if tpSavePos and hrp then
        hrp.CFrame = CFrame.new(tpSavePos)
        notify("⚡ Teletransportado")
    else
        notify("❌ No hay posición guardada")
    end
end)

----------------------------------------------------------------
-- 5) ESP Players (simple)
----------------------------------------------------------------
makeButton("ESP Players", 194, function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            if not head:FindFirstChild("PicolasESP") then
                local bg = Instance.new("BillboardGui")
                bg.Name = "PicolasESP"
                bg.Parent = head
                bg.Size = UDim2.new(0, 110, 0, 28)
                bg.AlwaysOnTop = true
                local tl = Instance.new("TextLabel")
                tl.Parent = bg
                tl.Size = UDim2.new(1,0,1,0)
                tl.BackgroundTransparency = 1
                tl.Font = Enum.Font.GothamBold
                tl.TextSize = 14
                tl.TextColor3 = Color3.new(1,1,1)
                tl.Text = p.Name
            end
        end
    end
    notify("👁️ ESP colocado (jugadores actuales)")
end)

----------------------------------------------------------------
-- Tips rápidos:
--  * Cambiá la velocidad del fly con la variable 'speed' arriba.
--  * Si querés subir/bajar sin mirar la cámara: podemos agregar botones
--    virtuales, o teclas (Space = subir, Ctrl = bajar) fácil de añadir.
----------------------------------------------------------------