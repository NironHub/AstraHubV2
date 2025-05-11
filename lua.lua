-- Astra UI Framework for Roblox Executors
local Astra = {}

-- Services and utilities
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Utility to get Game services reliably
local function getService(name)
    local service = game:GetService(name)
    -- cloneref might be available in some executors for safe reuse
    if cloneref then
        return cloneref(service)
    else
        return service
    end
end

-- Utility to get asset URI (for image IDs or asset URLs)
local function getAssetURI(asset)
    if type(asset) == "number" then
        return "rbxassetid://" .. tostring(asset)
    elseif type(asset) == "string" then
        return asset
    end
    return ""
end

-- Icons support (e.g., Lucide). Placeholder for icon retrieval function.
local Icons = nil -- Optionally load a Lucide icon library if available
local function getIcon(name)
    if Icons then
        local data = Icons[name:lower()]
        if data then
            return { id = data[1], imageRectOffset = data[2], imageRectSize = data[3] }
        end
        error("Icon \"".. name .."\" not found in Lucide icons")
    else
        warn("Icons library not loaded; using default placeholders")
        return { id = 0, imageRectOffset = Vector2.new(0,0), imageRectSize = Vector2.new(0,0) }
    end
end

-- Default theme (colors, fonts, etc.)
Astra.Theme = {
    Default = {
        Background = Color3.fromRGB(30, 30, 30),
        Topbar = Color3.fromRGB(45, 45, 45),
        TextColor = Color3.fromRGB(255, 255, 255),
        -- Elements
        ElementBackground = Color3.fromRGB(50, 50, 50),
        ElementStroke = Color3.fromRGB(80, 80, 80),
        ElementHover = Color3.fromRGB(60, 60, 60),
        -- Special elements
        ToggleBackground = Color3.fromRGB(70, 70, 70),
        ToggleEnabled = Color3.fromRGB(0, 170, 85),
        ToggleDisabled = Color3.fromRGB(85, 85, 85),
        ToggleEnabledStroke = Color3.fromRGB(0, 120, 50),
        ToggleDisabledStroke = Color3.fromRGB(60, 60, 60),
        -- Slider specifics
        SliderBackground = Color3.fromRGB(70, 70, 70),
        SliderStroke = Color3.fromRGB(100, 100, 100),
        SliderProgress = Color3.fromRGB(0, 170, 85),
        -- Input background
        InputBackground = Color3.fromRGB(60, 60, 60),
        InputStroke = Color3.fromRGB(100, 100, 100)
    }
}

-- Function to create a new window
function Astra:CreateWindow(settings)
    settings = settings or {}
    local Window = {}
    Window.Name = settings.Name or "Astra Window"
    local themeName = settings.Theme or "Default"
    local selectedTheme = Astra.Theme[themeName] or Astra.Theme.Default
    -- Configuration saving
    local configEnabled = settings.ConfigurationSaving and settings.ConfigurationSaving.Enabled
    if configEnabled == nil then configEnabled = false end
    local configFolder = settings.ConfigurationSaving and settings.ConfigurationSaving.FolderName
    local configFileName = settings.ConfigurationSaving and settings.ConfigurationSaving.FileName
    if configEnabled then
        if not isfolder then
            warn("Configuration saving not supported in this environment.")
            configEnabled = false
        else
            configFolder = configFolder or "Astra"
            if not isfolder(configFolder) then makefolder(configFolder) end
            configFileName = configFileName or tostring(game.PlaceId)
        end
    end

    -- Create ScreenGui and main GUI structure
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = Window.Name .. "_GUI"
    ScreenGui.ResetOnSpawn = false
    -- Parent to CoreGui for executor compatibility
    ScreenGui.Parent = getService("CoreGui")

    -- Main container frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -250, 0.3, -200)
    MainFrame.BackgroundColor3 = selectedTheme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    local mainCorner = Instance.new("UICorner"); mainCorner.Parent = MainFrame; mainCorner.CornerRadius = UDim.new(0, 8)

    -- Topbar with title and icon support
    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 30)
    Topbar.BackgroundColor3 = selectedTheme.Topbar
    Topbar.BorderSizePixel = 0
    Topbar.Parent = MainFrame
    local topCorner = Instance.new("UICorner"); topCorner.Parent = Topbar; topCorner.CornerRadius = UDim.new(0, 8)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.Text = Window.Name
    TitleLabel.TextSize = 18
    TitleLabel.TextColor3 = selectedTheme.TextColor
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Topbar

    -- Tab list (left sidebar)
    local TabList = Instance.new("Frame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(0, 150, 1, -30)
    TabList.Position = UDim2.new(0, 0, 0, 30)
    TabList.BackgroundColor3 = selectedTheme.ElementBackground
    TabList.BorderSizePixel = 0
    TabList.Parent = MainFrame
    local tabCorner = Instance.new("UICorner"); tabCorner.Parent = TabList; tabCorner.CornerRadius = UDim.new(0, 8)
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = TabList
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Content pages (for each tab)
    local Pages = Instance.new("Frame")
    Pages.Name = "Pages"
    Pages.Size = UDim2.new(1, -150, 1, -30)
    Pages.Position = UDim2.new(0, 150, 0, 30)
    Pages.BackgroundTransparency = 1
    Pages.Parent = MainFrame
    local pageLayout = Instance.new("UIPageLayout")
    pageLayout.Parent = Pages
    pageLayout.FillDirection = Enum.FillDirection.Horizontal
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.EasingStyle = Enum.EasingStyle.Quint
    pageLayout.TweenTime = 0.5

    -- Loading frame overlay
    local LoadingOverlay = Instance.new("Frame")
    LoadingOverlay.Name = "Loading"
    LoadingOverlay.Size = UDim2.new(1, 0, 1, 0)
    LoadingOverlay.Position = UDim2.new(0, 0, 0, 0)
    LoadingOverlay.BackgroundColor3 = selectedTheme.ElementBackground
    LoadingOverlay.BorderSizePixel = 0
    LoadingOverlay.Parent = MainFrame
    LoadingOverlay.Visible = false
    local loadCorner = Instance.new("UICorner"); loadCorner.Parent = LoadingOverlay; loadCorner.CornerRadius = UDim.new(0, 8)
    local LoadTitle = Instance.new("TextLabel"); LoadTitle.Name = "Title"; LoadTitle.Size = UDim2.new(1, 0, 0, 25)
    LoadTitle.Position = UDim2.new(0, 0, 0, 10); LoadTitle.BackgroundTransparency = 1; LoadTitle.Font = Enum.Font.SourceSansBold
    LoadTitle.TextSize = 20; LoadTitle.TextColor3 = selectedTheme.TextColor; LoadTitle.Text = settings.LoadingTitle or "Loading..."
    LoadTitle.TextXAlignment = Enum.TextXAlignment.Center; LoadTitle.Parent = LoadingOverlay
    local LoadSub = Instance.new("TextLabel"); LoadSub.Name = "Subtitle"; LoadSub.Size = UDim2.new(1, 0, 0, 20)
    LoadSub.Position = UDim2.new(0, 0, 0, 35); LoadSub.BackgroundTransparency = 1; LoadSub.Font = Enum.Font.SourceSans
    LoadSub.TextSize = 16; LoadSub.TextColor3 = selectedTheme.TextColor; LoadSub.Text = settings.LoadingSubtitle or ""
    LoadSub.TextXAlignment = Enum.TextXAlignment.Center; LoadSub.Parent = LoadingOverlay
    local LoadVer = Instance.new("TextLabel"); LoadVer.Name = "Version"; LoadVer.Size = UDim2.new(1, 0, 0, 20)
    LoadVer.Position = UDim2.new(0, 0, 1, -30); LoadVer.BackgroundTransparency = 1; LoadVer.Font = Enum.Font.SourceSansItalic
    LoadVer.TextSize = 14; LoadVer.TextColor3 = selectedTheme.TextColor; LoadVer.Text = ""
    LoadVer.TextXAlignment = Enum.TextXAlignment.Center; LoadVer.Parent = LoadingOverlay

    -- Notifications container (top-right)
    local NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "Notifications"
    NotifHolder.Size = UDim2.new(0, 300, 0, 200)
    NotifHolder.Position = UDim2.new(1, -310, 0, 50)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.Parent = ScreenGui
    local notifLayout = Instance.new("UIListLayout")
    notifLayout.Parent = NotifHolder
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.Padding = UDim.new(0, 10)

    -- Internal flags table
    Window.Flags = {}
    Window.CurrentTab = nil

    -- Window methods
    -- Save configuration to file
    function Window:SaveConfiguration()
        if not configEnabled then return end
        local data = {}
        for flag, info in pairs(self.Flags) do
            if info.Type == "ColorPicker" then
                local c = info.Color
                data[flag] = {R=c.R*255, G=c.G*255, B=c.B*255}
            else
                data[flag] = info.CurrentValue or info.CurrentOption or info.CurrentKeybind
            end
        end
        local ok, json = pcall(function() return HttpService:JSONEncode(data) end)
        if ok and writefile then
            writefile(configFolder .. "/" .. configFileName .. ".json", json)
        end
    end

    -- Load configuration from file
    function Window:LoadConfiguration()
        if not configEnabled then return end
        if not isfolder(configFolder) then return end
        local path = configFolder .. "/" .. configFileName .. ".json"
        if not isfile(path) then return end
        local content = readfile(path)
        local ok, tbl = pcall(function() return HttpService:JSONDecode(content) end)
        if not ok or type(tbl) ~= "table" then return end
        for flag, val in pairs(tbl) do
            local element = self.Flags[flag]
            if element and element.Set then
                if element.Type == "ColorPicker" and type(val) == "table" then
                    element:Set(Color3.fromRGB(val.R, val.G, val.B))
                else
                    element:Set(val)
                end
            end
        end
    end

    -- Modify theme function
    function Window:ModifyTheme(themeName)
        local newTheme = Astra.Theme[themeName]
        if not newTheme then warn("Theme not found") return end
        selectedTheme = newTheme
        -- Update colors
        MainFrame.BackgroundColor3 = selectedTheme.Background
        Topbar.BackgroundColor3 = selectedTheme.Topbar
        TitleLabel.TextColor3 = selectedTheme.TextColor
        LoadTitle.TextColor3 = selectedTheme.TextColor
        LoadSub.TextColor3 = selectedTheme.TextColor
        LoadVer.TextColor3 = selectedTheme.TextColor
        TabList.BackgroundColor3 = selectedTheme.ElementBackground
        -- Iterate pages and elements to update colors
        for _, page in ipairs(Pages:GetChildren()) do
            if page:IsA("Frame") then
                for _, el in ipairs(page:GetChildren()) do
                    if el:IsA("TextButton") or el:IsA("Frame") then
                        local stroke = el:FindFirstChild("UIStroke")
                        if stroke then stroke.Color = selectedTheme.ElementStroke end
                        el.BackgroundColor3 = selectedTheme.ElementBackground
                        if el:IsA("TextButton") then el.TextColor3 = selectedTheme.TextColor end
                    elseif el:IsA("TextLabel") then
                        el.TextColor3 = selectedTheme.TextColor
                    end
                end
            end
        end
    end

    -- Notification system
    function Window:Notify(data)
        local title = data.Title or "Notification"
        local content = data.Content or ""
        local duration = data.Duration or 3
        local image = data.Image
        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(1, 0, 0, 60)
        notif.BackgroundColor3 = selectedTheme.ElementBackground
        notif.BorderSizePixel = 0
        local nc = Instance.new("UICorner"); nc.Parent = notif; nc.CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke"); stroke.Parent = notif; stroke.Color = selectedTheme.ElementStroke; stroke.Transparency = 0.5
        notif.LayoutOrder = #NotifHolder:GetChildren() + 1
        notif.Parent = NotifHolder
        -- Title label
        local titLbl = Instance.new("TextLabel")
        titLbl.Size = UDim2.new(1, -10, 0, 20)
        titLbl.Position = UDim2.new(0, 5, 0, 5)
        titLbl.BackgroundTransparency = 1
        titLbl.Font = Enum.Font.SourceSansBold
        titLbl.Text = title; titLbl.TextSize = 16
        titLbl.TextColor3 = selectedTheme.TextColor; titLbl.Parent = notif
        -- Content label
        local contLbl = Instance.new("TextLabel")
        contLbl.Size = UDim2.new(1, -10, 0, 20)
        contLbl.Position = UDim2.new(0, 5, 0, 25)
        contLbl.BackgroundTransparency = 1
        contLbl.Font = Enum.Font.SourceSans
        contLbl.Text = content; contLbl.TextSize = 14
        contLbl.TextColor3 = selectedTheme.TextColor; contLbl.TextWrapped = true; contLbl.Parent = notif
        -- Icon (if any)
        if image then
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 30, 0, 30)
            icon.Position = UDim2.new(0, 5, 0, 15)
            icon.BackgroundTransparency = 1
            if type(image) == "string" and Icons then
                local ico = getIcon(image)
                icon.Image = "rbxassetid://"..ico.id
                icon.ImageRectOffset = ico.imageRectOffset
                icon.ImageRectSize = ico.imageRectSize
            else
                icon.Image = getAssetURI(image)
            end
            icon.ImageColor3 = selectedTheme.TextColor
            icon.Parent = notif
            titLbl.Position = UDim2.new(0, 40, 0, 5); titLbl.Size = UDim2.new(1, -45, 0, 20)
            contLbl.Position = UDim2.new(0, 40, 0, 25); contLbl.Size = UDim2.new(1, -45, 0, 20)
        end
        -- Show notification with tween and auto destroy
        notif.Position = UDim2.new(0, 0, 0, -100)
        TweenService:Create(notif, TweenInfo.new(0.4), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        spawn(function()
            wait(duration)
            TweenService:Create(notif, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
            wait(0.5)
            notif:Destroy()
        end)
    end

    -- Tab creation
    function Window:CreateTab(name, icon)
        local Tab = {}
        -- Tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "_Button"
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundColor3 = selectedTheme.ElementBackground
        TabButton.BorderSizePixel = 0
        TabButton.Font = Enum.Font.SourceSans
        TabButton.Text = name
        TabButton.TextSize = 14
        TabButton.TextColor3 = selectedTheme.TextColor
        TabButton.LayoutOrder = #TabList:GetChildren() + 1
        TabButton.Parent = TabList
        local btnCorner = Instance.new("UICorner"); btnCorner.Parent = TabButton; btnCorner.CornerRadius = UDim.new(0, 4)
        -- Optional icon on tab (not fully implemented)
        if icon then
            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(0, 20, 0, 20)
            img.Position = UDim2.new(0, 5, 0, 5)
            img.BackgroundTransparency = 1
            if type(icon) == "string" and Icons then
                local ico = getIcon(icon)
                img.Image = "rbxassetid://"..ico.id
                img.ImageRectOffset = ico.imageRectOffset
                img.ImageRectSize = ico.imageRectSize
            else
                img.Image = getAssetURI(icon)
            end
            img.ImageColor3 = selectedTheme.TextColor
            img.Parent = TabButton
            TabButton.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Text = " "..name
        end
        -- Page for this tab
        local Page = Instance.new("Frame")
        Page.Name = name .. "_Page"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Parent = Pages
        -- Layout inside page
        local pageInnerLayout = Instance.new("UIListLayout")
        pageInnerLayout.Parent = Page
        pageInnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageInnerLayout.Padding = UDim.new(0, 5)
        -- Hide page by default; only show when tab selected
        Page.Visible = false
        -- On click: switch tab
        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab == TabButton then return end
            -- Deselect previous tab
            if Window.CurrentTab then
                Window.CurrentTab.BackgroundColor3 = selectedTheme.ElementBackground
                Window.CurrentTab.TextColor3 = selectedTheme.TextColor
            end
            -- Select this tab
            TabButton.BackgroundColor3 = selectedTheme.ElementHover
            TabButton.TextColor3 = selectedTheme.TextColor
            Window.CurrentTab = TabButton
            -- Show corresponding page
            pageLayout:JumpTo(Page)
        end)

        -- Show first tab by default
        if not Window.CurrentTab then
            Window.CurrentTab = TabButton
            TabButton.BackgroundColor3 = selectedTheme.ElementHover
            TabButton.TextColor3 = selectedTheme.TextColor
            Page.Visible = true
            pageLayout:JumpTo(Page)
        end

        -- Section (title)
        function Tab:CreateSection(sectionName)
            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Text = sectionName
            sectionLabel.Font = Enum.Font.SourceSansSemibold
            sectionLabel.TextSize = 16
            sectionLabel.TextColor3 = selectedTheme.TextColor
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.Parent = Page
            local sectionObj = {}
            function sectionObj:Set(newName)
                sectionLabel.Text = newName
            end
            return sectionObj
        end
        -- Divider (simple horizontal line)
        function Tab:CreateDivider()
            local Divider = Instance.new("Frame")
            Divider.Size = UDim2.new(1, 0, 0, 2)
            Divider.BackgroundColor3 = selectedTheme.ElementStroke
            Divider.BorderSizePixel = 0
            Divider.Parent = Page
            local divObj = {}
            function divObj:Set(val)
                Divider.Visible = val
            end
            return divObj
        end
        -- Label (text with optional icon and color)
        function Tab:CreateLabel(settings)
            local name = settings.Name or "Label"
            local color = settings.Color or selectedTheme.ElementBackground
            local icon = settings.Icon
            local labelFrame = Instance.new("Frame")
            labelFrame.Size = UDim2.new(1, 0, 0, 20)
            labelFrame.BackgroundColor3 = color
            labelFrame.BorderSizePixel = 0
            local lblCorner = Instance.new("UICorner"); lblCorner.Parent = labelFrame; lblCorner.CornerRadius = UDim.new(0, 4)
            labelFrame.Parent = Page
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1
            label.Text = name
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14
            label.TextColor3 = selectedTheme.TextColor
            label.Size = UDim2.new(1, -10, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = labelFrame
            -- Icon support
            if icon then
                local iconLbl = Instance.new("ImageLabel")
                iconLbl.Size = UDim2.new(0, 20, 0, 20)
                iconLbl.Position = UDim2.new(0, 5, 0, 0)
                iconLbl.BackgroundTransparency = 1
                if type(icon) == "string" and Icons then
                    local ico = getIcon(icon)
                    iconLbl.Image = "rbxassetid://"..ico.id
                    iconLbl.ImageRectOffset = ico.imageRectOffset
                    iconLbl.ImageRectSize = ico.imageRectSize
                else
                    iconLbl.Image = getAssetURI(icon)
                end
                iconLbl.ImageColor3 = selectedTheme.TextColor
                iconLbl.Parent = labelFrame
                label.Position = UDim2.new(0, 30, 0, 0)
                label.Size = UDim2.new(1, -35, 1, 0)
            end
            local labelObj = {}
            function labelObj:Set(newText, newIcon, newColor)
                label.Text = newText or label.Text
                if newColor then labelFrame.BackgroundColor3 = newColor end
                if newIcon then
                    if iconLbl then
                        if type(newIcon)=="string" and Icons then
                            local ico = getIcon(newIcon)
                            iconLbl.Image = "rbxassetid://"..ico.id
                            iconLbl.ImageRectOffset = ico.imageRectOffset
                            iconLbl.ImageRectSize = ico.imageRectSize
                        else
                            iconLbl.Image = getAssetURI(newIcon)
                        end
                    end
                end
            end
            return labelObj
        end
        -- Button element
        function Tab:CreateButton(settings)
            local name = settings.Name or "Button"
            local callback = settings.Callback or function() end
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = selectedTheme.ElementBackground
            btn.BorderSizePixel = 0
            btn.Font = Enum.Font.SourceSans
            btn.Text = name
            btn.TextSize = 14
            btn.TextColor3 = selectedTheme.TextColor
            btn.Parent = Page
            local btnCorner = Instance.new("UICorner"); btnCorner.Parent = btn; btnCorner.CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(function()
                local success, err = pcall(callback)
                if not success then
                    warn("Button callback error: " .. tostring(err))
                end
                if settings.Flag then
                    Window.Flags[settings.Flag] = settings
                end
                if configEnabled and settings.Flag then Window:SaveConfiguration() end
            end)
            local btnObj = {}
            function btnObj:Set(newName)
                btn.Text = newName
            end
            settings.Type = "Button"
            settings.CurrentValue = nil
            if settings.Flag then Window.Flags[settings.Flag] = settings end
            return btnObj
        end
        -- Toggle element
        function Tab:CreateToggle(settings)
            local name = settings.Name or "Toggle"
            local current = settings.CurrentValue or false
            local callback = settings.Callback or function(val) end
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(1, 0, 0, 30)
            toggleBtn.BackgroundColor3 = selectedTheme.ElementBackground
            toggleBtn.BorderSizePixel = 0
            toggleBtn.Font = Enum.Font.SourceSans
            toggleBtn.Text = name .. ": " .. (current and "ON" or "OFF")
            toggleBtn.TextSize = 14
            toggleBtn.TextColor3 = selectedTheme.TextColor
            toggleBtn.Parent = Page
            local togCorner = Instance.new("UICorner"); togCorner.Parent = toggleBtn; togCorner.CornerRadius = UDim.new(0, 4)
            local toggleObj = {}
            function toggleObj:Set(val)
                current = val
                settings.CurrentValue = val
                toggleBtn.Text = name .. ": " .. (val and "ON" or "OFF")
                pcall(callback, val)
                if configEnabled and settings.Flag then Window:SaveConfiguration() end
            end
            toggleBtn.MouseButton1Click:Connect(function()
                toggleObj:Set(not current)
            end)
            settings.Type = "Toggle"
            settings.CurrentValue = current
            if settings.Flag then Window.Flags[settings.Flag] = settings end
            return toggleObj
        end
        -- Color Picker element (simplified)
        function Tab:CreateColorPicker(settings)
            local name = settings.Name or "ColorPicker"
            local col = settings.Color or Color3.new(1,1,1)
            local callback = settings.Callback or function(color) end
            local cpBtn = Instance.new("TextButton")
            cpBtn.Size = UDim2.new(1, 0, 0, 30)
            cpBtn.BackgroundColor3 = col
            cpBtn.BorderSizePixel = 0
            cpBtn.Font = Enum.Font.SourceSans
            cpBtn.Text = name
            cpBtn.TextSize = 14
            cpBtn.TextColor3 = selectedTheme.TextColor
            cpBtn.Parent = Page
            local cpCorner = Instance.new("UICorner"); cpCorner.Parent = cpBtn; cpCorner.CornerRadius = UDim.new(0, 4)
            local colorObj = {}
            function colorObj:Set(newColor)
                col = newColor
                settings.Color = newColor
                cpBtn.BackgroundColor3 = newColor
                pcall(callback, newColor)
                if configEnabled and settings.Flag then Window:SaveConfiguration() end
            end
            cpBtn.MouseButton1Click:Connect(function()
                -- Placeholder: cycle some colors for demonstration
                local nextColor = Color3.fromHSV(math.random(), 1, 1)
                colorObj:Set(nextColor)
            end)
            settings.Type = "ColorPicker"
            settings.Color = col
            if settings.Flag then Window.Flags[settings.Flag] = settings end
            return colorObj
        end
        -- Slider element (with increment controls)
        function Tab:CreateSlider(settings)
            local name = settings.Name or "Slider"
            local minVal = settings.Range and settings.Range[1] or 0
            local maxVal = settings.Range and settings.Range[2] or 100
            local inc = settings.Increment or 1
            local suffix = settings.Suffix or ""
            local current = settings.CurrentValue or minVal
            local callback = settings.Callback or function(val) end
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 40)
            frame.BackgroundTransparency = 1
            frame.Parent = Page
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0, 20)
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.SourceSans
            title.Text = name
            title.TextSize = 14
            title.TextColor3 = selectedTheme.TextColor
            title.Parent = frame
            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(1, 0, 0, 20)
            valLbl.Position = UDim2.new(0, 0, 0, 20)
            valLbl.BackgroundTransparency = 1
            valLbl.Font = Enum.Font.SourceSans
            valLbl.Text = tostring(current) .. suffix
            valLbl.TextSize = 14
            valLbl.TextColor3 = selectedTheme.TextColor
            valLbl.Parent = frame
            local decBtn = Instance.new("TextButton")
            decBtn.Size = UDim2.new(0, 30, 0, 20)
            decBtn.Position = UDim2.new(0, 0, 1, -20)
            decBtn.Text = "-" decBtn.Font = Enum.Font.SourceSans decBtn.TextSize = 18
            decBtn.TextColor3 = selectedTheme.TextColor decBtn.Parent = frame
            local incBtn = Instance.new("TextButton")
            incBtn.Size = UDim2.new(0, 30, 0, 20)
            incBtn.Position = UDim2.new(0, 30, 1, -20)
            incBtn.Text = "+" incBtn.Font = Enum.Font.SourceSans incBtn.TextSize = 18
            incBtn.TextColor3 = selectedTheme.TextColor incBtn.Parent = frame
            local sliderObj = {}
            local function updateVal(v)
                current = math.clamp(v, minVal, maxVal)
                settings.CurrentValue = current
                valLbl.Text = tostring(current) .. suffix
                pcall(callback, current)
                if configEnabled and settings.Flag then Window:SaveConfiguration() end
            end
            decBtn.MouseButton1Click:Connect(function() updateVal(current - inc) end)
            incBtn.MouseButton1Click:Connect(function() updateVal(current + inc) end)
            function sliderObj:Set(val)
                updateVal(val)
            end
            settings.Type = "Slider"
            settings.CurrentValue = current
            if settings.Flag then Window.Flags[settings.Flag] = settings end
            return sliderObj
        end
        -- Text Input (TextBox)
        function Tab:CreateInput(settings)
            local name = settings.Name or "Input"
            local placeholder = settings.PlaceholderText or ""
            local removeOnFocusLost = settings.RemoveTextAfterFocusLost or false
            local current = settings.CurrentValue or ""
            local callback = settings.Callback or function(text) end
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 50)
            frame.BackgroundTransparency = 1
            frame.Parent = Page
            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1, 0, 0, 20)
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.SourceSans
            title.Text = name
            title.TextSize = 14
            title.TextColor3 = selectedTheme.TextColor
            title.Parent = frame
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -10, 0, 20)
            box.Position = UDim2.new(0, 5, 0, 25)
            box.Text = current
            box.PlaceholderText = placeholder
            box.ClearTextOnFocus = false
            box.BackgroundColor3 = selectedTheme.InputBackground
            box.TextColor3 = selectedTheme.TextColor
            box.BorderColor3 = selectedTheme.InputStroke
            box.Parent = frame
            local inputObj = {}
            box.FocusLost:Connect(function(enterPressed)
                if not enterPressed then return end
                local text = box.Text
                settings.CurrentValue = text
                local success, err = pcall(callback, text)
                if not success then warn("Input callback error: " .. tostring(err)) end
                if removeOnFocusLost then box.Text = "" end
                if configEnabled and settings.Flag then Window:SaveConfiguration() end
            end)
            function inputObj:Set(text)
                box.Text = text
                settings.CurrentValue = text
                pcall(callback, text)
                if configEnabled and settings.Flag then Window:SaveConfiguration() end
            end
            settings.Type = "Input"
            settings.CurrentValue = current
            if settings.Flag then Window.Flags[settings.Flag] = settings end
            return inputObj
        end
        -- Dropdown element
        function Tab:CreateDropdown(settings)
            local name = settings.Name or "Dropdown"
            local options = settings.Options or {}
            local current = settings.CurrentOption or (options[1] or "")
            local multi = settings.MultipleOptions or false
            local callback = settings.Callback or function(selection) end
            local dropBtn = Instance.new("TextButton")
            dropBtn.Size = UDim2.new(1, 0, 0, 30)
            dropBtn.BackgroundColor3 = selectedTheme.ElementBackground
            dropBtn.BorderSizePixel = 0
            dropBtn.Font = Enum.Font.SourceSans
            dropBtn.Text = name .. ": " .. (current or "None")
            dropBtn.TextSize = 14
            dropBtn.TextColor3 = selectedTheme.TextColor
            dropBtn.Parent = Page
            local ddCorner = Instance.new("UICorner"); ddCorner.Parent = dropBtn; ddCorner.CornerRadius = UDim.new(0, 4)
            local listFrame = Instance.new("Frame")
            listFrame.Size = UDim2.new(1, 0, 0, #options * 25)
            listFrame.Position = UDim2.new(0, 0, 0, 30)
            listFrame.BackgroundColor3 = selectedTheme.ElementBackground
            listFrame.BorderSizePixel = 0
            listFrame.Visible = false
            listFrame.Parent = Page
            local listLayout = Instance.new("UIListLayout"); listLayout.Parent = listFrame; listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            for i, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 25)
                optBtn.BackgroundColor3 = selectedTheme.ElementBackground
                optBtn.BorderSizePixel = 0
                optBtn.Font = Enum.Font.SourceSans
                optBtn.Text = tostring(opt)
                optBtn.TextSize = 14
                optBtn.TextColor3 = selectedTheme.TextColor
                optBtn.Parent = listFrame
                optBtn.MouseButton1Click:Connect(function()
                    if multi then
                        -- Multi-select not implemented: fallback to single
                        current = opt
                    else
                        current = opt
                        listFrame.Visible = false
                    end
                    dropBtn.Text = name .. ": " .. tostring(current)
                    settings.CurrentOption = current
                    pcall(callback, current)
                    if configEnabled and settings.Flag then Window:SaveConfiguration() end
                end)
            end
            dropBtn.MouseButton1Click:Connect(function() listFrame.Visible = not listFrame.Visible end)
            local ddObj = {}
            function ddObj:Set(selection)
                if table.find(options, selection) then
                    current = selection
                    settings.CurrentOption = selection
                    dropBtn.Text = name .. ": " .. tostring(selection)
                    pcall(callback, selection)
                    if configEnabled and settings.Flag then Window:SaveConfiguration() end
                end
            end
            function ddObj:Refresh(newOptions)
                options = newOptions or options
                -- Rebuild listFrame (not fully implemented)
            end
            settings.Type = "Dropdown"
            settings.CurrentOption = current
            if settings.Flag then Window.Flags[settings.Flag] = settings end
            return ddObj
        end
        -- Keybind element
        function Tab:CreateKeybind(settings)
            local name = settings.Name or "Keybind"
            local current = settings.CurrentKeybind or ""
            local callback = settings.Callback or function() end
            local kbLabel = Instance.new("TextButton")
            kbLabel.Size = UDim2.new(1, 0, 0, 30)
            kbLabel.BackgroundColor3 = selectedTheme.ElementBackground
            kbLabel.BorderSizePixel = 0
            kbLabel.Font = Enum.Font.SourceSans
            kbLabel.Text = name .. ": [" .. current .. "]"
            kbLabel.TextSize = 14
            kbLabel.TextColor3 = selectedTheme.TextColor
            kbLabel.Parent = Page
            local kbCorner = Instance.new("UICorner"); kbCorner.Parent = kbLabel; kbCorner.CornerRadius = UDim.new(0, 4)
            local capturing = false
            kbLabel.MouseButton1Click:Connect(function()
                capturing = true
                kbLabel.Text = name .. ": [Press Key]"
            end)
            local conn
            conn = UserInputService.InputBegan:Connect(function(input, processed)
                if capturing and not processed and input.UserInputType == Enum.UserInputType.Keyboard then
                    local keyName = input.KeyCode.Name
                    current = keyName
                    settings.CurrentKeybind = keyName
                    kbLabel.Text = name .. ": [" .. keyName .. "]"
                    capturing = false
                    pcall(callback, keyName)
                    if configEnabled and settings.Flag then Window:SaveConfiguration() end
                end
            end)
            local kbObj = {}
            function kbObj:Set(keyName)
                current = keyName
                settings.CurrentKeybind = keyName
                kbLabel.Text = name .. ": [" .. keyName .. "]"
                if configEnabled and settings.Flag then Window:SaveConfiguration() end
            end
            settings.Type = "Keybind"
            settings.CurrentKeybind = current
            if settings.Flag then Window.Flags[settings.Flag] = settings end
            return kbObj
        end

        return Tab
    end

    -- Get element value by flag
    function Window:GetValue(flag)
        local el = self.Flags[flag]
        if not el then return nil end
        return el.CurrentValue or el.CurrentOption or el.CurrentKeybind or nil
    end
    -- Destroy the window
    function Window:Destroy()
        ScreenGui:Destroy()
    end

    -- Finalize window creation
    Window.ScreenGui = ScreenGui
    return Window
end

return Astra
