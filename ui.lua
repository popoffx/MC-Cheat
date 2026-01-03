--// Modern UI Library (Fixed & Stable)
--// UI only – no game logic

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local library = { windowcount = 0 }

--// Theme
local theme = {
	bg = Color3.fromRGB(18,18,22),
	panel = Color3.fromRGB(28,28,32),
	stroke = Color3.fromRGB(45,45,50),
	text = Color3.fromRGB(235,235,240),
	sub = Color3.fromRGB(160,160,170),
	accent = Color3.fromRGB(88,101,242)
}

--// Helpers
local function round(o,r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,r)
	c.Parent = o
end

local function tween(o,p,t)
	TweenService:Create(o,TweenInfo.new(t or 0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play()
end

--// Drag
local function drag(frame)
	local dragging,startPos,startInput
	frame.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startInput = i.Position
			startPos = frame.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - startInput
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

--// Window
function library:CreateWindow(opt)
	self.windowcount += 1
	library.gui = library.gui or Instance.new("ScreenGui",game.CoreGui)
	library.gui.Name = "ModernUILib"

	local window = {}

	local frame = Instance.new("Frame",library.gui)
	frame.Size = UDim2.fromOffset(300,40)
	frame.Position = UDim2.fromOffset(40 + (320*(self.windowcount-1)),60)
	frame.BackgroundColor3 = theme.panel
	frame.BorderSizePixel = 0
	round(frame,12)
	drag(frame)

	local title = Instance.new("TextLabel",frame)
	title.Size = UDim2.new(1,-40,0,40)
	title.Position = UDim2.fromOffset(16,0)
	title.BackgroundTransparency = 1
	title.Text = opt.text or "Window"
	title.Font = Enum.Font.GothamSemibold
	title.TextSize = 16
	title.TextColor3 = theme.text
	title.TextXAlignment = Enum.TextXAlignment.Left

	local toggle = Instance.new("TextButton",frame)
	toggle.Size = UDim2.fromOffset(32,32)
	toggle.Position = UDim2.new(1,-36,0,4)
	toggle.BackgroundTransparency = 1
	toggle.Text = "–"
	toggle.Font = Enum.Font.GothamBold
	toggle.TextSize = 20
	toggle.TextColor3 = theme.sub

	local container = Instance.new("Frame",frame)
	container.Position = UDim2.fromOffset(0,40)
	container.Size = UDim2.new(1,0,0,0)
	container.BackgroundTransparency = 1
	container.ClipsDescendants = true

	local layout = Instance.new("UIListLayout",container)
	layout.Padding = UDim.new(0,8)

	local pad = Instance.new("UIPadding",container)
	pad.PaddingLeft = UDim.new(0,16)
	pad.PaddingRight = UDim.new(0,16)
	pad.PaddingTop = UDim.new(0,12)
	pad.PaddingBottom = UDim.new(0,12)

	local open = true

	local function resize()
		if open then
			local h = layout.AbsoluteContentSize.Y + 24
			container.Size = UDim2.new(1,0,0,h)
			frame.Size = UDim2.new(0,300,0,h+40)
		else
			container.Size = UDim2.new(1,0,0,0)
			frame.Size = UDim2.fromOffset(300,40)
		end
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)

	toggle.MouseButton1Click:Connect(function()
		open = not open
		toggle.Text = open and "–" or "+"
		resize()
	end)

	--// Toggle
	function window:AddToggle(text,cb)
		local state = false

		local holder = Instance.new("Frame",container)
		holder.Size = UDim2.new(1,0,0,28)
		holder.BackgroundTransparency = 1

		local label = Instance.new("TextLabel",holder)
		label.Size = UDim2.new(1,-60,1,0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.TextColor3 = theme.text
		label.TextXAlignment = Enum.TextXAlignment.Left

		local bg = Instance.new("Frame",holder)
		bg.Size = UDim2.fromOffset(36,18)
		bg.Position = UDim2.new(1,-36,0.5,-9)
		bg.BackgroundColor3 = theme.stroke
		round(bg,9)

		local knob = Instance.new("Frame",bg)
		knob.Size = UDim2.fromOffset(14,14)
		knob.Position = UDim2.fromOffset(2,2)
		knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
		round(knob,7)

		holder.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				state = not state
				tween(knob,{Position = state and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2)})
				tween(bg,{BackgroundColor3 = state and theme.accent or theme.stroke})
				cb(state)
			end
		end)
	end

	--// Button
	function window:AddButton(text,cb)
		local b = Instance.new("TextButton",container)
		b.Size = UDim2.new(1,0,0,28)
		b.BackgroundColor3 = theme.stroke
		b.Text = text
		b.Font = Enum.Font.Gotham
		b.TextSize = 14
		b.TextColor3 = theme.text
		round(b,8)
		b.MouseButton1Click:Connect(cb)
	end

	--// Box
	function window:AddBox(placeholder,cb)
		local box = Instance.new("TextBox",container)
		box.Size = UDim2.new(1,0,0,28)
		box.BackgroundColor3 = theme.stroke
		box.PlaceholderText = placeholder
		box.Text = ""
		box.Font = Enum.Font.Gotham
		box.TextSize = 14
		box.TextColor3 = theme.text
		round(box,8)
		box.FocusLost:Connect(function()
			cb(box)
		end)
	end

	return window
end

return library
