-- Complete Functional Executor UI Framework
-- Opens directly to Main Tab on execution

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Safely Parent ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomUI_" .. math.random(1000, 9999)
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
	ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
	syn.protect_gui(ScreenGui)
	ScreenGui.Parent = CoreGui
else
	pcall(function() ScreenGui.Parent = CoreGui end)
	if not ScreenGui.Parent then
		ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end
end

-- Theme Palette
local COLORS = {
	Background = Color3.fromRGB(15, 15, 15),
	Sidebar = Color3.fromRGB(20, 20, 20),
	CardBg = Color3.fromRGB(25, 25, 25),
	InputBg = Color3.fromRGB(18, 18, 18),
	ButtonBg = Color3.fromRGB(28, 28, 28),
	ButtonHover = Color3.fromRGB(38, 38, 38),
	Border = Color3.fromRGB(35, 35, 35),
	TextPrimary = Color3.fromRGB(240, 240, 240),
	TextMuted = Color3.fromRGB(140, 140, 140),
	Accent = Color3.fromRGB(110, 86, 248),
	ToggleOff = Color3.fromRGB(40, 40, 40),
	ToggleOn = Color3.fromRGB(110, 86, 248)
}

local FONT = Enum.Font.Code

-- Main Window Frame
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 680, 0, 500)
MainWindow.Position = UDim2.new(0.5, -340, 0.5, -250)
MainWindow.BackgroundColor3 = COLORS.Background
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = false
MainWindow.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainWindow

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLORS.Border
MainStroke.Thickness = 1
MainStroke.Parent = MainWindow

-- Window Dragging System
local Dragging, DragInput, DragStart, StartPos
MainWindow.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = input.Position
		StartPos = MainWindow.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end
end)

MainWindow.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		DragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == DragInput and Dragging then
		local delta = input.Position - DragStart
		MainWindow.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
	end
end)

-- UI Visibility Toggle Keybind (RightControl to Hide/Show)
local UIVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
		UIVisible = not UIVisible
		MainWindow.Visible = UIVisible
	end
end)

---------------------------------------------------------
-- SIDEBAR & NAVIGATION SYSTEM
---------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = COLORS.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainWindow

local SidebarRightLine = Instance.new("Frame")
SidebarRightLine.Size = UDim2.new(0, 1, 1, 0)
SidebarRightLine.Position = UDim2.new(1, -1, 0, 0)
SidebarRightLine.BackgroundColor3 = COLORS.Border
SidebarRightLine.BorderSizePixel = 0
SidebarRightLine.Parent = Sidebar

local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(1, 0, 0, 50)
LogoContainer.BackgroundTransparency = 1
LogoContainer.Parent = Sidebar

local LogoIcon = Instance.new("ImageLabel")
LogoIcon.Size = UDim2.new(0, 22, 0, 22)
LogoIcon.Position = UDim2.new(0, 18, 0.5, -11)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Image = "rbxassetid://6034832801"
LogoIcon.ImageColor3 = Color3.fromRGB(255, 180, 50)
LogoIcon.Parent = LogoContainer

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, -50, 1, 0)
LogoText.Position = UDim2.new(0, 48, 0, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "IcarusHub"
LogoText.Font = FONT
LogoText.TextSize = 18
LogoText.TextColor3 = COLORS.TextPrimary
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Parent = LogoContainer

local NavContainer = Instance.new("Frame")
NavContainer.Size = UDim2.new(1, 0, 1, -50)
NavContainer.Position = UDim2.new(0, 0, 0, 50)
NavContainer.BackgroundTransparency = 1
NavContainer.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Padding = UDim.new(0, 4)
NavLayout.Parent = NavContainer

local Pages = {}
local NavButtons = {}

local function SwitchTab(tabName)
	for name, page in pairs(Pages) do
		page.Visible = (name == tabName)
	end
	for name, btnData in pairs(NavButtons) do
		local isSel = (name == tabName)
		btnData.Button.BackgroundColor3 = isSel and COLORS.CardBg or Color3.fromRGB(0, 0, 0)
		btnData.Button.BackgroundTransparency = isSel and 0 or 1
		btnData.Icon.ImageColor3 = isSel and COLORS.Accent or COLORS.TextMuted
		btnData.Label.TextColor3 = isSel and COLORS.TextPrimary or COLORS.TextMuted
	end
end

local function CreateTab(name, iconId)
	local Page = Instance.new("Frame")
	Page.Name = name .. "Page"
	Page.Size = UDim2.new(1, -180, 1, -45)
	Page.Position = UDim2.new(0, 180, 0, 45)
	Page.BackgroundTransparency = 1
	Page.Visible = false
	Page.Parent = MainWindow

	Pages[name] = Page

	local NavBtn = Instance.new("TextButton")
	NavBtn.Size = UDim2.new(1, -16, 0, 36)
	NavBtn.Position = UDim2.new(0, 8, 0, 0)
	NavBtn.BackgroundTransparency = 1
	NavBtn.AutoButtonColor = false
	NavBtn.Text = ""
	NavBtn.Parent = NavContainer

	local NavCorner = Instance.new("UICorner")
	NavCorner.CornerRadius = UDim.new(0, 4)
	NavCorner.Parent = NavBtn

	local Icon = Instance.new("ImageLabel")
	Icon.Size = UDim2.new(0, 16, 0, 16)
	Icon.Position = UDim2.new(0, 12, 0.5, -8)
	Icon.BackgroundTransparency = 1
	Icon.Image = iconId or "rbxassetid://6026568198"
	Icon.ImageColor3 = COLORS.TextMuted
	Icon.Parent = NavBtn

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -40, 1, 0)
	Label.Position = UDim2.new(0, 36, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = name
	Label.Font = FONT
	Label.TextSize = 13
	Label.TextColor3 = COLORS.TextMuted
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = NavBtn

	NavButtons[name] = {Button = NavBtn, Icon = Icon, Label = Label}

	NavBtn.MouseButton1Click:Connect(function()
		SwitchTab(name)
	end)

	return Page
end

---------------------------------------------------------
-- TOP BAR (Collapse Controls)
---------------------------------------------------------
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, -180, 0, 45)
TopBar.Position = UDim2.new(0, 180, 0, 0)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainWindow

local CollapseBtn = Instance.new("TextButton")
CollapseBtn.Size = UDim2.new(0, 28, 0, 28)
CollapseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CollapseBtn.BackgroundColor3 = COLORS.InputBg
CollapseBtn.BorderSizePixel = 0
CollapseBtn.Text = "-"
CollapseBtn.Font = FONT
CollapseBtn.TextSize = 16
CollapseBtn.TextColor3 = COLORS.TextMuted
CollapseBtn.Parent = TopBar

local CollapseCorner = Instance.new("UICorner")
CollapseCorner.CornerRadius = UDim.new(0, 4)
CollapseCorner.Parent = CollapseBtn

local CollapseStroke = Instance.new("UIStroke")
CollapseStroke.Color = COLORS.Border
CollapseStroke.Thickness = 1
CollapseStroke.Parent = CollapseBtn

CollapseBtn.MouseButton1Click:Connect(function()
	UIVisible = false
	MainWindow.Visible = false
end)

---------------------------------------------------------
-- UI HELPER BUILDERS
---------------------------------------------------------
local function CreatePageScroll(parentPage)
	local ScrollFrame = Instance.new("ScrollingFrame")
	ScrollFrame.Size = UDim2.new(1, -20, 1, -10)
	ScrollFrame.Position = UDim2.new(0, 10, 0, 0)
	ScrollFrame.BackgroundTransparency = 1
	ScrollFrame.BorderSizePixel = 0
	ScrollFrame.ScrollBarThickness = 2
	ScrollFrame.ScrollBarImageColor3 = COLORS.Border
	ScrollFrame.Parent = parentPage

	local Layout = Instance.new("UIListLayout")
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Padding = UDim.new(0, 8)
	Layout.Parent = ScrollFrame

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
	end)

	return ScrollFrame
end

local function CreateSectionLabel(parent, text)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 0, 16)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.Font = FONT
	Label.TextSize = 11
	Label.TextColor3 = COLORS.TextPrimary
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = parent
	return Label
end

local function CreateButton(text, parent, callback)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, -4, 0, 24)
	Btn.BackgroundColor3 = COLORS.ButtonBg
	Btn.BorderSizePixel = 0
	Btn.AutoButtonColor = false
	Btn.Text = text
	Btn.Font = FONT
	Btn.TextSize = 11
	Btn.TextColor3 = COLORS.TextPrimary
	Btn.Parent = parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 3)
	Corner.Parent = Btn

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = COLORS.Border
	Stroke.Thickness = 1
	Stroke.Parent = Btn

	Btn.MouseEnter:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.ButtonHover}):Play()
	end)
	Btn.MouseLeave:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.ButtonBg}):Play()
	end)

	if callback then
		Btn.MouseButton1Click:Connect(callback)
	end
	return Btn
end

local function CreateTextInput(parent, placeholder, callback)
	local InputFrame = Instance.new("Frame")
	InputFrame.Size = UDim2.new(1, -4, 0, 24)
	InputFrame.BackgroundColor3 = COLORS.InputBg
	InputFrame.BorderSizePixel = 0
	InputFrame.Parent = parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 3)
	Corner.Parent = InputFrame

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = COLORS.Border
	Stroke.Thickness = 1
	Stroke.Parent = InputFrame

	local Input = Instance.new("TextBox")
	Input.Size = UDim2.new(1, -12, 1, 0)
	Input.Position = UDim2.new(0, 6, 0, 0)
	Input.BackgroundTransparency = 1
	Input.Text = ""
	Input.PlaceholderText = placeholder or ""
	Input.PlaceholderColor3 = COLORS.TextMuted
	Input.Font = FONT
	Input.TextSize = 11
	Input.TextColor3 = COLORS.TextPrimary
	Input.TextXAlignment = Enum.TextXAlignment.Left
	Input.Parent = InputFrame

	if callback then
		Input.FocusLost:Connect(function()
			callback(Input.Text)
		end)
	end

	return Input
end

local function CreateToggle(text, defaultState, parent, callback)
	local state = defaultState or false

	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(1, -4, 0, 26)
	ToggleFrame.BackgroundColor3 = COLORS.CardBg
	ToggleFrame.BorderSizePixel = 0
	ToggleFrame.Parent = parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 4)
	Corner.Parent = ToggleFrame

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = COLORS.Border
	Stroke.Thickness = 1
	Stroke.Parent = ToggleFrame

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -50, 1, 0)
	Label.Position = UDim2.new(0, 10, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.Font = FONT
	Label.TextSize = 11
	Label.TextColor3 = COLORS.TextPrimary
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame

	local Indicator = Instance.new("Frame")
	Indicator.Size = UDim2.new(0, 32, 0, 16)
	Indicator.Position = UDim2.new(1, -40, 0.5, -8)
	Indicator.BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff
	Indicator.BorderSizePixel = 0
	Indicator.Parent = ToggleFrame

	local IndCorner = Instance.new("UICorner")
	IndCorner.CornerRadius = UDim.new(1, 0)
	IndCorner.Parent = Indicator

	local Dot = Instance.new("Frame")
	Dot.Size = UDim2.new(0, 12, 0, 12)
	Dot.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
	Dot.BackgroundColor3 = COLORS.TextPrimary
	Dot.BorderSizePixel = 0
	Dot.Parent = Indicator

	local DotCorner = Instance.new("UICorner")
	DotCorner.CornerRadius = UDim.new(1, 0)
	DotCorner.Parent = Dot

	local ClickArea = Instance.new("TextButton")
	ClickArea.Size = UDim2.new(1, 0, 1, 0)
	ClickArea.BackgroundTransparency = 1
	ClickArea.Text = ""
	ClickArea.Parent = ToggleFrame

	ClickArea.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(Indicator, TweenInfo.new(0.15), {
			BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff
		}):Play()
		TweenService:Create(Dot, TweenInfo.new(0.15), {
			Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
		}):Play()

		if callback then
			callback(state)
		end
	end)

	return ToggleFrame
end

local function CreateSlider(text, min, max, default, parent, callback)
	local SliderFrame = Instance.new("Frame")
	SliderFrame.Size = UDim2.new(1, -4, 0, 40)
	SliderFrame.BackgroundColor3 = COLORS.CardBg
	SliderFrame.BorderSizePixel = 0
	SliderFrame.Parent = parent

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 4)
	Corner.Parent = SliderFrame

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = COLORS.Border
	Stroke.Thickness = 1
	Stroke.Parent = SliderFrame

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.7, 0, 0, 18)
	Label.Position = UDim2.new(0, 10, 0, 4)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.Font = FONT
	Label.TextSize = 11
	Label.TextColor3 = COLORS.TextPrimary
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = SliderFrame

	local ValLabel = Instance.new("TextLabel")
	ValLabel.Size = UDim2.new(0.3, -10, 0, 18)
	ValLabel.Position = UDim2.new(0.7, 0, 0, 4)
	ValLabel.BackgroundTransparency = 1
	ValLabel.Text = tostring(default)
	ValLabel.Font = FONT
	ValLabel.TextSize = 11
	ValLabel.TextColor3 = COLORS.Accent
	ValLabel.TextXAlignment = Enum.TextXAlignment.Right
	ValLabel.Parent = SliderFrame

	local BarBackground = Instance.new("Frame")
	BarBackground.Size = UDim2.new(1, -20, 0, 6)
	BarBackground.Position = UDim2.new(0, 10, 0, 26)
	BarBackground.BackgroundColor3 = COLORS.InputBg
	BarBackground.BorderSizePixel = 0
	BarBackground.Parent = SliderFrame

	local BarCorner = Instance.new("UICorner")
	BarCorner.CornerRadius = UDim.new(1, 0)
	BarCorner.Parent = BarBackground

	local FillBar = Instance.new("Frame")
	local initialRatio = math.clamp((default - min) / (max - min), 0, 1)
	FillBar.Size = UDim2.new(initialRatio, 0, 1, 0)
	FillBar.BackgroundColor3 = COLORS.Accent
	FillBar.BorderSizePixel = 0
	FillBar.Parent = BarBackground

	local FillCorner = Instance.new("UICorner")
	FillCorner.CornerRadius = UDim.new(1, 0)
	FillCorner.Parent = FillBar

	local SliderBtn = Instance.new("TextButton")
	SliderBtn.Size = UDim2.new(1, 0, 1, 0)
	SliderBtn.BackgroundTransparency = 1
	SliderBtn.Text = ""
	SliderBtn.Parent = SliderFrame

	local isSliding = false

	local function UpdateSlider(input)
		local barPos = BarBackground.AbsolutePosition.X
		local barWidth = BarBackground.AbsoluteSize.X
		local mousePos = input.Position.X
		local ratio = math.clamp((mousePos - barPos) / barWidth, 0, 1)
		
		local rawVal = min + (max - min) * ratio
		local val = math.floor(rawVal * 10) / 10

		FillBar.Size = UDim2.new(ratio, 0, 1, 0)
		ValLabel.Text = tostring(val)

		if callback then
			callback(val)
		end
	end

	SliderBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isSliding = true
			UpdateSlider(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isSliding = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateSlider(input)
		end
	end)

	return SliderFrame
end

---------------------------------------------------------
-- TABS & CONTENT CREATION
---------------------------------------------------------

local MainPage = CreateTab("Main", "rbxassetid://6026568198")
local AvatarPage = CreateTab("Avatar", "rbxassetid://6034287525")
local MiscPage = CreateTab("Misc", "rbxassetid://6031280882")

local MainScroll = CreatePageScroll(MainPage)
local AvatarScroll = CreatePageScroll(AvatarPage)
local MiscScroll = CreatePageScroll(MiscPage)

-- ======================================================
-- POPULATE MAIN TAB
-- ======================================================
CreateSectionLabel(MainScroll, "Movement Settings")

CreateButton("Boost Speed (50)", MainScroll, function()
	local char = Players.LocalPlayer.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").WalkSpeed = 50
	end
end)

CreateButton("Reset Speed (16)", MainScroll, function()
	local char = Players.LocalPlayer.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
	end
end)

CreateSectionLabel(MainScroll, "Custom WalkSpeed Input")
CreateTextInput(MainScroll, "Enter Speed Value...", function(val)
	local num = tonumber(val)
	if num then
		local char = Players.LocalPlayer.Character
		if char and char:FindFirstChildOfClass("Humanoid") then
			char:FindFirstChildOfClass("Humanoid").WalkSpeed = num
		end
	end
end)

-- ======================================================
-- POPULATE AVATAR TAB (TWEEN SPEED CONTROLS WITH TOGGLE)
-- ======================================================
CreateSectionLabel(AvatarScroll, "Tween Speed Controls")

local TweenSpeedEnabled = false
local CustomTweenTime = 1.5
local DefaultTweenTime = 0.5 -- Default duration when toggle is off

-- Toggle to turn custom speed on or off
CreateToggle("Enable Custom Speed", false, AvatarScroll, function(enabled)
	TweenSpeedEnabled = enabled
end)

-- Slider to set the speed when enabled
CreateSlider("Tween Duration (Sec)", 0.1, 5.0, 1.5, AvatarScroll, function(val)
	CustomTweenTime = val
end)

-- Example buttons that read the toggle state
CreateButton("Tween Forward", AvatarScroll, function()
	local char = Players.LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		local duration = TweenSpeedEnabled and CustomTweenTime or DefaultTweenTime
		local targetCFrame = hrp.CFrame * CFrame.new(0, 0, -50)
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame}):Play()
	end
end)

CreateButton("Tween Upward", AvatarScroll, function()
	local char = Players.LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		local duration = TweenSpeedEnabled and CustomTweenTime or DefaultTweenTime
		local targetCFrame = hrp.CFrame * CFrame.new(0, 50, 0)
		local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame}):Play()
	end
end)

CreateSectionLabel(AvatarScroll, "Jump Options")

CreateButton("Boost Jump Power (100)", AvatarScroll, function()
	local char = Players.LocalPlayer.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").JumpPower = 100
	end
end)

CreateButton("Reset Jump Power (50)", AvatarScroll, function()
	local char = Players.LocalPlayer.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		char:FindFirstChildOfClass("Humanoid").JumpPower = 50
	end
end)

-- ======================================================
-- POPULATE MISC TAB
-- ======================================================
CreateSectionLabel(MiscScroll, "Server Utilities & External Scripts")

CreateButton("Execute Infinite Yield", MiscScroll, function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

CreateButton("Rejoin Current Server", MiscScroll, function()
	game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
end)

---------------------------------------------------------
-- INITIAL TAB SELECTION
---------------------------------------------------------

SwitchTab("Main")
