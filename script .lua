-- ============================================
-- DELTA EXECUTOR - AUTO FARM + AVATAR
-- F1:Farm F2:Loot F3:Equip F4:Upgrade F5:Sell
-- F6:Avatar F7:Spin F8:Roll F9:Claim
-- ============================================
getgenv().FARM = true
getgenv().LOOT = true
getgenv().EQUIP = true
getgenv().UPGRADE = true
getgenv().SELL = false
getgenv().AVATAR = false
getgenv().SPIN = false
getgenv().ROLL = false
getgenv().CLAIM = false
getgenv().RADIUS = 50

local p = game.Players.LocalPlayer
local c = p.Character or p.CharacterAdded:Wait()
local h = c:WaitForChild("Humanoid")
local r = c:WaitForChild("HumanoidRootPart")

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
        local cd = obj:FindFirstChildOfClass("ClickDetector")
        if cd then fireclickdetector(cd) return end
        local pp = obj:FindFirstChildOfClass("ProximityPrompt")
        if pp then fireproximityprompt(pp) return end
        local rs = game:GetService("ReplicatedStorage")
        local rem = rs:FindFirstChild("Remotes") or rs:FindFirstChild("Events") or rs
        local ev = rem:FindFirstChild("Mine") or rem:FindFirstChild("Harvest") or rem:FindFirstChild("Collect") or rem:FindFirstChild("Farm") or rem:FindFirstChild("Hit") or rem:FindFirstChild("Damage") or rem:FindFirstChild("Click")
        if ev and ev:IsA("RemoteEvent") then ev:FireServer(obj) return end
        local t = c:FindFirstChildOfClass("Tool")
        if t then t:Activate() wait(0.05) t:Deactivate() end
    end)
end

local function matchLoot(obj)
    local n = string.lower(obj.Name)
    for _, v in ipairs(lp) do if string.find(n, string.lower(v)) then return true end end
    return false
end

local function collectLoot(obj)
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
            local t = c:FindFirstChildOfClass("Tool")
            if t then ev:FireServer(t) end
            return
        end
        for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
            local n = string.lower(v.Name)
            if string.find(n, "upgrade") or string.find(n, "enchant") or string.find(n, "forge") or string.find(n, "smith") then
                local cd = v:FindFirstChildOfClass("ClickDetector")
                if cd then click(v); break end
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
                local cd = v:FindFirstChildOfClass("ClickDetector")
                if cd then click(v); break end
            end
        end
    end)
end

-- ============================================
-- AVATAR SCRIPT - TỰ ĐỘNG SPIN/ROLL/CLAIM
-- ============================================
local function findAndClick(name)
    for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
        local n = string.lower(v.Name)
        if string.find(n, string.lower(name)) then
            local cd = v:FindFirstChildOfClass("ClickDetector")
            if cd then fireclickdetector(cd) return true end
            local pp = v:FindFirstChildOfClass("ProximityPrompt")
            if pp then fireproximityprompt(pp) return true end
            local btn = v:FindFirstChildOfClass("TextButton") or v:FindFirstChildOfClass("ImageButton")
            if btn then
                pcall(function()
                    local gui = btn.Parent
                    if gui and gui:IsA("ScreenGui") then
                        fireclickdetector(btn)
                        return true
                    end
                end)
            end
        end
    end
    return false
end

local function fireRemote(name)
    local rs = game:GetService("ReplicatedStorage")
    local rem = rs:FindFirstChild("Remotes") or rs:FindFirstChild("Events") or rs
    for _, v in ipairs(rem:GetDescendants()) do
        if v:IsA("RemoteEvent") and string.find(string.lower(v.Name), string.lower(name)) then
            v:FireServer()
            return true
        end
    end
    return false
end

local function avatarSpin()
    pcall(function()
        if fireRemote("Spin") then return end
        findAndClick("Spin")
    end)
end

local function avatarRoll()
    pcall(function()
        if fireRemote("Roll") then return end
        findAndClick("Roll")
    end)
end

local function avatarClaim()
    pcall(function()
        if fireRemote("Claim") then return end
        findAndClick("Claim")
        findAndClick("Reward")
        findAndClick("Daily")
        findAndClick("Gift")
        findAndClick("Free")
    end)
end

local function autoAvatar()
    pcall(function()
        avatarClaim()
        wait(0.5)
        avatarSpin()
        wait(0.5)
        avatarRoll()
    end)
end

-- ============================================
-- RESPAWN
-- ============================================
p.CharacterAdded:Connect(function(nc)
    c = nc; h = c:WaitForChild("Humanoid"); r = c:WaitForChild("HumanoidRootPart")
    wait(0.5); equip()
end)

-- ============================================
-- STARTUP
-- ============================================
equip()
local lastPower = getPower()
local avatarCooldown = 0

print("===================================")
print(" DELTA AUTO FARM + AVATAR")
print(" CAP: " .. (tiers[lastPower] and tiers[lastPower].n or "DONG"))
print(" F1:Farm F2:Loot F3:Equip F4:Upgrade")
print(" F5:Sell F6:Avatar F7:Spin F8:Roll")
print("===================================")

-- ============================================
-- MAIN LOOP
-- ============================================
while wait(0.1) do
    if h.Health <= 0 then wait(1) continue end
    
    -- FARM
    if getgenv().FARM then
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
                    print("LEN CAP: " .. (tiers[cp] and tiers[cp].n or "???") .. " | POWER: " .. cp)
                    equip()
                end
            else
                r.CFrame = CFrame.new(r.Position + Vector3.new(math.random(-50,50), 0, math.random(-50,50)))
                wait(0.3)
            end
        end)
    end
    
    -- LOOT
    if getgenv().LOOT then
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
    
    -- AVATAR (MỖI 30 GIÂY)
    if getgenv().AVATAR or getgenv().SPIN or getgenv().ROLL or getgenv().CLAIM then
        avatarCooldown = avatarCooldown + 0.1
        if avatarCooldown >= 30 then
            avatarCooldown = 0
            if getgenv().AVATAR then autoAvatar()
            elseif getgenv().SPIN then avatarSpin()
            elseif getgenv().ROLL then avatarRoll()
            elseif getgenv().CLAIM then avatarClaim()
            end
        end
    end
end

-- ============================================
-- KEYBINDS
-- ============================================
game:GetService("UserInputService").InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.F1 then getgenv().FARM = not getgenv().FARM print("FARM:",getgenv().FARM) end
    if i.KeyCode == Enum.KeyCode.F2 then getgenv().LOOT = not getgenv().LOOT print("LOOT:",getgenv().LOOT) end
    if i.KeyCode == Enum.KeyCode.F3 then getgenv().EQUIP = not getgenv().EQUIP print("EQUIP:",getgenv().EQUIP) end
    if i.KeyCode == Enum.KeyCode.F4 then getgenv().UPGRADE = not getgenv().UPGRADE print("UPGRADE:",getgenv().UPGRADE) end
    if i.KeyCode == Enum.KeyCode.F5 then getgenv().SELL = not getgenv().SELL print("SELL:",getgenv().SELL) end
    if i.KeyCode == Enum.KeyCode.F6 then getgenv().AVATAR = not getgenv().AVATAR print("AVATAR:",getgenv().AVATAR) end
    if i.KeyCode == Enum.KeyCode.F7 then getgenv().SPIN = not getgenv().SPIN print("SPIN:",getgenv().SPIN) end
    if i.KeyCode == Enum.KeyCode.F8 then getgenv().ROLL = not getgenv().ROLL print("ROLL:",getgenv().ROLL) end
    if i.KeyCode == Enum.KeyCode.F9 then getgenv().CLAIM = not getgenv().CLAIM print("CLAIM:",getgenv().CLAIM) end
end)