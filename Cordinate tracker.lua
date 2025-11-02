-- Coordinate Tracker (LocalScript)
-- Place in StarterPlayer > StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local char = nil
local root = nil

-- UI creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoordTrackerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 110)
frame.Position = UDim2.new(0, 16, 0, 16)
frame.BackgroundTransparency = 0.12
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -12, 0, 24)
title.Position = UDim2.new(0, 6, 0, 6)
title.BackgroundTransparency = 1
title.Text = "Coordinate Tracker"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -12, 0, 40)
info.Position = UDim2.new(0, 6, 0, 30)
info.BackgroundTransparency = 1
info.Text = "Press R to print a CFrame line to Output.\nClick the box to select and copy coordinates."
info.Font = Enum.Font.SourceSans
info.TextSize = 12
info.TextColor3 = Color3.fromRGB(200,200,200)
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.Parent = frame

local coordsBox = Instance.new("TextBox")
coordsBox.Size = UDim2.new(1, -12, 0, 30)
coordsBox.Position = UDim2.new(0, 6, 0, 68)
coordsBox.BackgroundTransparency = 0.18
coordsBox.Text = "Position: N/A"
coordsBox.ClearTextOnFocus = false
coordsBox.TextEditable = true
coordsBox.Font = Enum.Font.SourceSans
coordsBox.TextSize = 14
coordsBox.TextColor3 = Color3.fromRGB(255,255,255)
coordsBox.TextXAlignment = Enum.TextXAlignment.Left
coordsBox.Parent = frame

-- helper to format floats reasonably
local function fmt(n)
	return string.format("%.3f", tonumber(n) or 0)
end

local function updateCharacterReferences()
	char = player.Character or player.CharacterAdded:Wait()
	root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
end

-- update when respawn
player.CharacterAdded:Connect(function()
	task.wait(0.1)
	updateCharacterReferences()
end)

-- initial
if not player.Character then
	player.CharacterAdded:Wait()
end
updateCharacterReferences()

-- update loop
spawn(function()
	while true do
		if root and root:IsDescendantOf(game) then
			local pos = root.Position
			local look = root.CFrame - root.CFrame.p
			-- show position and Yaw (approx)
			local eulerY = root.Orientation.Y -- approximate heading
			coordsBox.Text = string.format("X:%s  Y:%s  Z:%s  Yaw:%s",
				fmt(pos.X), fmt(pos.Y), fmt(pos.Z), fmt(eulerY))
		else
			coordsBox.Text = "Position: N/A"
		end
		task.wait(0.08)
	end
end)

-- On R: print usable CFrame/Vector3 lines to Output
local function printCoords()
	if not root then
		updateCharacterReferences()
		if not root then
			warn("CoordTracker: no root part found")
			return
		end
	end
	local cf = root.CFrame
	local pos = cf.p
	local rot = cf - cf.p -- rotation part (Matrix)
	local strVec = string.format("Vector3.new(%s, %s, %s)", fmt(pos.X), fmt(pos.Y), fmt(pos.Z))
	local strCFrame = string.format("CFrame.new(%s, %s, %s) * CFrame.Angles(%s, %s, %s)",
		fmt(pos.X), fmt(pos.Y), fmt(pos.Z),
		fmt(cf:ToEulerAnglesXYZ())) -- note: ToEulerAnglesXYZ returns 3 values; we'll format below

	-- safer formatted CFrame (position + look vector)
	local lookVector = cf.LookVector
	local lookLine = string.format("CFrame.new(%s, %s, %s)", fmt(pos.X), fmt(pos.Y), fmt(pos.Z))
	-- Print both easy options
	print("-- CoordTracker output --")
	print("Vector3 (position): " .. strVec)
	print("CFrame (position only): " .. lookLine)
	print("-- End CoordTracker output --")

	-- Also set the UI textbox so it's easy to select+copy
	coordsBox.Text = string.format("%s    %s", strVec, lookLine)
end

-- Hotkey listener
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.R then
		printCoords()
	end
end)

-- Clicking the textbox will focus it so user can select/copy
coordsBox.FocusLost:Connect(function(enterPressed)
	-- nothing to do; keep text editable so user can select+copy
end)

-- Small note in output on load
print("CoordTracker loaded. Press R to print your Vector3/CFrame to Output. UI is in PlayerGui > CoordTrackerGui")
