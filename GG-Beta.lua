-- Copyright 2024 Developed by Kagiru.
-- This Tool is freely available on my GitHub: https://github.com/HWYkagiru/GetGood
-- If you modify and distribute this tool, giving credits would be greatly appreciated.


local Plrs = game:GetService("Players")
local Plr = Plrs.LocalPlayer
local PlayerGui = Plr:WaitForChild("PlayerGui")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local Tweeny = game:GetService("TweenService")

local function showNotf()
    local NotfGui = Instance.new("ScreenGui")
    NotfGui.Parent = Plr:WaitForChild("PlayerGui")
    NotfGui.IgnoreGuiInset = true

    local notfF = Instance.new("Frame")
    notfF.Size = UDim2.new(0, 280, 0, 60)
    notfF.Position = UDim2.new(1, 20, 1, -100)
    notfF.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notfF.BorderSizePixel = 0
    notfF.AnchorPoint = Vector2.new(1, 1)
    notfF.Parent = NotfGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 14)
    uiCorner.Parent = notfF

    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = notfF

    local notfL = Instance.new("TextLabel")
    notfL.Size = UDim2.new(1, -20, 1, -20)
    notfL.Position = UDim2.new(0, 10, 0, 10)
    notfL.BackgroundTransparency = 1
    notfL.Text = "Hello, " .. Plr.Name
    notfL.TextColor3 = Color3.fromRGB(245, 245, 245)
    notfL.Font = Enum.Font.GothamBold
    notfL.TextSize = 18
    notfL.TextXAlignment = Enum.TextXAlignment.Left
    notfL.Parent = notfF

    local slideInTween = Tweeny:Create(notfF, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -20, 1, -100)
    })

    local slideOutTween = Tweeny:Create(notfF, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
        Position = UDim2.new(1, 20, 1, -100)
    })

    slideInTween:Play()
    slideInTween.Completed:Wait()
    wait(3)
    slideOutTween:Play()
    slideOutTween.Completed:Wait()
    NotfGui:Destroy()
end

_G.AutoParryEnabled = false
_G.BallTrailEnabled = false
_G.PlayerSphereEnabled = false

-- local ballFolder = Workspace.Balls
local ballFolder = workspace:WaitForChild("Balls")
-- local UInterval = 0.1 
local indicatorPart = Instance.new("Part", Workspace)
indicatorPart.Size = Vector3.new(5, 5, 5)
indicatorPart.Anchored = true
indicatorPart.CanCollide = false
indicatorPart.Transparency = 1
indicatorPart.BrickColor = BrickColor.new("Bright red")

local PlayerSphere = Instance.new("Part")
PlayerSphere.Shape = Enum.PartType.Ball
PlayerSphere.Material = Enum.Material.ForceField
PlayerSphere.Anchored = true
PlayerSphere.CanCollide = false
PlayerSphere.Transparency = 0.5
PlayerSphere.BrickColor = BrickColor.new("Cyan")
PlayerSphere.Parent = Workspace

local lastBallPressed, lastClickTime = nil, 0
local debounceTime, predictionBuffer = 0.1, 0.2

local function calcPredTime(ball, Plr)
    local character = Plr.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return math.huge end

    local rootPart = character.HumanoidRootPart
    local relativePosition = ball.Position - rootPart.Position
    local velocity = ball.Velocity + rootPart.Velocity
    local distance = relativePosition.Magnitude
    local radius = ball.Size.Magnitude / 2

    if velocity.Magnitude > 0 then
        return math.max(0, (distance - radius) / velocity.Magnitude + predictionBuffer)
    end
    return math.huge
end

local function UIndicatorPosition(ball)
    indicatorPart.Position = ball.Position
end

local function UPlayerSphere()
    if not _G.PlayerSphereEnabled then 
        if PlayerSphere then
            PlayerSphere:Destroy()
            PlayerSphere = nil
        end
        return
    end

    if not PlayerSphere then
        PlayerSphere = Instance.new("Part")
        PlayerSphere.Shape = Enum.PartType.Ball
        PlayerSphere.Material = Enum.Material.ForceField
        PlayerSphere.Anchored = true
        PlayerSphere.CanCollide = false
        PlayerSphere.Transparency = 0.5
        PlayerSphere.BrickColor = BrickColor.new("Cyan")
        PlayerSphere.Parent = Workspace
    end

    local Plr = Plrs.LocalPlayer
    local character = Plr and Plr.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not rootPart then return end

    local closestBall, minPredictionTime = nil, math.huge
    for _, ball in pairs(ballFolder:GetChildren()) do
        local predictionTime = calcPredTime(ball, Plr)
        if predictionTime < minPredictionTime then
            minPredictionTime = predictionTime
            closestBall = ball
        end
    end

    if closestBall then
        PlayerSphere.Position = rootPart.Position
        local scaleFactor = math.clamp(20 / (minPredictionTime + 0.1), 0.5, 20) -- Cooking
        PlayerSphere.Size = Vector3.new(scaleFactor, scaleFactor, scaleFactor)
    else
        PlayerSphere.Size = Vector3.new(0.5, 0.5, 0.5)
    end
end

local function Parry()
    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
end

local function shouldPressBall(ball, Plr)
    local predictionTime = calcPredTime(ball, Plr)
    local realBallAttribute = ball:GetAttribute("realBall")
    local target = ball:GetAttribute("target")
    local ballSpeedThreshold = math.max(0.4, 0.6 - ball.Velocity.Magnitude * 0.01)

    return predictionTime <= ballSpeedThreshold and realBallAttribute and target == Plr.Name
end

local function handleBallPress(ball)
    if lastBallPressed == ball or tick() - lastClickTime <= debounceTime then return end

    lastClickTime = tick()
    lastBallPressed = ball
    Parry()
end

local function ballProximity()
    if not _G.AutoParryEnabled then return end

    local Plr = Plrs.LocalPlayer
    if Plr then
        local ballPressedThisFrame = false
        for _, ball in pairs(ballFolder:GetChildren()) do
            UIndicatorPosition(ball)
            if shouldPressBall(ball, Plr) then
                if not ballPressedThisFrame then
                    handleBallPress(ball)
                    ballPressedThisFrame = true
                end
            else
                if lastBallPressed == ball then
                    lastBallPressed = nil
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(ballProximity)
RunService.RenderStepped:Connect(UPlayerSphere)

local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GetGood"
    screenGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 0, 0, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://201661130"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.Parent = frame

    local title = Instance.new("TextLabel")
    title.Text = "GetGood"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 28
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextStrokeTransparency = 0
    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    title.TextScaled = true
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Parent = frame

    local mainButton = Instance.new("TextButton")
    mainButton.Text = "Main"
    mainButton.Font = Enum.Font.GothamBold
    mainButton.TextSize = 18
    mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainButton.Size = UDim2.new(0, 120, 0, 40)
    mainButton.Position = UDim2.new(0, 15, 0, 60)
    mainButton.BorderSizePixel = 0
    mainButton.Parent = frame

    local mainButtonCorner = Instance.new("UICorner")
    mainButtonCorner.CornerRadius = UDim.new(0, 5)
    mainButtonCorner.Parent = mainButton

    local visualButton = Instance.new("TextButton")
    visualButton.Text = "Visual"
    visualButton.Font = Enum.Font.GothamBold
    visualButton.TextSize = 18
    visualButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    visualButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    visualButton.Size = UDim2.new(0, 120, 0, 40)
    visualButton.Position = UDim2.new(0, 15, 0, 110)
    visualButton.BorderSizePixel = 0
    visualButton.Parent = frame

    local visualButtonCorner = Instance.new("UICorner")
    visualButtonCorner.CornerRadius = UDim.new(0, 5)
    visualButtonCorner.Parent = visualButton

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0, 2, 1, -50)
    divider.Position = UDim2.new(0, 150, 0, 50)
    divider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    divider.BorderSizePixel = 0
    divider.Parent = frame

    local apL = Instance.new("TextLabel")
    apL.Text = "AutoParry"
    apL.Font = Enum.Font.GothamBold
    apL.TextSize = 20
    apL.TextColor3 = Color3.fromRGB(255, 255, 255)
    apL.Size = UDim2.new(0, 100, 0, 40)
    apL.Position = UDim2.new(0, 180, 0, 60)
    apL.BackgroundTransparency = 1
    apL.Visible = true
    apL.Parent = frame

    local apCB = Instance.new("TextButton")
    apCB.Text = ""
    apCB.Font = Enum.Font.GothamBold
    apCB.Size = UDim2.new(0, 30, 0, 30)
    apCB.Position = UDim2.new(0, 300, 0, 65)
    apCB.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    apCB.BorderSizePixel = 0
    apCB.Parent = frame

    local CBcorner = Instance.new("UICorner")
    CBcorner.CornerRadius = UDim.new(0, 5)
    CBcorner.Parent = apCB

    local function createTooltip(text, position, parent)
        local tooltip = Instance.new("TextLabel")
        tooltip.Text = text
        tooltip.Font = Enum.Font.GothamBold
        tooltip.TextSize = 14
        tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
        tooltip.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        tooltip.BackgroundTransparency = 0.7
        tooltip.Size = UDim2.new(0, 100, 0, 30)
        tooltip.Position = position
        tooltip.Visible = false
        tooltip.Parent = parent
        return tooltip
    end
    local tooltip = createTooltip("Enable AutoParry", UDim2.new(0, 300, 0, 100), frame)

    apCB.MouseButton1Click:Connect(function()
        _G.AutoParryEnabled = not _G.AutoParryEnabled
        if _G.AutoParryEnabled then
            apCB.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            apCB.TextColor3 = Color3.fromRGB(255, 255, 255)
            apCB.Text = "Enabled"
            -- startAutoParry()
        else
            apCB.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            apCB.TextColor3 = Color3.fromRGB(255, 255, 255)
            apCB.Text = "Disabled"
            stopAutoParry()
        end
    end)
    

    apCB.MouseEnter:Connect(function()
        tooltip.Visible = true
    end)

    apCB.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)

    local BTL = Instance.new("TextLabel")
    BTL.Text = "Ball Trail (Soon)"
    BTL.Font = Enum.Font.GothamBold
    BTL.TextSize = 18
    BTL.TextColor3 = Color3.fromRGB(255, 255, 255)
    BTL.Size = UDim2.new(0, 100, 0, 30)
    BTL.Position = UDim2.new(0, 180, 0, 60)
    BTL.BackgroundTransparency = 1
    BTL.Visible = false
    BTL.Parent = frame

    local PSL = Instance.new("TextLabel")
    PSL.Text = "Player Sphere"
    PSL.Font = Enum.Font.GothamBold
    PSL.TextSize = 18
    PSL.TextColor3 = Color3.fromRGB(255, 255, 255)
    PSL.Size = UDim2.new(0, 100, 0, 30)
    PSL.Position = UDim2.new(0, 180, 0, 100)
    PSL.BackgroundTransparency = 1
    PSL.Visible = false
    PSL.Parent = frame

    local BTCB = Instance.new("TextButton")
    BTCB.Text = ""
    BTCB.Font = Enum.Font.GothamBold
    BTCB.Size = UDim2.new(0, 30, 0, 30)
    BTCB.Position = UDim2.new(0, 300, 0, 60)
    BTCB.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    BTCB.BorderSizePixel = 0
    BTCB.Parent = frame

    local ballCBcorner = Instance.new("UICorner")
    ballCBcorner.CornerRadius = UDim.new(0, 5)
    ballCBcorner.Parent = BTCB

    local PSCB = Instance.new("TextButton")
    PSCB.Text = ""
    PSCB.Font = Enum.Font.GothamBold
    PSCB.Size = UDim2.new(0, 30, 0, 30)
    PSCB.Position = UDim2.new(0, 300, 0, 100)
    PSCB.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    PSCB.BorderSizePixel = 0
    PSCB.Parent = frame

    local playerCBcorner = Instance.new("UICorner")
    playerCBcorner.CornerRadius = UDim.new(0, 5)
    playerCBcorner.Parent = PSCB

    local BTTooltip = createTooltip("Enable Ball Trail", UDim2.new(0, 300, 0, 130), frame)

    -- BTCB.MouseButton1Click:Connect(function()
    --     _G.BallTrailEnabled = not _G.BallTrailEnabled
    --     if _G.BallTrailEnabled then
    --         BTCB.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    --         BTCB.TextColor3 = Color3.fromRGB(255, 255, 255)
    --         BTCB.Text = "Enabled"
    --         startBallTrail()
    --     else
    --         BTCB.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    --         BTCB.TextColor3 = Color3.fromRGB(255, 255, 255)
    --         BTCB.Text = "Disabled"
    --         stopBallTrail()
    --     end
    -- end)
    
    BTCB.MouseEnter:Connect(function()
        BTTooltip.Visible = true
    end)
    BTCB.MouseLeave:Connect(function()
        BTTooltip.Visible = false
    end)

    local PSTooltip = createTooltip("Enable Player Sphere", UDim2.new(0, 300, 0, 170), frame)

    PSCB.MouseButton1Click:Connect(function()
        _G.PlayerSphereEnabled = not _G.PlayerSphereEnabled
    
        if _G.PlayerSphereEnabled then
            PSCB.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            PSCB.TextColor3 = Color3.fromRGB(255, 255, 255)
            PSCB.Text = "Enabled"
            PlayerSphere = Instance.new("Part")
            PlayerSphere.Shape = Enum.PartType.Ball
            PlayerSphere.Material = Enum.Material.ForceField
            PlayerSphere.Anchored = true
            PlayerSphere.CanCollide = false
            PlayerSphere.Transparency = 0.5
            PlayerSphere.BrickColor = BrickColor.new("Cyan")
            PlayerSphere.Parent = Workspace
        else
            PSCB.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            PSCB.Text = "Disabled"
            if PlayerSphere then
                PlayerSphere:Destroy()
                PlayerSphere = nil
            end
        end
    end)

    PSCB.MouseEnter:Connect(function()
        PSTooltip.Visible = true
    end)
    PSCB.MouseLeave:Connect(function()
        PSTooltip.Visible = false
    end)

    if _G.AutoParryEnabled then
        apCB.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        apCB.TextColor3 = Color3.fromRGB(255, 255, 255)
        apCB.Text = "Enabled"
    end
    
    if _G.BallTrailEnabled then
        BTCB.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        BTCB.TextColor3 = Color3.fromRGB(255, 255, 255)
        BTCB.Text = "Enabled"
    end
    
    if _G.PlayerSphereEnabled then
        PSCB.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        PSCB.TextColor3 = Color3.fromRGB(255, 255, 255)
        PSCB.Text = "Enabled"
    end

    local function showVisuals()
        apL.Visible = false
        apCB.Visible = false
        tooltip.Visible = false

        BTL.Visible = true
        PSL.Visible = true
        BTCB.Visible = true
        PSCB.Visible = true
        BTTooltip.Visible = false
        PSTooltip.Visible = false
    end

    local function showAP()
        apL.Visible = true
        apCB.Visible = true
        tooltip.Visible = false

        BTL.Visible = false
        PSL.Visible = false
        BTCB.Visible = false
        PSCB.Visible = false
        BTTooltip.Visible = false
        PSTooltip.Visible = false
    end

    mainButton.MouseButton1Click:Connect(showAP)
    visualButton.MouseButton1Click:Connect(showVisuals)

    local function DragGui(frame)
        local dragging, dragInput, startPos, startDragPos
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                startPos = input.Position
                startDragPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)

        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
        end)

        UIS.InputChanged:Connect(function(input)
            if dragging and input == dragInput then
                local delta = input.Position - startPos
                frame.Position = UDim2.new(startDragPos.X.Scale, startDragPos.X.Offset + delta.X, startDragPos.Y.Scale, startDragPos.Y.Offset + delta.Y)
            end
        end)
    end

    DragGui(frame)

    local isVisible = true
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.L then
            isVisible = not isVisible
            frame.Visible = isVisible
        end
    end)
    return screenGui
end

local screenGui = createGui()

-- Plr.CharacterAdded:Connect(function()
--     if PlayerGui:FindFirstChild("GetGood") then PlayerGui.GetGood:Destroy() end
--     screenGui = createGui()
-- end)

Plr.CharacterAdded:Connect(function()
    local existingGui = PlayerGui:FindFirstChild("GetGood")
    if existingGui then
        existingGui:Destroy()
    end
    screenGui = createGui()
end)
showNotf()
print("GetGood(Beta) Succsesfully Executed\n     GitHub: https://github.com/HWYkagiru/GetGood")
