-- Advanced Ban Panel System for Roblox
-- Place this in ServerScriptService

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

-- Configuration
local CONFIG = {
    ADMIN_RANKS = {1, 2, 3}, -- Group ranks that can use ban panel
    ADMIN_USER_IDS = {4134725743}, -- Specific user IDs that can use ban panel
    BAN_DATASTORE_NAME = "PlayerBans_v2",
    ENABLE_WEBHOOK = false, -- Set to true and add webhook URL for Discord logging
    WEBHOOK_URL = "", -- Your Discord webhook URL
}

-- Services and Variables
local BanDataStore = DataStoreService:GetDataStore(CONFIG.BAN_DATASTORE_NAME)
local activeBans = {}

-- Ban Panel GUI Creation
local function createBanPanel(player)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminBanPanel"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    
    -- Main Frame (Initially hidden off-screen)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 500)
    mainFrame.Position = UDim2.new(0.5, 0, -1, 0) -- Start off-screen
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Add gradient and glow effects
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(70, 130, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = mainFrame
    
    -- Animated glow effect
    local glowFrame = Instance.new("Frame")
    glowFrame.Name = "GlowFrame"
    glowFrame.Size = UDim2.new(1, 20, 1, 20)
    glowFrame.Position = UDim2.new(0, -10, 0, -10)
    glowFrame.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    glowFrame.BackgroundTransparency = 0.9
    glowFrame.BorderSizePixel = 0
    glowFrame.ZIndex = -1
    glowFrame.Parent = mainFrame
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 20)
    glowCorner.Parent = glowFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    local headerBottom = Instance.new("Frame")
    headerBottom.Size = UDim2.new(1, 0, 0, 15)
    headerBottom.Position = UDim2.new(0, 0, 1, -15)
    headerBottom.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    headerBottom.BorderSizePixel = 0
    headerBottom.Parent = header
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🛡️ ADVANCED BAN PANEL"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = header
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    -- Content Frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -40, 1, -100)
    contentFrame.Position = UDim2.new(0, 20, 0, 80)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 8
    contentFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 130, 255)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    contentFrame.Parent = mainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 15)
    contentLayout.Parent = contentFrame
    
    -- Player Selection
    local playerSection = Instance.new("Frame")
    playerSection.Name = "PlayerSection"
    playerSection.Size = UDim2.new(1, 0, 0, 100)
    playerSection.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    playerSection.BorderSizePixel = 0
    playerSection.LayoutOrder = 1
    playerSection.Parent = contentFrame
    
    local playerCorner = Instance.new("UICorner")
    playerCorner.CornerRadius = UDim.new(0, 10)
    playerCorner.Parent = playerSection
    
    local playerLabel = Instance.new("TextLabel")
    playerLabel.Size = UDim2.new(1, 0, 0, 30)
    playerLabel.Position = UDim2.new(0, 15, 0, 10)
    playerLabel.BackgroundTransparency = 1
    playerLabel.Text = "👤 Target Player"
    playerLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    playerLabel.TextScaled = true
    playerLabel.TextXAlignment = Enum.TextXAlignment.Left
    playerLabel.Font = Enum.Font.GothamBold
    playerLabel.Parent = playerSection
    
    local playerInput = Instance.new("TextBox")
    playerInput.Name = "PlayerInput"
    playerInput.Size = UDim2.new(1, -30, 0, 35)
    playerInput.Position = UDim2.new(0, 15, 0, 45)
    playerInput.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    playerInput.BorderSizePixel = 0
    playerInput.Text = ""
    playerInput.PlaceholderText = "Enter player name or UserID..."
    playerInput.TextColor3 = Color3.new(1, 1, 1)
    playerInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    playerInput.TextScaled = true
    playerInput.Font = Enum.Font.Gotham
    playerInput.Parent = playerSection
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = playerInput
    
    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = Color3.fromRGB(70, 130, 255)
    inputStroke.Thickness = 1
    inputStroke.Transparency = 0.7
    inputStroke.Parent = playerInput
    
    -- Ban Type Selection
    local banTypeSection = Instance.new("Frame")
    banTypeSection.Name = "BanTypeSection"
    banTypeSection.Size = UDim2.new(1, 0, 0, 120)
    banTypeSection.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    banTypeSection.BorderSizePixel = 0
    banTypeSection.LayoutOrder = 2
    banTypeSection.Parent = contentFrame
    
    local banTypeCorner = Instance.new("UICorner")
    banTypeCorner.CornerRadius = UDim.new(0, 10)
    banTypeCorner.Parent = banTypeSection
    
    local banTypeLabel = Instance.new("TextLabel")
    banTypeLabel.Size = UDim2.new(1, 0, 0, 30)
    banTypeLabel.Position = UDim2.new(0, 15, 0, 10)
    banTypeLabel.BackgroundTransparency = 1
    banTypeLabel.Text = "⚡ Ban Type"
    banTypeLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    banTypeLabel.TextScaled = true
    banTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
    banTypeLabel.Font = Enum.Font.GothamBold
    banTypeLabel.Parent = banTypeSection
    
    -- Ban type buttons
    local banTypes = {
        {name = "Temporary", color = Color3.fromRGB(255, 165, 0), icon = "⏰"},
        {name = "Permanent", color = Color3.fromRGB(255, 70, 70), icon = "🚫"},
        {name = "Warning", color = Color3.fromRGB(255, 255, 70), icon = "⚠️"}
    }
    
    local selectedBanType = "Temporary"
    local banTypeButtons = {}
    
    for i, banType in ipairs(banTypes) do
        local button = Instance.new("TextButton")
        button.Name = banType.name .. "Button"
        button.Size = UDim2.new(0.3, -10, 0, 35)
        button.Position = UDim2.new((i-1) * 0.33, 10, 0, 50)
        button.BackgroundColor3 = banType.color
        button.BorderSizePixel = 0
        button.Text = banType.icon .. " " .. banType.name
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = banTypeSection
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button
        
        banTypeButtons[banType.name] = button
        
        -- Selection logic
        if banType.name == selectedBanType then
            button.BackgroundTransparency = 0
        else
            button.BackgroundTransparency = 0.5
        end
        
        button.MouseButton1Click:Connect(function()
            selectedBanType = banType.name
            for name, btn in pairs(banTypeButtons) do
                if name == selectedBanType then
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
                else
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
                end
            end
        end)
    end
    
    -- Duration Selection (for temporary bans)
    local durationSection = Instance.new("Frame")
    durationSection.Name = "DurationSection"
    durationSection.Size = UDim2.new(1, 0, 0, 120)
    durationSection.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    durationSection.BorderSizePixel = 0
    durationSection.LayoutOrder = 3
    durationSection.Parent = contentFrame
    
    local durationCorner = Instance.new("UICorner")
    durationCorner.CornerRadius = UDim.new(0, 10)
    durationCorner.Parent = durationSection
    
    local durationLabel = Instance.new("TextLabel")
    durationLabel.Size = UDim2.new(1, 0, 0, 30)
    durationLabel.Position = UDim2.new(0, 15, 0, 10)
    durationLabel.BackgroundTransparency = 1
    durationLabel.Text = "⏳ Ban Duration"
    durationLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
    durationLabel.TextScaled = true
    durationLabel.TextXAlignment = Enum.TextXAlignment.Left
    durationLabel.Font = Enum.Font.GothamBold
    durationLabel.Parent = durationSection
    
    local durations = {
        {name = "1 Hour", seconds = 3600},
        {name = "1 Day", seconds = 86400},
        {name = "1 Week", seconds = 604800},
        {name = "Custom", seconds = 0}
    }
    
    local selectedDuration = durations[2].seconds
    local durationButtons = {}
    
    for i, duration in ipairs(durations) do
        local button = Instance.new("TextButton")
        button.Name = duration.name:gsub(" ", "") .. "Button"
        button.Size = UDim2.new(0.22, -5, 0, 35)
        button.Position = UDim2.new((i-1) * 0.25, 5, 0, 50)
        button.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
        button.BorderSizePixel = 0
        button.Text = duration.name
        button.TextColor3 = Color3.fromRGB(20, 20, 30)
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = durationSection
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button
        
        durationButtons[duration.name] = button
        
        if i == 2 then -- Default to 1 Day
            button.BackgroundTransparency = 0
        else
            button.BackgroundTransparency = 0.5
        end
        
        button.MouseButton1Click:Connect(function()
            selectedDuration = duration.seconds
            for name, btn in pairs(durationButtons) do
                if name == duration.name then
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
                else
                    TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
                end
            end
        end)
    end
    
    -- Reason Section
    local reasonSection = Instance.new("Frame")
    reasonSection.Name = "ReasonSection"
    reasonSection.Size = UDim2.new(1, 0, 0, 120)
    reasonSection.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    reasonSection.BorderSizePixel = 0
    reasonSection.LayoutOrder = 4
    reasonSection.Parent = contentFrame
    
    local reasonCorner = Instance.new("UICorner")
    reasonCorner.CornerRadius = UDim.new(0, 10)
    reasonCorner.Parent = reasonSection
    
    local reasonLabel = Instance.new("TextLabel")
    reasonLabel.Size = UDim2.new(1, 0, 0, 30)
    reasonLabel.Position = UDim2.new(0, 15, 0, 10)
    reasonLabel.BackgroundTransparency = 1
    reasonLabel.Text = "📝 Ban Reason"
    reasonLabel.TextColor3 = Color3.fromRGB(255, 150, 255)
    reasonLabel.TextScaled = true
    reasonLabel.TextXAlignment = Enum.TextXAlignment.Left
    reasonLabel.Font = Enum.Font.GothamBold
    reasonLabel.Parent = reasonSection
    
    local reasonInput = Instance.new("TextBox")
    reasonInput.Name = "ReasonInput"
    reasonInput.Size = UDim2.new(1, -30, 0, 60)
    reasonInput.Position = UDim2.new(0, 15, 0, 45)
    reasonInput.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    reasonInput.BorderSizePixel = 0
    reasonInput.Text = ""
    reasonInput.PlaceholderText = "Enter ban reason..."
    reasonInput.TextColor3 = Color3.new(1, 1, 1)
    reasonInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    reasonInput.TextWrapped = true
    reasonInput.TextYAlignment = Enum.TextYAlignment.Top
    reasonInput.Font = Enum.Font.Gotham
    reasonInput.TextSize = 14
    reasonInput.Parent = reasonSection
    
    local reasonInputCorner = Instance.new("UICorner")
    reasonInputCorner.CornerRadius = UDim.new(0, 8)
    reasonInputCorner.Parent = reasonInput
    
    local reasonInputStroke = Instance.new("UIStroke")
    reasonInputStroke.Color = Color3.fromRGB(70, 130, 255)
    reasonInputStroke.Thickness = 1
    reasonInputStroke.Transparency = 0.7
    reasonInputStroke.Parent = reasonInput
    
    -- Action Buttons
    local actionSection = Instance.new("Frame")
    actionSection.Name = "ActionSection"
    actionSection.Size = UDim2.new(1, 0, 0, 80)
    actionSection.BackgroundTransparency = 1
    actionSection.LayoutOrder = 5
    actionSection.Parent = contentFrame
    
    local banButton = Instance.new("TextButton")
    banButton.Name = "BanButton"
    banButton.Size = UDim2.new(0.45, -10, 0, 50)
    banButton.Position = UDim2.new(0, 0, 0, 15)
    banButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    banButton.BorderSizePixel = 0
    banButton.Text = "🔨 EXECUTE BAN"
    banButton.TextColor3 = Color3.new(1, 1, 1)
    banButton.TextScaled = true
    banButton.Font = Enum.Font.GothamBold
    banButton.Parent = actionSection
    
    local banButtonCorner = Instance.new("UICorner")
    banButtonCorner.CornerRadius = UDim.new(0, 12)
    banButtonCorner.Parent = banButton
    
    local unbanButton = Instance.new("TextButton")
    unbanButton.Name = "UnbanButton"
    unbanButton.Size = UDim2.new(0.45, -10, 0, 50)
    unbanButton.Position = UDim2.new(0.55, 10, 0, 15)
    unbanButton.BackgroundColor3 = Color3.fromRGB(70, 255, 70)
    unbanButton.BorderSizePixel = 0
    unbanButton.Text = "🔓 UNBAN PLAYER"
    unbanButton.TextColor3 = Color3.fromRGB(20, 20, 30)
    unbanButton.TextScaled = true
    unbanButton.Font = Enum.Font.GothamBold
    unbanButton.Parent = actionSection
    
    local unbanButtonCorner = Instance.new("UICorner")
    unbanButtonCorner.CornerRadius = UDim.new(0, 12)
    unbanButtonCorner.Parent = unbanButton
    
    -- Mobile Compatibility
    if GuiService:IsTenFootInterface() or UserInputService.TouchEnabled then
        -- Adjust sizes for mobile
        mainFrame.Size = UDim2.new(0.95, 0, 0.85, 0)
        titleLabel.TextSize = 18
        -- Make buttons larger for touch
        for _, button in pairs({closeButton, banButton, unbanButton}) do
            if button then
                local currentSize = button.Size
                button.Size = UDim2.new(currentSize.X.Scale, currentSize.X.Offset, 0, math.max(currentSize.Y.Offset, 50))
            end
        end
    end
    
    -- Animation Functions
    local function showPanel()
        mainFrame.Position = UDim2.new(0.5, 0, -1, 0)
        
        local showTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Position = UDim2.new(0.5, 0, 0.5, 0)}
        )
        
        showTween:Play()
        
        -- Animate glow
        local glowTween = TweenService:Create(
            glowFrame,
            TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {BackgroundTransparency = 0.7}
        )
        glowTween:Play()
    end
    
    local function hidePanel()
        local hideTween = TweenService:Create(
            mainFrame,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, 0, -1, 0)}
        )
        
        hideTween:Play()
        
        hideTween.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end
    
    -- Button Hover Effects
    local function addHoverEffect(button, hoverColor, normalColor)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
        end)
    end
    
    addHoverEffect(closeButton, Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 70, 70))
    addHoverEffect(banButton, Color3.fromRGB(255, 100, 100), Color3.fromRGB(255, 70, 70))
    addHoverEffect(unbanButton, Color3.fromRGB(100, 255, 100), Color3.fromRGB(70, 255, 70))
    
    -- Input Focus Effects
    playerInput.Focused:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
    end)
    
    playerInput.FocusLost:Connect(function()
        TweenService:Create(inputStroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play()
    end)
    
    reasonInput.Focused:Connect(function()
        TweenService:Create(reasonInputStroke, TweenInfo.new(0.2), {Transparency = 0.3}):Play()
    end)
    
    reasonInput.FocusLost:Connect(function()
        TweenService:Create(reasonInputStroke, TweenInfo.new(0.2), {Transparency = 0.7}):Play()
    end)
    
    -- Button Events
    closeButton.MouseButton1Click:Connect(hidePanel)
    
    banButton.MouseButton1Click:Connect(function()
        local targetName = playerInput.Text
        local reason = reasonInput.Text
        
        if targetName == "" or reason == "" then
            -- Show error animation
            local errorTween = TweenService:Create(
                banButton,
                TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
                {Position = banButton.Position + UDim2.new(0, 5, 0, 0)}
            )
            errorTween:Play()
            return
        end
        
        -- Execute ban logic here
        executeBan(player, targetName, selectedBanType, selectedDuration, reason)
        hidePanel()
    end)
    
    unbanButton.MouseButton1Click:Connect(function()
        local targetName = playerInput.Text
        
        if targetName == "" then
            local errorTween = TweenService:Create(
                unbanButton,
                TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true, 0),
                {Position = unbanButton.Position + UDim2.new(0, 5, 0, 0)}
            )
            errorTween:Play()
            return
        end
        
        -- Execute unban logic here
        executeUnban(player, targetName)
        hidePanel()
    end)
    
    -- Parent to PlayerGui and show
    screenGui.Parent = player:WaitForChild("PlayerGui")
    showPanel()
end

-- Permission Check Function
local function hasPermission(player)
    -- Check user ID
    for _, id in ipairs(CONFIG.ADMIN_USER_IDS) do
        if player.UserId == id then
            return true
        end
    end
    
    -- Check group rank (if player is in a group)
    if player:IsInGroup(0) then -- Replace 0 with your group ID
        local rank = player:GetRankInGroup(0) -- Replace 0 with your group ID
        for _, adminRank in ipairs(CONFIG.ADMIN_RANKS) do
            if rank >= adminRank then
                return true
            end
        end
    end
    
    return false
end

-- Ban Execution Function
function executeBan(admin, targetName, banType, duration, reason)
    local targetPlayer = Players:FindFirstChild(targetName)
    local targetUserId
    
    if targetPlayer then
        targetUserId = targetPlayer.UserId
    else
        -- Try to get UserId from name
        local success, result = pcall(function()
            return Players:GetUserIdFromNameAsync(targetName)
        end)
        
        if success then
            targetUserId = result
        else
            return false, "Player not found"
        end
    end
    
    local banData = {
        UserId = targetUserId,
        PlayerName = targetName,
        BanType = banType,
        Reason = reason,
        AdminUserId = admin.UserId,
        AdminName = admin.Name,
        BanTime = os.time(),
        Duration = duration,
        UnbanTime = (banType == "Permanent") and 0 or (os.time() + duration),
        Active = true
    }
    
    -- Save to DataStore
    local success, errorMsg = pcall(function()
        BanDataStore:SetAsync(tostring(targetUserId), banData)
    end)
    
    if success then
        activeBans[targetUserId] = banData
        
        -- Kick player if online
        if targetPlayer then
            local kickMessage = string.format(
                "🚫 YOU HAVE BEEN BANNED 🚫\n\n" ..
                "Ban Type: %s\n" ..
                "Reason: %s\n" ..
                "Admin: %s\n" ..
                "Duration: %s\n\n" ..
                "Appeal at: [Your Appeal URL]",
                banType,
                reason,
                admin.Name,
                banType == "Permanent" and "Permanent" or formatTime(duration)
            )
            targetPlayer:Kick(kickMessage)
        end
        
        -- Log to webhook if enabled
        if CONFIG.ENABLE_WEBHOOK and CONFIG.WEBHOOK_URL ~= "" then
            logBanToWebhook(banData)
        end
        
        return true
    else
        return false, errorMsg
    end
end

-- Unban Function
function executeUnban(admin, targetName)
    local targetUserId
    
    -- Try to get UserId
    local success, result = pcall(function()
        return Players:GetUserIdFromNameAsync(targetName)
    end)
    
    if success then
        targetUserId = result
    else
        return false, "Player not found"
    end
    
    -- Remove from DataStore
    local success, errorMsg = pcall(function()
        local banData = BanDataStore:GetAsync(tostring(targetUserId))
        if banData then
            banData.Active = false
            banData.UnbanTime = os.time()
            banData.UnbanAdmin = admin.Name
            BanDataStore:SetAsync(tostring(targetUserId), banData)
        end
    end)
    
    if success then
        activeBans[targetUserId] = nil
        return true
    else
        return false, errorMsg
    end
end

-- Utility Functions
local function formatTime(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    
    if days > 0 then
        return string.format("%d day(s), %d hour(s)", days, hours)
    elseif hours > 0 then
        return string.format("%d hour(s), %d minute(s)", hours, minutes)
    else
        return string.format("%d minute(s)", minutes)
    end
end

local function logBanToWebhook(banData)
    local embed = {
        ["embeds"] = {{
            ["title"] = "🔨 Player Banned",
            ["color"] = 15158332, -- Red color
            ["fields"] = {
                {["name"] = "Player", ["value"] = banData.PlayerName, ["inline"] = true},
                {["name"] = "User ID", ["value"] = tostring(banData.UserId), ["inline"] = true},
                {["name"] = "Ban Type", ["value"] = banData.BanType, ["inline"] = true},
                {["name"] = "Reason", ["value"] = banData.Reason, ["inline"] = false},
                {["name"] = "Admin", ["value"] = banData.AdminName, ["inline"] = true},
                {["name"] = "Duration", ["value"] = banData.BanType == "Permanent" and "Permanent" or formatTime(banData.Duration), ["inline"] = true},
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ", banData.BanTime),
            ["footer"] = {["text"] = "Advanced Ban System"}
        }}
    }
    
    local success, response = pcall(function()
        return HttpService:PostAsync(CONFIG.WEBHOOK_URL, HttpService:JSONEncode(embed), Enum.HttpContentType.ApplicationJson)
    end)
end

-- Check if player is banned on join
local function checkPlayerBan(player)
    local success, banData = pcall(function()
        return BanDataStore:GetAsync(tostring(player.UserId))
    end)
    
    if success and banData and banData.Active then
        -- Check if temporary ban has expired
        if banData.BanType == "Temporary" and banData.UnbanTime <= os.time() then
            -- Ban expired, remove it
            banData.Active = false
            pcall(function()
                BanDataStore:SetAsync(tostring(player.UserId), banData)
            end)
            return false
        end
        
        -- Player is banned
        local kickMessage
        if banData.BanType == "Permanent" then
            kickMessage = string.format(
                "🚫 YOU ARE PERMANENTLY BANNED 🚫\n\n" ..
                "Reason: %s\n" ..
                "Banned by: %s\n" ..
                "Ban Date: %s\n\n" ..
                "This ban does not expire.\n" ..
                "Appeal at: [Your Appeal URL]",
                banData.Reason,
                banData.AdminName,
                os.date("%Y-%m-%d %H:%M:%S", banData.BanTime)
            )
        elseif banData.BanType == "Warning" then
            -- Don't kick for warnings, just notify
            return false
        else
            local timeLeft = banData.UnbanTime - os.time()
            kickMessage = string.format(
                "🚫 YOU ARE TEMPORARILY BANNED 🚫\n\n" ..
                "Reason: %s\n" ..
                "Banned by: %s\n" ..
                "Time Remaining: %s\n" ..
                "Unban Date: %s\n\n" ..
                "Appeal at: [Your Appeal URL]",
                banData.Reason,
                banData.AdminName,
                formatTime(timeLeft),
                os.date("%Y-%m-%d %H:%M:%S", banData.UnbanTime)
            )
        end
        
        if banData.BanType ~= "Warning" then
            player:Kick(kickMessage)
            return true
        end
    end
    
    return false
end

-- Load active bans on server start
local function loadActiveBans()
    -- This would typically iterate through all banned players
    -- For now, we'll load them as players join
end

-- Chat Commands (Alternative to GUI)
local function onPlayerChatted(player, message)
    if not hasPermission(player) then return end
    
    local args = string.split(message, " ")
    local command = args[1]:lower()
    
    if command == "/banpanel" or command == "/bp" then
        createBanPanel(player)
    elseif command == "/ban" and #args >= 3 then
        local targetName = args[2]
        local reason = table.concat(args, " ", 3)
        executeBan(player, targetName, "Temporary", 86400, reason) -- Default 1 day
    elseif command == "/unban" and #args >= 2 then
        local targetName = args[2]
        executeUnban(player, targetName)
    elseif command == "/permban" and #args >= 3 then
        local targetName = args[2]
        local reason = table.concat(args, " ", 3)
        executeBan(player, targetName, "Permanent", 0, reason)
    elseif command == "/warn" and #args >= 3 then
        local targetName = args[2]
        local reason = table.concat(args, " ", 3)
        executeBan(player, targetName, "Warning", 0, reason)
    end
end

-- Admin Panel Toggle Key (F4 key)
local function setupKeyToggle(player)
    if not hasPermission(player) then return end
    
    local function onKeyPress(key, gameProcessed)
        if gameProcessed then return end
        
        if key.KeyCode == Enum.KeyCode.F4 then
            -- Check if panel already exists
            local existingPanel = player.PlayerGui:FindFirstChild("AdminBanPanel")
            if existingPanel then
                existingPanel:Destroy()
            else
                createBanPanel(player)
            end
        end
    end
    
    UserInputService.InputBegan:Connect(onKeyPress)
end

-- Notification System
local function createNotification(player, title, message, color, duration)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BanNotification"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 100)
    frame.Position = UDim2.new(1, 50, 0, 50) -- Start off-screen
    frame.BackgroundColor3 = color or Color3.fromRGB(50, 50, 70)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 2
    stroke.Transparency = 0.7
    stroke.Parent = frame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = frame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 50)
    messageLabel.Position = UDim2.new(0, 10, 0, 40)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextWrapped = true
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 14
    messageLabel.Parent = frame
    
    -- Slide in animation
    local slideIn = TweenService:Create(
        frame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -420, 0, 50)}
    )
    slideIn:Play()
    
    -- Wait and slide out
    spawn(function()
        wait(duration or 3)
        
        local slideOut = TweenService:Create(
            frame,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 50, 0, 50)}
        )
        slideOut:Play()
        
        slideOut.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
end

-- Enhanced Ban Status Display
local function createBanStatusGUI(player)
    if not hasPermission(player) then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BanStatusGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "StatusFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    header.BorderSizePixel = 0
    header.Text = "📊 Active Bans"
    header.TextColor3 = Color3.new(1, 1, 1)
    header.TextScaled = true
    header.Font = Enum.Font.GothamBold
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    local headerBottom = Instance.new("Frame")
    headerBottom.Size = UDim2.new(1, 0, 0, 15)
    headerBottom.Position = UDim2.new(0, 0, 1, -15)
    headerBottom.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    headerBottom.BorderSizePixel = 0
    headerBottom.Parent = header
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scrollFrame
    
    -- Update function would populate this with active bans
    -- This is a placeholder for the ban status display
end

-- Event Connections
Players.PlayerAdded:Connect(function(player)
    -- Check if player is banned
    checkPlayerBan(player)
    
    -- Set up chat commands
    player.Chatted:Connect(function(message)
        onPlayerChatted(player, message)
    end)
    
    -- Set up key toggle for admins
    player.CharacterAdded:Connect(function()
        wait(1) -- Wait for character to fully load
        setupKeyToggle(player)
    end)
    
    -- Send welcome notification to admins
    if hasPermission(player) then
        wait(2) -- Wait for GUI to load
        createNotification(
            player,
            "🛡️ Admin Panel Ready",
            "Press F4 to open ban panel or use /banpanel",
            Color3.fromRGB(70, 130, 255),
            4
        )
    end
end)

-- Initialize system
loadActiveBans()

-- Auto-save active bans every 5 minutes
spawn(function()
    while true do
        wait(300) -- 5 minutes
        -- Save current ban data (placeholder for auto-save functionality)
    end
end)

-- Console Commands for Server Owners
if game.PlaceId == 0 then -- Replace with your game's PlaceId for production
    -- Additional server-side only features can go here
end

print("🛡️ Advanced Ban Panel System Loaded Successfully!")
print("Commands: /banpanel, /ban, /unban, /permban, /warn")
print("Hotkey: F4 (for admins)")
print("Configure ADMIN_USER_IDS and ADMIN_RANKS in the CONFIG table")
