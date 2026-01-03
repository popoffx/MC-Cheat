local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
local UIConfig = {
    MainColor = Color3.fromRGB(25, 25, 25),
    SecondaryColor = Color3.fromRGB(35, 35, 35),
    AccentColor = Color3.fromRGB(0, 170, 255), -- Cyan/Blue Neon
    TextColor = Color3.fromRGB(240, 240, 240),
    Font = Enum.Font.GothamBold,
    CornerRadius = UDim.new(0, 8)
}

function Library:CreateWindow(options)
    local WindowName = options.text or "Script"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MidnightChasersUI"
    -- Attempt to parent to CoreGui for security, fallback to PlayerGui
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromOffset(220, 300) -- Auto resizing handled later
    MainFrame.Position = UDim2.fromScale(0.1, 0.1)
    MainFrame.BackgroundColor3 = UIConfig.MainColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UIConfig.CornerRadius
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = UIConfig.AccentColor
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    Stroke.Parent = MainFrame

    -- Title Bar
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -30, 0, 35)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = WindowName
    TitleLabel.TextColor3 = UIConfig.AccentColor
    TitleLabel.TextSize = 16
    TitleLabel.Font = UIConfig.Font
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = MainFrame
    
    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 35)
    MinBtn.Position = UDim2.new(1, -30, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "-"
    MinBtn.TextColor3 = UIConfig.TextColor
    MinBtn.TextSize = 20
    MinBtn.Font = UIConfig.Font
    MinBtn.Parent = MainFrame
    
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -20, 1, -40)
    Container.Position = UDim2.new(0, 10, 0, 35)
    Container.BackgroundTransparency = 1
    Container.ClipsDescendants = true
    Container.Parent = MainFrame
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 6)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = Container

    -- Auto Resize function
    local function Resize()
        local ContentSize = UIList.AbsoluteContentSize.Y
        local TargetSize = UDim2.fromOffset(220, ContentSize + 50)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = TargetSize}):Play()
    end
    UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Resize)

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then update(input) end end)

    -- Minimize Logic
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Container.Visible = false
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.fromOffset(220, 35)}):Play()
            MinBtn.Text = "+"
        else
            Container.Visible = true
            Resize()
            MinBtn.Text = "-"
        end
    end)

    local Elements = {}

    -- Function: Add Box
    function Elements:AddBox(text, callback)
        local BoxFrame = Instance.new("Frame")
        BoxFrame.Size = UDim2.new(1, 0, 0, 35)
        BoxFrame.BackgroundColor3 = UIConfig.SecondaryColor
        BoxFrame.BorderSizePixel = 0
        BoxFrame.Parent = Container
        Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 6)
        
        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(1, 0, 1, 0)
        TextBox.BackgroundTransparency = 1
        TextBox.Text = ""
        TextBox.PlaceholderText = text
        TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        TextBox.TextColor3 = UIConfig.TextColor
        TextBox.Font = Enum.Font.GothamMedium
        TextBox.TextSize = 14
        TextBox.Parent = BoxFrame
        
        TextBox.FocusLost:Connect(function()
            pcall(callback, TextBox, true)
        end)
        Resize()
    end

    -- Function: Add Toggle
    function Elements:AddToggle(text, callback)
        local isEnabled = false
        local ToggleFrame = Instance.new("TextButton") -- Using button for easier clicking
        ToggleFrame.Text = ""
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.BackgroundTransparency = 1
        ToggleFrame.Parent = Container
        
        local Label = Instance.new("TextLabel")
        Label.Text = text
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = UIConfig.TextColor
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame
        
        local SwitchBg = Instance.new("Frame")
        SwitchBg.Size = UDim2.new(0, 40, 0, 20)
        SwitchBg.AnchorPoint = Vector2.new(0, 0.5)
        SwitchBg.Position = UDim2.new(1, -45, 0.5, 0)
        SwitchBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SwitchBg.Parent = ToggleFrame
        Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
        
        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 16, 0, 16)
        Circle.AnchorPoint = Vector2.new(0, 0.5)
        Circle.Position = UDim2.new(0, 2, 0.5, 0)
        Circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        Circle.Parent = SwitchBg
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
        
        ToggleFrame.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            callback(isEnabled)
            
            local targetPos = isEnabled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            local targetColor = isEnabled and UIConfig.AccentColor or Color3.fromRGB(50, 50, 50)
            local circleColor = isEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = circleColor}):Play()
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        end)
        Resize()
    end
    
    -- Function: Add Button
    function Elements:AddButton(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 30)
        Btn.BackgroundColor3 = UIConfig.SecondaryColor
        Btn.Text = text
        Btn.TextColor3 = UIConfig.TextColor
        Btn.Font = Enum.Font.GothamMedium
        Btn.TextSize = 14
        Btn.Parent = Container
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        
        Btn.MouseButton1Click:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = UIConfig.AccentColor}):Play()
            task.wait(0.1)
            TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = UIConfig.SecondaryColor}):Play()
            callback()
        end)
        Resize()
    end

    -- Initial Resize
    Resize()
    return Elements
end

return Library
