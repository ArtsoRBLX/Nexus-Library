--=====================================================================
--  NEXUS UI LIBRARY  •  v4.3.0 beta •  Pure Exploit Library
--  Features: Tiny Slide-In Notifications, Presets, Themes
--=====================================================================

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")

local Library = { Version = "4.3.0", Flags = {}, Elements = {}, Windows = {}, SavedPresets = {} }

--=========================  THEMES  ===================================
Library.Themes = {
	Dark = {
		Background  = Color3.fromRGB(8, 10, 14),
		Surface     = Color3.fromRGB(16, 20, 28),
		SurfaceAlt  = Color3.fromRGB(22, 27, 38),
		SurfaceHi   = Color3.fromRGB(30, 38, 52),
		Stroke      = Color3.fromRGB(50, 60, 80),
		Text        = Color3.fromRGB(245, 248, 255),
		TextDim     = Color3.fromRGB(150, 165, 190),
		TextMuted   = Color3.fromRGB(90, 105, 130),
		WindowGrad  = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 24, 35)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 12, 18)),
		})
	},
	Light = {
		Background  = Color3.fromRGB(240, 244, 250),
		Surface     = Color3.fromRGB(255, 255, 255),
		SurfaceAlt  = Color3.fromRGB(245, 247, 252),
		SurfaceHi   = Color3.fromRGB(225, 230, 240),
		Stroke      = Color3.fromRGB(200, 205, 215),
		Text        = Color3.fromRGB(20, 25, 35),
		TextDim     = Color3.fromRGB(80, 90, 105),
		TextMuted   = Color3.fromRGB(140, 150, 165),
		WindowGrad  = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 244, 250)),
		})
	}
}

Library.Theme = Library.Themes.Dark
Library.Theme.Accent  = Color3.fromRGB(0, 240, 255)
Library.Theme.Accent2 = Color3.fromRGB(180, 0, 255)
Library.Theme.Danger  = Color3.fromRGB(255, 60, 80)
Library.Theme.Success = Color3.fromRGB(0, 255, 150)
Library.Theme.Font      = Enum.Font.GothamMedium
Library.Theme.FontBold  = Enum.Font.GothamBold
Library.Theme.FontBlack = Enum.Font.GothamBlack

Library.Gradients = {
	Neon = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Library.Theme.Accent),
		ColorSequenceKeypoint.new(0.5, Library.Theme.Accent2),
		ColorSequenceKeypoint.new(1, Library.Theme.Accent),
	})
}

local Easings = {
	Smooth  = { Enum.EasingStyle.Quint,   Enum.EasingDirection.Out },
	Snappy  = { Enum.EasingStyle.Back,    Enum.EasingDirection.Out },
	Linear  = { Enum.EasingStyle.Linear,  Enum.EasingDirection.Out },
}

--=========================  HELPERS  ==================================
local function Create(class, props)
	local inst = Instance.new(class)
	local parent
	for k, v in next, props do
		if k == "Parent" then parent = v else inst[k] = v end
	end
	if parent ~= nil then inst.Parent = parent end
	return inst
end

local function Corner(p, r)
	return Create("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = p })
end

local function Stroke(p, color, thickness, transparency)
	return Create("UIStroke", {
		Color = color or Library.Theme.Stroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = p,
	})
end

local function Padding(p, t, b, l, r)
	return Create("UIPadding", {
		PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0),
		PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0),
		Parent = p,
	})
end

local function Tween(inst, props, duration, preset)
	if not inst or not inst.Parent then return nil end
	local e = Easings[preset] or Easings.Smooth
	local t = TweenService:Create(inst, TweenInfo.new(duration or 0.25, e[1], e[2]), props)
	t:Play()
	return t
end

local function Round(n, dec)
	local m = 10 ^ (dec or 0)
	return math.floor(n * m + 0.5) / m
end

--=========================  SERIALIZATION  ============================
local function Serialize(tbl)
	local lines = { "return {" }
	for k, v in pairs(tbl) do
		local line
		if type(v) == "string" then line = string.format("  [%q] = %q,", k, v)
		elseif type(v) == "boolean" or type(v) == "number" then line = string.format("  [%q] = %s,", k, tostring(v))
		elseif typeof(v) == "Color3" then line = string.format("  [%q] = Color3.new(%f, %f, %f),", k, v.R, v.G, v.B)
		elseif typeof(v) == "EnumItem" then line = string.format("  [%q] = Enum.%s.%s,", k, tostring(v.EnumType):gsub("Enum%.", ""), v.Name)
		elseif type(v) == "table" then
			local arr = {}
			for _, val in ipairs(v) do table.insert(arr, string.format("%q", val)) end
			line = string.format("  [%q] = {%s},", k, table.concat(arr, ", "))
		end
		if line then table.insert(lines, line) end
	end
	table.insert(lines, "}")
	return table.concat(lines, "\n")
end

--=========================  THEME ENGINE  =============================
function Library:SetTheme(themeName, window)
	local newTheme = self.Themes[themeName]
	if not newTheme then return end
	local oldTheme = self.Theme
	
	local newActive = {}
	for k, v in pairs(newTheme) do newActive[k] = v end
	newActive.Accent, newActive.Accent2 = oldTheme.Accent, oldTheme.Accent2
	newActive.Danger, newActive.Success = oldTheme.Danger, oldTheme.Success
	newActive.Font, newActive.FontBold, newActive.FontBlack = oldTheme.Font, oldTheme.FontBold, oldTheme.FontBlack
	self.Theme = newActive
	
	local function applyColors(obj)
		for _, desc in ipairs(obj:GetDescendants()) do
			if desc.BackgroundColor3 == oldTheme.Background then desc.BackgroundColor3 = newActive.Background
			elseif desc.BackgroundColor3 == oldTheme.Surface then desc.BackgroundColor3 = newActive.Surface
			elseif desc.BackgroundColor3 == oldTheme.SurfaceAlt then desc.BackgroundColor3 = newActive.SurfaceAlt
			elseif desc.BackgroundColor3 == oldTheme.SurfaceHi then desc.BackgroundColor3 = newActive.SurfaceHi
			end

			if desc.TextColor3 == oldTheme.Text then desc.TextColor3 = newActive.Text
			elseif desc.TextColor3 == oldTheme.TextDim then desc.TextColor3 = newActive.TextDim
			elseif desc.TextColor3 == oldTheme.TextMuted then desc.TextColor3 = newActive.TextMuted
			end

			if desc:IsA("UIStroke") and desc.Color == oldTheme.Stroke then desc.Color = newActive.Stroke end
		end
	end
	
	applyColors(window.Main)
	applyColors(window.ToggleBtn)
	applyColors(window.Gui)
	
	local bgGrad = window.BgImg:FindFirstChild("UIGradient")
	if bgGrad then bgGrad.Color = newActive.WindowGrad end
end

--=========================  PRESET SYSTEM  ============================
function Library:ShowPresetModal(title, code)
	local T = Library.Theme
	local modalGui = self.Windows[1].Gui
	
	local overlay = Create("TextButton", {
		Name = "PresetModalOverlay", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 0.5, Text = "", ZIndex = 500, Parent = modalGui
	})
	
	local modal = Create("Frame", {
		Name = "PresetModal", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(500, 300), BackgroundColor3 = T.Background, BorderSizePixel = 0,
		ClipsDescendants = true, ZIndex = 501, Parent = modalGui
	})
	Corner(modal, 12)
	Stroke(modal, T.Accent, 1.5, 0.2)
	Create("UIGradient", { Rotation = 90, Color = T.WindowGrad, Parent = modal })
	Padding(modal, 15, 15, 15, 15)
	
	Create("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = title, TextColor3 = T.Text, TextSize = 16, Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = modal })
	
	local codeBox = Create("TextBox", {
		Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, 0, 1, -80), BackgroundColor3 = T.SurfaceAlt,
		BorderSizePixel = 0, Text = code, TextColor3 = T.TextDim, TextSize = 12, Font = Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true, ClearTextOnFocus = false, MultiLine = true, Parent = modal
	})
	Corner(codeBox, 8)
	Stroke(codeBox, T.Stroke, 1, 0.5)
	Padding(codeBox, 10, 10, 10, 10)
	
	local btnRow = Create("Frame", { Position = UDim2.new(0, 0, 1, -40), Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = modal })
	Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = btnRow })
	
	local copyBtn = Create("TextButton", { Size = UDim2.new(0, 150, 1, 0), BackgroundColor3 = T.Accent, BackgroundTransparency = 0.2, Text = "Copy to Clipboard", TextColor3 = Color3.new(1,1,1), TextSize = 12, Font = T.FontBold, AutoButtonColor = false, Parent = btnRow })
	Corner(copyBtn, 6)
	
	local fileBtn = Create("TextButton", { Size = UDim2.new(0, 150, 1, 0), BackgroundColor3 = T.SurfaceHi, BackgroundTransparency = 0.2, Text = "Save to File", TextColor3 = T.Text, TextSize = 12, Font = T.FontBold, AutoButtonColor = false, Parent = btnRow })
	Corner(fileBtn, 6)
	
	local closeBtn = Create("TextButton", { Size = UDim2.new(0, 100, 1, 0), BackgroundColor3 = T.Danger, BackgroundTransparency = 0.2, Text = "Close", TextColor3 = Color3.new(1,1,1), TextSize = 12, Font = T.FontBold, AutoButtonColor = false, Parent = btnRow })
	Corner(closeBtn, 6)
	
	local function closeModal()
		overlay:Destroy()
		modal:Destroy()
	end
	
	copyBtn.MouseButton1Click:Connect(function()
		if setclipboard then setclipboard(code) end
		copyBtn.Text = "Copied!"
		task.delay(1.5, function() if copyBtn and copyBtn.Parent then copyBtn.Text = "Copy to Clipboard" end end)
	end)
	
	fileBtn.MouseButton1Click:Connect(function()
		if writefile then
			local ok, err = pcall(function()
				if not isfolder("NexusPresets") then makefolder("NexusPresets") end
				writefile("NexusPresets/" .. title .. ".txt", code)
			end)
			fileBtn.Text = ok and "Saved!" or "Error"
		else
			fileBtn.Text = "Unsupported"
		end
		task.delay(1.5, function() if fileBtn and fileBtn.Parent then fileBtn.Text = "Save to File" end end)
	end)
	
	closeBtn.MouseButton1Click:Connect(closeModal)
	overlay.MouseButton1Click:Connect(closeModal)
end

--=========================  NOTIFICATIONS  ============================
function Library:Notify(cfg)
	cfg = cfg or {}
	local T = Library.Theme
	local mainWin = self.Windows[1]
	if not mainWin or not mainWin.Gui then return end

	if not mainWin.NotifyHolder then
		mainWin.NotifyHolder = Create("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -16, 0, 16),
			Size = UDim2.fromOffset(260, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ZIndex = 300,
			Parent = mainWin.Gui,
		})
		Create("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Parent = mainWin.NotifyHolder
		})
	end

	local accent = cfg.Color or T.Accent
	local dur = cfg.Duration or 4

	-- Tiny notification container
	local group = Create("CanvasGroup", {
		Size = UDim2.new(1, 0, 0, 60), -- Tiny fixed height
		BackgroundColor3 = T.Surface,
		BackgroundTransparency = 0.05,
		GroupTransparency = 1,
		Position = UDim2.new(1, 300, 0, 0), -- Start off-screen to the right
		ZIndex = 300,
		Parent = mainWin.NotifyHolder
	})
	Corner(group, 8)
	Stroke(group, accent, 1.5, 0.3)

	-- Slide in animation
	Tween(group, { Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0 }, 0.4, "Snappy")

	-- Header (Title and close)
	local head = Create("Frame", { Position = UDim2.fromOffset(12, 10), Size = UDim2.new(1, -24, 0, 16), BackgroundTransparency = 1, Parent = group })
	local dot = Create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(6, 6), BackgroundColor3 = accent, BorderSizePixel = 0, Parent = head })
	Corner(dot, 3)
	Create("TextLabel", { Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, Text = cfg.Title or "Notification", TextColor3 = T.Text, TextSize = 13, Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = head })

	-- Body text
	Create("TextLabel", {
		Position = UDim2.fromOffset(12, 30),
		Size = UDim2.new(1, -24, 0, 18),
		BackgroundTransparency = 1,
		Text = cfg.Text or "",
		TextColor3 = T.TextDim,
		TextSize = 11,
		Font = T.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = group
	})

	-- Draining Progress Bar (bottom)
	local prog = Create("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Parent = group
	})
	Corner(prog, 2)
	local fillProg = Create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = accent, BorderSizePixel = 0, Parent = prog })
	Corner(fillProg, 2)

	Tween(fillProg, { Size = UDim2.fromScale(0, 1) }, dur, "Linear")

	-- Click to dismiss
	local clickBtn = Create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = group })
	clickBtn.MouseButton1Click:Connect(function()
		-- Slide out and destroy immediately
		Tween(group, { Position = UDim2.new(1, 300, 0, 0), GroupTransparency = 1 }, 0.3, "Smooth")
		task.wait(0.3)
		group:Destroy()
	end)

	-- Auto destroy when progress finishes
	task.delay(dur, function()
		if group and group.Parent then
			Tween(group, { Position = UDim2.new(1, 300, 0, 0), GroupTransparency = 1 }, 0.3, "Smooth")
			task.wait(0.3)
			group:Destroy()
		end
	end)
end

--=========================  WINDOW  ===================================
function Library:CreateWindow(config)
	config = config or {}
	local win = setmetatable({ Config = config, Tabs = {}, Flags = {} }, { __index = self })
	win.Notify = function(_, cfg) self:Notify(cfg) end
	self.Windows[#self.Windows + 1] = win
	win:_Build()
	return win
end

function Library:_Build()
	local T, G = Library.Theme, Library.Gradients
	local cfg = self.Config

	local gui = Instance.new("ScreenGui")
	gui.Name = "NexusUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 9999
	local ok = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
	if not ok or not gui.Parent then gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
	self.Gui = gui

	-- Shadow / Glow
	local shadow = Create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset((cfg.Width or 700) + 20, (cfg.Height or 480) + 20), BackgroundColor3 = T.Accent2, BackgroundTransparency = 0.85, BorderSizePixel = 0, ZIndex = 99, Parent = gui })
	Corner(shadow, 30)
	self.Shadow = shadow

	-- Main Frame
	local main = Create("Frame", { Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(cfg.Width or 700, cfg.Height or 480), BackgroundColor3 = T.Background, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 100, Parent = gui })
	self.Main = main
	Corner(main, 20)
	local ms = Stroke(main, T.Accent, 1.5, 0.2)
	Create("UIGradient", { Color = G.Neon, Parent = ms })

	-- Background
	local bgImg = Create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = T.Background, BorderSizePixel = 0, ZIndex = 1, Parent = main })
	Corner(bgImg, 20)
	Create("UIGradient", { Rotation = 135, Color = T.WindowGrad, Parent = bgImg })
	self.BgImg = bgImg

	-- Title Bar
	local titleBar = Create("Frame", { Name = "TitleBar", Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1, ZIndex = 5, Parent = main })
	local logo = Create("Frame", { Position = UDim2.fromOffset(16, 14), Size = UDim2.fromOffset(28, 28), BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 5, Parent = titleBar })
	Corner(logo, 8)
	Create("UIGradient", { Color = G.Neon, Rotation = 45, Parent = logo })
	Stroke(logo, Color3.new(1, 1, 1), 1, 0.8)
	
	if cfg.IconId then
		Create("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = "rbxassetid://" .. tostring(cfg.IconId), ScaleType = Enum.ScaleType.Fit, ZIndex = 6, Parent = logo })
	else
		Create("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "N", TextColor3 = Color3.new(0, 0, 0), TextSize = 16, Font = T.FontBlack, ZIndex = 6, Parent = logo })
	end

	Create("TextLabel", { Position = UDim2.fromOffset(54, 12), Size = UDim2.new(1, -200, 0, 16), BackgroundTransparency = 1, Text = cfg.Title or "NEXUS", TextColor3 = T.Text, TextSize = 16, Font = T.FontBlack, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = titleBar })
	Create("TextLabel", { Position = UDim2.fromOffset(54, 30), Size = UDim2.new(1, -200, 0, 14), BackgroundTransparency = 1, Text = cfg.Subtitle or ("v" .. Library.Version), TextColor3 = T.Accent, TextSize = 11, Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = titleBar })

	local minBtn = Create("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -78, 0, 14), Size = UDim2.fromOffset(30, 30), BackgroundColor3 = T.SurfaceAlt, BackgroundTransparency = 1, Text = "—", TextColor3 = T.TextDim, TextSize = 14, Font = T.FontBold, AutoButtonColor = false, ZIndex = 6, Parent = titleBar })
	Corner(minBtn, 8)
	minBtn.MouseEnter:Connect(function() Tween(minBtn, { BackgroundTransparency = 0.5, TextColor3 = T.Accent }, 0.15) end)
	minBtn.MouseLeave:Connect(function() Tween(minBtn, { BackgroundTransparency = 1, TextColor3 = T.TextDim }, 0.15) end)

	local closeBtn = Create("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 14), Size = UDim2.fromOffset(60, 30), BackgroundColor3 = T.Danger, BackgroundTransparency = 0.2, Text = "Close", TextColor3 = Color3.new(1, 1, 1), TextSize = 12, Font = T.FontBold, AutoButtonColor = false, ZIndex = 6, Parent = titleBar })
	Corner(closeBtn, 8)
	Stroke(closeBtn, T.Danger, 1, 0.5)
	closeBtn.MouseEnter:Connect(function() Tween(closeBtn, { BackgroundTransparency = 0, TextColor3 = Color3.new(1,1,1) }, 0.15) end)
	closeBtn.MouseLeave:Connect(function() Tween(closeBtn, { BackgroundTransparency = 0.2 }, 0.15) end)

	Create("Frame", { Position = UDim2.fromOffset(0, 56), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Stroke, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 5, Parent = main })

	local rail = Create("Frame", { Name = "Rail", Position = UDim2.fromOffset(0, 57), Size = UDim2.new(0, 160, 1, -57), BackgroundTransparency = 1, ZIndex = 5, Parent = main })
	self.Rail = rail

	local tabArea = Create("Frame", { Name = "TabArea", Position = UDim2.fromOffset(10, 10), Size = UDim2.new(1, -20, 1, -110), BackgroundTransparency = 1, ZIndex = 5, Parent = rail })
	Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tabArea })
	self.TabArea = tabArea

	local bottomArea1 = Create("Frame", { Name = "BottomArea1", Position = UDim2.new(0, 10, 1, -88), Size = UDim2.new(1, -20, 0, 36), BackgroundTransparency = 1, ZIndex = 5, Parent = rail })
	Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = bottomArea1 })
	self.BottomArea1 = bottomArea1

	local bottomArea2 = Create("Frame", { Name = "BottomArea2", Position = UDim2.new(0, 10, 1, -46), Size = UDim2.new(1, -20, 0, 36), BackgroundTransparency = 1, ZIndex = 5, Parent = rail })
	Create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = bottomArea2 })
	self.BottomArea2 = bottomArea2

	Create("Frame", { Position = UDim2.new(0, 10, 1, -93), Size = UDim2.new(1, -20, 0, 1), BackgroundColor3 = T.Stroke, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 5, Parent = rail })
	Create("Frame", { Position = UDim2.new(0, 10, 1, -51), Size = UDim2.new(1, -20, 0, 1), BackgroundColor3 = T.Stroke, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 5, Parent = rail })
	Create("Frame", { Position = UDim2.fromOffset(160, 57), Size = UDim2.new(0, 1, 1, -57), BackgroundColor3 = T.Stroke, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 5, Parent = main })

	local content = Create("Frame", { Name = "Content", Position = UDim2.fromOffset(161, 57), Size = UDim2.new(1, -161, 1, -57), BackgroundTransparency = 1, ZIndex = 5, Parent = main })
	self.Content = content

	local toggleBtn = Create("TextButton", { Name = "FloatingToggle", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 60, 0.5, 0), Size = UDim2.fromOffset(48, 48), BackgroundColor3 = T.Accent, Text = "", AutoButtonColor = false, Visible = false, ZIndex = 150, Parent = gui })
	Corner(toggleBtn, 999)
	Stroke(toggleBtn, Color3.new(1, 1, 1), 2, 0.3)
	Create("UIGradient", { Color = G.Neon, Rotation = 45, Parent = toggleBtn })

	if cfg.IconId then
		Create("ImageLabel", { Size = UDim2.fromScale(0.6, 0.6), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://" .. tostring(cfg.IconId), ScaleType = Enum.ScaleType.Fit, ZIndex = 151, Parent = toggleBtn })
	else
		Create("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "N", TextColor3 = Color3.new(0, 0, 0), TextSize = 24, Font = T.FontBlack, ZIndex = 151, Parent = toggleBtn })
	end
	self.ToggleBtn = toggleBtn

	local btnDragging, btnStart, btnStartPos
	toggleBtn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			btnDragging, btnStart, btnStartPos = true, i.Position, toggleBtn.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not btnDragging then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			local d = i.Position - btnStart
			toggleBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + d.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			btnDragging = false
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		main.Visible = false
		shadow.Visible = false
		toggleBtn.Visible = true
	end)
	minBtn.MouseButton1Click:Connect(function()
		local h = main.AbsoluteSize.Y
		Tween(main, { Size = UDim2.new(main.Size.X.Scale, main.Size.X.Offset, 0, 56) }, 0.25, "Snappy")
		task.wait(0.25)
		Tween(main, { Size = UDim2.new(main.Size.X.Scale, main.Size.X.Offset, 0, h) }, 0.25, "Snappy")
	end)
	toggleBtn.MouseButton1Click:Connect(function()
		main.Visible = true
		shadow.Visible = true
		toggleBtn.Visible = false
	end)

	local dragging, dragStart, startPos
	titleBar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, dragStart, startPos = true, i.Position, main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not dragging then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			local d = i.Position - dragStart
			local p = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			main.Position = p
			shadow.Position = p
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)

	-- SETTINGS TAB
	local SettingsTab = self:Tab("Settings", "⚙️", 1)
	local SettingsSec = SettingsTab:Section({ Name = "UI Appearance", Side = "Left" })
	local UtilitySec = SettingsTab:Section({ Name = "Utility", Side = "Right" })
	self.SettingsTab = SettingsTab

	local currentShape = "Squircle"
	local function ApplyShape()
		local maxRadius = math.min(self.Main.AbsoluteSize.X, self.Main.AbsoluteSize.Y) / 2
		local r = 20
		if currentShape == "Circle" then r = maxRadius
		elseif currentShape == "Square" then r = 0 end
		self.Main.UICorner.CornerRadius = UDim.new(0, r)
		self.BgImg.UICorner.CornerRadius = UDim.new(0, r)
		self.Shadow.UICorner.CornerRadius = UDim.new(0, r + 10)
	end

	SettingsSec:Dropdown({
		Name = "Theme Mode", Options = {"Dark", "Light"}, Default = "Dark",
		Callback = function(val) self:SetTheme(val, self) end
	})
	SettingsSec:Slider({
		Name = "UI Width", Min = 500, Max = 1200, Default = cfg.Width or 700,
		Callback = function(val)
			self.Main.Size = UDim2.fromOffset(val, self.Main.AbsoluteSize.Y)
			self.Shadow.Size = UDim2.fromOffset(val + 20, self.Main.AbsoluteSize.Y + 20)
			ApplyShape()
		end
	})
	SettingsSec:Slider({
		Name = "UI Height", Min = 300, Max = 900, Default = cfg.Height or 480,
		Callback = function(val)
			self.Main.Size = UDim2.fromOffset(self.Main.AbsoluteSize.X, val)
			self.Shadow.Size = UDim2.fromOffset(self.Main.AbsoluteSize.X + 20, val + 20)
			ApplyShape()
		end
	})
	SettingsSec:Dropdown({
		Name = "Menu Shape", Options = {"Squircle", "Circle", "Square"}, Default = "Squircle",
		Callback = function(val) currentShape = val; ApplyShape() end
	})
	SettingsSec:Dropdown({
		Name = "Button Shape", Options = {"Squircle", "Circle", "Square"}, Default = "Circle",
		Callback = function(val)
			local r = 14
			if val == "Circle" then r = 999 elseif val == "Square" then r = 0 end
			self.ToggleBtn.UICorner.CornerRadius = UDim.new(0, r)
		end
	})
	SettingsSec:Dropdown({
		Name = "Button Size", Options = {"Small", "Big", "Extra Big"}, Default = "Big",
		Callback = function(val)
			local size = 48
			if val == "Small" then size = 36 elseif val == "Extra Big" then size = 64 end
			self.ToggleBtn.Size = UDim2.fromOffset(size, size)
		end
	})
	UtilitySec:Keybind({
		Name = "Toggle UI Key", Default = Enum.KeyCode.RightShift, Mode = "Always",
		Callback = function(pressed)
			if pressed then
				if self.Main.Visible then
					self.Main.Visible = false
					self.Shadow.Visible = false
					self.ToggleBtn.Visible = true
				else
					self.Main.Visible = true
					self.Shadow.Visible = true
					self.ToggleBtn.Visible = false
				end
			end
		end
	})
	UtilitySec:Button({ Name = "Destroy UI", Callback = function() self.Gui:Destroy() end })

	-- PRESETS TAB
	local PresetsTab = self:Tab("Presets", "💾", 2)
	local SaveSec = PresetsTab:Section({ Name = "Save New Preset", Side = "Left" })
	local LoadSec = PresetsTab:Section({ Name = "Your Presets", Side = "Right" })
	self.PresetsTab = PresetsTab

	local nameBox = SaveSec:Textbox({ Name = "Preset Name", Placeholder = "e.g., PvP Config" })
	local listFrame = Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = LoadSec.Content })
	Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = listFrame })

	local function UpdatePresetList()
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end
		end
		
		for name, code in pairs(Library.SavedPresets) do
			local row = Create("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = T.SurfaceAlt, BackgroundTransparency = 0.5, Parent = listFrame })
			Corner(row, 8)
			Stroke(row, T.Stroke, 1, 0.5)
			
			Create("TextLabel", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -180, 1, 0), BackgroundTransparency = 1, Text = name, TextColor3 = T.Text, TextSize = 13, Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
			
			local btnArea = Create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.fromOffset(160, 22), BackgroundTransparency = 1, Parent = row })
			Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = btnArea })
			
			local function miniBtn(txt, color, callback)
				local b = Create("TextButton", { Size = UDim2.fromOffset(36, 22), BackgroundColor3 = color, BackgroundTransparency = 0.2, Text = txt, TextColor3 = Color3.new(1,1,1), TextSize = 10, Font = T.FontBold, AutoButtonColor = false, Parent = btnArea })
				Corner(b, 4)
				b.MouseButton1Click:Connect(callback)
				return b
			end
			
			miniBtn("Load", T.Accent, function()
				local func = loadstring(code)
				if func then
					local success, data = pcall(func)
					if success and type(data) == "table" then
						for k, v in pairs(data) do
							if Library.Elements[k] then
								Library.Elements[k]:Set(v)
							else
								Library.Flags[k] = v
							end
						end
						self:Notify({ Title = "Loaded", Text = "Preset '" .. name .. "' loaded!", Color = T.Success })
					end
				end
			end)
			
			miniBtn("Save", T.Success, function()
				local newCode = Serialize(Library.Flags)
				Library.SavedPresets[name] = newCode
				self:Notify({ Title = "Overwritten", Text = "Preset '" .. name .. "' overwritten.", Color = T.Success })
			end)
			
			miniBtn("Copy", T.SurfaceHi, function() self:ShowPresetModal(name, code) end)
			
			miniBtn("Del", T.Danger, function()
				Library.SavedPresets[name] = nil
				UpdatePresetList()
				self:Notify({ Title = "Deleted", Text = "Preset '" .. name .. "' removed.", Color = T.Danger })
			end)
		end
	end

	SaveSec:Button({
		Name = "Create Preset",
		Callback = function()
			local name = nameBox:Get()
			if name == "" then
				self:Notify({ Title = "Error", Text = "Please enter a preset name.", Color = T.Danger })
				return
			end
			local code = Serialize(Library.Flags)
			Library.SavedPresets[name] = code
			nameBox:Set("")
			UpdatePresetList()
			self:ShowPresetModal(name, code)
		end
	})

	self:SelectTab(SettingsTab)
end

--=========================  TABS  =====================================
local TabClass = {}
TabClass.__index = TabClass

function Library:Tab(name, icon, bottomIndex)
	local T = Library.Theme
	local index = #self.Tabs + 1
	local parent = self.TabArea
	if bottomIndex == 1 then parent = self.BottomArea1
	elseif bottomIndex == 2 then parent = self.BottomArea2 end

	local button = Create("TextButton", { Name = (name .. "Tab"):gsub("%s+", ""), Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = T.SurfaceAlt, BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ClipsDescendants = true, LayoutOrder = index, ZIndex = 5, Parent = parent })
	Corner(button, 8)

	local bar = Create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(4, 18), BackgroundColor3 = T.Accent, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 6, Parent = button })
	Corner(bar, 2)
	Create("UIGradient", { Color = Library.Gradients.Neon, Rotation = 90, Parent = bar })

	local lblText = icon and (icon .. "  " .. name) or name
	local label = Create("TextLabel", { Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, Text = lblText, TextColor3 = T.TextDim, TextSize = 13, Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = button })

	local page = Create("Frame", { Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, ZIndex = 5, Parent = self.Content })

	local cols = {}
	for i = 1, 2 do
		local c = Create("ScrollingFrame", {
			Name = "Col" .. i,
			Position = (i == 1) and UDim2.fromOffset(10, 10) or UDim2.new(0.5, 5, 0, 10),
			Size = UDim2.new(0.5, -15, 1, -20),
			BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
			ScrollBarImageColor3 = T.Accent, ScrollBarImageTransparency = 0.2,
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 5, Parent = page,
		})
		Create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = c })
		cols[i] = c
	end

	local tab = setmetatable({ Window = self, Name = name, Button = button, Bar = bar, Label = label, Page = page, Columns = cols }, TabClass)
	self.Tabs[index] = tab

	button.MouseEnter:Connect(function() if self.ActiveTab ~= tab then Tween(button, { BackgroundTransparency = 0.8 }, 0.15) end end)
	button.MouseLeave:Connect(function() if self.ActiveTab ~= tab then Tween(button, { BackgroundTransparency = 1 }, 0.15) end end)
	button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)

	if not bottomIndex then
		self._userTabCount = (self._userTabCount or 0) + 1
		if self._userTabCount == 1 then self:SelectTab(tab) end
	end
	return tab
end

function Library:SelectTab(target)
	local T = Library.Theme
	for _, t in ipairs(self.Tabs) do
		local on = (t == target)
		t.Page.Visible = on
		Tween(t.Bar,   { BackgroundTransparency = on and 0 or 1 }, 0.2)
		Tween(t.Label, { TextColor3 = on and T.Text or T.TextDim }, 0.2)
		Tween(t.Button,{ BackgroundTransparency = on and 0.9 or 1 }, 0.2)
		if on then
			t.Page.Position = UDim2.fromOffset(10, 0)
			Tween(t.Page, { Position = UDim2.fromOffset(0, 0) }, 0.25, "Snappy")
		end
	end
	self.ActiveTab = target
end

--=========================  SECTIONS  =================================
local SectionClass = {}
SectionClass.__index = SectionClass

function TabClass:Section(config)
	config = config or {}
	local T = Library.Theme
	local col = self.Columns[(config.Side == "Right") and 2 or 1]

	local frame = Create("Frame", { Name = config.Name or "Section", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = T.Surface, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 5, Parent = col })
	Corner(frame, 10)
	local stroke = Stroke(frame, T.Stroke, 1, 0.6)
	Padding(frame, 12, 12, 12, 12)
	Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame })

	local header = Create("TextButton", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = 0, ZIndex = 5, Parent = frame })
	local accentBar = Create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(3, 12), BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 6, Parent = header })
	Corner(accentBar, 2)
	Create("UIGradient", { Color = Library.Gradients.Neon, Rotation = 90, Parent = accentBar })
	Create("TextLabel", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -28, 1, 0), BackgroundTransparency = 1, Text = string.upper(config.Name or "SECTION"), TextColor3 = T.Text, TextSize = 11, Font = T.FontBlack, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = header })
	
	local arrow = Create("TextLabel", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1, Text = "▾", TextColor3 = T.TextDim, TextSize = 11, Font = T.FontBold, ZIndex = 6, Parent = header })

	Create("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = T.Stroke, BackgroundTransparency = 0.5, BorderSizePixel = 0, LayoutOrder = 1, ZIndex = 5, Parent = frame })

	local content = Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2, ZIndex = 5, Parent = frame })
	Create("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content })

	local self_sec = setmetatable({ Window = self.Window, Tab = self, Frame = frame, Content = content, Order = 0, Collapsed = false }, SectionClass)

	header.MouseButton1Click:Connect(function()
		self_sec.Collapsed = not self_sec.Collapsed
		content.Visible = not self_sec.Collapsed
		if not self_sec.Collapsed then
			content.Size = UDim2.new(1, 0, 0, 0)
			content.AutomaticSize = Enum.AutomaticSize.Y
		end
		Tween(arrow, { Rotation = self_sec.Collapsed and -90 or 0 }, 0.2)
	end)
	
	frame.MouseEnter:Connect(function() Tween(stroke, { Color = T.Accent, Transparency = 0.3 }, 0.2) end)
	frame.MouseLeave:Connect(function() Tween(stroke, { Color = T.Stroke, Transparency = 0.6 }, 0.2) end)

	return self_sec
end

function SectionClass:_next()
	self.Order = self.Order + 1
	return self.Order
end

--=========================  ELEMENTS  =================================
function SectionClass:Toggle(cfg)
	local T = Library.Theme
	local o = self:_next()

	local row = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = o, ZIndex = 5, Parent = self.Content })
	Create("TextLabel", { Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, Text = cfg.Name or "Toggle", TextColor3 = T.Text, TextSize = 13, Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = row })
	
	local sw = Create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(44, 24), BackgroundColor3 = T.SurfaceHi, BorderSizePixel = 0, ZIndex = 6, Parent = row })
	Corner(sw, 12)
	local swS = Stroke(sw, T.Stroke, 1, 0.5)
	local knob = Create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = T.TextDim, BorderSizePixel = 0, ZIndex = 7, Parent = sw })
	Corner(knob, 9)

	local val = cfg.Default and true or false
	local function set(v, silent)
		val = v and true or false
		if val then
			Tween(sw, { BackgroundColor3 = T.Accent }, 0.2)
			Tween(knob, { Position = UDim2.new(1, -21, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1) }, 0.25, "Snappy")
			Tween(swS, { Color = T.Accent, Transparency = 0.2 }, 0.2)
		else
			Tween(sw, { BackgroundColor3 = T.SurfaceHi }, 0.2)
			Tween(knob, { Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = T.TextDim }, 0.25, "Snappy")
			Tween(swS, { Color = T.Stroke, Transparency = 0.5 }, 0.2)
		end
		if cfg.Flag then Library.Flags[cfg.Flag] = val end
		if not silent and cfg.Callback then task.spawn(cfg.Callback, val) end
	end

	row.MouseButton1Click:Connect(function() set(not val) end)
	set(val, true)
	
	if cfg.Flag then Library.Elements[cfg.Flag] = { Set = set, Get = function() return val end } end
	return { Set = function(v) set(v, true) end, Get = function() return val end }
end

function SectionClass:Slider(cfg)
	local T = Library.Theme
	local o = self:_next()
	local min, max = cfg.Min or 0, cfg.Max or 100
	local dec = cfg.Decimals or 0
	local val = math.clamp(cfg.Default or min, min, max)

	local row = Create("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, LayoutOrder = o, ZIndex = 5, Parent = self.Content })
	Create("TextLabel", { Size = UDim2.new(1, -60, 0, 16), BackgroundTransparency = 1, Text = cfg.Name or "Slider", TextColor3 = T.Text, TextSize = 13, Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = row })
	local vLabel = Create("TextLabel", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(60, 16), BackgroundTransparency = 1, Text = tostring(val), TextColor3 = T.Accent, TextSize = 12, Font = T.FontBlack, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 6, Parent = row })

	local bar = Create("Frame", { Position = UDim2.fromOffset(0, 28), Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = T.SurfaceHi, BorderSizePixel = 0, ZIndex = 6, Parent = row })
	Corner(bar, 3)
	local fill = Create("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = T.Accent, BorderSizePixel = 0, ZIndex = 7, Parent = bar })
	Corner(fill, 3)
	Create("UIGradient", { Color = Library.Gradients.Neon, Parent = fill })
	
	local knob = Create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 8, Parent = bar })
	Corner(knob, 7)
	Stroke(knob, T.Accent, 2, 0)

	local function set(v, silent)
		val = math.clamp(Round(v, dec), min, max)
		local a = (max == min) and 0 or (val - min) / (max - min)
		fill.Size = UDim2.new(a, 0, 1, 0)
		knob.Position = UDim2.new(a, 0, 0.5, 0)
		vLabel.Text = tostring(val)
		if cfg.Flag then Library.Flags[cfg.Flag] = val end
		if not silent and cfg.Callback then task.spawn(cfg.Callback, val) end
	end

	local drag = false
	local function fromX(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		set(min + (max - min) * rel)
	end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = true
			Tween(knob, { Size = UDim2.fromOffset(18, 18) }, 0.1)
			fromX(i.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if not drag then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then fromX(i.Position.X) end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			if drag then drag = false; Tween(knob, { Size = UDim2.fromOffset(14, 14) }, 0.1) end
		end
	end)
	set(val, true)
	
	if cfg.Flag then Library.Elements[cfg.Flag] = { Set = set, Get = function() return val end } end
	return { Set = function(v) set(v, true) end, Get = function() return val end }
end

function SectionClass:Button(cfg)
	local T = Library.Theme
	local o = self:_next()

	local b = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = T.SurfaceAlt, BackgroundTransparency = 0.5, Text = cfg.Name or "Button", TextColor3 = T.Text, TextSize = 13, Font = T.FontBold, AutoButtonColor = false, ClipsDescendants = true, LayoutOrder = o, ZIndex = 5, Parent = self.Content })
	Corner(b, 8)
	local s = Stroke(b, T.Stroke, 1, 0.5)

	b.MouseEnter:Connect(function() Tween(b, { BackgroundColor3 = T.Accent, BackgroundTransparency = 0.7, TextColor3 = T.Accent }, 0.15); Tween(s, { Color = T.Accent, Transparency = 0.2 }, 0.15) end)
	b.MouseLeave:Connect(function() Tween(b, { BackgroundColor3 = T.SurfaceAlt, BackgroundTransparency = 0.5, TextColor3 = T.Text }, 0.15); Tween(s, { Color = T.Stroke, Transparency = 0.5 }, 0.15) end)
	b.MouseButton1Click:Connect(function()
		if cfg.Callback then task.spawn(cfg.Callback) end
	end)
	return { Fire = function() if cfg.Callback then task.spawn(cfg.Callback) end end }
end

function SectionClass:Textbox(cfg)
	local T = Library.Theme
	local o = self:_next()

	local row = Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = o, ZIndex = 5, Parent = self.Content })
	Create("TextLabel", { Size = UDim2.new(1, -118, 1, 0), BackgroundTransparency = 1, Text = cfg.Name or "Textbox", TextColor3 = T.Text, TextSize = 13, Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = row })
	
	local box = Create("TextBox", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(112, 26), BackgroundColor3 = T.SurfaceAlt, BorderSizePixel = 0, Text = cfg.Default or "", PlaceholderText = cfg.Placeholder or "Type...", PlaceholderColor3 = T.TextMuted, TextColor3 = T.Text, TextSize = 12, Font = T.Font, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 6, Parent = row })
	Corner(box, 6)
	Padding(box, 0, 0, 8, 8)
	local s = Stroke(box, T.Stroke, 1, 0.5)

	box.Focused:Connect(function() Tween(s, { Color = T.Accent, Transparency = 0 }, 0.13) end)
	box.FocusLost:Connect(function(enter)
		Tween(s, { Color = T.Stroke, Transparency = 0.5 }, 0.13)
		if cfg.Flag then Library.Flags[cfg.Flag] = box.Text end
		if cfg.Callback then task.spawn(cfg.Callback, box.Text, enter) end
	end)
	if cfg.Flag then Library.Flags[cfg.Flag] = box.Text end
	
	local obj = { Set = function(v) box.Text = tostring(v) end, Get = function() return box.Text end }
	if cfg.Flag then Library.Elements[cfg.Flag] = obj end
	return obj
end

function SectionClass:Dropdown(cfg)
	local T = Library.Theme
	local o = self:_next()
	local multi = cfg.Multi and true or false
	local options = cfg.Options or {}
	local sel = multi and {} or (cfg.Default or options[1])
	if multi then for _, v in ipairs(cfg.Default or {}) do sel[v] = true end end

	local function showText()
		if multi then
			local list = {}
			for k in next, sel do list[#list + 1] = k end
			table.sort(list)
			return #list > 0 and table.concat(list, ", ") or "None"
		end
		return tostring(sel or "None")
	end

	local row = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = T.SurfaceAlt, BackgroundTransparency = 0.5, Text = "", AutoButtonColor = false, LayoutOrder = o, ZIndex = 5, Parent = self.Content })
	Corner(row, 8)
	local rowS = Stroke(row, T.Stroke, 1, 0.5)
	Padding(row, 0, 0, 10, 10)
	Create("TextLabel", { Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, Text = cfg.Name or "Dropdown", TextColor3 = T.Text, TextSize = 13, Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = row })
	local valLbl = Create("TextLabel", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 0), Size = UDim2.new(0.5, -16, 1, 0), BackgroundTransparency = 1, Text = showText(), TextColor3 = T.Accent, TextSize = 12, Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Right, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6, Parent = row })
	local chev = Create("TextLabel", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 1, Text = "▾", TextColor3 = T.TextDim, TextSize = 12, Font = T.FontBold, ZIndex = 6, Parent = row })

	local overlay = Create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Visible = false, ZIndex = 190, Parent = self.Window.Main })
	local sheet = Create("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 10, 1, 10), Size = UDim2.new(1, -20, 0, 0), BackgroundColor3 = T.Background, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 200, Parent = self.Window.Main })
	local sheetCorner = Corner(sheet, 16)
	Stroke(sheet, T.Accent, 1.5, 0.4)
	Create("UIGradient", { Rotation = 90, Color = T.WindowGrad, Parent = sheet })
	
	Padding(sheet, 15, 15, 15, 15)
	Create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sheet })
	
	local handle = Create("Frame", { Size = UDim2.new(1, 0, 0, 6), BackgroundTransparency = 1, LayoutOrder = 0, ZIndex = 201, Parent = sheet })
	Create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(40, 4), BackgroundColor3 = T.SurfaceHi, BorderSizePixel = 0, ZIndex = 201, Parent = handle })

	local header = Create("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = 1, ZIndex = 201, Parent = sheet })
	Create("TextLabel", { Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1, Text = "SELECT " .. string.upper(cfg.Name or "OPTION"), TextColor3 = T.TextDim, TextSize = 12, Font = T.FontBlack, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202, Parent = header })
	local closeBtn = Create("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = T.SurfaceHi, Text = "✕", TextColor3 = T.Text, TextSize = 12, Font = T.FontBold, AutoButtonColor = false, ZIndex = 202, Parent = header })
	Corner(closeBtn, 6)

	local scroll = Create("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = T.Accent, CanvasSize = UDim2.new(), LayoutOrder = 2, ZIndex = 201, Parent = sheet })
	Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })

	local cancelBtn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = T.Danger, BackgroundTransparency = 0.2, Text = "Cancel", TextColor3 = Color3.new(1, 1, 1), TextSize = 13, Font = T.FontBold, AutoButtonColor = false, LayoutOrder = 100, ZIndex = 202, Parent = sheet })
	Corner(cancelBtn, 8)
	Stroke(cancelBtn, T.Danger, 1, 0.5)

	local closeBottomBtn = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = T.SurfaceHi, BackgroundTransparency = 0.2, Text = "Close", TextColor3 = T.Text, TextSize = 13, Font = T.FontBold, AutoButtonColor = false, LayoutOrder = 101, ZIndex = 202, Parent = sheet })
	Corner(closeBottomBtn, 8)
	Stroke(closeBottomBtn, T.Stroke, 1, 0.5)

	local items = {}
	local open = false
	
	local function refresh()
		valLbl.Text = showText()
		for opt, data in next, items do
			local on = multi and sel[opt] or (sel == opt)
			if multi then
				if on then
					data.Toggle.BackgroundColor3 = T.Accent
					data.Knob.Position = UDim2.new(1, -18, 0.5, 0)
					data.Knob.BackgroundColor3 = Color3.new(1,1,1)
				else
					data.Toggle.BackgroundColor3 = T.SurfaceHi
					data.Knob.Position = UDim2.new(0, 2, 0.5, 0)
					data.Knob.BackgroundColor3 = T.TextDim
				end
			else
				if on then
					data.Btn.BackgroundColor3 = T.Accent
					data.Btn.BackgroundTransparency = 0.8
					data.Btn.TextColor3 = T.Accent
					data.Stroke.Color = T.Accent
				else
					data.Btn.BackgroundColor3 = T.SurfaceAlt
					data.Btn.BackgroundTransparency = 0.5
					data.Btn.TextColor3 = T.Text
					data.Stroke.Color = T.Stroke
				end
			end
		end
	end

	local function close()
		if not open then return end
		open = false
		Tween(sheet, { Position = UDim2.new(0, 10, 1, 10) }, 0.25, "Snappy")
		Tween(overlay, { BackgroundTransparency = 1 }, 0.25)
		Tween(chev, { Rotation = 0 }, 0.15)
		Tween(rowS, { Color = T.Stroke, Transparency = 0.5 }, 0.15)
		task.delay(0.26, function()
			if not open then
				sheet.Visible = false
				overlay.Visible = false
			end
		end)
	end

	local function openSheet()
		open = true
		overlay.Visible = true
		sheet.Visible = true
		overlay.BackgroundTransparency = 1
		
		local mainRadius = self.Window.Main.UICorner.CornerRadius.Offset
		sheetCorner.CornerRadius = UDim.new(0, mainRadius)
		
		local maxH = self.Window.Main.AbsoluteSize.Y - 20
		local calcHeight = math.min(#options * 38 + 160, maxH)
		
		sheet.Size = UDim2.new(1, -20, 0, calcHeight)
		scroll.Size = UDim2.new(1, 0, 0, math.max(0, calcHeight - 150))
		
		sheet.Position = UDim2.new(0, 10, 1, 10)
		Tween(overlay, { BackgroundTransparency = 0.4 }, 0.25)
		Tween(sheet, { Position = UDim2.new(0, 10, 1, -10) }, 0.3, "Snappy")
		
		Tween(chev, { Rotation = 180 }, 0.15)
		Tween(rowS, { Color = T.Accent, Transparency = 0.3 }, 0.15)
	end

	local function selectOpt(opt)
		if multi then sel[opt] = (not sel[opt]) or nil else sel = opt end
		if cfg.Flag then
			if multi then
				local out = {}; for k in next, sel do out[#out + 1] = k end
				Library.Flags[cfg.Flag] = out
			else Library.Flags[cfg.Flag] = sel end
		end
		refresh()
		if cfg.Callback then
			if multi then
				local out = {}; for k in next, sel do out[#out + 1] = k end
				task.spawn(cfg.Callback, out)
			else task.spawn(cfg.Callback, sel) end
		end
		if not multi then close() end
	end

	for i, opt in ipairs(options) do
		local item = Create("TextButton", { Name = tostring(opt), Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = i, ZIndex = 202, Parent = scroll })
		
		if multi then
			Create("TextLabel", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, Text = tostring(opt), TextColor3 = T.Text, TextSize = 13, Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 203, Parent = item })
			local toggle = Create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(34, 20), BorderSizePixel = 0, ZIndex = 203, Parent = item })
			Corner(toggle, 10)
			local knob = Create("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(16, 16), BorderSizePixel = 0, ZIndex = 204, Parent = toggle })
			Corner(knob, 8)
			items[opt] = { Toggle = toggle, Knob = knob }
			item.MouseButton1Click:Connect(function() selectOpt(opt) end)
		else
			local btn = Create("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = T.SurfaceAlt, BackgroundTransparency = 0.5, Text = tostring(opt), TextColor3 = T.Text, TextSize = 13, Font = T.FontBold, AutoButtonColor = false, ZIndex = 203, Parent = item })
			Corner(btn, 8)
			local s = Stroke(btn, T.Stroke, 1, 0.3)
			items[opt] = { Btn = btn, Stroke = s }
			btn.MouseButton1Click:Connect(function() selectOpt(opt) end)
		end
	end

	row.MouseButton1Click:Connect(function() if open then close() else openSheet() end end)
	closeBtn.MouseButton1Click:Connect(close)
	cancelBtn.MouseButton1Click:Connect(close)
	closeBottomBtn.MouseButton1Click:Connect(close)
	overlay.MouseButton1Click:Connect(close)
	refresh()
	
	if cfg.Flag then 
		Library.Elements[cfg.Flag] = { 
			Set = function(v) 
				if multi then sel = {}; for _, x in ipairs(v) do sel[x] = true end else sel = v end
				refresh() 
			end, 
			Get = function() return sel end 
		} 
	end
	
	return { Set = function(v) if multi then sel = {}; for _, x in ipairs(v) do sel[x] = true end else sel = v end; refresh() end, Get = function() return sel end }
end

function SectionClass:Keybind(cfg)
	local T = Library.Theme
	local o = self:_next()
	local value = cfg.Default or Enum.KeyCode.Unknown
	local mode = cfg.Mode or "Always"
	local listening = false
	local held = false

	local row = Create("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = o, ZIndex = 5, Parent = self.Content })
	Create("TextLabel", { Size = UDim2.new(1, -90, 1, 0), BackgroundTransparency = 1, Text = cfg.Name or "Keybind", TextColor3 = T.Text, TextSize = 13, Font = T.FontBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Parent = row })
	
	local pill = Create("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(80, 24), BackgroundColor3 = T.SurfaceAlt, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 6, Parent = row })
	Corner(pill, 6)
	Stroke(pill, T.Stroke, 1, 0.5)
	local keyLbl = Create("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = value.Name, TextColor3 = T.Accent, TextSize = 12, Font = T.FontBlack, ZIndex = 7, Parent = pill })

	row.MouseButton1Click:Connect(function()
		listening = true
		keyLbl.Text = "..."
		keyLbl.TextColor3 = T.TextDim
	end)

	UserInputService.InputBegan:Connect(function(i, gp)
		if listening and i.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			value = i.KeyCode
			keyLbl.Text = value.Name
			keyLbl.TextColor3 = T.Accent
			if cfg.Flag then Library.Flags[cfg.Flag] = value end
			if cfg.Changed then task.spawn(cfg.Changed, value) end
			return
		end
		if gp or i.KeyCode ~= value then return end
		held = true
		if mode == "Always" then
			if cfg.Callback then task.spawn(cfg.Callback, true) end
		elseif mode == "Toggle" then
			held = not held
			if cfg.Callback then task.spawn(cfg.Callback, held) end
		elseif mode == "Hold" then
			if cfg.Callback then task.spawn(cfg.Callback, true) end
		end
	end)

	UserInputService.InputEnded:Connect(function(i)
		if i.KeyCode ~= value then return end
		if mode == "Hold" then
			held = false
			if cfg.Callback then task.spawn(cfg.Callback, false) end
		end
	end)

	if cfg.Flag then Library.Elements[cfg.Flag] = { Set = function(k) value = k; keyLbl.Text = k.Name end, Get = function() return value end } end
	return { Set = function(k) value = k; keyLbl.Text = k.Name end, Get = function() return value end }
end

function Library:Destroy()
	for _, w in ipairs(self.Windows) do
		if w.Gui then pcall(function() w.Gui:Destroy() end) end
	end
	self.Windows = {}
	self.Flags = {}
end

return Library
