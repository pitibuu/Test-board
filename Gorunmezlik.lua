local Services = {
    Players = game:GetService("Players"),
    StarterGui = game:GetService("StarterGui"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace")
}

local player = Services.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local primaryPart = character:WaitForChild("HumanoidRootPart")

local invis_on = false
local defaultSpeed = 16
local boostedSpeed = 48
local isSpeedBoosted = false
local healthConnection = nil

local function cleanPreviousStates()
    pcall(function()
        for _, gui in ipairs(player:WaitForChild("PlayerGui"):GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name == "Mei_wu Mod Menu" or gui.Name == "Mei_wu Notification") then
                gui:Destroy()
            end
        end

        local existingInvisChair = Services.Workspace:FindFirstChild('invischair')
        if existingInvisChair then
            existingInvisChair:Destroy()
        end

        if humanoid and humanoid.Parent then
            humanoid.WalkSpeed = defaultSpeed
        end

        if character and character.Parent then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("MeshPart") then
                    part.Transparency = 0
                elseif part:IsA("Accessory") then
                    for _, accPart in ipairs(part:GetDescendants()) do
                        if accPart:IsA("BasePart") or accPart:IsA("Decal") or accPart:IsA("MeshPart") then
                            accPart.Transparency = 0
                        end
                    end
                end
            end
        end

        if healthConnection then
            healthConnection:Disconnect()
            healthConnection = nil
        end
    end)
end
cleanPreviousStates()

local notifGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
notifGui.Name = "Mei_wu Notification"
notifGui.ResetOnSpawn = false

local notifFrame = Instance.new("Frame", notifGui)
notifFrame.Size = UDim2.new(0, 240, 0, 60)
notifFrame.Position = UDim2.new(1, 50, 0, 15)
notifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
notifFrame.BackgroundTransparency = 0.15
notifFrame.AnchorPoint = Vector2.new(1, 0)
notifFrame.Visible = false
notifFrame.BorderSizePixel = 0
notifFrame.ClipsDescendants = true

local notifCorner = Instance.new("UICorner", notifFrame)
notifCorner.CornerRadius = UDim.new(0, 14)

local shadow = Instance.new("ImageLabel", notifFrame)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://3523067697"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ZIndex = 0

local notifIcon = Instance.new("ImageLabel", notifFrame)
notifIcon.Size = UDim2.new(0, 40, 0, 40)
notifIcon.Position = UDim2.new(0, 10, 0.5, -20)
notifIcon.BackgroundTransparency = 1
notifIcon.Image = "rbxassetid://6031094677"
notifIcon.ZIndex = 2

local notifLabel = Instance.new("TextLabel", notifFrame)
notifLabel.Size = UDim2.new(1, -60, 1, 0)
notifLabel.Position = UDim2.new(0, 60, 0, 0)
notifLabel.BackgroundTransparency = 1
notifLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
notifLabel.Font = Enum.Font.GothamBold
notifLabel.TextScaled = true
notifLabel.TextXAlignment = Enum.TextXAlignment.Left
notifLabel.ZIndex = 2

local tweenInInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenOutInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

local function showNotification(text)
    notifLabel.Text = text
    notifFrame.Position = UDim2.new(1, 50, 0, 15)
    notifFrame.Visible = true
    local tweenIn = Services.TweenService:Create(notifFrame, tweenInInfo, {Position = UDim2.new(1, -250, 0, 15)})
    tweenIn:Play()
    tweenIn.Completed:Wait()
    task.wait(2.5)
    local tweenOut = Services.TweenService:Create(notifFrame, tweenOutInfo, {Position = UDim2.new(1, 50, 0, 15)})
    tweenOut:Play()
    tweenOut.Completed:Wait()
    notifFrame.Visible = false
}

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "Mei_wu Mod Menu"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 150, 0, 120)
frame.Position = UDim2.new(0.5, -75, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true
frame.BackgroundTransparency = 0.1
frame.ClipsDescendants = true
frame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", frame)
UICorner.CornerRadius = UDim.new(0, 12)

local signatureLabel = Instance.new("TextLabel", frame)
signatureLabel.Size = UDim2.new(1, 0, 0, 20)
signatureLabel.Position = UDim2.new(0, 0, 0, 0)
signatureLabel.BackgroundTransparency = 1
signatureLabel.Text = "Discord @Mei_wu."
signatureLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
signatureLabel.Font = Enum.Font.Gotham
signatureLabel.TextScaled = true
signatureLabel.TextXAlignment = Enum.TextXAlignment.Center

local function createButton(name, text, color, posY)
    local btn = Instance.new("TextButton", frame)
    btn.Name = name
    btn.Size = UDim2.new(0, 120, 0, 35)
    btn.Position = UDim2.new(0.5, -60, 0, posY)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.AutoButtonColor = false
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = color:lerp(Color3.fromRGB(255,255,255),0.2) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = color end)
    return btn
end

local toggleButton = createButton("Toggle", "INVISIBLE", Color3.fromRGB(0,170,255), 30)
local speedButton = createButton("Speed", "SPEED BOOST", Color3.fromRGB(255,0,0), 75)

local sound = Instance.new("Sound", player:WaitForChild("PlayerGui"))
sound.SoundId = "rbxassetid://942127495"
sound.Volume = 1

local function setTransparency(char, transparency)
    pcall(function()
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") or part:IsA("MeshPart") then
                part.Transparency = transparency
            elseif part:IsA("Accessory") then
                for _, accPart in ipairs(part:GetDescendants()) do
                    if accPart:IsA("BasePart") or accPart:IsA("Decal") or accPart:IsA("MeshPart") then
                        accPart.Transparency = transparency
                    end
                end
            end
        end
    end)
}

local function enableAntiDeath()
    if healthConnection then healthConnection:Disconnect() end

    healthConnection = humanoid.HealthChanged:Connect(function(health)
        if health <= 0 then
            humanoid.Health = humanoid.MaxHealth
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            if primaryPart then
                 primaryPart.CFrame = primaryPart.CFrame + Vector3.new(0, 10, 0)
            end
            showNotification("Death prevented with anti-death mechanism!")
        end
    end)
}

local function disableAntiDeath()
    if healthConnection then
        healthConnection:Disconnect()
        healthConnection = nil
    end
}

local function toggleInvisibility()
    invis_on = not invis_on
    sound:Play()
    if invis_on then
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        local savedpos = character.HumanoidRootPart.CFrame
        
        local existingInvisChair = Services.Workspace:FindFirstChild('invischair')
        if existingInvisChair then
            existingInvisChair:Destroy()
        end

        Services.Workspace.CurrentCamera.CameraSubject = nil
        
        character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
        task.wait(0.15)

        local Seat = Instance.new('Seat', Services.Workspace)
        Seat.Anchored = false
        Seat.CanCollide = false
        Seat.Name = 'invischair'
        Seat.Transparency = 1
        Seat.Position = Vector3.new(-25.95, 84, 3537.55)
        
        local Weld = Instance.new("Weld")
        Weld.Part0 = Seat
        Weld.Part1 = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        Weld.Parent = Seat

        task.wait()
        Seat.CFrame = savedpos

        setTransparency(character, 0.5)
        showNotification("Invis (on)")
        enableAntiDeath()
    else
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        local invisChair = Services.Workspace:FindFirstChild('invischair')
        if invisChair then
            invisChair:Destroy()
        end
        setTransparency(character, 0)
        showNotification("Invis (off)")
        disableAntiDeath()
    end
}

local function toggleSpeedBoost()
    isSpeedBoosted = not isSpeedBoosted
    sound:Play()
    
    if not humanoid or not humanoid.Parent then
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:WaitForChild("Humanoid")
    end

    if humanoid then
        if isSpeedBoosted then
            humanoid.WalkSpeed = boostedSpeed
            speedButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            showNotification("Speed Boost (on) - " .. boostedSpeed)
        else
            humanoid.WalkSpeed = defaultSpeed
            speedButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            showNotification("Speed Boost (off) - " .. defaultSpeed)
        end
    end
}

toggleButton.MouseButton1Click:Connect(toggleInvisibility)
speedButton.MouseButton1Click:Connect(toggleSpeedBoost)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    primaryPart = newChar:WaitForChild("HumanoidRootPart")

    isSpeedBoosted = false
    humanoid.WalkSpeed = defaultSpeed
    speedButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

    invis_on = false
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    setTransparency(newChar, 0)
    disableAntiDeath()

    local existingInvisChair = Services.Workspace:FindFirstChild('invischair')
    if existingInvisChair then
        existingInvisChair:Destroy()
    end
end)
