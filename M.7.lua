CAMP M7 v6.0 — PATCH เพิ่ม GUI เลือกรูปทรง FOV (แสดงผลอย่างเดียว)
=====================================================================

หมายเหตุ:
- ไฟล์นี้เป็นแพตช์สำหรับเพิ่มหน้าต่างเลือกรูปทรง FOV แบบแสดงผลเท่านั้น
- ไม่แก้ระบบค้นหาเป้าหมาย / ล็อกเป้า / ESP เดิม
- รูปทรงที่เลือก: CIRCLE, SQUARE, TRIANGLE
- มีหน้าต่างย่อเป็นปุ่ม M7S และกดปุ่มเพื่อเปิดกลับได้

วิธีใส่:
1) ในสคริปต์เดิม หาแถว `local fovStroke = Instance.new("UIStroke")`
   แล้วเลื่อนลงมาหลังบรรทัด `fovStroke.Parent = fovCircle`
2) วางโค้ดในส่วน [A] ตรงนั้น
3) หาแถว `createPopupTriggerButton("เลือกสีเป้ากลางจอ (FOV Color)", ... )`
   แล้ววางโค้ดส่วน [B] ต่อจากบรรทัดนั้น
4) ใน RenderStepped เดิม ไม่ต้องแก้ระบบล็อกเป้าหรือ ESP
   วางโค้ดส่วน [C] ไว้หลังบรรทัดคำนวณ `rainbowColor`

[A] วางหลัง `fovStroke.Parent = fovCircle`
-----------------------------------------------------

-- FOV Shape Preview: แสดงรูปทรงบนหน้าจอเท่านั้น
local ShapeConfig = {
    Enabled = false,
    Shape = "CIRCLE",
    Size = 120,
    Color = Color3.fromRGB(0, 210, 255)
}

local shapePreview = Instance.new("Frame")
shapePreview.Name = "M7_FOV_Shape_Preview"
shapePreview.AnchorPoint = Vector2.new(0.5, 0.5)
shapePreview.Position = UDim2.new(0.5, 0, 0.5, 0)
shapePreview.Size = UDim2.fromOffset(ShapeConfig.Size * 2, ShapeConfig.Size * 2)
shapePreview.BackgroundTransparency = 1
shapePreview.BorderSizePixel = 0
shapePreview.Visible = false
shapePreview.ZIndex = 8
shapePreview.Parent = screenGui

local shapeCircleCorner = Instance.new("UICorner")
shapeCircleCorner.CornerRadius = UDim.new(1, 0)
shapeCircleCorner.Parent = shapePreview

local shapeStroke = Instance.new("UIStroke")
shapeStroke.Color = ShapeConfig.Color
shapeStroke.Thickness = 1.8
shapeStroke.Transparency = 0.1
shapeStroke.Parent = shapePreview

-- เส้นสามด้านสำหรับรูปสามเหลี่ยม
local triangleLines = {}
for i = 1, 3 do
    local line = Instance.new("Frame")
    line.Name = "TriangleSide" .. i
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Size = UDim2.fromOffset(ShapeConfig.Size * 2, 2)
    line.BackgroundColor3 = ShapeConfig.Color
    line.BorderSizePixel = 0
    line.Visible = false
    line.ZIndex = 9
    line.Parent = screenGui
    table.insert(triangleLines, line)
end

local function updateShapePreview()
    local diameter = ShapeConfig.Size * 2
    shapePreview.Size = UDim2.fromOffset(diameter, diameter)
    shapePreview.Position = UDim2.new(0.5, 0, 0.5, 0)

    local isCircle = ShapeConfig.Shape == "CIRCLE"
    local isSquare = ShapeConfig.Shape == "SQUARE"
    local isTriangle = ShapeConfig.Shape == "TRIANGLE"

    shapePreview.Visible = ShapeConfig.Enabled and (isCircle or isSquare)
    shapeStroke.Enabled = ShapeConfig.Enabled and (isCircle or isSquare)

    if isCircle then
        shapeCircleCorner.CornerRadius = UDim.new(1, 0)
    else
        shapeCircleCorner.CornerRadius = UDim.new(0, 0)
    end

    local center = camera.ViewportSize / 2
    local radius = ShapeConfig.Size
    local vertices = {
        Vector2.new(center.X, center.Y - radius),
        Vector2.new(center.X - radius * 0.866, center.Y + radius * 0.5),
        Vector2.new(center.X + radius * 0.866, center.Y + radius * 0.5)
    }

    for i, line in ipairs(triangleLines) do
        line.Visible = ShapeConfig.Enabled and isTriangle
        line.BackgroundColor3 = ShapeConfig.Color

        if isTriangle then
            local a = vertices[i]
            local b = vertices[(i % 3) + 1]
            local delta = b - a
            local midpoint = (a + b) / 2

            line.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
            line.Size = UDim2.fromOffset(delta.Magnitude, 2)
            line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
        end
    end
end

local function setShapeEnabled(enabled)
    ShapeConfig.Enabled = enabled
    updateShapePreview()
end

local function setShape(shapeName)
    ShapeConfig.Shape = shapeName
    updateShapePreview()
end


[B] วางต่อจากปุ่มเลือกสี FOV เดิม ในส่วนสร้างเมนู
-----------------------------------------------------

-- หน้าต่างตั้งค่ารูปทรง FOV แบบย่อ/ขยายได้
local shapePanel = Instance.new("Frame")
shapePanel.Name = "M7_FOV_Shape_Panel"
shapePanel.Size = UDim2.fromOffset(250, 210)
shapePanel.Position = UDim2.new(0.04, 368, 0.18, 0)
shapePanel.BackgroundColor3 = Color3.fromRGB(16, 19, 30)
shapePanel.BorderSizePixel = 0
shapePanel.Visible = false
shapePanel.Active = true
shapePanel.Draggable = true
shapePanel.ZIndex = 30
shapePanel.Parent = screenGui

local shapePanelCorner = Instance.new("UICorner")
shapePanelCorner.CornerRadius = UDim.new(0, 12)
shapePanelCorner.Parent = shapePanel

local shapePanelStroke = Instance.new("UIStroke")
shapePanelStroke.Color = Color3.fromRGB(0, 195, 255)
shapePanelStroke.Thickness = 1.5
shapePanelStroke.Parent = shapePanel

local shapeHeader = Instance.new("TextLabel")
shapeHeader.Size = UDim2.new(1, -44, 0, 38)
shapeHeader.Position = UDim2.fromOffset(12, 0)
shapeHeader.BackgroundTransparency = 1
shapeHeader.Text = "✦ M7 FOV SHAPE"
shapeHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
shapeHeader.Font = Enum.Font.GothamBold
shapeHeader.TextSize = 13
shapeHeader.TextXAlignment = Enum.TextXAlignment.Left
shapeHeader.ZIndex = 31
shapeHeader.Parent = shapePanel

local shapeMinimize = Instance.new("TextButton")
shapeMinimize.Size = UDim2.fromOffset(28, 26)
shapeMinimize.Position = UDim2.new(1, -34, 0, 6)
shapeMinimize.BackgroundColor3 = Color3.fromRGB(35, 42, 62)
shapeMinimize.Text = "_"
shapeMinimize.TextColor3 = Color3.fromRGB(255, 255, 255)
shapeMinimize.Font = Enum.Font.GothamBold
shapeMinimize.TextSize = 16
shapeMinimize.ZIndex = 32
shapeMinimize.Parent = shapePanel

local shapeMiniButton = Instance.new("TextButton")
shapeMiniButton.Name = "M7_FOV_Shape_Mini"
shapeMiniButton.Size = UDim2.fromOffset(58, 58)
shapeMiniButton.Position = UDim2.new(0.04, 0, 0.32, 0)
shapeMiniButton.BackgroundColor3 = Color3.fromRGB(13, 17, 29)
shapeMiniButton.Text = "M7S"
shapeMiniButton.TextColor3 = Color3.fromRGB(0, 225, 255)
shapeMiniButton.Font = Enum.Font.GothamBlack
shapeMiniButton.TextSize = 16
shapeMiniButton.Visible = false
shapeMiniButton.Active = true
shapeMiniButton.Draggable = true
shapeMiniButton.ZIndex = 40
shapeMiniButton.Parent = screenGui

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(1, 0)
miniCorner.Parent = shapeMiniButton

local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(0, 205, 255)
miniStroke.Thickness = 2
miniStroke.Parent = shapeMiniButton

local function makeShapeButton(textValue, xScale, shapeName)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.30, 0, 0, 38)
    button.Position = UDim2.new(xScale, 0, 0, 52)
    button.BackgroundColor3 = ShapeConfig.Shape == shapeName
        and Color3.fromRGB(0, 145, 220)
        or Color3.fromRGB(35, 42, 62)
    button.Text = textValue
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.ZIndex = 32
    button.Parent = shapePanel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        setShape(shapeName)
        for _, child in ipairs(shapePanel:GetChildren()) do
            if child:IsA("TextButton") and child ~= shapeMinimize then
                child.BackgroundColor3 = Color3.fromRGB(35, 42, 62)
            end
        end
        button.BackgroundColor3 = Color3.fromRGB(0, 145, 220)
    end)
end

makeShapeButton("วงกลม", 0.04, "CIRCLE")
makeShapeButton("สี่เหลี่ยม", 0.35, "SQUARE")
makeShapeButton("สามเหลี่ยม", 0.66, "TRIANGLE")

local shapeToggle = Instance.new("TextButton")
shapeToggle.Size = UDim2.new(1, -20, 0, 34)
shapeToggle.Position = UDim2.fromOffset(10, 102)
shapeToggle.BackgroundColor3 = Color3.fromRGB(50, 56, 74)
shapeToggle.Text = "แสดงรูปทรง: ปิด"
shapeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
shapeToggle.Font = Enum.Font.GothamBold
shapeToggle.TextSize = 12
shapeToggle.ZIndex = 32
shapeToggle.Parent = shapePanel

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = shapeToggle

shapeToggle.MouseButton1Click:Connect(function()
    setShapeEnabled(not ShapeConfig.Enabled)
    shapeToggle.Text = ShapeConfig.Enabled and "แสดงรูปทรง: เปิด" or "แสดงรูปทรง: ปิด"
    shapeToggle.BackgroundColor3 = ShapeConfig.Enabled
        and Color3.fromRGB(0, 150, 105)
        or Color3.fromRGB(50, 56, 74)
end)

local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(1, -20, 0, 20)
sizeLabel.Position = UDim2.fromOffset(10, 144)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = "ขนาดรูปทรง: " .. tostring(ShapeConfig.Size)
sizeLabel.TextColor3 = Color3.fromRGB(235, 240, 250)
sizeLabel.Font = Enum.Font.GothamMedium
sizeLabel.TextSize = 11
sizeLabel.TextXAlignment = Enum.TextXAlignment.Left
sizeLabel.ZIndex = 32
sizeLabel.Parent = shapePanel

local sizeTrack = Instance.new("TextButton")
sizeTrack.Size = UDim2.new(1, -20, 0, 8)
sizeTrack.Position = UDim2.fromOffset(10, 174)
sizeTrack.BackgroundColor3 = Color3.fromRGB(45, 52, 72)
sizeTrack.Text = ""
sizeTrack.AutoButtonColor = false
sizeTrack.ZIndex = 32
sizeTrack.Parent = shapePanel

local sizeFill = Instance.new("Frame")
sizeFill.Size = UDim2.new((ShapeConfig.Size - 50) / 250, 0, 1, 0)
sizeFill.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
sizeFill.BorderSizePixel = 0
sizeFill.ZIndex = 33
sizeFill.Parent = sizeTrack

local sizeFillCorner = Instance.new("UICorner")
sizeFillCorner.CornerRadius = UDim.new(1, 0)
sizeFillCorner.Parent = sizeFill

local sizeDragging = false
local function updateShapeSize(input)
    local width = math.max(sizeTrack.AbsoluteSize.X, 1)
    local alpha = math.clamp(
        (input.Position.X - sizeTrack.AbsolutePosition.X) / width,
        0, 1
    )
    ShapeConfig.Size = math.floor(50 + alpha * 250 + 0.5)
    sizeFill.Size = UDim2.new(alpha, 0, 1, 0)
    sizeLabel.Text = "ขนาดรูปทรง: " .. tostring(ShapeConfig.Size)
    updateShapePreview()
end

sizeTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        sizeDragging = true
        updateShapeSize(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sizeDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateShapeSize(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        sizeDragging = false
    end
end)

shapeMinimize.MouseButton1Click:Connect(function()
    shapeMiniButton.Position = shapePanel.Position
    shapePanel.Visible = false
    shapeMiniButton.Visible = true
end)

shapeMiniButton.MouseButton1Click:Connect(function()
    shapePanel.Position = shapeMiniButton.Position
    shapeMiniButton.Visible = false
    shapePanel.Visible = true
end)

[C] วางใน RenderStepped หลังบรรทัดคำนวณ rainbowColor
-----------------------------------------------------

updateShapePreview()

-- อัปเดตสีตามสี FOV ที่ตั้งไว้เดิม
ShapeConfig.Color = Config.FOVRainbow
    and rainbowColor
    or Config.FOVColor

shapeStroke.Color = ShapeConfig.Color
for _, line in ipairs(triangleLines) do
    line.BackgroundColor3 = ShapeConfig.Color
end


ปุ่มเปิดหน้าต่างจากเมนูหลัก
-----------------------------------------------------

วางโค้ดนี้ในส่วนสร้างเมนู (Section 8) ต่อจากปุ่มเลือกสี FOV เดิม
โดยต้องวางหลังจากประกาศฟังก์ชัน `nextOrder()` และหลังจากสร้าง helper UI แล้ว:

local shapeOpenButton = Instance.new("TextButton")
shapeOpenButton.Size = UDim2.new(1, -24, 0, 42)
shapeOpenButton.BackgroundColor3 = Color3.fromRGB(26, 32, 48)
shapeOpenButton.Text = "ตั้งค่ารูปทรง FOV  ▸"
shapeOpenButton.TextColor3 = Color3.fromRGB(235, 240, 250)
shapeOpenButton.Font = Enum.Font.GothamMedium
shapeOpenButton.TextSize = 12
shapeOpenButton.LayoutOrder = nextOrder()
shapeOpenButton.ZIndex = 3
shapeOpenButton.Parent = scrollContainer

local shapeOpenCorner = Instance.new("UICorner")
shapeOpenCorner.CornerRadius = UDim.new(0, 10)
shapeOpenCorner.Parent = shapeOpenButton

shapeOpenButton.MouseButton1Click:Connect(function()
    shapePanel.Position = UDim2.new(
        mainFrame.Position.X.Scale,
        mainFrame.Position.X.Offset + mainFrame.AbsoluteSize.X + 12,
        mainFrame.Position.Y.Scale,
        mainFrame.Position.Y.Offset
    )
    shapePanel.Visible = not shapePanel.Visible
end)

หมายเหตุการใช้งาน:
- เลือกวงกลม/สี่เหลี่ยม/สามเหลี่ยมได้จากหน้าต่าง M7 FOV SHAPE
- กด "แสดงรูปทรง" เพื่อเปิดหรือปิดเส้นแสดงผล
- ลากแถบขนาดเพื่อปรับขนาด
- กด "_" เพื่อย่อเป็นปุ่ม M7S และกด M7S เพื่อเปิดกลับ
- เป็นเส้นแสดงผลอิสระ ไม่เปลี่ยนการคำนวณเป้าหมายเดิม
