--[[
  __  __ ___ _   _  _____  __  __  __   _____ 
 |  \/  |_ _| \ | |/ _ \ \/ /  \ \ / /  |___  |
 | |\/| || ||  \| | | | \  /____\ V /____  / / 
 | |  | || || |\  | |_| /  |_____| |_____|/ /  
 |_|  |_|___|_| \_|\___/_/\_\    |_|     /_/   
]]

print("Minoxx V1: 2D/3D Hybrid System Loading...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // SETTINGS //
local Settings = {
    ESP = true,
    Tracers = true,
    ESPMode = "2D", -- Options: "2D" or "3D"
    AimAssist = false,
    TeamCheck = false,
    FOV = 120,
    Accent = Color3.fromRGB(138, 43, 226)
}

-- // UI SETUP //
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "Minoxx_v1"
ScreenGui.ResetOnSpawn = false

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
Main.Size = UDim2.new(0, 200, 0, 380)
Main.Position = UDim2.new(0.1, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", Main).Color = Settings.Accent

local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 5)

-- // ESP HANDLER //
local function CreateESP(plr)
    local tracer = Drawing.new("Line")
    local label = Drawing.new("Text")
    local box = Drawing.new("Square") -- For 2D ESP

    RunService.RenderStepped:Connect(function()
        if Settings.ESP and plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local hum = plr.Character:FindFirstChild("Humanoid")
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            -- Handle 3D Highlight Mode
            local highlight = plr.Character:FindFirstChild("Minoxx_3D")
            if Settings.ESPMode == "3D" then
                if not highlight then
                    highlight = Instance.new("Highlight", plr.Character)
                    highlight.Name = "Minoxx_3D"
                    highlight.FillColor = Settings.Accent
                    highlight.FillTransparency = 0.5
                end
                box.Visible = false
            else
                if highlight then highlight:Destroy() end
            end

            if onScreen then
                -- Tracers
                tracer.Visible = Settings.Tracers
                tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(vector.X, vector.Y)
                tracer.Color = Settings.Accent

                -- Name/Health Label
                label.Visible = true
                label.Position = Vector2.new(vector.X, vector.Y - 50)
                label.Text = string.format("[%s] HP: %d", plr.Name, hum and hum.Health or 0)
                label.Center = true
                label.Outline = true
                label.Size = 14

                -- 2D Box Logic
                if Settings.ESPMode == "2D" then
                    box.Visible = true
                    box.Size = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
                    box.Position = Vector2.new(vector.X - box.Size.X / 2, vector.Y - box.Size.Y / 2)
                    box.Color = Settings.Accent
                    box.Thickness = 1
                end
            else
                tracer.Visible = false
                label.Visible = false
                box.Visible = false
            end
        else
            tracer.Visible = false
            label.Visible = false
            box.Visible = false
            local h = plr.Character and plr.Character:FindFirstChild("Minoxx_3D")
            if h then h:Destroy() end
        end
    end)
end

for _, v in pairs(Players:GetPlayers()) do CreateESP(v) end
Players.PlayerAdded:Connect(CreateESP)

-- // AIMASSIST //
RunService.RenderStepped:Connect(function()
    FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
    if Settings.AimAssist then
        local target = nil
        local closest = Settings.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < closest then closest, target = mag, p end
                end
            end
        end
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), 0.1)
        end
    end
end)

-- // BUTTONS //
local function AddToggle(text, prop)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        Settings[prop] = not Settings[prop]
        b.BackgroundColor3 = Settings[prop] and Settings.Accent or Color3.fromRGB(30, 30, 35)
    end)
end

AddToggle("Aim Assist", "AimAssist")
AddToggle("Tracers", "Tracers")
AddToggle("Master ESP", "ESP")

-- THE MODE SWITCHER
local ModeBtn = Instance.new("TextButton", Container)
ModeBtn.Size = UDim2.new(1, 0, 0, 35)
ModeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
ModeBtn.Text = "Mode: 2D"
ModeBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", ModeBtn)

ModeBtn.MouseButton1Click:Connect(function()
    if Settings.ESPMode == "2D" then
        Settings.ESPMode = "3D"
        ModeBtn.Text = "Mode: 3D (Glow)"
    else
        Settings.ESPMode = "2D"
        ModeBtn.Text = "Mode: 2D (Box)"
    end
end)

-- Dragging & Icon
local Icon = Instance.new("TextButton", ScreenGui)
Icon.Size = UDim2.new(0, 40, 0, 40)
Icon.Position = UDim2.new(0, 10, 0.4, 0)
Icon.Text = "M"
Icon.BackgroundColor3 = Settings.Accent
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)
Icon.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging, dragStart, startPos = true, input.Position, Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
