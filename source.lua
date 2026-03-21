local SplixLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/eradicator2/ske.gg-criminality/refs/heads/main/splixui_source.lua'))()

getgenv().SkeetAccent = Color3.fromRGB(180, 120, 255)

local Window = SplixLib:New({
    name = 'Skeet.gg',
    size = Vector2.new(500, 425),
    accent = getgenv().SkeetAccent,
})

Window:Watermark({
    text = 'Skeet.gg',
})

local FeaturesPage = Window:Page({
    name = 'Features',
})
local SectRagebot = FeaturesPage:Section({
    name = 'Ragebot Settings',
    side = 'left',
})
local SectTarget = FeaturesPage:Section({
    name = 'Target Settings',
    side = 'right',
})
local SectWallbang = FeaturesPage:Section({
    name = 'Wallbang',
    side = 'left',
})
local SectSound = FeaturesPage:Section({
    name = 'Sound Settings',
    side = 'right',
})
local SectPlayer = FeaturesPage:Section({
    name = 'Player',
    side = 'left',
})
local SectESP = FeaturesPage:Section({
    name = 'ESP',
    side = 'left',
})
local SectTargetLists = FeaturesPage:Section({
    name = 'Target Lists',
    side = 'right',
})
local SectUI = FeaturesPage:Section({
    name = 'UI Settings',
    side = 'left',
})

local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local CollectionService = game:GetService('CollectionService')
local TweenService = game:GetService('TweenService')
local Debris = game:GetService('Debris')

getgenv().RageEnabled = false
getgenv().FireRate = 5
getgenv().Prediction = true
getgenv().PredictionAmount = 0.1
getgenv().TracerEnabled = false
getgenv().TracerColor = Color3.fromRGB(255, 0, 0)
getgenv().TracerWidth = 0.3
getgenv().TracerLifetime = 0.3
getgenv().VisibilityCheck = true
getgenv().RandomTracer = true
getgenv().RandomTracerOffset = 5
getgenv().TeamCheck = false
getgenv().FovEnabled = true
getgenv().FovRadius = 100
getgenv().NoFovLimit = false
getgenv().DownedCheck = false
getgenv().TargetLock = false
getgenv().LockedTarget = nil
getgenv().TargetList = {}
getgenv().Whitelist = {}
getgenv().PendingTargets = {}
getgenv().WallbangEnabled = false
getgenv().HitSoundType = 'Default'
getgenv().CustomHitSoundId = 'rbxassetid://6534948092'
getgenv().FlyEnabled = false
getgenv().FlySpeed = 50
getgenv().AutoReload = false
getgenv().NoScream = false

local isFlying = false
local lastFireTime = 0

local function getEquippedTool()
    if LocalPlayer.Character then
        for _, child in pairs(LocalPlayer.Character:GetChildren()) do
            if child:IsA('Tool') then
                return child
            end
        end
    end
    return nil
end

local function generateRandomString(length)
    local result = ''
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    for _ = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

local function getCameraPosition()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild('Head') then
        return Vector3.new(char.Head.Position.X, char.Head.Position.Y + 7, char.Head.Position.Z)
    end
    return CurrentCamera.CFrame.Position
end

local function enableWallbang()
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA('BasePart') then
            local isPlayer = false
            local model = part:FindFirstAncestorOfClass('Model')
            if model then
                isPlayer = Players:GetPlayerFromCharacter(model) and true or isPlayer
            end
            if not isPlayer then
                CollectionService:AddTag(part, 'RANGED_CASTER_IGNORE_LIST')
            end
        end
    end
end

local function playHitSound()
    if getgenv().HitSoundType ~= 'Weapon' then
        local sound = Instance.new('Sound')
        sound.SoundId = getgenv().HitSoundType == 'Custom' and getgenv().CustomHitSoundId or 'rbxassetid://6534948092'
        sound.Volume = 1
        sound.PlayOnRemove = true
        sound.Parent = CurrentCamera
        sound:Destroy()
    elseif LocalPlayer.Character then
        for _, child in ipairs(LocalPlayer.Character:GetChildren()) do
            if child:IsA('Tool') then
                for _, desc in ipairs(child:GetDescendants()) do
                    if desc:IsA('Sound') and desc.Name == 'FireSound1' then
                        local soundClone = desc:Clone()
                        soundClone.Parent = CurrentCamera
                        soundClone:Play()
                        Debris:AddItem(soundClone, soundClone.TimeLength)
                        return
                    end
                end
            end
        end
    end
end

local function isWhitelisted(player)
    for _, name in pairs(getgenv().Whitelist) do
        if player.Name == name then return true end
    end
    return false
end

local function isTargeted(player)
    if #getgenv().TargetList == 0 then return true end
    for _, name in pairs(getgenv().TargetList) do
        if player.Name == name then return true end
    end
    return false
end

local function checkVisibility(targetPart)
    if not getgenv().VisibilityCheck then return true end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character }

    local startPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Head') and LocalPlayer.Character.Head.Position or CurrentCamera.CFrame.Position
    local direction = targetPart.Position - startPos
    local raycastResult = workspace:Raycast(startPos, direction.Unit * direction.Magnitude, rayParams)

    if raycastResult then
        local inst = raycastResult.Instance
        if inst and inst.CanCollide then
            local model = inst:FindFirstAncestorOfClass('Model')
            return model and model:FindFirstChild('Humanoid') and true or false
        end
    end
    return true
end

local function getClosestTarget()
    if getgenv().TargetLock and getgenv().LockedTarget then
        local lockedChar = getgenv().LockedTarget.Character
        if lockedChar then
            local head = lockedChar:FindFirstChild('Head')
            local humanoid = lockedChar:FindFirstChild('Humanoid')
            if head and humanoid and humanoid.Health > 0 and (not getgenv().DownedCheck or humanoid.Health > 0) and checkVisibility(head) and not isWhitelisted(getgenv().LockedTarget) and isTargeted(getgenv().LockedTarget) then
                return head
            end
        else
            getgenv().PendingTargets[getgenv().LockedTarget.Name] = true
            getgenv().LockedTarget = nil
        end
    end

    for targetName, _ in pairs(getgenv().PendingTargets) do
        local plr = Players:FindFirstChild(targetName)
        if plr and plr.Character then
            getgenv().PendingTargets[targetName] = nil
            if getgenv().TargetLock then
                getgenv().LockedTarget = plr
                local head = plr.Character:FindFirstChild('Head')
                local humanoid = plr.Character:FindFirstChild('Humanoid')
                if head and humanoid and humanoid.Health > 0 and (not getgenv().DownedCheck or humanoid.Health > 0) and checkVisibility(head) and not isWhitelisted(plr) and isTargeted(plr) then
                    return head
                end
            end
        end
    end

    local shortestDistance = math.huge
    local closestHead = nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and not isWhitelisted(plr) and isTargeted(plr) then
            local humanoid = plr.Character:FindFirstChild('Humanoid')
            local head = plr.Character:FindFirstChild('Head')

            if humanoid and humanoid.Health > 0 and head and checkVisibility(head) and (not getgenv().TeamCheck or plr.Team ~= LocalPlayer.Team) then
                if getgenv().NoFovLimit or not getgenv().FovEnabled then
                    local dist = (head.Position - CurrentCamera.CFrame.Position).Magnitude
                    if dist < shortestDistance then
                        if getgenv().TargetLock then getgenv().LockedTarget = plr end
                        closestHead = head
                        shortestDistance = dist
                    end
                else
                    local pos, onScreen = CurrentCamera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local screenCenter = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
                        local distToCenter = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                        if distToCenter <= getgenv().FovRadius and distToCenter < shortestDistance then
                            if getgenv().TargetLock then getgenv().LockedTarget = plr end
                            closestHead = head
                            shortestDistance = distToCenter
                        end
                    end
                end
            end
        end
    end
    return closestHead
end

local function drawTracer(startPos, endPos)
    if getgenv().TracerEnabled then
        if getgenv().RandomTracer then
            local target = getClosestTarget()
            if target then
                local maxY = target.Position.Y + 10
                local randY = math.random(target.Position.Y, maxY)
                startPos = Vector3.new(startPos.X + math.random(-5, 5), randY, startPos.Z + math.random(-5, 5))
                endPos = Vector3.new(endPos.X + math.random(-3, 3), randY, endPos.Z + math.random(-3, 3))
            end
        end

        local tracerModel = Instance.new('Model')
        tracerModel.Name = 'TracerBeam'

        local beam = Instance.new('Beam')
        beam.Color = ColorSequence.new(getgenv().TracerColor)
        beam.Width0 = getgenv().TracerWidth
        beam.Width1 = getgenv().TracerWidth
        beam.Texture = 'rbxassetid://7136858729'
        beam.TextureSpeed = 1
        beam.Brightness = 5
        beam.LightEmission = 3
        beam.FaceCamera = true

        local att0 = Instance.new('Attachment')
        local att1 = Instance.new('Attachment')
        att0.WorldPosition = startPos
        att1.WorldPosition = endPos

        beam.Attachment0 = att0
        beam.Attachment1 = att1
        beam.Parent = tracerModel
        att0.Parent = tracerModel
        att1.Parent = tracerModel
        tracerModel.Parent = workspace

        local tween = TweenService:Create(beam, TweenInfo.new(getgenv().TracerLifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
            Width0 = 0,
            Width1 = 0,
            Brightness = 0,
        })
        tween:Play()
        tween.Completed:Connect(function()
            if tracerModel then tracerModel:Destroy() end
        end)
    end
end

local function fireRagebot(targetHead)
    local tool = getEquippedTool()
    if tool then
        local values = tool:FindFirstChild('Values')
        local hitmarker = tool:FindFirstChild('Hitmarker')

        if values and hitmarker then
            local serverAmmo = values:FindFirstChild('SERVER_Ammo')
            local serverStoredAmmo = values:FindFirstChild('SERVER_StoredAmmo')

            if serverAmmo and serverStoredAmmo and serverAmmo.Value > 0 then
                local startPos = getCameraPosition()
                local endPos = targetHead.Position
                local direction = (endPos - startPos).Unit

                if getgenv().Prediction then
                    endPos = endPos + (targetHead.Velocity or Vector3.zero) * getgenv().PredictionAmount
                    direction = (endPos - startPos).Unit
                end

                local camPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Head') and LocalPlayer.Character.Head.Position or CurrentCamera.CFrame.Position
                local spoofCode = generateRandomString(30) .. '0'
                
                local gnx_s = ReplicatedStorage:WaitForChild('Events'):WaitForChild('GNX_S')
                local zfklf_h = ReplicatedStorage:WaitForChild('Events'):WaitForChild('ZFKLF__H')

                gnx_s:FireServer(tick(), spoofCode, tool, 'FDS9I83', startPos, {direction}, false)
                zfklf_h:FireServer("🧈", tool, spoofCode, 1, targetHead, endPos, direction)

                serverAmmo.Value = math.max(serverAmmo.Value - 1, 0)
                hitmarker:Fire(targetHead)

                drawTracer(camPos, endPos)
                playHitSound()
            end
        end
    end
end

local function startFly()
    local char = LocalPlayer.Character
    if char then
        local root = char:WaitForChild('HumanoidRootPart')
        local hum = char:WaitForChild('Humanoid')

        coroutine.wrap(function()
            while isFlying and root and hum and hum.Health > 0 do
                local lookVec = CurrentCamera.CFrame.LookVector
                root.Velocity = Vector3.new(lookVec.X, lookVec.Y, lookVec.Z).Unit * getgenv().FlySpeed

                local flyArgs = { '__---r', Vector3.zero, CFrame.new(-4574, 3, -443, 0, 0, 1, 0, 1, 0, -1, 0, 0), false }
                ReplicatedStorage:WaitForChild('Events'):WaitForChild('__RZDONL'):FireServer(unpack(flyArgs))
                
                RunService.Heartbeat:Wait()
            end
        end)()
        hum.PlatformStand = true
    end
end

local function stopFly()
    isFlying = false
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChild('Humanoid')
        local root = char:FindFirstChild('HumanoidRootPart')
        if hum then hum.PlatformStand = false end
        if root then root.Velocity = Vector3.new(0, 0, 0) end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    if getgenv().FlyEnabled then task.wait(1); startFly() else stopFly() end
end)
LocalPlayer.CharacterRemoving:Connect(stopFly)

SectRagebot:Checkbox({ name = 'Enable Ragebot', def = false, callback = function(v) getgenv().RageEnabled = v end })
SectRagebot:Slider({ name = 'Fire Rate', min = 1, max = 1000, def = 5, rounding = 1, callback = function(v) getgenv().FireRate = v end })
SectRagebot:Checkbox({ name = 'Prediction', def = true, callback = function(v) getgenv().Prediction = v end })
SectRagebot:Slider({ name = 'Prediction Amount', min = 0.05, max = 0.3, def = 0.1, rounding = 2, callback = function(v) getgenv().PredictionAmount = v end })
SectRagebot:Checkbox({ name = 'Random Tracer', def = true, callback = function(v) getgenv().RandomTracer = v end })
SectRagebot:Slider({ name = 'Tracer Offset', min = 1, max = 15, def = 5, rounding = 1, callback = function(v) getgenv().RandomTracerOffset = v end })

SectTarget:Checkbox({ name = 'Visibility Check', def = true, callback = function(v) getgenv().VisibilityCheck = v end })
SectTarget:Checkbox({ name = 'Team Check', def = false, callback = function(v) getgenv().TeamCheck = v end })
SectTarget:Checkbox({ name = 'Downed Check', def = false, callback = function(v) getgenv().DownedCheck = v end })
SectTarget:Checkbox({ name = 'Target Lock', def = false, callback = function(v) getgenv().TargetLock = v; if not v then getgenv().LockedTarget = nil end end })
SectTarget:Checkbox({ name = 'FOV Circle', def = true, callback = function(v) getgenv().FovEnabled = v end })
SectTarget:Slider({ name = 'FOV Radius', min = 10, max = 500, def = 100, rounding = 1, callback = function(v) getgenv().FovRadius = v end })

SectWallbang:Checkbox({ name = 'Enable Wallbang', def = false, callback = function(v) getgenv().WallbangEnabled = v; if v then enableWallbang() end end })

SectSound:Checkbox({ name = 'Tracer Enabled', def = false, callback = function(v) getgenv().TracerEnabled = v end })
SectSound:Colorpicker({ name = 'Tracer Color', def = Color3.fromRGB(255, 0, 0), callback = function(v) getgenv().TracerColor = v end })
SectSound:Slider({ name = 'Tracer Width', min = 0.1, max = 2, def = 0.3, rounding = 1, callback = function(v) getgenv().TracerWidth = v end })
SectSound:Slider({ name = 'Tracer Lifetime', min = 0.1, max = 5, def = 0.3, rounding = 1, callback = function(v) getgenv().TracerLifetime = v end })
SectSound:Dropdown({ name = 'Hit Sound Type', options = {'Default', 'Weapon', 'Custom'}, def = {'Default'}, callback = function(v) getgenv().HitSoundType = v[1] end })
SectSound:Button({ name = 'Test Hit Sound', callback = function() playHitSound() end })

SectPlayer:Checkbox({ name = 'Fly', def = false, callback = function(v) getgenv().FlyEnabled = v; isFlying = v; if v then startFly() else stopFly() end end })
SectPlayer:Slider({ name = 'Fly Speed', min = 10, max = 200, def = 50, rounding = 1, callback = function(v) getgenv().FlySpeed = v end })

local NoRagdollConn
local NoRagdollEnabled = false
SectPlayer:Checkbox({
    name = 'No Ragdoll',
    def = false,
    callback = function(enabled)
        local function createMotor(part0, part1)
            local motor = Instance.new('Motor6D')
            motor.Name = 'NoRagdollMotor'
            motor.Part0 = part0
            motor.Part1 = part1
            motor.C0 = part0.CFrame:ToObjectSpace(part1.CFrame)
            motor.C1 = CFrame.new()
            motor.Parent = part0
            return motor
        end

        local function removeMotors(char)
            if char then
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA('BasePart') then
                        local m = part:FindFirstChild('NoRagdollMotor')
                        if m then m:Destroy() end
                    end
                end
            end
        end

        local function applyNoRagdoll()
            if NoRagdollEnabled then return end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild('HumanoidRootPart') then
                local root = char.HumanoidRootPart
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA('BasePart') and part ~= root then
                        local m = part:FindFirstChild('NoRagdollMotor')
                        if m then
                            m.C0 = root.CFrame:ToObjectSpace(part.CFrame)
                            m.C1 = CFrame.new()
                        else
                            createMotor(root, part)
                        end
                    end
                end
                NoRagdollEnabled = true
            end
        end

        if enabled then
            if NoRagdollConn then NoRagdollConn:Disconnect() end
            NoRagdollConn = LocalPlayer.CharacterAdded:Connect(function() NoRagdollEnabled = false; applyNoRagdoll() end)
            if LocalPlayer.Character then applyNoRagdoll() end
        else
            if NoRagdollConn then NoRagdollConn:Disconnect() end
            NoRagdollEnabled = false
            if LocalPlayer.Character then removeMotors(LocalPlayer.Character) end
        end
    end,
})

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(names, plr.Name) end
    end
    return names
end

local plrNamesList = getPlayerNames()
local TargetListDropdown = SectTargetLists:Dropdown({ name = 'Target List', options = plrNamesList, def = {}, multi = true, callback = function(v) getgenv().TargetList = v end })
local WhitelistDropdown = SectTargetLists:Dropdown({ name = 'Whitelist', options = plrNamesList, def = {}, multi = true, callback = function(v) getgenv().Whitelist = v end })

local function updatePlayerLists()
    local names = getPlayerNames()
    TargetListDropdown:UpdateOptions(names)
    WhitelistDropdown:UpdateOptions(names)
end

Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then updatePlayerLists() end end)
Players.PlayerRemoving:Connect(function() updatePlayerLists() end)

RunService.Heartbeat:Connect(function()
    if getgenv().RageEnabled then
        local currentTime = tick()
        local target = (1 / getgenv().FireRate <= currentTime - lastFireTime) and getClosestTarget()
        if target then
            fireRagebot(target)
            lastFireTime = currentTime
        end
    end
end)

local autoReloadRunning = false
local function handleAutoReload()
    if autoReloadRunning then return end
    autoReloadRunning = true

    local gnx_r = ReplicatedStorage:FindFirstChild('Events'):FindFirstChild('GNX_R')
    local conns = {}
    local charAddedConn, childAddedConn

    local function clearConns()
        for _, c in ipairs(conns) do if c.Connected then c:Disconnect() end end
        conns = {}
        if charAddedConn and charAddedConn.Connected then charAddedConn:Disconnect() end
        if childAddedConn and childAddedConn.Connected then childAddedConn:Disconnect() end
    end

    local function hookGun(tool)
        if tool and tool:FindFirstChild('IsGun') then
            local vals = tool:FindFirstChild('Values')
            if vals then
                local ammo = vals:FindFirstChild('SERVER_Ammo')
                local stored = vals:FindFirstChild('SERVER_StoredAmmo')
                if stored then
                    table.insert(conns, stored:GetPropertyChangedSignal('Value'):Connect(function()
                        if getgenv().AutoReload and stored.Value > 0 then gnx_r:FireServer(tick(), 'KLWE89U0', tool) end
                    end))
                end
                if ammo and stored then
                    table.insert(conns, ammo:GetPropertyChangedSignal('Value'):Connect(function()
                        if getgenv().AutoReload and stored.Value > 0 then gnx_r:FireServer(tick(), 'KLWE89U0', tool) end
                    end))
                end
            end
        end
    end

    local function setupCharacter(char)
        clearConns()
        hookGun(char:FindFirstChildOfClass('Tool'))
        childAddedConn = char.ChildAdded:Connect(function(child)
            if child:IsA('Tool') and child:FindFirstChild('IsGun') then hookGun(child) end
        end)
    end

    if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
    charAddedConn = LocalPlayer.CharacterAdded:Connect(setupCharacter)

    while getgenv().AutoReload do task.wait(0.1) end
    clearConns()
    autoReloadRunning = false
end

SectPlayer:Checkbox({ name = 'Auto Reload', def = false, callback = function(v) getgenv().AutoReload = v; if v then task.spawn(handleAutoReload) end end })
SectPlayer:Checkbox({ name = 'No Scream', def = false, callback = function(v) getgenv().NoScream = v end })

RunService.Heartbeat:Connect(function()
    if getgenv().NoScream and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Head') then
        for _, v in ipairs(LocalPlayer.Character.Head:GetChildren()) do
            if v:IsA('Sound') then v:Destroy() end
        end
    end
end)

getgenv().ESPEnabled = false
getgenv().ESPColor = Color3.fromRGB(255, 0, 0)
getgenv().ShowHealthBar = true
getgenv().ShowName = true
getgenv().ShowTool = true
getgenv().ShowDistance = true
getgenv().MaxDistance = 1000
getgenv().ShowBox = true
getgenv().ShowTracer = false
getgenv().ShowSkeleton = false
getgenv().ShowGlow = true

SectESP:Checkbox({ name = 'ESP Enabled', def = false, callback = function(v) getgenv().ESPEnabled = v end })
SectESP:Checkbox({ name = 'Show Health Bar', def = true, callback = function(v) getgenv().ShowHealthBar = v end })
SectESP:Checkbox({ name = 'Show Name', def = true, callback = function(v) getgenv().ShowName = v end })
SectESP:Checkbox({ name = 'Show Tool', def = true, callback = function(v) getgenv().ShowTool = v end })
SectESP:Checkbox({ name = 'Show Distance', def = true, callback = function(v) getgenv().ShowDistance = v end })
SectESP:Checkbox({ name = 'Show Box', def = true, callback = function(v) getgenv().ShowBox = v end })
SectESP:Checkbox({ name = 'Show Tracer', def = false, callback = function(v) getgenv().ShowTracer = v end })
SectESP:Checkbox({ name = 'Show Skeleton', def = false, callback = function(v) getgenv().ShowSkeleton = v end })
SectESP:Checkbox({ name = 'Show Glow', def = true, callback = function(v) getgenv().ShowGlow = v end })
SectESP:Slider({ name = 'Max Distance', min = 0, max = 5000, def = 1000, rounding = 0, callback = function(v) getgenv().MaxDistance = v end })
SectESP:Colorpicker({ name = 'ESP Color', def = Color3.fromRGB(255, 0, 0), callback = function(v) getgenv().ESPColor = v end })

SectUI:Colorpicker({ name = 'Custom Accent', def = getgenv().SkeetAccent, callback = function(v) getgenv().SkeetAccent = v end })

local ESPObjects = {}
local GlowObjects = {}

local function createESP(plr)
    if not ESPObjects[plr] then
        local esp = {
            Box = Drawing.new('Square'),
            HealthBar = Drawing.new('Square'),
            HealthText = Drawing.new('Text'),
            Name = Drawing.new('Text'),
            Tool = Drawing.new('Text'),
            Distance = Drawing.new('Text'),
            Tracer = Drawing.new('Line'),
            Skeleton = {}
        }
        esp.Box.Visible = false; esp.Box.Thickness = 1; esp.Box.Filled = false
        esp.HealthBar.Visible = false; esp.HealthBar.Thickness = 1; esp.HealthBar.Filled = true
        esp.HealthText.Visible = false; esp.HealthText.Size = 13; esp.HealthText.Outline = true; esp.HealthText.Center = true; esp.HealthText.Font = 3
        esp.Name.Visible = false; esp.Name.Size = 14; esp.Name.Outline = true; esp.Name.Center = true; esp.Name.Font = 3
        esp.Tool.Visible = false; esp.Tool.Size = 12; esp.Tool.Outline = true; esp.Tool.Center = true; esp.Tool.Font = 3
        esp.Distance.Visible = false; esp.Distance.Size = 12; esp.Distance.Outline = true; esp.Distance.Center = true; esp.Distance.Font = 3
        esp.Tracer.Visible = false; esp.Tracer.Thickness = 1
        ESPObjects[plr] = esp

        if getgenv().ShowGlow then
            local bb = Instance.new('BillboardGui')
            bb.Name = 'ESPBillboard'
            bb.Size = UDim2.new(0, 200, 0, 50)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true

            local tl = Instance.new('TextLabel')
            tl.Name = 'ESPLabel'
            tl.BackgroundTransparency = 1
            tl.TextColor3 = getgenv().ESPColor
            tl.TextSize = 14
            tl.FontFace = Font.new('rbxassetid://12187371840')
            tl.TextStrokeTransparency = 0
            tl.TextStrokeColor3 = Color3.new(0, 0, 0)
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.Parent = bb
            GlowObjects[plr] = bb
        end
    end
end

local function removeESP(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do
            if type(obj) ~= 'table' then
                if obj and obj.Remove then obj:Remove() end
            else
                for _, subObj in pairs(obj) do if subObj and subObj.Remove then subObj:Remove() end end
            end
        end
        ESPObjects[plr] = nil
    end
    if GlowObjects[plr] then GlowObjects[plr]:Destroy(); GlowObjects[plr] = nil end
end

local function updateESP()
    if getgenv().ESPEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if not ESPObjects[plr] then createESP(plr) end
                
                local esp = ESPObjects[plr]
                local glow = GlowObjects[plr]
                
                if plr.Character and plr.Character:FindFirstChild('Humanoid') and plr.Character:FindFirstChild('HumanoidRootPart') then
                    local char = plr.Character
                    local hum = char:FindFirstChild('Humanoid')
                    local root = char:FindFirstChild('HumanoidRootPart')
                    local head = char:FindFirstChild('Head')
                    local torso = char:FindFirstChild('UpperTorso') or char:FindFirstChild('Torso')

                    if hum.Health <= 0 then
                        for _, obj in pairs(esp) do if type(obj) ~= 'table' then obj.Visible = false end end
                        if glow then glow.Parent = nil end
                    else
                        local dist = (CurrentCamera.CFrame.Position - root.Position).Magnitude
                        if dist > getgenv().MaxDistance then
                            for _, obj in pairs(esp) do if type(obj) ~= 'table' then obj.Visible = false end end
                            if glow then glow.Parent = nil end
                        elseif head and torso then
                            local headPos, onScreen1 = CurrentCamera:WorldToViewportPoint(head.Position)
                            local torsoPos, onScreen2 = CurrentCamera:WorldToViewportPoint(torso.Position)
                            
                            if onScreen1 or onScreen2 then
                                if glow then
                                    glow.Adornee = head
                                    glow.Parent = head
                                    local label = glow:FindFirstChild('ESPLabel')
                                    if label then label.Text = plr.Name; label.TextColor3 = getgenv().ESPColor end
                                end

                                if getgenv().ShowBox then
                                    local boxSize = Vector2.new(2000 / dist, 3000 / dist)
                                    esp.Box.Visible = true
                                    esp.Box.Size = boxSize
                                    esp.Box.Position = Vector2.new(torsoPos.X - boxSize.X / 2, torsoPos.Y - boxSize.Y / 2)
                                    esp.Box.Color = getgenv().ESPColor
                                else
                                    esp.Box.Visible = false
                                end

                                if getgenv().ShowHealthBar then
                                    local hpPct = hum.Health / hum.MaxHealth
                                    local hpSize = Vector2.new(3, 40)
                                    local hpPos = Vector2.new(torsoPos.X - 25, torsoPos.Y - 20)
                                    
                                    esp.HealthBar.Visible = true
                                    esp.HealthBar.Size = Vector2.new(hpSize.X, hpSize.Y * hpPct)
                                    esp.HealthBar.Position = Vector2.new(hpPos.X, hpPos.Y + hpSize.Y * (1 - hpPct))
                                    esp.HealthBar.Color = Color3.fromRGB(255 * (1 - hpPct), 255 * hpPct, 0)
                                    
                                    esp.HealthText.Visible = true
                                    esp.HealthText.Text = tostring(math.floor(hum.Health))
                                    esp.HealthText.Position = Vector2.new(hpPos.X - 10, hpPos.Y - 15)
                                    esp.HealthText.Color = Color3.new(1, 1, 1)
                                else
                                    esp.HealthBar.Visible = false; esp.HealthText.Visible = false
                                end

                                if getgenv().ShowTracer then
                                    esp.Tracer.Visible = true
                                    esp.Tracer.From = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y)
                                    esp.Tracer.To = Vector2.new(torsoPos.X, torsoPos.Y)
                                    esp.Tracer.Color = getgenv().ESPColor
                                else
                                    esp.Tracer.Visible = false
                                end
                            else
                                for _, obj in pairs(esp) do if type(obj) ~= 'table' then obj.Visible = false end end
                                if glow then glow.Parent = nil end
                            end
                        end
                    end
                else
                    for _, obj in pairs(esp) do if type(obj) ~= 'table' then obj.Visible = false end end
                    if glow then glow.Parent = nil end
                end
            end
        end
    else
        for plr, _ in pairs(ESPObjects) do removeESP(plr) end
    end
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)
for _, plr in pairs(Players:GetPlayers()) do if plr ~= LocalPlayer then createESP(plr) end end

RunService.RenderStepped:Connect(updateESP)

repeat task.wait() until game:IsLoaded()

local oldNamecall
oldNamecall = hookmetamethod(game, '__namecall', function(self, ...)
    local args = {...}
    if getnamecallmethod() == 'FireServer' and not checkcaller() and args[1] == 'FlllD' and args[4] == false then
        args[2] = 0
        args[3] = 0
    end
    return oldNamecall(self, unpack(args))
end)

local function checkTable(t)
    local det = rawget(t, 'Detected')
    if det then
        if type(det) ~= 'function' then return false end
        return rawget(t, 'RLocked')
    end
    return false
end

for _, v in pairs(getgc(true)) do
    if type(v) == 'table' and checkTable(v) then
        for key, func in pairs(v) do
            if key == 'Detected' then
                local oldFunc
                oldFunc = hookfunction(func, function(a, b, c)
                    if a == '_' and b == '_' and c == false then
                        return oldFunc(a, b, c)
                    else
                        return task.wait(9e9)
                    end
                end)
                warn('bypassed')
                break
            end
        end
    end
end
