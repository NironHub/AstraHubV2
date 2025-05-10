-- Astra UI Script (Roblox Lua) 
-- Designed for executors (Synapse, Script-Ware, etc.)
-- Contains tweened animations, tabs, minimize/close, keybind, key system, notifications, and theme toggle.

-- Services
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration (customizable by editing values below)
local ToggleKey = Enum.KeyCode.RightControl  -- Key to toggle UI
local CreatorName = "CreatorName"            -- Name to display
local TitleText = "Astra UI"
local DarkTheme = {
    Background = Color3.fromRGB(28, 28, 28),
    Panel      = Color3.fromRGB(40, 40, 40),
    Accent     = Color3.fromRGB(100, 149, 237),  -- Teal/blue accent
    Text       = Color3.fromRGB(240, 240, 240),
}
local LightTheme = {
    Background = Color3.fromRGB(240, 240, 240),
    Panel      = Color3.fromRGB(200, 200, 200),
    Accent     = Color3.fromRGB(100, 149, 237),  -- Same accent
    Text       = Color3.fromRGB(20, 20, 20),
}
local CurrentTheme = DarkTheme  -- start in dark mode

-- Notification settings (user-editable)
local NotificationSettings = {
    BackgroundColor = Color3.fromRGB(30, 30, 30),
    TextColor       = Color3.fromRGB(245, 245, 245),
    Duration        = 3,  -- seconds
}

-- Helper: Apply colors for current theme to all GUI elements
local function applyTheme()
    -- Window background
    mainFrame.BackgroundColor3 = CurrentTheme.Panel
    titleBar.BackgroundColor3 = CurrentTheme.Background
    titleLabel.TextColor3 = CurrentTheme.Text
    creatorLabel.TextColor3 = CurrentTheme.Text
    -- Buttons
    for _, btn in ipairs({minimizeButton, closeButton, themeButton}) do
        btn.BackgroundColor3 = CurrentTheme.Panel
        btn.TextColor3 = CurrentTheme.Text
    end
    -- Tab buttons
    for _, tabBtn in ipairs(tabButtons:GetChildren()) do
        if tabBtn:IsA("TextButton") then
            tabBtn.BackgroundColor3 = CurrentTheme.Panel
            tabBtn.TextColor3 = CurrentTheme.Text
        end
    end
    -- Key system elements
    keyLabel.TextColor3 = CurrentTheme.Text
    keyInput.BackgroundColor3 = CurrentTheme.Panel
    keyInput.TextColor3 = CurrentTheme.Text
    copyButton.BackgroundColor3 = CurrentTheme.Accent
    copyButton.TextColor3 = CurrentTheme.Text
    -- Test tab elements
    toggleLabel.TextColor3 = CurrentTheme.Text
    toggleSwitchFrame.BackgroundColor3 = CurrentTheme.Panel
    toggleButton.BackgroundColor3 = Color3.fromRGB(150,150,150)
    testButton1.BackgroundColor3 = CurrentTheme.Accent
    testButton1.TextColor3 = CurrentTheme.Text
    testButton2.BackgroundColor3 = CurrentTheme.Accent
    testButton2.TextColor3 = CurrentTheme.Text
    -- Slider
    sliderBar.BackgroundColor3 = CurrentTheme.Panel
    sliderValueLabel.TextColor3 = CurrentTheme.Text
    -- Dropdown
    dropdownMain.BackgroundColor3 = CurrentTheme.Panel
    dropdownMainLabel.TextColor3 = CurrentTheme.Text
    for _, optionBtn in ipairs(dropdownOptions:GetChildren()) do
        if optionBtn:IsA("TextButton") then
            optionBtn.BackgroundColor3 = CurrentTheme.Background
            optionBtn.TextColor3 = CurrentTheme.Text
        end
    end
end

-- Toggle theme between dark and light
local function toggleTheme()
    if CurrentTheme == DarkTheme then
        CurrentTheme = LightTheme
        themeButton.Text = "☀️"
    else
        CurrentTheme = DarkTheme
        themeButton.Text = "🌙"
    end
    applyTheme()
end

-- Custom notification function
local function Notify(text, style)
    -- style can be "Success", "Error", etc. (choose icon)
    local icons = { Success = "✅", Error = "❌", Info = "ℹ️" }
    local icon = icons[style] or icons.Info

    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 300, 0, 50)
    notifFrame.Position = UDim2.new(0.5, -150, 0, -60)  -- start above screen
    notifFrame.BackgroundColor3 = NotificationSettings.BackgroundColor
    notifFrame.BorderSizePixel = 0
    notifFrame.Parent = ScreenGui

    local iconLabel = Instance.new("TextLabel", notifFrame)
    iconLabel.Size = UDim2.new(0, 40, 1, 0)
    iconLabel.Position = UDim2.new(0, 0, 0, 0)
    iconLabel.Text = icon
    iconLabel.Font = Enum.Font.SourceSans
    iconLabel.TextSize = 24
    iconLabel.TextColor3 = NotificationSettings.TextColor
    iconLabel.BackgroundTransparency = 1

    local textLabel = Instance.new("TextLabel", notifFrame)
    textLabel.Size = UDim2.new(1, -50, 1, 0)
    textLabel.Position = UDim2.new(0, 50, 0, 0)
    textLabel.Text = text
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextSize = 18
    textLabel.TextColor3 = NotificationSettings.TextColor
    textLabel.BackgroundTransparency = 1

    -- Animate in
    TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -150, 0, 20)}):Play()
    -- Wait and animate out
    delay(NotificationSettings.Duration, function()
        TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -150, 0, -60)}):Play()
        -- Destroy after animation
        delay(0.5, function() notifFrame:Destroy() end)
    end)
end

-- Create the ScreenGui and main window
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AstraUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

-- Main window frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = CurrentTheme.Panel
mainFrame.BorderSizePixel = 0
mainFrame.Parent = ScreenGui

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = CurrentTheme.Background
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = TitleText
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.TextColor3 = CurrentTheme.Text
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = titleBar

local creatorLabel = Instance.new("TextLabel")
creatorLabel.Name = "CreatorLabel"
creatorLabel.Size = UDim2.new(0.3, -10, 1, 0)
creatorLabel.Position = UDim2.new(0.7, 10, 0, 0)
creatorLabel.Text = CreatorName
creatorLabel.Font = Enum.Font.SourceSans
creatorLabel.TextSize = 18
creatorLabel.TextColor3 = CurrentTheme.Text
creatorLabel.TextXAlignment = Enum.TextXAlignment.Right
creatorLabel.BackgroundTransparency = 1
creatorLabel.Parent = titleBar

-- Title bar buttons: Theme toggle, Minimize, Close
themeButton = Instance.new("TextButton")
themeButton.Name = "ThemeButton"
themeButton.Size = UDim2.new(0, 30, 0, 30)
themeButton.Position = UDim2.new(1, -90, 0, 0)
themeButton.Text = "🌙"
themeButton.Font = Enum.Font.GothamBold
themeButton.TextSize = 18
themeButton.BackgroundColor3 = CurrentTheme.Panel
themeButton.BorderSizePixel = 0
themeButton.Parent = titleBar
themeButton.MouseButton1Click:Connect(toggleTheme)

minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -60, 0, 0)
minimizeButton.Text = "–"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 20
minimizeButton.TextColor3 = CurrentTheme.Text
minimizeButton.BackgroundColor3 = CurrentTheme.Panel
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = titleBar

closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.Text = "✕"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.TextColor3 = CurrentTheme.Text
closeButton.BackgroundColor3 = CurrentTheme.Panel
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

-- Content container (below title)
local contentContainer = Instance.new("Frame")
contentContainer.Name = "Content"
contentContainer.Size = UDim2.new(1, 0, 1, -30)
contentContainer.Position = UDim2.new(0, 0, 0, 30)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- Tab buttons panel
local tabButtons = Instance.new("Frame")
tabButtons.Name = "TabButtons"
tabButtons.Size = UDim2.new(0, 100, 1, 0)
tabButtons.Position = UDim2.new(0, 0, 0, 30)
tabButtons.BackgroundColor3 = CurrentTheme.Background
tabButtons.BorderSizePixel = 0
tabButtons.Parent = contentContainer

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.Parent = tabButtons
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0, 5)

-- Content pages container (rest of area)
local pagesContainer = Instance.new("Frame")
pagesContainer.Name = "Pages"
pagesContainer.Size = UDim2.new(1, -100, 1, 0)
pagesContainer.Position = UDim2.new(0, 100, 0, 0)
pagesContainer.BackgroundTransparency = 1
pagesContainer.Parent = contentContainer

-- Add UIPageLayout for animated tab pages
local pageLayout = Instance.new("UIPageLayout")
pageLayout.Parent = pagesContainer
pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
pageLayout.EasingStyle = Enum.EasingStyle.Quint
pageLayout.EasingDirection = Enum.EasingDirection.Out
pageLayout.Padding = UDim.new(0, 0)
pageLayout.Circular = false
pageLayout.TouchInputEnabled = false
pageLayout.GamepadInputEnabled = false
pageLayout.ScrollWheelInputEnabled = false
pageLayout.TweenTime = 0.3

-- Helper to create a tab
local function CreateTab(name)
    -- Tab button
    local btn = Instance.new("TextButton")
    btn.Name = name.."TabButton"
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.BackgroundColor3 = CurrentTheme.Panel
    btn.TextColor3 = CurrentTheme.Text
    btn.BorderSizePixel = 0
    btn.Parent = tabButtons

    -- Tab content frame (page)
    local frame = Instance.new("Frame")
    frame.Name = name.."Tab"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = CurrentTheme.Panel
    frame.BorderSizePixel = 0
    frame.Parent = pagesContainer

    -- Return both for further customization
    return btn, frame
end

-- Create "Home" and "Test" tabs
local homeButton, homeFrame = CreateTab("Home")
local testButton, testFrame = CreateTab("Test")

-- Tab button click handlers
homeButton.MouseButton1Click:Connect(function()
    pageLayout:JumpTo(homeFrame)
end)
testButton.MouseButton1Click:Connect(function()
    pageLayout:JumpTo(testFrame)
end)

-- Minimize/Close logic
local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    if not isMinimized then
        contentContainer.Visible = false
        minimizeButton.Text = "+"
        isMinimized = true
    else
        contentContainer.Visible = true
        minimizeButton.Text = "–"
        isMinimized = false
    end
end)
closeButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- Keybind to toggle GUI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == ToggleKey then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- === Home Tab UI ===
-- Key System UI
local keyLabel = Instance.new("TextLabel")
keyLabel.Text = "Enter Key:"
keyLabel.Font = Enum.Font.Gotham
keyLabel.TextSize = 16
keyLabel.TextColor3 = CurrentTheme.Text
keyLabel.BackgroundTransparency = 1
keyLabel.Size = UDim2.new(0, 100, 0, 25)
keyLabel.Position = UDim2.new(0, 10, 0, 10)
keyLabel.Parent = homeFrame

local keyInput = Instance.new("TextBox")
keyInput.PlaceholderText = "Paste your key here..."
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 16
keyInput.TextColor3 = CurrentTheme.Text
keyInput.BackgroundColor3 = CurrentTheme.Panel
keyInput.BackgroundTransparency = 0
keyInput.BorderSizePixel = 0
keyInput.Size = UDim2.new(0, 250, 0, 25)
keyInput.Position = UDim2.new(0, 120, 0, 10)
keyInput.Parent = homeFrame

local copyButton = Instance.new("TextButton")
copyButton.Text = "Copy Key"
copyButton.Font = Enum.Font.Gotham
copyButton.TextSize = 16
copyButton.TextColor3 = CurrentTheme.Text
copyButton.BackgroundColor3 = CurrentTheme.Accent
copyButton.BorderSizePixel = 0
copyButton.Size = UDim2.new(0, 100, 0, 25)
copyButton.Position = UDim2.new(0, 380, 0, 10)
copyButton.Parent = homeFrame

-- Copy to clipboard action
copyButton.MouseButton1Click:Connect(function()
    local keyText = keyInput.Text
    if keyText ~= "" then
        setclipboard(keyText)  -- executor function
        Notify("Key copied to clipboard!", "Success")
    else
        Notify("No key to copy.", "Error")
    end
end)

-- Submit key button (example)
local submitKey = Instance.new("TextButton")
submitKey.Text = "Submit Key"
submitKey.Font = Enum.Font.Gotham
submitKey.TextSize = 16
submitKey.TextColor3 = CurrentTheme.Text
submitKey.BackgroundColor3 = CurrentTheme.Accent
submitKey.BorderSizePixel = 0
submitKey.Size = UDim2.new(0, 100, 0, 25)
submitKey.Position = UDim2.new(0, 10, 0, 45)
submitKey.Parent = homeFrame

submitKey.MouseButton1Click:Connect(function()
    local keyText = keyInput.Text
    -- Dummy check: accept if matches "TestKey"
    if keyText == "TestKey" then
        Notify("Key accepted!", "Success")
    else
        Notify("Invalid key!", "Error")
    end
end)

-- === Test Tab UI ===
-- Toggle Switch
local toggleLabel = Instance.new("TextLabel")
toggleLabel.Text = "Demo Toggle"
toggleLabel.Font = Enum.Font.Gotham
toggleLabel.TextSize = 16
toggleLabel.TextColor3 = CurrentTheme.Text
toggleLabel.BackgroundTransparency = 1
toggleLabel.Size = UDim2.new(0, 100, 0, 25)
toggleLabel.Position = UDim2.new(0, 10, 0, 10)
toggleLabel.Parent = testFrame

local toggleSwitchFrame = Instance.new("Frame")
toggleSwitchFrame.Name = "ToggleSwitch"
toggleSwitchFrame.BackgroundColor3 = CurrentTheme.Panel
toggleSwitchFrame.Size = UDim2.new(0, 50, 0, 25)
toggleSwitchFrame.Position = UDim2.new(0, 120, 0, 10)
toggleSwitchFrame.Parent = testFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "Switch"
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleButton.Size = UDim2.new(0, 20, 0, 25)
toggleButton.Position = UDim2.new(0, 0, 0, 0)
toggleButton.Text = ""
toggleButton.Parent = toggleSwitchFrame

local isToggled = false
toggleButton.MouseButton1Click:Connect(function()
    if not isToggled then
        toggleButton:TweenPosition(UDim2.new(1, -20, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3)
        wait(0.3)
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        isToggled = true
    else
        toggleButton:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.3)
        wait(0.3)
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        isToggled = false
    end
end)

-- ScrollFrame example
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0, 200, 0, 100)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundColor3 = CurrentTheme.Panel
scrollFrame.BorderSizePixel = 0
scrollFrame.Parent = testFrame

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Parent = scrollFrame
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Padding = UDim.new(0, 5)

-- Add items to scroll frame
for i = 1, 10 do
    local item = Instance.new("TextLabel")
    item.Size = UDim2.new(1, -10, 0, 20)
    item.BackgroundColor3 = CurrentTheme.Background
    item.TextColor3 = CurrentTheme.Text
    item.Text = "Item "..i
    item.Font = Enum.Font.Gotham
    item.TextSize = 14
    item.Position = UDim2.new(0, 5, 0, 0)
    item.Parent = scrollFrame
end

-- Example Buttons
local testButton1 = Instance.new("TextButton")
testButton1.Text = "Button 1"
testButton1.Font = Enum.Font.Gotham
testButton1.TextSize = 16
testButton1.TextColor3 = CurrentTheme.Text
testButton1.BackgroundColor3 = CurrentTheme.Accent
testButton1.BorderSizePixel = 0
testButton1.Size = UDim2.new(0, 100, 0, 25)
testButton1.Position = UDim2.new(0, 220, 0, 50)
testButton1.Parent = testFrame

local testButton2 = Instance.new("TextButton")
testButton2.Text = "Button 2"
testButton2.Font = Enum.Font.Gotham
testButton2.TextSize = 16
testButton2.TextColor3 = CurrentTheme.Text
testButton2.BackgroundColor3 = CurrentTheme.Accent
testButton2.BorderSizePixel = 0
testButton2.Size = UDim2.new(0, 100, 0, 25)
testButton2.Position = UDim2.new(0, 220, 0, 85)
testButton2.Parent = testFrame

-- Slider
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Text = "Slider:"
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextSize = 16
sliderLabel.TextColor3 = CurrentTheme.Text
sliderLabel.BackgroundTransparency = 1
sliderLabel.Size = UDim2.new(0, 50, 0, 25)
sliderLabel.Position = UDim2.new(0, 10, 0, 160)
sliderLabel.Parent = testFrame

local sliderBar = Instance.new("Frame")
sliderBar.Name = "SliderBar"
sliderBar.BackgroundColor3 = CurrentTheme.Panel
sliderBar.Size = UDim2.new(0, 200, 0, 10)
sliderBar.Position = UDim2.new(0, 70, 0, 170)
sliderBar.BorderSizePixel = 0
sliderBar.Parent = testFrame

local sliderValueLabel = Instance.new("TextLabel")
sliderValueLabel.Text = "0%"
sliderValueLabel.Font = Enum.Font.Gotham
sliderValueLabel.TextSize = 14
sliderValueLabel.TextColor3 = CurrentTheme.Text
sliderValueLabel.BackgroundTransparency = 1
sliderValueLabel.Position = UDim2.new(0, 280, 0, 160)
sliderValueLabel.Size = UDim2.new(0, 50, 0, 25)
sliderValueLabel.Parent = testFrame

local indicator = Instance.new("Frame")
indicator.BackgroundColor3 = Color3.fromRGB(100,100,100)
indicator.Size = UDim2.new(0, 10, 1, 0)
indicator.Position = UDim2.new(0, 0, 0, 0)
indicator.Parent = sliderBar

-- Slider input handling
local dragging = false
local function updateSlider(inputX)
    local relativeX = math.clamp(inputX - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
    local percent = relativeX / sliderBar.AbsoluteSize.X
    indicator.Position = UDim2.new(percent, -5, 0, 0)
    sliderValueLabel.Text = math.floor(percent * 100).."%"
end

sliderBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        updateSlider(input.Position.X)
    end
end)
sliderBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
sliderBar.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSlider(input.Position.X)
    end
end)

-- Dropdown
local dropdownLabel = Instance.new("TextLabel")
dropdownLabel.Text = "Dropdown:"
dropdownLabel.Font = Enum.Font.Gotham
dropdownLabel.TextSize = 16
dropdownLabel.TextColor3 = CurrentTheme.Text
dropdownLabel.BackgroundTransparency = 1
dropdownLabel.Size = UDim2.new(0, 70, 0, 25)
dropdownLabel.Position = UDim2.new(0, 10, 0, 200)
dropdownLabel.Parent = testFrame

local dropdownMain = Instance.new("TextButton")
dropdownMain.Name = "DropdownMain"
dropdownMain.Text = "Select Option"
dropdownMain.Font = Enum.Font.Gotham
dropdownMain.TextSize = 16
dropdownMain.TextColor3 = CurrentTheme.Text
dropdownMain.BackgroundColor3 = CurrentTheme.Panel
dropdownMain.BorderSizePixel = 0
dropdownMain.Size = UDim2.new(0, 150, 0, 25)
dropdownMain.Position = UDim2.new(0, 90, 0, 200)
dropdownMain.Parent = testFrame

local dropdownOptions = Instance.new("Frame")
dropdownOptions.Name = "Options"
dropdownOptions.Size = UDim2.new(0, 150, 0, 75)
dropdownOptions.Position = UDim2.new(0, 90, 0, 225)
dropdownOptions.BackgroundColor3 = CurrentTheme.Panel
dropdownOptions.BorderSizePixel = 0
dropdownOptions.Visible = false
dropdownOptions.Parent = testFrame

local optionsLayout = Instance.new("UIListLayout")
optionsLayout.Parent = dropdownOptions
optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Option buttons
local optionNames = {"Option 1", "Option 2", "Option 3"}
for i, optName in ipairs(optionNames) do
    local optBtn = Instance.new("TextButton")
    optBtn.Size = UDim2.new(1, 0, 0, 25)
    optBtn.Text = optName
    optBtn.Font = Enum.Font.Gotham
    optBtn.TextSize = 14
    optBtn.TextColor3 = CurrentTheme.Text
    optBtn.BackgroundColor3 = CurrentTheme.Background
    optBtn.BorderSizePixel = 0
    optBtn.Parent = dropdownOptions
    optBtn.MouseButton1Click:Connect(function()
        dropdownMain.Text = optName
        dropdownOptions.Visible = false
    end)
end

-- Toggle dropdown visibility
dropdownMain.MouseButton1Click:Connect(function()
    dropdownOptions.Visible = not dropdownOptions.Visible
end)

-- Initial theme application
applyTheme()
