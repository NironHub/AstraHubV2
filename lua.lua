-- Astra UI Library (Enhanced)
local Astra = {}

-- Services
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Configuration
Astra.Flags = {}
Astra.LucideIcons = {
    ["alert-circle"] = "M12 8v4m0 4h.01M22 12a10 10 0 1 1-20 0 10 10 0 0 1 20 0z",
    ["rewind"] = "M11 19l-7-7 7-7m8 14l-7-7 7-7",
    -- Add more Lucide icons as needed
}

-- Helper functions
function Astra:Create(instanceType, properties)
    local obj = Instance.new(instanceType)
    for prop, val in pairs(properties or {}) do
        obj[prop] = val
    end
    return obj
end

function Astra:AddCorner(instance, radius)
    self:Create("UICorner", {
        Parent = instance,
        CornerRadius = UDim.new(0, radius or 8)
    })
end

function Astra:AddStroke(instance)
    self:Create("UIStroke", {
        Parent = instance,
        Thickness = 1,
        Color = Color3.fromRGB(0, 0, 0),
        Transparency = 0.8
    })
end

function Astra:MakeDraggable(dragRegion, target)
    local dragging, dragStart, startPos
    
    dragRegion.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragRegion.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Notification System
function Astra:Notify(options)
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 5
    local image = options.Image or nil
    
    -- Create notification frame
    local notification = self:Create("Frame", {
        Parent = self.ScreenGui,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -20, 0, 20),
        Size = UDim2.new(0, 300, 0, 80),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BackgroundTransparency = 0.2,
        ZIndex = 10
    })
    
    self:AddCorner(notification, 8)
    self:AddStroke(notification)
    
    -- Icon (supports both Lucide and Image IDs)
    if image then
        local iconFrame = self:Create("Frame", {
            Parent = notification,
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, 15, 0, 15),
            BackgroundTransparency = 1
        })
        
        if type(image) == "string" and self.LucideIcons[image] then
            -- Lucide icon
            local icon = self:Create("ImageLabel", {
                Parent = iconFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://7733765391", -- Blank canvas
                ImageColor3 = Color3.fromRGB(200, 200, 200)
            })
            
            local path = self.LucideIcons[image]
            local svg = string.format('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">%s</svg>', path)
            local encoded = HttpService:JSONEncode(svg)
            icon:SetAttribute("SVG", encoded)
        else
            -- Regular image
            self:Create("ImageLabel", {
                Parent = iconFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://"..tostring(image),
                ImageColor3 = Color3.fromRGB(200, 200, 200)
            })
        end
    end
    
    -- Title and content
    local textOffset = image and 55 or 15
    self:Create("TextLabel", {
        Parent = notification,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -textOffset, 0, 20),
        Position = UDim2.new(0, textOffset, 0, 15)
    })
    
    self:Create("TextLabel", {
        Parent = notification,
        Text = content,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -textOffset, 1, -35),
        Position = UDim2.new(0, textOffset, 0, 35)
    })
    
    -- Animation
    notification.Position = UDim2.new(1, 320, 0, 20)
    notification:TweenPosition(UDim2.new(1, -20, 0, 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    
    -- Auto-close after duration
    task.delay(duration, function()
        notification:TweenPosition(UDim2.new(1, 320, 0, 20), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.3, true, function()
            notification:Destroy()
        end)
    end)
    
    return notification
end

-- Tab System
function Astra:CreateTab(name)
    if not self.SideBar then return end
    
    -- Tab button
    local tabButton = self:Create("TextButton", {
        Parent = self.SideBar,
        Text = name,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        AutoButtonColor = false,
        Size = UDim2.new(1, -10, 0, 30)
    })
    
    self:AddCorner(tabButton, 6)
    
    -- Content frame
    local contentFrame = self:Create("Frame", {
        Parent = self.ContentArea,
        Name = name.."Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false
    })
    
    -- Layout for content
    local layout = self:Create("UIListLayout", {
        Parent = contentFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    self:Create("UIPadding", {
        Parent = contentFrame,
        PaddingLeft = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 5)
    })
    
    -- Tab management
    local tab = {
        Button = tabButton,
        Content = contentFrame,
        Elements = {}
    }
    
    -- Button interactions
    tabButton.MouseEnter:Connect(function()
        TweenService:Create(tabButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
    end)
    
    tabButton.MouseLeave:Connect(function()
        if not tab.Content.Visible then
            TweenService:Create(tabButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
        end
    end)
    
    tabButton.MouseButton1Click:Connect(function()
        -- Hide all other tabs
        for _, otherTab in pairs(self.Tabs) do
            otherTab.Content.Visible = false
            otherTab.Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end
        
        -- Show this tab
        contentFrame.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end)
    
    -- Store the tab
    self.Tabs[name] = tab
    
    -- Activate first tab if none are active
    if not self.ActiveTab then
        self.ActiveTab = name
        contentFrame.Visible = true
        tabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    end
    
    -- Tab methods
    function tab:CreateButton(options)
        local button = self:Create("TextButton", {
            Parent = self.Content,
            Text = options.Name or "Button",
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(230, 230, 230),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            Size = UDim2.new(1, -10, 0, 30),
            LayoutOrder = #self.Elements + 1
        })
        
        self:AddCorner(button, 6)
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
        end)
        
        button.MouseButton1Click:Connect(function()
            if options.Callback then
                options.Callback()
            end
        end)
        
        local element = {
            Type = "Button",
            Instance = button,
            Set = function(newText)
                button.Text = newText
            end,
            CurrentValue = button.Text
        }
        
        table.insert(self.Elements, element)
        if options.Flag then Astra.Flags[options.Flag] = element end
        
        return element
    end
    
    function tab:CreateToggle(options)
        local frame = self:Create("Frame", {
            Parent = self.Content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 30),
            LayoutOrder = #self.Elements + 1
        })
        
        local label = self:Create("TextLabel", {
            Parent = frame,
            Text = options.Name or "Toggle",
            Font = Enum.Font.Gotham,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(230, 230, 230),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.7, 0, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local toggleFrame = self:Create("Frame", {
            Parent = frame,
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -45, 0, 5),
            BackgroundColor3 = options.CurrentValue and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(100, 100, 100)
        })
        
        self:AddCorner(toggleFrame, 10)
        
        local toggleKnob = self:Create("Frame", {
            Parent = toggleFrame,
            Size = UDim2.new(0, 18, 0, 18),
            Position = options.CurrentValue and UDim2.new(0, 21, 0, 1) or UDim2.new(0, 1, 0, 1),
            BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        })
        
        self:AddCorner(toggleKnob, 9)
        
        local function updateToggle(value)
            if value then
                toggleKnob:TweenPosition(UDim2.new(0, 21, 0, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 130, 255)}):Play()
                TweenService:Create(toggleKnob, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            else
                toggleKnob:TweenPosition(UDim2.new(0, 1, 0, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
                TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
                TweenService:Create(toggleKnob, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}):Play()
            end
            
            if options.Callback then
                options.Callback(value)
            end
        end
        
        toggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateToggle(not options.CurrentValue)
                options.CurrentValue = not options.CurrentValue
            end
        end)
        
        local element = {
            Type = "Toggle",
            Instance = frame,
            Set = function(value)
                options.CurrentValue = value
                updateToggle(value)
            end,
            CurrentValue = options.CurrentValue
        }
        
        table.insert(self.Elements, element)
        if options.Flag then Astra.Flags[options.Flag] = element end
        
        return element
    end
    
    -- Add other element creation methods (Slider, Dropdown, etc.) similarly
    
    return tab
end

-- Initialize the library
function Astra:Init(options)
    self:CreateWindow(options.Title or "Astra UI", options.Size)
    return self
end

return Astra
