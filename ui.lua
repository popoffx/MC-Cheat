--// Modern UI Library
--// Clean, animated, dark-mode focused
--// Drop-in replacement

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local library = {
	windowcount = 0
}

--// Theme
local theme = {
	bg = Color3.fromRGB(20,20,24),
	panel = Color3.fromRGB(28,28,32),
	stroke = Color3.fromRGB(40,40,46),
	text = Color3.fromRGB(235,235,240),
	subtext = Color3.fromRGB(160,160,170),
	accent = Color3.fromRGB(88,101,242),
	success = Color3.fromRGB(90,190,120),
	danger = Color3.fromRGB(220,80,80)
}

--// Helpers
local function round(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
end

local function shadow(parent)
	local s = Instance.new("ImageLabel")
	s.Image = "rbxassetid://1316045217"
	s.ImageTransparency = 0.7
	s.BackgroundTransparency = 1
	s.Size = UDim2.new(1, 24, 1, 24)
	s.Position = UDim2.new(0, -12, 0, -12)
	s.ZIndex = parent.ZIndex - 1
	s.Parent = parent
end

local function tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

--// Draggable
local function makeDraggable(frame)
	local drag, startPos, startInput
	frame.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = true
			startInput = i.Position
			startPos = frame.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = i.Position - startInput
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			drag = false
		end
	end)
end

--// Create Window
function library:CreateWindow(opt)
	self.windowcount += 1

	library.gui = library.gui or Instance.new("ScreenGui", game.CoreGui)
	library.gui.Name = "ModernUILib"

	local window = {}

	local frame = Instance.new("Frame", library.gui)
	frame.Size = UDim2.fromOffset(280, 40)
	frame.Position = UDim2.fromOffset(40 + (300 * (self.windowcount-1)), 60)
	frame.BackgroundColor3 = theme.panel
	frame.BorderSizePixel = 0
	frame.ZIndex = 2
	round(frame, 12)
	shadow(frame)
	makeDraggable(frame)

	local title = Instance.new("TextLabel", frame)
	title.Size = UDim2.new(1, -40, 0, 40)
	title.Position = UDim2.fromOffset(16,0)
	title.Text = opt.text or "Window"
	title.Font = Enum.Font.GothamSemibold
	title.TextSize = 16
	title.TextXAlignment = Left
	title.TextColor3 = theme.text
	title.BackgroundTransparency = 1

	local toggle = Instance.new("TextButton", frame)
	toggle.Size = UDim2.fromOffset(30,30)
	toggle.Position = UDim2.fromOffset(frame.Size.X.Offset-36,5)
	toggle.Text = "–"
	toggle.Font = Enum.Font.GothamBold
	toggle.TextSize = 18
	toggle.TextColor3 = theme.subtext
	toggle.BackgroundTransparency = 1

	local container = Instance.new("Frame", frame)
	container.Position = UDim2.fromOffset(0,40)
	container.Size = UDim2.new(1,0,0,0)
	container.BackgroundTransparency = 1
	container.ClipsDescendants = true

	local layout = Instance.new("UIListLayout", container)
	layout.Padding = UDim.new(0,8)

	local padding = Instance.new("UIPadding", container)
	padding.PaddingLeft = UDim.new(0,16)
	padding.PaddingRight = UDim.new(0,16)
	padding.PaddingTop = UDim.new(0,12)
	padding.PaddingBottom = UDim.new(0,12)

	local open = true
	toggle.MouseButton1Click:Connect(function()
		open = not open
		toggle.Text = open and "–" or "+"
		local size = open and UDim2.new(1,0,0,layout.AbsoluteContentSize.Y+24) or UDim2.new(1,0,0,0)
		tween(container, {Size = size}, 0.25)
	end)

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if open then
			container.Size = UDim2.new(1,0,0,layout.AbsoluteContentSize.Y+24)
		end
	end)

	--// CONTROLS

	function window:AddToggle(text, cb)
		local state = false

		local holder = Instance.new("Frame", container)
		holder.Size = UDim2.new(1,0,0,28)
		holder.BackgroundTransparency = 1

		local label = Instance.new("TextLabel", holder)
		label.Text = text
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.TextColor3 = theme.text
		label.Size = UDim2.new(1,-50,1,0)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Left

		local switch = Instance.new("Frame", holder)
		switch.Size = UDim2.fromOffset(36,18)
		switch.Position = UDim2.new(1,-36,0.5,-9)
		switch.BackgroundColor3 = theme.stroke
		round(switch,9)

		local knob = Instance.new("Frame", switch)
		knob.Size = UDim2.fromOffset(14,14)
		knob.Position = UDim2.fromOffset(2,2)
		knob.BackgroundColor3 = Color3.new(1,1,1)
		round(knob,7)

		holder.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				state = not state
				tween(knob,{Position = state and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2)})
				tween(switch,{BackgroundColor3 = state and theme.accent or theme.stroke})
				cb(state)
			end
		end)
	end

	function window:AddButton(text, cb)
		local b = Instance.new("TextButton", container)
		b.Size = UDim2.new(1,0,0,28)
		b.Text = text
		b.Font = Enum.Font.Gotham
		b.TextSize = 14
		b.TextColor3 = theme.text
		b.BackgroundColor3 = theme.stroke
		round(b,8)

		b.MouseButton1Click:Connect(cb)
	end

	function window:AddBox(placeholder, cb)
		local box = Instance.new("TextBox", container)
		box.Size = UDim2.new(1,0,0,28)
		box.PlaceholderText = placeholder
		box.Text = ""
		box.Font = Enum.Font.Gotham
		box.TextSize = 14
		box.TextColor3 = theme.text
		box.BackgroundColor3 = theme.stroke
		round(box,8)

		box.FocusLost:Connect(function()
			cb(box)
		end)
	end

	return window
end

return library
