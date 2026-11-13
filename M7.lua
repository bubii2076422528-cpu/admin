-- ============================================================================
-- ระบบ: ค่ายM7 (CAMP M7 STUDIO SYSTEM v6.0)
-- ตำแหน่งติดตั้ง: StarterPlayer -> StarterPlayerScripts (LocalScript)
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- 1. การตั้งค่าระบบทั้งหมด (Config)
-- ==========================================
local Config = {
	-- ระบบล็อคเป้า
	TargetLockEnabled = false,
	WallCheck = true, -- true = ไม่ล็อคทะลุกำแพง, false = ล็อคทะลุกำแพง
	FOVRadius = 120,
	LockSpeed = 0.45,
	FOVColor = Color3.fromRGB(0, 210, 255),
	FOVRainbow = false,

	-- ส่วนของร่างกายที่เปิดให้ล็อค (เปิดศีรษะเป็นค่าเริ่มต้น)
	TargetParts = {
		Head = true,
		Torso = false,
		LeftArm = false,
		RightArm = false,
		LeftLeg = false,
		RightLeg = false
	},

	-- รายชื่อผู้เล่นที่ยกเว้นการล็อค (Whitelist / ทีมเดียวกัน)
	ExcludedPlayers = {}, -- [UserId] = true

	-- ระบบมองเห็น (ESP)
	BoxESPEnabled = false,
	TracerESPEnabled = false,
	HealthBarEnabled = false,
	ESPColor = Color3.fromRGB(0, 210, 255),
	ESPRainbow = false,

	-- ระบบการเคลื่อนที่ (Movement + Anti-Rubberband)
	SpeedEnabled = false,
	JumpEnabled = false,
	WalkSpeed = 32,
	JumpPower = 85
}

local NORMAL_SPEED = 16
local NORMAL_JUMP = 50

local ColorPalette = {
	{Name = "สีรุ้ง (Rainbow)", IsRainbow = true, Color = Color3.fromRGB(255, 100, 100)},
	{Name = "ฟ้าไซเบอร์ (Cyan)", IsRainbow = false, Color = Color3.fromRGB(0, 210, 255)},
	{Name = "แดงเพลิง (Crimson)", IsRainbow = false, Color = Color3.fromRGB(255, 60, 85)},
	{Name = "เขียวนีออน (Neon Green)", IsRainbow = false, Color = Color3.fromRGB(50, 240, 120)},
	{Name = "เหลืองทอง (Gold)", IsRainbow = false, Color = Color3.fromRGB(255, 210, 50)},
	{Name = "ม่วงกาแล็กซี (Purple)", IsRainbow = false, Color = Color3.fromRGB(175, 85, 255)},
	{Name = "ชมพูสว่าง (Hot Pink)", IsRainbow = false, Color = Color3.fromRGB(255, 90, 195)},
	{Name = "ส้มลาวา (Orange)", IsRainbow = false, Color = Color3.fromRGB(255, 135, 45)},
	{Name = "ขาวบริสุทธิ์ (White)", IsRainbow = false, Color = Color3.fromRGB(255, 255, 255)}
}

local function randomName()
	return HttpService:GenerateGUID(false)
end

-- ==========================================
-- 2. สร้าง ScreenGui หลัก และ วงกลม FOV
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = randomName()
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local espFolder = Instance.new("Folder")
espFolder.Name = randomName()
espFolder.Parent = screenGui

local fovCircle = Instance.new("Frame")
fovCircle.Name = randomName()
fovCircle.Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = screenGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Config.FOVColor
fovStroke.Thickness = 1.8
fovStroke.Transparency = 0.15
fovStroke.Parent = fovCircle

-- ==========================================
-- 3. ปุ่มย่อ/ซ่อน UI โลโก้ "M7" สไตล์โปร
-- ==========================================
local m7Button = Instance.new("TextButton")
m7Button.Name = randomName()
m7Button.Size = UDim2.new(0, 66, 0, 66)
m7Button.Position = UDim2.new(0.04, 0, 0.2, 0)
m7Button.BackgroundColor3 = Color3.fromRGB(13, 17, 29)
m7Button.Text = ""
m7Button.Visible = false
m7Button.Active = true
m7Button.Draggable = true
m7Button.AutoButtonColor = false
m7Button.ZIndex = 20
m7Button.Parent = screenGui

local m7Corner = Instance.new("UICorner")
m7Corner.CornerRadius = UDim.new(1, 0)
m7Corner.Parent = m7Button

local m7OuterStroke = Instance.new("UIStroke")
m7OuterStroke.Color = Color3.fromRGB(0, 205, 255)
m7OuterStroke.Thickness = 2.5
m7OuterStroke.Parent = m7Button

local m7Gradient = Instance.new("UIGradient")
m7Gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 48, 88)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 12, 21))
}
m7Gradient.Rotation = 45
m7Gradient.Parent = m7Button

local m7InnerRing = Instance.new("Frame")
m7InnerRing.Size = UDim2.new(1, -10, 1, -10)
m7InnerRing.Position = UDim2.new(0, 5, 0, 5)
m7InnerRing.BackgroundTransparency = 1
m7InnerRing.ZIndex = 21
m7InnerRing.Parent = m7Button

local m7InnerCorner = Instance.new("UICorner")
m7InnerCorner.CornerRadius = UDim.new(1, 0)
m7InnerCorner.Parent = m7InnerRing

local m7InnerStroke = Instance.new("UIStroke")
m7InnerStroke.Color = Color3.fromRGB(140, 230, 255)
m7InnerStroke.Thickness = 1.2
m7InnerStroke.Transparency = 0.35
m7InnerStroke.Parent = m7InnerRing

local m7StarTop = Instance.new("TextLabel")
m7StarTop.Size = UDim2.new(1, 0, 0, 14)
m7StarTop.Position = UDim2.new(0, 0, 0, 6)
m7StarTop.BackgroundTransparency = 1
m7StarTop.Text = "✦"
m7StarTop.TextColor3 = Color3.fromRGB(255, 255, 255)
m7StarTop.Font = Enum.Font.GothamBold
m7StarTop.TextSize = 11
m7StarTop.ZIndex = 22
m7StarTop.Parent = m7Button

local m7LogoText = Instance.new("TextLabel")
m7LogoText.Size = UDim2.new(1, 0, 1, 0)
m7LogoText.Position = UDim2.new(0, 0, 0, 3)
m7LogoText.BackgroundTransparency = 1
m7LogoText.Text = "M7"
m7LogoText.TextColor3 = Color3.fromRGB(0, 225, 255)
m7LogoText.Font = Enum.Font.GothamBlack
m7LogoText.TextSize = 22
m7LogoText.ZIndex = 22
m7LogoText.Parent = m7Button

-- ==========================================
-- 4. หน้าต่างเมนูหลัก (✦ ค่ายM7)
-- ==========================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = randomName()
mainFrame.Size = UDim2.new(0, 355, 0, 480)
mainFrame.Position = UDim2.new(0.04, 0, 0.18, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(65, 155, 255)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

local function addStarfield(parentFrame, count)
	for i = 1, count do
		local star = Instance.new("Frame")
		local size = math.random(2, 3)
		star.Size = UDim2.new(0, size, 0, size)
		star.Position = UDim2.new(math.random(2, 98) / 100, 0, math.random(2, 98) / 100, 0)
		star.BackgroundColor3 = Color3.fromRGB(220, 240, 255)
		star.BackgroundTransparency = math.random(2, 7) / 10
		star.BorderSizePixel = 0
		star.ZIndex = 1

		local sCorner = Instance.new("UICorner")
		sCorner.CornerRadius = UDim.new(1, 0)
		sCorner.Parent = star
		star.Parent = parentFrame

		task.spawn(function()
			while star.Parent do
				local tween = TweenService:Create(star, TweenInfo.new(math.random(12, 28) / 10), {
					BackgroundTransparency = math.random(2, 9) / 10
				})
				tween:Play()
				tween.Completed:Wait()
			end
		end)
	end
end

addStarfield(mainFrame, 45)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(22, 26, 40)
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.75, 0, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✦ ค่ายM7  |  PRO SYSTEM"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -38, 0.5, -15)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 42, 62)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.ZIndex = 3
minimizeBtn.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

local scrollContainer = Instance.new("ScrollingFrame")
scrollContainer.Size = UDim2.new(1, 0, 1, -50)
scrollContainer.Position = UDim2.new(0, 0, 0, 48)
scrollContainer.BackgroundTransparency = 1
scrollContainer.BorderSizePixel = 0
scrollContainer.ScrollBarThickness = 4
scrollContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 185, 255)
scrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollContainer.ZIndex = 2
scrollContainer.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollContainer

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 4)
listPadding.PaddingBottom = UDim.new(0, 14)
listPadding.Parent = scrollContainer

-- ==========================================
-- 5. หน้าต่างป๊อปอัปย่อย (Color Picker, Body Part, Team/Whitelist)
-- ==========================================
local subPopups = {}

local function closeAllPopupsExcept(activePopup)
	for _, p in ipairs(subPopups) do
		if p ~= activePopup then
			p.Visible = false
		end
	end
end

local function createPopupBase(popupTitleText, height)
	local popup = Instance.new("Frame")
	popup.Name = randomName()
	popup.Size = UDim2.new(0, 275, 0, height)
	popup.Position = UDim2.new(0.04, 368, 0.18, 0)
	popup.BackgroundColor3 = Color3.fromRGB(16, 19, 30)
	popup.BorderSizePixel = 0
	popup.Visible = false
	popup.Active = true
	popup.Draggable = true
	popup.ClipsDescendants = true
	popup.ZIndex = 10
	popup.Parent = screenGui

	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(0, 12)
	pCorner.Parent = popup

	local pStroke = Instance.new("UIStroke")
	pStroke.Color = Color3.fromRGB(0, 195, 255)
	pStroke.Thickness = 1.5
	pStroke.Parent = popup

	addStarfield(popup, 20)

	local pHeader = Instance.new("Frame")
	pHeader.Size = UDim2.new(1, 0, 0, 38)
	pHeader.BackgroundColor3 = Color3.fromRGB(24, 29, 45)
	pHeader.BorderSizePixel = 0
	pHeader.ZIndex = 11
	pHeader.Parent = popup

	local pTitle = Instance.new("TextLabel")
	pTitle.Size = UDim2.new(0.8, 0, 1, 0)
	pTitle.Position = UDim2.new(0, 12, 0, 0)
	pTitle.BackgroundTransparency = 1
	pTitle.Text = popupTitleText
	pTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	pTitle.Font = Enum.Font.GothamBold
	pTitle.TextSize = 13
	pTitle.TextXAlignment = Enum.TextXAlignment.Left
	pTitle.ZIndex = 12
	pTitle.Parent = pHeader

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 26, 0, 26)
	closeBtn.Position = UDim2.new(1, -32, 0.5, -13)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 12
	closeBtn.ZIndex = 12
	closeBtn.Parent = pHeader

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 6)
	cCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		popup.Visible = false
	end)

	table.insert(subPopups, popup)
	return popup
end

-- 5.1 หน้าต่างเลือกสี (Color Picker)
local function createColorPickerPopup(titleText, onSelect)
	local popup = createPopupBase(titleText, 325)

	local listFrame = Instance.new("ScrollingFrame")
	listFrame.Size = UDim2.new(1, -16, 1, -48)
	listFrame.Position = UDim2.new(0, 8, 0, 42)
	listFrame.BackgroundTransparency = 1
	listFrame.BorderSizePixel = 0
	listFrame.ScrollBarThickness = 3
	listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	listFrame.ZIndex = 11
	listFrame.Parent = popup

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = listFrame

	for _, item in ipairs(ColorPalette) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -6, 0, 32)
		btn.BackgroundColor3 = Color3.fromRGB(26, 31, 46)
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 12
		btn.Parent = listFrame

		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 8)
		bCorner.Parent = btn

		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 18, 0, 18)
		dot.Position = UDim2.new(0, 10, 0.5, -9)
		dot.BackgroundColor3 = item.Color
		dot.ZIndex = 13
		dot.Parent = btn

		local dCorner = Instance.new("UICorner")
		dCorner.CornerRadius = UDim.new(1, 0)
		dCorner.Parent = dot

		if item.IsRainbow then
			local rbGrad = Instance.new("UIGradient")
			rbGrad.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(50, 255, 80)),
				ColorSequenceKeypoint.new(0.66, Color3.fromRGB(50, 150, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 220))
			}
			rbGrad.Parent = dot
		end

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -40, 1, 0)
		lbl.Position = UDim2.new(0, 36, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = item.Name
		lbl.TextColor3 = Color3.fromRGB(235, 240, 250)
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 13
		lbl.Parent = btn

		btn.MouseButton1Click:Connect(function()
			onSelect(item)
			popup.Visible = false
		end)
	end

	return popup
end

local fovColorPopup = createColorPickerPopup("✦ เลือกสีเป้ากลางจอ (FOV)", function(item)
	Config.FOVRainbow = item.IsRainbow
	if not item.IsRainbow then
		Config.FOVColor = item.Color
		fovStroke.Color = item.Color
	end
end)

local espColorPopup = createColorPickerPopup("✦ เลือกสี ESP", function(item)
	Config.ESPRainbow = item.IsRainbow
	if not item.IsRainbow then
		Config.ESPColor = item.Color
	end
end)

-- 5.2 หน้าต่างเลือกจุดล็อคบนร่างกาย (Body Part Selector GUI)
local bodyPartPopup = createPopupBase("✦ เลือกจุดล็อคบนร่างกาย", 335)

local bodyPartList = Instance.new("ScrollingFrame")
bodyPartList.Size = UDim2.new(1, -16, 1, -48)
bodyPartList.Position = UDim2.new(0, 8, 0, 42)
bodyPartList.BackgroundTransparency = 1
bodyPartList.BorderSizePixel = 0
bodyPartList.ScrollBarThickness = 3
bodyPartList.AutomaticCanvasSize = Enum.AutomaticSize.Y
bodyPartList.CanvasSize = UDim2.new(0, 0, 0, 0)
bodyPartList.ZIndex = 11
bodyPartList.Parent = bodyPartPopup

local bpLayout = Instance.new("UIListLayout")
bpLayout.Padding = UDim.new(0, 6)
bpLayout.Parent = bodyPartList

local bodyPartItems = {
	{Key = "Head", Label = "ล็อคศีรษะ (Head)"},
	{Key = "Torso", Label = "ล็อคลำตัว (Torso)"},
	{Key = "LeftArm", Label = "ล็อคแขนซ้าย (Left Arm)"},
	{Key = "RightArm", Label = "ล็อคแขนขวา (Right Arm)"},
	{Key = "LeftLeg", Label = "ล็อคขาซ้าย (Left Leg)"},
	{Key = "RightLeg", Label = "ล็อคขาขวา (Right Leg)"}
}

for _, bp in ipairs(bodyPartItems) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 40)
	row.BackgroundColor3 = Color3.fromRGB(24, 29, 44)
	row.ZIndex = 12
	row.Parent = bodyPartList

	local rCorner = Instance.new("UICorner")
	rCorner.CornerRadius = UDim.new(0, 8)
	rCorner.Parent = row

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.7, 0, 1, 0)
	lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = bp.Label
	lbl.TextColor3 = Color3.fromRGB(235, 240, 250)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 13
	lbl.Parent = row

	local isOn = Config.TargetParts[bp.Key]
	local swBtn = Instance.new("TextButton")
	swBtn.Size = UDim2.new(0, 42, 0, 22)
	swBtn.Position = UDim2.new(1, -50, 0.5, -11)
	swBtn.BackgroundColor3 = isOn and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 56, 74)
	swBtn.Text = ""
	swBtn.AutoButtonColor = false
	swBtn.ZIndex = 13
	swBtn.Parent = row

	local swC = Instance.new("UICorner")
	swC.CornerRadius = UDim.new(1, 0)
	swC.Parent = swBtn

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = isOn and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.ZIndex = 14
	knob.Parent = swBtn

	local kC = Instance.new("UICorner")
	kC.CornerRadius = UDim.new(1, 0)
	kC.Parent = knob

	swBtn.MouseButton1Click:Connect(function()
		isOn = not isOn
		Config.TargetParts[bp.Key] = isOn
		TweenService:Create(knob, TweenInfo.new(0.18), {
			Position = isOn and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		}):Play()
		TweenService:Create(swBtn, TweenInfo.new(0.18), {
			BackgroundColor3 = isOn and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 56, 74)
		}):Play()
	end)
end

-- 5.3 หน้าต่างเลือกผู้เล่น/ทีมที่ยกเว้นการล็อค (Whitelist & Auto-Team GUI)
local teamWhitelistPopup = createPopupBase("✦ เลือกคน/ทีมที่ไม่ต้องการล็อค", 365)

local autoTeamBtn = Instance.new("TextButton")
autoTeamBtn.Size = UDim2.new(1, -16, 0, 34)
autoTeamBtn.Position = UDim2.new(0, 8, 0, 44)
autoTeamBtn.BackgroundColor3 = Color3.fromRGB(35, 165, 110)
autoTeamBtn.Text = "✦ เลือกเพื่อนร่วมทีมให้อัตโนมัติ"
autoTeamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoTeamBtn.Font = Enum.Font.GothamBold
autoTeamBtn.TextSize = 12
autoTeamBtn.ZIndex = 12
autoTeamBtn.Parent = teamWhitelistPopup

local atCorner = Instance.new("UICorner")
atCorner.CornerRadius = UDim.new(0, 8)
atCorner.Parent = autoTeamBtn

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -16, 1, -92)
playerScroll.Position = UDim2.new(0, 8, 0, 84)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 3
playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.ZIndex = 11
playerScroll.Parent = teamWhitelistPopup

local plLayout = Instance.new("UIListLayout")
plLayout.Padding = UDim.new(0, 6)
plLayout.Parent = playerScroll

local function isSameTeam(targetPlayer)
	if not targetPlayer or targetPlayer == player then return false end
	if player.Team ~= nil and targetPlayer.Team == player.Team then
		return true
	end
	if not player.Neutral and not targetPlayer.Neutral and player.TeamColor == targetPlayer.TeamColor then
		return true
	end
	return false
end

local function refreshPlayerWhitelistUI()
	for _, child in ipairs(playerScroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, -6, 0, 48)
			row.BackgroundColor3 = Color3.fromRGB(24, 29, 44)
			row.ZIndex = 12
			row.Parent = playerScroll

			local rCorner = Instance.new("UICorner")
			rCorner.CornerRadius = UDim.new(0, 8)
			rCorner.Parent = row

			-- รูปสกิน/อวตารของผู้เล่น (Avatar Thumbnail)
			local avatarImg = Instance.new("ImageLabel")
			avatarImg.Size = UDim2.new(0, 36, 0, 36)
			avatarImg.Position = UDim2.new(0, 6, 0.5, -18)
			avatarImg.BackgroundColor3 = Color3.fromRGB(38, 45, 65)
			avatarImg.ZIndex = 13
			avatarImg.Parent = row

			local avCorner = Instance.new("UICorner")
			avCorner.CornerRadius = UDim.new(1, 0)
			avCorner.Parent = avatarImg

			task.spawn(function()
				local success, content = pcall(function()
					return Players:GetUserThumbnailAsync(
						targetPlayer.UserId,
						Enum.ThumbnailType.HeadShot,
						Enum.ThumbnailSize.Size100x100
					)
				end)
				if success and content and avatarImg.Parent then
					avatarImg.Image = content
				end
			end)

			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(0.55, 0, 0, 20)
			nameLabel.Position = UDim2.new(0, 48, 0, 6)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = targetPlayer.DisplayName
			nameLabel.TextColor3 = Color3.fromRGB(245, 248, 255)
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextSize = 12
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.ZIndex = 13
			nameLabel.Parent = row

			local subLabel = Instance.new("TextLabel")
			subLabel.Size = UDim2.new(0.55, 0, 0, 16)
			subLabel.Position = UDim2.new(0, 48, 0, 25)
			subLabel.BackgroundTransparency = 1
			local sameTeam = isSameTeam(targetPlayer)
			subLabel.Text = sameTeam and "✦ ทีมเดียวกัน (@" .. targetPlayer.Name .. ")" or "@" .. targetPlayer.Name
			subLabel.TextColor3 = sameTeam and Color3.fromRGB(80, 240, 150) or Color3.fromRGB(150, 165, 195)
			subLabel.Font = Enum.Font.GothamMedium
			subLabel.TextSize = 10
			subLabel.TextXAlignment = Enum.TextXAlignment.Left
			subLabel.TextTruncate = Enum.TextTruncate.AtEnd
			subLabel.ZIndex = 13
			subLabel.Parent = row

			local isExcluded = Config.ExcludedPlayers[targetPlayer.UserId] == true

			local swBtn = Instance.new("TextButton")
			swBtn.Size = UDim2.new(0, 42, 0, 22)
			swBtn.Position = UDim2.new(1, -48, 0.5, -11)
			swBtn.BackgroundColor3 = isExcluded and Color3.fromRGB(50, 215, 130) or Color3.fromRGB(50, 56, 74)
			swBtn.Text = ""
			swBtn.AutoButtonColor = false
			swBtn.ZIndex = 13
			swBtn.Parent = row

			local swC = Instance.new("UICorner")
			swC.CornerRadius = UDim.new(1, 0)
			swC.Parent = swBtn

			local knob = Instance.new("Frame")
			knob.Size = UDim2.new(0, 16, 0, 16)
			knob.Position = isExcluded and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
			knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			knob.ZIndex = 14
			knob.Parent = swBtn

			local kC = Instance.new("UICorner")
			kC.CornerRadius = UDim.new(1, 0)
			kC.Parent = knob

			swBtn.MouseButton1Click:Connect(function()
				isExcluded = not isExcluded
				Config.ExcludedPlayers[targetPlayer.UserId] = isExcluded and true or nil
				TweenService:Create(knob, TweenInfo.new(0.18), {
					Position = isExcluded and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
				}):Play()
				TweenService:Create(swBtn, TweenInfo.new(0.18), {
					BackgroundColor3 = isExcluded and Color3.fromRGB(50, 215, 130) or Color3.fromRGB(50, 56, 74)
				}):Play()
			end)
		end
	end
end

local function autoSelectTeammates()
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if isSameTeam(targetPlayer) then
			Config.ExcludedPlayers[targetPlayer.UserId] = true
		end
	end
	refreshPlayerWhitelistUI()
end

autoTeamBtn.MouseButton1Click:Connect(function()
	autoSelectTeammates()
end)

-- ==========================================
-- 6. การทำงานปุ่มย่อ/ซ่อนหน้าต่างเป็นโลโก้ M7
-- ==========================================
minimizeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	closeAllPopupsExcept(nil)
	m7Button.Position = mainFrame.Position
	m7Button.Visible = true
end)

m7Button.MouseButton1Click:Connect(function()
	m7Button.Visible = false
	mainFrame.Position = m7Button.Position
	mainFrame.Visible = true
end)

-- ==========================================
-- 7. ตัวช่วยสร้าง UI บนหน้าต่างหลัก
-- ==========================================
local layoutOrderCounter = 0
local function nextOrder()
	layoutOrderCounter = layoutOrderCounter + 1
	return layoutOrderCounter
end

local function createToggle(labelText, defaultState, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -24, 0, 42)
	row.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
	row.BackgroundTransparency = 0.15
	row.LayoutOrder = nextOrder()
	row.ZIndex = 2
	row.Parent = scrollContainer

	local rCorner = Instance.new("UICorner")
	rCorner.CornerRadius = UDim.new(0, 10)
	rCorner.Parent = row

	local rStroke = Instance.new("UIStroke")
	rStroke.Color = Color3.fromRGB(45, 55, 80)
	rStroke.Thickness = 1
	rStroke.Parent = row

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(0.74, 0, 1, 0)
	text.Position = UDim2.new(0, 12, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = labelText
	text.TextColor3 = Color3.fromRGB(235, 240, 250)
	text.Font = Enum.Font.GothamMedium
	text.TextSize = 12
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.ZIndex = 3
	text.Parent = row

	local switchBtn = Instance.new("TextButton")
	switchBtn.Size = UDim2.new(0, 44, 0, 22)
	switchBtn.Position = UDim2.new(1, -54, 0.5, -11)
	switchBtn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 56, 74)
	switchBtn.Text = ""
	switchBtn.AutoButtonColor = false
	switchBtn.ZIndex = 3
	switchBtn.Parent = row

	local swCorner = Instance.new("UICorner")
	swCorner.CornerRadius = UDim.new(1, 0)
	swCorner.Parent = switchBtn

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.ZIndex = 4
	knob.Parent = switchBtn

	local kCorner = Instance.new("UICorner")
	kCorner.CornerRadius = UDim.new(1, 0)
	kCorner.Parent = knob

	local state = defaultState
	switchBtn.MouseButton1Click:Connect(function()
		state = not state
		local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		local targetColor = state and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 56, 74)

		TweenService:Create(knob, TweenInfo.new(0.18), {Position = targetPos}):Play()
		TweenService:Create(switchBtn, TweenInfo.new(0.18), {BackgroundColor3 = targetColor}):Play()
		callback(state)
	end)
end

local function createPopupTriggerButton(labelText, badgeText, targetPopup, onOpenCallback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -24, 0, 42)
	btn.BackgroundColor3 = Color3.fromRGB(26, 32, 48)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.LayoutOrder = nextOrder()
	btn.ZIndex = 2
	btn.Parent = scrollContainer

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 10)
	bCorner.Parent = btn

	local bStroke = Instance.new("UIStroke")
	bStroke.Color = Color3.fromRGB(55, 75, 115)
	bStroke.Thickness = 1
	bStroke.Parent = btn

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(0.68, 0, 1, 0)
	text.Position = UDim2.new(0, 12, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = labelText
	text.TextColor3 = Color3.fromRGB(235, 240, 250)
	text.Font = Enum.Font.GothamMedium
	text.TextSize = 12
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.ZIndex = 3
	text.Parent = btn

	local badge = Instance.new("TextLabel")
	badge.Size = UDim2.new(0, 82, 0, 24)
	badge.Position = UDim2.new(1, -92, 0.5, -12)
	badge.BackgroundColor3 = Color3.fromRGB(0, 165, 255)
	badge.Text = badgeText
	badge.TextColor3 = Color3.fromRGB(255, 255, 255)
	badge.Font = Enum.Font.GothamBold
	badge.TextSize = 11
	badge.ZIndex = 3
	badge.Parent = btn

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 6)
	bgCorner.Parent = badge

	btn.MouseButton1Click:Connect(function()
		local willShow = not targetPopup.Visible
		closeAllPopupsExcept(targetPopup)
		if willShow then
			if onOpenCallback then onOpenCallback() end
			targetPopup.Position = UDim2.new(
				mainFrame.Position.X.Scale,
				mainFrame.Position.X.Offset + mainFrame.AbsoluteSize.X + 12,
				mainFrame.Position.Y.Scale,
				mainFrame.Position.Y.Offset
			)
		end
		targetPopup.Visible = willShow
	end)
end

local function createModeSwitcher()
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -24, 0, 44)
	container.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
	container.LayoutOrder = nextOrder()
	container.ZIndex = 2
	container.Parent = scrollContainer

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 10)
	cCorner.Parent = container

	local cStroke = Instance.new("UIStroke")
	cStroke.Color = Color3.fromRGB(55, 70, 105)
	cStroke.Thickness = 1
	cStroke.Parent = container

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0.48, 0, 1, -8)
	indicator.Position = UDim2.new(0.015, 0, 0, 4)
	indicator.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	indicator.ZIndex = 3
	indicator.Parent = container

	local indCorner = Instance.new("UICorner")
	indCorner.CornerRadius = UDim.new(0, 8)
	indCorner.Parent = indicator

	local btnNormal = Instance.new("TextButton")
	btnNormal.Size = UDim2.new(0.5, 0, 1, 0)
	btnNormal.BackgroundTransparency = 1
	btnNormal.Text = "ไม่ล็อคทะลุกำแพง"
	btnNormal.TextColor3 = Color3.fromRGB(255, 255, 255)
	btnNormal.Font = Enum.Font.GothamBold
	btnNormal.TextSize = 11
	btnNormal.ZIndex = 4
	btnNormal.Parent = container

	local btnWall = Instance.new("TextButton")
	btnWall.Size = UDim2.new(0.5, 0, 1, 0)
	btnWall.Position = UDim2.new(0.5, 0, 0, 0)
	btnWall.BackgroundTransparency = 1
	btnWall.Text = "ล็อคทะลุกำแพง"
	btnWall.TextColor3 = Color3.fromRGB(160, 175, 200)
	btnWall.Font = Enum.Font.GothamMedium
	btnWall.TextSize = 11
	btnWall.ZIndex = 4
	btnWall.Parent = container

	btnNormal.MouseButton1Click:Connect(function()
		Config.WallCheck = true
		TweenService:Create(indicator, TweenInfo.new(0.2), {
			Position = UDim2.new(0.015, 0, 0, 4),
			BackgroundColor3 = Color3.fromRGB(0, 150, 255)
		}):Play()
		btnNormal.TextColor3 = Color3.fromRGB(255, 255, 255)
		btnNormal.Font = Enum.Font.GothamBold
		btnWall.TextColor3 = Color3.fromRGB(160, 175, 200)
		btnWall.Font = Enum.Font.GothamMedium
	end)

	btnWall.MouseButton1Click:Connect(function()
		Config.WallCheck = false
		TweenService:Create(indicator, TweenInfo.new(0.2), {
			Position = UDim2.new(0.505, 0, 0, 4),
			BackgroundColor3 = Color3.fromRGB(220, 65, 95)
		}):Play()
		btnWall.TextColor3 = Color3.fromRGB(255, 255, 255)
		btnWall.Font = Enum.Font.GothamBold
		btnNormal.TextColor3 = Color3.fromRGB(160, 175, 200)
		btnNormal.Font = Enum.Font.GothamMedium
	end)
end

local function createSlider(labelPrefix, minVal, maxVal, defaultVal, isFloat, onChanged)
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, -24, 0, 52)
	box.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
	box.BackgroundTransparency = 0.15
	box.LayoutOrder = nextOrder()
	box.ZIndex = 2
	box.Parent = scrollContainer

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 10)
	bCorner.Parent = box

	local bStroke = Instance.new("UIStroke")
	bStroke.Color = Color3.fromRGB(45, 55, 80)
	bStroke.Thickness = 1
	bStroke.Parent = box

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -24, 0, 22)
	label.Position = UDim2.new(0, 12, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = labelPrefix .. ": " .. (isFloat and string.format("%.2f", defaultVal) or tostring(defaultVal))
	label.TextColor3 = Color3.fromRGB(235, 240, 250)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 3
	label.Parent = box

	local track = Instance.new("TextButton")
	track.Size = UDim2.new(1, -24, 0, 8)
	track.Position = UDim2.new(0, 12, 0, 34)
	track.BackgroundColor3 = Color3.fromRGB(45, 52, 72)
	track.Text = ""
	track.AutoButtonColor = false
	track.ZIndex = 3
	track.Parent = box

	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(1, 0)
	tCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
	fill.BorderSizePixel = 0
	fill.ZIndex = 4
	fill.Parent = track

	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(1, 0)
	fCorner.Parent = fill

	local dragging = false
	local function updateSlider(input)
		local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local rawVal = minVal + rel * (maxVal - minVal)
		local finalVal = isFloat and (math.floor(rawVal * 100 + 0.5) / 100) or math.floor(rawVal + 0.5)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		label.Text = labelPrefix .. ": " .. (isFloat and string.format("%.2f", finalVal) or tostring(finalVal))
		onChanged(finalVal)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateSlider(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- ==========================================
-- 8. จัดวางเมนูทั้งหมดลงในหน้าต่าง ค่ายM7
-- ==========================================
createToggle("เปิดใช้งานล็อคเป้า (เป้ากลางจอ)", false, function(isOn)
	Config.TargetLockEnabled = isOn
	fovCircle.Visible = isOn
end)

createModeSwitcher()

createPopupTriggerButton("เลือกจุดล็อคบนร่างกาย (หัว/ตัว/แขน/ขา)", "ตั้งค่า ▸", bodyPartPopup)

createPopupTriggerButton("เลือกคน/ทีมที่ไม่ต้องการล็อค", "รายชื่อ ▸", teamWhitelistPopup, function()
	refreshPlayerWhitelistUI()
end)

createSlider("ปรับขนาดเป้ากลางจอ (FOV)", 50, 300, Config.FOVRadius, false, function(val)
	Config.FOVRadius = val
	fovCircle.Size = UDim2.new(0, val * 2, 0, val * 2)
end)

createSlider("ความเร็วในการล็อคเป้า (Lock Speed)", 0.05, 1.00, Config.LockSpeed, true, function(val)
	Config.LockSpeed = val
end)

createPopupTriggerButton("เลือกสีเป้ากลางจอ (FOV Color)", "เลือกสี ▸", fovColorPopup)

createToggle("ESP กรอบสี่เหลี่ยมรอบตัว (Box)", false, function(isOn)
	Config.BoxESPEnabled = isOn
end)

createToggle("ESP เส้นลากหาผู้เล่น (Tracer Line)", false, function(isOn)
	Config.TracerESPEnabled = isOn
end)

createToggle("แสดงหลอดเลือดบนหัว (Health Bar)", false, function(isOn)
	Config.HealthBarEnabled = isOn
end)

createPopupTriggerButton("เลือกสี ESP (กรอบและเส้น)", "เลือกสี ▸", espColorPopup)

createToggle("วิ่งเร็ว (SPEED BOOST)", false, function(isOn)
	Config.SpeedEnabled = isOn
end)

createToggle("กระโดดสูง (HIGH JUMP)", false, function(isOn)
	Config.JumpEnabled = isOn
end)

-- ==========================================
-- 9. ระบบ ESP 2D (Box, Tracer, HealthBar)
-- ==========================================
local espCache = {}

local function createPlayerESP(targetPlayer)
	if targetPlayer == player or espCache[targetPlayer] then return end

	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1
	box.Visible = false
	box.Parent = espFolder

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = Config.ESPColor
	boxStroke.Thickness = 1.6
	boxStroke.Parent = box

	local tracer = Instance.new("Frame")
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BackgroundColor3 = Config.ESPColor
	tracer.BorderSizePixel = 0
	tracer.Visible = false
	tracer.Parent = espFolder

	local hpBg = Instance.new("Frame")
	hpBg.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
	hpBg.BorderSizePixel = 0
	hpBg.Visible = false
	hpBg.Parent = espFolder

	local hpFill = Instance.new("Frame")
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3 = Color3.fromRGB(60, 235, 115)
	hpFill.BorderSizePixel = 0
	hpFill.Parent = hpBg

	espCache[targetPlayer] = {
		Box = box,
		BoxStroke = boxStroke,
		Tracer = tracer,
		HpBg = hpBg,
		HpFill = hpFill
	}
end

local function removePlayerESP(targetPlayer)
	local data = espCache[targetPlayer]
	if data then
		data.Box:Destroy()
		data.Tracer:Destroy()
		data.HpBg:Destroy()
		espCache[targetPlayer] = nil
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	createPlayerESP(p)
end

Players.PlayerAdded:Connect(function(p)
	createPlayerESP(p)
	p:GetPropertyChangedSignal("Team"):Connect(function()
		if isSameTeam(p) then
			Config.ExcludedPlayers[p.UserId] = true
		end
		if teamWhitelistPopup.Visible then
			refreshPlayerWhitelistUI()
		end
	end)
	task.wait(0.5)
	if isSameTeam(p) then
		Config.ExcludedPlayers[p.UserId] = true
	end
end)

Players.PlayerRemoving:Connect(function(p)
	removePlayerESP(p)
	Config.ExcludedPlayers[p.UserId] = nil
	if teamWhitelistPopup.Visible then
		refreshPlayerWhitelistUI()
	end
end)

player:GetPropertyChangedSignal("Team"):Connect(function()
	autoSelectTeammates()
end)

task.defer(autoSelectTeammates)

-- ==========================================
-- 10. ระบบตรวจจับส่วนร่างกาย (รองรับ R15 & R6) + ล็อคเป้า
-- ==========================================
local partNameMapping = {
	Head = {"Head"},
	Torso = {"UpperTorso", "Torso", "HumanoidRootPart"},
	LeftArm = {"LeftUpperArm", "Left Arm"},
	RightArm = {"RightUpperArm", "Right Arm"},
	LeftLeg = {"LeftUpperLeg", "Left Leg"},
	RightLeg = {"RightUpperLeg", "Right Leg"}
}

local function getEnabledBodyParts(character)
	local parts = {}
	for key, enabled in pairs(Config.TargetParts) do
		if enabled and partNameMapping[key] then
			for _, partName in ipairs(partNameMapping[key]) do
				local found = character:FindFirstChild(partName)
				if found and found:IsA("BasePart") then
					table.insert(parts, found)
					break
				end
			end
		end
	end
	return parts
end

local function isTargetVisible(targetPart, targetCharacter)
	if not Config.WallCheck then return true end
	local origin = camera.CFrame.Position
	local direction = targetPart.Position - origin
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {player.Character, camera}
	local result = Workspace:Raycast(origin, direction, rayParams)
	if result then
		return result.Instance:IsDescendantOf(targetCharacter)
	end
	return true
end

local function getClosestTargetInFOV()
	local closestPart = nil
	local shortestDistance = Config.FOVRadius
	local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player and not Config.ExcludedPlayers[targetPlayer.UserId] and targetPlayer.Character then
			local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local candidateParts = getEnabledBodyParts(targetPlayer.Character)
				for _, part in ipairs(candidateParts) do
					local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
					if onScreen and screenPos.Z > 0 then
						local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
						if dist <= shortestDistance and isTargetVisible(part, targetPlayer.Character) then
							shortestDistance = dist
							closestPart = part
						end
					end
				end
			end
		end
	end

	return closestPart
end

-- ==========================================
-- 11. ระบบประคองความเร็วและกระโดดสูง (Anti-Rubberband)
-- ==========================================
local lastSafePos = nil
local recoveryCooldown = 0

RunService.Heartbeat:Connect(function(dt)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	if recoveryCooldown > 0 then
		recoveryCooldown -= dt
		hum.WalkSpeed = NORMAL_SPEED
		hum.JumpPower = NORMAL_JUMP
		lastSafePos = hrp.Position
		return
	end

	local desiredSpeed = Config.SpeedEnabled and Config.WalkSpeed or NORMAL_SPEED
	local desiredJump = Config.JumpEnabled and Config.JumpPower or NORMAL_JUMP

	if lastSafePos then
		local horizontalDist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(lastSafePos.X, 0, lastSafePos.Z)).Magnitude
		local expectedMaxDist = (desiredSpeed * dt * 2.5) + 3
		if horizontalDist > expectedMaxDist and hrp.AssemblyLinearVelocity.Magnitude < 5 then
			recoveryCooldown = 0.35
			hum.WalkSpeed = NORMAL_SPEED
			hum.JumpPower = NORMAL_JUMP
			return
		end
	end

	lastSafePos = hrp.Position
	hum.WalkSpeed = desiredSpeed
	hum.UseJumpPower = true
	hum.JumpPower = desiredJump
end)

-- ==========================================
-- 12. ลูปอัปเดตภาพและระบบล็อคเป้าหลัก (RenderStepped)
-- ==========================================
RunService.RenderStepped:Connect(function()
	local rainbowColor = Color3.fromHSV((tick() * 0.25) % 1, 0.85, 1)

	if Config.FOVRainbow then
		fovStroke.Color = rainbowColor
	end

	if Config.TargetLockEnabled then
		local targetPart = getClosestTargetInFOV()
		if targetPart then
			local targetCF = CFrame.new(camera.CFrame.Position, targetPart.Position)
			camera.CFrame = camera.CFrame:Lerp(targetCF, Config.LockSpeed)
		end
	end

	local viewportSize = camera.ViewportSize
	local bottomCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y)
	local activeESPColor = Config.ESPRainbow and rainbowColor or Config.ESPColor

	for targetPlayer, data in pairs(espCache) do
		local char = targetPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local head = char and char:FindFirstChild("Head")

		if char and hum and hum.Health > 0 and hrp and head then
			local hrpPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
			if onScreen and hrpPos.Z > 0 then
				local topPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
				local botPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.0, 0))

				local boxHeight = math.max(math.abs(botPos.Y - topPos.Y), 12)
				local boxWidth = boxHeight * 0.62
				local boxX = hrpPos.X - (boxWidth / 2)
				local boxY = topPos.Y

				local isExcluded = Config.ExcludedPlayers[targetPlayer.UserId] == true
				local finalColor = isExcluded and Color3.fromRGB(70, 240, 140) or activeESPColor

				if Config.BoxESPEnabled then
					data.Box.Position = UDim2.new(0, boxX, 0, boxY)
					data.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
					data.BoxStroke.Color = finalColor
					data.Box.Visible = true
				else
					data.Box.Visible = false
				end

				if Config.TracerESPEnabled then
					local targetFoot = Vector2.new(hrpPos.X, botPos.Y)
					local diff = targetFoot - bottomCenter
					local length = diff.Magnitude
					local mid = (bottomCenter + targetFoot) / 2
					local angle = math.deg(math.atan2(diff.Y, diff.X))

					data.Tracer.Position = UDim2.new(0, mid.X, 0, mid.Y)
					data.Tracer.Size = UDim2.new(0, length, 0, 1.5)
					data.Tracer.Rotation = angle
					data.Tracer.BackgroundColor3 = finalColor
					data.Tracer.Visible = true
				else
					data.Tracer.Visible = false
				end

				if Config.HealthBarEnabled then
					local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
					data.HpBg.Position = UDim2.new(0, boxX - 6, 0, boxY)
					data.HpBg.Size = UDim2.new(0, 3, 0, boxHeight)
					data.HpFill.Position = UDim2.new(0, 0, 1 - hpRatio, 0)
					data.HpFill.Size = UDim2.new(1, 0, hpRatio, 0)
					data.HpFill.BackgroundColor3 = Color3.fromHSV(hpRatio * 0.33, 0.85, 0.95)
					data.HpBg.Visible = true
				else
					data.HpBg.Visible = false
				end
			else
				data.Box.Visible = false
				data.Tracer.Visible = false
				data.HpBg.Visible = false
			end
		else
			data.Box.Visible = false
			data.Tracer.Visible = false
			data.HpBg.Visible = false
		end
	end
end)
