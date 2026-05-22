repeat task.wait() until game:IsLoaded()

local function isAdonisAC(tab) 
    return rawget(tab,"Detected") and typeof(rawget(tab,"Detected"))=="function" and rawget(tab,"RLocked") 
end
for _,v in next,getgc(true) do 
    if typeof(v)=="table" and isAdonisAC(v) then 
        for i,f in next,v do 
            if rawequal(i,"Detected") then 
                local old 
                old=hookfunction(f,function(action,info,crash)
                    if rawequal(action,"_") and rawequal(info,"_") and rawequal(crash,false) then 
                        return old(action,info,crash) 
                    end 
                    return task.wait(9e9) 
                end) 
                warn("bypassed") 
                break 
            end 
        end 
    end 
end
for _,v in pairs(getgc(true)) do 
    if type(v)=="table" then 
        local func=rawget(v,"DTXC1") 
        if type(func)=="function" then 
            hookfunction(func,function() return end) 
            break 
        end 
    end 
end
local TargetList = {}
local Whitelist = {}
local function tableContains(t, value)
    for _, v in ipairs(t) do if v == value then return true end end
    return false
end

local function tableRemove(t, value)
    for i, v in ipairs(t) do
        if v == value then table.remove(t, i) return true end
    end
    return false
end
local LegitAimbotModule = {
    Enabled = false,
    Settings = {
        FOV = 120,
        Smoothness = 40,
        VisibleCheck = true,
        ForcefieldCheck = true,
        DownedCheck = true,
        DiedCheck = true,
        TeamCheck = true,
        AimKey = Enum.KeyCode.LeftAlt,
        UseKeybind = true
    },
    ArmChams = {
        Enabled = false,
        OriginalTransparency = {},
        OriginalMaterial = {},
        TransparencyValue = 0.5
    },
    ItemsChams = {
        Enabled = false,
        OriginalData = {},
        TransparencyValue = 0.5
    },
    Connection = nil
}

local function InitializeLegitAimbot()
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    local function GetViewModel()
        return Camera:FindFirstChild("ViewModel")
    end
    
    local function GetArms()
        local viewModel = GetViewModel()
        if not viewModel then return nil, nil end
        
        local rightArm = viewModel:FindFirstChild("Right Arm")
        local leftArm = viewModel:FindFirstChild("Left Arm")
        
        return rightArm, leftArm
    end
    
    local function ApplyArmChams()
        local rightArm, leftArm = GetArms()
        if not rightArm or not leftArm then return end
        
        for _, arm in pairs({rightArm, leftArm}) do
            if not LegitAimbotModule.ArmChams.OriginalTransparency[arm] then
                LegitAimbotModule.ArmChams.OriginalTransparency[arm] = arm.Transparency
                LegitAimbotModule.ArmChams.OriginalMaterial[arm] = arm.Material
            end
            
            arm.Transparency = LegitAimbotModule.ArmChams.TransparencyValue
            arm.Material = Enum.Material.ForceField
        end
    end
    
    local function RestoreArms()
        local rightArm, leftArm = GetArms()
        if not rightArm or not leftArm then return end
        
        for _, arm in pairs({rightArm, leftArm}) do
            if LegitAimbotModule.ArmChams.OriginalTransparency[arm] then
                arm.Transparency = LegitAimbotModule.ArmChams.OriginalTransparency[arm]
            end
            
            if LegitAimbotModule.ArmChams.OriginalMaterial[arm] then
                arm.Material = LegitAimbotModule.ArmChams.OriginalMaterial[arm]
            end
        end
    end
    
    local function UpdateArms()
        if LegitAimbotModule.ArmChams.Enabled then
            ApplyArmChams()
        else
            RestoreArms()
        end
    end
    
    local function ApplyItemsChams()
        local localPlayer = game.Players.LocalPlayer
        
        if localPlayer:FindFirstChild("Backpack") then
            for _, tool in ipairs(localPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, part in ipairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if not LegitAimbotModule.ItemsChams.OriginalData[part] then
                                LegitAimbotModule.ItemsChams.OriginalData[part] = {
                                    Transparency = part.Transparency,
                                    Material = part.Material
                                }
                            end
                            
                            part.Transparency = LegitAimbotModule.ItemsChams.TransparencyValue
                            part.Material = Enum.Material.ForceField
                        end
                    end
                end
            end
        end
        
        local character = localPlayer.Character
        if character then
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, part in ipairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") then
                            if not LegitAimbotModule.ItemsChams.OriginalData[part] then
                                LegitAimbotModule.ItemsChams.OriginalData[part] = {
                                    Transparency = part.Transparency,
                                    Material = part.Material
                                }
                            end
                            
                            part.Transparency = LegitAimbotModule.ItemsChams.TransparencyValue
                            part.Material = Enum.Material.ForceField
                        end
                    end
                end
            end
        end
    end
    
    local function RestoreItemsChams()
        for part, data in pairs(LegitAimbotModule.ItemsChams.OriginalData) do
            if part and part.Parent then
                part.Transparency = data.Transparency
                part.Material = data.Material
            end
        end
        LegitAimbotModule.ItemsChams.OriginalData = {}
    end
    
    local function UpdateItemsChams()
        if LegitAimbotModule.ItemsChams.Enabled then
            ApplyItemsChams()
        else
            RestoreItemsChams()
        end
    end
    
    local function IsVisible(targetPart, origin)
        if not origin then
            origin = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            if not origin then return false end
        end
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local direction = (targetPart.Position - origin.Position).Unit
        local raycastResult = workspace:Raycast(origin.Position, direction * 1000, raycastParams)
        
        if raycastResult then
            local hitPart = raycastResult.Instance
            local hitChar = hitPart:FindFirstAncestorOfClass("Model")
            return hitChar == targetPart.Parent
        end
        return true
    end

    local function HasForcefield(character)
        if not character then return false end
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("ForceField") then
                return true
            end
        end
        return false
    end

    local function GetHealth(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            return humanoid.Health
        end
        return 100
    end

    local function IsAlive(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            return humanoid.Health > 0
        end
        return false
    end

    local function GetClosestPlayer()
        local closest = nil
        local closestDist = LegitAimbotModule.Settings.FOV
        
        local camera = workspace.CurrentCamera
        local mousePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if LegitAimbotModule.Settings.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local character = player.Character
                if character then
                    if LegitAimbotModule.Settings.DiedCheck and not IsAlive(character) then
                        continue
                    end
                    
                    if LegitAimbotModule.Settings.DownedCheck and GetHealth(character) < 15 then
                        continue
                    end
                    
                    if LegitAimbotModule.Settings.ForcefieldCheck and HasForcefield(character) then
                        continue
                    end
                    
                    local head = character:FindFirstChild("Head")
                    if head then
                        local screenPoint = camera:WorldToViewportPoint(head.Position)
                        if screenPoint.Z > 0 then
                            local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                            local distance = (mousePos - screenPos).Magnitude
                            
                            if LegitAimbotModule.Settings.VisibleCheck and not IsVisible(head) then
                                continue
                            end
                            
                            if distance < closestDist then
                                closestDist = distance
                                closest = {player = player, character = character, head = head}
                            end
                        end
                    end
                end
            end
        end
        
        return closest
    end

    local function ShouldAim()
        if not LegitAimbotModule.Enabled then
            return false
        end
        
        if LegitAimbotModule.Settings.UseKeybind then
            return UserInputService:IsKeyDown(LegitAimbotModule.Settings.AimKey)
        else
            return true
        end
    end

    local function AimAssist()
        if not ShouldAim() then return end
        
        local targetData = GetClosestPlayer()
        if targetData then
            local camera = workspace.CurrentCamera
            
            local targetCFrame = CFrame.new(camera.CFrame.Position, targetData.head.Position)
            local currentCFrame = camera.CFrame
            
            local smoothFactor = (100 - LegitAimbotModule.Settings.Smoothness) / 100
            smoothFactor = math.max(smoothFactor, 0.01)
            
            local lerpCFrame = currentCFrame:Lerp(targetCFrame, smoothFactor * 0.1)
            
            camera.CFrame = lerpCFrame
        end
    end

    LegitAimbotModule.Connection = RunService.RenderStepped:Connect(function()
        if LegitAimbotModule.Enabled then
            AimAssist()
        end
        UpdateArms()
        UpdateItemsChams()
    end)

    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        UpdateArms()
    end)

    

    workspace.DescendantAdded:Connect(function(descendant)
        if LegitAimbotModule.ItemsChams.Enabled and descendant:IsA("Tool") then
            task.wait()
            ApplyItemsChams()
        end
    end)
end

InitializeLegitAimbot()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/helloxyzcodervisuals/warepastecc/refs/heads/main/warepastecc.lua"))()
local UI = Library:CreateWindow("Warepaste", UDim2.new(0, 650, 0, 750))
local Tab1 = UI:CreateTab("Legitbot")
local Sec1 = Tab1:CreateSection("Aimbot", "Left")
local Sec2 = Tab1:CreateSection("Visual", "Right")

Sec1:CreateToggle("Enable Legit Aimbot", false, function(v)
    LegitAimbotModule.Enabled = v
end)

Sec1:CreateToggle("Visible Check", true, function(v)
    LegitAimbotModule.Settings.VisibleCheck = v
end)

Sec1:CreateToggle("Forcefield Check", true, function(v)
    LegitAimbotModule.Settings.ForcefieldCheck = v
end)

Sec1:CreateToggle("Downed Check", true, function(v)
    LegitAimbotModule.Settings.DownedCheck = v
end)

Sec1:CreateToggle("Died Check", true, function(v)
    LegitAimbotModule.Settings.DiedCheck = v
end)

Sec1:CreateToggle("Team Check", true, function(v)
    LegitAimbotModule.Settings.TeamCheck = v
end)

Sec1:CreateToggle("Use Keybind", true, function(v)
    LegitAimbotModule.Settings.UseKeybind = v
end)

Sec1:CreateSlider("FOV Size", 0, 360, 120, "°", function(v)
    LegitAimbotModule.Settings.FOV = v
end)

Sec1:CreateSlider("Smoothness", 0, 100, 40, "%", function(v)
    LegitAimbotModule.Settings.Smoothness = v
end)

Sec1:CreateKeybind("Aimbot Key", Enum.KeyCode.LeftAlt, function(key)
    LegitAimbotModule.Settings.AimKey = key
end)

Sec1:CreateButton("Test Aimbot", function()
    print("Legit Aimbot Test")
end)

Sec2:CreateToggle("Arm Chams", false, function(v)
    LegitAimbotModule.ArmChams.Enabled = v
end)

Sec2:CreateSlider("Arm Transparency", 0, 1, 0.5, "", function(v)
    LegitAimbotModule.ArmChams.TransparencyValue = v
end)

Sec2:CreateToggle("Items Chams", false, function(v)
    LegitAimbotModule.ItemsChams.Enabled = v
end)

Sec2:CreateSlider("Items Transparency", 0, 1, 0.5, "", function(v)
    LegitAimbotModule.ItemsChams.TransparencyValue = v
end)

Sec2:CreateButton("Reset All Chams", function()
    LegitAimbotModule.ArmChams.Enabled = false
    LegitAimbotModule.ItemsChams.Enabled = false
    
    local rightArm, leftArm = GetArms()
    if rightArm and LegitAimbotModule.ArmChams.OriginalTransparency[rightArm] then
        rightArm.Transparency = LegitAimbotModule.ArmChams.OriginalTransparency[rightArm]
        rightArm.Material = LegitAimbotModule.ArmChams.OriginalMaterial[rightArm]
    end
    if leftArm and LegitAimbotModule.ArmChams.OriginalTransparency[leftArm] then
        leftArm.Transparency = LegitAimbotModule.ArmChams.OriginalTransparency[leftArm]
        leftArm.Material = LegitAimbotModule.ArmChams.OriginalMaterial[leftArm]
    end
    
    for part, data in pairs(LegitAimbotModule.ItemsChams.OriginalData) do
        if part and part.Parent then
            part.Transparency = data.Transparency
            part.Material = data.Material
        end
    end
    LegitAimbotModule.ItemsChams.OriginalData = {}
end)
local VisualModule = {
    ESP = {
        Enabled = false,
        Box = true,
        Name = true,
        Distance = true,
        Health = true,
        Tool = true,
        TeamColor = false,
        MaxDistance = 500,
        BoxColor = Color3.new(1, 1, 1),
        NameColor = Color3.new(1, 1, 1),
        DistanceColor = Color3.new(1, 1, 1),
        HealthColor = Color3.fromRGB(0, 255, 0),
        EnemyColor = Color3.fromRGB(255, 50, 50),
        FriendColor = Color3.fromRGB(0, 150, 255),
        TextSize = 14
    },
    PlayerChams = {
        Enabled = false,
        BoxChams = true,
        Color = Color3.fromRGB(170, 0, 255),
        BorderColor = Color3.new(1, 1, 1),
        Transparency = 0,
        BorderTransparency = 0.5,
        LightEnabled = true,
        GlowEnabled = true,
        WallCheck = true,
        WallColor = Color3.new(1, 1, 1),
        WallTransparency = 0.3
    }
}

local function InitializeVisuals()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local CoreGui = game:GetService("CoreGui")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    
    local l_1 = Players
    local l_4 = RunService
    local l_7 = CoreGui
    local l_8 = LocalPlayer
    local Camera = Camera
    
    local function vc()
        local v2 = "Font_" .. tostring(math.random(10000, 99999))
        local v24 = "Folder_" .. tostring(math.random(10000, 99999))
        if isfolder("UI_Fonts") then delfolder("UI_Fonts") end
        makefolder(v24)
        local v3 = v24 .. "/" .. v2 .. ".ttf"
        local v4 = v24 .. "/" .. v2 .. ".json"
        
        local success, body = pcall(function()
            return game:HttpGet("https://github.com/i77lhm/storage/blob/main/fonts/smallest_pixel-7.ttf?raw=true")
        end)
        
        if success then 
            writefile(v3, body) 
        else
            return Font.fromEnum(Enum.Font.Code)
        end

        local v16 = {
            name = v2,
            faces = {{
                name = "Regular",
                weight = 400,
                style = "Normal",
                assetId = getcustomasset(v3)
            }}
        }
        writefile(v4, game:GetService("HttpService"):JSONEncode(v16))
        VisualModule.Font = Font.new(getcustomasset(v4))
    end
    
    vc()
    
    local espParts = {}
    local chamParts = {}
    local connections = {}
    local espDrawings = {}
    
    local function createESP(player)
        if player == l_8 then return end
        if espDrawings[player] then return end

        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 1
        box.Filled = false
        box.Color = VisualModule.ESP.BoxColor
        box.Transparency = 1

        local sg = Instance.new("ScreenGui")
        sg.Name = player.Name .. "_ESP"
        sg.IgnoreGuiInset = true
        sg.Parent = l_7

        local infoLabel = Instance.new("TextLabel")
        infoLabel.BackgroundTransparency = 1
        infoLabel.TextColor3 = VisualModule.ESP.NameColor
        infoLabel.FontFace = VisualModule.Font or Font.fromEnum(Enum.Font.Code)
        infoLabel.TextSize = VisualModule.ESP.TextSize
        infoLabel.TextStrokeTransparency = 0
        infoLabel.Parent = sg

        local distLabel = Instance.new("TextLabel")
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = VisualModule.ESP.DistanceColor
        distLabel.FontFace = VisualModule.Font or Font.fromEnum(Enum.Font.Code)
        distLabel.TextSize = VisualModule.ESP.TextSize
        distLabel.TextStrokeTransparency = 0
        distLabel.Parent = sg

        local healthOutline = Instance.new("Frame")
        healthOutline.BackgroundColor3 = Color3.new(0, 0, 0)
        healthOutline.BorderSizePixel = 1
        healthOutline.BorderColor3 = Color3.new(0, 0, 0)
        healthOutline.Visible = false
        healthOutline.Parent = sg

        local healthFill = Instance.new("Frame")
        healthFill.BorderSizePixel = 0
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.Parent = healthOutline

        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 0)),
            ColorSequenceKeypoint.new(1, VisualModule.ESP.HealthColor)
        })
        gradient.Rotation = -90
        gradient.Parent = healthFill

        local connection
        connection = l_4.RenderStepped:Connect(function()
            if not VisualModule.ESP.Enabled then
                box.Visible = false
                infoLabel.Visible = false
                distLabel.Visible = false
                healthOutline.Visible = false
                return
            end
            
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if hrp and hum and hum.Health > 0 then
                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                if dist > VisualModule.ESP.MaxDistance then
                    box.Visible = false
                    infoLabel.Visible = false
                    distLabel.Visible = false
                    healthOutline.Visible = false
                    return
                end
                
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local sizeX, sizeY = 2000/dist, 3500/dist
                    local topY = pos.Y - sizeY/2
                    local bottomY = pos.Y + sizeY/2
                    local tool = char:FindFirstChildOfClass("Tool")
                    local toolName = tool and tool.Name or "None"

                    box.Visible = VisualModule.ESP.Box
                    box.Position = Vector2.new(pos.X - sizeX/2, topY)
                    box.Size = Vector2.new(sizeX, sizeY)
                    
                    if VisualModule.ESP.TeamColor then
                        if player.Team == l_8.Team then
                            box.Color = VisualModule.ESP.FriendColor
                            infoLabel.TextColor3 = VisualModule.ESP.FriendColor
                            distLabel.TextColor3 = VisualModule.ESP.FriendColor
                        else
                            box.Color = VisualModule.ESP.EnemyColor
                            infoLabel.TextColor3 = VisualModule.ESP.EnemyColor
                            distLabel.TextColor3 = VisualModule.ESP.EnemyColor
                        end
                    else
                        box.Color = VisualModule.ESP.BoxColor
                        infoLabel.TextColor3 = VisualModule.ESP.NameColor
                        distLabel.TextColor3 = VisualModule.ESP.DistanceColor
                    end

                    infoLabel.Visible = VisualModule.ESP.Name
                    infoLabel.Text = player.Name .. (VisualModule.ESP.Tool and " [" .. toolName .. "]" or "")
                    infoLabel.Position = UDim2.new(0, pos.X, 0, topY - 20)

                    distLabel.Visible = VisualModule.ESP.Distance
                    distLabel.Text = math.floor(dist) .. "ft"
                    distLabel.Position = UDim2.new(0, pos.X, 0, bottomY + 8)

                    healthOutline.Visible = VisualModule.ESP.Health
                    healthOutline.Position = UDim2.new(0, (pos.X - sizeX/2) - 6, 0, topY)
                    healthOutline.Size = UDim2.new(0, 3, 0, sizeY)

                    local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    healthFill.Size = UDim2.new(1, 0, hpPercent, 0)
                    healthFill.Position = UDim2.new(0, 0, 1 - hpPercent, 0)
                    return
                end
            end
            box.Visible = false
            infoLabel.Visible = false
            distLabel.Visible = false
            healthOutline.Visible = false
        end)

        espDrawings[player] = {
            box = box,
            gui = sg,
            infoLabel = infoLabel,
            distLabel = distLabel,
            healthOutline = healthOutline,
            connection = connection
        }

        player.AncestryChanged:Connect(function()
            if not player:IsDescendantOf(l_1) then
                if espDrawings[player] then
                    espDrawings[player].box:Remove()
                    espDrawings[player].gui:Destroy()
                    espDrawings[player].connection:Disconnect()
                    espDrawings[player] = nil
                end
            end
        end)
    end
    
    local function createChams(character)
        if not VisualModule.PlayerChams.Enabled then return end
        if chamParts[character] then return end
        
        local boxes = {}
        
        local bodyParts = {
            "Head",
            "Torso", 
            "Left Arm",
            "Right Arm",
            "Left Leg",
            "Right Leg"
        }
        
        for _, partName in ipairs(bodyParts) do
            local originalPart = character:FindFirstChild(partName)
            if originalPart and originalPart:IsA("BasePart") then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ChamsBox"
                box.Adornee = originalPart
                box.AlwaysOnTop = true
                box.ZIndex = 1
                box.Size = originalPart.Size
                box.Transparency = VisualModule.PlayerChams.Transparency
                box.Color3 = VisualModule.PlayerChams.Color
                
                local whiteBorder = Instance.new("BoxHandleAdornment")
                whiteBorder.Name = "ChamsBorder"
                whiteBorder.Adornee = originalPart
                whiteBorder.AlwaysOnTop = true
                whiteBorder.ZIndex = 0
                whiteBorder.Size = originalPart.Size + Vector3.new(0.05, 0.05, 0.05)
                whiteBorder.Transparency = VisualModule.PlayerChams.BorderTransparency
                whiteBorder.Color3 = VisualModule.PlayerChams.BorderColor
                
                if VisualModule.PlayerChams.LightEnabled then
                    local pointLight = Instance.new("PointLight")
                    pointLight.Name = "ChamsLight"
                    pointLight.Parent = box
                    pointLight.Brightness = 1.2
                    pointLight.Range = 8
                    pointLight.Shadows = false
                    pointLight.Color = VisualModule.PlayerChams.Color
                end
                
                if VisualModule.PlayerChams.GlowEnabled then
                    local bloomEffect = Instance.new("BloomEffect")
                    bloomEffect.Name = "ChamsGlow"
                    bloomEffect.Parent = box
                    bloomEffect.Intensity = 0.15
                    bloomEffect.Size = 12
                    bloomEffect.Threshold = 0.9
                end
                
                box.Parent = character
                whiteBorder.Parent = character
                
                table.insert(boxes, {box = box, border = whiteBorder})
            end
        end
        
        chamParts[character] = boxes
    end
    
    local function updateChams()
        for character, boxes in pairs(chamParts) do
            if character and character:IsDescendantOf(Workspace) then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local isBehindWall = false
                        
                        if VisualModule.PlayerChams.WallCheck then
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                            raycastParams.FilterDescendantsInstances = {character, camera}
                            raycastParams.IgnoreWater = true
                            
                            local origin = camera.CFrame.Position
                            local direction = (rootPart.Position - origin).Unit * 500
                            local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
                            
                            if raycastResult then
                                local hitParent = raycastResult.Instance:GetFullName()
                                local targetParent = character:GetFullName()
                                if not string.find(hitParent, targetParent) then
                                    isBehindWall = true
                                end
                            end
                        end
                        
                        for _, boxData in ipairs(boxes) do
                            if boxData.box.Adornee and boxData.box.Adornee:IsDescendantOf(Workspace) then
                                if isBehindWall then
                                    boxData.box.Visible = false
                                    boxData.border.Color3 = VisualModule.PlayerChams.WallColor
                                    boxData.border.Transparency = VisualModule.PlayerChams.WallTransparency
                                    boxData.border.Visible = true
                                else
                                    boxData.box.Visible = VisualModule.PlayerChams.BoxChams
                                    boxData.box.Color3 = VisualModule.PlayerChams.Color
                                    boxData.box.Transparency = VisualModule.PlayerChams.Transparency
                                    boxData.border.Color3 = VisualModule.PlayerChams.BorderColor
                                    boxData.border.Transparency = VisualModule.PlayerChams.BorderTransparency
                                    boxData.border.Visible = true
                                end
                                
                                boxData.box.Size = boxData.box.Adornee.Size
                                boxData.border.Size = boxData.box.Adornee.Size + Vector3.new(0.05, 0.05, 0.05)
                            end
                        end
                    end
                else
                    for _, boxData in ipairs(boxes) do
                        boxData.box:Destroy()
                        boxData.border:Destroy()
                    end
                    chamParts[character] = nil
                end
            else
                for _, boxData in ipairs(boxes) do
                    boxData.box:Destroy()
                    boxData.border:Destroy()
                end
                chamParts[character] = nil
            end
        end
    end
    
    local function onPlayerAdded(player)
        if player ~= LocalPlayer then
            local function characterAdded(character)
                task.wait(1)
                createESP(player)
                createChams(character)
            end
            
            if player.Character then
                characterAdded(player.Character)
            end
            
            table.insert(connections, player.CharacterAdded:Connect(characterAdded))
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end
    
    table.insert(connections, Players.PlayerAdded:Connect(onPlayerAdded))
    
    table.insert(connections, Players.PlayerRemoving:Connect(function(player)
        if espDrawings[player] then
            espDrawings[player].box:Remove()
            espDrawings[player].gui:Destroy()
            espDrawings[player].connection:Disconnect()
            espDrawings[player] = nil
        end
        
        local character = player.Character
        if character and chamParts[character] then
            for _, boxData in ipairs(chamParts[character]) do
                boxData.box:Destroy()
                boxData.border:Destroy()
            end
            chamParts[character] = nil
        end
    end))
    
    local updateConnection = RunService.RenderStepped:Connect(function()
        if VisualModule.PlayerChams.Enabled then
            updateChams()
        end
    end)
    
    table.insert(connections, updateConnection)
    
    local function cleanup()
        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end
        
        for player, drawing in pairs(espDrawings) do
            drawing.box:Remove()
            drawing.gui:Destroy()
            drawing.connection:Disconnect()
        end
        
        for character, boxes in pairs(chamParts) do
            for _, boxData in ipairs(boxes) do
                boxData.box:Destroy()
                boxData.border:Destroy()
            end
        end
    end
    
    return cleanup
end

local cleanupVisuals = InitializeVisuals()
local Tab1 = UI:CreateTab("Visuals")
local Sec1 = Tab1:CreateSection("ESP", "Left")

Sec1:CreateToggle("Enable ESP", false, function(v)
    VisualModule.ESP.Enabled = v
end)

Sec1:CreateToggle("Box ESP", true, function(v)
    VisualModule.ESP.Box = v
end)

Sec1:CreateToggle("Name ESP", true, function(v)
    VisualModule.ESP.Name = v
end)

Sec1:CreateToggle("Distance ESP", true, function(v)
    VisualModule.ESP.Distance = v
end)

Sec1:CreateToggle("Health ESP", true, function(v)
    VisualModule.ESP.Health = v
end)

Sec1:CreateToggle("Tool ESP", true, function(v)
    VisualModule.ESP.Tool = v
end)

Sec1:CreateToggle("Team Colors", false, function(v)
    VisualModule.ESP.TeamColor = v
end)

Sec1:CreateSlider("Max Distance", 0, 1000, 500, "ft", function(v)
    VisualModule.ESP.MaxDistance = v
end)

Sec1:CreateSlider("Text Size", 10, 20, 14, "", function(v)
    VisualModule.ESP.TextSize = v
end)

Sec1:CreateColorpicker("Box Color", Color3.new(1, 1, 1), function(c)
    VisualModule.ESP.BoxColor = c
end)

Sec1:CreateColorpicker("Name Color", Color3.new(1, 1, 1), function(c)
    VisualModule.ESP.NameColor = c
end)

Sec1:CreateColorpicker("Distance Color", Color3.new(1, 1, 1), function(c)
    VisualModule.ESP.DistanceColor = c
end)

Sec1:CreateColorpicker("Health Color", Color3.fromRGB(0, 255, 0), function(c)
    VisualModule.ESP.HealthColor = c
end)

Sec1:CreateColorpicker("Enemy Color", Color3.fromRGB(255, 50, 50), function(c)
    VisualModule.ESP.EnemyColor = c
end)

Sec1:CreateColorpicker("Friend Color", Color3.fromRGB(0, 150, 255), function(c)
    VisualModule.ESP.FriendColor = c
end)

local BulletTracersModule = {
    Enabled = false,
    Settings = {
        Lifetime = 1,
        Width = 0.1,
        Color = Color3.fromRGB(255, 255, 255),
        Enabled = false
    }
}

local function InitializeBulletTracers()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local TweenService = game:GetService("TweenService")
    local Camera = Workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    
    local function createTracer(startPos, endPos)
        if not BulletTracersModule.Enabled or not BulletTracersModule.Settings.Enabled then return end
        
        local tracerModel = Instance.new("Model")
        tracerModel.Name = "Tracer"
        
        local beam = Instance.new("Beam")
        beam.Color = ColorSequence.new(BulletTracersModule.Settings.Color)
        beam.Width0 = BulletTracersModule.Settings.Width
        beam.Width1 = BulletTracersModule.Settings.Width
        beam.Texture = "rbxassetid://7136858729"
        beam.TextureSpeed = 1
        beam.Brightness = 2
        beam.LightEmission = 1
        beam.FaceCamera = true
        
        local a0 = Instance.new("Attachment")
        local a1 = Instance.new("Attachment")
        a0.WorldPosition = startPos
        a1.WorldPosition = endPos
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        
        beam.Parent = tracerModel
        a0.Parent = tracerModel
        a1.Parent = tracerModel
        tracerModel.Parent = Workspace
        
        local tweenInfo = TweenInfo.new(BulletTracersModule.Settings.Lifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(beam, tweenInfo, {Brightness = 0, Width0 = 0, Width1 = 0})
        tween:Play()
        
        tween.Completed:Connect(function()
            if tracerModel then 
                tracerModel:Destroy() 
            end 
        end)
        
        task.delay(BulletTracersModule.Settings.Lifetime + 0.1, function()
            if tracerModel and tracerModel.Parent then 
                tracerModel:Destroy() 
            end 
        end)
    end
    
    local function trackGlobalBullets()
        if _G.TracersRunning then return end
        _G.TracersRunning = true
        
        local bfr = Camera:FindFirstChild("Bullets")
        if not bfr then 
            bfr = Instance.new("Folder") 
            bfr.Name = "Bullets" 
            bfr.Parent = Camera 
        end
        
        local function trackBullet(blt)
            if not blt:IsA("BasePart") then return end
            
            local stp = blt.Position
            local lsp = stp
            local stc = 0
            local con
            
            con = RunService.Heartbeat:Connect(function()
                if not blt or not blt.Parent then
                    con:Disconnect()
                    if (lsp - stp).Magnitude > 1 then 
                        createTracer(stp, lsp) 
                    end
                    return
                end
                
                local cp = blt.Position
                if (cp - lsp).Magnitude < 0.1 then
                    stc = stc + 1
                    if stc > 3 then 
                        con:Disconnect() 
                        if (cp - stp).Magnitude > 1 then 
                            createTracer(stp, cp) 
                        end 
                    end
                else 
                    stc = 0 
                    lsp = cp 
                end
            end)
        end
        
        bfr.ChildAdded:Connect(trackBullet)
        for _, v in ipairs(bfr:GetChildren()) do 
            trackBullet(v) 
        end
    end
    
    trackGlobalBullets()
end

InitializeBulletTracers()

Sec1:CreateToggle("Enable Tracers", false, function(v)
    BulletTracersModule.Enabled = v
end)

Sec1:CreateToggle("Show Tracers", false, function(v)
    BulletTracersModule.Settings.Enabled = v
end)

Sec1:CreateSlider("Tracer Lifetime", 0.1, 5, 1, "s", function(v)
    BulletTracersModule.Settings.Lifetime = v
end)

Sec1:CreateSlider("Tracer Width", 0.01, 1, 0.1, "", function(v)
    BulletTracersModule.Settings.Width = v
end)

Sec1:CreateColorpicker("Tracer Color", Color3.fromRGB(255, 255, 255), function(c)
    BulletTracersModule.Settings.Color = c
end)

local CharacterRenderModule = {
    Enabled = false,
    Color = Color3.fromRGB(170, 0, 255),
    Transparency = 0.3
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local OriginalData = {}

local function updateCharacterRender()
    if CharacterRenderModule.Enabled then
        local character = LocalPlayer.Character
        if character then
            local partsToRender = {
                "Torso",
                "Right Leg", 
                "Right Arm",
                "Left Leg",
                "Left Arm",
                "Head"
            }
            
            for _, partName in ipairs(partsToRender) do
                local part = character:FindFirstChild(partName)
                if part and part:IsA("BasePart") then
                    if not OriginalData[part] then
                        OriginalData[part] = {
                            Color = part.Color,
                            Transparency = part.Transparency,
                            Material = part.Material
                        }
                    end
                    
                    part.Color = CharacterRenderModule.Color
                    part.Transparency = CharacterRenderModule.Transparency
                    part.Material = Enum.Material.ForceField
                end
            end
        end
    else
        for part, data in pairs(OriginalData) do
            if part and part.Parent then
                part.Color = data.Color
                part.Transparency = data.Transparency
                part.Material = data.Material
            end
        end
        table.clear(OriginalData)
    end
end

local renderConnection
local function setupCharacterRender()
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    
    if CharacterRenderModule.Enabled then
        renderConnection = RunService.RenderStepped:Connect(updateCharacterRender)
    else
        updateCharacterRender()
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    OriginalData = {}
    if CharacterRenderModule.Enabled then
        task.wait(0.5)
        renderConnection = RunService.RenderStepped:Connect(updateCharacterRender)
    end
end)

if CharacterRenderModule.Enabled then
    setupCharacterRender()
end

local Sec2 = Tab1:CreateSection("Character Rendering", "Right")

Sec2:CreateToggle("Enable", false, function(v)
    CharacterRenderModule.Enabled = v
    setupCharacterRender()
end)

Sec2:CreateColorpicker("Render Color", Color3.fromRGB(170, 0, 255), function(c)
    CharacterRenderModule.Color = c
    if CharacterRenderModule.Enabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = c
                end
            end
        end
    end
end)

Sec2:CreateSlider("Transparency", 0, 1, 0.3, "", function(v)
    CharacterRenderModule.Transparency = v
    if CharacterRenderModule.Enabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = v
                end
            end
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ConfigTable = {
    Ragebot = {
        Enabled = false,
        RapidFire = false,
        FireRate = 30,
        Prediction = true,
        PredictionAmount = 0.12,
        TeamCheck = false,
        VisibilityCheck = true,
        Wallbang = true,
        Tracers = true,
        TracerColor = Color3.fromRGB(255, 0, 0),
        TracerWidth = 1,
        TracerLifetime = 3,
        ShootRange = 15,
        HitRange = 15,
        HitNotify = true,
        AutoReload = true,
        HitSound = true,
        HitColor = Color3.fromRGB(255, 182, 193),
        UseTargetList = true,
        UseWhitelist = true,
        HitNotifyDuration = 5,
        LowHealthCheck = false,
        SelectedHitSound = "Skeet",
        FriendCheck = false,
        MaxTarget = 0,
        TracerTexture = "rbxassetid://7136858729"
    }
}

local function getClosestTarget()
    local character = LocalPlayer.Character
    local localHead = character and character:FindFirstChild("Head")
    if not localHead then return nil end

    local closest = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local isWhitelisted = tableContains(Whitelist, player.Name)
        if ConfigTable.Ragebot.FriendCheck and LocalPlayer:IsFriendsWith(player.UserId) then
            isWhitelisted = true
        end
        
        if ConfigTable.Ragebot.UseWhitelist and isWhitelisted then continue end
        if ConfigTable.Ragebot.UseTargetList and not tableContains(TargetList, player.Name) then continue end
        if ConfigTable.Ragebot.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local head = char and char:FindFirstChild("Head")
        
        if hum and head and hum.Health > 0 then
            if char:FindFirstChildOfClass("ForceField") then continue end
            if ConfigTable.Ragebot.LowHealthCheck and hum.Health < 15 then continue end
            
            local distance = (head.Position - localHead.Position).Magnitude
            if distance < shortestDistance then
                if typeof(canSeeTarget) == "function" and not canSeeTarget(head) then continue end
                closest = head
                shortestDistance = distance
            end
        end
    end
    return closest
end
local lastShotTime = 0
local cachedBestPositions = {shootPos = nil, hitPos = nil, target = nil}
local hitNotifications = {}
local notificationYOffset = 5
local MAX_VISIBLE_NOTIFICATIONS = 15

local function getCurrentTool()
    if LocalPlayer.Character then 
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do 
            if tool:IsA("Tool") then 
                return tool 
            end 
        end 
    end
    return nil
end

local function autoReload()
    if not ConfigTable.Ragebot.AutoReload then
        if instantReloadConnections then
            for _,conn in pairs(instantReloadConnections) do 
                if conn then conn:Disconnect() end 
            end
            instantReloadConnections = {}
        end
        if characterAddedConnection then 
            characterAddedConnection:Disconnect() 
            characterAddedConnection = nil 
        end
        return
    end
    
    if not instantReloadConnections then
        instantReloadConnections = {}
    end
    
    local tool = getCurrentTool()
    if not tool then return end
    
    local values = tool:FindFirstChild("Values")
    if not values then return end
    
    local ammo = values:FindFirstChild("SERVER_Ammo")
    local storedAmmo = values:FindFirstChild("SERVER_StoredAmmo")
    if not ammo or not storedAmmo then return end
    
    for _,conn in pairs(instantReloadConnections) do 
        if conn then conn:Disconnect() end 
    end
    instantReloadConnections = {}
    
    if characterAddedConnection then 
        characterAddedConnection:Disconnect() 
        characterAddedConnection = nil 
    end
    
    local gunR_remote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("GNX_R")
    local me = Players.LocalPlayer
    
    local function setupToolListeners(toolObj)
        if not toolObj or not toolObj:FindFirstChild("IsGun") then return end
        
        local values = toolObj:FindFirstChild("Values")
        if not values then return end
        
        local ammo = values:FindFirstChild("SERVER_Ammo")
        local storedAmmo = values:FindFirstChild("SERVER_StoredAmmo")
        if not ammo or not storedAmmo then return end
        
        local conn1 = storedAmmo:GetPropertyChangedSignal("Value"):Connect(function()
            local currentRagebot = ConfigTable.Ragebot.AutoReload
            if currentRagebot then 
                gunR_remote:FireServer(tick(), "KLWE89U0", toolObj) 
            end
        end)
        
        if storedAmmo.Value ~= 0 then 
            gunR_remote:FireServer(tick(), "KLWE89U0", toolObj) 
        end
        
        local conn2 = ammo:GetPropertyChangedSignal("Value"):Connect(function()
            local currentRagebot = ConfigTable.Ragebot.AutoReload
            if currentRagebot and storedAmmo.Value ~= 0 then 
                gunR_remote:FireServer(tick(), "KLWE89U0", toolObj) 
            end
        end)
        
        table.insert(instantReloadConnections, conn1)
        table.insert(instantReloadConnections, conn2)
    end
    
    local char = me.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then 
            setupToolListeners(tool) 
        end
        
        local conn3 = char.ChildAdded:Connect(function(obj) 
            if obj:IsA("Tool") then 
                setupToolListeners(obj) 
            end 
        end)
        table.insert(instantReloadConnections, conn3)
    end
    
    characterAddedConnection = me.CharacterAdded:Connect(function(charr)
        repeat task.wait() until charr and charr.Parent
        local conn4 = charr.ChildAdded:Connect(function(obj) 
            if obj:IsA("Tool") then 
                setupToolListeners(obj) 
            end 
        end)
        table.insert(instantReloadConnections, conn4)
    end)
end

local function canSeeTarget(targetPart)
    if not ConfigTable.Ragebot.VisibilityCheck then return true end
    local localHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if not localHead then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local startPos = localHead.Position
    local endPos = targetPart.Position
    local direction = (endPos - startPos)
    local distance = direction.Magnitude
    
    local raycastResult = Workspace:Raycast(startPos, direction.Unit * distance, raycastParams)
    if raycastResult then
        local hitPart = raycastResult.Instance
        if hitPart and hitPart.CanCollide then
            local model = hitPart:FindFirstAncestorOfClass("Model")
            if model then
                local humanoid = model:FindFirstChild("Humanoid")
                if humanoid then
                    local targetPlayer = Players:GetPlayerFromCharacter(model)
                    if targetPlayer then return true end
                end
            end
            return false
        end
    end
    return true
end

local function checkClearPath(startPos, endPos)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local direction = (endPos - startPos)
    local distance = direction.Magnitude
    local raycastResult = Workspace:Raycast(startPos, direction.Unit * distance, raycastParams)
    if raycastResult then
        local hitPart = raycastResult.Instance
        if hitPart and hitPart.CanCollide then
            local model = hitPart:FindFirstAncestorOfClass("Model")
            if model then
                local humanoid = model:FindFirstChild("Humanoid")
                if not humanoid then return false end
            else return false end
        end
    end
    return true
end
local l_1=game:GetService("Players")
local l_2=game:GetService("TweenService")
local l_3=game:GetService("UserInputService")
local l_4=game:GetService("RunService")
local l_5=game:GetService("HttpService")
local l_6=game:GetService("TextService")
local l_7=game:GetService("CoreGui")
local l_8=l_1.LocalPlayer
local l_9=l_8:GetMouse()

local function vc()
    local v2="Font_"..tostring(math.random(10000,99999))
    local v24="Folder_"..tostring(math.random(10000,99999))
    if isfolder("UI_Fonts")then delfolder("UI_Fonts")end
    makefolder(v24)
    local v3=v24.."/"..v2..".ttf"
    local v4=v24.."/"..v2..".json"
    local v5=v24.."/"..v2..".rbxmx"
    if not isfile(v3)then
        local v8=pcall(function()
            local v9=request({Url="https://raw.githubusercontent.com/bluescan/proggyfonts/refs/heads/master/ProggyOriginal/ProggyClean.ttf",Method="GET"})
            if v9 and v9.Success then writefile(v3,v9.Body)return true end
            return false
        end)
        if not v8 then return Font.fromEnum(Enum.Font.Code)end
    end
    local v12=pcall(function()
        local v13=readfile(v3)
        local v14=game:GetService("TextService"):RegisterFontFaceAsync(v13,v2)
        return v14
    end)
    if v12 then return v12 end
    local v15=pcall(function()return Font.fromFilename(v3)end)
    if v15 then return v15 end
    local v16={name=v2,faces={{name="Regular",weight=400,style="Normal",assetId=getcustomasset(v3)}}}
    writefile(v4,game:GetService("HttpService"):JSONEncode(v16))
    local v17,v18=pcall(function()return Font.new(getcustomasset(v4))end)
    if v17 then return v18 end
    local v19=[[
<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
<External>null</External>
<External>nil</External>
<Item class="FontFace" referent="RBX0">
<Properties>
<Content name="FontData">
<url>rbxasset://]]..v3..[[</url>
</Content>
<string name="Family">]]..v2..[[</string>
<token name="Style">0</token>
<token name="Weight">400</token>
</Properties>
</Item>
</roblox>]]
    writefile(v5,v19)
    return Font.fromEnum(Enum.Font.Code)
end
local l_26=vc()
local function wallbang()
    local localHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if not localHead then return nil, nil, false end
    
    local target = getClosestTarget()
    if not target then 
        cachedBestPositions = {shootPos = nil, hitPos = nil, target = nil}
        return nil, nil, false
    end
    
    local startPos = localHead.Position
    local targetPos = target.Position
    
    if not ConfigTable.Ragebot.Wallbang then
        cachedBestPositions = {shootPos = startPos, hitPos = targetPos, target = target}
        return startPos, targetPos, false
    end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local function findSmartBounce()
        local directions = {
            Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0),
            Vector3.new(0, 1, 0), Vector3.new(0, -1, 0),
            Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
            Vector3.new(1, 1, 0), Vector3.new(-1, 1, 0)
        }
        
        for _, dir in ipairs(directions) do
            local bouncePos = startPos + dir * (ConfigTable.Ragebot.ShootRange * 0.8)
            
            if checkClearPath(startPos, bouncePos) then
                local rayToTarget = Workspace:Raycast(bouncePos, (targetPos - bouncePos).Unit * (targetPos - bouncePos).Magnitude, raycastParams)
                if not rayToTarget then
                    return bouncePos, targetPos
                end
            end
        end
        
        return nil, nil
    end
    
    local function findAngleOffset()
        local minAngle = -30
        local maxAngle = 30
        local steps = 120
        
        for i = 1, steps do
            local angle = minAngle + (maxAngle - minAngle) * (i / steps)
            local radians = math.rad(angle)
            
            local direction = (targetPos - startPos).Unit
            local right = direction:Cross(Vector3.new(0, 1, 0)).Unit
            local up = direction:Cross(right).Unit
            
            local offsetDir = right * math.cos(radians) + up * math.sin(radians)
            local offsetDistance = ConfigTable.Ragebot.ShootRange * 0.6
            
            local shootPos = startPos + offsetDir * offsetDistance
            
            if checkClearPath(startPos, shootPos) then
                local rayToTarget = Workspace:Raycast(shootPos, (targetPos - shootPos).Unit * (targetPos - shootPos).Magnitude, raycastParams)
                if not rayToTarget then
                    return shootPos, targetPos
                end
            end
        end
        
        return nil, nil
    end
    
    local function findQuickPath()
        for i = 1, 120 do
            local shootX = startPos.X + math.random(-ConfigTable.Ragebot.ShootRange, ConfigTable.Ragebot.ShootRange)
            local shootY = startPos.Y + math.random(-ConfigTable.Ragebot.ShootRange, ConfigTable.Ragebot.ShootRange)
            local shootZ = startPos.Z + math.random(-ConfigTable.Ragebot.ShootRange, ConfigTable.Ragebot.ShootRange)
            
            local shootPos = Vector3.new(shootX, shootY, shootZ)
            
            local hitX = targetPos.X + math.random(-ConfigTable.Ragebot.HitRange, ConfigTable.Ragebot.HitRange)
            local hitY = targetPos.Y + math.random(-ConfigTable.Ragebot.HitRange, ConfigTable.Ragebot.HitRange)
            local hitZ = targetPos.Z + math.random(-ConfigTable.Ragebot.HitRange, ConfigTable.Ragebot.HitRange)
            
            local hitPos = Vector3.new(hitX, hitY, hitZ)
            
            if checkClearPath(startPos, shootPos) and checkClearPath(shootPos, hitPos) then
                local finalRay = Workspace:Raycast(shootPos, (hitPos - shootPos).Unit * (hitPos - shootPos).Magnitude, raycastParams)
                if not finalRay then
                    return shootPos, hitPos
                end
            end
        end
        
        return nil, nil
    end
    
    local shootPos, hitPos
    
    if math.random(1, 100) <= 40 then
        shootPos, hitPos = findSmartBounce()
    end
    
    if not shootPos then
        shootPos, hitPos = findAngleOffset()
    end
    
    if not shootPos then
        shootPos, hitPos = findQuickPath()
    end
    
    return shootPos, hitPos, false
end
local function createHitNotification(toolName, offsetValue, playerName, usedCache)
    if not ConfigTable.Ragebot.HitNotify then return end
    
    local targetPlayer = game:GetService("Players"):FindFirstChild(playerName)
    local health = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and math.floor(targetPlayer.Character.Humanoid.Health) or 0

    local ScreenGui = game:GetService("CoreGui"):FindFirstChild("HitNotifications") or Instance.new("ScreenGui")
    ScreenGui.Name = "HitNotifications"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local scrollFrame = ScreenGui:FindFirstChild("NotificationScroll") or Instance.new("ScrollingFrame")
    scrollFrame.Name = "NotificationScroll"
    scrollFrame.Parent = ScreenGui
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Size = UDim2.new(0, 600, 0, 400)
    scrollFrame.Position = UDim2.new(0, 30, 0, 10)
    scrollFrame.ScrollingEnabled = false
    scrollFrame.ScrollBarThickness = 0
    scrollFrame.ClipsDescendants = false

    local THEME_COLOR = Color3.fromRGB(30, 30, 30)
    local THEME_TRANSPARENCY = 0.5
    local GLOW_WIDTH = 20
    local HIT_COLOR = ConfigTable.Ragebot.HitColor

    local box = Instance.new("Frame")
    box.Parent = scrollFrame
    box.BackgroundColor3 = THEME_COLOR
    box.BackgroundTransparency = THEME_TRANSPARENCY
    box.BorderSizePixel = 0
    
    local function createGlow(side)
        local glow = Instance.new("Frame")
        glow.Size = UDim2.new(0, GLOW_WIDTH, 1, 0)
        glow.Position = (side == "Left") and UDim2.new(0, -GLOW_WIDTH, 0, 0) or UDim2.new(1, 0, 0, 0)
        glow.BackgroundColor3 = THEME_COLOR
        glow.BackgroundTransparency = THEME_TRANSPARENCY
        glow.BorderSizePixel = 0
        glow.Parent = box
        local grad = Instance.new("UIGradient")
        grad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, (side == "Left" and 1 or 0)), NumberSequenceKeypoint.new(1, (side == "Left" and 0 or 1))})
        grad.Parent = glow
    end
    createGlow("Left")
    createGlow("Right")

    local parts = {
        {"hit ", Color3.fromRGB(255, 255, 255)},
        {playerName .. " ", HIT_COLOR},
        {"on head ", Color3.fromRGB(255, 255, 255)},
        {"Health at ", Color3.fromRGB(200, 200, 200)},
        {tostring(health) .. " ", Color3.fromRGB(0, 255, 120)},
        {"in ", Color3.fromRGB(200, 200, 200)},
        {string.format("%.2f", offsetValue) .. " ", HIT_COLOR}
    }
    
    if usedCache then
        table.insert(parts, {" via cache", Color3.fromRGB(150, 150, 150)})
    end

    local offsetX = 8
    local totalW, maxH = 0, 0
    for _, seg in ipairs(parts) do
        local label = Instance.new("TextLabel")
        label.Parent = box
        label.BackgroundTransparency = 1
        label.BorderSizePixel = 0
        label.TextColor3 = seg[2]
        label.FontFace = l_26
        label.TextSize = 10
        label.Text = seg[1]
        label.AutomaticSize = Enum.AutomaticSize.XY
        
        label.Position = UDim2.new(0, offsetX, 0, 0)
        local xSize = label.TextBounds.X
        offsetX = offsetX + xSize
        totalW = offsetX
        maxH = math.max(maxH, label.TextBounds.Y)
    end

    box.Size = UDim2.new(0, totalW + 8, 0, maxH + 4)
    table.insert(hitNotifications, {box = box, createTime = tick()})

    local function updateScrollFrame()
        local currentY = 0
        for i, notif in ipairs(hitNotifications) do
            if notif.box and notif.box.Parent then
                notif.box.Position = UDim2.new(0, GLOW_WIDTH, 0, currentY)
                currentY = currentY + notif.box.AbsoluteSize.Y + 4
            end
        end
    end

    updateScrollFrame()

    task.delay(ConfigTable.Ragebot.HitNotifyDuration, function()
        for i, notif in ipairs(hitNotifications) do 
            if notif.box == box then 
                table.remove(hitNotifications, i) 
                box:Destroy() 
                break 
            end 
        end
        updateScrollFrame()
    end)
end

local function playHitSound()
    if not ConfigTable.Ragebot.HitSound then return end
    local soundIds = {
        ["Bameware"] = "rbxassetid://3124331820",
        ["Bell"] = "rbxassetid://6534947240",
        ["Bubble"] = "rbxassetid://6534947588",
        ["Pick"] = "rbxassetid://1347140027",
        ["Pop"] = "rbxassetid://198598793",
        ["Rust"] = "rbxassetid://1255040462",
        ["Sans"] = "rbxassetid://3188795283",
        ["Fart"] = "rbxassetid://130833677",
        ["Big"] = "rbxassetid://5332005053",
        ["Vine"] = "rbxassetid://5332680810",
        ["Bruh"] = "rbxassetid://4578740568",
        ["Skeet"] = "rbxassetid://5633695679",
        ["Neverlose"] = "rbxassetid://6534948092",
        ["Fatality"] = "rbxassetid://6534947869",
        ["Bonk"] = "rbxassetid://5766898159",
        ["Minecraft"] = "rbxassetid://4018616850",
        ["xp"] = "rbxassetid://17148249625"
    }
    local soundId = soundIds[ConfigTable.Ragebot.SelectedHitSound] or soundIds["Skeet"]
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.75
    sound.Parent = Workspace
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 0.75)
end


local tracerTextures = {
    ["Default"] = "rbxassetid://7136858729",
    ["Alternative"] = "rbxassetid://6060542021",
    ["Laser"] = "rbxassetid://446111271",
    ["Rainbow"] = "rbxassetid://875688442"
}

local function createTracer(startPos, endPos)
    if not ConfigTable.Ragebot.Tracers then return end
    
    local tracerModel = Instance.new("Model")
    tracerModel.Name = "TracerBeam"
    
    local beam = Instance.new("Beam")
    beam.Color = ColorSequence.new(ConfigTable.Ragebot.TracerColor)
    beam.Width0 = ConfigTable.Ragebot.TracerWidth
    beam.Width1 = ConfigTable.Ragebot.TracerWidth
    beam.Texture = tracerTextures[ConfigTable.Ragebot.TracerTexture] or "rbxassetid://7136858729"
    beam.TextureSpeed = 1
    beam.Brightness = 2
    beam.LightEmission = 2
    beam.FaceCamera = true
    
    local a0 = Instance.new("Attachment")
    local a1 = Instance.new("Attachment")
    a0.WorldPosition = startPos
    a1.WorldPosition = endPos
    
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.Parent = tracerModel
    a0.Parent = tracerModel
    a1.Parent = tracerModel
    tracerModel.Parent = Workspace
    
    local tweenInfo = TweenInfo.new(ConfigTable.Ragebot.TracerLifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(beam, tweenInfo, {Brightness = 0})
    tween:Play()
    tween.Completed:Connect(function()
        if tracerModel then 
            tracerModel:Destroy() 
        end 
    end)
end

local function RandomString(length)
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    for i = 1, length do 
        result = result .. charset:sub(math.random(1, #charset), math.random(1, #charset)) 
    end
    return result
end

local function shootAtTarget(targetHead)
    if not targetHead then return false end
    local localHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if not localHead then return false end
    
    local tool = getCurrentTool()
    if not tool then return false end
    
    local values = tool:FindFirstChild("Values")
    local hitMarker = tool:FindFirstChild("Hitmarker")
    if not values or not hitMarker then return false end
    
    local ammo = values:FindFirstChild("SERVER_Ammo")
    local storedAmmo = values:FindFirstChild("SERVER_StoredAmmo")
    if not ammo or not storedAmmo then return false end
    if ammo.Value <= 0 then 
        autoReload()
        return false 
    end
    
    local bestShootPos, bestHitPos = wallbang()
    if not bestShootPos or not bestHitPos then return false end
    
    local hitPosition = bestHitPos
    if ConfigTable.Ragebot.Prediction then 
        local velocity = targetHead.Velocity or Vector3.zero 
        hitPosition = hitPosition + velocity * ConfigTable.Ragebot.PredictionAmount 
    end
    
    local hitDirection = (hitPosition - bestShootPos).Unit
    local randomKey = RandomString(30) .. "0"
    
    local events = ReplicatedStorage:WaitForChild("Events")
    local GNX_S = events:WaitForChild("GNX_S")
    local ZFKLF__H = events:WaitForChild("ZFKLF__H")
    
    local args1 = {tick(), randomKey, tool, "FDS9I83", bestShootPos, {hitDirection}, false}
    local args2 = {"🧈", tool, randomKey, 1, targetHead, hitPosition, hitDirection}
    
    local targetPlayer = Players:GetPlayerFromCharacter(targetHead.Parent)
    if targetPlayer then 
        createHitNotification(tool.Name, (bestShootPos - localHead.Position).Magnitude, targetPlayer.Name) 
        playHitSound() 
    end
    
    GNX_S:FireServer(unpack(args1))
    ZFKLF__H:FireServer(unpack(args2))
    hitMarker:Fire(targetHead)
    storedAmmo.Value = storedAmmo.Value
    
    createTracer(bestShootPos, hitPosition)
    return true
end

coroutine.wrap(function()
    while wait() do
        if not (ConfigTable.Ragebot.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") and getClosestTarget()) then continue end
        
        local target = getClosestTarget()
        local currentTool
        
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then currentTool = tool break end
        end
        
        local isSpecial = currentTool and (currentTool.Name == "TEC-9" or currentTool.Name == "Beretta")
        local fireRate
        
        if isSpecial then
            fireRate = ConfigTable.Ragebot.RapidFire and 9e14 or ConfigTable.Ragebot.FireRate
        else
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" and rawget(v, "FireRate") and rawget(v, "Damage") and rawget(v, "MagSize") then
                    fireRate = rawget(v, "FireRate")
                    break
                end
            end
            fireRate = fireRate or 2.5
        end
        
        local currentTime = tick()
        if not isSpecial or not ConfigTable.Ragebot.RapidFire then
            if currentTime - lastShotTime >= 1 / fireRate then
                shootAtTarget(target)
                lastShotTime = currentTime
            end
        else
            shootAtTarget(target)
        end
    end
end)()
local RagebotTab = UI:CreateTab("Ragebot")

local MainSection = RagebotTab:CreateSection("Main", "Left")
MainSection:CreateToggle("Enabled", false, function(v) 
    ConfigTable.Ragebot.Enabled = v
end)
MainSection:CreateToggle("Rapid Fire", false, function(v) 
    ConfigTable.Ragebot.RapidFire = v
end)
MainSection:CreateToggle("Auto Reload", true, function(v) 
    ConfigTable.Ragebot.AutoReload = v
end)
MainSection:CreateSlider("Fire Rate", 1, 1000, 30, "", function(v) 
    ConfigTable.Ragebot.FireRate = v
end)
MainSection:CreateKeybind("Activation Key", Enum.KeyCode.LeftAlt, function(key) end)

local AimSection = RagebotTab:CreateSection("Aim Settings", "Right")
AimSection:CreateToggle("Prediction", true, function(v) 
    ConfigTable.Ragebot.Prediction = v
end)
AimSection:CreateSlider("Prediction Amount", 0.05, 0.3, 0.12, "", function(v) 
    ConfigTable.Ragebot.PredictionAmount = v
end)
AimSection:CreateToggle("Wallbang", true, function(v) 
    ConfigTable.Ragebot.Wallbang = v
end)
AimSection:CreateSlider("Shoot Range", 1, 30, 15, "", function(v) 
    ConfigTable.Ragebot.ShootRange = v
end)
AimSection:CreateSlider("Hit Range", 1, 30, 15, "", function(v) 
    ConfigTable.Ragebot.HitRange = v
end)
AimSection:CreateSlider("Max Targets", 0, 10, 0, "", function(v) 
    ConfigTable.Ragebot.MaxTarget = v
end)

local TargetSection = RagebotTab:CreateSection("Targeting", "Left")
TargetSection:CreateToggle("Team Check", false, function(v) 
    ConfigTable.Ragebot.TeamCheck = v
end)
TargetSection:CreateToggle("Visibility Check", true, function(v) 
    ConfigTable.Ragebot.VisibilityCheck = v
end)
TargetSection:CreateToggle("Friend Check", false, function(v) 
    ConfigTable.Ragebot.FriendCheck = v
end)
TargetSection:CreateToggle("Low Health Check", false, function(v) 
    ConfigTable.Ragebot.LowHealthCheck = v
end)
TargetSection:CreateToggle("Use Target List", true, function(v) 
    ConfigTable.Ragebot.UseTargetList = v
end)
TargetSection:CreateToggle("Use Whitelist", true, function(v) 
    ConfigTable.Ragebot.UseWhitelist = v
end)
local ManagementSection = RagebotTab:CreateSection("Management", "Left")
local currentSelectedPlayer = nil
local onlineOptions = {}
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(onlineOptions, player.Name)
    end
end
local onlineListBox = ManagementSection:CreateListbox("Online Players", onlineOptions, false, function(selected) 
    if typeof(selected) == "table" then
        currentSelectedPlayer = selected[1]
    else
        currentSelectedPlayer = selected
    end
    print("Selected player:", tostring(currentSelectedPlayer))
end)
ManagementSection:CreateButton("Add to Target List", function()
    local name = tostring(currentSelectedPlayer)
    if name and name ~= "nil" then
        for i, v in ipairs(Whitelist) do if v == name then table.remove(Whitelist, i) break end end
        local exists = false
        for _, v in ipairs(TargetList) do if v == name then exists = true break end end
        if not exists then table.insert(TargetList, name) end
    end
end)
ManagementSection:CreateButton("Add to Whitelist", function()
    local name = tostring(currentSelectedPlayer)
    if name and name ~= "nil" then
        for i, v in ipairs(TargetList) do if v == name then table.remove(TargetList, i) break end end
        local exists = false
        for _, v in ipairs(Whitelist) do if v == name then exists = true break end end
        if not exists then table.insert(Whitelist, name) end
    end
end)
ManagementSection:CreateButton("Clear Selected Player", function()
    local name = tostring(currentSelectedPlayer)
    if name and name ~= "nil" then
        for i, v in ipairs(TargetList) do if v == name then table.remove(TargetList, i) break end end
        for i, v in ipairs(Whitelist) do if v == name then table.remove(Whitelist, i) break end end
    end
end)
ManagementSection:CreateButton("Clear All Lists", function()
    table.clear(TargetList)
    table.clear(Whitelist)
end)
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        onlineListBox:Add(player.Name)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    if player ~= LocalPlayer then
        onlineListBox:Remove(player.Name)
        local name = player.Name
        for i, v in ipairs(TargetList) do if v == name then table.remove(TargetList, i) break end end
        for i, v in ipairs(Whitelist) do if v == name then table.remove(Whitelist, i) break end end
    end
end)
local VisualSection = RagebotTab:CreateSection("Visuals", "Right")
VisualSection:CreateToggle("Tracers", true, function(v) 
    ConfigTable.Ragebot.Tracers = v
end)
VisualSection:CreateColorpicker("Tracer Color", Color3.fromRGB(255, 0, 0), function(c) 
    ConfigTable.Ragebot.TracerColor = c
end)
VisualSection:CreateSlider("Tracer Width", 0.1, 5, 1, "", function(v) 
    ConfigTable.Ragebot.TracerWidth = v
end)
VisualSection:CreateSlider("Tracer Lifetime", 0.5, 10, 3, "s", function(v) 
    ConfigTable.Ragebot.TracerLifetime = v
end)
local tracerTextureList = {"Default", "Alternative", "Laser", "Rainbow"}
VisualSection:CreateListbox("Tracer Texture", tracerTextureList, false, function(v) 
    ConfigTable.Ragebot.TracerTexture = v
end)
VisualSection:CreateToggle("Hit Notify", true, function(v) 
    ConfigTable.Ragebot.HitNotify = v
end)
VisualSection:CreateColorpicker("Hit Color", Color3.fromRGB(255, 182, 193), function(c) 
    ConfigTable.Ragebot.HitColor = c
end)
VisualSection:CreateSlider("Notify Duration", 1, 10, 5, "s", function(v) 
    ConfigTable.Ragebot.HitNotifyDuration = v
end)
VisualSection:CreateToggle("Hit Sound", true, function(v) 
    ConfigTable.Ragebot.HitSound = v
end)

local SoundList = {"Skeet", "Neverlose", "Fatality", "Bameware", "Bell", "Bubble", "Pop", "Rust", "Sans", "Minecraft", "xp"}
VisualSection:CreateListbox("Hit Sound", SoundList, false, function(v) 
    ConfigTable.Ragebot.SelectedHitSound = v
end)

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local forceTimeEnabled = false
local forceTimeValue = 12
local forceTimeConnection = nil

local speedEnabled = false
local speedValue = 50
local speedConnection = nil

local flyEnabled = false
local flySpeed = 50
local flyConnection = nil

local jumpPowerEnabled = false
local jumpPowerValue = 100
local jumpPowerConnection = nil

local loopFOVEnabled = false
local fovConnection = nil

local hideHeadEnabled = false
local handsUpEnabled = false

local infStaminaEnabled = false
local infStaminaHook = nil

local noFallEnabled = false
local noFallHook = nil

local lockpickEnabled = false
local lockpickAddedConnection = nil

local instantPromptEnabled = false
local instantPromptConnection = nil

local autoDoorEnabled = false
local doorConnection = nil

local safeESPEnabled = false
local safeColor = Color3.fromRGB(255,215,0)

local bulletTracersEnabled = false
local tracerColor = Color3.fromRGB(255,50,50)
local tracerWidth = 0.2
local tracerLifetime = 1

local SafeESP = {Enabled = false, Safes = {}, Visuals = {}}

local function enableForceTime()
    if forceTimeConnection then forceTimeConnection:Disconnect() forceTimeConnection = nil end
    forceTimeConnection = RunService.RenderStepped:Connect(function()
        if not forceTimeEnabled then return end
        Lighting.ClockTime = forceTimeValue
        Lighting.TimeOfDay = string.format("%02d:00:00", forceTimeValue)
    end)
end

local function disableForceTime()
    if forceTimeConnection then forceTimeConnection:Disconnect() forceTimeConnection = nil end
end

local function enableSpeed()
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    speedConnection = RunService.RenderStepped:Connect(function()
        if not speedEnabled then return end
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        humanoid.WalkSpeed = speedValue
    end)
end

local function disableSpeed()
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
    local character = LocalPlayer.Character
    if character then 
        local humanoid = character:FindFirstChild("Humanoid") 
        if humanoid then humanoid.WalkSpeed = 16 end 
    end
end

local function startFlying()
    local Char = LocalPlayer.Character
    if not Char then return end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    local Root = Char:FindFirstChild("HumanoidRootPart")
    if not Hum or not Root then return end
    
    local RagdollEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("__RZDONL")
    
    for _,child in ipairs(Char:GetDescendants()) do 
        if child:IsA("Motor6D") then child.Enabled = false end 
    end
    
    Hum.PlatformStand = true
    Hum:ChangeState(Enum.HumanoidStateType.Freefall)
    
    local flyMotors = {}
    for _,part in ipairs(Char:GetDescendants()) do
        if part:IsA("BasePart") and part ~= Root then
            local motor = Instance.new("Motor6D")
            motor.Name = "FlyMotor"
            motor.Part0 = Root
            motor.Part1 = part
            motor.C1 = CFrame.new()
            motor.C0 = Root.CFrame:ToObjectSpace(part.CFrame)
            motor.Parent = part
            table.insert(flyMotors, motor)
        end
    end
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled then
            if flyConnection then flyConnection:Disconnect() flyConnection = nil end
            Hum.PlatformStand = false
            Root.Velocity = Vector3.new(0,0,0)
            Hum:ChangeState(Enum.HumanoidStateType.Running)
            --RagdollEvent:FireServer("__---r",Vector3.zero,CFrame.new(-4574,3,-443,0,0,1,0,1,0,-1,0,0),true)
            for _,motor in ipairs(flyMotors) do motor:Destroy() end
            for _,child in ipairs(Char:GetDescendants()) do 
                if child:IsA("Motor6D") and child.Name ~= "FlyMotor" then child.Enabled = true end 
            end
            return
        end
        
        local Cam = Workspace.CurrentCamera
        if not Cam then return end
        
        local cameraLook = Cam.CFrame.LookVector
        local IsMoving = Hum.MoveDirection.Magnitude > 0
        local targetLook = Vector3.new(cameraLook.X, cameraLook.Y, cameraLook.Z)
        
        if targetLook.Magnitude > 0 then 
            targetLook = targetLook.Unit 
            Root.CFrame = CFrame.new(Root.Position, Root.Position + targetLook) 
        end
        
        if IsMoving then
            local moveVector = Vector3.new(cameraLook.X, cameraLook.Y, cameraLook.Z).Unit
            Root.Velocity = moveVector * flySpeed
            RagdollEvent:FireServer("__---r",Vector3.zero,CFrame.new(-4574,3,-443,0,0,1,0,1,0,-1,0,0),true)
        else 
            Root.Velocity = Vector3.new(0,0,0) 
        end
    end)
end

local function disableFlying()
    flyEnabled = false
    if flyConnection then 
        flyConnection:Disconnect() 
        flyConnection = nil 
    end
    
    local Char = LocalPlayer.Character
    if not Char then return end
    
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    local Root = Char:FindFirstChild("HumanoidRootPart")
    local RagdollEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("__RZDONL")
    
    if Hum then
        Hum.PlatformStand = false
        Hum:ChangeState(Enum.HumanoidStateType.Running)
    end
    
    if Root then
        Root.Velocity = Vector3.new(0,0,0)
    end
    
    for _, part in ipairs(Char:GetDescendants()) do
        local motor = part:FindFirstChild("FlyMotor")
        if motor then
            motor:Destroy()
        end
    end
    
    for _, child in ipairs(Char:GetDescendants()) do 
        if child:IsA("Motor6D") and child.Name ~= "FlyMotor" then 
            child.Enabled = true 
        end 
    end
end

local function enableJumpPower()
    if jumpPowerConnection then jumpPowerConnection:Disconnect() jumpPowerConnection = nil end
    jumpPowerConnection = RunService.Heartbeat:Connect(function()
        if not jumpPowerEnabled then return end
        if not LocalPlayer.Character then return end
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if humanoid:GetState() == Enum.HumanoidStateType.Jumping then 
            hrp.Velocity = Vector3.new(hrp.Velocity.X, jumpPowerValue, hrp.Velocity.Z) 
        end
    end)
end

local function disableJumpPower()
    if jumpPowerConnection then jumpPowerConnection:Disconnect() jumpPowerConnection = nil end
end

local function enableLoopFOV()
    if fovConnection then fovConnection:Disconnect() fovConnection = nil end
    fovConnection = RunService.RenderStepped:Connect(function()
        if not loopFOVEnabled then return end
        Workspace.CurrentCamera.FieldOfView = 120
    end)
end

local function disableLoopFOV()
    if fovConnection then fovConnection:Disconnect() fovConnection = nil end
end

local function enableInfStamina()
    if infStaminaHook then return end
    local module
    for i,v in pairs(game:GetService("StarterPlayer").StarterPlayerScripts:GetDescendants()) do 
        if v:IsA("ModuleScript") and v.Name == "XIIX" then 
            module = v 
            break 
        end 
    end
    if module then
        module = require(module)
        local ac = module["XIIX"]
        local glob = getfenv(ac)["_G"]
        local stamina = getupvalues((getupvalues(glob["S_Check"]))[2])[1]
        if stamina ~= nil then 
            infStaminaHook = hookfunction(stamina,function() return 100,100 end) 
        end
    end
end

local function disableInfStamina()
    if infStaminaHook then hookfunction(stamina,infStaminaHook) infStaminaHook = nil end
end

local function enableNoFallDmg()
    if noFallHook then return end
    noFallHook = hookmetamethod(game,"__namecall",function(self,...)
        local args = {...}
        if getnamecallmethod() == "FireServer" and not checkcaller() and args[1] == "FlllD" and args[4] == false then 
            args[2] = 0 
            args[3] = 0 
        end
        return noFallHook(self,unpack(args))
    end)
end

local function disableNoFallDmg()
    if noFallHook then hookmetamethod(game,"__namecall",noFallHook) noFallHook = nil end
end

local function enableLockpick()
    lockpickEnabled = true
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not PlayerGui then return end
    local function lockpick(gui)
        for _,a in pairs(gui:GetDescendants()) do
            if a:IsA("ImageLabel") and a.Name == "Bar" and a.Parent.Name ~= "Attempts" then
                local oldsize = a.Size
                RunService.RenderStepped:Connect(function()
                    if lockpickEnabled then a.Size = UDim2.new(0,280,0,280) else a.Size = oldsize end
                end)
            end
        end
    end
    if lockpickAddedConnection then lockpickAddedConnection:Disconnect() end
    lockpickAddedConnection = PlayerGui.ChildAdded:Connect(function(child) 
        if child:IsA("ScreenGui") and child.Name == "LockpickGUI" then lockpick(child) end 
    end)
    for _,child in pairs(PlayerGui:GetChildren()) do 
        if child:IsA("ScreenGui") and child.Name == "LockpickGUI" then lockpick(child) end 
    end
end

local function disableLockpick()
    lockpickEnabled = false
    if lockpickAddedConnection then 
        lockpickAddedConnection:Disconnect() 
        lockpickAddedConnection = nil 
    end
end

local function enableInstantPrompt()
    instantPromptEnabled = true
    for _,obj in pairs(game:GetDescendants()) do 
        if obj:IsA("ProximityPrompt") then obj.HoldDuration = 0 end 
    end
    if instantPromptConnection then instantPromptConnection:Disconnect() end
    instantPromptConnection = game.DescendantAdded:Connect(function(obj) 
        if obj:IsA("ProximityPrompt") then task.wait() obj.HoldDuration = 0 end 
    end)
end

local function disableInstantPrompt()
    instantPromptEnabled = false
    if instantPromptConnection then 
        instantPromptConnection:Disconnect() 
        instantPromptConnection = nil 
    end
    for _,obj in pairs(game:GetDescendants()) do 
        if obj:IsA("ProximityPrompt") then obj.HoldDuration = 1 end 
    end
end

local function enableAutoDoor()
    autoDoorEnabled = true
    if doorConnection then doorConnection:Disconnect() end
    doorConnection = RunService.Heartbeat:Connect(function()
        if not autoDoorEnabled then return end
        if not LocalPlayer.Character then return end
        local charRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not charRoot then return end
        local Map = Workspace:FindFirstChild("Map")
        if not Map then return end
        local Doors = Map:FindFirstChild("Doors")
        if not Doors then return end
        local closestDoor = nil
        local closestDistance = 15
        for _,door in pairs(Doors:GetChildren()) do
            local knob = door:FindFirstChild("Knob1") or door:FindFirstChild("Knob2")
            if knob then
                local distance = (knob.Position - charRoot.Position).Magnitude
                if distance < closestDistance then 
                    closestDistance = distance 
                    closestDoor = door 
                end
            end
        end
        if closestDoor then
            local knob = closestDoor:FindFirstChild("Knob1") or closestDoor:FindFirstChild("Knob2")
            local events = closestDoor:FindFirstChild("Events")
            local toggleEvent = events and events:FindFirstChild("Toggle")
            if knob and toggleEvent then 
                local args = {"Open",knob} 
                toggleEvent:FireServer(unpack(args)) 
            end
        end
    end)
end

local function disableAutoDoor()
    autoDoorEnabled = false
    if doorConnection then doorConnection:Disconnect() doorConnection = nil end
end

local QuickUIFrame = Instance.new("Frame")
QuickUIFrame.Name = "QuickUIFrame"
QuickUIFrame.Size = UDim2.new(0, 80, 0, 30)
QuickUIFrame.Position = UDim2.new(0, 10, 0, 50)
QuickUIFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
QuickUIFrame.BackgroundTransparency = 0.5
QuickUIFrame.BorderSizePixel = 0

local QuickUIText = Instance.new("TextButton")
QuickUIText.Name = "QuickUIText"
QuickUIText.Size = UDim2.new(1, 0, 1, 0)
QuickUIText.BackgroundTransparency = 1
QuickUIText.Text = "FLY OFF"
QuickUIText.TextColor3 = Color3.fromRGB(255, 50, 50)
QuickUIText.Font = Enum.Font.GothamBold
QuickUIText.TextSize = 12
QuickUIText.Parent = QuickUIFrame

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuickUIScreen"
ScreenGui.Parent = game:GetService("CoreGui")
QuickUIFrame.Parent = ScreenGui

QuickUIText.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    if flyEnabled then 
        QuickUIText.Text = "FLY ON" 
        QuickUIText.TextColor3 = Color3.fromRGB(50, 255, 50) 
        startFlying()
    else 
        QuickUIText.Text = "FLY OFF" 
        QuickUIText.TextColor3 = Color3.fromRGB(255, 50, 50) 
        disableFlying() 
    end
end)

local MiscTab = UI:CreateTab("Misc")

local MovementSection = MiscTab:CreateSection("Movement", "Left")
MovementSection:CreateToggle("Speed", false, function(v)
    speedEnabled = v
    if v then enableSpeed() else disableSpeed() end
end)
MovementSection:CreateSlider("Speed Value", 16, 200, 50, "", function(v)
    speedValue = v
end)
MovementSection:CreateKeybind("Speed Key", Enum.KeyCode.X, function() end)

MovementSection:CreateToggle("Fly", false, function(v)
    flyEnabled = v
    if v then startFlying() else disableFlying() end
end)
MovementSection:CreateSlider("Fly Speed", 10, 200, 50, "", function(v)
    flySpeed = v
end)
MovementSection:CreateKeybind("Fly Key", Enum.KeyCode.F, function() end)

MovementSection:CreateToggle("Jump Power", false, function(v)
    jumpPowerEnabled = v
    if v then enableJumpPower() else disableJumpPower() end
end)
MovementSection:CreateSlider("Jump Value", 50, 300, 100, "", function(v)
    jumpPowerValue = v
end)

local WorldSection = MiscTab:CreateSection("World", "Right")
WorldSection:CreateToggle("Force Time", false, function(v)
    forceTimeEnabled = v
    if v then enableForceTime() else disableForceTime() end
end)
WorldSection:CreateSlider("Time", 0, 24, 12, "hr", function(v)
    forceTimeValue = v
    if forceTimeEnabled then
        Lighting.ClockTime = forceTimeValue
        Lighting.TimeOfDay = string.format("%02d:00:00", forceTimeValue)
    end
end)

local ToolsSection = MiscTab:CreateSection("Tools", "Left")
ToolsSection:CreateToggle("Loop FOV", false, function(v)
    loopFOVEnabled = v
    if v then enableLoopFOV() else disableLoopFOV() end
end)

ToolsSection:CreateToggle("Inf Stamina", false, function(v)
    infStaminaEnabled = v
    if v then enableInfStamina() else disableInfStamina() end
end)

ToolsSection:CreateToggle("No Fall Damage", false, function(v)
    noFallEnabled = v
    if v then enableNoFallDmg() else disableNoFallDmg() end
end)

ToolsSection:CreateToggle("No Fail Lockpick", false, function(v)
    lockpickEnabled = v
    if v then enableLockpick() else disableLockpick() end
end)

ToolsSection:CreateToggle("Instant Prompt", false, function(v)
    instantPromptEnabled = v
    if v then enableInstantPrompt() else disableInstantPrompt() end
end)

ToolsSection:CreateToggle("Auto Door", false, function(v)
    autoDoorEnabled = v
    if v then enableAutoDoor() else disableAutoDoor() end
end)
local hideHeadEnabled = false
local originalHook = nil
local renderConnection = nil
local HandsUp = {
    Enabled = false,
    Tool = nil,
    OriginalMotor6Ds = {},
    RenderConnection = nil,
    FirstMotorData = {}
}

local function lockNeckMotorForHideHead()
    local character = LocalPlayer.Character
    if not character then return end
    
    local torso = character:FindFirstChild("Torso")
    if not torso then return end
    
    local neck = torso:FindFirstChild("Neck")
    if not neck or not neck:IsA("Motor6D") then return end
    
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
    
    renderConnection = RunService.RenderStepped:Connect(function()
        if not hideHeadEnabled then
            if renderConnection then
                renderConnection:Disconnect()
                renderConnection = nil
            end
            return
        end
        
        neck.C0 = CFrame.new(0, 0, 0.75) * CFrame.Angles(math.rad(90), 0, 0)
        neck.C1 = CFrame.new(0, 0.25, 0) * CFrame.Angles(0, 0, 0)
    end)
end

local function restoreNeckMotorsForHideHead()
    if renderConnection then
        renderConnection:Disconnect()
        renderConnection = nil
    end
end

local function updateHideHeadHook()
    if hideHeadEnabled then
        if not originalHook then
            originalHook = hookmetamethod(game, "__namecall", function(self, ...)
                local methodName = getnamecallmethod()
                if tostring(methodName) == "FireServer" then
                    if self.Name == "MOVZREP" then 
                        if hideHeadEnabled then
                            local fixedArguments = {
                                {
                                    {
                                        Vector3.new(-5721.2001953125,-5,971.5162353515625),
                                        Vector3.new(-4181.38818359375,-6,11.123311996459961),
                                        Vector3.new(0.006237113382667303,-6,-0.18136750161647797),
                                        true,
                                        true,
                                        true,
                                        false
                                    },
                                    false,
                                    false,
                                    15.8
                                }
                            }
                            return originalHook(self, table.unpack(fixedArguments))
                        end
                    end
                end
                return originalHook(self, ...)
            end)
        end
        lockNeckMotorForHideHead()
    else
        if originalHook then
            hookmetamethod(game, "__namecall", originalHook)
            originalHook = nil
        end
        restoreNeckMotorsForHideHead()
    end
end

ToolsSection:CreateToggle("Hide Head", false, function(v)
    hideHeadEnabled = v
    updateHideHeadHook()
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local State = {
    Enabled = false,
    OriginalNamecall = nil,
    Connection = nil,
    CurrentTool = nil,
    CreatedMotors = {},
    OrigRightC0 = nil,
    OrigLeftC0 = nil,
    MoveForward = 1.25,
    RaiseAngle = math.rad(90)
}

local function getShoulders(character)
    local root = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not root then return nil, nil end
    local rs = root:FindFirstChild("Right Shoulder") or character:FindFirstChild("RightUpperArm", true):FindFirstChild("RightShoulder")
    local ls = root:FindFirstChild("Left Shoulder") or character:FindFirstChild("LeftUpperArm", true):FindFirstChild("LeftShoulder")
    return rs, ls
end

local function cleanup()
    for _, m in pairs(State.CreatedMotors) do if m then m:Destroy() end end
    State.CreatedMotors = {}
    local char = LocalPlayer.Character
    if char then
        local rs, ls = getShoulders(char)
        if rs and State.OrigRightC0 then rs.C0 = State.OrigRightC0 end
        if ls and State.OrigLeftC0 then ls.C0 = State.OrigLeftC0 end
    end
    State.CurrentTool = nil
end

local function updateHook()
    if State.OriginalNamecall then
        hookmetamethod(game, "__namecall", State.OriginalNamecall)
        State.OriginalNamecall = nil
    end
    
    if State.Enabled and State.CurrentTool then
        State.OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if tostring(method) == "FireServer" and self.Name == "MOVZREP" then
                local yValue = hideHeadEnabled and -6 or 0.9833956360816956
                local args = {{
                    {
                        Vector3.new(-5721.2001953125, 9834.1708984375, 971.5162353515625),
                        Vector3.new(-4181.38818359375, 0.3198874592781067, 11.123311996459961),
                        Vector3.new(0.006237113382667303, yValue, -0.18136750161647797),
                        true, true, true, false
                    },
                    false, false, 15.8
                }}
                return State.OriginalNamecall(self, table.unpack(args))
            end
            return State.OriginalNamecall(self, ...)
        end)
    end
end

local function onStepped()
    local character = LocalPlayer.Character
    if not character or not State.Enabled then return end
    
    local rs, ls = getShoulders(character)
    if not rs or not ls then return end
    if not State.OrigRightC0 then State.OrigRightC0 = rs.C0 end
    if not State.OrigLeftC0 then State.OrigLeftC0 = ls.C0 end

    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        rs.C0 = State.OrigRightC0 * CFrame.Angles(0, 0, State.RaiseAngle)
        ls.C0 = State.OrigLeftC0 * CFrame.Angles(0, 0, -State.RaiseAngle)

        if State.CurrentTool ~= tool then
            for _, m in pairs(State.CreatedMotors) do if m then m:Destroy() end end
            State.CreatedMotors = {}
            
            local t6d = tool:FindFirstChild("Tool6D_Torso", true)
            local m6d = tool:FindFirstChild("Mag6D_Torso", true)
            local wHandle = tool:FindFirstChild("WeaponHandle", true)
            local mHandle = tool:FindFirstChild("MagazineHandle", true)

            if t6d and wHandle then
                local nm = Instance.new("Motor6D")
                nm.Part0 = t6d.Part0
                nm.Part1 = wHandle
                nm.C0 = t6d.C0 * CFrame.new(0, 0, -State.MoveForward) * CFrame.Angles(State.RaiseAngle, 0, 0)
                nm.Parent = wHandle
                table.insert(State.CreatedMotors, nm)
            end
            if m6d and mHandle then
                local nm = Instance.new("Motor6D")
                nm.Part0 = m6d.Part0
                nm.Part1 = mHandle
                nm.C0 = m6d.C0 * CFrame.new(0, 0, -State.MoveForward) * CFrame.Angles(State.RaiseAngle, 0, 0)
                nm.Parent = mHandle
                table.insert(State.CreatedMotors, nm)
            end
            State.CurrentTool = tool
            updateHook()
        end
    else
        if State.CurrentTool then
            cleanup()
            updateHook()
        end
    end
end

ToolsSection:CreateToggle("Hands Up", false, function(v)
    State.Enabled = v
    if v then
        State.Connection = State.Connection or RunService.RenderStepped:Connect(onStepped)
    else
        if State.Connection then
            State.Connection:Disconnect()
            State.Connection = nil
        end
        cleanup()
        updateHook()
    end
end)
