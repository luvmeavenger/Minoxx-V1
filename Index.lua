--[[
  __  __ ___ _   _  _____  __  __  __   _____ 
 |  \/  |_ _| \ | |/ _ \ \/ /  \ \ / /  |___  |
 | |\/| || ||  \| | | | \  /____\ V /____  / / 
 | |  | || || |\  | |_| /  |_____| |_____|/ /  
 |_|  |_|___|_| \_|\___/_/\_\    |_|     /_/   
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // SETTINGS //
local Settings = {
    ESP = true,
    Tracers = true,
    ESPMode = "2D", 
    SilentAim = true,
    AutoShoot = false,
    FOV = 150,
    Smoothness = 0.05,
    Accent = Color3.fromRGB(138, 43, 226),
    Speed = 16,
    Gravity = 196.2
}

-- // UI SETUP //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Milox_V1"
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

-- DRAWING FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5; FOVCircle.NumSides = 64; FOVCircle.Radius = Settings.FOV
FOVCircle.Filled = false; FOVCircle.Visible = true

-- MINI PANEL (160x260)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 160, 0, 260)
Main.Position = UDim2.new(0.5, -80, 0.5, -130)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
Main.Visible = false
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color, MainStroke.Thickness = Settings.Accent, 1.5

-- HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 25)
Header.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -30, 1, 0)
Title.Position = UDim2.new(0, 8, 0, 0)
Title.Text, Title.TextColor3, Title.Font, Title.TextSize = "MILOX V1", Settings.Accent, Enum.Font.GothamBold, 10
Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1

local Close = Instance.new("TextButton", Header)
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -25, 0, 0)
Close.Text, Close.TextColor3, Close.Font, Close.TextSize = "X", Color3.new(1,0,0), Enum.Font.GothamBold, 12
Close.BackgroundTransparency = 1
Close.MouseButton1Click:Connect(function() Main.Visible = false end)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -10, 1, -35)
Container.Position = UDim2.new(0, 5, 0, 30)
Container.BackgroundTransparency, Container.ScrollBarThickness = 1, 0
Container.CanvasSize = UDim2.new(0, 0, 2.5, 0)
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 4)

local Toggles = {}

-- // AIM & AUTO SHOOT LOGIC //
local function GetTarget()
    local target, closest = nil, Settings.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if mag < closest then closest, target = mag, p.Character.Head end
            end
        end
    end
    return target
end

-- // MAIN LOOP //
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.SilentAim
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Color = Settings.Accent

    if Settings.SilentAim then
        local target = GetTarget()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), Settings.Smoothness)
            if Settings.AutoShoot then
                mouse1press(); task.wait(); mouse1release()
            end
        end
    end

    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Settings.Speed end
    workspace.Gravity = Settings.Gravity
end)

-- // UI BUILDER //
local function AddToggle(text, prop)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 24); b.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    b.Text, b.TextColor3, b.Font, b.TextSize = text, Color3.new(1,1,1), Enum.Font.Gotham, 9
    Instance.new("UICorner", b)
    local function update()
        TS:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Settings[prop] and Settings.Accent or Color3.fromRGB(15, 15, 18)}):Play()
    end
    b.MouseButton1Click:Connect(function() Settings[prop] = not Settings[prop] update() end)
    Toggles[prop] = update; update()
end

local function AddInput(placeholder, prop, default)
    local box = Instance.new("TextBox", Container)
    box.Size = UDim2.new(1, 0, 0, 24); box.PlaceholderText = placeholder; box.Text = ""
    box.BackgroundColor3 = Color3.fromRGB(12,12,15); box.TextColor3 = Color3.new(1,1,1)
    box.Font, box.TextSize = Enum.Font.Gotham, 9
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function() Settings[prop] = tonumber(box.Text) or default end)
end

AddToggle("Silent Aim", "SilentAim")
AddToggle("Auto Shoot", "AutoShoot")
AddToggle("Master ESP", "ESP")

local ModeBtn = Instance.new("TextButton", Container)
ModeBtn.Size = UDim2.new(1, 0, 0, 24); ModeBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
ModeBtn.Text, ModeBtn.TextColor3, ModeBtn.Font, ModeBtn.TextSize = "Mode: 2D", Color3.new(1,1,1), Enum.Font.Gotham, 9
Instance.new("UICorner", ModeBtn)
ModeBtn.MouseButton1Click:Connect(function()
    Settings.ESPMode = (Settings.ESPMode == "2D" and "3D" or "2D")
    ModeBtn.Text = "Mode: " .. Settings.ESPMode
end)

AddInput("FOV Size", "FOV", 150)
AddInput("Speed", "Speed", 16)
AddInput("Gravity", "Gravity", 196.2)

-- TOGGLE ICON
local Icon = Instance.new("TextButton", ScreenGui)
Icon.Size = UDim2.new(0, 32, 0, 32); Icon.Position = UDim2.new(0, 10, 0.05, 0)
Icon.Text, Icon.Font, Icon.TextColor3 = "M", Enum.Font.GothamBold, Color3.new(1,1,1)
Icon.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)
local IconStroke = Instance.new("UIStroke", Icon)
IconStroke.Thickness, IconStroke.Color = 1.5, Settings.Accent
Icon.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- ESP DRAWING (INTERNAL)
local function CreateESP(plr)
    if plr == LocalPlayer then return end
    local tracer, label, box = Drawing.new("Line"), Drawing.new("Text"), Drawing.new("Square")
    RunService.RenderStepped:Connect(function()
        if Settings.ESP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            local highlight = plr.Character:FindFirstChild("Milox_3D")
            if Settings.ESPMode == "3D" then
                if not highlight then
                    highlight = Instance.new("Highlight", plr.Character); highlight.Name = "Milox_3D"; highlight.FillTransparency = 0.5
                end
                highlight.FillColor = Settings.Accent; box.Visible = false
            elseif highlight then highlight:Destroy() end

            if onScreen then
                tracer.Visible = Settings.Tracers; tracer.Color = Settings.Accent
                tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(vector.X, vector.Y)
                label.Visible, label.Position, label.Text = true, Vector2.new(vector.X, vector.Y - 35), plr.Name
                label.Center, label.Outline, label.Size = true, true, 9
                if Settings.ESPMode == "2D" then
                    box.Visible, box.Color, box.Filled = true, Settings.Accent, false
                    box.Size = Vector2.new(1600/vector.Z, 2600/vector.Z)
                    box.Position = Vector2.new(vector.X - box.Size.X/2, vector.Y - box.Size.Y/2)
                else box.Visible = false end
            else tracer.Visible, label.Visible, box.Visible = false, false, false end
        else tracer.Visible, label.Visible, box.Visible = false, false, false end
    end)
end

for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)
