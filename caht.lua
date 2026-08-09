local Players = game:GetService("Players")

-- Tự tạo folder nếu chưa có
local mobsFolder = workspace:FindFirstChild("Mobs") or Instance.new("Folder", workspace)
mobsFolder.Name = "Mobs"

local lootFolder = workspace:FindFirstChild("Loot") or Instance.new("Folder", workspace)
lootFolder.Name = "Loot"

local CONFIG = {
	AttackRange = 9,
	Damage = 15,
	AttackCooldown = 0.35,
	LootRange = 12,
	PreferBoss = true,
}

local function getRoot(model)
	return model and model:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid(model)
	return model and model:FindFirstChildOfClass("Humanoid")
end

-- Tìm mục tiêu tối ưu
local function findTarget(character)
	local root = getRoot(character)
	if not root then return nil end

	local normalTarget, bossTarget
	local normalDistance, bossDistance = math.huge, math.huge

	for _, mob in ipairs(mobsFolder:GetChildren()) do
		local humanoid = getHumanoid(mob)
		local mobRoot = getRoot(mob)

		if humanoid and mobRoot and humanoid.Health > 0 then
			local distance = (root.Position - mobRoot.Position).Magnitude
			local isBoss = mob:GetAttribute("Boss") == true or string.find(string.lower(mob.Name), "boss") ~= nil

			if isBoss and distance < bossDistance then
				bossTarget = mob
				bossDistance = distance
			end

			if distance < normalDistance then
				normalTarget = mob
				normalDistance = distance
			end
		end
	end

	return (CONFIG.PreferBoss and bossTarget) or normalTarget
end

-- Hút loot và xóa khỏi workspace khi chạm
local function collectLoot(character)
	local root = getRoot(character)
	if not root then return end

	for _, item in ipairs(lootFolder:GetChildren()) do
		local itemRoot = item:IsA("BasePart") and item or getRoot(item)

		if itemRoot then
			local distance = (root.Position - itemRoot.Position).Magnitude

			if distance <= CONFIG.LootRange then
				-- Thu dọn item (Bạn có thể thêm logic cộng tiền/điểm vào đây)
				item:Destroy()
			end
		end
	end
end

-- Logic Auto Farm theo từng lượt hồi sinh
local function autoFarmLoop(player, character)
	local humanoid = getHumanoid(character)
	local root = getRoot(character)

	if not humanoid or not root then return end

	-- Đợi cho đến khi Character tải xong hoàn toàn
	humanoid.Died:Connect(function()
		-- Dừng khi nhân vật chết
	end)

	while character.Parent and humanoid.Health > 0 do
		collectLoot(character)

		local target = findTarget(character)

		if target then
			local targetHumanoid = getHumanoid(target)
			local targetRoot = getRoot(target)

			if targetHumanoid and targetRoot and targetHumanoid.Health > 0 then
				local distance = (root.Position - targetRoot.Position).Magnitude

				if distance > CONFIG.AttackRange then
					-- Di chuyển tới quái
					humanoid:MoveTo(targetRoot.Position)
					task.wait(0.1)
				else
					-- Đã vào tầm đánh: Dừng di chuyển và tấn công
					humanoid:MoveTo(root.Position)
					targetHumanoid:TakeDamage(CONFIG.Damage)
					task.wait(CONFIG.AttackCooldown)
				end
			else
				task.wait(0.1)
			end
		else
			task.wait(0.3) -- Nghỉ khi không tìm thấy quái
		end
	end
end

-- Xử lý Player và Character Spawning
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.spawn(function()
			autoFarmLoop(player, character)
		end)
	end)
end)