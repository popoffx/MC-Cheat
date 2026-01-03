local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local folder = workspace.NPCVehicles.Vehicles

pcall(function()
	CoreGui.CollisionToggle:Destroy()
end)

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "CollisionToggle"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(280, 170)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 22)

local grad = Instance.new("UIGradient", frame)
grad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 45)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 22))
})
grad.Rotation = 90

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -24, 0, 28)
title.Position = UDim2.new(0, 12, 0, 12)
title.BackgroundTransparency = 1
title.Text = "Vehicle Collision"
title.Font = Enum.Font.GothamMedium
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(240, 240, 245)
title.TextXAlignment = Enum.TextXAlignment.Left

local button = Instance.new("TextButton", frame)
button.Size = UDim2.fromOffset(200, 40)
button.Position = UDim2.fromScale(0.5, 0.48)
button.AnchorPoint = Vector2.new(0.5, 0.5)
button.Text = "OFF"
button.Font = Enum.Font.GothamMedium
button.TextSize = 15
button.TextColor3 = Color3.fromRGB(245, 245, 245)
button.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
button.BorderSizePixel = 0
Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)

local unload = Instance.new("TextButton", frame)
unload.Size = UDim2.fromOffset(200, 34)
unload.Position = UDim2.fromScale(0.5, 0.73)
unload.AnchorPoint = Vector2.new(0.5, 0.5)
unload.Text = "Unload"
unload.Font = Enum.Font.Gotham
unload.TextSize = 14
unload.TextColor3 = Color3.fromRGB(230, 230, 235)
unload.BackgroundColor3 = Color3.fromRGB(90, 90, 95)
unload.BorderSizePixel = 0
Instance.new("UICorner", unload).CornerRadius = UDim.new(1, 0)

local credit = Instance.new("TextLabel", frame)
credit.Size = UDim2.new(1, -24, 0, 16)
credit.Position = UDim2.new(0, 12, 1, -20)
credit.BackgroundTransparency = 1
credit.Text = "made by schlabbadabbadoo (discord)"
credit.Font = Enum.Font.Gotham
credit.TextSize = 11
credit.TextColor3 = Color3.fromRGB(160, 160, 170)
credit.TextXAlignment = Enum.TextXAlignment.Left


do
	local dragging, startPos, startInput

	frame.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startInput = i.Position
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - startInput
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + d.X,
				startPos.Y.Scale,
				startPos.Y.Offset + d.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

local parts = {}
local parts_n = 0

local function addPart(p)
	if p:IsA("BasePart") then
		parts_n += 1
		parts[parts_n] = p
	end
end

for _, d in ipairs(folder:GetDescendants()) do
	addPart(d)
end

local addedConn = folder.DescendantAdded:Connect(addPart)

local parts_ref = parts

local function renderLoop()
	for i = 1, parts_n do
		local p = parts_ref[i]
		if p and p.Parent then
			p.CanCollide = false
		end
	end
end

local conn
local enabled = false

button.MouseButton1Click:Connect(function()
	enabled = not enabled

	if enabled then
		button.Text = "ON"
		button.BackgroundColor3 = Color3.fromRGB(90, 190, 120)
		conn = RunService.RenderStepped:Connect(renderLoop)
	else
		button.Text = "OFF"
		button.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
		if conn then
			conn:Disconnect()
			conn = nil
		end
	end
end)

unload.MouseButton1Click:Connect(function()
	if conn then
		conn:Disconnect()
		conn = nil
	end

	if addedConn then
		addedConn:Disconnect()
		addedConn = nil
	end

	table.clear(parts)
	parts_n = 0

	gui:Destroy()
end)