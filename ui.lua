local library = {
    windowcount = 0;
}

local dragger = {};
local resizer = {};

do
    local mouse = game:GetService("Players").LocalPlayer:GetMouse();
    local inputService = game:GetService('UserInputService');
    local heartbeat = game:GetService("RunService").Heartbeat;

    function dragger.new(frame)
        local s, event = pcall(function()
            return frame.MouseEnter
        end)

        if s then
            frame.Active = true;

            event:Connect(function()
                local input = frame.InputBegan:Connect(function(key)
                    if key.UserInputType == Enum.UserInputType.MouseButton1 then
                        local objectPosition = Vector2.new(
                            mouse.X - frame.AbsolutePosition.X,
                            mouse.Y - frame.AbsolutePosition.Y
                        );
                        while heartbeat:Wait()
                            and inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                            frame:TweenPosition(
                                UDim2.new(
                                    0,
                                    mouse.X - objectPosition.X + (frame.Size.X.Offset * frame.AnchorPoint.X),
                                    0,
                                    mouse.Y - objectPosition.Y + (frame.Size.Y.Offset * frame.AnchorPoint.Y)
                                ),
                                'Out',
                                'Quad',
                                0.12,
                                true
                            );
                        end
                    end
                end)

                local leave;
                leave = frame.MouseLeave:Connect(function()
                    input:Disconnect();
                    leave:Disconnect();
                end)
            end)
        end
    end

    function resizer.new(p, s)
        p:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
            s.Size = UDim2.new(
                s.Size.X.Scale,
                s.Size.X.Offset,
                s.Size.Y.Scale,
                p.AbsoluteSize.Y
            );
        end)
    end
end

--// PREMIUM THEME
local defaults = {
    txtcolor = Color3.fromRGB(235, 235, 235),
    underline = Color3.fromRGB(0, 255, 170),
    barcolor = Color3.fromRGB(20, 20, 24),
    bgcolor = Color3.fromRGB(26, 26, 32),
    boxcolor = Color3.fromRGB(32, 32, 40),
    strokecolor = Color3.fromRGB(60, 60, 70),
    accent = Color3.fromRGB(0, 255, 170)
}

function library:Create(class, props)
    local object = Instance.new(class);
    for i, prop in next, props do
        if i ~= "Parent" then
            object[i] = prop;
        end
    end
    object.Parent = props.Parent;
    return object;
end

function library:CreateWindow(options)
    assert(options.text, "no name");
    local window = {
        count = 0;
        toggles = {},
        closed = false;
    }

    options = options or {};
    setmetatable(options, {__index = defaults})

    self.windowcount += 1;

    library.gui = library.gui or self:Create("ScreenGui", {
        Name = "UILibrary",
        Parent = game:GetService("CoreGui")
    })

    --// TOP BAR
    window.frame = self:Create("Frame", {
        Name = options.text;
        Parent = self.gui,
        Active = true,
        Size = UDim2.new(0, 220, 0, 36),
        Position = UDim2.new(0, 20 + ((240 * self.windowcount) - 240), 0, 20),
        BackgroundColor3 = options.barcolor,
        BorderSizePixel = 0;
    })

    self:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = window.frame})
    self:Create("UIStroke", {
        Color = options.strokecolor,
        Thickness = 1,
        Transparency = 0.4,
        Parent = window.frame
    })
    self:Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30,30,36)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(18,18,22))
        },
        Rotation = 90,
        Parent = window.frame
    })

    --// TITLE
    self:Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1;
        TextColor3 = options.txtcolor,
        TextSize = 16,
        Font = Enum.Font.GothamSemibold;
        TextXAlignment = Enum.TextXAlignment.Left;
        Text = options.text,
        Parent = window.frame,
    })

    --// TOGGLE BUTTON
    local togglebutton = self:Create("TextButton", {
        BackgroundTransparency = 1;
        Position = UDim2.new(1, -30, 0, 0),
        Size = UDim2.new(0, 30, 1, 0),
        Text = "–",
        TextSize = 20,
        TextColor3 = options.accent,
        Font = Enum.Font.GothamBold;
        Parent = window.frame,
    })

    --// BACKGROUND
    window.background = self:Create("Frame", {
        Parent = window.frame,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundColor3 = options.bgcolor,
        BorderSizePixel = 0,
        ClipsDescendants = true;
    })

    self:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = window.background})
    self:Create("UIStroke", {
        Color = options.strokecolor,
        Thickness = 1,
        Transparency = 0.5,
        Parent = window.background
    })

    --// CONTAINER
    window.container = self:Create('Frame', {
    Name = 'Container';
    Parent = window.background, -- IMPORTANT FIX
    BorderSizePixel = 0;
    BackgroundTransparency = 1;
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 1, 0),
    ClipsDescendants = false;
})


    self:Create("UIListLayout", {
        Parent = window.container,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    self:Create("UIPadding", {
        Parent = window.container,
        PaddingLeft = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 8)
    })

    dragger.new(window.frame)
    resizer.new(window.container, window.background);

    local function getSize()
        local y = 0
        for _, v in next, window.container:GetChildren() do
            if v:IsA("GuiObject") then
                y += v.AbsoluteSize.Y
            end
        end
        return UDim2.new(1, 0, 0, y + 12)
    end

    function window:Resize(tween, change)
        local size = change or getSize()
        if tween then
            self.background:TweenSize(size, "Out", "Sine", 0.4, true)
        else
            self.background.Size = size
        end
    end

    togglebutton.MouseButton1Click:Connect(function()
        window.closed = not window.closed
        togglebutton.Text = window.closed and "+" or "–"
        window:Resize(true, window.closed and UDim2.new(1,0,0,0) or nil)
    end)

    --// CONTROLS (VISUAL ONLY MODIFIED)
    function window:AddButton(text, callback)
        callback = callback or function() end

        local button = library:Create("TextButton", {
            Text = text,
            Size = UDim2.new(1, -10, 0, 24),
            BackgroundColor3 = options.boxcolor,
            TextColor3 = options.txtcolor,
            TextXAlignment = Left,
            TextSize = 15,
            Font = Enum.Font.Gotham,
            BorderSizePixel = 0,
            Parent = self.container
        })

        self:Create("UICorner", {CornerRadius = UDim.new(0,6), Parent = button})
        self:Create("UIStroke", {Color = options.strokecolor, Transparency = 0.6, Parent = button})

        button.MouseButton1Click:Connect(callback)
        self:Resize()
        return button
    end

    function window:AddLabel(text)
        local label = library:Create("TextLabel", {
            Text = text,
            Size = UDim2.new(1, -10, 0, 22),
            BackgroundTransparency = 1,
            TextColor3 = options.txtcolor,
            TextXAlignment = Left,
            TextSize = 15,
            Font = Enum.Font.Gotham,
            Parent = self.container
        })

        self:Resize()
        return label
    end

    return window
end

return library

