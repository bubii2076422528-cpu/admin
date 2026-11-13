-- ============================================================================
-- ระบบค่าย M7 (CAMP M7 STUDIO SYSTEM v5)
-- สำหรับใช้งานใน Roblox Studio (LocalScript ภายใต้ StarterPlayerScripts)
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

-- ฟังก์ชันสุ่มชื่อ GUID ลดการชนกันของชื่อ Instance ใน PlayerGui
local function randomId()
	return HttpService:GenerateGUID(false):gsub("-", "")
end

-- ตั้งค่าระบบทั้งหมด
local Config = {
	TargetLockEnabled = false,
	WallCheck = true,          -- true = ไม่ล็อคทะลุกำแพง, false = ทะลุกำแพง
	TeamCheck = false,         -- true = ไม่ล็อคทีมตัวเอง (Team Check)
	FOVRadius = 120,
	LockSpeed = 0.45,
	FOVColor = Color3.fromRGB(0, 210, 255),
	FOVRainbow = false,

	BoxESPEnabled = false,
	TracerESPEnabled = false,
	HealthBarEnabled = false,
	ESPColor = Color3.fromRGB(0, 220, 255),
	ESPRainbow = false,

	SpeedEnabled = false,
	JumpEnabled = false,
	WalkSpeed = 32,
	JumpPower = 85
}

local NORMAL_SPEED = 16
local NORMAL_JUMP = 50

-- ชุดสีสำหรับหน้าต่างเลือกสี (FOV และ ESP)
local ColorPalette = {
	{Name = "สีรุ้ง (Rainbow)", IsRainbow = true, Color = Color3.fromRGB(255, 100, 100)},
	{Name = "ฟ้าไซเบอร์ (Cyan)", IsRainbow = false, Color = Color3.fromRGB(0, 210, 255)},
	{Name = "แดงเพลิง (Crimson)", IsRainbow = false, Color = Color3.fromRGB(255, 55, 75)},
	{Name = "เขียวนีออน (Neon Green)", IsRainbow = false, Color = Color3.fromRGB(50, 240, 120)},
	{Name = "เหลืองทอง (Gold)", IsRainbow = false, Color = Color3.fromRGB(255, 205, 45)},
	{Name = "ม่วงกาแล็กซี (Purple)", IsRainbow = false, Color = Color3.fromRGB(175, 85, 255)},
	{Name = "ชมพูพาสเทล (Pink)", IsRainbow = false, Color = Color3.fromRGB(255, 110, 195)},
	{Name = "ส้มลาวา (Orange)", IsRainbow = false, Color = Color3.fromRGB(255, 130, 35)},
	{Name = "ขาวบริสุทธิ์ (White)", IsRainbow = false, Color = Color3.fromRGB(255, 255, 255)},
	{Name = "น้ำเงินเข้ม (Royal Blue)", IsRainbow = false, Color = Color3.fromRGB(45, 110, 255)}
}

-- ============================================================================
-- 1. สร้าง ScreenGui และ Layer สำหรับวาด ESP / FOV
-- ============================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = randomId()
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local espFolder = Instance.new("Folder")
espFolder.Name = randomId()
espFolder.Parent = screenGui

-- วงกลมเป้ากลางจอ (FOV Circle)
local fovCircle = Instance.new("Frame")
fovCircle.Name = randomId()
fovCircle.Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.ZIndex = 1
fovCircle.Parent = screenGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Config.FOVColor
fovStroke.Thickness = 1.6
fovStroke.Transparency = 0.15
fovStroke.Parent = fovCircle

-- ============================================================================
-- 2. ปุ่มโลโก้ N7 (แสดงเมื่อกดซ่อนหน้าต่างหลัก)
-- ============================================================================
local n7Button = Instance.new("TextButton")
n7Button.Name = randomId()
n7Button.Size = UDim2.new(0, 58, 0, 58)
n7Button.Position = UDim2.new(0.05, 0, 0.2, 0)
n7Button.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
n7Button.Text = ""
n7Button.Visible = false
n7Button.Active = true
n7Button.Draggable = true
n7Button.AutoButtonColor = false
n7Button.ZIndex = 20
n7Button.Parent = screenGui

local n7Corner = Instance.new("UICorner")
n7Corner.CornerRadius = UDim.new(1, 0)
n7Corner.Parent = n7Button

local n7Stroke = Instance.new("UIStroke")
n7Stroke.Color = Color3.fromRGB(0, 200, 255)
n7Stroke.Thickness = 2
n7Stroke.Parent = n7Button

local n7Gradient = Instance.new("UIGradient")
n7Gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 35, 60)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 12, 20))
}
n7Gradient.Rotation = 45
n7Gradient.Parent = n7Button

local n7Text = Instance.new("TextLabel")
n7Text.Size = UDim2.new(1, 0, 1, 0)
n7Text.BackgroundTransparency = 1
n7Text.Text = "N7"
n7Text.TextColor3 = Color3.fromRGB(0, 220, 255)
n7Text.Font = Enum.Font.GothamBlack
n7Text.TextSize = 20
n7Text.ZIndex = 21
n7Text.Parent = n7Button

local n7SubStar = Instance.new("TextLabel")
n7SubStar.Size = UDim2.new(1, 0, 0, 14)
n7SubStar.Position = UDim2.new(0, 0, 0, 4)
n7SubStar.BackgroundTransparency = 1
n7SubStar.Text = "✦"
n7SubStar.TextColor3 = Color3.fromRGB(255, 255, 255)
n7SubStar.Font = Enum.Font.GothamBold
n7SubStar.TextSize = 10
n7SubStar.ZIndex = 21
n7SubStar.Parent = n7Button

-- ============================================================================
-- 3. หน้าต่างป๊อปอัปเลือกสี (ใช้ร่วมกันได้ทั้ง FOV และ ESP)
-- ============================================================================
local colorPickerFrame = Instance.new("Frame")
colorPickerFrame.Name = randomId()
colorPickerFrame.Size = UDim2.new(0, 240, 0, 320)
colorPickerFrame.Position = UDim2.new(0.05, 365, 0.22, 0)
colorPickerFrame.BackgroundColor3 = Color3.fromRGB(16, 19, 30)
colorPickerFrame.BorderSizePixel = 0
colorPickerFrame.Visible = false
colorPickerFrame.Active = true
colorPickerFrame.Draggable = true
colorPickerFrame.ZIndex = 30
colorPickerFrame.Parent = screenGui

local cpCorner = Instance.new("UICorner")
cpCorner.CornerRadius = UDim.new(0, 12)
cpCorner.Parent = colorPickerFrame

local cpStroke = Instance.new("UIStroke")
cpStroke.Color = Color3.fromRGB(0, 190, 255)
cpStroke.Thickness = 1.5
cpStroke.Parent = colorPickerFrame

local cpHeader = Instance.new("Frame")
cpHeader.Size = UDim2.new(1, 0, 0, 38)
cpHeader.BackgroundColor3 = Color3.fromRGB(24, 29, 45)
cpHeader.BorderSizePixel = 0
cpHeader.ZIndex = 31
cpHeader.Parent = colorPickerFrame

local cpHeaderCorner = Instance.new("UICorner")
cpHeaderCorner.CornerRadius = UDim.new(0, 12)
cpHeaderCorner.Parent = cpHeader

local cpTitle = Instance.new("TextLabel")
cpTitle.Size = UDim2.new(0.8, 0, 1, 0)
cpTitle.Position = UDim2.new(0, 12, 0, 0)
cpTitle.BackgroundTransparency = 1
cpTitle.Text = "✦ เลือกสี"
cpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
cpTitle.Font = Enum.Font.GothamBold
cpTitle.TextSize = 13
cpTitle.TextXAlignment = Enum.TextXAlignment.Left
cpTitle.ZIndex = 32
cpTitle.Parent = cpHeader

local cpCloseBtn = Instance.new("TextButton")
cpCloseBtn.Size = UDim2.new(0, 26, 0, 26)
cpCloseBtn.Position = UDim2.new(1, -32, 0.5, -13)
cpCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 55, 75)
cpCloseBtn.Text = "X"
cpCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cpCloseBtn.Font = Enum.Font.GothamBold
cpCloseBtn.TextSize = 12
cpCloseBtn.ZIndex = 32
cpCloseBtn.Parent = cpHeader

local cpCloseCorner = Instance.new("UICorner")
cpCloseCorner.CornerRadius = UDim.new(0, 6)
cpCloseCorner.Parent = cpCloseBtn

cpCloseBtn.MouseButton1Click:Connect(function()
	colorPickerFrame.Visible = false
end)

local cpScroll = Instance.new("ScrollingFrame")
cpScroll.Size = UDim2.new(1, -16, 1, -48)
cpScroll.Position = UDim2.new(0, 8, 0, 42)
cpScroll.BackgroundTransparency = 1
cpScroll.BorderSizePixel = 0
cpScroll.ScrollBarThickness = 4
cpScroll.CanvasSize = UDim2.new(0, 0, 0, #ColorPalette * 34)
cpScroll.ZIndex = 31
cpScroll.Parent = colorPickerFrame

local cpListLayout = Instance.new("UIListLayout")
cpListLayout.Padding = UDim.new(0, 5)
cpListLayout.Parent = cpScroll

local currentColorTarget = "FOV" -- "FOV" หรือ "ESP"
local fovPreviewDot = nil
local espPreviewDot = nil

for _, item in ipairs(ColorPalette) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 29)
	btn.BackgroundColor3 = Color3.fromRGB(26, 31, 48)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = 32
	btn.Parent = cpScroll

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 7)
	bCorner.Parent = btn

	local swatch = Instance.new("Frame")
	swatch.Size = UDim2.new(0, 16, 0, 16)
	swatch.Position = UDim2.new(0, 8, 0.5, -8)
	swatch.BackgroundColor3 = item.Color
	swatch.BorderSizePixel = 0
	swatch.ZIndex = 33
	swatch.Parent = btn

	local swCorner = Instance.new("UICorner")
	swCorner.CornerRadius = UDim.new(1, 0)
	swCorner.Parent = swatch

	if item.IsRainbow then
		local rbGrad = Instance.new("UIGradient")
		rbGrad.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 120)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 180, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 0, 255))
		}
		rbGrad.Parent = swatch
	end

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -34, 1, 0)
	lbl.Position = UDim2.new(0, 32, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = item.Name
	lbl.TextColor3 = Color3.fromRGB(235, 240, 250)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 33
	lbl.Parent = btn

	btn.MouseButton1Click:Connect(function()
		if currentColorTarget == "FOV" then
			Config.FOVRainbow = item.IsRainbow
			if not item.IsRainbow then
				Config.FOVColor = item.Color
				fovStroke.Color = item.Color
				if fovPreviewDot then fovPreviewDot.BackgroundColor3 = item.Color end
			end
		elseif currentColorTarget == "ESP" then
			Config.ESPRainbow = item.IsRainbow
			if not item.IsRainbow then
				Config.ESPColor = item.Color
				if espPreviewDot then espPreviewDot.BackgroundColor3 = item.Color end
			end
		end
	end)
end

local function openColorPicker(targetType, titleText, anchorFrame)
	currentColorTarget = targetType
	cpTitle.Text = "✦ " .. titleText
	colorPickerFrame.Position = UDim2.new(
		anchorFrame.Position.X.Scale,
		anchorFrame.Position.X.Offset + anchorFrame.Size.X.Offset + 12,
		anchorFrame.Position.Y.Scale,
		anchorFrame.Position.Y.Offset
	)
	colorPickerFrame.Visible = true
end

-- ============================================================================
-- 4. หน้าต่างเมนูหลัก (✦ ค่ายM7)
-- ============================================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = randomId()
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.05, 0, 0.14, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 5
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(65, 155, 255)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- เอฟเฟกต์ดวงดาวระยิบระยับในพื้นหลัง
for i = 1, 45 do
	local star = Instance.new("Frame")
	local size = math.random(2, 3)
	star.Size = UDim2.new(0, size, 0, size)
	star.Position = UDim2.new(math.random(2, 98) / 100, 0, math.random(2, 98) / 100, 0)
	star.BackgroundColor3 = Color3.fromRGB(220, 240, 255)
	star.BackgroundTransparency = math.random(2, 7) / 10
	star.BorderSizePixel = 0
	star.ZIndex = 6
	
	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(1, 0)
	sCorner.Parent = star
	star.Parent = mainFrame
	
	task.spawn(function()
		while star.Parent do
			local tween = TweenService:Create(star, TweenInfo.new(math.random(12, 28)/10), {BackgroundTransparency = math.random(2, 9)/10})
			tween:Play()
			tween.Completed:Wait()
		end
	end)
end

-- แถบหัวข้อด้านบน
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Color3.fromRGB(22, 26, 40)
header.BackgroundTransparency = 0.25
header.BorderSizePixel = 0
header.ZIndex = 7
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✦ ค่ายM7"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 8
title.Parent = header

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -36, 0.5, -14)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 42, 62)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.ZIndex = 8
minimizeBtn.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

minimizeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	colorPickerFrame.Visible = false
	n7Button.Position = mainFrame.Position
	n7Button.Visible = true
end)

n7Button.MouseButton1Click:Connect(function()
	n7Button.Visible = false
	mainFrame.Position = n7Button.Position
	mainFrame.Visible = true
end)

-- ScrollingFrame สำหรับจัดเรียงเมนูทั้งหมดอย่างเป็นระเบียบ
local menuScroll = Instance.new("ScrollingFrame")
menuScroll.Size = UDim2.new(1, -16, 1, -50)
menuScroll.Position = UDim2.new(0, 8, 0, 46)
menuScroll.BackgroundTransparency = 1
menuScroll.BorderSizePixel = 0
menuScroll.ScrollBarThickness = 4
menuScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 190, 255)
menuScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
menuScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
menuScroll.ZIndex = 7
menuScroll.Parent = mainFrame

local menuLayout = Instance.new("UIListLayout")
menuLayout.Padding = UDim.new(0, 7)
menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
menuLayout.Parent = menuScroll

local menuPadding = Instance.new("UIPadding")
menuPadding.PaddingLeft = UDim.new(0, 4)
menuPadding.PaddingRight = UDim.new(0, 6)
menuPadding.PaddingBottom = UDim.new(0, 8)
menuPadding.Parent = menuScroll

-- ============================================================================
-- 5. ฟังก์ชันสร้างองค์ประกอบ UI (Toggle, Mode Switch, Color Button, Slider)
-- ============================================================================
local layoutIndex = 0
local function nextOrder()
	layoutIndex += 1
	return layoutIndex
end

local function createToggle(labelText, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 40)
	row.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
	row.BackgroundTransparency = 0.2
	row.LayoutOrder = nextOrder()
	row.ZIndex = 8
	row.Parent = menuScroll

	local rCorner = Instance.new("UICorner")
	rCorner.CornerRadius = UDim.new(0, 9)
	rCorner.Parent = row

	local rStroke = Instance.new("UIStroke")
	rStroke.Color = Color3.fromRGB(45, 55, 80)
	rStroke.Thickness = 1
	rStroke.Parent = row

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(0.75, 0, 1, 0)
	text.Position = UDim2.new(0, 12, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = labelText
	text.TextColor3 = Color3.fromRGB(235, 240, 250)
	text.Font = Enum.Font.GothamMedium
	text.TextSize = 12.5
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.ZIndex = 9
	text.Parent = row

	local switchBtn = Instance.new("TextButton")
	switchBtn.Size = UDim2.new(0, 42, 0, 20)
	switchBtn.Position = UDim2.new(1, -52, 0.5, -10)
	switchBtn.BackgroundColor3 = Color3.fromRGB(50, 56, 74)
	switchBtn.Text = ""
	switchBtn.AutoButtonColor = false
	switchBtn.ZIndex = 9
	switchBtn.Parent = row

	local swCorner = Instance.new("UICorner")
	swCorner.CornerRadius = UDim.new(1, 0)
	swCorner.Parent = switchBtn

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(0, 3, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.ZIndex = 10
	knob.Parent = switchBtn

	local kCorner = Instance.new("UICorner")
	kCorner.CornerRadius = UDim.new(1, 0)
	kCorner.Parent = knob

	local state = false
	switchBtn.MouseButton1Click:Connect(function()
		state = not state
		local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		local targetColor = state and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 56, 74)

		TweenService:Create(knob, TweenInfo.new(0.18), {Position = targetPos}):Play()
		TweenService:Create(switchBtn, TweenInfo.new(0.18), {BackgroundColor3 = targetColor}):Play()
		callback(state)
	end)
end

local function createModeSwitcher()
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 42)
	container.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
	container.LayoutOrder = nextOrder()
	container.ZIndex = 8
	container.Parent = menuScroll

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 9)
	cCorner.Parent = container

	local cStroke = Instance.new("UIStroke")
	cStroke.Color = Color3.fromRGB(55, 70, 105)
	cStroke.Thickness = 1
	cStroke.Parent = container

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0.48, 0, 1, -8)
	indicator.Position = UDim2.new(0.015, 0, 0, 4)
	indicator.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
	indicator.ZIndex = 9
	indicator.Parent = container

	local indCorner = Instance.new("UICorner")
	indCorner.CornerRadius = UDim.new(0, 7)
	indCorner.Parent = indicator

	local btnNormal = Instance.new("TextButton")
	btnNormal.Size = UDim2.new(0.5, 0, 1, 0)
	btnNormal.BackgroundTransparency = 1
	btnNormal.Text = "ไม่ล็อคทะลุกำแพง"
	btnNormal.TextColor3 = Color3.fromRGB(255, 255, 255)
	btnNormal.Font = Enum.Font.GothamBold
	btnNormal.TextSize = 11.5
	btnNormal.ZIndex = 10
	btnNormal.Parent = container

	local btnWall = Instance.new("TextButton")
	btnWall.Size = UDim2.new(0.5, 0, 1, 0)
	btnWall.Position = UDim2.new(0.5, 0, 0, 0)
	btnWall.BackgroundTransparency = 1
	btnWall.Text = "ล็อคทะลุกำแพง"
	btnWall.TextColor3 = Color3.fromRGB(160, 175, 200)
	btnWall.Font = Enum.Font.GothamMedium
	btnWall.TextSize = 11.5
	btnWall.ZIndex = 10
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

local function createColorPickerRow(labelText, defaultColor, targetType)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
	btn.BackgroundTransparency = 0.2
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.LayoutOrder = nextOrder()
	btn.ZIndex = 8
	btn.Parent = menuScroll

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 9)
	bCorner.Parent = btn

	local bStroke = Instance.new("UIStroke")
	bStroke.Color = Color3.fromRGB(45, 55, 80)
	bStroke.Thickness = 1
	bStroke.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.75, 0, 1, 0)
	lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = Color3.fromRGB(235, 240, 250)
	lbl.Font = Enum.Font.GothamMedium
	lbl.TextSize = 12.5
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 9
	lbl.Parent = btn

	local previewDot = Instance.new("Frame")
	previewDot.Size = UDim2.new(0, 22, 0, 22)
	previewDot.Position = UDim2.new(1, -34, 0.5, -11)
	previewDot.BackgroundColor3 = defaultColor
	previewDot.BorderSizePixel = 0
	previewDot.ZIndex = 9
	previewDot.Parent = btn

	local dCorner = Instance.new("UICorner")
	dCorner.CornerRadius = UDim.new(1, 0)
	dCorner.Parent = previewDot

	local dStroke = Instance.new("UIStroke")
	dStroke.Color = Color3.fromRGB(255, 255, 255)
	dStroke.Thickness = 1.2
	dStroke.Parent = previewDot

	btn.MouseButton1Click:Connect(function()
		openColorPicker(targetType, labelText, mainFrame)
	end)

	return previewDot
end

local function createSlider(labelPrefix, minVal, maxVal, defaultVal, isFloat, callback)
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, 0, 0, 48)
	box.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
	box.BackgroundTransparency = 0.2
	box.LayoutOrder = nextOrder()
	box.ZIndex = 8
	box.Parent = menuScroll

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 9)
	bCorner.Parent = box

	local bStroke = Instance.new("UIStroke")
	bStroke.Color = Color3.fromRGB(45, 55, 80)
	bStroke.Thickness = 1
	bStroke.Parent = box

	local function formatVal(v)
		return isFloat and string.format("%.2f", v) or tostring(math.floor(v))
	end

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -24, 0, 20)
	label.Position = UDim2.new(0, 12, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = labelPrefix .. ": " .. formatVal(defaultVal)
	label.TextColor3 = Color3.fromRGB(235, 240, 250)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 9
	label.Parent = box

	local track = Instance.new("TextButton")
	track.Size = UDim2.new(1, -24, 0, 7)
	track.Position = UDim2.new(0, 12, 0, 30)
	track.BackgroundColor3 = Color3.fromRGB(45, 52, 72)
	track.Text = ""
	track.AutoButtonColor = false
	track.ZIndex = 9
	track.Parent = box

	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(1, 0)
	tCorner.Parent = track

	local initRatio = (defaultVal - minVal) / (maxVal - minVal)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(initRatio, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
	fill.BorderSizePixel = 0
	fill.ZIndex = 10
	fill.Parent = track

	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(1, 0)
	fCorner.Parent = fill

	local dragging = false
	local function updateSlider(input)
		local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local rawVal = minVal + (relX * (maxVal - minVal))
		local finalVal = isFloat and (math.floor(rawVal * 100) / 100) or math.floor(rawVal)
		fill.Size = UDim2.new(relX, 0, 1, 0)
		label.Text = labelPrefix .. ": " .. formatVal(finalVal)
		callback(finalVal)
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

-- ============================================================================
-- 6. จัดวางเมนูทั้งหมดลงในหน้าต่าง ✦ ค่ายM7
-- ============================================================================
createToggle("เปิดใช้งานล็อคเป้า (เป้ากลางจอ)", function(isOn)
	Config.TargetLockEnabled = isOn
	fovCircle.Visible = isOn
end)

createToggle("ไม่ล็อคทีมตัวเอง (Team Check)", function(isOn)
	Config.TeamCheck = isOn
end)

createModeSwitcher()

fovPreviewDot = createColorPickerRow("เลือกสีเป้ากลางจอ (FOV Color)", Config.FOVColor, "FOV")

createSlider("ปรับขนาดเป้ากลางจอ (FOV)", 50, 300, Config.FOVRadius, false, function(val)
	Config.FOVRadius = val
	fovCircle.Size = UDim2.new(0, val * 2, 0, val * 2)
end)

createSlider("ความเร็วในการล็อคเป้า (Lock Speed)", 0.05, 1.00, Config.LockSpeed, true, function(val)
	Config.LockSpeed = val
end)

espPreviewDot = createColorPickerRow("เลือกสี ESP (ESP Color)", Config.ESPColor, "ESP")

createToggle("ESP กรอบสี่เหลี่ยมรอบตัว (Box)", function(isOn)
	Config.BoxESPEnabled = isOn
end)

createToggle("ESP เส้นลากหาผู้เล่น (Tracer Line)", function(isOn)
	Config.TracerESPEnabled = isOn
end)

createToggle("แสดงหลอดเลือดบนหัว (Health Bar)", function(isOn)
	Config.HealthBarEnabled = isOn
end)

createToggle("วิ่งเร็ว (SPEED BOOST)", function(isOn)
	Config.SpeedEnabled = isOn
end)

createToggle("กระโดดสูง (HIGH JUMP)", function(isOn)
	Config.JumpEnabled = isOn
end)

-- ============================================================================
-- 7. ระบบตรวจสอบทีม (Team Check) & ระบบ ESP 2D Overlay (Box + Tracer + HP)
-- ============================================================================
local function isSameTeam(targetPlayer)
	if not Config.TeamCheck then
		return false
	end
	if player.Team ~= nil and targetPlayer.Team ~= nil then
		return player.Team == targetPlayer.Team
	end
	if player.TeamColor ~= nil and targetPlayer.TeamColor ~= nil then
		return player.TeamColor == targetPlayer.TeamColor
	end
	return false
end

local espCache = {}

local function removeESP(targetPlayer)
	local data = espCache[targetPlayer]
	if data then
		if data.Box then data.Box:Destroy() end
		if data.Tracer then data.Tracer:Destroy() end
		if data.HPBg then data.HPBg:Destroy() end
		espCache[targetPlayer] = nil
	end
end

local function getOrCreateESP(targetPlayer)
	if espCache[targetPlayer] then
		return espCache[targetPlayer]
	end

	-- กรอบสี่เหลี่ยม (Box ESP)
	local box = Instance.new("Frame")
	box.Name = randomId()
	box.BackgroundTransparency = 1
	box.Visible = false
	box.ZIndex = 2
	box.Parent = espFolder

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = Config.ESPColor
	boxStroke.Thickness = 1.5
	boxStroke.Parent = box

	-- เส้นลากหาผู้เล่น (Tracer Line)
	local tracer = Instance.new("Frame")
	tracer.Name = randomId()
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BackgroundColor3 = Config.ESPColor
	tracer.BorderSizePixel = 0
	tracer.Visible = false
	tracer.ZIndex = 2
	tracer.Parent = espFolder

	-- หลอดเลือดด้านข้างกรอบ (Health Bar)
	local hpBg = Instance.new("Frame")
	hpBg.Name = randomId()
	hpBg.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
	hpBg.BorderSizePixel = 0
	hpBg.Visible = false
	hpBg.ZIndex = 2
	hpBg.Parent = espFolder

	local hpFill = Instance.new("Frame")
	hpFill.Name = "Fill"
	hpFill.AnchorPoint = Vector2.new(0, 1)
	hpFill.Position = UDim2.new(0, 0, 1, 0)
	hpFill.Size = UDim2.new(1, 0, 1, 0)
	hpFill.BackgroundColor3 = Color3.fromRGB(60, 235, 115)
	hpFill.BorderSizePixel = 0
	hpFill.ZIndex = 3
	hpFill.Parent = hpBg

	espCache[targetPlayer] = {
		Box = box,
		BoxStroke = boxStroke,
		Tracer = tracer,
		HPBg = hpBg,
		HPFill = hpFill
	}
	return espCache[targetPlayer]
end

Players.PlayerRemoving:Connect(removeESP)

-- ============================================================================
-- 8. ระบบตรวจสอบสิ่งกีดขวาง (Raycast) & ล็อคเป้าหมายในระยะ FOV
-- ============================================================================
local function isTargetVisible(targetPart, targetCharacter)
	if not Config.WallCheck then
		return true
	end
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
		if targetPlayer ~= player and not isSameTeam(targetPlayer) and targetPlayer.Character then
			local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
			local targetPart = targetPlayer.Character:FindFirstChild("Head") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")

			if humanoid and humanoid.Health > 0 and targetPart then
				local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
				if onScreen then
					local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
					if distance <= shortestDistance and isTargetVisible(targetPart, targetPlayer.Character) then
						shortestDistance = distance
						closestPart = targetPart
					end
				end
			end
		end
	end

	return closestPart
end

-- ============================================================================
-- 9. ระบบการเคลื่อนที่และประคองความเร็ว (Anti-Rubberband Movement)
-- ============================================================================
local lastSafePos = nil
local isRecovering = false

RunService.Heartbeat:Connect(function(dt)
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local rootPart = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return end

	if isRecovering then
		humanoid.WalkSpeed = NORMAL_SPEED
		return
	end

	humanoid.WalkSpeed = Config.SpeedEnabled and Config.WalkSpeed or NORMAL_SPEED
	humanoid.UseJumpPower = true
	humanoid.JumpPower = Config.JumpEnabled and Config.JumpPower or NORMAL_JUMP

	-- ตรวจจับการดีดกลับ (Rubberband) หากตำแหน่งกระชากผิดปกติ
	if lastSafePos and dt > 0 then
		local horizontalDist = (Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z) - Vector3.new(lastSafePos.X, 0, lastSafePos.Z)).Magnitude
		local speedRate = horizontalDist / dt
		if Config.SpeedEnabled and speedRate > (Config.WalkSpeed * 2.8) then
			isRecovering = true
			humanoid.WalkSpeed = NORMAL_SPEED
			task.delay(0.35, function()
				isRecovering = false
			end)
		end
	end
	lastSafePos = rootPart.Position
end)

-- ============================================================================
-- 10. ลูปหลักอัปเดตสี Rainbow, Target Lock และ ESP แบบเรียลไทม์
-- ============================================================================
RunService.RenderStepped:Connect(function()
	local rainbowColor = Color3.fromHSV((tick() * 0.25) % 1, 0.85, 1)

	-- อัปเดตสี FOV
	local activeFOVColor = Config.FOVRainbow and rainbowColor or Config.FOVColor
	fovStroke.Color = activeFOVColor
	if Config.FOVRainbow and fovPreviewDot then
		fovPreviewDot.BackgroundColor3 = rainbowColor
	end

	-- อัปเดตสี ESP
	local activeESPColor = Config.ESPRainbow and rainbowColor or Config.ESPColor
	if Config.ESPRainbow and espPreviewDot then
		espPreviewDot.BackgroundColor3 = rainbowColor
	end

	-- ระบบล็อคเป้าหมาย
	if Config.TargetLockEnabled then
		local target = getClosestTargetInFOV()
		if target then
			local goalCFrame = CFrame.new(camera.CFrame.Position, target.Position)
			camera.CFrame = camera.CFrame:Lerp(goalCFrame, Config.LockSpeed)
		end
	end

	-- อัปเดตการวาด ESP (Box, Tracer, HealthBar)
	local viewport = camera.ViewportSize
	local tracerOrigin = Vector2.new(viewport.X / 2, viewport.Y)

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			local char = targetPlayer.Character
			local humanoid = char and char:FindFirstChildOfClass("Humanoid")
			local rootPart = char and char:FindFirstChild("HumanoidRootPart")
			local head = char and char:FindFirstChild("Head")

			local anyESPEnabled = Config.BoxESPEnabled or Config.TracerESPEnabled or Config.HealthBarEnabled
			if anyESPEnabled and char and humanoid and humanoid.Health > 0 and rootPart and head then
				local esp = getOrCreateESP(targetPlayer)
				local rootPos, onScreen = camera:WorldToViewportPoint(rootPart.Position)

				if onScreen and rootPos.Z > 0 then
					local headTopPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
					local footPos = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3.0, 0))

					local boxHeight = math.max(math.abs(footPos.Y - headTopPos.Y), 12)
					local boxWidth = boxHeight * 0.62
					local topLeftX = rootPos.X - (boxWidth / 2)
					local topLeftY = headTopPos.Y

					-- สีแยกทีม (หากเปิด Team Check จะแสดงสีเขียวอ่อนสำหรับทีมเดียวกัน)
					local drawColor = isSameTeam(targetPlayer) and Color3.fromRGB(80, 255, 140) or activeESPColor

					-- 1. Box ESP
					if Config.BoxESPEnabled then
						esp.Box.Visible = true
						esp.Box.Position = UDim2.new(0, topLeftX, 0, topLeftY)
						esp.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
						esp.BoxStroke.Color = drawColor
					else
						esp.Box.Visible = false
					end

					-- 2. Tracer Line ESP
					if Config.TracerESPEnabled then
						local targetPoint = Vector2.new(rootPos.X, footPos.Y)
						local diff = targetPoint - tracerOrigin
						local length = diff.Magnitude
						local midPoint = (tracerOrigin + targetPoint) / 2
						local angle = math.deg(math.atan2(diff.Y, diff.X))

						esp.Tracer.Visible = true
						esp.Tracer.Position = UDim2.new(0, midPoint.X, 0, midPoint.Y)
						esp.Tracer.Size = UDim2.new(0, length, 0, 1.5)
						esp.Tracer.Rotation = angle
						esp.Tracer.BackgroundColor3 = drawColor
					else
						esp.Tracer.Visible = false
					end

					-- 3. Health Bar
					if Config.HealthBarEnabled then
						local hpRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
						esp.HPBg.Visible = true
						esp.HPBg.Position = UDim2.new(0, topLeftX - 6, 0, topLeftY)
						esp.HPBg.Size = UDim2.new(0, 3.5, 0, boxHeight)
						esp.HPFill.Size = UDim2.new(1, 0, hpRatio, 0)
						esp.HPFill.BackgroundColor3 = Color3.fromHSV(hpRatio * 0.33, 0.85, 0.95)
					else
						esp.HPBg.Visible = false
					end
				else
					esp.Box.Visible = false
					esp.Tracer.Visible = false
					esp.HPBg.Visible = false
				end
			else
				local esp = espCache[targetPlayer]
				if esp then
					esp.Box.Visible = false
					esp.Tracer.Visible = false
					esp.HPBg.Visible = false
				end
			end
		end
	end
end)
