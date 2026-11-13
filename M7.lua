-- ============================================================================
-- ระบบ ✦ ค่ายM7 (CampM7 Full System v4 - Studio Edition)
-- วิธีติดตั้ง: นำโค้ดนี้ไปใส่ใน LocalScript ภายใต้ StarterPlayer -> StarterPlayerScripts
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

-- ฟังก์ชันสร้างชื่อแบบสุ่มเพื่อความเป็นระเบียบและลดการชนกันของชื่อ Instance ในเกม
local function randomId()
	return HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 10)
end

-- ==========================================
-- ตั้งค่าระบบเริ่มต้น (Config)
-- ==========================================
local Config = {
	TargetLockEnabled = false,
	WallCheck = true,          -- true = ไม่ล็อคทะลุกำแพง, false = ล็อคทะลุกำแพงได้
	LockSpeed = 0.45,          -- ความเร็วในการหันกล้อง (0.05 - 1.00)
	FOVRadius = 120,           -- ขนาดรัศมีวงกลม FOV (50 - 300)
	FOVColorMode = "Cyan",     -- โหมดสีของ FOV
	FOVCustomColor = Color3.fromRGB(0, 210, 255),
	BoxESPEnabled = false,
	TracerESPEnabled = false,
	HealthBarEnabled = false,
	SpeedEnabled = false,
	JumpEnabled = false,
	WalkSpeed = 32,
	JumpPower = 85,
	AntiRubberband = true      -- ระบบช่วยประคอง/คืนค่าเมื่อความเร็วหรือการกระโดดผิดปกติ
}

local NORMAL_SPEED = 16
local NORMAL_JUMP = 50

-- ชุดสีสำหรับเลือกวงกลม FOV
local ColorPresets = {
	{Name = "สีรุ้ง (Rainbow)", Mode = "Rainbow", Color = Color3.fromRGB(255, 0, 128)},
	{Name = "ฟ้าไซอัน (Cyan)", Mode = "Static", Color = Color3.fromRGB(0, 210, 255)},
	{Name = "แดงเพลิง (Red)", Mode = "Static", Color = Color3.fromRGB(255, 55, 75)},
	{Name = "เขียวนีออน (Green)", Mode = "Static", Color = Color3.fromRGB(50, 240, 120)},
	{Name = "เหลืองทอง (Gold)", Mode = "Static", Color = Color3.fromRGB(255, 200, 45)},
	{Name = "ม่วงอวกาศ (Purple)", Mode = "Static", Color = Color3.fromRGB(175, 85, 255)},
	{Name = "ขาวบริสุทธิ์ (White)", Mode = "Static", Color = Color3.fromRGB(255, 255, 255)},
	{Name = "ชมพูสว่าง (Pink)", Mode = "Static", Color = Color3.fromRGB(255, 105, 210)}
}

-- ==========================================
-- 1. สร้าง ScreenGui และ Layer สำหรับ ESP 2D
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UI_" .. randomId()
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local espFolder = Instance.new("Folder")
espFolder.Name = "Layer_" .. randomId()
espFolder.Parent = screenGui

-- วงกลมเป้ากลางจอ (FOV Circle)
local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOV_" .. randomId()
fovCircle.Size = UDim2.new(0, Config.FOVRadius * 2, 0, Config.FOVRadius * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.ZIndex = 2
fovCircle.Parent = screenGui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Config.FOVCustomColor
fovStroke.Thickness = 1.8
fovStroke.Transparency = 0.15
fovStroke.Parent = fovCircle

-- ==========================================
-- 2. ปุ่มโลโก้ N7 (แสดงเมื่อกดซ่อนหน้าต่างหลัก)
-- ==========================================
local n7Button = Instance.new("TextButton")
n7Button.Name = "Btn_" .. randomId()
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

-- ==========================================
-- 3. หน้าต่างเมนูหลัก (✦ ค่ายM7) + ระบบเลื่อน (ScrollingFrame)
-- ==========================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main_" .. randomId()
mainFrame.Size = UDim2.new(0, 350, 0, 460)
mainFrame.Position = UDim2.new(0.05, 0, 0.22, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.ZIndex = 10
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
	star.ZIndex = 11
	
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
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(22, 26, 40)
header.BackgroundTransparency = 0.25
header.BorderSizePixel = 0
header.ZIndex = 12
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.75, 0, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✦ ค่ายM7  |  PRO STUDIO"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 13
title.Parent = header

-- ปุ่มย่อหน้าต่าง (-)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -38, 0.5, -15)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 42, 62)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.ZIndex = 13
minimizeBtn.Parent = header

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeBtn

-- พื้นที่เลื่อนเมนูด้านใน (ScrollingFrame)
local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Size = UDim2.new(1, -12, 1, -54)
contentScroll.Position = UDim2.new(0, 6, 0, 48)
contentScroll.BackgroundTransparency = 1
contentScroll.BorderSizePixel = 0
contentScroll.ScrollBarThickness = 4
contentScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 585)
contentScroll.ZIndex = 12
contentScroll.Parent = mainFrame

-- ==========================================
-- 4. หน้าต่างป๊อปอัปเลือกสี FOV (Color Picker Popup GUI)
-- ==========================================
local colorPopup = Instance.new("Frame")
colorPopup.Name = "ColorPopup_" .. randomId()
colorPopup.Size = UDim2.new(0, 260, 0, 275)
colorPopup.Position = UDim2.new(0.35, 0, 0.25, 0)
colorPopup.BackgroundColor3 = Color3.fromRGB(18, 21, 33)
colorPopup.BorderSizePixel = 0
colorPopup.Visible = false
colorPopup.Active = true
colorPopup.Draggable = true
colorPopup.ZIndex = 30
colorPopup.Parent = screenGui

local popupCorner = Instance.new("UICorner")
popupCorner.CornerRadius = UDim.new(0, 12)
popupCorner.Parent = colorPopup

local popupStroke = Instance.new("UIStroke")
popupStroke.Color = Color3.fromRGB(0, 200, 255)
popupStroke.Thickness = 1.5
popupStroke.Parent = colorPopup

local popupHeader = Instance.new("Frame")
popupHeader.Size = UDim2.new(1, 0, 0, 38)
popupHeader.BackgroundColor3 = Color3.fromRGB(26, 30, 46)
popupHeader.BorderSizePixel = 0
popupHeader.ZIndex = 31
popupHeader.Parent = colorPopup

local popupHeaderCorner = Instance.new("UICorner")
popupHeaderCorner.CornerRadius = UDim.new(0, 12)
popupHeaderCorner.Parent = popupHeader

local popupTitle = Instance.new("TextLabel")
popupTitle.Size = UDim2.new(0.8, 0, 1, 0)
popupTitle.Position = UDim2.new(0, 12, 0, 0)
popupTitle.BackgroundTransparency = 1
popupTitle.Text = "🎨 เลือกสีวงกลม FOV"
popupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
popupTitle.Font = Enum.Font.GothamBold
popupTitle.TextSize = 13
popupTitle.TextXAlignment = Enum.TextXAlignment.Left
popupTitle.ZIndex = 32
popupTitle.Parent = popupHeader

local closePopupBtn = Instance.new("TextButton")
closePopupBtn.Size = UDim2.new(0, 26, 0, 26)
closePopupBtn.Position = UDim2.new(1, -32, 0.5, -13)
closePopupBtn.BackgroundColor3 = Color3.fromRGB(200, 55, 75)
closePopupBtn.Text = "X"
closePopupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closePopupBtn.Font = Enum.Font.GothamBold
closePopupBtn.TextSize = 13
closePopupBtn.ZIndex = 32
closePopupBtn.Parent = popupHeader

local closePopupCorner = Instance.new("UICorner")
closePopupCorner.CornerRadius = UDim.new(0, 6)
closePopupCorner.Parent = closePopupBtn

closePopupBtn.MouseButton1Click:Connect(function()
	colorPopup.Visible = false
end)

-- สร้างรายการสีให้กดเลือกในป๊อปอัป
local currentColorBadge = nil

for idx, preset in ipairs(ColorPresets) do
	local rowBtn = Instance.new("TextButton")
	rowBtn.Size = UDim2.new(1, -20, 0, 24)
	rowBtn.Position = UDim2.new(0, 10, 0, 42 + ((idx - 1) * 28))
	rowBtn.BackgroundColor3 = Color3.fromRGB(28, 33, 50)
	rowBtn.Text = ""
	rowBtn.AutoButtonColor = true
	rowBtn.ZIndex = 31
	rowBtn.Parent = colorPopup

	local rbCorner = Instance.new("UICorner")
	rbCorner.CornerRadius = UDim.new(0, 6)
	rbCorner.Parent = rowBtn

	local colorDot = Instance.new("Frame")
	colorDot.Size = UDim2.new(0, 14, 0, 14)
	colorDot.Position = UDim2.new(0, 8, 0.5, -7)
	colorDot.BackgroundColor3 = preset.Color
	colorDot.BorderSizePixel = 0
	colorDot.ZIndex = 32
	colorDot.Parent = rowBtn

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = colorDot

	if preset.Mode == "Rainbow" then
		local rbGrad = Instance.new("UIGradient")
		rbGrad.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 100)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 120, 255))
		}
		rbGrad.Parent = colorDot
	end

	local cLabel = Instance.new("TextLabel")
	cLabel.Size = UDim2.new(1, -32, 1, 0)
	cLabel.Position = UDim2.new(0, 28, 0, 0)
	cLabel.BackgroundTransparency = 1
	cLabel.Text = preset.Name
	cLabel.TextColor3 = Color3.fromRGB(235, 240, 250)
	cLabel.Font = Enum.Font.GothamMedium
	cLabel.TextSize = 12
	cLabel.TextXAlignment = Enum.TextXAlignment.Left
	cLabel.ZIndex = 32
	cLabel.Parent = rowBtn

	rowBtn.MouseButton1Click:Connect(function()
		Config.FOVColorMode = preset.Mode
		Config.FOVCustomColor = preset.Color
		if preset.Mode == "Static" then
			fovStroke.Color = preset.Color
		end
		if currentColorBadge then
			currentColorBadge.BackgroundColor3 = preset.Color
		end
	end)
end

-- การทำงานของปุ่มซ่อน UI และปุ่มโลโก้ N7
minimizeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	colorPopup.Visible = false
	n7Button.Position = mainFrame.Position
	n7Button.Visible = true
end)

n7Button.MouseButton1Click:Connect(function()
	n7Button.Visible = false
	mainFrame.Position = n7Button.Position
	mainFrame.Visible = true
end)

-- ==========================================
-- 5. ฟังก์ชันสร้างส่วนประกอบ UI (Toggle, Switch, Slider, ColorButton)
-- ==========================================
local function createToggle(labelText, posY, defaultState, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -16, 0, 42)
	row.Position = UDim2.new(0, 8, 0, posY)
	row.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
	row.BackgroundTransparency = 0.2
	row.ZIndex = 12
	row.Parent = contentScroll

	local rCorner = Instance.new("UICorner")
	rCorner.CornerRadius = UDim.new(0, 10)
	rCorner.Parent = row

	local rStroke = Instance.new("UIStroke")
	rStroke.Color = Color3.fromRGB(45, 55, 80)
	rStroke.Thickness = 1
	rStroke.Parent = row

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(0.72, 0, 1, 0)
	text.Position = UDim2.new(0, 12, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = labelText
	text.TextColor3 = Color3.fromRGB(235, 240, 250)
	text.Font = Enum.Font.GothamMedium
	text.TextSize = 13
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.ZIndex = 13
	text.Parent = row

	local switchBtn = Instance.new("TextButton")
	switchBtn.Size = UDim2.new(0, 44, 0, 22)
	switchBtn.Position = UDim2.new(1, -54, 0.5, -11)
	switchBtn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 56, 74)
	switchBtn.Text = ""
	switchBtn.AutoButtonColor = false
	switchBtn.ZIndex = 13
	switchBtn.Parent = row

	local swCorner = Instance.new("UICorner")
	swCorner.CornerRadius = UDim.new(1, 0)
	swCorner.Parent = switchBtn

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.ZIndex = 14
	knob.Parent = switchBtn

	local kCorner = Instance.new("UICorner")
	kCorner.CornerRadius = UDim.new(1, 0)
	kCorner.Parent = knob

	local state = defaultState or false
	switchBtn.MouseButton1Click:Connect(function()
		state = not state
		local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		local targetColor = state and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(50, 56, 74)

		TweenService:Create(knob, TweenInfo.new(0.18), {Position = targetPos}):Play()
		TweenService:Create(switchBtn, TweenInfo.new(0.18), {BackgroundColor3 = targetColor}):Play()
		callback(state)
	end)
end

local function createModeSwitcher(posY)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -16, 0, 44)
	container.Position = UDim2.new(0, 8, 0, posY)
	container.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
	container.ZIndex = 12
	container.Parent = contentScroll

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
	indicator.ZIndex = 13
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
	btnNormal.TextSize = 12
	btnNormal.ZIndex = 14
	btnNormal.Parent = container

	local btnWall = Instance.new("TextButton")
	btnWall.Size = UDim2.new(0.5, 0, 1, 0)
	btnWall.Position = UDim2.new(0.5, 0, 0, 0)
	btnWall.BackgroundTransparency = 1
	btnWall.Text = "ล็อคทะลุกำแพง"
	btnWall.TextColor3 = Color3.fromRGB(160, 175, 200)
	btnWall.Font = Enum.Font.GothamMedium
	btnWall.TextSize = 12
	btnWall.ZIndex = 14
	btnWall.Parent = container

	btnNormal.MouseButton1Click:Connect(function()
		Config.WallCheck = true
		TweenService:Create(indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
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
		TweenService:Create(indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Position = UDim2.new(0.505, 0, 0, 4),
			BackgroundColor3 = Color3.fromRGB(220, 65, 95)
		}):Play()
		btnWall.TextColor3 = Color3.fromRGB(255, 255, 255)
		btnWall.Font = Enum.Font.GothamBold
		btnNormal.TextColor3 = Color3.fromRGB(160, 175, 200)
		btnNormal.Font = Enum.Font.GothamMedium
	end)
end

local function createSlider(titleText, posY, minVal, maxVal, defaultVal, isFloat, onChange)
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, -16, 0, 52)
	box.Position = UDim2.new(0, 8, 0, posY)
	box.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
	box.BackgroundTransparency = 0.2
	box.ZIndex = 12
	box.Parent = contentScroll

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 10)
	bCorner.Parent = box

	local bStroke = Instance.new("UIStroke")
	bStroke.Color = Color3.fromRGB(45, 55, 80)
	bStroke.Thickness = 1
	bStroke.Parent = box

	local function formatValue(v)
		if isFloat then
			return string.format("%.2f", v)
		end
		return tostring(math.floor(v))
	end

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -24, 0, 22)
	label.Position = UDim2.new(0, 12, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = titleText .. ": " .. formatValue(defaultVal)
	label.TextColor3 = Color3.fromRGB(235, 240, 250)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 13
	label.Parent = box

	local track = Instance.new("TextButton")
	track.Size = UDim2.new(1, -24, 0, 8)
	track.Position = UDim2.new(0, 12, 0, 33)
	track.BackgroundColor3 = Color3.fromRGB(45, 52, 72)
	track.Text = ""
	track.AutoButtonColor = false
	track.ZIndex = 13
	track.Parent = box

	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(1, 0)
	tCorner.Parent = track

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
	fill.BorderSizePixel = 0
	fill.ZIndex = 14
	fill.Parent = track

	local fCorner = Instance.new("UICorner")
	fCorner.CornerRadius = UDim.new(1, 0)
	fCorner.Parent = fill

	local dragging = false
	local function updateSlider(input)
		local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local rawVal = minVal + (relativeX * (maxVal - minVal))
		local finalVal = isFloat and (math.floor(rawVal * 100) / 100) or math.floor(rawVal)
		fill.Size = UDim2.new(relativeX, 0, 1, 0)
		label.Text = titleText .. ": " .. formatValue(finalVal)
		onChange(finalVal)
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

local function createColorPickerTrigger(posY)
	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, -16, 0, 42)
	row.Position = UDim2.new(0, 8, 0, posY)
	row.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
	row.BackgroundTransparency = 0.2
	row.Text = ""
	row.AutoButtonColor = true
	row.ZIndex = 12
	row.Parent = contentScroll

	local rCorner = Instance.new("UICorner")
	rCorner.CornerRadius = UDim.new(0, 10)
	rCorner.Parent = row

	local rStroke = Instance.new("UIStroke")
	rStroke.Color = Color3.fromRGB(45, 55, 80)
	rStroke.Thickness = 1
	rStroke.Parent = row

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(0.75, 0, 1, 0)
	text.Position = UDim2.new(0, 12, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = "เลือกสีเป้ากลางจอ (FOV Color)"
	text.TextColor3 = Color3.fromRGB(235, 240, 250)
	text.Font = Enum.Font.GothamMedium
	text.TextSize = 13
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.ZIndex = 13
	text.Parent = row

	local badge = Instance.new("Frame")
	badge.Size = UDim2.new(0, 34, 0, 20)
	badge.Position = UDim2.new(1, -46, 0.5, -10)
	badge.BackgroundColor3 = Config.FOVCustomColor
	badge.ZIndex = 13
	badge.Parent = row

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 6)
	bCorner.Parent = badge

	currentColorBadge = badge

	row.MouseButton1Click:Connect(function()
		colorPopup.Visible = not colorPopup.Visible
		if colorPopup.Visible then
			colorPopup.Position = UDim2.new(0, mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X + 12, 0, mainFrame.AbsolutePosition.Y + 40)
		end
	end)
end

-- ==========================================
-- 6. ระบบเคลื่อนที่ + ระบบป้องกันดีดกลับ / คืนค่าอัตโนมัติ (Anti-Rubberband)
-- ==========================================
local lastSafePosition = nil
local lastSafeTime = tick()

local function getHumanoid()
	local character = player.Character
	if not character then return nil end
	return character:FindFirstChildOfClass("Humanoid")
end

local function updateMovement()
	local humanoid = getHumanoid()
	if not humanoid then return end

	humanoid.WalkSpeed = Config.SpeedEnabled and Config.WalkSpeed or NORMAL_SPEED
	humanoid.UseJumpPower = true
	humanoid.JumpPower = Config.JumpEnabled and Config.JumpPower or NORMAL_JUMP
end

-- ตรวจสอบและช่วยประคองเมื่อตัวละครเกิดการเด้งกลับหรือความเร็ว/ความสูงหลุดขอบเขต
RunService.Heartbeat:Connect(function()
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not humanoid or humanoid.Health <= 0 then return end

	if Config.AntiRubberband then
		local currentPos = hrp.Position
		if lastSafePosition then
			local displacement = (currentPos - lastSafePosition).Magnitude
			local elapsed = tick() - lastSafeTime

			-- หากเกิดการดีดกลับ (Rubberband) อย่างรุนแรงหรือหลุดความสูงผิดปกติ ให้รีเซ็ตความเร็วกลับค่ามาตรฐานชั่วคราวเพื่อให้ตัวละครทรงตัวได้
			if elapsed > 0 and (displacement / elapsed) > 160 then
				hrp.AssemblyLinearVelocity = Vector3.zero
				humanoid.WalkSpeed = NORMAL_SPEED
				humanoid.JumpPower = NORMAL_JUMP
				task.delay(0.35, function()
					updateMovement()
				end)
			else
				lastSafePosition = currentPos
				lastSafeTime = tick()
			end
		else
			lastSafePosition = currentPos
			lastSafeTime = tick()
		end
	end
end)

player.CharacterAdded:Connect(function(character)
	lastSafePosition = nil
	character:WaitForChild("Humanoid")
	task.wait(0.2)
	updateMovement()
end)

-- ==========================================
-- 7. ระบบ ESP (2D Box, Tracer Line, Health Bar)
-- ==========================================
local ESPCache = {}

local function createPlayerESP(targetPlayer)
	if targetPlayer == player or ESPCache[targetPlayer] then return end

	local boxFrame = Instance.new("Frame")
	boxFrame.BackgroundTransparency = 1
	boxFrame.Visible = false
	boxFrame.ZIndex = 3
	boxFrame.Parent = espFolder

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = Color3.fromRGB(0, 220, 255)
	boxStroke.Thickness = 1.6
	boxStroke.Parent = boxFrame

	local tracerLine = Instance.new("Frame")
	tracerLine.AnchorPoint = Vector2.new(0.5, 0.5)
	tracerLine.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
	tracerLine.BorderSizePixel = 0
	tracerLine.Visible = false
	tracerLine.ZIndex = 3
	tracerLine.Parent = espFolder

	ESPCache[targetPlayer] = {
		Box = boxFrame,
		Tracer = tracerLine
	}
end

local function removePlayerESP(targetPlayer)
	local data = ESPCache[targetPlayer]
	if data then
		if data.Box then data.Box:Destroy() end
		if data.Tracer then data.Tracer:Destroy() end
		ESPCache[targetPlayer] = nil
	end
end

for _, p in ipairs(Players:GetPlayers()) do createPlayerESP(p) end
Players.PlayerAdded:Connect(createPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

local function updateESPAndVisuals()
	local viewportSize = camera.ViewportSize
	local screenBottomCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y)

	for targetPlayer, data in pairs(ESPCache) do
		local char = targetPlayer.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local head = char and char:FindFirstChild("Head")

		if char and humanoid and humanoid.Health > 0 and hrp and head then
			local rootPos, onScreen = camera:WorldToViewportPoint(hrp.Position)

			if onScreen and rootPos.Z > 0 then
				local topPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.8, 0))
				local bottomPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.8, 0))
				local height = math.abs(bottomPos.Y - topPos.Y)
				local width = height * 0.6

				if Config.BoxESPEnabled then
					data.Box.Size = UDim2.new(0, width, 0, height)
					data.Box.Position = UDim2.new(0, rootPos.X - (width / 2), 0, topPos.Y)
					data.Box.Visible = true
				else
					data.Box.Visible = false
				end

				if Config.TracerESPEnabled then
					local targetPoint = Vector2.new(rootPos.X, bottomPos.Y)
					local distance = (targetPoint - screenBottomCenter).Magnitude
					local midPoint = (screenBottomCenter + targetPoint) / 2
					local angle = math.deg(math.atan2(targetPoint.Y - screenBottomCenter.Y, targetPoint.X - screenBottomCenter.X))

					data.Tracer.Size = UDim2.new(0, distance, 0, 1.5)
					data.Tracer.Position = UDim2.new(0, midPoint.X, 0, midPoint.Y)
					data.Tracer.Rotation = angle
					data.Tracer.Visible = true
				else
					data.Tracer.Visible = false
				end
			else
				data.Box.Visible = false
				data.Tracer.Visible = false
			end

			-- หลอดเลือดบนหัว
			local hpGui = head:FindFirstChild("M7_HealthBar")
			if Config.HealthBarEnabled then
				if not hpGui then
					hpGui = Instance.new("BillboardGui")
					hpGui.Name = "M7_HealthBar"
					hpGui.Size = UDim2.new(0, 60, 0, 8)
					hpGui.StudsOffset = Vector3.new(0, 2.2, 0)
					hpGui.AlwaysOnTop = true
					hpGui.Parent = head

					local bg = Instance.new("Frame")
					bg.Name = "BG"
					bg.Size = UDim2.new(1, 0, 1, 0)
					bg.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
					bg.BorderSizePixel = 0
					bg.Parent = hpGui

					local bgCorner = Instance.new("UICorner")
					bgCorner.CornerRadius = UDim.new(1, 0)
					bgCorner.Parent = bg

					local bar = Instance.new("Frame")
					bar.Name = "Bar"
					bar.Size = UDim2.new(1, 0, 1, 0)
					bar.BackgroundColor3 = Color3.fromRGB(60, 235, 115)
					bar.BorderSizePixel = 0
					bar.Parent = bg

					local barCorner = Instance.new("UICorner")
					barCorner.CornerRadius = UDim.new(1, 0)
					barCorner.Parent = bar
				end

				local bar = hpGui.BG:FindFirstChild("Bar")
				if bar then
					local hpRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
					bar.Size = UDim2.new(hpRatio, 0, 1, 0)
					bar.BackgroundColor3 = Color3.fromHSV(hpRatio * 0.33, 0.85, 0.95)
				end
			elseif hpGui then
				hpGui:Destroy()
			end
		else
			data.Box.Visible = false
			data.Tracer.Visible = false
		end
	end
end

-- ==========================================
-- 8. ระบบล็อคเป้าในระยะ FOV + Rainbow Color Loop
-- ==========================================
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
		if targetPlayer ~= player and targetPlayer.Character then
			local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
			local targetPart = targetPlayer.Character:FindFirstChild("Head") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid.Health > 0 and targetPart then
				local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
				if onScreen and screenPos.Z > 0 then
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

local rainbowHue = 0
RunService.RenderStepped:Connect(function(dt)
	-- อัปเดตสี Rainbow สำหรับวงกลม FOV
	if Config.FOVColorMode == "Rainbow" then
		rainbowHue = (rainbowHue + (dt * 0.5)) % 1
		local rbColor = Color3.fromHSV(rainbowHue, 0.9, 1)
		fovStroke.Color = rbColor
		if currentColorBadge then
			currentColorBadge.BackgroundColor3 = rbColor
		end
	end

	-- ระบบล็อคเป้า
	if Config.TargetLockEnabled then
		local target = getClosestTargetInFOV()
		if target then
			local targetCFrame = CFrame.new(camera.CFrame.Position, target.Position)
			camera.CFrame = camera.CFrame:Lerp(targetCFrame, Config.LockSpeed)
		end
	end

	updateESPAndVisuals()
end)

-- ==========================================
-- 9. จัดเรียงเมนูทั้งหมดลงในหน้าต่าง ✦ ค่ายM7
-- ==========================================
createToggle("เปิดใช้งานล็อคเป้า (เป้ากลางจอ)", 4, false, function(isOn)
	Config.TargetLockEnabled = isOn
	fovCircle.Visible = isOn
end)

createModeSwitcher(52)

createSlider("ความเร็วในการล็อคเป้า (Lock Speed)", 102, 0.05, 1.00, Config.LockSpeed, true, function(val)
	Config.LockSpeed = val
end)

createSlider("ขนาดเป้ากลางจอ (FOV Radius)", 160, 50, 300, Config.FOVRadius, false, function(val)
	Config.FOVRadius = val
	fovCircle.Size = UDim2.new(0, val * 2, 0, val * 2)
end)

createColorPickerTrigger(218)

createToggle("ESP กรอบสี่เหลี่ยมรอบตัว (Box)", 266, false, function(isOn)
	Config.BoxESPEnabled = isOn
end)

createToggle("ESP เส้นลากหาผู้เล่น (Tracer)", 314, false, function(isOn)
	Config.TracerESPEnabled = isOn
end)

createToggle("แสดงหลอดเลือดบนหัว (Health Bar)", 362, false, function(isOn)
	Config.HealthBarEnabled = isOn
end)

createToggle("วิ่งเร็ว (SPEED BOOST)", 410, false, function(isOn)
	Config.SpeedEnabled = isOn
	updateMovement()
end)

createToggle("กระโดดสูง (HIGH JUMP)", 458, false, function(isOn)
	Config.JumpEnabled = isOn
	updateMovement()
end)

createToggle("ระบบประคอง/คืนค่าเมื่อความเร็วผิดปกติ", 506, true, function(isOn)
	Config.AntiRubberband = isOn
end)
