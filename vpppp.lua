-- ============================================
-- DELTA EXECUTOR - FIX MENU HIỂN THỊ (VERSION 2.0)
-- SỬA LỖI KHÔNG HIỆN MENU BẰNG CÁCH TẠO NHIỀU LỚP DỰ PHÒNG
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
-- FIX MENU - PHƯƠNG ÁN DỰ PHÒNG NHIỀU LỚP
-- ============================================
local function createMenu()
    pcall(function()
        -- XÓA MENU CŨ
        if _G.MenuUI then
            _G.MenuUI:Destroy()
            _G.MenuUI = nil
        end
        
        -- DANH SÁCH CÁC PARENT CÓ THỂ SỬ DỤNG
        local possibleParents = {}
        
        -- THỬ LẤY PlayerGui
        pcall(function()
            local pg = p:FindFirstChild("PlayerGui")
            if pg then table.insert(possibleParents, pg) end
        end)
        
        -- THỬ LẤY CoreGui
        pcall(function()
            local cg = game:GetService("CoreGui")
            if cg then table.insert(possibleParents, cg) end
        end)
        
        -- THỬ LẤY StarterGui (để chèn vào)
        pcall(function()
            local sg = game:GetService("StarterGui")
            if sg then table.insert(possibleParents, sg) end
        end)
        
        -- THỬ LẤY Workspace (luôn tồn tại)
        pcall(function()
            local ws = game:GetService("Workspace")
            if ws then table.insert(possibleParents, ws) end
        end)
        
        -- THỬ LẤY CurrentCamera (dùng làm canvas)
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then table.insert(possibleParents, cam) end
        end)
        
        -- THỬ LẤY ReplicatedStorage (nếu cần)
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            if rs then table.insert(possibleParents, rs) end
        end)
        
        -- TẠO MENU TRÊN TỪNG PARENT CHO ĐẾN KHI THÀNH CÔNG
        for _, parent in ipairs(possibleParents) do
            pcall(function()
                if not parent then return end
                
                -- TẠO SCREEN GUI
                local sg = Instance.new("ScreenGui")
                sg.Name = "AimFarmMenu"
                sg.Parent = parent
                sg.ResetOnSpawn = false
                sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                sg.Enabled = true
                
                -- KIỂM TRA GUI CÓ HIỂN THỊ KHÔNG
                wait(0.1)
                if sg.Parent then
                    _G.MenuUI = sg
                    print("[+] MENU DUOC TAO TRONG:", parent.Name)
                    break
                end
            end)
        end
        
        -- NẾU VẪN CHƯA TẠO ĐƯỢC, TẠO BẰNG CÁCH KHÁC
        if not _G.MenuUI then
            pcall(function()
                -- DÙNG Instance.new trực tiếp vào CoreGui
                local sg = Instance.new("ScreenGui")
                sg.Name = "AimFarmMenu"
                sg.Parent = game:GetService("CoreGui")
                sg.ResetOnSpawn = false
                _G.MenuUI = sg
                print("[+] MENU DUOC TAO TRONG: CoreGui (fallback)")
            end)
        end
        
        -- NẾU VẪN CHƯA CÓ, DÙNG BILLBOARD GUI TRONG WORKSPACE
        if not _G.MenuUI then
            pcall(function()
                local bill = Instance.new("BillboardGui")
                bill.Name = "AimFarmMenu"
                bill.Parent = workspace
                bill.Size = UDim2.new(0, 220, 0, 310)
                bill.StudsOffset = Vector3.new(0, 5, 0)
                bill.AlwaysOnTop = true
                bill.Adornee = workspace.CurrentCamera
                _G.MenuUI = bill
                print("[+] MENU DUOC TAO TRONG: BillboardGui (fallback 2)")
            end)
        end
        
        -- NẾU VẪN CHƯA CÓ, IN RA CẢNH BÁO
        if not _G.MenuUI then
            print("[!] KHONG THE TAO MENU!")
            return
        end
        
        -- ============================================
        -- TẠO GIAO DIỆN MENU
        -- ============================================
        local container = _G.MenuUI
        
        -- FRAME CHÍNH
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 220, 0, 310)
        frame.Position = UDim2.new(0, 10, 0.5, -155)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Draggable = true
        frame.Parent = container
        
        -- TIÊU ĐỀ
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 35)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        title.Text = "AUTO FARM + AVATAR"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 14
        title.Parent = frame
        
        -- NÚT ĐÓNG
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 30, 0, 25)
        closeBtn.Position = UDim2.new(1, -35, 0, 5)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.TextSize = 14
        closeBtn.Parent = title
        closeBtn.MouseButton1Click:Connect(function()
            _G.MenuUI:Destroy()
            _G.MenuUI = nil
            print("[!] MENU DA TAT")
        end)
        
        -- HÀM TẠO TOGGLE
        local function createToggle(y, text, flag, key)
            local bg = Instance.new("Frame")
            bg.Size = UDim2.new(1, 0, 0, 28)
            bg.Position = UDim2.new(0, 0, 0, y)
            bg.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            bg.BorderSizePixel = 0
            bg.Parent = frame
            
            -- BUTTON CLICK
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.Position = UDim2.new(0, 0, 0, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = bg
            
            btn.MouseButton1Click:Connect(function()
                getgenv()[flag] = not getgenv()[flag]
                print(flag .. ":", getgenv()[flag])
                updateMenu()
            end)
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0, 140, 1, 0)
            lbl.Position = UDim2.new(0, 8, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text .. " [" .. key .. "]"
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.Font = Enum.Font.SourceSans
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = bg
            
            local status = Instance.new("TextLabel")
            status.Size = UDim2.new(0, 60, 1, 0)
            status.Position = UDim2.new(1, -65, 0, 0)
            status.BackgroundTransparency = 1
            status.Text = getgenv()[flag] and "ON" or "OFF"
            status.TextColor3 = getgenv()[flag] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            status.Font = Enum.Font.SourceSansBold
            status.TextSize = 13
            status.TextXAlignment = Enum.TextXAlignment.Right
            status.Name = flag .. "_Status"
            status.Parent = bg
            
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, 1, 0)
            line.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            line.BorderSizePixel = 0
            line.Parent = bg
            
            return bg
        end
        
        createToggle(37, "AUTO FARM", "FARM", "F1")
        createToggle(66, "AUTO LOOT", "LOOT", "F2")
        createToggle(95, "AUTO EQUIP", "EQUIP", "F3")
        createToggle(124, "AUTO UPGRADE", "UPGRADE", "F4")
        createToggle(153, "AUTO SELL", "SELL", "F5")
        createToggle(182, "AUTO AVATAR", "AVATAR", "F6")
        createToggle(211, "AUTO SPIN", "SPIN", "F7")
        createToggle(240, "AUTO ROLL", "ROLL", "F8")
        createToggle(269, "AUTO CLAIM", "CLAIM", "F9")
        
        -- THÔNG BÁO CUỐI
        print("[+] MENU DA TAO THANH CONG!")
        print("[+] NHAN F1-F9 DE CHUYEN DOI CHUC NANG")
        print("[+] KEo MENU BANG CHUOT")
    end)
end

function updateMenu()
    pcall(function()
        if not _G.MenuUI then return end
        -- TÌM CÁC STATUS LABEL TRONG MENU
        for _, v in pairs({"FARM","LOOT","EQUIP","UPGRADE","SELL","AVATAR","SPIN","ROLL","CLAIM"}) do
            -- TÌM TRONG TOÀN BỘ MENU
            local statusLabel = nil
            pcall(function()
                statusLabel = _G.MenuUI:FindFirstChild(v .. "_Status", true)
                if not statusLabel then
                    -- TÌM TRONG TẤT CẢ CON CHÁU
                    for _, child in ipairs(_G.MenuUI:GetDescendants()) do
                        if child.Name == v .. "_Status" then
                            statusLabel = child
                            break
                        end
                    end
                end
            end)
            
            if statusLabel then
                statusLabel.Text = getgenv()[v] and "ON" or "OFF"
                statusLabel.TextColor3 = getgenv()[v] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
        end
    end)
end

-- ============================================
-- TẠO MENU VỚI NHIỀU LẦN THỬ
-- ============================================
local function tryCreateMenu(attempt)
    print("[*] DANG TAO MENU (LAN " .. attempt .. ")...")
    createMenu()
    wait(0.5)
    
    if _G.MenuUI then
        print("[+] MENU DA HIEN THI THANH CONG!")
        return true
    else
        if attempt < 5 then
            print("[!] THU LAI LAN " .. (attempt + 1) .. "...")
            wait(1)
            return tryCreateMenu(attempt + 1)
        else
            print("[!] KHONG THE TAO MENU SAU 5 LAN THU")
            print("[!] THU DUNG BILLBOARDGUI...")
            pcall(function()
                local bill = Instance.new("BillboardGui")
                bill.Name = "AimFarmMenu"
                bill.Parent = workspace
                bill.Size = UDim2.new(0, 220, 0, 310)
                bill.StudsOffset = Vector3.new(0, 5, 0)
                bill.AlwaysOnTop = true
                bill.Adornee = workspace.CurrentCamera
                _G.MenuUI = bill
                print("[+] MENU DA TAO BANG BillboardGui")
            end)
            return _G.MenuUI ~= nil
        end
    end
end

-- CHẠY TẠO MENU
wait(2)
tryCreateMenu(1)

-- ============================================
-- MAIN LOOP
-- ============================================
while wait(0.1) do
    if not c or not h or not r then
        waitForCharacter()
        equip()
    end
    
    if h and h.Health <= 0 then wait(1) continue end
    
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
  