-- ============================================
-- DELTA EXECUTOR - AUTO FARM + AVATAR + MENU
-- F1:Farm F2:Loot F3:Equip F4:Upgrade F5:Sell
-- F6:Avatar F7:Spin F8:Roll F9:Claim
-- ============================================
getgenv().FARM = true
getgenv().LOOT = true
getgenv().EQUIP = true
getgenv().UPGRADE = false
getgenv().SELL = false
getgenv().AVATAR = false
getgenv().SPIN = false
getgenv().ROLL = false
getgenv().CLAIM = false
getgenv().RADIUS = 50

local p = game.Players.LocalPlayer
local c = nil
local h = nil
local r = nil

local function waitForCharacter()
    repeat c = p.Character; wait(0.5) until c
    repeat h = c:FindFirstChild("Humanoid"); wait(0.5) until h
    repeat r = c:FindFirstChild("HumanoidRootPart"); wait(0.5) until r
end
waitForCharacter()

local tiers = {
    {n="Dirt", p=1, pt={"Dirt","Grass","Sand","Gravel","Mud"}},
    {n="Stone", p=2, pt={"Stone","Rock","Boulder","Pebble"}},
    {n="Copper", p=3, pt={"Copper","Bronze","Tin"}},
    {n="Iron", p=4, pt={"Iron","Steel","Metal"}},
    {n="Coal", p=5, pt={"Coal","Carbon","Charcoal"}},
    {n="Gold", p=6, pt={"Gold","Golden","Gilded"}},
    {n="Crystal", p=7, pt={"Crystal","Quartz","Gem","Amethyst"}},
    {n="Diamond", p=8, pt={"Diamond","Sapphire","Ruby","Emerald"}},
    {n="Obsidian", p=9, pt={"Obsidian","Magma","Lava","Volcanic"}},
    {n="Mythic", p=10, pt={"Mythic","Legendary","Divine","Godly","Titanic"}}
}

local lp = {"Coin","Money","Cash","Gold","Diamond","Gem","Crystal","Loot","Drop","Item","Sword","Pickaxe","Axe","Weapon","Tool","Gun","Armor","Helmet","Shield","Potion","Food","Backpack","Pet","Egg","Mount","Scroll","Book","Rune","Key","Fragment","Shard","Token","Ticket","Material","Resource","Common","Uncommon","Rare","Epic","Legendary","Mythic","Divine","Godly"}

local function getPower()
    if not c then return 1 end
    local t = c:FindFirstChildOfClass("Tool")
    if not t then return 1 end
    local n = string.lower(t.Name)
    for i = #tiers, 1, -1 do
        for _, k in pairs(tiers[i].pt) do
            if string.find(n, string.lower(k)) then return tiers[i].p end
        end
    end
    return 1
end

local function findBlock()
    if not r then return nil end
    local power = getPower()
    local best, bd = nil, getgenv().RADIUS
    local order = {power}
    for i = power-1, 1, -1 do table.insert(order, i) end
    if power < #tiers then table.insert(order, power+1) end
    for _, tp in ipairs(order) do
        local tier = tiers[tp]
        if tier then
            for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
                if v:IsA("BasePart") then
                    local d = (v.Position - r.Position).Magnitude
                    if d < bd then
                        local n = string.lower(v.Name)
                        for _, k in ipairs(tier.pt) do
                            if string.find(n, string.lower(k)) then best = v; bd = d; break end
                        end
                    end
                end
            end
        end
        if best then return best end
    end
    return nil
end

local function click(obj)
    pcall(function()
        if fireclickdetector then
            local cd = obj:FindFirstChildOfClass("ClickDetector")
            if cd then fireclickdetector(cd) return end
        end
        if fireproximityprompt then
            local pp = obj:FindFirstChildOfClass("ProximityPrompt")
            if pp then fireproximityprompt(pp) return end
        end
        local rs = game:GetService("ReplicatedStorage")
        local rem = rs:FindFirstChild("Remotes") or rs:FindFirstChild("Events") or rs
        local ev = rem:FindFirstChild("Mine") or rem:FindFirstChild("Harvest") or rem:FindFirstChild("Collect") or rem:FindFirstChild("Farm") or rem:FindFirstChild("Hit") or rem:FindFirstChild("Damage") or rem:FindFirstChild("Click")
        if ev and ev:IsA("RemoteEvent") then ev:FireServer(obj) return end
        if c then
            local t = c:FindFirstChildOfClass("Tool")
            if t then t:Activate() wait(0.05) t:Deactivate() end
        end
    end)
end

local function matchLoot(obj)
    local n = string.lower(obj.Name)
    for _, v in ipairs(lp) do if string.find(n, string.lower(v)) then return true end end
    return false
end

local function collectLoot(obj)
    if not r then return end
    pcall(function()
        local old = r.CFrame
        r.CFrame = CFrame.new(obj.Position)
        wait(0.05)
        local rs = game:GetService("ReplicatedStorage")
        local rem = rs:FindFirstChild("Remotes") or rs:FindFirstChild("Events") or rs
        local ev = rem:FindFirstChild("Collect") or rem:FindFirstChild("Pickup") or rem:FindFirstChild("Loot") or rem:FindFirstChild("Grab") or rem:FindFirstChild("Take")
        if ev and ev:IsA("RemoteEvent") then ev:FireServer(obj) end
        click(obj)
        wait(0.02)
        r.CFrame = old
    end)
end

local function equip()
    if not c or not h then return end
    pcall(function()
        local bp = p:FindFirstChild("Backpack") or c:FindFirstChild("Backpack")
        if not bp then return end
        local best, bp2 = nil, 0
        for _, v in ipairs(bp:GetChildren()) do
            if v:IsA("Tool") then
                local n = string.lower(v.Name)
                for i = #tiers, 1, -1 do
                    for _, k in ipairs(tiers[i].pt) do
                        if string.find(n, string.lower(k)) and tiers[i].p > bp2 then
                            best = v; bp2 = tiers[i].p
                        end
                    end
                end
            end
        end
        if best then h:EquipTool(best) end
    end)
end

local function upgrade()
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local rem = rs:FindFirstChild("Remotes") or rs:FindFirstChild("Events") or rs
        local ev = rem:FindFirstChild("Upgrade") or rem:FindFirstChild("Enchant") or rem:FindFirstChild("Forge") or rem:FindFirstChild("Craft") or rem:FindFirstChild("Smith")
        if ev and ev:IsA("RemoteEvent") then
            if c then
                local t = c:FindFirstChildOfClass("Tool")
                if t then ev:FireServer(t) end
            end
            return
        end
        for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
            local n = string.lower(v.Name)
            if string.find(n, "upgrade") or string.find(n, "enchant") or string.find(n, "forge") or string.find(n, "smith") then
                click(v); break
            end
        end
    end)
end

local function sell()
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local rem = rs:FindFirstChild("Remotes") or rs:FindFirstChild("Events") or rs
        local ev = rem:FindFirstChild("Sell") or rem:FindFirstChild("SellAll") or rem:FindFirstChild("Trade")
        if ev and ev:IsA("RemoteEvent") then ev:FireServer() return end
        for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
            local n = string.lower(v.Name)
            if string.find(n, "shop") or string.find(n, "sell") or string.find(n, "merchant") then
                click(v); break
            end
        end
    end)
end

local function fireRemote(name)
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local rem = rs:FindFirstChild("Remotes") or rs:FindFirstChild("Events") or rs
        for _, v in ipairs(rem:GetDescendants()) do
            if v:IsA("RemoteEvent") and string.find(string.lower(v.Name), string.lower(name)) then
                v:FireServer()
                return
            end
        end
    end)
end

local function findAndClick(name)
    for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
        local n = string.lower(v.Name)
        if string.find(n, string.lower(name)) then
            click(v)
            return
        end
    end
end

local function avatarSpin()
    fireRemote("Spin")
    findAndClick("Spin")
end

local function avatarRoll()
    fireRemote("Roll")
    findAndClick("Roll")
end

local function avatarClaim()
    fireRemote("Claim")
    findAndClick("Claim")
    findAndClick("Reward")
    findAndClick("Daily")
    findAndClick("Gift")
    findAndClick("Free")
end

local function autoAvatar()
    avatarClaim()
    wait(0.3)
    avatarSpin()
    wait(0.3)
    avatarRoll()
end

p.CharacterAdded:Connect(function()
    wait(1)
    waitForCharacter()
    equip()
end)

equip()
local lastPower = getPower()
local avatarCooldown = 0

-- ============================================
-- MENU HIỂN THỊ TẤT CẢ TRẠNG THÁI
-- ============================================
local menu = {}
local function createMenu()
    pcall(function()
        -- XÓA MENU CŨ NẾU CÓ
        if _G.MenuUI then
            _G.MenuUI:Destroy()
        end
        
        local ui = game:GetService("CoreGui"):FindFirstChild("AimFarmMenu")
        if ui then ui:Destroy() end
        
        -- TẠO SCREEN GUI
        local sg = Instance.new("ScreenGui")
        sg.Name = "AimFarmMenu"
        sg.Parent = game:GetService("CoreGui")
        sg.ResetOnSpawn = false
        _G.MenuUI = sg
        
        -- FRAME CHÍNH
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 220, 0, 300)
        frame.Position = UDim2.new(0, 10, 0.5, -150)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Draggable = true
        frame.Parent = sg
        
        -- TIÊU ĐỀ
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        title.Text = "AUTO FARM + AVATAR"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 14
        title.Parent = frame
        
        -- TẠO TỪNG DÒNG MENU
        local function createToggle(y, text, flag, key)
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 0, 25)
            bg.Position = UDim2.new(0, 0, 0, y)
            bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            bg.BorderSizePixel = 0
            bg.Parent = frame
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.Position = UDim2.new(0, 5, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text .. " [" .. key .. "]"
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = bg
            
            local status = Instance.new("TextLabel")
            status.Size = UDim2.new(0.3, 0, 1, 0)
            status.Position = UDim2.new(0.7, 0, 0, 0)
            status.BackgroundTransparency = 1
            status.Text = getgenv()[flag] and "ON" or "OFF"
            status.TextColor3 = getgenv()[flag] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            status.Font = Enum.Font.SourceSansBold
            status.TextSize = 12
            status.Name = flag .. "_Status"
            status.Parent = bg
            
            return bg
        end
        
        createToggle(30, "AUTO FARM", "FARM", "F1")
        createToggle(55, "AUTO LOOT", "LOOT", "F2")
        createToggle(80, "AUTO EQUIP", "EQUIP", "F3")
        createToggle(105, "AUTO UPGRADE", "UPGRADE", "F4")
        createToggle(130, "AUTO SELL", "SELL", "F5")
        createToggle(155, "AUTO AVATAR", "AVATAR", "F6")
        createToggle(180, "AUTO SPIN", "SPIN", "F7")
        createToggle(205, "AUTO ROLL", "ROLL", "F8")
        createToggle(230, "AUTO CLAIM", "CLAIM", "F9")
        
        -- NÚT RESET
        local resetBtn = Instance.new("TextButton")
        resetBtn.Size = UDim2.new(1, -10, 0, 25)
        resetBtn.Position = UDim2.new(0, 5, 0, 260)
        resetBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        resetBtn.Text = "RESET ALL (OFF)"
        resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        resetBtn.Font = Enum.Font.SourceSansBold
        resetBtn.TextSize = 12
        resetBtn.Parent = frame
        resetBtn.MouseButton1Click:Connect(function()
            for _, v in pairs({"FARM","LOOT","EQUIP","UPGRADE","SELL","AVATAR","SPIN","ROLL","CLAIM"}) do
                getgenv()[v] = false
            end
            updateMenu()
        end)
    end)
end

function updateMenu()
    pcall(function()
        for _, v in pairs({"FARM","LOOT","EQUIP","UPGRADE","SELL","AVATAR","SPIN","ROLL","CLAIM"}) do
            local statusLabel = _G.MenuUI:FindFirstChild(v .. "_Status", true)
            if statusLabel then
                statusLabel.Text = getgenv()[v] and "ON" or "OFF"
                statusLabel.TextColor3 = getgenv()[v] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
        end
    end)
end

-- ============================================
-- GỌI MENU
-- ============================================
createMenu()

-- ============================================
-- MAIN LOOP
-- ============================================
print("===================================")
print(" DELTA AUTO FARM + AVATAR + MENU")
print(" F1:Farm F2:Loot F3:Equip F4:Upgrade")
print(" F5:Sell F6:Avatar F7:Spin F8:Roll F9:Claim")
print("===================================")

while wait(0.1) do
    if not c or not h or not r then
        waitForCharacter()
        equip()
    end
    
    if h and h.Health <= 0 then wait(1) continue end
    
    -- FARM
    if getgenv().FARM and r then
        pcall(function()
            local block = findBlock()
            if block then
                if (block.Position - r.Position).Magnitude > 10 then
                    r.CFrame = CFrame.new(block.Position)
                    wait(0.05)
                end
                click(block)
                local cp = getPower()
                if cp ~= lastPower then
                    lastPower = cp
                    equip()
                end
            else
                r.CFrame = CFrame.new(r.Position + Vector3.new(math.random(-50,50), 0, math.random(-50,50)))
                wait(0.3)
            end
        end)
    end
    
    -- LOOT
    if getgenv().LOOT and r then
        pcall(function()
            for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
                if v:IsA("BasePart") and (v.Position - r.Position).Magnitude < getgenv().RADIUS and matchLoot(v) then
                    collectLoot(v)
                end
            end
        end)
    end
    
    if getgenv().EQUIP then equip() end
    if getgenv().UPGRADE then upgrade() end
    if getgenv().SELL then sell() end
    
    -- AVATAR
    if getgenv().AVATAR or getgenv().SPIN or getgenv().ROLL or getgenv().CLAIM then
        avatarCooldown = avatarCooldown + 0.1
        if avatarCooldown >= 30 then
            avatarCooldown = 0
            if getgenv().AVATAR then autoAvatar() end
            if getgenv().SPIN then avatarSpin() end
            if getgenv().ROLL then avatarRoll() end
            if getgenv().CLAIM then avatarClaim() end
        end
    end
    
    updateMenu()
end

-- ============================================
-- KEYBINDS
-- ============================================
game:GetService("UserInputService").InputBegan:Connect(function(i,g)
    if g then return end
    local keys = {
        [Enum.KeyCode.F1] = "FARM",
        [Enum.KeyCode.F2] = "LOOT",
        [Enum.KeyCode.F3] = "EQUIP",
        [Enum.KeyCode.F4] = "UPGRADE",
        [Enum.KeyCode.F5] = "SELL",
        [Enum.KeyCode.F6] = "AVATAR",
        [Enum.KeyCode.F7] = "SPIN",
        [Enum.KeyCode.F8] = "ROLL",
        [Enum.KeyCode.F9] = "CLAIM"
    }
    if keys[i.KeyCode] then
        getgenv()[keys[i.KeyCode]] = not getgenv()[keys[i.KeyCode]]
        print(keys[i.KeyCode] .. ":", getgenv()[keys[i.KeyCode]])
        updateMenu()
    end
end)