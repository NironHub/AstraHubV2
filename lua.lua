-- Custom UI Library (Rayfield Alternative)
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local CustomUI = {}
CustomUI.__index = CustomUI

-- Default Theme
local Theme = {
    MainColor = Color3.fromRGB(25, 25, 25),
    SecondaryColor = Color3.fromRGB(35, 35, 35),
    AccentColor = Color3.fromRGB(0, 120, 215),
    TextColor = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Gotham,
}

-- Create a new UI Window
function CustomUI:CreateWindow(options)
    local Window = {}
    options = options or {}
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "CustomUIWindow"
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.MainColor
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Theme.SecondaryColor
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = options.Name or "Custom UI"
    Title.Font = Theme.Font
    Title.TextColor3 = Theme.TextColor
    Title.TextSize = 16
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(1, -10, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Text = "X"
    CloseButton.Font = Theme.Font
    CloseButton.TextColor3 = Theme.TextColor
    CloseButton.TextSize = 16
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Parent = TitleBar
    
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame:Destroy()
    end)
    
    -- Draggable Window
    local Dragging
    local DragInput
    local DragStart
    local StartPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
    
    -- Tab System
    function Window:CreateTab(name)
        local Tab = {}
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.Text = name
        TabButton.Font = Theme.Font
        TabButton.TextColor3 = Theme.TextColor
        TabButton.TextSize = 14
        TabButton.Size = UDim2.new(0, 100, 0, 30)
        TabButton.BackgroundColor3 = Theme.SecondaryColor
        TabButton.BorderSizePixel = 0
        TabButton.Parent = TitleBar
        
        local TabFrame = Instance.new("Frame")
        TabFrame.Name = name .. "Tab"
        TabFrame.Size = UDim2.new(1, -20, 1, -60)
        TabFrame.Position = UDim2.new(0, 10, 0, 40)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.Parent = MainFrame
        
        TabButton.MouseButton1Click:Connect(function()
            for _, child in ipairs(MainFrame:GetChildren()) do
                if child:IsA("Frame") and child.Name:find("Tab") then
                    child.Visible = false
                end
            end
            TabFrame.Visible = true
        end)
        
        function Tab:CreateButton(options)
            local Button = Instance.new("TextButton")
            Button.Name = options.Name or "Button"
            Button.Text = options.Name or "Click Me"
            Button.Font = Theme.Font
            Button.TextColor3 = Theme.TextColor
            Button.TextSize = 14
            Button.Size = UDim2.new(1, 0, 0, 30)
            Button.Position = UDim2.new(0, 0, 0, #TabFrame:GetChildren() * 35)
            Button.BackgroundColor3 = Theme.SecondaryColor
            Button.BorderSizePixel = 0
            Button.Parent = TabFrame
            
            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = Button
            
            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.AccentColor}):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.SecondaryColor}):Play()
            end)
            
            Button.MouseButton1Click:Connect(function()
                if options.Callback then
                    options.Callback()
                end
            end)
        end
        
        return Tab
    end
    
    -- Notification System
    function Window:Notify(options)
        local NotifyFrame = Instance.new("Frame")
        NotifyFrame.Name = "Notification"
        NotifyFrame.Size = UDim2.new(0, 300, 0, 80)
        NotifyFrame.Position = UDim2.new(1, -310, 1, -90)
        NotifyFrame.BackgroundColor3 = Theme.MainColor
        NotifyFrame.BorderSizePixel = 0
        NotifyFrame.Parent = MainFrame.Parent
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = NotifyFrame
        
        local Title = Instance.new("TextLabel")
        Title.Text = options.Title or "Notification"
        Title.Font = Theme.Font
        Title.TextColor3 = Theme.TextColor
        Title.TextSize = 16
        Title.Position = UDim2.new(0, 10, 0, 5)
        Title.Size = UDim2.new(1, -10, 0, 20)
        Title.BackgroundTransparency = 1
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = NotifyFrame
        
        local Message = Instance.new("TextLabel")
        Message.Text = options.Content or "This is a notification."
        Message.Font = Theme.Font
        Message.TextColor3 = Theme.TextColor
        Message.TextSize = 14
        Message.Position = UDim2.new(0, 10, 0, 30)
        Message.Size = UDim2.new(1, -10, 1, -40)
        Message.BackgroundTransparency = 1
        Message.TextXAlignment = Enum.TextXAlignment.Left
        Message.TextYAlignment = Enum.TextYAlignment.Top
        Message.Parent = NotifyFrame
        
        task.delay(options.Duration or 5, function()
            TweenService:Create(NotifyFrame, TweenInfo.new(0.5), {Position = UDim2.new(1, 310, 1, -90)}):Play()
            task.wait(0.5)
            NotifyFrame:Destroy()
        end)
    end
    
    MainFrame.Parent = game:GetService("CoreGui")
    return Window
end

return CustomUI
