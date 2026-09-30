-- ============================================
-- DR HUB (FREE / PREMIUM)
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")

local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

-- ========== ENCRYPTED KEYS ==========
-- "magabok" (free)
local _kf = {109,97,103,97,98,111,107}
local KEY_FREE = string.char(_kf[1],_kf[2],_kf[3],_kf[4],_kf[5],_kf[6],_kf[7])
-- "magaPrem" (premium)
local _kp = {109,97,103,97,80,114,101,109}
local KEY_PREM = string.char(_kp[1],_kp[2],_kp[3],_kp[4],_kp[5],_kp[6],_kp[7],_kp[8])

local IS_PREMIUM = false

-- ========== CONFIG ==========
local ACCENT = Color3.fromRGB(140, 90, 255)
local RED = Color3.fromRGB(255, 40, 40)
local GOLD = Color3.fromRGB(255, 200, 60)
local BG = Color3.fromRGB(22, 22, 30)
local PANEL = Color3.fromRGB(32, 32, 44)
local SIDE = Color3.fromRGB(18, 18, 26)
local OFF = Color3.fromRGB(70, 70, 88)
local WHITE = Color3.new(1, 1, 1)

local S = {
    ThirdPerson = false, Spin = false,
    Chams = false, ChamsRainbow = false, Highlight = false,
    ESP = false, ESPDist = true, Tracers = false,
    -- Premium only:
    Aim = false, FOVCircle = false, WallCheck = true, Snap = true,
}

local spinSpeed = 6
local defaultFov = Cam.FieldOfView
local hasDrawing = pcall(function() return Drawing.new("Circle") end)

-- Premium vars
local aimFovSize = 150
local aimSmooth = 0.3
local fovCircle = nil

-- Visual
local chamsColor = Color3.fromRGB(255, 60, 120)
local chamsTransparency = 0.35
local espColor = Color3.fromRGB(255, 255, 255)
local tracerColor = Color3.fromRGB(255, 255, 255)

local espObjects = {}
local tracerObjects = {}
local currentRatio = 16/9

-- Skins (premium)
local charOriginals = {}
local lastSkin = nil

local ColorPalette = {
    {name = "Red",     color = Color3.fromRGB(255, 40, 40)},
    {name = "Blue",    color = Color3.fromRGB(40, 120, 255)},
    {name = "Green",   color = Color3.fromRGB(40, 255, 90)},
    {name = "Yellow",  color = Color3.fromRGB(255, 230, 40)},
    {name = "Pink",    color = Color3.fromRGB(255, 60, 200)},
    {name = "Orange",  color = Color3.fromRGB(255, 130, 40)},
    {name = "Purple",  color = Color3.fromRGB(180, 60, 255)},
    {name = "Cyan",    color = Color3.fromRGB(60, 230, 255)},
    {name = "White",   color = Color3.fromRGB(255, 255, 255)},
    {name = "Black",   color = Color3.fromRGB(20, 20, 20)},
}

local function round(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
end

-- ============================================
-- KEY SYSTEM
-- ============================================
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "DRHubKey"; keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true; keyGui.DisplayOrder = 1000
keyGui.Parent = LP:WaitForChild("PlayerGui")

local kbg = Instance.new("Frame", keyGui)
kbg.Size = UDim2.new(1,0,1,0); kbg.BackgroundColor3 = Color3.fromRGB(10,10,15)
kbg.BorderSizePixel = 0

local kpanel = Instance.new("Frame", kbg)
kpanel.Size = UDim2.fromOffset(320, 230)
kpanel.Position = UDim2.new(0.5, -160, 0.5, -115)
kpanel.BackgroundColor3 = BG; kpanel.BorderSizePixel = 0
round(kpanel, 12)
local kps = Instance.new("UIStroke", kpanel); kps.Color = ACCENT; kps.Thickness = 1.5

local ktitle = Instance.new("TextLabel", kpanel)
ktitle.Size = UDim2.new(1,0,0,44); ktitle.BackgroundTransparency = 1
ktitle.Text = "DR HUB"; ktitle.Font = Enum.Font.GothamBold
ktitle.TextSize = 24; ktitle.TextColor3 = ACCENT

local ksub = Instance.new("TextLabel", kpanel)
ksub.Size = UDim2.new(1,0,0,32); ksub.Position = UDim2.fromOffset(0,46)
ksub.BackgroundTransparency = 1
ksub.Text = "Enter key to continue\n(free or premium)"
ksub.Font = Enum.Font.Gotham; ksub.TextSize = 11
ksub.TextColor3 = Color3.fromRGB(180,180,200)
ksub.TextWrapped = true

local kbox = Instance.new("TextBox", kpanel)
kbox.Size = UDim2.new(1,-40,0,38); kbox.Position = UDim2.new(0,20,0,90)
kbox.BackgroundColor3 = PANEL; kbox.Text = ""; kbox.PlaceholderText = "Key..."
kbox.Font = Enum.Font.GothamMedium; kbox.TextSize = 15; kbox.TextColor3 = WHITE
kbox.PlaceholderColor3 = Color3.fromRGB(120,120,140); kbox.ClearTextOnFocus = false
round(kbox, 8)

local kbtn = Instance.new("TextButton", kpanel)
kbtn.Size = UDim2.new(1,-40,0,38); kbtn.Position = UDim2.new(0,20,0,140)
kbtn.BackgroundColor3 = ACCENT; kbtn.Text = "Enter"
kbtn.Font = Enum.Font.GothamBold; kbtn.TextSize = 15; kbtn.TextColor3 = WHITE
round(kbtn, 8)

local kerr = Instance.new("TextLabel", kpanel)
kerr.Size = UDim2.new(1,0,0,20); kerr.Position = UDim2.new(0,0,0,195)
kerr.BackgroundTransparency = 1; kerr.Text = ""
kerr.Font = Enum.Font.GothamBold; kerr.TextSize = 12; kerr.TextColor3 = Color3.fromRGB(255,80,80)

local unlocked = false
local function tryKey()
    local txt = kbox.Text
    if txt == KEY_FREE then
        unlocked = true
        IS_PREMIUM = false
        kerr.TextColor3 = Color3.fromRGB(80,255,120)
        kerr.Text = "✓ FREE access granted"
        kbtn.BackgroundColor3 = Color3.fromRGB(80,255,120)
        task.wait(0.6); keyGui:Destroy()
    elseif txt == KEY_PREM then
        unlocked = true
        IS_PREMIUM = true
        kerr.TextColor3 = GOLD
        kerr.Text = "★ PREMIUM access granted"
        kbtn.BackgroundColor3 = GOLD
        task.wait(0.6); keyGui:Destroy()
    else
        kerr.Text = "✗ Wrong key"; kbox.Text = ""
        kps.Color = Color3.fromRGB(255,80,80); task.wait(0.4); kps.Color = ACCENT
    end
end
kbtn.MouseButton1Click:Connect(tryKey)
kbox.FocusLost:Connect(function(e) if e then tryKey() end end)
while not unlocked do task.wait(0.1) end

-- ============================================
-- SPLASH
-- ============================================
task.spawn(function()
    local sg = Instance.new("ScreenGui")
    sg.IgnoreGuiInset = true; sg.DisplayOrder = 999; sg.ResetOnSpawn = false
    sg.Parent = LP:WaitForChild("PlayerGui")
    local dark = Instance.new("Frame", sg)
    dark.Size = UDim2.new(1,0,1,0); dark.BackgroundColor3 = Color3.fromRGB(10,10,15)
    dark.BackgroundTransparency = 1
    TS:Create(dark, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play(); task.wait(0.4)

    local t = Instance.new("TextLabel", sg)
    t.Size = UDim2.new(1,0,0,90); t.Position = UDim2.new(0,0,0.5,-45)
    t.BackgroundTransparency = 1; t.Text = "DR HUB"
    t.Font = Enum.Font.GothamBlack; t.TextSize = 8
    t.TextColor3 = IS_PREMIUM and GOLD or ACCENT
    t.TextTransparency = 1
    local st = Instance.new("UIStroke", t); st.Color = WHITE; st.Thickness = 2; st.Transparency = 1

    TS:Create(t, TweenInfo.new(0.6, Enum.EasingStyle.Back), {TextSize = 72, TextTransparency = 0}):Play()
    TS:Create(st, TweenInfo.new(0.5), {Transparency = 0.3}):Play()
    task.wait(0.3)
    local sub = Instance.new("TextLabel", sg)
    sub.Size = UDim2.new(1,0,0,20); sub.Position = UDim2.new(0,0,0.5,45)
    sub.BackgroundTransparency = 1; sub.Text = IS_PREMIUM and "★ premium" or "free"
    sub.Font = Enum.Font.GothamMedium; sub.TextSize = 14
    sub.TextColor3 = IS_PREMIUM and GOLD or Color3.fromRGB(200,200,220)
    sub.TextTransparency = 1
    TS:Create(sub, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
    task.spawn(function()
        for i = 1, 4 do
            if not t.Parent then break end
            TS:Create(st, TweenInfo.new(0.25), {Color = IS_PREMIUM and GOLD or Color3.fromRGB(255,100,255)}):Play()
            task.wait(0.25)
            TS:Create(st, TweenInfo.new(0.25), {Color = WHITE}):Play()
            task.wait(0.25)
        end
    end)
    task.wait(1.5)
    TS:Create(t, TweenInfo.new(0.4), {TextTransparency = 1, TextSize = 110}):Play()
    TS:Create(st, TweenInfo.new(0.4), {Transparency = 1}):Play()
    TS:Create(sub, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TS:Create(dark, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    task.wait(0.8); sg:Destroy()
end)

-- ============================================
-- MAIN MENU
-- ============================================
local gui = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
gui.Name = "DRHub"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true

local BASE_W, BASE_H = 512, 288
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(BASE_W, BASE_H)
main.Position = UDim2.new(0.5, -BASE_W/2, 0.5, -BASE_H/2)
main.BackgroundColor3 = BG; main.BorderSizePixel = 0
round(main, 12)
local stroke = Instance.new("UIStroke", main)
stroke.Color = IS_PREMIUM and GOLD or ACCENT
stroke.Thickness = 1.5

-- SIDEBAR
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.fromOffset(110, BASE_H - 16)
sidebar.Position = UDim2.fromOffset(8, 8)
sidebar.BackgroundColor3 = SIDE; sidebar.BorderSizePixel = 0
round(sidebar, 10)

local photoFrame = Instance.new("Frame", sidebar)
photoFrame.Size = UDim2.fromOffset(48, 48)
photoFrame.Position = UDim2.new(0.5, -24, 0, 8)
photoFrame.BackgroundColor3 = PANEL
round(photoFrame, 24)
local photoImg = Instance.new("ImageLabel", photoFrame)
photoImg.Size = UDim2.new(1,-4,1,-4); photoImg.Position = UDim2.fromOffset(2,2)
photoImg.BackgroundTransparency = 1
photoImg.Image = "rbxassetid://0"
photoImg.ScaleType = Enum.ScaleType.Crop
round(photoImg, 22)

task.spawn(function()
    local ok, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok and thumb then photoImg.Image = thumb
    else photoImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LP.UserId .. "&width=150&height=150&format=png" end
end)

LP.CharacterAdded:Connect(function()
    local ok, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok and thumb then photoImg.Image = thumb end
end)

local nameLbl = Instance.new("TextLabel", sidebar)
nameLbl.Size = UDim2.new(1,0,0,16); nameLbl.Position = UDim2.fromOffset(0, 60)
nameLbl.BackgroundTransparency = 1; nameLbl.Text = LP.Name or "Player"
nameLbl.Font = Enum.Font.GothamBold; nameLbl.TextSize = 11
nameLbl.TextColor3 = WHITE; nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

local execLbl = Instance.new("TextLabel", sidebar)
execLbl.Size = UDim2.new(1,0,0,12); execLbl.Position = UDim2.fromOffset(0, 74)
execLbl.BackgroundTransparency = 1
execLbl.Text = IS_PREMIUM and "★ DR HUB premium" or "DR HUB free"
execLbl.Font = Enum.Font.Gotham; execLbl.TextSize = 9
execLbl.TextColor3 = IS_PREMIUM and GOLD or ACCENT

local separator = Instance.new("Frame", sidebar)
separator.Size = UDim2.new(1,-16,0,1); separator.Position = UDim2.new(0,8,0,92)
separator.BackgroundColor3 = Color3.fromRGB(50,50,65); separator.BorderSizePixel = 0

local tabList = Instance.new("Frame", sidebar)
tabList.Size = UDim2.new(1,-8,1,-104); tabList.Position = UDim2.fromOffset(4, 100)
tabList.BackgroundTransparency = 1
local tll = Instance.new("UIListLayout", tabList)
tll.Padding = UDim.new(0,3); tll.SortOrder = Enum.SortOrder.LayoutOrder

local pages, tabButtons = {}, {}

local function selectTab(name)
    for n, p in pairs(pages) do
        p.Visible = (n == name)
        tabButtons[n].BackgroundColor3 = (n == name) and (IS_PREMIUM and GOLD or ACCENT) or SIDE
    end
end

local function createTab(name, order)
    local b = Instance.new("TextButton", tabList)
    b.Size = UDim2.new(1,0,0,26)
    b.BackgroundColor3 = SIDE; b.Text = name
    b.Font = Enum.Font.GothamMedium; b.TextSize = 11; b.TextColor3 = WHITE
    b.TextXAlignment = Enum.TextXAlignment.Left; b.AutoButtonColor = false
    b.LayoutOrder = order
    local bpad = Instance.new("UIPadding", b)
    bpad.PaddingLeft = UDim.new(0, 8)
    round(b, 6)

    local page = Instance.new("Frame", main)
    page.Size = UDim2.new(1, -128, 1, -16)
    page.Position = UDim2.fromOffset(122, 8)
    page.BackgroundTransparency = 1; page.Visible = false

    local scroll = Instance.new("ScrollingFrame", page)
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4; scroll.ScrollBarImageColor3 = IS_PREMIUM and GOLD or ACCENT
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local sl = Instance.new("UIListLayout", scroll); sl.Padding = UDim.new(0,5)
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingRight = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 4)

    pages[name], tabButtons[name] = page, b
    b.MouseButton1Click:Connect(function() selectTab(name) end)
    return scroll
end

local pgProfile = createTab("Profile", 1)
local pgCombat, pgSkins
local pgVisual
local pgChar
local pgSettings

if IS_PREMIUM then
    pgCombat = createTab("Combat", 2)
    pgVisual = createTab("Visual", 3)
    pgChar = createTab("Character", 4)
    pgSkins = createTab("Skins", 5)
    pgSettings = createTab("Settings", 6)
else
    pgVisual = createTab("Visual", 2)
    pgChar = createTab("Character", 3)
    pgSettings = createTab("Settings", 4)
end

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.fromOffset(22,22); closeBtn.Position = UDim2.new(1,-28,0,6)
closeBtn.BackgroundColor3 = PANEL; closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 12; closeBtn.TextColor3 = WHITE
round(closeBtn, 6); closeBtn.ZIndex = 3

local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.fromOffset(46,46)
openBtn.Position = UDim2.new(0, 10, 0.5, -23)
openBtn.BackgroundColor3 = RED; openBtn.Text = "M"
openBtn.Font = Enum.Font.GothamBlack; openBtn.TextSize = 24; openBtn.TextColor3 = WHITE
openBtn.AutoButtonColor = false; round(openBtn, 23)
local openStroke = Instance.new("UIStroke", openBtn)
openStroke.Color = WHITE; openStroke.Thickness = 2; openStroke.Transparency = 0.4

task.spawn(function()
    while openBtn.Parent do
        TS:Create(openStroke, TweenInfo.new(0.8), {Transparency = 0.8}):Play(); task.wait(0.8)
        TS:Create(openStroke, TweenInfo.new(0.8), {Transparency = 0.2}):Play(); task.wait(0.8)
    end
end)

closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)
openBtn.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)
UIS.InputBegan:Connect(function(i,p) if not p and i.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible end end)

-- RESIZE
local resizeHandle = Instance.new("TextButton", main)
resizeHandle.Size = UDim2.fromOffset(16,16)
resizeHandle.Position = UDim2.new(1,-18,1,-18)
resizeHandle.BackgroundColor3 = IS_PREMIUM and GOLD or ACCENT
resizeHandle.Text = "◢"; resizeHandle.Font = Enum.Font.GothamBold
resizeHandle.TextSize = 10; resizeHandle.TextColor3 = WHITE
resizeHandle.AutoButtonColor = false; resizeHandle.ZIndex = 5
round(resizeHandle, 4)

do
    local resizing, startPos, startSize
    resizeHandle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            resizing = true; startPos = i.Position; startSize = main.AbsoluteSize
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startPos
            local newW = math.clamp(startSize.X + d.X, 400, 900)
            local newH = newW / currentRatio
            if newH < 250 then newH = 250; newW = newH * currentRatio end
            main.Size = UDim2.fromOffset(newW, newH)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then resizing = false end
    end)
end

-- Drag menu
do
    local dragging, dragStart, startPos
    local function startDrag(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = main.Position
        end
    end
    sidebar.InputBegan:Connect(startDrag)
    main.InputBegan:Connect(function(i) startDrag(i) end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- Drag M
do
    local dragging, dragStart, startPos
    openBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = openBtn.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            openBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- ============================================
-- UI COMPONENTS
-- ============================================
local function createToggle(page, text, key, onChange)
    local row = Instance.new("TextButton", page)
    row.Size = UDim2.new(1,-6,0,30); row.BackgroundColor3 = PANEL
    row.Text = ""; row.AutoButtonColor = false; round(row, 6)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-56,1,0); lbl.Position = UDim2.fromOffset(10,0)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextColor3 = WHITE

    local accent = IS_PREMIUM and GOLD or ACCENT
    local pill = Instance.new("Frame", row)
    pill.Size = UDim2.fromOffset(36,18); pill.Position = UDim2.new(1,-44,0.5,-9)
    pill.BackgroundColor3 = S[key] and accent or OFF; round(pill, 9)

    local knob = Instance.new("Frame", pill)
    knob.Size = UDim2.fromOffset(14,14)
    knob.Position = S[key] and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2)
    knob.BackgroundColor3 = WHITE; round(knob, 7)

    row.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        local on = S[key]
        local ti = TweenInfo.new(0.15)
        TS:Create(pill, ti, {BackgroundColor3 = on and accent or OFF}):Play()
        TS:Create(knob, ti, {Position = on and UDim2.fromOffset(20,2) or UDim2.fromOffset(2,2)}):Play()
        if onChange then onChange(on) end
    end)
end

local function createSlider(page, text, mn, mx, init, fmt, onChange)
    local row = Instance.new("Frame", page)
    row.Size = UDim2.new(1,-6,0,42); row.BackgroundColor3 = PANEL; round(row, 6)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-60,0,18); lbl.Position = UDim2.fromOffset(10,3)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextColor3 = WHITE
    local val = Instance.new("TextLabel", row)
    val.Size = UDim2.fromOffset(56,18); val.Position = UDim2.new(1,-62,0,3)
    val.BackgroundTransparency = 1; val.Text = string.format(fmt, init)
    val.Font = Enum.Font.GothamBold; val.TextSize = 11
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.TextColor3 = IS_PREMIUM and GOLD or ACCENT

    local accent = IS_PREMIUM and GOLD or ACCENT
    local bar = Instance.new("Frame", row)
    bar.Size = UDim2.new(1,-20,0,6); bar.Position = UDim2.new(0,10,0,28)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,76); round(bar, 3)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((init-mn)/(mx-mn),0,1,0); fill.BackgroundColor3 = accent; round(fill, 3)

    local drag = false
    local function upd(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
        local v = mn + (mx-mn)*rel
        fill.Size = UDim2.new(rel,0,1,0)
        val.Text = string.format(fmt, v)
        if onChange then onChange(v) end
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; upd(i.Position.X) end end)
    UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
end

local function createColorPicker(page, titleText, initialColor, onSelect)
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1,-6,0,18); title.BackgroundTransparency = 1
    title.Text = titleText; title.Font = Enum.Font.GothamBold; title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left; title.TextColor3 = WHITE

    local previewRow = Instance.new("Frame", page)
    previewRow.Size = UDim2.new(1,-6,0,26); previewRow.BackgroundColor3 = PANEL
    round(previewRow, 6)

    local previewSquare = Instance.new("Frame", previewRow)
    previewSquare.Size = UDim2.fromOffset(18,18); previewSquare.Position = UDim2.new(0, 4, 0.5, -9)
    previewSquare.BackgroundColor3 = initialColor; round(previewSquare, 4)
    local pSqStroke = Instance.new("UIStroke", previewSquare)
    pSqStroke.Color = WHITE; pSqStroke.Thickness = 2

    local previewText = Instance.new("TextLabel", previewRow)
    previewText.Size = UDim2.new(1,-30,1,0); previewText.Position = UDim2.fromOffset(28,0)
    previewText.BackgroundTransparency = 1
    previewText.Text = "Selected: " .. tostring(initialColor)
    previewText.Font = Enum.Font.Gotham; previewText.TextSize = 10
    previewText.TextXAlignment = Enum.TextXAlignment.Left; previewText.TextColor3 = WHITE

    local gridHolder = Instance.new("Frame", page)
    gridHolder.Size = UDim2.new(1,-6,0,90); gridHolder.BackgroundColor3 = PANEL
    round(gridHolder, 6)

    local grid = Instance.new("UIGridLayout", gridHolder)
    grid.CellSize = UDim2.fromOffset(48,28); grid.CellPadding = UDim2.fromOffset(4,4)
    local gridPad = Instance.new("UIPadding", gridHolder)
    gridPad.PaddingLeft = UDim.new(0,4); gridPad.PaddingTop = UDim.new(0,4)

    local colorButtons = {}
    for _, c in ipairs(ColorPalette) do
        local b = Instance.new("TextButton", gridHolder)
        b.BackgroundColor3 = c.color; b.Text = ""
        b.AutoButtonColor = false; round(b, 5)
        local bst = Instance.new("UIStroke", b)
        bst.Color = WHITE; bst.Thickness = 0; bst.Transparency = 1
        if c.color.R == initialColor.R and c.color.G == initialColor.G and c.color.B == initialColor.B then
            bst.Thickness = 3; bst.Transparency = 0
        end
        colorButtons[c.name] = {btn = b, stroke = bst}
        b.MouseButton1Click:Connect(function()
            for _, info in pairs(colorButtons) do
                info.stroke.Thickness = 0
                info.stroke.Transparency = 1
            end
            bst.Thickness = 3; bst.Transparency = 0
            previewSquare.BackgroundColor3 = c.color
            previewText.Text = "Selected: " .. c.name
            onSelect(c.color, c.name)
        end)
    end
end

-- ============================================
-- PROFILE TAB
-- ============================================
do
    local info = Instance.new("Frame", pgProfile)
    info.Size = UDim2.new(1,-6,0,72); info.BackgroundColor3 = PANEL; round(info, 8)
    local t1 = Instance.new("TextLabel", info)
    t1.Size = UDim2.new(1,-10,0,20); t1.Position = UDim2.fromOffset(10,6)
    t1.BackgroundTransparency = 1
    t1.Text = IS_PREMIUM and "★ DR HUB premium" or "DR HUB free"
    t1.Font = Enum.Font.GothamBold; t1.TextSize = 15
    t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.TextColor3 = IS_PREMIUM and GOLD or ACCENT
    local t2 = Instance.new("TextLabel", info)
    t2.Size = UDim2.new(1,-10,0,14); t2.Position = UDim2.fromOffset(10,28)
    t2.BackgroundTransparency = 1; t2.Text = "Welcome back, " .. LP.Name
    t2.Font = Enum.Font.Gotham; t2.TextSize = 10
    t2.TextXAlignment = Enum.TextXAlignment.Left; t2.TextColor3 = Color3.fromRGB(200,200,220)
    local t3 = Instance.new("TextLabel", info)
    t3.Size = UDim2.new(1,-10,0,14); t3.Position = UDim2.fromOffset(10,46)
    t3.BackgroundTransparency = 1; t3.Text = "Executor: Delta  •  Device: " .. (UIS.TouchEnabled and "Mobile" or "PC")
    t3.Font = Enum.Font.Gotham; t3.TextSize = 10
    t3.TextXAlignment = Enum.TextXAlignment.Left; t3.TextColor3 = Color3.fromRGB(180,180,200)

    local sep = Instance.new("Frame", pgProfile)
    sep.Size = UDim2.new(1,-6,0,1); sep.BackgroundColor3 = Color3.fromRGB(50,50,65); sep.BorderSizePixel = 0

    local stats = Instance.new("Frame", pgProfile)
    stats.Size = UDim2.new(1,-6,0,80); stats.BackgroundColor3 = PANEL; round(stats, 8)
    local s1 = Instance.new("TextLabel", stats)
    s1.Size = UDim2.new(1,-10,0,14); s1.Position = UDim2.fromOffset(10,6)
    s1.BackgroundTransparency = 1; s1.Text = "Statistics"
    s1.Font = Enum.Font.GothamBold; s1.TextSize = 11
    s1.TextXAlignment = Enum.TextXAlignment.Left
    s1.TextColor3 = IS_PREMIUM and GOLD or ACCENT
    local s2 = Instance.new("TextLabel", stats)
    s2.Size = UDim2.new(1,-10,0,14); s2.Position = UDim2.fromOffset(10,26)
    s2.BackgroundTransparency = 1
    s2.Text = IS_PREMIUM and "Aimbot: OFF" or "ESP: OFF"
    s2.Font = Enum.Font.Gotham; s2.TextSize = 10
    s2.TextXAlignment = Enum.TextXAlignment.Left; s2.TextColor3 = WHITE
    local s3 = Instance.new("TextLabel", stats)
    s3.Size = UDim2.new(1,-10,0,14); s3.Position = UDim2.fromOffset(10,42)
    s3.BackgroundTransparency = 1; s3.Text = "Chams: OFF"
    s3.Font = Enum.Font.Gotham; s3.TextSize = 10
    s3.TextXAlignment = Enum.TextXAlignment.Left; s3.TextColor3 = WHITE
    local s4 = Instance.new("TextLabel", stats)
    s4.Size = UDim2.new(1,-10,0,14); s4.Position = UDim2.fromOffset(10,58)
    s4.BackgroundTransparency = 1; s4.Text = "Spin: OFF"
    s4.Font = Enum.Font.Gotham; s4.TextSize = 10
    s4.TextXAlignment = Enum.TextXAlignment.Left; s4.TextColor3 = WHITE

    RunService.RenderStepped:Connect(function()
        if IS_PREMIUM then
            s2.Text = "Aimbot: " .. (S.Aim and "ON" or "OFF")
        else
            s2.Text = "ESP: " .. (S.ESP and "ON" or "OFF")
        end
        s3.Text = "Chams: " .. (S.Chams and "ON" or "OFF")
        s4.Text = "Spin: " .. (S.Spin and "ON" or "OFF")
    end)

    local fv = Instance.new("TextLabel", pgProfile)
    fv.Size = UDim2.new(1,-6,0,30); fv.BackgroundColor3 = PANEL
    if IS_PREMIUM then
        fv.Text = "★ Premium  •  Aimbot  •  Skins"
        fv.TextColor3 = GOLD
    else
        fv.Text = "Free  •  No Aimbot  •  No Skins"
        fv.TextColor3 = Color3.fromRGB(150,220,255)
    end
    fv.Font = Enum.Font.Gotham; fv.TextSize = 10
    fv.TextWrapped = true; round(fv, 8)
end

-- ============================================
-- VISUAL FUNCTIONS
-- ============================================
local function applyChams(p)
    if p == LP or not p.Character then return end
    local h = p.Character:FindFirstChild("DH_Chams")
    if S.Chams then
        if not h then
            h = Instance.new("Highlight", p.Character)
            h.Name = "DH_Chams"; h.Adornee = p.Character
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
        h.FillColor = chamsColor; h.OutlineColor = chamsColor
        h.FillTransparency = chamsTransparency; h.OutlineTransparency = 0
    elseif h then h:Destroy() end
end

local function applyHL(p)
    if p == LP or not p.Character then return end
    local h = p.Character:FindFirstChild("DH_HL")
    if S.Highlight then
        if not h then
            h = Instance.new("Highlight", p.Character)
            h.Name = "DH_HL"; h.Adornee = p.Character
            h.DepthMode = Enum.HighlightDepthMode.Occluded
        end
        h.FillColor = IS_PREMIUM and GOLD or ACCENT; h.OutlineColor = WHITE; h.FillTransparency = 0.6
    elseif h then h:Destroy() end
end

local function refreshVisuals()
    for _, p in ipairs(Players:GetPlayers()) do applyHL(p); applyChams(p) end
end

local function recolorChams()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local h = p.Character:FindFirstChild("DH_Chams")
            if h then h.FillColor = chamsColor; h.OutlineColor = chamsColor; h.FillTransparency = chamsTransparency end
        end
    end
end

local function createESPObjects(p)
    if not hasDrawing then return end
    if espObjects[p] then
        if espObjects[p].name then espObjects[p].name:Remove() end
        if espObjects[p].dist then espObjects[p].dist:Remove() end
    end
    if tracerObjects[p] then tracerObjects[p]:Remove() end

    local nameTag = Drawing.new("Text"); nameTag.Size = 14; nameTag.Center = true
    nameTag.Outline = true; nameTag.Color = WHITE; nameTag.Visible = false

    local distTag = Drawing.new("Text"); distTag.Size = 13; distTag.Center = true
    distTag.Outline = true; distTag.Color = Color3.fromRGB(255,220,100); distTag.Visible = false

    local line = Drawing.new("Line"); line.Thickness = 2
    line.Color = tracerColor; line.Transparency = 1; line.Visible = false

    espObjects[p] = {name = nameTag, dist = distTag}
    tracerObjects[p] = line
end

local function removeESP(p)
    if espObjects[p] then
        if espObjects[p].name then espObjects[p].name:Remove() end
        if espObjects[p].dist then espObjects[p].dist:Remove() end
        espObjects[p] = nil
    end
    if tracerObjects[p] then tracerObjects[p]:Remove(); tracerObjects[p] = nil end
end

local function hookPlayer(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5); applyHL(p); applyChams(p); createESPObjects(p)
    end)
    if p.Character then createESPObjects(p) end
end
for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(removeESP)

local function applyTP()
    if not LP.Character then return end
    if S.ThirdPerson then
        LP.CameraMode = Enum.CameraMode.Classic
        LP.CameraMinZoomDistance = 8; LP.CameraMaxZoomDistance = 20
        local hu = LP.Character:FindFirstChildOfClass("Humanoid")
        if hu then Cam.CameraSubject = hu; Cam.CameraType = Enum.CameraType.Custom end
    else
        LP.CameraMinZoomDistance = 0.5; LP.CameraMaxZoomDistance = 0.5
        LP.CameraMode = Enum.CameraMode.LockFirstPerson
        local hu = LP.Character:FindFirstChildOfClass("Humanoid")
        if hu then Cam.CameraSubject = hu end
    end
end

local hue = 0
RunService.RenderStepped:Connect(function(dt)
    if S.ChamsRainbow then
        hue = (hue + dt * 0.4) % 1
        local rc = Color3.fromHSV(hue, 1, 1)
        chamsColor = rc
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local h = p.Character:FindFirstChild("DH_Chams")
                if h then h.FillColor = rc; h.OutlineColor = rc end
            end
        end
    end
end)

-- ============================================
-- AIMBOT (только premium)
-- ============================================
local function isPlayerVisible(part)
    if not S.WallCheck then return true end
    local o = Cam.CFrame.Position
    local ch = LP.Character
    if ch and ch:FindFirstChild("Head") then o = ch.Head.Position end
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {LP.Character, Cam}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local res = workspace:Raycast(o, part.Position - o, rp)
    if res then return res.Instance:IsDescendantOf(part.Parent) end
    return true
end

local function getTarget()
    local c = Cam.ViewportSize/2
    local best, bd = nil, aimFovSize
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChild("Head")
            local hu = p.Character:FindFirstChildOfClass("Humanoid")
            if h and hu and hu.Health > 0 and isPlayerVisible(h) then
                local pos, on = Cam:WorldToViewportPoint(h.Position)
                if on then
                    local d = (Vector2.new(pos.X, pos.Y) - c).Magnitude
                    if d < bd then best, bd = h, d end
                end
            end
        end
    end
    return best
end

if IS_PREMIUM then
    if hasDrawing then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2; fovCircle.NumSides = 60
        fovCircle.Radius = aimFovSize; fovCircle.Filled = false
        fovCircle.Transparency = 1; fovCircle.Color = GOLD; fovCircle.Visible = false
    end
end

-- ============================================
-- COMBAT TAB (только premium)
-- ============================================
if IS_PREMIUM and pgCombat then
    createToggle(pgCombat, "Aim Assist", "Aim", function(on) if fovCircle then fovCircle.Visible = on and S.FOVCircle end end)
    createToggle(pgCombat, "Snap Aim (instant)", "Snap")
    createToggle(pgCombat, "Show FOV Circle", "FOVCircle", function() if fovCircle then fovCircle.Visible = S.FOVCircle and S.Aim end end)
    createToggle(pgCombat, "Wall Check (Raycast)", "WallCheck")
    createSlider(pgCombat, "FOV Size", 50, 500, aimFovSize, "%.0f", function(v) aimFovSize = v; if fovCircle then fovCircle.Radius = v end end)
    createSlider(pgCombat, "Aim Smoothness", 0.05, 1, aimSmooth, "%.2f", function(v) aimSmooth = v end)
end

-- ============================================
-- VISUAL TAB
-- ============================================
createToggle(pgVisual, "ESP (player nick)", "ESP")
createToggle(pgVisual, "Show Distance", "ESPDist")
createToggle(pgVisual, "Tracers (lines)", "Tracers")
createToggle(pgVisual, "Highlight players", "Highlight", refreshVisuals)

createColorPicker(pgVisual, "Nick color:", espColor, function(c) espColor = c end)
createColorPicker(pgVisual, "Tracer color:", tracerColor, function(c) tracerColor = c end)

createToggle(pgVisual, "Enable Chams", "Chams", refreshVisuals)
createToggle(pgVisual, "🌈 Rainbow Chams", "ChamsRainbow")
createSlider(pgVisual, "Chams Transparency", 0, 0.9, chamsTransparency, "%.2f", function(v)
    chamsTransparency = v; recolorChams()
end)
createColorPicker(pgVisual, "Chams color:", chamsColor, function(c)
    chamsColor = c; S.ChamsRainbow = false; recolorChams()
end)

-- ESP update
RunService.RenderStepped:Connect(function()
    if not hasDrawing then return end
    for p, obj in pairs(espObjects) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("HumanoidRootPart") then
            local headPos = p.Character.Head.Position
            local rootPos = p.Character.HumanoidRootPart.Position
            local sp, on = Cam:WorldToViewportPoint(headPos)
            if on then
                local myPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local dist = 0
                if myPos then dist = (myPos.Position - rootPos).Magnitude end
                if S.ESP then
                    obj.name.Text = p.Name
                    obj.name.Position = Vector2.new(sp.X, sp.Y - 20)
                    obj.name.Color = espColor
                    obj.name.Visible = true
                    if S.ESPDist then
                        obj.dist.Text = string.format("[%d m]", math.floor(dist))
                        obj.dist.Position = Vector2.new(sp.X, sp.Y - 4)
                        obj.dist.Visible = true
                    else obj.dist.Visible = false end
                else
                    obj.name.Visible = false; obj.dist.Visible = false
                end
                if S.Tracers then
                    local line = tracerObjects[p]
                    if line then
                        line.From = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y)
                        line.To = Vector2.new(sp.X, sp.Y)
                        line.Color = tracerColor
                        line.Visible = true
                    end
                else
                    if tracerObjects[p] then tracerObjects[p].Visible = false end
                end
            else
                obj.name.Visible = false; obj.dist.Visible = false
                if tracerObjects[p] then tracerObjects[p].Visible = false end
            end
        end
    end
end)

-- ============================================
-- CHARACTER TAB
-- ============================================
createToggle(pgChar, "Third Person", "ThirdPerson", function(on) applyTP() end)
createToggle(pgChar, "Spin", "Spin", function(on)
    local ch = LP.Character
    local hu = ch and ch:FindFirstChildOfClass("Humanoid")
    if hu then hu.AutoRotate = not on end
end)
createSlider(pgChar, "Spin Speed", 1, 100, spinSpeed, "%.0f", function(v) spinSpeed = v end)
createSlider(pgChar, "FOV (Camera)", 50, 110, defaultFov, "%.0f", function(v) Cam.FieldOfView = v end)

LP.CharacterAdded:Connect(function(char)
    charOriginals = {}
    task.wait(0.6)
    applyTP()
    local hu = char:FindFirstChildOfClass("Humanoid")
    if hu then hu.AutoRotate = not S.Spin end
    task.wait(0.3)
    refreshVisuals()
    -- Переприменяем скин
    if IS_PREMIUM and lastSkin then
        task.wait(0.2)
        local ch = LP.Character
        if ch then
            for _, part in ipairs(ch:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    charOriginals[part] = {c = part.Color, m = part.Material, t = part.Transparency}
                    part.Color = lastSkin.c; part.Material = lastSkin.m
                    if lastSkin.t then part.Transparency = lastSkin.t end
                end
            end
        end
    end
end)

-- ============================================
-- SKINS TAB (только premium)
-- ============================================
if IS_PREMIUM and pgSkins then
    local function resetSkin()
        for part, d in pairs(charOriginals) do
            if part.Parent then part.Color, part.Material, part.Transparency = d.c, d.m, d.t end
        end
        charOriginals = {}; lastSkin = nil
    end

    local function applySkin(c, m, t)
        lastSkin = {c = c, m = m, t = t}
        local ch = LP.Character; if not ch then return end
        for _, part in ipairs(ch:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                if not charOriginals[part] then
                    charOriginals[part] = {c = part.Color, m = part.Material, t = part.Transparency}
                end
                part.Color = c; part.Material = m
                if t then part.Transparency = t end
            end
        end
    end

    local skinHolder = Instance.new("Frame", pgSkins)
    skinHolder.Size = UDim2.new(1,-6,0,180)
    skinHolder.BackgroundTransparency = 1
    local grid = Instance.new("UIGridLayout", skinHolder)
    grid.CellSize = UDim2.fromOffset(110,28); grid.CellPadding = UDim2.fromOffset(5,5)

    local list = {
        {"Gold",   function() applySkin(Color3.fromRGB(255,200,40), Enum.Material.Metal) end},
        {"Neon",   function() applySkin(GOLD, Enum.Material.Neon) end},
        {"Ice",    function() applySkin(Color3.fromRGB(150,220,255), Enum.Material.Ice) end},
        {"Ghost",  function() applySkin(Color3.fromRGB(230,230,255), Enum.Material.ForceField, 0.3) end},
        {"Lava",   function() applySkin(Color3.fromRGB(255,80,20), Enum.Material.CrackedLava) end},
        {"Black",  function() applySkin(Color3.fromRGB(20,20,20), Enum.Material.Plastic) end},
        {"Reset",  resetSkin},
    }
    for _, it in ipairs(list) do
        local b = Instance.new("TextButton", skinHolder)
        b.BackgroundColor3 = PANEL; b.Text = it[1]
        b.Font = Enum.Font.GothamMedium; b.TextSize = 11; b.TextColor3 = WHITE
        round(b, 6); b.MouseButton1Click:Connect(it[2])
    end

    local hint = Instance.new("TextLabel", pgSkins)
    hint.Size = UDim2.new(1,-6,0,30); hint.BackgroundColor3 = PANEL
    hint.Text = "Skin persists after death ✓"
    hint.Font = Enum.Font.Gotham; hint.TextSize = 10
    hint.TextColor3 = Color3.fromRGB(150,220,150)
    hint.TextWrapped = true; round(hint, 6)
end

-- ============================================
-- SETTINGS TAB
-- ============================================
do
    local ratioTitle = Instance.new("TextLabel", pgSettings)
    ratioTitle.Size = UDim2.new(1,-6,0,18); ratioTitle.BackgroundTransparency = 1
    ratioTitle.Text = "Aspect Ratio:"; ratioTitle.Font = Enum.Font.GothamBold
    ratioTitle.TextSize = 11; ratioTitle.TextXAlignment = Enum.TextXAlignment.Left
    ratioTitle.TextColor3 = WHITE

    local ratioHolder = Instance.new("Frame", pgSettings)
    ratioHolder.Size = UDim2.new(1,-6,0,36); ratioHolder.BackgroundTransparency = 1
    local rhLayout = Instance.new("UIListLayout", ratioHolder)
    rhLayout.FillDirection = Enum.FillDirection.Horizontal
    rhLayout.Padding = UDim.new(0, 4)

    local ratioButtons = {}

    local function setRatio(w, h, ratio, btn)
        currentRatio = ratio
        main.Size = UDim2.fromOffset(w, h)
        main.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
        for _, b in pairs(ratioButtons) do b.BackgroundColor3 = PANEL end
        if btn then btn.BackgroundColor3 = IS_PREMIUM and GOLD or ACCENT end
    end

    local ratios = {
        {name = "16:9",  w = 512, h = 288, r = 16/9},
        {name = "4:3",   w = 480, h = 360, r = 4/3},
        {name = "16:10", w = 512, h = 320, r = 16/10},
    }

    for _, rr in ipairs(ratios) do
        local b = Instance.new("TextButton", ratioHolder)
        b.Size = UDim2.fromOffset(72, 28); b.BackgroundColor3 = PANEL
        b.Text = rr.name; b.Font = Enum.Font.GothamBold
        b.TextSize = 11; b.TextColor3 = WHITE; b.AutoButtonColor = false
        round(b, 6)
        ratioButtons[rr.name] = b
        b.MouseButton1Click:Connect(function() setRatio(rr.w, rr.h, rr.r, b) end)
    end

    ratioButtons["16:9"].BackgroundColor3 = IS_PREMIUM and GOLD or ACCENT

    local info = Instance.new("TextLabel", pgSettings)
    info.Size = UDim2.new(1,-6,0,50); info.BackgroundColor3 = PANEL
    info.Text = "Drag the ◢ handle (bottom-right)\nto resize menu (keeps selected ratio)"
    info.Font = Enum.Font.Gotham; info.TextSize = 10
    info.TextColor3 = Color3.fromRGB(200,200,220)
    info.TextWrapped = true; info.TextYAlignment = Enum.TextYAlignment.Center
    round(info, 8)

    local resetBtn = Instance.new("TextButton", pgSettings)
    resetBtn.Size = UDim2.new(1,-6,0,30); resetBtn.BackgroundColor3 = PANEL
    resetBtn.Text = "Reset Menu Size"; resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 11; resetBtn.TextColor3 = WHITE
    round(resetBtn, 6)
    resetBtn.MouseButton1Click:Connect(function()
        local w, h
        if currentRatio == 4/3 then w = 480
        elseif currentRatio == 16/10 then w = 512
        else w = 512 end
        h = w / currentRatio
        main.Size = UDim2.fromOffset(w, h)
        main.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
    end)

    local credit = Instance.new("TextLabel", pgSettings)
    credit.Size = UDim2.new(1,-6,0,40); credit.BackgroundTransparency = 1
    credit.Text = (IS_PREMIUM and "★ DR HUB premium" or "DR HUB free") .. "\nby Assistant"
    credit.Font = Enum.Font.Gotham; credit.TextSize = 10
    credit.TextColor3 = Color3.fromRGB(150,150,170)
    credit.TextWrapped = true
end

-- ============================================
-- MAIN LOOP
-- ============================================
RunService.RenderStepped:Connect(function()
    Cam = workspace.CurrentCamera

    -- Aim (только premium)
    if IS_PREMIUM then
        if fovCircle then
            fovCircle.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
            fovCircle.Radius = aimFovSize
            fovCircle.Visible = S.FOVCircle and S.Aim
        end

        local aiming = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or UIS.TouchEnabled
        if S.Aim and aiming then
            local t = getTarget()
            if t then
                local goal = CFrame.lookAt(Cam.CFrame.Position, t.Position)
                if S.Snap then Cam.CFrame = goal
                else Cam.CFrame = Cam.CFrame:Lerp(goal, aimSmooth) end
            end
        end
    end

    -- Spin
    if S.Spin then
        local ch = LP.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
        end
    end
end)

selectTab("Profile")
print(IS_PREMIUM and "★ DR HUB premium loaded!" or "DR HUB free loaded!")
