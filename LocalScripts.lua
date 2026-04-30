-- leaked by https://discord.gg/F4eknseBRK join for more sources
-- Ensure game + (optional) Galaxy Hub UI are loaded before building toggles
repeat task.wait() until game:IsLoaded()

local galaxyHubAddToggle = rawget(_G, "AddToggle")
if typeof(galaxyHubAddToggle) ~= "function" then
    local startedAt = os.clock()
    repeat
        task.wait()
        galaxyHubAddToggle = rawget(_G, "AddToggle")
    until typeof(galaxyHubAddToggle) == "function" or (os.clock() - startedAt) >= 10
end

-- ══════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local Lighting           = game:GetService("Lighting")
local Stats              = game:GetService("Stats")
local ContextActionService = game:GetService("ContextActionService")
local GuiService         = game:GetService("GuiService")
local HttpService        = game:GetService("HttpService")
local CoreGui            = game:GetService("CoreGui")
local function showScreenText(_) end

if not RunService:IsClient() then
    showScreenText("NOT RUNNING ON CLIENT - UI WILL NOT SHOW")
    return
end

local player = game.Players.LocalPlayer
if not player then
    local waitStart = os.clock()
    repeat
        task.wait()
        player = game.Players.LocalPlayer
    until player or (os.clock() - waitStart) >= 15
end
if not player then
    showScreenText("LocalPlayer missing after 15s - UI bootstrap aborted")
    return
end
local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 10)
if not playerGui then
    showScreenText("PlayerGui missing after 10s - using CoreGui fallback")
end
local lp = player

local statusGuiRef, statusFrameRef, statusLabelRef, statusCopyBtnRef
local currentStatusMessage = ""

showScreenText = function(message)
    local targetGuiParent = playerGui or CoreGui or player
    if not targetGuiParent then return end

    if not statusGuiRef or not statusGuiRef.Parent then
        statusGuiRef = targetGuiParent:FindFirstChild("GalaxyStatusGui")
        if not (statusGuiRef and statusGuiRef:IsA("ScreenGui")) then
            statusGuiRef = Instance.new("ScreenGui")
            statusGuiRef.Name = "GalaxyStatusGui"
            statusGuiRef.ResetOnSpawn = false
            statusGuiRef.IgnoreGuiInset = true
            statusGuiRef.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            statusGuiRef.DisplayOrder = 10000
            statusGuiRef.Enabled = true
            statusGuiRef.Parent = targetGuiParent
        end
    end

    if not statusFrameRef or not statusFrameRef.Parent then
        statusFrameRef = Instance.new("Frame")
        statusFrameRef.Name = "StatusFrame"
        statusFrameRef.BackgroundTransparency = 1
        statusFrameRef.AnchorPoint = Vector2.new(0.5, 0.5)
        statusFrameRef.Position = UDim2.new(0.5, 0, 0.5, 0)
        statusFrameRef.Size = UDim2.new(0, 530, 0, 80)
        statusFrameRef.Parent = statusGuiRef
    end

    if not statusCopyBtnRef or not statusCopyBtnRef.Parent then
        statusCopyBtnRef = Instance.new("ImageButton")
        statusCopyBtnRef.Name = "CopyButton"
        statusCopyBtnRef.BackgroundTransparency = 1
        statusCopyBtnRef.Size = UDim2.new(0, 20, 0, 20)
        statusCopyBtnRef.AnchorPoint = Vector2.new(0, 0.5)
        statusCopyBtnRef.Position = UDim2.new(0, 0, 0.5, 0)
        statusCopyBtnRef.Image = "rbxassetid://6031068421"
        statusCopyBtnRef.ImageColor3 = Color3.fromRGB(200, 200, 200)
        statusCopyBtnRef.Parent = statusFrameRef

        statusCopyBtnRef.MouseEnter:Connect(function()
            statusCopyBtnRef.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end)
        statusCopyBtnRef.MouseLeave:Connect(function()
            statusCopyBtnRef.ImageColor3 = Color3.fromRGB(200, 200, 200)
            statusCopyBtnRef.Size = UDim2.new(0, 20, 0, 20)
        end)
        statusCopyBtnRef.MouseButton1Down:Connect(function()
            statusCopyBtnRef.Size = UDim2.new(0, 18, 0, 18)
        end)
        statusCopyBtnRef.MouseButton1Up:Connect(function()
            statusCopyBtnRef.Size = UDim2.new(0, 20, 0, 20)
        end)
        statusCopyBtnRef.Activated:Connect(function()
            local env = (getgenv and getgenv()) or _G
            local copyFn = rawget(env, "setclipboard") or rawget(_G, "setclipboard")
            if typeof(copyFn) == "function" then
                pcall(copyFn, currentStatusMessage)
            end
        end)
    end

    if not statusLabelRef or not statusLabelRef.Parent then
        statusLabelRef = Instance.new("TextLabel")
        statusLabelRef.Name = "StatusText"
        statusLabelRef.BackgroundTransparency = 1
        statusLabelRef.AnchorPoint = Vector2.new(0, 0.5)
        statusLabelRef.Position = UDim2.new(0, 30, 0.5, 0)
        statusLabelRef.Size = UDim2.new(0, 500, 0, 80)
        statusLabelRef.Font = Enum.Font.GothamBlack
        statusLabelRef.TextSize = 30
        statusLabelRef.TextColor3 = Color3.fromRGB(157, 78, 221)
        statusLabelRef.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        statusLabelRef.TextStrokeTransparency = 0
        statusLabelRef.TextScaled = false
        statusLabelRef.TextWrapped = true
        statusLabelRef.TextXAlignment = Enum.TextXAlignment.Left
        statusLabelRef.TextYAlignment = Enum.TextYAlignment.Center
        statusLabelRef.Parent = statusFrameRef
    end

    currentStatusMessage = tostring(message or "")
    statusLabelRef.Text = currentStatusMessage

end

showScreenText("SCRIPT EXECUTED / UI BOOTING | Galaxy UI Loaded: " .. tostring(galaxyHubAddToggle))


local function finalizeScreenGui(gui)
    if not (gui and gui:IsA("ScreenGui")) then return end
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 10000
    gui.Enabled = true
    if playerGui then
        gui.Parent = playerGui
    elseif CoreGui then
        gui.Parent = CoreGui
    end
end

-- ══════════════════════════════════════════
-- COLORS (script 2 palette + slight purple)
-- ══════════════════════════════════════════
local BG_DARK    = Color3.fromRGB(11, 11, 11)
local BTN_DARK   = Color3.fromRGB(20, 20, 20)
local BTN_HOVER  = Color3.fromRGB(28, 28, 28)
local BTN_ON     = Color3.fromRGB(100, 30, 200)
local PURPLE     = Color3.fromRGB(157, 78, 221)
local PURPLE2    = Color3.fromRGB(123, 44, 177)
local TEXT_ON    = Color3.fromRGB(255, 255, 255)
local TEXT_OFF   = Color3.fromRGB(180, 180, 180)
local STROKE_OFF = Color3.fromRGB(42, 42, 42)
local STROKE_ON  = Color3.fromRGB(180, 100, 255)

local function tw(obj, t, props, style)
    style = style or Enum.EasingStyle.Quad
    TweenService:Create(obj, TweenInfo.new(t, style, Enum.EasingDirection.Out), props):Play()
end

local function getViewportSize()
    local cam = workspace.CurrentCamera
    if cam then return cam.ViewportSize end
    local ok, res = pcall(function() return GuiService:GetScreenResolution() end)
    if ok and res then return res end
    return Vector2.new(1920, 1080)
end

local dragSessionPositions = {}
local draggableEntries = {}

local function getSafeInsets()
    local ok, topLeftInset, bottomRightInset = pcall(function()
        return GuiService:GetGuiInset()
    end)
    if ok and topLeftInset and bottomRightInset then
        return topLeftInset, bottomRightInset
    end
    return Vector2.zero, Vector2.zero
end

local spinBtnRef = nil
local floatBtnRef = nil
local dropBtnRef = nil
local lockBtnRef = nil
local walkBtnRef = nil
local viewportLayoutConn = nil
local dropGui = nil
local tpDownGui = nil
local tpDownBtnRef = nil
local tpDownEnabled = false
local tpDownConn = nil
local TP_DOWN_Y = -7.00

local function positionRightSideActionButtons(spinBtn, floatBtn, dropBtn, tpDownBtn, lockBtn, walkBtn)
    spinBtn = spinBtn or spinBtnRef
    floatBtn = floatBtn or floatBtnRef
    dropBtn = dropBtn or dropBtnRef
    tpDownBtn = tpDownBtn or tpDownBtnRef
    lockBtn = lockBtn or lockBtnRef
    walkBtn = walkBtn or walkBtnRef
    if not (spinBtn or floatBtn or dropBtn or tpDownBtn or lockBtn or walkBtn) then return end

    if spinBtn and not spinBtn:IsA("GuiObject") then spinBtn = nil end
    if floatBtn and not floatBtn:IsA("GuiObject") then floatBtn = nil end
    if dropBtn and not dropBtn:IsA("GuiObject") then dropBtn = nil end
    if tpDownBtn and not tpDownBtn:IsA("GuiObject") then tpDownBtn = nil end
    if lockBtn and not lockBtn:IsA("GuiObject") then lockBtn = nil end
    if walkBtn and not walkBtn:IsA("GuiObject") then walkBtn = nil end
    if not (spinBtn or floatBtn or dropBtn or tpDownBtn or lockBtn or walkBtn) then return end

    local viewport = getViewportSize()
    local topLeftInset, bottomRightInset = getSafeInsets()
    local rightX = viewport.X - bottomRightInset.X - 24
    local gap = 8
    local spinHeight = 41
    local spinWidth = 125
    local floatWidth = 125
    local lockHeight = 41
    local spinTop = topLeftInset.Y + 15
    local floatTop = spinTop
    local dropTop = floatTop + spinHeight + gap
    local tpDownTop = dropTop + spinHeight + gap
    local lockTop = spinTop + spinHeight + gap
    local walkTop = lockTop + lockHeight + gap
    spinTop = spinTop - spinHeight
    floatTop = floatTop - spinHeight
    dropTop = dropTop - spinHeight
    tpDownTop = tpDownTop - spinHeight
    lockTop = lockTop - spinHeight
    walkTop = walkTop - spinHeight

    if spinBtn then
        spinBtn.AnchorPoint = Vector2.new(1, 0)
        spinBtn.Position = UDim2.fromOffset(rightX, spinTop)
    end
    if floatBtn then
        floatBtn.AnchorPoint = Vector2.new(1, 0)
        if spinBtn then
            floatBtn.Position = UDim2.fromOffset(rightX - spinWidth - gap, floatTop)
        else
            floatBtn.Position = UDim2.fromOffset(rightX - floatWidth - gap, floatTop)
        end
    end
    if dropBtn then
        dropBtn.AnchorPoint = Vector2.new(1, 0)
        if floatBtn then
            local baseX = rightX - spinWidth - gap
            dropBtn.Position = UDim2.fromOffset(baseX, dropTop)
        else
            dropBtn.Position = UDim2.fromOffset(rightX - floatWidth - gap, dropTop)
        end
    end
    if tpDownBtn then
        tpDownBtn.AnchorPoint = Vector2.new(1, 0)
        if floatBtn then
            local baseX = rightX - spinWidth - gap
            tpDownBtn.Position = UDim2.fromOffset(baseX, tpDownTop)
        else
            tpDownBtn.Position = UDim2.fromOffset(rightX - floatWidth - gap, tpDownTop)
        end
    end
    if lockBtn then
        lockBtn.AnchorPoint = Vector2.new(1, 0)
        lockBtn.Position = UDim2.fromOffset(rightX, lockTop)
    end
    if walkBtn then
        walkBtn.AnchorPoint = Vector2.new(1, 0)
        walkBtn.Position = UDim2.fromOffset(rightX, walkTop)
    end
end

local function ensureRightActionButtonsLayoutHook()
    if viewportLayoutConn then return end
    viewportLayoutConn = RunService.RenderStepped:Connect(function()
        if not (spinBtnRef or floatBtnRef or dropBtnRef or tpDownBtnRef or lockBtnRef or walkBtnRef) then return end
        positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
    end)
end

local function getDragBounds()
    local viewport = getViewportSize()
    local topLeftInset, bottomRightInset = getSafeInsets()
    return {
        left = topLeftInset.X,
        top = topLeftInset.Y,
        right = viewport.X - bottomRightInset.X,
        bottom = viewport.Y - bottomRightInset.Y,
    }
end

local function clampGuiToBounds(guiObject, visibleMargin)
    if not (guiObject and guiObject.Parent) then return end
    local size = guiObject.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then return end

    local anchor = guiObject.AnchorPoint
    local bounds = getDragBounds()
    visibleMargin = math.max(visibleMargin or 24, 0)

    local topLeft = Vector2.new(guiObject.AbsolutePosition.X, guiObject.AbsolutePosition.Y)
    local minTopLeftX = bounds.left - math.max(size.X - visibleMargin, 0)
    local maxTopLeftX = bounds.right - math.max(visibleMargin, 0)
    local minTopLeftY = bounds.top - math.max(size.Y - visibleMargin, 0)
    local maxTopLeftY = bounds.bottom - math.max(visibleMargin, 0)

    local clampedTopLeftX = math.clamp(topLeft.X, minTopLeftX, maxTopLeftX)
    local clampedTopLeftY = math.clamp(topLeft.Y, minTopLeftY, maxTopLeftY)
    local anchorPosX = clampedTopLeftX + (size.X * anchor.X)
    local anchorPosY = clampedTopLeftY + (size.Y * anchor.Y)
    guiObject.Position = UDim2.fromOffset(anchorPosX, anchorPosY)
end

local function shouldSuppressButtonClick(btn)
    if not btn then return false end
    local suppressUntil = btn:GetAttribute("UGC_DragSuppressUntil")
    return typeof(suppressUntil) == "number" and tick() < suppressUntil
end

local function makeDraggable(guiObject, dragHandle, options)
    if not (guiObject and guiObject:IsA("GuiObject")) then return end
    dragHandle = (dragHandle and dragHandle:IsA("GuiObject")) and dragHandle or guiObject
    options = options or {}
    local visibleMargin = options.visibleMargin or 24
    local dragThreshold = options.dragThreshold or 8
    local mouseDragThreshold = options.mouseDragThreshold or dragThreshold
    local touchDragThreshold = options.touchDragThreshold or math.min(dragThreshold, 4)
    local touchImmediate = options.touchImmediate == true
    local storageKey = options.storageKey
    local isEnabledFn = options.isEnabled
    local dragZIndex = options.dragZIndex
    local suppressClickDuration = options.suppressClickDuration or 0.18

    local function disableSelection(gui)
        if gui and gui:IsA("GuiObject") then
            gui.Selectable = false
        end
    end

    disableSelection(guiObject)
    disableSelection(dragHandle)
    for _, desc in ipairs(dragHandle:GetDescendants()) do
        disableSelection(desc)
    end
    dragHandle.DescendantAdded:Connect(disableSelection)

    dragHandle.Active = true
    dragHandle.Selectable = false

    local pointerDown = false
    local dragging = false
    local touchConsumedByDrag = false
    local dragInput = nil
    local dragInputType = nil
    local dragStart = Vector2.zero
    local startAbsTopLeft = Vector2.zero

    if storageKey and dragSessionPositions[storageKey] then
        guiObject.Position = dragSessionPositions[storageKey]
    end
    task.defer(function()
        clampGuiToBounds(guiObject, visibleMargin)
        if storageKey then dragSessionPositions[storageKey] = guiObject.Position end
    end)

    local function updatePosition(inputPos)
        local delta = inputPos - dragStart
        local newTopLeft = startAbsTopLeft + delta
        local size = guiObject.AbsoluteSize
        local anchor = guiObject.AnchorPoint
        local bounds = getDragBounds()

        local minTopLeftX = bounds.left - math.max(size.X - visibleMargin, 0)
        local maxTopLeftX = bounds.right - math.max(visibleMargin, 0)
        local minTopLeftY = bounds.top - math.max(size.Y - visibleMargin, 0)
        local maxTopLeftY = bounds.bottom - math.max(visibleMargin, 0)

        local clampedTopLeftX = math.clamp(newTopLeft.X, minTopLeftX, maxTopLeftX)
        local clampedTopLeftY = math.clamp(newTopLeft.Y, minTopLeftY, maxTopLeftY)

        local anchorPosX = clampedTopLeftX + (size.X * anchor.X)
        local anchorPosY = clampedTopLeftY + (size.Y * anchor.Y)

        guiObject.Position = UDim2.fromOffset(anchorPosX, anchorPosY)
    end

    local function endDrag()
        if dragging then
            guiObject:SetAttribute("UGC_DragSuppressUntil", tick() + suppressClickDuration)
            clampGuiToBounds(guiObject, visibleMargin)
        end
        guiObject:SetAttribute("UGC_DragActive", false)
        guiObject:SetAttribute("UGC_TouchDragConsumed", touchConsumedByDrag)
        pointerDown = false
        dragging = false
        touchConsumedByDrag = false
        dragInput = nil
        dragInputType = nil
        if storageKey then dragSessionPositions[storageKey] = guiObject.Position end
    end

    dragHandle.InputBegan:Connect(function(input)
        if isEnabledFn and not isEnabledFn() then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            pointerDown = true
            dragging = false
            touchConsumedByDrag = false
            guiObject:SetAttribute("UGC_DragActive", false)
            guiObject:SetAttribute("UGC_TouchDragConsumed", false)
            dragInput = input
            dragInputType = input.UserInputType
            dragStart = input.Position
            startAbsTopLeft = Vector2.new(guiObject.AbsolutePosition.X, guiObject.AbsolutePosition.Y)
            if dragInputType == Enum.UserInputType.Touch and touchImmediate then
                dragging = true
                touchConsumedByDrag = true
                guiObject:SetAttribute("UGC_DragActive", true)
                guiObject:SetAttribute("UGC_TouchDragConsumed", true)
            end
            if dragZIndex then guiObject.ZIndex = dragZIndex end
        end
    end)

    dragHandle.InputEnded:Connect(function(input)
        if not pointerDown then return end
        if dragInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1 then
            endDrag()
        elseif dragInputType == Enum.UserInputType.Touch and input == dragInput then
            endDrag()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if not pointerDown then return end
        if dragInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1 then
            endDrag()
        elseif dragInputType == Enum.UserInputType.Touch and input == dragInput then
            endDrag()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not pointerDown or not dragInput then return end
        if isEnabledFn and not isEnabledFn() then
            endDrag()
            return
        end

        local inputPos = nil
        if dragInputType == Enum.UserInputType.MouseButton1 then
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                inputPos = input.Position
            end
        elseif dragInputType == Enum.UserInputType.Touch then
            if input == dragInput then
                inputPos = input.Position
            end
        end

        if inputPos then
            local delta = inputPos - dragStart
            local activeThreshold = (dragInputType == Enum.UserInputType.Touch) and touchDragThreshold or mouseDragThreshold
            if not dragging and delta.Magnitude >= activeThreshold then
                dragging = true
                if dragInputType == Enum.UserInputType.Touch then
                    touchConsumedByDrag = true
                    guiObject:SetAttribute("UGC_TouchDragConsumed", true)
                end
                guiObject:SetAttribute("UGC_DragActive", true)
            end
            if dragging then
                updatePosition(inputPos)
                if storageKey then dragSessionPositions[storageKey] = guiObject.Position end
            end
        end
    end)

    table.insert(draggableEntries, {guiObject = guiObject, visibleMargin = visibleMargin, storageKey = storageKey})
end

local function reclampDraggables()
    for _, entry in ipairs(draggableEntries) do
        if entry.guiObject and entry.guiObject.Parent then
            clampGuiToBounds(entry.guiObject, entry.visibleMargin)
            if entry.storageKey then
                dragSessionPositions[entry.storageKey] = entry.guiObject.Position
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════
-- ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
-- ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
-- █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
-- ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
-- ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
-- ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
-- ══════════════════════════════════════════════════════════

-- ─── OPTIMIZER ──────────────────────────────────────────
local optimizerEnabled = false
local savedLighting    = {}
local optimized        = {}

local function enableOptimizer()
    if optimizerEnabled then return end
    optimizerEnabled = true
    savedLighting = {
        GlobalShadows = Lighting.GlobalShadows, FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd, Brightness = Lighting.Brightness,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    }
    Lighting.GlobalShadows = false; Lighting.FogStart = 0; Lighting.FogEnd = 1e9
    Lighting.Brightness = 1; Lighting.EnvironmentDiffuseScale = 0; Lighting.EnvironmentSpecularScale = 0
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            optimized[v] = {v.Material, v.Reflectance}
            v.Material = Enum.Material.Plastic; v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            optimized[v] = v.Transparency; v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
            optimized[v] = v.Enabled; v.Enabled = false
        end
    end
end

local function disableOptimizer()
    if not optimizerEnabled then return end
    optimizerEnabled = false
    for k, v in pairs(savedLighting) do Lighting[k] = v end
    for obj, val in pairs(optimized) do
        if obj and obj.Parent then
            if typeof(val) == "table" then obj.Material = val[1]; obj.Reflectance = val[2]
            elseif typeof(val) == "boolean" then obj.Enabled = val
            else obj.Transparency = val end
        end
    end
    optimized = {}
end

-- ─── XRAY BASE ──────────────────────────────────────────
local baseOrigTransp  = {}
local plotConns       = {}
local xrayConn

local function applyXray(plot)
    if baseOrigTransp[plot] then return end
    baseOrigTransp[plot] = {}
    for _, p in ipairs(plot:GetDescendants()) do
        if p:IsA("BasePart") and p.Transparency < 0.6 then
            baseOrigTransp[plot][p] = p.Transparency; p.Transparency = 0.68
        end
    end
    plotConns[plot] = plot.DescendantAdded:Connect(function(d)
        if d:IsA("BasePart") and d.Transparency < 0.6 then
            baseOrigTransp[plot][d] = d.Transparency; d.Transparency = 0.68
        end
    end)
end

function toggleESPBases(on)
    local plots = workspace:FindFirstChild("Plots"); if not plots then return end
    if not on then
        for _, c in pairs(plotConns) do c:Disconnect() end; plotConns = {}
        if xrayConn then xrayConn:Disconnect(); xrayConn = nil end
        for _, parts in pairs(baseOrigTransp) do
            for p, orig in pairs(parts) do if p and p.Parent then p.Transparency = orig end end
        end
        baseOrigTransp = {}; return
    end
    for _, plot in ipairs(plots:GetChildren()) do applyXray(plot) end
    xrayConn = plots.ChildAdded:Connect(function(np) task.wait(0.2); applyXray(np) end)
end

-- ─── ESP PLAYERS ────────────────────────────────────────
local espConns   = {}
local espEnabled = false

local function createESP(plr)
    if plr == lp or not plr.Character then return end
    if plr.Character:FindFirstChild("ESP_UGC") then return end
    local char = plr.Character
    local hrp  = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not (hrp and head) then return end
    local hl = Instance.new("Highlight"); hl.Name = "ESP_UGC"
    hl.FillColor = Color3.fromRGB(138,43,226); hl.OutlineColor = Color3.fromRGB(180,100,255)
    hl.FillTransparency = 0.25; hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char
    local hb = Instance.new("BoxHandleAdornment"); hb.Name = "ESP_Hitbox"
    hb.Adornee = hrp; hb.Size = Vector3.new(4,6,2)
    hb.Color3 = Color3.fromRGB(138,43,226); hb.Transparency = 0.5
    hb.AlwaysOnTop = true; hb.ZIndex = 10; hb.Parent = char
    local bb = Instance.new("BillboardGui"); bb.Name = "ESP_Name"
    bb.Adornee = head; bb.Size = UDim2.new(0,200,0,50)
    bb.StudsOffset = Vector3.new(0,3,0); bb.AlwaysOnTop = true; bb.Parent = char
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1; lbl.Text = plr.DisplayName or plr.Name
    lbl.TextColor3 = Color3.fromRGB(200,150,255); lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true; lbl.TextStrokeTransparency = 0.4
    lbl.TextStrokeColor3 = Color3.fromRGB(80,0,120); lbl.Parent = bb
end

local function removeESP(plr)
    if not plr.Character then return end
    for _, n in ipairs({"ESP_UGC","ESP_Hitbox","ESP_Name"}) do
        local o = plr.Character:FindFirstChild(n); if o then o:Destroy() end
    end
end

function toggleESPPlayers(on)
    espEnabled = on
    if on then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then
                if plr.Character then createESP(plr) end
                local c = plr.CharacterAdded:Connect(function() task.wait(0.2); if espEnabled then createESP(plr) end end)
                table.insert(espConns, c)
            end
        end
        local pa = Players.PlayerAdded:Connect(function(plr)
            if plr == lp then return end
            local c = plr.CharacterAdded:Connect(function() task.wait(0.2); if espEnabled then createESP(plr) end end)
            table.insert(espConns, c)
        end)
        table.insert(espConns, pa)
    else
        for _, plr in ipairs(Players:GetPlayers()) do removeESP(plr) end
        for _, c in ipairs(espConns) do if c and c.Connected then c:Disconnect() end end
        espConns = {}
    end
end

-- ─── ANTI SENTRY ────────────────────────────────────────
local antiSentryConn, antiSentryTarget
local DETECT_DIST = 60; local PULL_DIST = -5

local function getChar() return Players.LocalPlayer.Character end
local function getWeapon()
    local char = getChar(); if not char then return nil end
    return Players.LocalPlayer.Backpack:FindFirstChild("Bat") or char:FindFirstChild("Bat")
end
local function findSentryTarget()
    local char = getChar(); if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local rp = char.HumanoidRootPart.Position
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
            local id = obj.Name:match("Sentry_(%d+)")
            if id and tonumber(id) == Players.LocalPlayer.UserId then continue end
            local part = obj:IsA("BasePart") and obj or obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))
            if part and (rp - part.Position).Magnitude <= DETECT_DIST then return obj end
        end
    end
end
local function moveSentry(obj)
    local char = getChar(); if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    for _, p in pairs(obj:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    local cf = char.HumanoidRootPart.CFrame * CFrame.new(0,0,PULL_DIST)
    if obj:IsA("BasePart") then obj.CFrame = cf
    elseif obj:IsA("Model") then local m = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"); if m then m.CFrame = cf end end
end
local function attackSentry()
    local char = getChar(); if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local weapon = getWeapon(); if not weapon then return end
    if weapon.Parent == Players.LocalPlayer.Backpack then hum:EquipTool(weapon); task.wait(0.1) end
    local handle = weapon:FindFirstChild("Handle"); if handle then handle.CanCollide = false end
    pcall(function() weapon:Activate() end)
    for _, r in pairs(weapon:GetDescendants()) do
        if r:IsA("RemoteEvent") then pcall(function() r:FireServer() end) end
    end
end
local function startAntiSentry()
    if antiSentryConn then return end
    antiSentryConn = RunService.Heartbeat:Connect(function()
        if antiSentryTarget and antiSentryTarget.Parent == workspace then moveSentry(antiSentryTarget); attackSentry()
        else antiSentryTarget = findSentryTarget() end
    end)
end
local function stopAntiSentry()
    if antiSentryConn then antiSentryConn:Disconnect(); antiSentryConn = nil end; antiSentryTarget = nil
end

-- ─── ANTI BEE & DISCO ───────────────────────────────────
local ABD = { enabled=false, conns={}, origMove=nil, protected=false }
local BAD_NAMES = { Blue=true, DiscoEffect=true, BeeBlur=true, ColorCorrection=true }

local function abdNuke(obj) if obj and obj.Parent and BAD_NAMES[obj.Name] then pcall(function() obj:Destroy() end) end end
local function abdDisconnect()
    for _, c in ipairs(ABD.conns) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() end end; ABD.conns = {}
end
local function protectControls()
    if ABD.protected then return end
    pcall(function()
        local PM = player.PlayerScripts:FindFirstChild("PlayerModule"); if not PM then return end
        local Ctrl = require(PM):GetControls(); if not Ctrl then return end
        if not ABD.origMove then ABD.origMove = Ctrl.moveFunction end
        local function pm(self,mv,rel) if ABD.origMove then ABD.origMove(self,mv,rel) end end
        local cc = RunService.Heartbeat:Connect(function() if ABD.enabled and Ctrl.moveFunction ~= pm then Ctrl.moveFunction = pm end end)
        table.insert(ABD.conns, cc); Ctrl.moveFunction = pm; ABD.protected = true
    end)
end
local function restoreControls()
    if not ABD.protected then return end
    pcall(function()
        local PM = player.PlayerScripts:FindFirstChild("PlayerModule"); if not PM then return end
        local Ctrl = require(PM):GetControls()
        if Ctrl and ABD.origMove then Ctrl.moveFunction = ABD.origMove; ABD.protected = false end
    end)
end
local function blockBuzz()
    pcall(function()
        local bs = player.PlayerScripts:FindFirstChild("Bee", true)
        if bs then local b = bs:FindFirstChild("Buzzing"); if b and b:IsA("Sound") then b:Stop(); b.Volume = 0 end end
    end)
end
local function enableAntiBee()
    if ABD.enabled then return end; ABD.enabled = true
    for _, i in ipairs(Lighting:GetDescendants()) do abdNuke(i) end
    local ac = Lighting.DescendantAdded:Connect(function(o) if ABD.enabled then abdNuke(o) end end); table.insert(ABD.conns, ac)
    protectControls()
    local sc = RunService.Heartbeat:Connect(function() if ABD.enabled then blockBuzz() end end); table.insert(ABD.conns, sc)
end
local function disableAntiBee() if not ABD.enabled then return end; ABD.enabled = false; restoreControls(); abdDisconnect() end

-- ─── ANTI FPS DEVOURER ──────────────────────────────────
local AFPS = { enabled=false, conns={}, hidden={} }
local function removeAcc(acc) if not AFPS.hidden[acc] then AFPS.hidden[acc] = acc.Parent; acc.Parent = nil end end
function enableAntiFPSDevourer()
    if AFPS.enabled then return end; AFPS.enabled = true
    for _, o in ipairs(workspace:GetDescendants()) do if o:IsA("Accessory") then removeAcc(o) end end
    local c = workspace.DescendantAdded:Connect(function(o) if AFPS.enabled and o:IsA("Accessory") then removeAcc(o) end end)
    table.insert(AFPS.conns, c)
end
function disableAntiFPSDevourer()
    if not AFPS.enabled then return end; AFPS.enabled = false
    for _, c in ipairs(AFPS.conns) do if typeof(c)=="RBXScriptConnection" then c:Disconnect() end end; AFPS.conns = {}
    for acc, orig in pairs(AFPS.hidden) do if acc then acc.Parent = orig end end; AFPS.hidden = {}
end

-- ─── MELEE AIMBOT ───────────────────────────────────────
local MELEE_RANGE        = 45
local MELEE_ONLY_ENEMIES = true
local meleeEnabled       = false
local meleeConn, meleeAO, meleeAtt
local character, hrp, hum

local function isValidMeleeTarget(hm, rp)
    if not (hm and rp) or hm.Health <= 0 then return false end
    if MELEE_ONLY_ENEMIES then
        local tp = Players:GetPlayerFromCharacter(hm.Parent)
        if not tp or tp == player then return false end
    end; return true
end
local function getClosestMelee(hrp0)
    local closest, minD = nil, MELEE_RANGE
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        local c = p.Character; if not c then continue end
        local th = c:FindFirstChild("HumanoidRootPart"); local hm = c:FindFirstChildOfClass("Humanoid")
        if isValidMeleeTarget(hm, th) then
            local d = (th.Position - hrp0.Position).Magnitude
            if d < minD then minD = d; closest = th end
        end
    end; return closest
end
local function createMeleeAimbot(char)
    local hrp0 = char:WaitForChild("HumanoidRootPart",8); local hm = char:WaitForChild("Humanoid",8)
    if not (hrp0 and hm) then return end
    if meleeAO then pcall(function() meleeAO:Destroy() end) end
    if meleeAtt then pcall(function() meleeAtt:Destroy() end) end
    meleeAtt = Instance.new("Attachment"); meleeAtt.Parent = hrp0
    meleeAO = Instance.new("AlignOrientation"); meleeAO.Attachment0 = meleeAtt
    meleeAO.Mode = Enum.OrientationAlignmentMode.OneAttachment; meleeAO.RigidityEnabled = true
    meleeAO.MaxTorque = 100000; meleeAO.Responsiveness = 200; meleeAO.Parent = hrp0
    if meleeConn then meleeConn:Disconnect() end
    meleeConn = RunService.RenderStepped:Connect(function()
        if not char.Parent or not meleeEnabled then return end
        local t = getClosestMelee(hrp0)
        if t then hm.AutoRotate = false; meleeAO.Enabled = true
            meleeAO.CFrame = CFrame.lookAt(hrp0.Position, Vector3.new(t.Position.X, hrp0.Position.Y, t.Position.Z))
        else meleeAO.Enabled = false; hm.AutoRotate = true end
    end)
end
local function disableMeleeAimbot()
    meleeEnabled = false
    if meleeConn then meleeConn:Disconnect(); meleeConn = nil end
    if meleeAO then meleeAO.Enabled = false; pcall(function() meleeAO:Destroy() end); meleeAO = nil end
    if character and character:FindFirstChild("Humanoid") then character.Humanoid.AutoRotate = true end
    if meleeAtt then pcall(function() meleeAtt:Destroy() end); meleeAtt = nil end
end

-- ─── ANTI RAGDOLL ───────────────────────────────────────
local antiRagdollEnabled = false; local antiRagdollConn = nil

local function startAntiRagdoll()
    if antiRagdollConn then return end
    antiRagdollConn = RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled then return end
        local char = player.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")

        if hum then
            local s = hum:GetState()
            if s == Enum.HumanoidStateType.Physics
            or s == Enum.HumanoidStateType.Ragdoll
            or s == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)

                local cam = workspace.CurrentCamera
                if cam then cam.CameraSubject = hum end

                pcall(function()
                    local ps = player:FindFirstChild("PlayerScripts")
                    local pm = ps and ps:FindFirstChild("PlayerModule")
                    if pm then
                        local controlModule = pm:FindFirstChild("ControlModule")
                        if controlModule then require(controlModule):Enable() end
                    end
                end)

                if root then
                    pcall(function() root.AssemblyLinearVelocity = Vector3.zero end)
                    pcall(function() root.AssemblyAngularVelocity = Vector3.zero end)
                    pcall(function() root.Velocity = Vector3.zero end)
                    pcall(function() root.RotVelocity = Vector3.zero end)
                end
            end
        end

        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled = true end
        end
    end)
end

local function stopAntiRagdoll()
    if antiRagdollConn then antiRagdollConn:Disconnect(); antiRagdollConn = nil end
end

function toggleAntiRagdoll(on)
    antiRagdollEnabled = on == true
    if antiRagdollEnabled then startAntiRagdoll() else stopAntiRagdoll() end
end

-- ─── LOCK TARGET ────────────────────────────────────────
LOCK_RADIUS = 70; local LOCK_SPEED = 50
local lockGui, lockHbConn, lockLv, lockAtt, lockGyro; local lockEnabled = false

local function getNearest()
    local char = lp.Character; if not char then return nil end
    local hrp0 = char:FindFirstChild("HumanoidRootPart"); if not hrp0 then return nil end
    local nearest, nd = nil, LOCK_RADIUS
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local pc = plr.Character; local phrp = pc and pc:FindFirstChild("HumanoidRootPart")
            if phrp then local d=(phrp.Position-hrp0.Position).Magnitude; if d<=nd then nearest=plr; nd=d end end
        end
    end; return nearest
end
local function getBat()
    for _, t in ipairs(lp.Backpack:GetChildren()) do
        if t:IsA("Tool") and string.find(string.lower(t.Name),"bat",1,true) then return t end
    end
    local char = lp.Character
    if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") and string.find(string.lower(t.Name),"bat",1,true) then return t end end end
    return nil
end
local function startLock()
    local char = lp.Character; if not char then return end
    local hrp0 = char:FindFirstChild("HumanoidRootPart"); if not hrp0 then return end
    lockAtt = Instance.new("Attachment",hrp0)
    lockLv = Instance.new("LinearVelocity",hrp0); lockLv.Attachment0 = lockAtt
    lockLv.MaxForce = 50000; lockLv.RelativeTo = Enum.ActuatorRelativeTo.World; lockLv.Enabled = false
    lockGyro = Instance.new("AlignOrientation",hrp0); lockGyro.Attachment0 = lockAtt
    lockGyro.MaxTorque = 50000; lockGyro.Responsiveness = 120; lockGyro.Enabled = false
    lockHbConn = RunService.Heartbeat:Connect(function()
        local tp = getNearest()
        if not tp then lockLv.Enabled=false; lockGyro.Enabled=false; return end
        local tc = tp.Character; local thrp = tc and tc:FindFirstChild("HumanoidRootPart")
        if not thrp then lockLv.Enabled=false; lockGyro.Enabled=false; return end
        lockLv.Enabled=true; lockGyro.Enabled=true
        local fp = thrp.Position + thrp.CFrame.LookVector * 2.2; local dir = fp - hrp0.Position
        if dir.Magnitude > 0.5 then lockLv.VectorVelocity = dir.Unit * LOCK_SPEED else lockLv.VectorVelocity = Vector3.zero end
        lockGyro.CFrame = CFrame.lookAt(hrp0.Position, fp)
        local bat = getBat()
        if bat then if bat.Parent ~= char then char.Humanoid:EquipTool(bat) end; bat:Activate() end
    end)
end
local function stopLock()
    if lockHbConn then lockHbConn:Disconnect(); lockHbConn=nil end
    if lockLv then lockLv:Destroy(); lockLv=nil end
    if lockGyro then lockGyro:Destroy(); lockGyro=nil end
    if lockAtt then lockAtt:Destroy(); lockAtt=nil end
end

function createLockGui()
    if lockGui then return end
    local success, err = xpcall(function()
        lockGui = Instance.new("ScreenGui"); lockGui.Name="UGC_LockTarget"; finalizeScreenGui(lockGui)
        local btn = Instance.new("TextButton")
        btn.Size=UDim2.new(0,125,0,41)
        btn.BackgroundColor3=BTN_DARK; btn.Text="LOCK ON"; btn.Font=Enum.Font.GothamBlack
        btn.TextSize=16; btn.TextColor3=TEXT_OFF; btn.AutoButtonColor=false; btn.Parent=lockGui
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,13)
        local bs = Instance.new("UIStroke",btn); bs.Color=STROKE_OFF; bs.Thickness=1.5
        btn.Active=true
        btn.Selectable=false
        btn.ZIndex = 20
        local origS=btn.Size; local hoverS=UDim2.new(0,129,0,45); local clickS=UDim2.new(0,119,0,37)
        btn.MouseEnter:Connect(function() tw(btn,0.2,{Size=hoverS}); if not lockEnabled then tw(bs,0.2,{Color=PURPLE}) end end)
        btn.MouseLeave:Connect(function() tw(btn,0.2,{Size=origS}); if not lockEnabled then tw(bs,0.2,{Color=STROKE_OFF}) end end)
        btn.MouseButton1Down:Connect(function()
            tw(btn,0.08,{Size=clickS},Enum.EasingStyle.Back)
        end)
        btn.MouseButton1Up:Connect(function()
            tw(btn,0.1,{Size=hoverS},Enum.EasingStyle.Back)
        end)
        btn.MouseButton1Click:Connect(function()
            lockEnabled = not lockEnabled
            if lockEnabled then
                btn.Text="LOCKED"; tw(btn,0.3,{BackgroundColor3=PURPLE2}); tw(bs,0.3,{Color=STROKE_ON}); btn.TextColor3=TEXT_ON; startLock()
            else
                btn.Text="LOCK ON"; tw(btn,0.3,{BackgroundColor3=BTN_DARK}); tw(bs,0.3,{Color=STROKE_OFF}); btn.TextColor3=TEXT_OFF; stopLock()
            end
        end)
        lockBtnRef = btn
        ensureRightActionButtonsLayoutHook()
        task.wait()
        positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
        task.defer(function()
            if lockBtnRef and lockBtnRef.Parent then
                positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
            end
        end)
    end)
    if not success then
        showScreenText("UI ERROR: " .. tostring(err))
    end
end
function destroyLockGui()
    lockBtnRef=nil
    lockEnabled=false; stopLock(); if lockGui then lockGui:Destroy(); lockGui=nil end
end

-- ─── MEDUSA ─────────────────────────────────────────────
local MEDUSA_RADIUS=10; local SPAM_DELAY=0.15
local medusaPart, lastUse, AutoMedusaEnabled, MedusaInit = nil,0,false,false
local function InitMedusa()
    if MedusaInit then return end; MedusaInit = true
    local function createMR()
        if medusaPart then medusaPart:Destroy() end
        medusaPart = Instance.new("Part"); medusaPart.Name="MedusaRadius"
        medusaPart.Anchored=true; medusaPart.CanCollide=false; medusaPart.Transparency=1
        medusaPart.Material=Enum.Material.Neon; medusaPart.Color=PURPLE
        medusaPart.Shape=Enum.PartType.Cylinder
        medusaPart.Size=Vector3.new(0.05,MEDUSA_RADIUS*2,MEDUSA_RADIUS*2); medusaPart.Parent=workspace
    end
    local function medusaEquipped()
        local char=lp.Character; if not char then return nil end
        for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") and t.Name=="Medusa's Head" then return t end end
        return nil
    end
    createMR()
    RunService.RenderStepped:Connect(function()
        if not AutoMedusaEnabled then if medusaPart then medusaPart.Transparency=1 end; return end
        medusaPart.Transparency=0.72
        local char=lp.Character; if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
        medusaPart.CFrame=CFrame.new(root.Position+Vector3.new(0,-2.5,0))*CFrame.Angles(0,0,math.rad(90))
    end)
    RunService.Heartbeat:Connect(function()
        if not AutoMedusaEnabled then return end
        local char=lp.Character; if not char then return end
        local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
        local tool=medusaEquipped(); if not tool then return end
        if tick()-lastUse<SPAM_DELAY then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr~=lp then
                local pc=plr.Character; local pr=pc and pc:FindFirstChild("HumanoidRootPart")
                if pr and (pr.Position-root.Position).Magnitude<=MEDUSA_RADIUS then tool:Activate(); lastUse=tick(); break end
            end
        end
    end)
end

-- ─── SPIN BODY ──────────────────────────────────────────
local spinForce, spinGui, spinActive = nil,nil,false
local floatGui, floatActive = nil,false
local floatBodyPosition, floatHeartbeatConn, floatTargetY = nil,nil,nil
local floatSavedJumpPower, floatSavedJumpHeight, floatSavedUseJumpPower = nil,nil,nil
local floatRootRef = nil

local function updateFloatButtonVisual(on)
    if not floatBtnRef then return end
    local bs = floatBtnRef:FindFirstChildOfClass("UIStroke")
    if on then
        floatBtnRef.Text = "FLOAT"
        tw(floatBtnRef,0.25,{BackgroundColor3=PURPLE2})
        if bs then tw(bs,0.25,{Color=STROKE_ON}) end
        floatBtnRef.TextColor3 = TEXT_ON
    else
        floatBtnRef.Text = "FLOAT"
        tw(floatBtnRef,0.25,{BackgroundColor3=BTN_DARK})
        if bs then tw(bs,0.25,{Color=STROKE_OFF}) end
        floatBtnRef.TextColor3 = TEXT_OFF
    end
end

local function cleanupFloat(restoreJump)
    if floatHeartbeatConn then floatHeartbeatConn:Disconnect(); floatHeartbeatConn=nil end
    if floatBodyPosition then floatBodyPosition:Destroy(); floatBodyPosition=nil end
    floatTargetY=nil
    if restoreJump and floatRootRef and floatRootRef.Parent then
        local humanoid = floatRootRef.Parent:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if floatSavedUseJumpPower ~= nil then humanoid.UseJumpPower = floatSavedUseJumpPower end
            if floatSavedJumpPower ~= nil then humanoid.JumpPower = floatSavedJumpPower end
            if floatSavedJumpHeight ~= nil then humanoid.JumpHeight = floatSavedJumpHeight end
        end
    end
    floatSavedJumpPower, floatSavedJumpHeight, floatSavedUseJumpPower = nil,nil,nil
    floatRootRef=nil
    floatActive=false
    updateFloatButtonVisual(false)
end

local function startFloat()
    local char = lp.Character; if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return false end
    if floatBodyPosition then cleanupFloat(true) end

    floatRootRef = root
    floatSavedUseJumpPower = humanoid.UseJumpPower
    floatSavedJumpPower = humanoid.JumpPower
    floatSavedJumpHeight = humanoid.JumpHeight
    humanoid.JumpPower = 0
    humanoid.JumpHeight = 0

    floatTargetY = root.Position.Y + 10
    floatBodyPosition = Instance.new("BodyPosition")
    floatBodyPosition.Name = "UGC_FloatPosition"
    floatBodyPosition.MaxForce = Vector3.new(0, math.huge, 0)
    floatBodyPosition.P = 8000
    floatBodyPosition.D = 800
    floatBodyPosition.Position = Vector3.new(root.Position.X, floatTargetY, root.Position.Z)
    floatBodyPosition.Parent = root

    floatHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not floatActive then return end
        if not (root and root.Parent and humanoid and humanoid.Parent) then
            cleanupFloat(true)
            return
        end
        humanoid.Jump = false
        floatBodyPosition.Position = Vector3.new(root.Position.X, floatTargetY, root.Position.Z)
    end)
    return true
end

local function stopFloat()
    if not floatRootRef or not floatBodyPosition then
        cleanupFloat(true)
        return
    end
    floatTargetY = floatTargetY and (floatTargetY - 10) or (floatRootRef.Position.Y - 10)
    local root = floatRootRef
    floatBodyPosition.Position = Vector3.new(root.Position.X, floatTargetY, root.Position.Z)
    task.delay(0.35, function()
        cleanupFloat(true)
    end)
end

local function createFloatButton()
    if floatGui then return end
    local success, err = xpcall(function()
    floatGui=Instance.new("ScreenGui"); floatGui.Name="UGC_FloatGui"; finalizeScreenGui(floatGui)
    local button=Instance.new("TextButton")
    button.Size=UDim2.new(0,125,0,41)
    button.BackgroundColor3=BTN_DARK; button.Text="FLOAT"; button.Font=Enum.Font.GothamBlack
    button.TextSize=16; button.TextColor3=TEXT_OFF; button.AutoButtonColor=false; button.Parent=floatGui
    Instance.new("UICorner",button).CornerRadius=UDim.new(0,13)
    local bs=Instance.new("UIStroke",button); bs.Color=STROKE_OFF; bs.Thickness=1.5
    button.Active=true
    button.Selectable=false
    button.ZIndex = 20
    local oS=button.Size; local hS=UDim2.new(0,129,0,45); local cS=UDim2.new(0,119,0,37)
    button.MouseEnter:Connect(function() tw(button,0.2,{Size=hS}); if not floatActive then tw(bs,0.2,{Color=PURPLE}) end end)
    button.MouseLeave:Connect(function() tw(button,0.2,{Size=oS}); if not floatActive then tw(bs,0.2,{Color=STROKE_OFF}) end end)
    button.MouseButton1Down:Connect(function() tw(button,0.08,{Size=cS},Enum.EasingStyle.Back) end)
    button.MouseButton1Up:Connect(function() tw(button,0.1,{Size=hS},Enum.EasingStyle.Back) end)
    button.MouseButton1Click:Connect(function()
        if shouldSuppressButtonClick(button) then return end
        floatActive = not floatActive
        if floatActive then
            if not startFloat() then floatActive=false end
            updateFloatButtonVisual(floatActive)
        else
            updateFloatButtonVisual(false)
            stopFloat()
        end
    end)
    floatBtnRef = button
    ensureRightActionButtonsLayoutHook()
    task.wait()
    positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
    task.defer(function()
        if floatBtnRef and floatBtnRef.Parent then
            positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
        end
    end)
    end)
    if not success then
        showScreenText("UI ERROR: " .. tostring(err))
    end
end

local function destroyFloatButton()
    cleanupFloat(true)
    floatBtnRef=nil
    if floatGui then floatGui:Destroy(); floatGui=nil end
    positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
end

local function createDropButton()
    if dropGui then return end
    local success, err = pcall(function()
    dropGui=Instance.new("ScreenGui"); dropGui.Name="UGC_DropGui"; finalizeScreenGui(dropGui)
    local button=Instance.new("TextButton")
    button.Size=UDim2.new(0,125,0,41)
    button.BackgroundColor3=BTN_DARK; button.Text="DROP"; button.Font=Enum.Font.GothamBlack
    button.TextSize=16; button.TextColor3=TEXT_OFF; button.AutoButtonColor=false; button.Parent=dropGui
    Instance.new("UICorner",button).CornerRadius=UDim.new(0,13)
    local bs=Instance.new("UIStroke",button); bs.Color=STROKE_OFF; bs.Thickness=1.5
    button.Active=true
    button.Selectable=false
    button.ZIndex = 20
    local oS=button.Size; local hS=UDim2.new(0,129,0,45); local cS=UDim2.new(0,119,0,37)
    button.MouseEnter:Connect(function() tw(button,0.2,{Size=hS}); tw(bs,0.2,{Color=PURPLE}) end)
    button.MouseLeave:Connect(function() tw(button,0.2,{Size=oS}); tw(bs,0.2,{Color=STROKE_OFF}) end)
    button.MouseButton1Down:Connect(function() tw(button,0.08,{Size=cS},Enum.EasingStyle.Back) end)
    button.MouseButton1Up:Connect(function() tw(button,0.1,{Size=hS},Enum.EasingStyle.Back) end)
    button.MouseButton1Click:Connect(function()
        if shouldSuppressButtonClick(button) then return end
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0,125,0)
            task.delay(0.4, function()
                if hrp and hrp.Parent then
                    hrp.AssemblyLinearVelocity = Vector3.new(0,-600,0)
                end
            end)
        end
    end)
    dropBtnRef = button
    ensureRightActionButtonsLayoutHook()
    task.wait()
    positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
    task.defer(function()
        if dropBtnRef and dropBtnRef.Parent then
            positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
        end
    end)
    end)
    if not success then
        showScreenText("UI ERROR: " .. tostring(err))
    end
end

local function destroyDropButton()
    dropBtnRef=nil
    if dropGui then dropGui:Destroy(); dropGui=nil end
    positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
end

local function updateTpDownButtonVisual(on)
    if not tpDownBtnRef then return end
    local bs = tpDownBtnRef:FindFirstChildOfClass("UIStroke")
    if on then
        tpDownBtnRef.Text = "TP DOWN"
        tw(tpDownBtnRef,0.25,{BackgroundColor3=PURPLE2})
        if bs then tw(bs,0.25,{Color=STROKE_ON}) end
        tpDownBtnRef.TextColor3 = TEXT_ON
    else
        tpDownBtnRef.Text = "TP DOWN"
        tw(tpDownBtnRef,0.25,{BackgroundColor3=BTN_DARK})
        if bs then tw(bs,0.25,{Color=STROKE_OFF}) end
        tpDownBtnRef.TextColor3 = TEXT_OFF
    end
end

local function startTpDown()
    if tpDownConn then
        tpDownConn:Disconnect()
        tpDownConn = nil
    end
    SETTINGS.TPDOWN = true
    tpDownEnabled = true
    updateTpDownButtonVisual(true)
    tpDownConn = RunService.Heartbeat:Connect(function()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local pos = hrp.Position
        local rot = hrp.CFrame.Rotation
        hrp.CFrame = CFrame.new(pos.X, TP_DOWN_Y, pos.Z) * rot

        if tpDownConn then
            tpDownConn:Disconnect()
            tpDownConn = nil
        end
        SETTINGS.TPDOWN = false
        tpDownEnabled = false
        updateTpDownButtonVisual(false)
    end)
end

local function stopTpDown()
    if tpDownConn then
        tpDownConn:Disconnect()
        tpDownConn = nil
    end
    SETTINGS.TPDOWN = false
    tpDownEnabled = false
    updateTpDownButtonVisual(false)
end

local function createTpDownButton()
    if tpDownGui then
        updateTpDownButtonVisual(SETTINGS.TPDOWN == true)
        if SETTINGS.TPDOWN == true then startTpDown() else stopTpDown() end
        return
    end

    local success, err = pcall(function()
        tpDownGui=Instance.new("ScreenGui"); tpDownGui.Name="UGC_TpDownGui"; finalizeScreenGui(tpDownGui)
        local button=Instance.new("TextButton")
        button.Size=UDim2.new(0,125,0,41)
        button.BackgroundColor3=BTN_DARK; button.Text="TP DOWN"; button.Font=Enum.Font.GothamBlack
        button.TextSize=16; button.TextColor3=TEXT_OFF; button.AutoButtonColor=false; button.Parent=tpDownGui
        Instance.new("UICorner",button).CornerRadius=UDim.new(0,13)
        local bs=Instance.new("UIStroke",button); bs.Color=STROKE_OFF; bs.Thickness=1.5
        button.Active=true
        button.Selectable=false
        button.ZIndex = 20
        local oS=button.Size; local hS=UDim2.new(0,129,0,45); local cS=UDim2.new(0,119,0,37)
        button.MouseEnter:Connect(function() tw(button,0.2,{Size=hS}); if not (SETTINGS.TPDOWN == true) then tw(bs,0.2,{Color=PURPLE}) end end)
        button.MouseLeave:Connect(function() tw(button,0.2,{Size=oS}); if not (SETTINGS.TPDOWN == true) then tw(bs,0.2,{Color=STROKE_OFF}) end end)
        button.MouseButton1Down:Connect(function() tw(button,0.08,{Size=cS},Enum.EasingStyle.Back) end)
        button.MouseButton1Up:Connect(function() tw(button,0.1,{Size=hS},Enum.EasingStyle.Back) end)
        button.MouseButton1Click:Connect(function()
            if shouldSuppressButtonClick(button) then return end
            if floatActive or floatBodyPosition or floatHeartbeatConn then
                floatActive = false
                cleanupFloat(true)
                updateFloatButtonVisual(false)
            end

            if tpDownConn or tpDownEnabled or SETTINGS.TPDOWN == true then
                stopTpDown()
            else
                startTpDown()
            end
        end)

        tpDownBtnRef = button
        ensureRightActionButtonsLayoutHook()
        task.wait()
        positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
        task.defer(function()
            if tpDownBtnRef and tpDownBtnRef.Parent then
                positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
            end
        end)

        tpDownEnabled = SETTINGS.TPDOWN == true
        updateTpDownButtonVisual(tpDownEnabled)
        if tpDownEnabled then startTpDown() else stopTpDown() end
    end)
    if not success then
        showScreenText("UI ERROR: " .. tostring(err))
    end
end

local function destroyTpDownButton()
    stopTpDown()
    SETTINGS.TPDOWN = false
    tpDownEnabled = false
    tpDownBtnRef=nil
    if tpDownGui then tpDownGui:Destroy(); tpDownGui=nil end
    positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
end

local function startSpinBody()
    local char=lp.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); if not root or spinForce then return end
    spinForce=Instance.new("BodyAngularVelocity"); spinForce.Name="SpinForce"
    spinForce.AngularVelocity=Vector3.new(0,25,0); spinForce.MaxTorque=Vector3.new(0,math.huge,0)
    spinForce.P=1250; spinForce.Parent=root
end
local function stopSpinBody() if spinForce then spinForce:Destroy(); spinForce=nil end end
local function createSpinButton()
    if spinGui then return end
    local success, err = pcall(function()
    spinGui=Instance.new("ScreenGui"); spinGui.Name="UGC_SpinGui"; finalizeScreenGui(spinGui)
    local button=Instance.new("TextButton")
    button.Size=UDim2.new(0,125,0,41)
    button.BackgroundColor3=BTN_DARK; button.Text="SPIN"; button.Font=Enum.Font.GothamBlack
    button.TextSize=16; button.TextColor3=TEXT_OFF; button.AutoButtonColor=false; button.Parent=spinGui
    Instance.new("UICorner",button).CornerRadius=UDim.new(0,13)
    local bs=Instance.new("UIStroke",button); bs.Color=STROKE_OFF; bs.Thickness=1.5
    button.Active=true
    button.Selectable=false
    button.ZIndex = 20
    local oS=button.Size; local hS=UDim2.new(0,129,0,45); local cS=UDim2.new(0,119,0,37)
    button.MouseEnter:Connect(function() tw(button,0.2,{Size=hS}); if not spinActive then tw(bs,0.2,{Color=PURPLE}) end end)
    button.MouseLeave:Connect(function() tw(button,0.2,{Size=oS}); if not spinActive then tw(bs,0.2,{Color=STROKE_OFF}) end end)
    button.MouseButton1Down:Connect(function() tw(button,0.08,{Size=cS},Enum.EasingStyle.Back) end)
    button.MouseButton1Up:Connect(function() tw(button,0.1,{Size=hS},Enum.EasingStyle.Back) end)
    button.MouseButton1Click:Connect(function()
        if shouldSuppressButtonClick(button) then return end
        spinActive=not spinActive
        if spinActive then button.Text="SPINNING"; tw(button,0.3,{BackgroundColor3=PURPLE2}); tw(bs,0.3,{Color=STROKE_ON}); button.TextColor3=TEXT_ON; startSpinBody()
        else button.Text="SPIN"; tw(button,0.3,{BackgroundColor3=BTN_DARK}); tw(bs,0.3,{Color=STROKE_OFF}); button.TextColor3=TEXT_OFF; stopSpinBody() end
    end)
    spinBtnRef = button
    ensureRightActionButtonsLayoutHook()
    task.wait()
    positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
    task.defer(function()
        if spinBtnRef and spinBtnRef.Parent then
            positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
        end
    end)
    end)
    if not success then
        showScreenText("UI ERROR: " .. tostring(err))
    end
end
local function removeSpinButton()
    stopSpinBody()
    spinActive=false
    spinBtnRef=nil
    if spinGui then spinGui:Destroy(); spinGui=nil end
    positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
end

local speedBox, stealBox, configPasteBox

-- ─── AUTO PLAY ──────────────────────────────────────────
local autoPlayEnabled=false; local autoPlayGui=nil; local autoPlayHeartbeatConn=nil; local autoPlayRespawnConn=nil
local autoPlayLeftBtn=nil; local autoPlayRightBtn=nil; local autoPlayLeftStroke=nil; local autoPlayRightStroke=nil
local LeftPhase, RightPhase = 1, 1
local LeftStartPos, RightStartPos = nil, nil

local L_POS_1      = Vector3.new(-476.48, -6.28, 92.73)
local L_POS_END    = Vector3.new(-483.12, -4.95, 94.80)
local L_POS_RETURN = Vector3.new(-475, -8, 19)
local L_POS_FINAL  = Vector3.new(-488, -6, 19)

local R_POS_1      = Vector3.new(-476.16, -6.52, 25.62)
local R_POS_END    = Vector3.new(-483.04, -5.09, 23.14)
local R_POS_RETURN = Vector3.new(-476, -8, 99)
local R_POS_FINAL  = Vector3.new(-488, -6, 102)

local function getAutoPlaySpeeds()
    local normalSpeed = 59.9
    local stealSpeed = 29.9

    if typeof(speedBox) == "Instance" and speedBox:IsA("TextBox") then
        local n=tonumber(speedBox.Text)
        if n and n>0 then normalSpeed=n end
    end

    if typeof(stealBox) == "Instance" and stealBox:IsA("TextBox") then
        local s=tonumber(stealBox.Text)
        if s and s>0 then stealSpeed=s end
    elseif tonumber(SETTINGS.STEAL_SPEED) and SETTINGS.STEAL_SPEED>0 then
        stealSpeed=SETTINGS.STEAL_SPEED
    end

    return normalSpeed, stealSpeed
end

local function getCurrentAutoPlayTarget(side, phase)
    if side=="Left" then
        if phase==1 then return L_POS_1 end
        if phase==2 then return L_POS_END end
        if phase==3 then return L_POS_1 end
        if phase==4 then return L_POS_RETURN end
        if phase==5 then return L_POS_FINAL end
    elseif side=="Right" then
        if phase==1 then return R_POS_1 end
        if phase==2 then return R_POS_END end
        if phase==3 then return R_POS_1 end
        if phase==4 then return R_POS_RETURN end
        if phase==5 then return R_POS_FINAL end
    end
    return nil
end

local function updateAutoPlayButtonVisuals()
    if autoPlayLeftBtn then
        local on=SETTINGS.AUTOLEFT
        autoPlayLeftBtn.BackgroundColor3=on and PURPLE2 or BTN_DARK
        autoPlayLeftBtn.TextColor3=on and TEXT_ON or TEXT_OFF
        if autoPlayLeftStroke then autoPlayLeftStroke.Color=on and STROKE_ON or STROKE_OFF end
    end
    if autoPlayRightBtn then
        local on=SETTINGS.AUTORIGHT
        autoPlayRightBtn.BackgroundColor3=on and PURPLE2 or BTN_DARK
        autoPlayRightBtn.TextColor3=on and TEXT_ON or TEXT_OFF
        if autoPlayRightStroke then autoPlayRightStroke.Color=on and STROKE_ON or STROKE_OFF end
    end
end

local function setAutoLeftState(on)
    SETTINGS.AUTOLEFT=on==true
    if SETTINGS.AUTOLEFT then SETTINGS.AUTORIGHT=false end
    updateAutoPlayButtonVisuals()
end

local function setAutoRightState(on)
    SETTINGS.AUTORIGHT=on==true
    if SETTINGS.AUTORIGHT then SETTINGS.AUTOLEFT=false end
    updateAutoPlayButtonVisuals()
end

local function resetAutoPlayState()
    SETTINGS.AUTOLEFT=false; SETTINGS.AUTORIGHT=false
    LeftPhase, RightPhase = 1, 1
    LeftStartPos, RightStartPos = nil, nil
    updateAutoPlayButtonVisuals()
end

local function stopAutoPlayHeartbeat()
    if autoPlayHeartbeatConn then autoPlayHeartbeatConn:Disconnect(); autoPlayHeartbeatConn=nil end
end

local function startAutoPlayHeartbeat()
    if autoPlayHeartbeatConn then return end
    autoPlayHeartbeatConn=RunService.Heartbeat:Connect(function()
        if not (SETTINGS.AUTOLEFT or SETTINGS.AUTORIGHT) then return end
        if SETTINGS.AUTOLEFT and SETTINGS.AUTORIGHT then
            SETTINGS.AUTORIGHT=false
            setAutoRightState(false)
        end

        local char=player.Character; if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end

        local activeSide = SETTINGS.AUTOLEFT and "Left" or (SETTINGS.AUTORIGHT and "Right" or nil)
        if not activeSide then return end

        local phase = (activeSide=="Left") and LeftPhase or RightPhase
        local target = getCurrentAutoPlayTarget(activeSide, phase)
        if not target then
            if activeSide=="Left" then
                SETTINGS.AUTOLEFT=false; setAutoLeftState(false); LeftPhase=1; LeftStartPos=nil
            else
                SETTINGS.AUTORIGHT=false; setAutoRightState(false); RightPhase=1; RightStartPos=nil
            end
            return
        end

        local normalSpeed, stealSpeed = getAutoPlaySpeeds()
        local speed = (phase>=3) and stealSpeed or normalSpeed
        local targetFlat = Vector3.new(target.X, hrp.Position.Y, target.Z)
        local dist = (targetFlat - hrp.Position).Magnitude
        if dist < 0.5 then
            if activeSide=="Left" then
                if LeftPhase < 5 then LeftPhase=LeftPhase+1
                else SETTINGS.AUTOLEFT=false; setAutoLeftState(false); LeftPhase=1; LeftStartPos=nil end
            else
                if RightPhase < 5 then RightPhase=RightPhase+1
                else SETTINGS.AUTORIGHT=false; setAutoRightState(false); RightPhase=1; RightStartPos=nil end
            end
            return
        end

        local delta = target - hrp.Position
        local flatDelta = Vector3.new(delta.X,0,delta.Z)
        if flatDelta.Magnitude<=0 then return end
        local dir=flatDelta.Unit
        hrp.AssemblyLinearVelocity=Vector3.new(dir.X*speed,hrp.AssemblyLinearVelocity.Y,dir.Z*speed)
    end)
end

local function createAutoPlayGui()
    if autoPlayGui then return end
    local success, err = pcall(function()
    autoPlayGui=Instance.new("ScreenGui"); autoPlayGui.Name="UGC_AutoPlayGui"; finalizeScreenGui(autoPlayGui)

    local holder=Instance.new("Frame")
    holder.Size=UDim2.new(0,125,0,41)
    holder.BackgroundColor3=BTN_DARK; holder.BorderSizePixel=0; holder.Parent=autoPlayGui
    holder.Active=true; holder.Selectable=false; holder.ZIndex=20
    Instance.new("UICorner",holder).CornerRadius=UDim.new(0,13)
    local holderStroke=Instance.new("UIStroke",holder); holderStroke.Color=STROKE_OFF; holderStroke.Thickness=1.5

    local title=Instance.new("TextLabel")
    title.Size=UDim2.new(1,0,0,12); title.Position=UDim2.new(0,0,0,2)
    title.BackgroundTransparency=1; title.Text="AUTO PLAY"; title.Font=Enum.Font.GothamBlack; title.TextSize=11
    title.TextColor3=TEXT_OFF; title.ZIndex=21; title.Parent=holder

    local divider=Instance.new("Frame")
    divider.Size=UDim2.new(0,2,1,-18); divider.Position=UDim2.new(0.5,-1,0,14)
    divider.BorderSizePixel=0; divider.BackgroundColor3=PURPLE; divider.ZIndex=22; divider.Parent=holder

    local function makeHalf(text, xPos)
        local btn=Instance.new("TextButton")
        btn.Size=UDim2.new(0.5,-1,1,-16); btn.Position=UDim2.new(xPos,0,0,14)
        btn.BackgroundColor3=BTN_DARK; btn.Text=text; btn.Font=Enum.Font.GothamBlack; btn.TextSize=16
        btn.TextColor3=TEXT_OFF; btn.AutoButtonColor=false; btn.Active=true; btn.Selectable=false; btn.ZIndex=21; btn.Parent=holder
        local st=Instance.new("UIStroke",btn); st.Color=STROKE_OFF; st.Thickness=1.2
        local cr=Instance.new("UICorner",btn); cr.CornerRadius=UDim.new(0,10)
        return btn, st
    end

    autoPlayLeftBtn, autoPlayLeftStroke = makeHalf("L", 0)
    autoPlayRightBtn, autoPlayRightStroke = makeHalf("R", 0.5)

    local oS=holder.Size; local hS=UDim2.new(0,129,0,45); local cS=UDim2.new(0,119,0,37)
    local function hover(on)
        if on then tw(holder,0.2,{Size=hS}); tw(holderStroke,0.2,{Color=PURPLE})
        else tw(holder,0.2,{Size=oS}); tw(holderStroke,0.2,{Color=STROKE_OFF}) end
    end
    holder.MouseEnter:Connect(function() hover(true) end)
    holder.MouseLeave:Connect(function() hover(false) end)
    holder.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then tw(holder,0.08,{Size=cS},Enum.EasingStyle.Back) end
    end)
    holder.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then tw(holder,0.1,{Size=hS},Enum.EasingStyle.Back) end
    end)

    autoPlayLeftBtn.MouseButton1Click:Connect(function()
        if shouldSuppressButtonClick(holder) then return end
        local on=not SETTINGS.AUTOLEFT
        SETTINGS.AUTOLEFT=on
        if on then SETTINGS.AUTORIGHT=false; RightPhase, RightStartPos = 1, nil end
        LeftPhase=1; LeftStartPos=nil
        setAutoLeftState(SETTINGS.AUTOLEFT)
        updateAutoPlayButtonVisuals()
    end)

    autoPlayRightBtn.MouseButton1Click:Connect(function()
        if shouldSuppressButtonClick(holder) then return end
        local on=not SETTINGS.AUTORIGHT
        SETTINGS.AUTORIGHT=on
        if on then SETTINGS.AUTOLEFT=false; LeftPhase, LeftStartPos = 1, nil end
        RightPhase=1; RightStartPos=nil
        setAutoRightState(SETTINGS.AUTORIGHT)
        updateAutoPlayButtonVisuals()
    end)

    if autoPlayRespawnConn then autoPlayRespawnConn:Disconnect(); autoPlayRespawnConn=nil end
    autoPlayRespawnConn=player.CharacterAdded:Connect(function()
        resetAutoPlayState()
    end)

    autoPlayGui.AncestryChanged:Connect(function()
        if autoPlayGui and not autoPlayGui.Parent then
            stopAutoPlayHeartbeat()
            resetAutoPlayState()
            if autoPlayRespawnConn then autoPlayRespawnConn:Disconnect(); autoPlayRespawnConn=nil end
        end
    end)

    walkBtnRef = holder
    ensureRightActionButtonsLayoutHook()
    task.wait()
    positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
    task.defer(function()
        if walkBtnRef and walkBtnRef.Parent then
            positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
        end
    end)

    updateAutoPlayButtonVisuals()
    startAutoPlayHeartbeat()
    end)
    if not success then
        showScreenText("UI ERROR: " .. tostring(err))
    end
end

local function destroyAutoPlayGui()
    stopAutoPlayHeartbeat()
    resetAutoPlayState()
    if autoPlayRespawnConn then autoPlayRespawnConn:Disconnect(); autoPlayRespawnConn=nil end
    autoPlayLeftBtn=nil; autoPlayRightBtn=nil; autoPlayLeftStroke=nil; autoPlayRightStroke=nil
    walkBtnRef=nil
    if autoPlayGui then autoPlayGui:Destroy(); autoPlayGui=nil end
    positionRightSideActionButtons(spinBtnRef, floatBtnRef, dropBtnRef, tpDownBtnRef, lockBtnRef, walkBtnRef)
end

-- ─── CHARACTER SETUP ────────────────────────────────────
local function createSelfOverheadTag(characterModel)
    if not characterModel then return end
    local head = characterModel:FindFirstChild("Head")
    if not head then return end
    local existingTag = characterModel:FindFirstChild("UGC_SelfDiscordTag")
    if existingTag then existingTag:Destroy() end

    local tagGui = Instance.new("BillboardGui")
    tagGui.Name = "UGC_SelfDiscordTag"
    tagGui.Adornee = head
    tagGui.AlwaysOnTop = true
    tagGui.Size = UDim2.new(0, 260, 0, 50)
    tagGui.StudsOffset = Vector3.new(0, 3.5, 0)
    tagGui.Parent = characterModel

    local tagText = Instance.new("TextLabel")
    tagText.Size = UDim2.new(1, 0, 1, 0)
    tagText.BackgroundTransparency = 1
    tagText.Text = "discord.gg/F4eknseBRK"
    tagText.TextColor3 = Color3.fromRGB(255,255,255)
    tagText.Font = Enum.Font.GothamBold
    tagText.TextScaled = true
    tagText.TextStrokeTransparency = 0.3
    tagText.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    tagText.Parent = tagGui
end

local function setupCharacter(char)
    cleanupFloat(true)
    character=char; hrp=character:WaitForChild("HumanoidRootPart"); hum=character:WaitForChild("Humanoid")
    createSelfOverheadTag(char)
    if meleeEnabled then task.spawn(function() task.wait(0.3); createMeleeAimbot(char) end) end
end
if player.Character then setupCharacter(player.Character) end
player.CharacterAdded:Connect(setupCharacter)

-- ══════════════════════════════════════════════════════════
--  ██╗   ██╗██╗
--  ██║   ██║██║
--  ██║   ██║██║     INTERFACE — STYLE SCRIPT 2 SMOOTH
--  ██║   ██║██║
--  ╚██████╔╝██║
--   ╚═════╝ ╚═╝
-- ══════════════════════════════════════════════════════════

-- Clean existing GUIs
for _, n in ipairs({"UGC_Duels","UGC_SpeedCustomizer"}) do
    if playerGui:FindFirstChild(n) then playerGui[n]:Destroy() end
end

-- ══════════════════════════════════════════
-- SPEED CUSTOMIZER (sub-window, style script2)
-- ══════════════════════════════════════════
local scGui
local infiniteJumpEnabled=false
local scSuccess, scErr = pcall(function()
scGui = Instance.new("ScreenGui"); scGui.Name="UGC_SpeedCustomizer"; finalizeScreenGui(scGui); scGui.Enabled=false

local scFrame = Instance.new("Frame"); scFrame.Name="MainFrame"
scFrame.Size=UDim2.new(0,240,0,200); scFrame.AnchorPoint=Vector2.new(1,0.5)
scFrame.Position=UDim2.new(1,-200,0.5,0); scFrame.BackgroundColor3=BG_DARK; scFrame.BackgroundTransparency=0.05
scFrame.BorderSizePixel=0; scFrame.Parent=scGui
Instance.new("UICorner",scFrame).CornerRadius=UDim.new(0,16)
local scStroke=Instance.new("UIStroke",scFrame); scStroke.Color=PURPLE; scStroke.Thickness=2

local scTitle=Instance.new("TextLabel"); scTitle.Size=UDim2.new(1,0,0,44); scTitle.BackgroundTransparency=1
scTitle.Text="⚡ Speed Customizer"; scTitle.Font=Enum.Font.GothamBlack; scTitle.TextSize=13
scTitle.TextColor3=PURPLE; scTitle.Active=true; scTitle.Selectable=false; scTitle.Parent=scFrame

local scDragBar=Instance.new("TextButton"); scDragBar.Name="DragBar"; scDragBar.Size=UDim2.new(1,0,0,44)
scDragBar.Position=UDim2.new(0,0,0,0); scDragBar.BackgroundTransparency=1; scDragBar.Text=""; scDragBar.AutoButtonColor=false
scDragBar.Active=true; scDragBar.Selectable=false; scDragBar.ZIndex=scTitle.ZIndex+1; scDragBar.Parent=scFrame

local scDragOk, scDragErr = pcall(function()
    makeDraggable(scFrame, scDragBar)
end)
if not scDragOk then
    showScreenText("[Galaxy Hub] Speed Customizer drag setup failed: " .. tostring(scDragErr))
end

-- activate button
local scActive=false; local scConn=nil
local scBtn=Instance.new("TextButton"); scBtn.Size=UDim2.new(1,-20,0,40); scBtn.Position=UDim2.new(0,10,0,44)
scBtn.BackgroundColor3=BTN_DARK; scBtn.Text="OFF"; scBtn.Font=Enum.Font.GothamBlack; scBtn.TextSize=14
scBtn.TextColor3=TEXT_OFF; scBtn.AutoButtonColor=false; scBtn.Parent=scFrame
Instance.new("UICorner",scBtn).CornerRadius=UDim.new(0,11)
local scBs=Instance.new("UIStroke",scBtn); scBs.Color=STROKE_OFF; scBs.Thickness=1.5
local sInf=TweenInfo.new(0.1,Enum.EasingStyle.Back)
local scOrigS=scBtn.Size; local scHovS=UDim2.new(1,-16,0,44); local scClkS=UDim2.new(1,-26,0,36)
scBtn.MouseEnter:Connect(function() tw(scBtn,0.2,{Size=scHovS}); if not scActive then tw(scBs,0.2,{Color=PURPLE}) end end)
scBtn.MouseLeave:Connect(function() tw(scBtn,0.2,{Size=scOrigS}); if not scActive then tw(scBs,0.2,{Color=STROKE_OFF}) end end)
scBtn.MouseButton1Down:Connect(function() TweenService:Create(scBtn,sInf,{Size=scClkS}):Play() end)
scBtn.MouseButton1Up:Connect(function() TweenService:Create(scBtn,sInf,{Size=scHovS}):Play() end)

local function scMakeRow(label,posY,def)
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(0.5,0,0,26); lbl.Position=UDim2.new(0,14,0,posY)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.Font=Enum.Font.Gotham; lbl.TextSize=12
    lbl.TextColor3=Color3.fromRGB(140,140,140); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=scFrame
    local box=Instance.new("TextBox"); box.Size=UDim2.new(0,80,0,26); box.Position=UDim2.new(1,-92,0,posY)
    box.BackgroundColor3=BTN_DARK; box.TextColor3=TEXT_ON; box.Font=Enum.Font.GothamBold; box.TextSize=13
    box.Text=tostring(def); box.ClearTextOnFocus=false; box.Parent=scFrame
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,7)
    Instance.new("UIStroke",box).Color=STROKE_OFF
    return box
end
speedBox=scMakeRow("Vitesse",92,53); stealBox=scMakeRow("Vol Speed",124,29); local jumpBox=scMakeRow("Saut",156,60)

local function applyBI(box,mn,mx,def) box.FocusLost:Connect(function() local n=tonumber(box.Text:gsub("%D","")) or def; box.Text=tostring(math.clamp(n,mn,mx)) end) end
applyBI(speedBox,15,200,53); applyBI(stealBox,15,200,29); applyBI(jumpBox,50,200,60)

local sNoSteal,sSteal=52,28

scBtn.MouseButton1Click:Connect(function()
    scActive=not scActive
    if scActive then
        scBtn.Text="ON"; tw(scBtn,0.3,{BackgroundColor3=PURPLE2}); tw(scBs,0.3,{Color=STROKE_ON}); scBtn.TextColor3=TEXT_ON
        scConn=RunService.Heartbeat:Connect(function()
            if character and hrp and hum then
                sNoSteal=tonumber(speedBox.Text) or 53; sSteal=tonumber(stealBox.Text) or 29
                if hum.MoveDirection.Magnitude>0 then
                    local sp=(hum.WalkSpeed<25) and sSteal or sNoSteal
                    hrp.AssemblyLinearVelocity=Vector3.new(hum.MoveDirection.X*sp,hrp.AssemblyLinearVelocity.Y,hum.MoveDirection.Z*sp)
                end
            end
        end)
    else
        scBtn.Text="OFF"; tw(scBtn,0.3,{BackgroundColor3=BTN_DARK}); tw(scBs,0.3,{Color=STROKE_OFF}); scBtn.TextColor3=TEXT_OFF
        if scConn then scConn:Disconnect(); scConn=nil end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if not character or not hum or not hrp then return end
    local state=hum:GetState()
    if scActive and (state==Enum.HumanoidStateType.Running or state==Enum.HumanoidStateType.Landed) then
        hrp.AssemblyLinearVelocity=Vector3.new(hrp.AssemblyLinearVelocity.X,tonumber(jumpBox.Text) or 70,hrp.AssemblyLinearVelocity.Z)
    end
    if infiniteJumpEnabled then hrp.AssemblyLinearVelocity=Vector3.new(hrp.AssemblyLinearVelocity.X,50,hrp.AssemblyLinearVelocity.Z) end
end)
end)
if not scSuccess then
    showScreenText("UI ERROR: " .. tostring(scErr))
end

-- ══════════════════════════════════════════
-- SLOW FALL + AUTO STEAL
-- ══════════════════════════════════════════
local slowFallEnabled=false
local defaultVisualLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    FogColor = Lighting.FogColor,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
}
local purpleSkyApplied = false
local fpsBoostApplied = false
local purpleSkyRef = nil
local purpleColorCorrection = nil

local function ensurePurpleSky()
    if purpleSkyApplied then return end
    purpleSkyApplied = true
    local sky = Lighting:FindFirstChild("GalaxyHubPurpleSky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "GalaxyHubPurpleSky"
        sky.Parent = Lighting
    end
    sky.SkyboxBk = "rbxassetid://159454299"
    sky.SkyboxDn = "rbxassetid://159454296"
    sky.SkyboxFt = "rbxassetid://159454293"
    sky.SkyboxLf = "rbxassetid://159454286"
    sky.SkyboxRt = "rbxassetid://159454300"
    sky.SkyboxUp = "rbxassetid://159454288"
    purpleSkyRef = sky

    Lighting.Ambient = Color3.fromRGB(95, 65, 140)
    Lighting.FogColor = Color3.fromRGB(120, 80, 170)

    local cc = Lighting:FindFirstChild("GalaxyHubPurpleCC")
    if not cc then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "GalaxyHubPurpleCC"
        cc.Parent = Lighting
    end
    cc.TintColor = Color3.fromRGB(210, 170, 255)
    cc.Saturation = 0.06
    cc.Contrast = 0.08
    purpleColorCorrection = cc
end

local function disablePurpleSky()
    if not purpleSkyApplied then return end
    purpleSkyApplied = false
    Lighting.Ambient = defaultVisualLighting.Ambient
    Lighting.FogColor = defaultVisualLighting.FogColor
    if purpleColorCorrection and purpleColorCorrection.Parent then
        purpleColorCorrection:Destroy()
    end
    purpleColorCorrection = nil
    if purpleSkyRef and purpleSkyRef.Parent then
        purpleSkyRef:Destroy()
    end
    purpleSkyRef = nil
end

local function ensureFpsBooster()
    if fpsBoostApplied then return end
    fpsBoostApplied = true
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e9
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
end

local function disableFpsBooster()
    if not fpsBoostApplied then return end
    fpsBoostApplied = false
    Lighting.GlobalShadows = defaultVisualLighting.GlobalShadows
    Lighting.FogEnd = defaultVisualLighting.FogEnd
    Lighting.EnvironmentDiffuseScale = defaultVisualLighting.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = defaultVisualLighting.EnvironmentSpecularScale
end

RunService.Heartbeat:Connect(function()
    local cam = workspace.CurrentCamera
    if cam then
        if SETTINGS.STRETCH_REZ then
            cam.FieldOfView = 120
        else
            cam.FieldOfView = 70
        end
    end

    if SETTINGS.NIGHT_TIME then
        Lighting.ClockTime = 0
        Lighting.Brightness = 0.2
        Lighting.Ambient = Color3.fromRGB(20, 20, 35)
    else
        Lighting.ClockTime = 14
        Lighting.Brightness = defaultVisualLighting.Brightness
        Lighting.Ambient = defaultVisualLighting.Ambient
    end

    if SETTINGS.PURPLE_SKY then
        ensurePurpleSky()
    else
        disablePurpleSky()
    end

    if SETTINGS.FPS_BOOSTER then
        ensureFpsBooster()
    else
        disableFpsBooster()
    end
end)

RunService.Heartbeat:Connect(function()
    if not slowFallEnabled then return end
    local char=lp.Character; if not char then return end
    local hm=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
    if not hm or not root then return end
    if hm:GetState()==Enum.HumanoidStateType.Freefall then
        local vel=root.AssemblyLinearVelocity; if vel.Y<-1 then root.AssemblyLinearVelocity=Vector3.new(vel.X,vel.Y*0.5,vel.Z) end
    end
end)

local autoStealEnabled=false; local grabRadius=50
local stealCircle=nil
local stealCircleConn=nil
local animalCache = {}
local promptCache = {}
local stealCache = {}
local isStealing = false
local AnimalsData = {}
local function hideStealCircle() if stealCircle then stealCircle:Destroy(); stealCircle=nil end end
local function updateStealCircle()
    if stealCircle and lp.Character then
        local root=lp.Character:FindFirstChild("HumanoidRootPart")
        if root then stealCircle.CFrame=CFrame.new(root.Position+Vector3.new(0,-2.5,0))*CFrame.Angles(0,0,math.rad(90)) end
    end
end
local function createStealCircle(r)
    if not stealCircle then
        stealCircle=Instance.new("Part"); stealCircle.Name="UGC_StealR"; stealCircle.Anchored=true; stealCircle.CanCollide=false
        stealCircle.Transparency=0.72; stealCircle.Material=Enum.Material.Neon; stealCircle.Color=PURPLE
        stealCircle.Shape=Enum.PartType.Cylinder; stealCircle.Size=Vector3.new(0.05,r*2,r*2); stealCircle.Parent=workspace
    else stealCircle.Size=Vector3.new(0.05,r*2,r*2) end
end

pcall(function()
    local datas = game:GetService("ReplicatedStorage"):FindFirstChild("Datas")
    if datas then
        local animals = datas:FindFirstChild("Animals")
        if animals then AnimalsData = require(animals) end
    end
end)

local function stealHRP()
    local c = lp.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")
end

local function isMyBase(plotName)
    local plot = workspace.Plots and workspace.Plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if not sign then return false end
    local yb = sign:FindFirstChild("YourBase")
    return yb and yb:IsA("BillboardGui") and yb.Enabled == true
end

local function scanPlot(plot)
    if not plot or not plot:IsA("Model") then return end
    if isMyBase(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return end
    for _, pod in ipairs(podiums:GetChildren()) do
        if pod:IsA("Model") and pod:FindFirstChild("Base") then
            local name = "Unknown"
            local spawn = pod.Base:FindFirstChild("Spawn")
            if spawn then
                for _, child in ipairs(spawn:GetChildren()) do
                    if child:IsA("Model") and child.Name ~= "PromptAttachment" then
                        name = child.Name
                        local info = AnimalsData[name]
                        if info and info.DisplayName then name = info.DisplayName end
                        break
                    end
                end
            end
            table.insert(animalCache, {
                name = name,
                plot = plot.Name,
                slot = pod.Name,
                worldPosition = pod:GetPivot().Position,
                uid = plot.Name .. "*" .. pod.Name,
            })
        end
    end
end

local function findPrompt(ad)
    if not ad then return nil end
    local cp = promptCache[ad.uid]
    if cp and cp.Parent then return cp end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local plot = plots:FindFirstChild(ad.plot)
    if not plot then return nil end
    local pods = plot:FindFirstChild("AnimalPodiums")
    if not pods then return nil end
    local pod = pods:FindFirstChild(ad.slot)
    if not pod then return nil end
    local base = pod:FindFirstChild("Base")
    if not base then return nil end
    local sp = base:FindFirstChild("Spawn")
    if not sp then return nil end
    local att = sp:FindFirstChild("PromptAttachment")
    if not att then return nil end
    for _, p in ipairs(att:GetChildren()) do
        if p:IsA("ProximityPrompt") then
            promptCache[ad.uid] = p
            return p
        end
    end
end

local function buildCallbacks(prompt)
    if stealCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(c1) == "table" then
        for _, conn in ipairs(c1) do
            if type(conn.Function) == "function" then
                table.insert(data.holdCallbacks, conn.Function)
            end
        end
    end
    local ok2, c2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(c2) == "table" then
        for _, conn in ipairs(c2) do
            if type(conn.Function) == "function" then
                table.insert(data.triggerCallbacks, conn.Function)
            end
        end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
        stealCache[prompt] = data
    end
end

local function execSteal(prompt)
    local data = stealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    isStealing = true
    task.spawn(function()
        for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
        task.wait(0.2)
        for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
        task.wait(0.01)
        data.ready = true
        task.wait(0.01)
        isStealing = false
    end)
    return true
end

local function nearestAnimal()
    local h = stealHRP()
    if not h then return nil end
    local best, bestD = nil, math.huge
    for _, ad in ipairs(animalCache) do
        if not isMyBase(ad.plot) and ad.worldPosition then
            local d = (h.Position - ad.worldPosition).Magnitude
            if d < bestD then
                bestD = d
                best = ad
            end
        end
    end
    return best
end

task.spawn(function()
    task.wait(2)
    local plots = workspace:WaitForChild("Plots", 10)
    if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") then scanPlot(plot) end
    end
    plots.ChildAdded:Connect(function(plot)
        if plot:IsA("Model") then task.wait(0.5); scanPlot(plot) end
    end)
    task.spawn(function()
        while task.wait(5) do
            animalCache = {}
            for _, plot in ipairs(plots:GetChildren()) do
                if plot:IsA("Model") then scanPlot(plot) end
            end
        end
    end)
end)

local autoBatActive=false; local autoBatLoop=nil; local savedAnimate=nil

-- ══════════════════════════════════════════
-- MAIN SCREEN GUI
-- ══════════════════════════════════════════
local success, err = pcall(function()
local sg=Instance.new("ScreenGui"); sg.Name="UGC_Duels"; finalizeScreenGui(sg)
showScreenText("MAIN UI CREATED")

-- Progress bar
local pbBg=Instance.new("Frame"); pbBg.Size=UDim2.new(0,260,0,13); pbBg.Position=UDim2.new(0.5,-130,0,8)
pbBg.BackgroundColor3=BTN_DARK; pbBg.BackgroundTransparency=0.2; pbBg.Visible=false; pbBg.Parent=sg
Instance.new("UICorner",pbBg).CornerRadius=UDim.new(1,0)
local pbFill=Instance.new("Frame"); pbFill.Size=UDim2.new(0,0,1,0); pbFill.BackgroundColor3=PURPLE2; pbFill.Parent=pbBg
Instance.new("UICorner",pbFill).CornerRadius=UDim.new(1,0)
local pbPct=Instance.new("TextLabel"); pbPct.Size=UDim2.new(1,0,1,0); pbPct.BackgroundTransparency=1
pbPct.Font=Enum.Font.GothamBold; pbPct.TextSize=9; pbPct.TextColor3=TEXT_ON; pbPct.Text="0%"; pbPct.Parent=pbBg
local function resetBar(hide)
    pbFill.Size=UDim2.new(0,0,1,0)
    pbPct.Text="0%"
    if hide then pbBg.Visible=false end
end

RunService.Heartbeat:Connect(function()
    if not autoStealEnabled or isStealing then return end
    local target = nearestAnimal()
    if not target then return end
    local h = stealHRP()
    if not h then return end
    if (h.Position - target.worldPosition).Magnitude > grabRadius then return end
    local prompt = promptCache[target.uid]
    if not prompt or not prompt.Parent then prompt = findPrompt(target) end
    if prompt then
        buildCallbacks(prompt)
        execSteal(prompt)
    end
end)

-- ── TOP BAR (LEFT SIDE, CLICKABLE) ──
local GUI_WIDTH = 260
local GUI_HEIGHT = 420
local TOP_GAP = 16
local GAP_BETWEEN_TOPBAR_AND_PANEL = 8
local menuOpen = true

-- Small reopen button (hidden by default, appears when menu is closed)
local reopenBtn=Instance.new("TextButton"); reopenBtn.Name="ReopenBtn"
reopenBtn.Size=UDim2.new(0,44,0,44); reopenBtn.AnchorPoint=Vector2.new(0,0)
reopenBtn.Position=UDim2.new(0,TOP_GAP,0,TOP_GAP); reopenBtn.BackgroundColor3=BTN_DARK
reopenBtn.BackgroundTransparency=0.05; reopenBtn.BorderSizePixel=0
reopenBtn.Text="≡"; reopenBtn.Font=Enum.Font.GothamBlack; reopenBtn.TextSize=22
reopenBtn.TextColor3=PURPLE; reopenBtn.AutoButtonColor=false
reopenBtn.Visible=false; reopenBtn.Parent=sg
Instance.new("UICorner",reopenBtn).CornerRadius=UDim.new(0,12)
local rbStroke=Instance.new("UIStroke",reopenBtn); rbStroke.Color=PURPLE; rbStroke.Thickness=2
reopenBtn.MouseEnter:Connect(function() tw(reopenBtn,0.15,{BackgroundColor3=Color3.fromRGB(30,30,30)}) end)
reopenBtn.MouseLeave:Connect(function() tw(reopenBtn,0.15,{BackgroundColor3=BTN_DARK}) end)

-- TopBar: left side, acts as clickable toggle
local topBar=Instance.new("TextButton"); topBar.Name="TopBar"
topBar.Size=UDim2.new(0,GUI_WIDTH,0,44); topBar.AnchorPoint=Vector2.new(0,0)
topBar.Position=UDim2.new(0,TOP_GAP,0,TOP_GAP); topBar.BackgroundColor3=BG_DARK; topBar.BackgroundTransparency=0.05
topBar.BorderSizePixel=0; topBar.Text=""; topBar.AutoButtonColor=false; topBar.Parent=sg
Instance.new("UICorner",topBar).CornerRadius=UDim.new(0,16)
local topStroke=Instance.new("UIStroke",topBar); topStroke.Color=PURPLE; topStroke.Thickness=2

-- Inner label (non-interactive, just display)
local topLabel=Instance.new("TextLabel"); topLabel.Size=UDim2.new(1,-46,1,0); topLabel.Position=UDim2.new(0,14,0,0)
topLabel.BackgroundTransparency=1; topLabel.Font=Enum.Font.GothamBlack; topLabel.TextSize=13
topLabel.TextColor3=PURPLE; topLabel.TextXAlignment=Enum.TextXAlignment.Left; topLabel.Parent=topBar

-- Small close indicator on the right of topBar
local closeHint=Instance.new("TextLabel"); closeHint.Size=UDim2.new(0,32,1,0)
closeHint.Position=UDim2.new(1,-36,0,0); closeHint.BackgroundTransparency=1
closeHint.Text="✕"; closeHint.Font=Enum.Font.GothamBold; closeHint.TextSize=12
closeHint.TextColor3=Color3.fromRGB(70,70,70); closeHint.Parent=topBar

local fps,fAcc,fLast=60,0,tick()
RunService.RenderStepped:Connect(function()
    fAcc+=1; if tick()-fLast>=1 then fps=fAcc; fAcc=0; fLast=tick() end
    local ping=0; local net=Stats:FindFirstChild("Network")
    if net then local si=net:FindFirstChild("ServerStatsItem"); if si then local dp=si:FindFirstChild("Data Ping"); if dp then ping=math.floor(dp:GetValue()) end end end
    topLabel.Text="🌌 Galaxy Hub 🌌  ·  "..fps.." FPS  ·  "..ping.." ms"
end)

-- Hover effect on topBar
topBar.MouseEnter:Connect(function() if menuOpen then tw(closeHint,0.2,{TextColor3=Color3.fromRGB(150,50,255)}) end end)
topBar.MouseLeave:Connect(function() tw(closeHint,0.2,{TextColor3=Color3.fromRGB(70,70,70)}) end)

-- ── MAIN PANEL (LEFT SIDE) ──
local mainFrame=Instance.new("Frame"); mainFrame.Name="MainFrame"
mainFrame.Size=UDim2.new(0,GUI_WIDTH,0,GUI_HEIGHT); mainFrame.AnchorPoint=Vector2.new(0,0)
mainFrame.Position=UDim2.new(0,TOP_GAP,0,TOP_GAP + 44 + GAP_BETWEEN_TOPBAR_AND_PANEL); mainFrame.BackgroundColor3=BG_DARK
mainFrame.BackgroundTransparency=0.05; mainFrame.BorderSizePixel=0; mainFrame.Parent=sg
Instance.new("UICorner",mainFrame).CornerRadius=UDim.new(0,16)
local mainStroke=Instance.new("UIStroke",mainFrame); mainStroke.Color=PURPLE; mainStroke.Thickness=2
local sectionBtns = {}

local function layoutMainUi()
    local viewport = getViewportSize()
    local topLeftInset, bottomRightInset = getSafeInsets()

    local leftSafe = topLeftInset.X
    local topSafe = topLeftInset.Y
    local rightSafe = bottomRightInset.X
    local bottomSafe = bottomRightInset.Y

    local availableWidth = math.max(180, viewport.X - leftSafe - rightSafe - (TOP_GAP * 2))
    local availableHeight = math.max(220, viewport.Y - topSafe - bottomSafe - TOP_GAP - (44 + GAP_BETWEEN_TOPBAR_AND_PANEL))

    local panelWidth = math.min(GUI_WIDTH, availableWidth)
    local panelHeight = math.min(GUI_HEIGHT, availableHeight)

    local xPos = leftSafe + TOP_GAP
    local topBarY = topSafe + TOP_GAP
    local mainY = topBarY + 44 + GAP_BETWEEN_TOPBAR_AND_PANEL

    topBar.Size = UDim2.new(0, panelWidth, 0, 44)
    topBar.Position = UDim2.new(0, xPos, 0, topBarY)

    reopenBtn.Position = UDim2.new(0, xPos, 0, topBarY)
    mainFrame.Size = UDim2.new(0, panelWidth, 0, panelHeight)
    mainFrame.Position = UDim2.new(0, xPos, 0, mainY)

    local tabWidth = math.max(36, math.floor((panelWidth - 16 - 12) / 4))
    for _, btn in ipairs(sectionBtns or {}) do
        btn.Size = UDim2.new(0, tabWidth, 0, 28)
    end
end

layoutMainUi()
task.defer(reclampDraggables)

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        layoutMainUi()
        reclampDraggables()
    end)
end

-- ── TOGGLE MENU (click FPS bar or reopen btn) ──
local function hideMenu()
    menuOpen=false
    tw(mainFrame,0.25,{Position=UDim2.new(0,-mainFrame.AbsoluteSize.X-30,0,mainFrame.Position.Y.Offset)},Enum.EasingStyle.Back)
    tw(topBar,0.22,{Position=UDim2.new(0,-topBar.AbsoluteSize.X-30,0,topBar.Position.Y.Offset)},Enum.EasingStyle.Quad)
    task.wait(0.26)
    topBar.Visible=false; mainFrame.Visible=false
    reopenBtn.Visible=true
    tw(reopenBtn,0.2,{BackgroundColor3=BTN_DARK})
end

local function showMenu()
    menuOpen=true
    layoutMainUi()
    reopenBtn.Visible=false
    topBar.Visible=true; mainFrame.Visible=true
    local targetTopPos = topBar.Position
    local targetMainPos = mainFrame.Position
    topBar.Position=UDim2.new(0,-topBar.AbsoluteSize.X-30,0,targetTopPos.Y.Offset)
    mainFrame.Position=UDim2.new(0,-mainFrame.AbsoluteSize.X-30,0,targetMainPos.Y.Offset)
    TweenService:Create(topBar,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=targetTopPos}):Play()
    TweenService:Create(mainFrame,TweenInfo.new(0.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=targetMainPos}):Play()
end

topBar.MouseButton1Click:Connect(function() if menuOpen then hideMenu() end end)
reopenBtn.MouseButton1Click:Connect(function() showMenu() end)

-- ── SECTION TABS ──
local sections={"Combat","Player","Visual","Settings"}
local frames={}
local ShowSection

local tabRow=Instance.new("Frame"); tabRow.Size=UDim2.new(1,-16,0,36); tabRow.Position=UDim2.new(0,8,0,8)
tabRow.BackgroundTransparency=1; tabRow.Parent=mainFrame
tabRow.ZIndex=3
local tabLayout=Instance.new("UIListLayout",tabRow); tabLayout.FillDirection=Enum.FillDirection.Horizontal
tabLayout.Padding=UDim.new(0,4); tabLayout.VerticalAlignment=Enum.VerticalAlignment.Center

local contentArea=Instance.new("Frame"); contentArea.Size=UDim2.new(1,-16,1,-58); contentArea.Position=UDim2.new(0,8,0,50)
contentArea.BackgroundTransparency=1; contentArea.Parent=mainFrame
contentArea.ZIndex=1

local sectionsBuiltOk, sectionBuildErr = pcall(function()
    for _,name in ipairs(sections) do
        local scroll=Instance.new("ScrollingFrame"); scroll.Size=UDim2.new(1,0,1,0)
        scroll.CanvasSize=UDim2.new(0,0,0,0)
        scroll.ScrollBarThickness=2
        scroll.ScrollBarImageColor3=PURPLE
        scroll.BackgroundTransparency=1
        scroll.BorderSizePixel=0
        scroll.Visible=false
        scroll.ScrollingEnabled=true
        scroll.Active=true
        scroll.Name=name.."Frame"; scroll.Parent=contentArea; frames[name]=scroll

        local sectionPad = Instance.new("UIPadding")
        sectionPad.PaddingTop = UDim.new(0, 4)
        sectionPad.PaddingBottom = UDim.new(0, 18)
        sectionPad.Parent = scroll

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 5)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scroll

        local function updateCanvas()
            local paddingY = sectionPad.PaddingTop.Offset + sectionPad.PaddingBottom.Offset
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + paddingY + 8)
        end

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        task.defer(updateCanvas)
    end

    ShowSection = function(name)
        if not frames[name] then return end
        for _,f in pairs(frames) do f.Visible=false end
        frames[name].Visible=true
        frames[name].CanvasPosition=Vector2.new(0,0)
        for _,b in pairs(sectionBtns) do
            tw(b,0.18,{BackgroundColor3=BTN_DARK,TextColor3=TEXT_OFF})
            local bs=b:FindFirstChildOfClass("UIStroke"); if bs then tw(bs,0.18,{Color=STROKE_OFF}) end
        end
        for _,b in pairs(sectionBtns) do
            if b.Text==name then
                tw(b,0.18,{BackgroundColor3=PURPLE2,TextColor3=TEXT_ON})
                local bs=b:FindFirstChildOfClass("UIStroke"); if bs then tw(bs,0.18,{Color=STROKE_ON}) end
            end
        end
    end

    for _,v in ipairs(sections) do
        local btn=Instance.new("TextButton"); btn.Size=UDim2.new(0,58,0,28)
        btn.BackgroundColor3=BTN_DARK; btn.Text=v; btn.Font=Enum.Font.GothamBold
        btn.TextSize=11; btn.TextColor3=TEXT_OFF; btn.AutoButtonColor=false; btn.Parent=tabRow
        btn.ZIndex=4
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
        local bs=Instance.new("UIStroke",btn); bs.Color=STROKE_OFF; bs.Thickness=1
        table.insert(sectionBtns,btn)
        btn.MouseButton1Click:Connect(function() ShowSection(v) end)
    end

    layoutMainUi()
end)
if not sectionsBuiltOk then
    showScreenText("[Galaxy Hub] Section/tab setup failed: " .. tostring(sectionBuildErr))
    ShowSection = ShowSection or function() end
end

-- ══════════════════════════════════════════
-- BUTTON FACTORY (style script 2)
-- ══════════════════════════════════════════
local function MakeButton(parent, label)
    local btn=Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,46)
    btn.BackgroundColor3=BTN_DARK; btn.Text=label; btn.Font=Enum.Font.GothamBlack
    btn.TextSize=13; btn.TextColor3=TEXT_OFF; btn.AutoButtonColor=false; btn.Parent=parent
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,12)
    local bs=Instance.new("UIStroke",btn); bs.Color=STROKE_OFF; bs.Thickness=1.5

    local origS=btn.Size; local hoverS=UDim2.new(1,4,0,50); local clickS=UDim2.new(1,-6,0,42)
    local enabled=false

    local function setOn()
        enabled=true; btn.Text="✓  "..label; btn.TextColor3=TEXT_ON
        tw(btn,0.28,{BackgroundColor3=PURPLE2}); tw(bs,0.28,{Color=STROKE_ON})
    end
    local function setOff()
        enabled=false; btn.Text=label; btn.TextColor3=TEXT_OFF
        tw(btn,0.28,{BackgroundColor3=BTN_DARK}); tw(bs,0.28,{Color=STROKE_OFF})
    end

    btn.MouseEnter:Connect(function() tw(btn,0.2,{Size=hoverS}); if not enabled then tw(bs,0.2,{Color=PURPLE}) end end)
    btn.MouseLeave:Connect(function() tw(btn,0.2,{Size=origS}); if not enabled then tw(bs,0.2,{Color=STROKE_OFF}) end end)
    btn.MouseButton1Down:Connect(function() TweenService:Create(btn,TweenInfo.new(0.08,Enum.EasingStyle.Back),{Size=clickS}):Play() end)
    btn.MouseButton1Up:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1,Enum.EasingStyle.Back),{Size=hoverS}):Play() end)

    return btn, setOn, setOff, function() return enabled end
end

-- ══════════════════════════════════════════
-- NUMBER INPUT FACTORY
-- ══════════════════════════════════════════
local settingsInputRefs = {}

local function MakeNumInput(parent, label, default, minV, maxV, callback)
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,46)
    row.BackgroundColor3=BTN_DARK; row.Parent=parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,12)
    local rs=Instance.new("UIStroke",row); rs.Color=STROKE_OFF; rs.Thickness=1.5
    local lbl=Instance.new("TextLabel"); lbl.Size=UDim2.new(0.55,0,1,0); lbl.Position=UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12
    lbl.TextColor3=Color3.fromRGB(140,140,140); lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row
    local box=Instance.new("TextBox"); box.Size=UDim2.new(0,72,0,30); box.Position=UDim2.new(1,-82,0.5,-15)
    box.BackgroundColor3=Color3.fromRGB(16,16,16); box.TextColor3=TEXT_ON; box.Font=Enum.Font.GothamBold
    box.TextSize=13; box.Text=tostring(default); box.ClearTextOnFocus=false; box.Parent=row
    settingsInputRefs[label] = box
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,8)
    local bxs=Instance.new("UIStroke",box); bxs.Color=STROKE_OFF; bxs.Thickness=1
    box.Focused:Connect(function() tw(bxs,0.2,{Color=PURPLE}) end)
    box.FocusLost:Connect(function(entered)
        tw(bxs,0.2,{Color=STROKE_OFF})
        if entered then local n=tonumber(box.Text); if n and n>=minV and n<=maxV then callback(n) else box.Text=tostring(default) end end
    end)
end

local savedConfig = {}
local toggleStates = {}
local toggleHandlers = {}
local CONFIG_PASTE_PLACEHOLDER = "Paste config JSON here, then click Load Config"

local function refreshSettingsInputs()
    if settingsInputRefs["Steal Radius"] then
        settingsInputRefs["Steal Radius"].Text = tostring(grabRadius)
    end
    if settingsInputRefs["Lock Range"] then
        settingsInputRefs["Lock Range"].Text = tostring(LOCK_RADIUS)
    end
    if settingsInputRefs["Medusa Radius"] then
        settingsInputRefs["Medusa Radius"].Text = tostring(MEDUSA_RADIUS)
    end
    if settingsInputRefs["Melee Range"] then
        settingsInputRefs["Melee Range"].Text = tostring(MELEE_RANGE)
    end
end

local function saveConfig()
    local settingsCopy = {}
    if type(SETTINGS) == "table" then
        for k, v in pairs(SETTINGS) do
            settingsCopy[k] = v
        end
    end

    local toggleCopy = {}
    for k, v in pairs(toggleStates) do
        toggleCopy[k] = v
    end

    savedConfig = {
        speed = speedBox and speedBox.Text,
        steal = stealBox and stealBox.Text,
        SETTINGS = settingsCopy,
        toggles = toggleCopy,
        grabRadius = grabRadius,
        lockRadius = LOCK_RADIUS,
        medusaRadius = MEDUSA_RADIUS,
        meleeRange = MELEE_RANGE
    }

    local encoded = HttpService:JSONEncode(savedConfig)
    pcall(function()
        if setclipboard then
            setclipboard(encoded)
        end
    end)
    pcall(function()
        if writefile then
            writefile("galaxy_config.json", encoded)
        end
    end)

    if configPasteBox then
        configPasteBox.Text = encoded
    end
end

local function loadConfig()
    pcall(function()
        local raw

        local manualText = nil
        if configPasteBox then
            manualText = configPasteBox.Text
        end

        if manualText and manualText ~= "" and manualText ~= CONFIG_PASTE_PLACEHOLDER then
            raw = manualText
        end

        if not raw or raw == "" then
            pcall(function()
                if isfile and readfile and isfile("galaxy_config.json") then
                    raw = readfile("galaxy_config.json")
                end
            end)
        end

        if not raw or raw == "" then
            pcall(function()
                if getclipboard then
                    raw = getclipboard()
                end
            end)
        end

        if not raw or raw == "" then return end

        local ok, data = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if not ok or type(data) ~= "table" then return end

        if data.speed and speedBox then speedBox.Text = tostring(data.speed) end
        if data.steal and stealBox then stealBox.Text = tostring(data.steal) end

        if type(data.SETTINGS) == "table" then
            for k, v in pairs(data.SETTINGS) do
                SETTINGS[k] = v
            end
        end
        SETTINGS.TPDOWN = SETTINGS.TPDOWN == true
        SETTINGS.STRETCH_REZ = SETTINGS.STRETCH_REZ == true
        SETTINGS.NIGHT_TIME = SETTINGS.NIGHT_TIME == true
        SETTINGS.PURPLE_SKY = SETTINGS.PURPLE_SKY == true
        SETTINGS.FPS_BOOSTER = SETTINGS.FPS_BOOSTER == true

        if data.grabRadius ~= nil then
            local n = tonumber(data.grabRadius)
            if n then grabRadius = n end
        end
        if data.lockRadius ~= nil then
            local n = tonumber(data.lockRadius)
            if n then LOCK_RADIUS = n end
        end
        if data.medusaRadius ~= nil then
            local n = tonumber(data.medusaRadius)
            if n then MEDUSA_RADIUS = n end
        end
        if data.meleeRange ~= nil then
            local n = tonumber(data.meleeRange)
            if n then MELEE_RANGE = n end
        end

        if stealCircle then
            stealCircle.Size = Vector3.new(0.05, grabRadius * 2, grabRadius * 2)
        end
        if medusaPart then
            medusaPart.Size = Vector3.new(0.05, MEDUSA_RADIUS * 2, MEDUSA_RADIUS * 2)
        end

        if applyUISettings then
            pcall(applyUISettings)
        end
        refreshSettingsInputs()

        if type(data.toggles) == "table" then
            for label, desired in pairs(data.toggles) do
                local info = toggleHandlers[label]
                if info then
                    local target = desired == true
                    toggleStates[label] = target
                    if info.isOn and info.isOn() ~= target then
                        if target then
                            if info.setOn then info.setOn() end
                            if info.onFn then pcall(info.onFn) end
                        else
                            if info.setOff then info.setOff() end
                            if info.offFn then pcall(info.offFn) end
                        end
                    end
                end
            end
        end
    end)
end

-- ══════════════════════════════════════════
-- POPULATE TOGGLES
-- ══════════════════════════════════════════
local function AddToggle(section, label, onFn, offFn)
    local btn, setOn, setOff, isOn = MakeButton(frames[section], label)
    toggleStates[label] = false
    toggleHandlers[label] = { setOn = setOn, setOff = setOff, isOn = isOn, onFn = onFn, offFn = offFn }
    btn.MouseButton1Click:Connect(function()
        local newState = not toggleStates[label]
        toggleStates[label] = newState
        if newState then
            setOn()
            if onFn then pcall(onFn) end
        else
            setOff()
            if offFn then pcall(offFn) end
        end

        if isOn() ~= newState then
            if newState then
                setOn()
            else
                setOff()
            end
        end
    end)
end

-- COMBAT
if typeof(galaxyHubAddToggle) == "function" then
    AddToggle = galaxyHubAddToggle
else
    showScreenText("_G.AddToggle missing after 10s - using standalone fallback UI")
end

AddToggle("Combat","Melee Aimbot",
    function() meleeEnabled=true; if character then createMeleeAimbot(character) end end,
    function() disableMeleeAimbot() end)

AddToggle("Combat","Auto Steal Nearest",
    function()
        autoStealEnabled=true; createStealCircle(grabRadius); pbBg.Visible=true
        if stealCircleConn then stealCircleConn:Disconnect() end
        stealCircleConn=RunService.RenderStepped:Connect(updateStealCircle)
    end,
    function()
        autoStealEnabled=false
        resetBar(true)
        hideStealCircle()
        if stealCircleConn then stealCircleConn:Disconnect(); stealCircleConn=nil end
    end)

AddToggle("Combat","Auto Play",
    function()
        autoPlayEnabled = true
        createAutoPlayGui()
    end,
    function()
        autoPlayEnabled = false
        destroyAutoPlayGui()
    end
)
AddToggle("Combat","Lock Target", function() createLockGui() end, function() destroyLockGui() end)
AddToggle("Combat","Auto Medusa", function() AutoMedusaEnabled=true; InitMedusa() end, function() AutoMedusaEnabled=false end)
AddToggle("Combat","Auto Bat",
    function()
        autoBatActive=true
        autoBatLoop=task.spawn(function()
            while autoBatActive do
                local char=lp.Character; if char then local t=char:FindFirstChild("Bat"); if t and t:IsA("Tool") then pcall(function() t:Activate() end) end end
                task.wait(0.4)
            end
        end)
    end,
    function() autoBatActive=false end)
AddToggle("Combat","Anti Sentry", function() startAntiSentry() end, function() stopAntiSentry() end)

-- PLAYER
AddToggle("Player","Speed Customizer", function() if scGui then scGui.Enabled=true end end, function() if scGui then scGui.Enabled=false end end)
AddToggle("Player","No Walk Animation",
    function()
        local char=lp.Character; if not char then return end
        local anim=char:FindFirstChild("Animate")
        if anim then savedAnimate=anim; anim.Disabled=true end
        local hm=char:FindFirstChildOfClass("Humanoid"); if hm then for _,t in ipairs(hm:GetPlayingAnimationTracks()) do t:Stop() end end
    end,
    function() if savedAnimate then savedAnimate.Disabled=false; savedAnimate=nil end end)
AddToggle("Player","Anti Ragdoll", function() toggleAntiRagdoll(true) end, function() toggleAntiRagdoll(false) end)
AddToggle("Player","Spin Body", function() createSpinButton() end, function() removeSpinButton() end)
AddToggle("Player","Float", function() createFloatButton() end, function() destroyFloatButton() end)
AddToggle("Player","Drop", function() createDropButton() end, function() destroyDropButton() end)
AddToggle("Player","TP Down", function() createTpDownButton() end, function() destroyTpDownButton() end)
AddToggle("Player","Slow Fall", function() slowFallEnabled=true end, function() slowFallEnabled=false end)
AddToggle("Player","Infinite Jump", function() infiniteJumpEnabled=true end, function() infiniteJumpEnabled=false end)

-- VISUAL
AddToggle("Visual","ESP Players", function() toggleESPPlayers(true) end, function() toggleESPPlayers(false) end)
AddToggle("Visual","Anti Bee & Disco", function() enableAntiBee() end, function() disableAntiBee() end)
AddToggle("Visual","Xray Base", function() toggleESPBases(true) end, function() toggleESPBases(false) end)
AddToggle("Visual","Optimizer", function() enableOptimizer() end, function() disableOptimizer() end)
AddToggle("Visual","Anti FPS Devourer", function() enableAntiFPSDevourer() end, function() disableAntiFPSDevourer() end)
AddToggle("Visual","Stretch Rez", function() SETTINGS.STRETCH_REZ = true end, function() SETTINGS.STRETCH_REZ = false end)
AddToggle("Visual","Night Time", function() SETTINGS.NIGHT_TIME = true end, function() SETTINGS.NIGHT_TIME = false end)
AddToggle("Visual","Purple Sky", function() SETTINGS.PURPLE_SKY = true end, function() SETTINGS.PURPLE_SKY = false end)
AddToggle("Visual","FPS Booster", function() SETTINGS.FPS_BOOSTER = true end, function() SETTINGS.FPS_BOOSTER = false end)

-- SETTINGS
MakeNumInput(frames["Settings"],"Steal Radius",grabRadius,1,1000,function(v) grabRadius=v; if stealCircle then stealCircle.Size=Vector3.new(0.05,v*2,v*2) end end)
MakeNumInput(frames["Settings"],"Lock Range",LOCK_RADIUS,5,500,function(v) LOCK_RADIUS=v end)
MakeNumInput(frames["Settings"],"Medusa Radius",MEDUSA_RADIUS,1,200,function(v) MEDUSA_RADIUS=v; if medusaPart then medusaPart.Size=Vector3.new(0.05,v*2,v*2) end end)
MakeNumInput(frames["Settings"],"Melee Range",MELEE_RANGE,1,50,function(v) MELEE_RANGE=v end)

configPasteBox=Instance.new("TextBox"); configPasteBox.Size=UDim2.new(1,0,0,72)
configPasteBox.BackgroundColor3=BTN_DARK; configPasteBox.Text=CONFIG_PASTE_PLACEHOLDER; configPasteBox.Font=Enum.Font.Gotham
configPasteBox.TextSize=11; configPasteBox.TextColor3=TEXT_ON; configPasteBox.TextWrapped=false; configPasteBox.ClearTextOnFocus=false
configPasteBox.MultiLine=true; configPasteBox.TextXAlignment=Enum.TextXAlignment.Left; configPasteBox.TextYAlignment=Enum.TextYAlignment.Top
configPasteBox.Parent=frames["Settings"]
local function isConfigPastePlaceholder()
    return configPasteBox and configPasteBox.Text == CONFIG_PASTE_PLACEHOLDER
end

configPasteBox.TextColor3 = Color3.fromRGB(140,140,140)
Instance.new("UICorner",configPasteBox).CornerRadius=UDim.new(0,12)
local configPasteStroke=Instance.new("UIStroke",configPasteBox); configPasteStroke.Color=STROKE_OFF; configPasteStroke.Thickness=1.5
configPasteBox.Focused:Connect(function()
    tw(configPasteStroke,0.2,{Color=PURPLE})
    if isConfigPastePlaceholder() then
        configPasteBox.Text = ""
        configPasteBox.TextColor3 = TEXT_ON
    end
end)

configPasteBox.FocusLost:Connect(function()
    tw(configPasteStroke,0.2,{Color=STROKE_OFF})
    if configPasteBox.Text == "" then
        configPasteBox.Text = CONFIG_PASTE_PLACEHOLDER
        configPasteBox.TextColor3 = Color3.fromRGB(140,140,140)
    else
        configPasteBox.TextColor3 = TEXT_ON
    end
end)

local saveCfgBtn=Instance.new("TextButton"); saveCfgBtn.Size=UDim2.new(1,0,0,46)
saveCfgBtn.BackgroundColor3=BTN_DARK; saveCfgBtn.Text="Save Config"; saveCfgBtn.Font=Enum.Font.GothamBlack
saveCfgBtn.TextSize=13; saveCfgBtn.TextColor3=TEXT_OFF; saveCfgBtn.AutoButtonColor=false; saveCfgBtn.Parent=frames["Settings"]
Instance.new("UICorner",saveCfgBtn).CornerRadius=UDim.new(0,12)
local saveCfgStroke=Instance.new("UIStroke",saveCfgBtn); saveCfgStroke.Color=STROKE_OFF; saveCfgStroke.Thickness=1.5
local saveOS=saveCfgBtn.Size; local saveHS=UDim2.new(1,4,0,50); local saveCS=UDim2.new(1,-6,0,42)
saveCfgBtn.MouseEnter:Connect(function() tw(saveCfgBtn,0.2,{Size=saveHS}); tw(saveCfgStroke,0.2,{Color=PURPLE}) end)
saveCfgBtn.MouseLeave:Connect(function() tw(saveCfgBtn,0.2,{Size=saveOS}); tw(saveCfgStroke,0.2,{Color=STROKE_OFF}) end)
saveCfgBtn.MouseButton1Down:Connect(function() TweenService:Create(saveCfgBtn,TweenInfo.new(0.08,Enum.EasingStyle.Back),{Size=saveCS}):Play() end)
saveCfgBtn.MouseButton1Up:Connect(function() TweenService:Create(saveCfgBtn,TweenInfo.new(0.1,Enum.EasingStyle.Back),{Size=saveHS}):Play() end)
saveCfgBtn.MouseButton1Click:Connect(function() saveConfig() end)

local loadCfgBtn=Instance.new("TextButton"); loadCfgBtn.Size=UDim2.new(1,0,0,46)
loadCfgBtn.BackgroundColor3=BTN_DARK; loadCfgBtn.Text="Load Config"; loadCfgBtn.Font=Enum.Font.GothamBlack
loadCfgBtn.TextSize=13; loadCfgBtn.TextColor3=TEXT_OFF; loadCfgBtn.AutoButtonColor=false; loadCfgBtn.Parent=frames["Settings"]
Instance.new("UICorner",loadCfgBtn).CornerRadius=UDim.new(0,12)
local loadCfgStroke=Instance.new("UIStroke",loadCfgBtn); loadCfgStroke.Color=STROKE_OFF; loadCfgStroke.Thickness=1.5
local loadOS=loadCfgBtn.Size; local loadHS=UDim2.new(1,4,0,50); local loadCS=UDim2.new(1,-6,0,42)
loadCfgBtn.MouseEnter:Connect(function() tw(loadCfgBtn,0.2,{Size=loadHS}); tw(loadCfgStroke,0.2,{Color=PURPLE}) end)
loadCfgBtn.MouseLeave:Connect(function() tw(loadCfgBtn,0.2,{Size=loadOS}); tw(loadCfgStroke,0.2,{Color=STROKE_OFF}) end)
loadCfgBtn.MouseButton1Down:Connect(function() TweenService:Create(loadCfgBtn,TweenInfo.new(0.08,Enum.EasingStyle.Back),{Size=loadCS}):Play() end)
loadCfgBtn.MouseButton1Up:Connect(function() TweenService:Create(loadCfgBtn,TweenInfo.new(0.1,Enum.EasingStyle.Back),{Size=loadHS}):Play() end)
loadCfgBtn.MouseButton1Click:Connect(function() loadConfig() end)

-- Discord row
local dcRow=Instance.new("Frame"); dcRow.Size=UDim2.new(1,0,0,36); dcRow.BackgroundColor3=BTN_DARK; dcRow.Parent=frames["Settings"]
Instance.new("UICorner",dcRow).CornerRadius=UDim.new(0,12)
local dcBtn=Instance.new("TextButton"); dcBtn.Size=UDim2.new(1,0,1,0); dcBtn.BackgroundTransparency=1
dcBtn.Text="📋  https://discord.gg/F4eknseBRK"; dcBtn.Font=Enum.Font.Gotham; dcBtn.TextSize=11
dcBtn.TextColor3=Color3.fromRGB(130,130,130); dcBtn.Parent=dcRow
dcBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard("https://discord.gg/F4eknseBRK") end); dcBtn.Text="✅  Copied!"; task.wait(1.5); dcBtn.Text="📋  https://discord.gg/F4eknseBRK" end)

ShowSection("Combat")
layoutMainUi()
showMenu()
sg.Enabled = true
showScreenText("[GalaxyHub] UI initialization complete.")
end, function(startErr)
    return debug.traceback(tostring(startErr), 2)
end)

if not success then
    showScreenText("UI CREATION FAILED: " .. tostring(err))
end

task.delay(1, function()
    local targetGui = playerGui or (player and player:FindFirstChild("PlayerGui"))
    if targetGui and not targetGui:FindFirstChild("UGC_Duels") then
        showScreenText("UI DID NOT CREATE - FORCING TEST BUTTON")

        local test = Instance.new("ScreenGui")
        test.Name = "TEST_GUI"
        finalizeScreenGui(test)

        local btn = Instance.new("TextLabel")
        btn.Size = UDim2.new(0,200,0,50)
        btn.Position = UDim2.new(0.5,-100,0.5,-25)
        btn.Text = "UI FAILED"
        btn.BackgroundColor3 = Color3.new(1,0,0)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Parent = test
    end
end)

showScreenText("[GalaxyHub] Script finished executing.")
