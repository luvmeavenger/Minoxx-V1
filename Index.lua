--[[
  __  __ ___ _   _  _____  __  __  __   _____ 
 |  \/  |_ _| \ | |/ _ \ \/ /  \ \ / /  |___  |
 | |\/| || ||  \| | | | \  /____\ V /____  / / 
 | |  | || || |\  | |_| /  |_____| |_____|/ /  
 |_|  |_|___|_| \_|\___/_/\_\    |_|     /_/   
]]

print("Minoxx V1 Loading...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Robust PlayerGui Check
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
local Camera = workspace.CurrentCamera

-- // SETTINGS //
local Settings = {
    ESP = false,
    AimAssist = false,
    TeamCheck = false,
    FOV = 120,
    Accent = Color3.fromRGB(138, 43, 226)
}

-- // UI SETUP //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Minoxx_v1"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- FOV Ring
local FOVCircle = Instance.new("Frame", ScreenGui)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
local Stroke = Instance.new("UIStroke", FOVCircle)
Stroke.Thickness, Stroke.Color = 1.5, Settings.Accent
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)

-- MAIN PANEL
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 320)
Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.GroupTransparency = 1 -- Start invisible for animation
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Settings.Accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.5

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "MINOXX V1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BackgroundTransparency = 1

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- // ANIMATION: Fade In //
TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Position = UDim2.new(0.1, 0, 0.25, 0)}):Play()
task.spawn(function()
    for i = 1, 0, -0.1 do
        Main.GroupTransparency = i
        task.wait(0.05)
    end
end)

-- // INPUTS //
local function CreateInput(placeholder, prop)
    local box = Instance.new("TextBox", Container)
    box.Size = UDim2.new(1, 0, 0, 35)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val then Settings[prop] = val end
    end)
end

CreateInput("FOV Size (Current: " .. Settings.FOV .. ")", "FOV")

-- // AIMBOT LOGIC //
RunService.RenderStepped:Connect(function()
    FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
    
    if Settings.AimAssist then
        local target = nil
        local closest = Settings.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                if Settings.TeamCheck and p.Team == LocalPlayer.Team then continue end
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < closest then closest, target = mag, p end
                end
            end
        end
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), 0.15)
        end
    end
end)

-- // BUTTONS //
local function AddToggle(text, prop)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.TextColor3 = Color3.fromRGB(150, 150, 150)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    
    local s = Instance.new("UIStroke", b)
    s.Thickness = 1
    s.Color = Settings.Accent
    s.Transparency = 0.8

    b.MouseButton1Click:Connect(function()
        Settings[prop] = not Settings[prop]
        -- Animation for Toggle
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Settings[prop] and Color3.fromRGB(35, 30, 45) or Color3.fromRGB(20, 20, 23)}):Play()
        b.TextColor3 = Settings[prop] and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150)
        s.Transparency = Settings[prop] and 0 or 0.8
    end)
end

AddToggle("Aim Assist", "AimAssist")
AddToggle("ESP Glow", "ESP")
AddToggle("Team Check", "TeamCheck")

-- // ESP LOOP //
task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("MinoxxH")
                if Settings.ESP then
                    if not h then
                        h = Instance.new("Highlight", p.Character)
                        h.Name = "MinoxxH"
                        h.FillColor = Settings.Accent
                    end
                elseif h then
                    h:Destroy()
                end
            end
        end
        task.wait(1)
    end
end)

-- Toggle Icon
local Icon = Instance.new("TextButton", ScreenGui)
Icon.Size = UDim2.new(0, 45, 0, 45)
Icon.Position = UDim2.new(0, 20, 0.5, 0)
Icon.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Icon.Text = "M"
Icon.Font = Enum.Font.GothamBold
Icon.TextSize = 20
Icon.TextColor3 = Settings.Accent
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)
local IconStroke = Instance.new("UIStroke", Icon)
IconStroke.Color = Settings.Accent
IconStroke.Thickness = 2

Icon.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- // DRAG LOGIC //
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("Minoxx V1 Loaded!")
