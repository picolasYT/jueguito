--// 🍍 Picolas Hub v2 - by PicolasYT //--

-- Esperar al jugador y personaje
repeat wait() until game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRoot = character:WaitForChild("HumanoidRootPart")

-- Variables
local savedPos = nil
local noclip = false

-- Crear GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PicolasHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 180)
frame.Position = UDim2.new(0.7, 0, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 2
frame.BackgroundTransparency = 0.1
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "🍍 Picolas Hub 🍍"
title.Size = UDim2.new(1, 0, 0, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Función para crear botones
local function crearBoton(nombre, posY, accion)
	local boton = Instance.new("TextButton")
	boton.Text = nombre
	boton.Size = UDim2.new(1, -20, 0, 40)
	boton.Position = UDim2.new(0, 10, 0, posY)
	boton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	boton.TextColor3 = Color3.fromRGB(255, 255, 255)
	boton.Font = Enum.Font.SourceSansBold
	boton.TextSize = 18
	boton.Parent = frame
	boton.MouseButton1Click:Connect(accion)
end

-- 🧭 TP - Guardar posición
crearBoton("TP (Guardar)", 50, function()
	savedPos = humanoidRoot.Position
	game.StarterGui:SetCore("SendNotification", {
		Title = "📍 Picolas Hub";
		Text = "Posición guardada correctamente!";
		Duration = 2;
	})
end)

-- ⚡ TP2 - Teletransportar
crearBoton("TP2 (Ir)", 100, function()
	if savedPos then
		humanoidRoot.CFrame = CFrame.new(savedPos)
		game.StarterGui:SetCore("SendNotification", {
			Title = "⚡ Picolas Hub";
			Text = "Teletransportado a la posición guardada!";
			Duration = 2;
		})
	else
		game.StarterGui:SetCore("SendNotification", {
			Title = "❌ Picolas Hub";
			Text = "No hay posición guardada todavía!";
			Duration = 2;
		})
	end
end)

-- 🚪 Tras - Noclip
crearBoton("Tras (NoClip)", 150, function()
	noclip = not noclip
	game.StarterGui:SetCore("SendNotification", {
		Title = "🚪 Picolas Hub";
		Text = noclip and "Noclip ACTIVADO" or "Noclip DESACTIVADO";
		Duration = 2;
	})
end)

-- Modo Noclip
game:GetService("RunService").Stepped:Connect(function()
	if noclip and character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide == true then
				part.CanCollide = false
			end
		end
	end
end)