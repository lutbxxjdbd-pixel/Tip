-- ============================================
-- AUTO FARM QUÁI VẬT - UNIVERSAL SCRIPT
-- TƯƠNG THÍCH VỚI 90% GAME ROBLOX (MMO, RPG, FARMING)
-- PHIÊN BẢN: 3.0 - TỐI ƯU TOÀN DIỆN
-- ============================================

-- ============================================
-- CẤU HÌNH CHÍNH (CHỈNH SỬA TẠI ĐÂY)
-- ============================================
getgenv().FARM_ENABLED = true
getgenv().AUTO_ATTACK = true
getgenv().AUTO_LOOT = true
getgenv().AUTO_HEAL = true
getgenv().AUTO_EQUIP = true
getgenv().AUTO_UPGRADE = false
getgenv().AUTO_SELL = false
getgenv().RADIUS = 50
getgenv().ATTACK_DELAY = 0.3
getgenv().HEAL_THRESHOLD = 0.3 -- Heal khi HP < 30%
getgenv().LOOT_RADIUS = 30
getgenv().IGNORE_PLAYERS = true -- Bỏ qua người chơi khác
getgenv().ONLY_TARGET_MOBS = true -- Chỉ tấn công quái vật

-- ============================================
-- DANH SÁCH TỪ KHÓA NHẬN DIỆN QUÁI VẬT
-- ============================================
local MOB_KEYWORDS = {
    "Mob", "Monster", "Enemy", "Zombie", "Skeleton", "Demon", "Dragon",
    "Slime", "Goblin", "Orc", "Troll", "Giant", "Wolf", "Bear", "Spider",
    "Bat", "Rat", "Snake", "Scorpion", "Vampire", "Wraith", "Ghost",
    "Golem", "Minion", "Boss", "Creature", "Beast", "Mutant", "Alien",
    "Robot", "Droid", "Cyborg", "Ninja", "Samurai", "Knight", "Bandit",
    "Thief", "Assassin", "Mage", "Wizard", "Necromancer", "Summon",
    "Titan", "Giant", "Colossus", "Hydra", "Cerberus", "Phoenix",
    "Yeti", "Bigfoot", "Lizard", "Crocodile", "Shark", "Piranha"
}

local LOOT_KEYWORDS = {
    "Coin", "Gold", "Money", "Cash", "Diamond", "Gem", "Crystal",
    "Loot", "Drop", "Item", "Chest", "Box", "Bag", "Potion", "Food",
    "Material", "Resource", "Wood", "Stone", "Iron", "Steel", "Leather",
    "Cloth", "Silk", "Rune", "Scroll", "Book", "Key", "Fragment",
    "Shard", "Token", "Ticket", "Essence", "Soul", "Heart", "Blood",
    "Bone", "Fang", "Claw", "Scale", "Feather", "Fur", "Meat"
}

-- ============================================
-- KHỞI TẠO PLAYER
-- ============================================
local p = game:GetService("Players").LocalPlayer
local c = nil
local h = nil
local r = nil

local function waitForCharacter()
    repeat 
        c = p.Character
        wait(0.3)
    until c
    repeat 
        h = c:FindFirstChildOfClass("Humanoid")
        wait(0.3)
    until h
    repeat 
        r = c:FindFirstChild("HumanoidRootPart")
        wait(0.3)
    until r
end

waitForCharacter()

-- ============================================
-- HÀM TIỆN ÍCH
-- ============================================
local function getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function isMob(obj)
    if not obj or not obj:IsA("Model") then return false end
    
    -- Bỏ qua nếu là Player
    if IGNORE_PLAYERS then
        if game:GetService("Players"):GetPlayerFromCharacter(obj) then
            return false
        end
    end
    
    -- Bỏ qua nếu là character của chính mình
    if obj == c then return false end
    
    -- Kiểm tra tên
    local name = string.lower(obj.Name)
    for _, kw in ipairs(MOB_KEYWORDS) do
        if string.find(name, string.lower(kw)) then
            return true
        end
    end
    
    -- Kiểm tra Humanoid
    local hum = obj:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 then
        return true
    end
    
    return false
end

local function isLoot(obj)
    if not obj then return false end
    local name = string.lower(obj.Name)
    for _, kw in ipairs(LOOT_KEYWORDS) do
        if string.find(name, string.lower(kw)) then
            return true
        end
    end
    return false
end

-- ============================================
-- TÌM QUÁI VẬT GẦN NHẤT
-- ============================================
local function findNearestMob()
    if not r then return nil end
    local nearest = nil
    local minDist = getgenv().RADIUS
    
    for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if isMob(obj) and obj:IsA("Model") then
            local root = obj:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = getDistance(r.Position, root.Position)
                if dist < minDist then
                    nearest = obj
                    minDist = dist
                end
            end
        end
    end
    return nearest
end

-- ============================================
-- TÌM LOOT GẦN NHẤT
-- ============================================
local function findNearestLoot()
    if not r then return nil end
    local nearest = nil
    local minDist = getgenv().LOOT_RADIUS
    
    for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("BasePart") and isLoot(obj) then
            local dist = getDistance(r.Position, obj.Position)
            if dist < minDist then
                nearest = obj
                minDist = dist
            end
        end
    end
    return nearest
end

-- ============================================
-- HÀM TẤN CÔNG
-- ============================================
local function attack(target)
    pcall(function()
        if not target or not r then return end
        
        -- Di chuyển đến gần
        local root = target:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        if getDistance(r.Position, root.Position) > 10 then
            r.CFrame = CFrame.new(root.Position + Vector3.new(0, 0, 5))
            wait(0.1)
        end
        
        -- Xoay về phía target
        r.CFrame = CFrame.lookAt(r.Position, root.Position)
        
        -- Các cách tấn công khác nhau
        -- 1. ClickDetector
        local cd = target:FindFirstChildOfClass("ClickDetector")
        if cd and fireclickdetector then
            fireclickdetector(cd)
            wait(getgenv().ATTACK_DELAY)
            return
        end
        
        -- 2. Remote Event
        local rs = game:GetService("ReplicatedStorage")
        local remotes = rs:FindFirstChild("Remotes") or rs:FindFirstChild("Events") or rs
        for _, ev in ipairs(remotes:GetDescendants()) do
            if ev:IsA("RemoteEvent") then
                local evName = string.lower(ev.Name)
                if string.find(evName, "attack") or string.find(evName, "damage") or 
                   string.find(evName, "hit") or string.find(evName, "fight") then
                    ev:FireServer(target)
                    wait(getgenv().ATTACK_DELAY)
                    return
                end
            end
        end
        
        -- 3. Tool Activation
        if c then
            local tool = c:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
                wait(0.1)
                tool:Deactivate()
                wait(getgenv().ATTACK_DELAY)
                return
            end
        end
        
        -- 4. Mouse Click (simulate)
        if getgenv().AUTO_ATTACK then
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            if mouse then
                mouse.Button1Down:Fire()
                wait(0.05)
                mouse.Button1Up:Fire()
                wait(getgenv().ATTACK_DELAY)
            end
        end
    end)
end

-- ============================================
-- HÀM NHẶT LOOT
-- ============================================
local function collectLoot(obj)
    pcall(function()
        if not r or not obj then return end
        
        -- Di chuyển đến loot
        if getDistance(r.Position, obj.Position) > 5 then
            r.CFrame = CFrame.new(obj.Position + Vector3.new(0, 0, 3))
            wait(0.1)
        end
        
        -- Click loot
        local cd = obj:FindFirstChildOfClass("ClickDetector")
        if cd and fireclickdetector then
            fireclickdetector(cd)
            return
        end
        
        -- Remote collect
        local rs = game:GetService("ReplicatedStorage")
        local remotes = rs:FindFirstChild("Remotes") or rs:FindFirstChild("Events") or rs
        for _, ev in ipairs(remotes:GetDescendants()) do
            if ev:IsA("RemoteEvent") then
                local evName = string.lower(ev.Name)
                if string.find(evName, "collect") or string.find(evName, "pickup") or 
                   string.find(evName, "loot") or string.find(evName, "grab") then
                    ev:FireServer(obj)
                    return
                end
            end
        end
    end)
end

-- ============================================
-- HÀM HEAL / HỒI MÁU
-- ============================================
local function heal()
    pcall(function()
        if not h then return end
        if h.Health / h.MaxHealth < getgenv().HEAL_THRESHOLD then
            -- Tìm và sử dụng potion
            local backpack = p:FindFirstChild("Backpack") or c:FindFirstChild("Backpack")
            if backpack then
                for _, v in ipairs(backpack:GetChildren()) do
                    local name = string.lower(v.Name)
                    if string.find(name, "potion") or string.find(name, "heal") or 
                       string.find(name, "health") or string.find(name, "recover") or
                       string.find(name, "food") or string.find(name, "eat") then
                        if v:IsA("Tool") then
                            if h then h:EquipTool(v) end
                            wait(0.3)
                            if v:FindFirstChild("Activate") then
                                v:Activate()
                            end
                            wait(0.5)
                            return
                        end
                    end
                end
            end
            
            -- Remote heal
            local rs = game:GetService("ReplicatedStorage")
            local remotes = rs:FindFirstChild("Remotes") or rs:FindFirstChild("Events") or rs
            for _, ev in ipairs(remotes:GetDescendants()) do
                if ev:IsA("RemoteEvent") and string.find(string.lower(ev.Name), "heal") then
                    ev:FireServer()
                    wait(1)
                    return
                end
            end
        end
    end)
end

-- ============================================
-- HÀM TRANG BỊ VŨ KHÍ TỐT NHẤT
-- ============================================
local function equipBest()
    pcall(function()
        if not c or not h then return end
        
        local best = nil
        local bestPower = 0
        
        local backpack = p:FindFirstChild("Backpack") or c:FindFirstChild("Backpack")
        if not backpack then return end
        
        for _, v in ipairs(backpack:GetChildren()) do
            if v:IsA("Tool") then
                local name = string.lower(v.Name)
                local power = 0
                -- Đánh giá sức mạnh dựa trên tên
                for _, tier in ipairs({
                    {"godly", 100}, {"mythic", 90}, {"divine", 85}, {"legendary", 80},
                    {"epic", 70}, {"rare", 60}, {"uncommon", 50}, {"common", 40}
                }) do
                    if string.find(name, tier[1]) then
                        power = tier[2]
                        break
                    end
                end
                if power == 0 then power = 30 end
                
                if power > bestPower then
                    best = v
                    bestPower = power
                end
            end
        end
        
        if best then
            h:EquipTool(best)
            print("[+] Đã trang bị:", best.Name)
        end
    end)
end

-- ============================================
-- HÀM NÂNG CẤP VŨ KHÍ
-- ============================================
local function upgradeWeapon()
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local remotes = rs:FindFirstChild("Remotes") or rs:FindFirstChild("Events") or rs
        
        for _, ev in ipairs(remotes:GetDescendants()) do
            if ev:IsA("RemoteEvent") then
                local evName = string.lower(ev.Name)
                if string.find(evName, "upgrade") or string.find(evName, "forge") or 
                   string.find(evName, "enhance") or string.find(evName, "craft") then
                    if c then
                        local tool = c:FindFirstChildOfClass("Tool")
                        if tool then
                            ev:FireServer(tool)
                            wait(0.5)
                        end
                    end
                    return
                end
            end
        end
        
        -- Click upgrade NPC
        for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
            if v:IsA("Model") then
                local name = string.lower(v.Name)
                if string.find(name, "upgrade") or string.find(name, "forge") or 
                   string.find(name, "anvil") or string.find(name, "smith") then
                    local cd = v:FindFirstChildOfClass("ClickDetector")
                    if cd and fireclickdetector then
                        fireclickdetector(cd)
                        return
                    end
                end
            end
        end
    end)
end

-- ============================================
-- HÀM BÁN ĐỒ
-- ============================================
local function sellItems()
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local remotes = rs:FindFirstChild("Remotes") or rs:FindFirstChild("Events") or rs
        
        for _, ev in ipairs(remotes:GetDescendants()) do
            if ev:IsA("RemoteEvent") then
                local evName = string.lower(ev.Name)
                if string.find(evName, "sell") then
                    ev:FireServer()
                    wait(0.5)
                    return
                end
            end
        end
        
        -- Click sell NPC
        for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
            if v:IsA("Model") then
                local name = string.lower(v.Name)
                if string.find(name, "sell") or string.find(name, "shop") or 
                   string.find(name, "merchant") or string.find(name, "vendor") then
                    local cd = v:FindFirstChildOfClass("ClickDetector")
                    if cd and fireclickdetector then
                        fireclickdetector(cd)
                        return
                    end
                end
            end
        end
    end)
end

-- ============================================
-- HÀM TẠO MENU
-- ============================================
local function createMenu()
    pcall(function()
        if _G.FarmMenu then
            _G.FarmMenu:Destroy()
            _G.FarmMenu = nil
        end
        
        local sg = Instance.new("ScreenGui")
        sg.Name = "FarmMenu"
        sg.Parent = game:GetService("CoreGui")
        sg.ResetOnSpawn = false
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 230, 0, 320)
        frame.Position = UDim2.new(0, 10, 0.5, -160)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Draggable = true
        frame.Parent = sg
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        title.Text = "⚔ AUTO FARM QUÁI VẬT ⚔"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 14
        title.Parent = frame
        
        local function createToggle(y, text, flag, key)
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 0, 28)
            bg.Position = UDim2.new(0, 0, 0, y)
            bg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            bg.BorderSizePixel = 0
            bg.Parent = frame
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = bg
            btn.MouseButton1Click:Connect(function()
                getgenv()[flag] = not getgenv()[flag]
                print(flag, ":", getgenv()[flag])
                updateMenu()
            end)
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 150, 1, 0)
            lbl.Position = UDim2.new(0, 8, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text .. " [" .. key .. "]"
            lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = bg
            
            local status = Instance.new("TextLabel")
            status.Size = UDim2.new(0, 55, 1, 0)
            status.Position = UDim2.new(1, -60, 0, 0)
            status.BackgroundTransparency = 1
            status.Text = getgenv()[flag] and "ON" or "OFF"
            status.TextColor3 = getgenv()[flag] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            status.Font = Enum.Font.SourceSansBold
            status.TextSize = 12
            status.Name = flag .. "_Status"
            status.Parent = bg
        end
        
        createToggle(32, "FARM QUÁI", "FARM_ENABLED", "F1")
        createToggle(61, "TẤN CÔNG", "AUTO_ATTACK", "F2")
        createToggle(90, "NHẶT LOOT", "AUTO_LOOT", "F3")
        createToggle(119, "HỒI MÁU", "AUTO_HEAL", "F4")
        createToggle(148, "TRANG BỊ", "AUTO_EQUIP", "F5")
        createToggle(177, "NÂNG CẤP", "AUTO_UPGRADE", "F6")
        createToggle(206, "BÁN ĐỒ", "AUTO_SELL", "F7")
        createToggle(235, "CHỈ TẤN CÔNG QUÁI", "ONLY_TARGET_MOBS", "F8")
        
        -- Thông tin
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, 0, 0, 25)
        info.Position = UDim2.new(0, 0, 1, -25)
        info.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        info.BackgroundTransparency = 0.5
        info.Text = "Bấm F1-F8 để bật/tắt"
        info.TextColor3 = Color3.fromRGB(255, 255, 255)
        info.Font = Enum.Font.SourceSans
        info.TextSize = 11
        info.Parent = frame
        
        _G.FarmMenu = sg
        print("[+] MENU AUTO FARM ĐÃ ĐƯỢC TẠO!")
    end)
end

function updateMenu()
    pcall(function()
        if not _G.FarmMenu then return end
        for _, flag in ipairs({
            "FARM_ENABLED", "AUTO_ATTACK", "AUTO_LOOT", "AUTO_HEAL",
            "AUTO_EQUIP", "AUTO_UPGRADE", "AUTO_SELL", "ONLY_TARGET_MOBS"
        }) do
            local label = _G.FarmMenu:FindFirstChild(flag .. "_Status", true)
            if label then
                label.Text = getgenv()[flag] and "ON" or "OFF"
                label.TextColor3 = getgenv()[flag] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
        end
    end)
end

-- ============================================
-- KEYBINDS
-- ============================================
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    local keys = {
        [Enum.KeyCode.F1] = "FARM_ENABLED",
        [Enum.KeyCode.F2] = "AUTO_ATTACK",
        [Enum.KeyCode.F3] = "AUTO_LOOT",
        [Enum.KeyCode.F4] = "AUTO_HEAL",
        [Enum.KeyCode.F5] = "AUTO_EQUIP",
        [Enum.KeyCode.F6] = "AUTO_UPGRADE",
        [Enum.KeyCode.F7] = "AUTO_SELL",
        [Enum.KeyCode.F8] = "ONLY_TARGET_MOBS"
    }
    if keys[input.KeyCode] then
        getgenv()[keys[input.KeyCode]] = not getgenv()[keys[input.KeyCode]]
        print(keys[input.KeyCode], ":", getgenv()[keys[input.KeyCode]])
        updateMenu()
    end
end)

-- ================================