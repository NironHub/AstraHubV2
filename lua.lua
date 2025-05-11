local NexusUI = {}
NexusUI.__index = NexusUI

-- Service declarations
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Default configuration
local DEFAULT_CONFIG = {
    Theme = "Dark",
    PrimaryColor = Color3.fromRGB(0, 144, 255),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    EnableDragging = true,
    ToggleKey = Enum.KeyCode.RightShift,
    ConfigAutoSave = false,
    ConfigFileName = "NexusUI_Settings"
}

-- Visual theme configurations
local UI_THEMES = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 35),
        Header = Color3.fromRGB(40, 40, 45),
        Element = Color3.fromRGB(50, 50, 60),
        ElementHover = Color3.fromRGB(65, 65, 75),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Divider = Color3.fromRGB(70, 70, 80)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Header = Color3.fromRGB(230, 230, 230),
        Element = Color3.fromRGB(255, 255, 255),
        ElementHover = Color3.fromRGB(240, 240, 240),
        TextPrimary = Color3.fromRGB(40, 40, 40),
        TextSecondary = Color3.fromRGB(100, 100, 100),
        Divider = Color3.fromRGB(220, 220, 220)
    }
}

-- Element templates container
local ELEMENT_TEMPLATES = {}

function NexusUI.new(config)
    local self = setmetatable({}, NexusUI)
    self.config = setmetatable(config or {}, {__index = DEFAULT_CONFIG})
    self.elements = {}
    self.windows = {}
    self.currentTheme = UI_THEMES[self.config.Theme]
    
    -- Initialize core UI container
    self.container = Instance.new("ScreenGui")
    self.container.Name = "NexusUI_Root"
    self.container.ResetOnSpawn = false
    self.container.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.container.Parent = game:GetService("CoreGui")
    
    -- Setup notification system
    self.notificationQueue = {}
    self.activeNotifications = {}
    
    return self
end

--[[ Window Management ]]--
function NexusUI:CreateWindow(title)
    local window = {
        Title = title,
        Tabs = {},
        Elements = {}
    }
    
    -- Window frame
    local windowFrame = Instance.new("Frame")
    windowFrame.Size = UDim2.new(0, 500, 0, 400)
    windowFrame.BackgroundColor3 = self.currentTheme.Background
    windowFrame.Position = self.config.Position
    windowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    windowFrame.Parent = self.container
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = self.currentTheme.Header
    
    -- Dragging logic
    if self.config.EnableDragging then
        local dragInput, dragStart, startPos
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragStart = input.Position
                startPos = windowFrame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragStart = nil
                    end
                end)
            end
        end)
        
        header.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragStart then
                local delta = input.Position - dragStart
                windowFrame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
            end
        end)
    end
    
    -- Tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 1, -40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundTransparency = 1
    
    window.frame = windowFrame
    window.tabContainer = tabContainer
    table.insert(self.windows, window)
    
    return window
end

--[[ UI Element: Button ]]--
function NexusUI:CreateButton(parent, config)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 0)
    button.BackgroundColor3 = self.currentTheme.Element
    button.TextColor3 = self.currentTheme.TextPrimary
    button.Text = config.Text
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = parent
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.currentTheme.ElementHover
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.currentTheme.Element
        }):Play()
    end)
    
    -- Click handler
    if config.Callback then
        button.MouseButton1Click:Connect(config.Callback)
    end
    
    return {
        Update = function(newText)
            button.Text = newText
        end
    }
end

--[[ UI Element: Toggle Switch ]]--
function NexusUI:CreateToggle(parent, config)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, -20, 0, 30)
    toggle.BackgroundTransparency = 1
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 50, 0, 24)
    track.Position = UDim2.new(1, -60, 0.5, -12)
    track.BackgroundColor3 = self.currentTheme.Element
    track.Parent = toggle
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 20, 0, 20)
    thumb.Position = UDim2.new(0, 2, 0.5, -10)
    thumb.BackgroundColor3 = self.currentTheme.TextPrimary
    thumb.Parent = track
    
    local state = config.Default or false
    local function updateVisual()
        TweenService:Create(thumb, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        }):Play()
        TweenService:Create(track, TweenInfo.new(0.2), {
            BackgroundColor3 = state and self.config.PrimaryColor or self.currentTheme.Element
        }):Play()
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            updateVisual()
            if config.Callback then config.Callback(state) end
        end
    end)
    
    updateVisual()
    toggle.Parent = parent
    
    return {
        SetState = function(newState)
            state = newState
            updateVisual()
        end
    }
end

--[[ UI Element: Slider ]]--
function NexusUI:CreateSlider(parent, config)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -20, 0, 50)
    slider.BackgroundTransparency = 1
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0.5, -2)
    track.BackgroundColor3 = self.currentTheme.Element
    track.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = self.config.PrimaryColor
    fill.Parent = track
    
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.BackgroundColor3 = self.currentTheme.TextPrimary
    thumb.Position = UDim2.new(0, -8, 0.5, -8)
    thumb.Parent = track
    
    local min = config.Min or 0
    local max = config.Max or 100
    local value = math.clamp(config.Default or min, min, max)
    
    local function updateVisual()
        local ratio = (value - min) / (max - min)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        thumb.Position = UDim2.new(ratio, -8, 0.5, -8)
    end
    
    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    track.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local xPos = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            value = math.floor(min + (max - min) * math.clamp(xPos, 0, 1))
            updateVisual()
            if config.Callback then config.Callback(value) end
        end
    end)
    
    updateVisual()
    slider.Parent = parent
    
    return {
        SetValue = function(newValue)
            value = math.clamp(newValue, min, max)
            updateVisual()
        end
    }
end

--[[ UI Element: Dropdown ]]--
function NexusUI:CreateDropdown(parent, config)
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, -20, 0, 30)
    dropdown.BackgroundColor3 = self.currentTheme.Element
    dropdown.Parent = parent
    
    local currentValue = Instance.new("TextLabel")
    currentValue.Size = UDim2.new(1, -40, 1, 0)
    currentValue.Text = config.Default or "Select..."
    currentValue.TextColor3 = self.currentTheme.TextPrimary
    currentValue.Font = Enum.Font.GothamMedium
    currentValue.TextSize = 14
    currentValue.Parent = dropdown
    
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 1, 5)
    optionsFrame.BackgroundColor3 = self.currentTheme.Element
    optionsFrame.Visible = false
    
    local function toggleOptions()
        optionsFrame.Visible = not optionsFrame.Visible
        TweenService:Create(optionsFrame, TweenInfo.new(0.2), {
            Size = optionsFrame.Visible and UDim2.new(1, 0, 0, #config.Options * 30) or UDim2.new(1, 0, 0, 0)
        }):Play()
    end
    
    for i, option in ipairs(config.Options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.Position = UDim2.new(0, 0, 0, (i-1)*30)
        optionButton.Text = option
        optionButton.TextColor3 = self.currentTheme.TextPrimary
        optionButton.BackgroundColor3 = self.currentTheme.Element
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = self.currentTheme.ElementHover
        end)
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = self.currentTheme.Element
        end)
        optionButton.MouseButton1Click:Connect(function()
            currentValue.Text = option
            toggleOptions()
            if config.Callback then config.Callback(option) end
        end)
        optionButton.Parent = optionsFrame
    end
    
    dropdown.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggleOptions()
        end
    end)
    
    optionsFrame.Parent = dropdown
    return {
        SetOptions = function(newOptions)
            -- Update logic for dynamic options
        end
    }
end

--[[ Notification System ]]--
function NexusUI:Notify(notification)
    local noteFrame = Instance.new("Frame")
    noteFrame.Size = UDim2.new(0, 300, 0, 60)
    noteFrame.BackgroundColor3 = self.currentTheme.Element
    noteFrame.Position = UDim2.new(1, 20, 0.8, 0)
    noteFrame.AnchorPoint = Vector2.new(1, 0)
    
    -- Notification animation
    TweenService:Create(noteFrame, TweenInfo.new(0.3), {
        Position = UDim2.new(1, -20, 0.8, 0)
    }):Play()
    
    task.delay(notification.Duration or 5, function()
        TweenService:Create(noteFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 20, 0.8, 0)
        }):Play()
        task.wait(0.3)
        noteFrame:Destroy()
    end)
end

--[[ Configuration Handling ]]--
function NexusUI:SaveConfig()
    if not self.config.ConfigAutoSave then return end
    
    local saveData = {
        Theme = self.config.Theme,
        Position = self.container.Position
    }
    
    if isfolder and writefile then
        if not isfolder(self.config.ConfigFileName) then
            makefolder(self.config.ConfigFileName)
        end
        writefile(self.config.ConfigFileName.."/settings.json", HttpService:JSONEncode(saveData))
    end
end

function NexusUI:LoadConfig()
    if readfile and isfile then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(self.config.ConfigFileName.."/settings.json"))
        end)
        if success then
            self.config.Theme = data.Theme
            self.container.Position = data.Position
        end
    end
end

return NexusUI
