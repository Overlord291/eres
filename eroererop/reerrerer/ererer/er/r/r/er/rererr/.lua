local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local StatsService = game:GetService("Stats")
local isMobile = UIS.TouchEnabled

local T_FAST = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local T_MED = TweenInfo.new(0.22, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local T_SMOOTH = TweenInfo.new(0.28, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local T_BACK = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local T_SLIDER = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local T_EDIT = TweenInfo.new(0.32, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

local SEARCH_ICON_ID = "rbxassetid://118685771787843"
local SETTINGS_ICON_ID = "rbxassetid://7059346373"

local VALID_CHAR_PARTS = {
	HumanoidRootPart = true, Head = true, Torso = true,
	["Left Arm"] = true, ["Right Arm"] = true, ["Left Leg"] = true, ["Right Leg"] = true,
	UpperTorso = true, LowerTorso = true,
	LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
	RightUpperArm = true, RightLowerArm = true, RightHand = true,
	LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
	RightUpperLeg = true, RightLowerLeg = true, RightFoot = true
}

local shortKeys = {
	LeftControl = "LC", RightControl = "RC", LeftShift = "LS", RightShift = "RS",
	LeftAlt = "LA", RightAlt = "RA",
	Zero = "0", One = "1", Two = "2", Three = "3", Four = "4",
	Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
	LeftBracket = "[", RightBracket = "]", Semicolon = ";", Quote = "'",
	Comma = ",", Period = ".", Slash = "/", BackSlash = "\\",
	Minus = "-", Equals = "=", Backquote = "`",
	Space = "Spc", Tab = "Tab", CapsLock = "Caps", Escape = "Esc",
	Return = "Ent", KeypadZero = "Num0", KeypadOne = "Num1", KeypadTwo = "Num2",
	KeypadThree = "Num3", KeypadFour = "Num4", KeypadFive = "Num5", KeypadSix = "Num6",
	KeypadSeven = "Num7", KeypadEight = "Num8", KeypadNine = "Num9"
}

local FontsList = {}
for _, font in pairs(Enum.Font:GetEnumItems()) do
	if font.Name ~= "Unknown" then
		table.insert(FontsList, font.Name)
	end
end
table.sort(FontsList)

local THEME_DEFAULTS = {
	Accent = Color3.fromRGB(110, 100, 255),
	Background = Color3.fromRGB(24, 23, 35),
	Sidebar = Color3.fromRGB(20, 19, 30),
	Card = Color3.fromRGB(34, 32, 48),
	CardHover = Color3.fromRGB(42, 40, 58),
	Element = Color3.fromRGB(24, 23, 35),
	ElementHover = Color3.fromRGB(32, 31, 45),
	Outlines = Color3.fromRGB(50, 48, 68),
	Input = Color3.fromRGB(16, 15, 23),
	Text = Color3.fromRGB(245, 245, 250),
	TextMuted = Color3.fromRGB(145, 142, 165),
	CloseBtn = Color3.fromRGB(255, 87, 87),
	BackgroundTrans = 0,
	HUDTransparency = 0,
	BgImageTrans = 1,
	CardTrans = 0,
	ElementTrans = 0,
	InputTrans = 0,
	TextFont = "Gotham",
	SubtextFont = "Gotham",
	BackgroundImage = "",
	TogglePosition = "Right",
	InternalOutlines = "Off",
	ElementStyle = 1,
	TopbarAlign = "Right",
	MainOutlineEnabled = false,
	DoubleOutline = false,
	CloseAnimation = 1
}

local function getFS()
	local g = (getgenv and getgenv()) or _G or {}
	local env = (getfenv and getfenv()) or {}
	return {
		isfolder = isfolder or env.isfolder or g.isfolder,
		makefolder = makefolder or env.makefolder or g.makefolder,
		listfiles = listfiles or listdir or env.listfiles or env.listdir or g.listfiles or g.listdir,
		readfile = readfile or env.readfile or g.readfile,
		writefile = writefile or env.writefile or g.writefile,
		delfile = delfile or deletefile or env.delfile or env.deletefile or g.delfile or g.deletefile
	}
end

local function safeIsFolder(path)
	local fs = getFS()
	if fs.isfolder then
		local s, res = pcall(fs.isfolder, path)
		return s and res
	end
	return false
end

local function safeMakeFolder(path)
	local fs = getFS()
	if fs.makefolder and not safeIsFolder(path) then
		pcall(fs.makefolder, path)
	end
end

local function safeWriteFile(path, content)
	local fs = getFS()
	if fs.writefile then
		return pcall(fs.writefile, path, content)
	end
	return false, "writefile not supported"
end

local function safeReadFile(path)
	local fs = getFS()
	if fs.readfile then
		local s, content = pcall(fs.readfile, path)
		if s then return content end
	end
	return nil
end

local function safeDelFile(path)
	local fs = getFS()
	if fs.delfile then
		return pcall(fs.delfile, path)
	end
	return false
end

local function safeListFiles(folder)
	local fs = getFS()
	if not fs.listfiles then return {} end
	local s, files = pcall(fs.listfiles, folder)
	if s and type(files) == "table" and next(files) ~= nil then return files end
	local s2, files2 = pcall(fs.listfiles, folder .. "/")
	if s2 and type(files2) == "table" and next(files2) ~= nil then return files2 end
	local s3, files3 = pcall(fs.listfiles, "./" .. folder)
	if s3 and type(files3) == "table" and next(files3) ~= nil then return files3 end
	local s4, files4 = pcall(fs.listfiles, "")
	if not s4 or type(files4) ~= "table" then
		s4, files4 = pcall(fs.listfiles)
	end
	if s4 and type(files4) == "table" then
		local matched = {}
		local targetFolder = folder:lower():gsub("[/\\]+$", "")
		for _, f in pairs(files4) do
			local fStr = tostring(f):lower():gsub("\\", "/")
			if fStr:find(targetFolder .. "/", 1, true) then
				table.insert(matched, f)
			end
		end
		if #matched > 0 then return matched end
	end
	if s and type(files) == "table" then return files end
	return {}
end

local function parseAsset(input)
	if input == nil or input == "" then return "" end
	if type(input) == "number" then
		return "rbxthumb://type=Asset&id=" .. tostring(math.floor(input)) .. "&w=420&h=420"
	end
	local str = tostring(input):match("^%s*(.-)%s*$")
	if str == "" then return "" end

	if str:match("^rbxthumb://") or str:match("^rbxasset://") or str:match("^rbxhttp://") then
		return str
	end

	local rbxAssetId = str:match("^rbxassetid://(%d+)")
	if rbxAssetId then
		return "rbxassetid://" .. rbxAssetId
	end

	local webTextureId = str:match("^https?://[%w%.]*roblox%.com/asset/?%?id=(%d+)")
	if webTextureId then
		return "rbxassetid://" .. webTextureId
	end

	if str:match("^[%w_]+://") then
		return str
	end

	local id = str:match("(%d+)")
	if id then
		return "rbxthumb://type=Asset&id=" .. id .. "&w=420&h=420"
	end
	return str
end

local function getFirstChar(str)
	if not str or str == "" then return "" end
	for _, code in utf8.codes(str) do
		return string.upper(utf8.char(code))
	end
	return string.upper(string.sub(str, 1, 1))
end

local function truncateTwoDots(text, font, size, maxW)
	if not text or text == "" then return "" end
	if maxW <= 10 then return ".." end
	local full = TextService:GetTextSize(text, size, font, Vector2.new(10000, 100))
	if full.X <= maxW then return text end
	local dotsW = TextService:GetTextSize("..", size, font, Vector2.new(10000, 100)).X
	local avail = maxW - dotsW
	if avail <= 0 then return ".." end
	local utfLen = utf8.len(text)
	local len = utfLen or #text
	local function prefix(n)
		if not utfLen or n == len then return string.sub(text, 1, utfLen and #text or n) end
		return string.sub(text, 1, utf8.offset(text, n + 1) - 1)
	end
	local lo, hi, best = 1, len, 0
	while lo <= hi do
		local mid = math.floor((lo + hi) / 2)
		local sub = prefix(mid)
		local w = TextService:GetTextSize(sub, size, font, Vector2.new(10000, 100)).X
		if w <= avail then
			best = mid
			lo = mid + 1
		else
			hi = mid - 1
		end
	end
	if best == 0 then return ".." end
	return prefix(best) .. ".."
end

local function resolveKeycode(value)
	if value == false then return Enum.KeyCode.Unknown end
	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then return value end
	if type(value) == "string" then
		local name = value:match("^Enum%.KeyCode%.(.+)$") or value
		return Enum.KeyCode[name]
	end
	return nil
end

local function getShortKey(keyObj)
	if type(keyObj) == "string" then return keyObj end
	if not keyObj or keyObj == Enum.KeyCode.Unknown then return "None" end
	return shortKeys[keyObj.Name] or keyObj.Name
end

local function syncKeyBoxWidth(box, btn, height)
	local w = math.max(30, math.ceil(TextService:GetTextSize(btn.Text, btn.TextSize, btn.Font, Vector2.new(500, 100)).X) + 14)
	box.Size = UDim2.new(0, w, 0, height)
	return w
end

local function parseDropdownOption(opt, iconMap)
	local name, rawIcon
	if type(opt) == "table" then
		name = tostring(opt.Name or opt.Text or opt.Title or opt[1] or "")
		rawIcon = opt.Icon or opt.Image or opt.Texture or opt.Asset or opt[2]
	else
		name = tostring(opt)
	end
	if (not rawIcon or rawIcon == "") and type(iconMap) == "table" then
		rawIcon = iconMap[name]
	end
	local icon = rawIcon and parseAsset(rawIcon) or ""
	return name, icon
end

local function copyThemeDefaults()
	local t = {}
	for k, v in pairs(THEME_DEFAULTS) do
		t[k] = v
	end
	return t
end

local Library = {}
Library.__index = Library

local function createThemeSystem(ctx)
	local THEME = ctx.THEME
	local WEAK = { __mode = "k" }
	local themeBindings = {} -- [themeKey] = weak{ [obj] = { [prop] = true } }
	local activeProps = setmetatable({}, WEAK)
	local cornerRegistry = {
		Main = setmetatable({}, WEAK),
		Element = setmetatable({}, WEAK),
		HUD = setmetatable({}, WEAK)
	}
	local strokeRegistry = {
		Block = setmetatable({}, WEAK),
		Element = setmetatable({}, WEAK),
		MainOutline = setmetatable({}, WEAK)
	}
	local doubleOutlines = {}
	local doubleCounter = 0
	local layoutBindings = {
		ToggleBox = {}, ToggleLabel = {}, ComboToggle = {},
		TopbarLayout = {}, TopbarPadding = {}, SearchContainer = {},
		ProfileBlock = {}, CloseBtn = {}, TopbarDesc = {}
	}

	local function setProp(obj, themeKey, prop)
		if prop == "Font" then
			pcall(function() obj[prop] = Enum.Font[THEME[themeKey]] end)
		elseif prop == "Image" and themeKey == "BackgroundImage" then
			obj[prop] = parseAsset(THEME[themeKey])
		else
			obj[prop] = THEME[themeKey]
		end
	end

	local function registerOnly(obj, themeKey, prop)
		prop = prop or "BackgroundColor3"
		local map = activeProps[obj]
		if not map then
			map = {}
			activeProps[obj] = map
		end
		local old = map[prop]
		if old == themeKey then return end
		-- убираем старую привязку (раньше она оставалась и копилась)
		if old then
			local oldList = themeBindings[old]
			local oe = oldList and oldList[obj]
			if oe then
				oe[prop] = nil
				if next(oe) == nil then oldList[obj] = nil end
			end
		end
		map[prop] = themeKey
		local list = themeBindings[themeKey]
		if not list then
			list = setmetatable({}, WEAK)
			themeBindings[themeKey] = list
		end
		local e = list[obj]
		if not e then
			e = {}
			list[obj] = e
		end
		e[prop] = true
	end

	function ctx.ApplyTheme(obj, themeKey, prop)
		prop = prop or "BackgroundColor3"
		registerOnly(obj, themeKey, prop)
		setProp(obj, themeKey, prop)
	end

	function ctx.TweenTheme(obj, themeKey, prop, tweenInfo)
		prop = prop or "BackgroundColor3"
		registerOnly(obj, themeKey, prop)
		local targetVal
		if prop == "Font" then
			pcall(function() obj[prop] = Enum.Font[THEME[themeKey]] end)
			return
		elseif prop == "Image" and themeKey == "BackgroundImage" then
			targetVal = parseAsset(THEME[themeKey])
		else
			targetVal = THEME[themeKey]
		end
		TS:Create(obj, tweenInfo or T_FAST, { [prop] = targetVal }):Play()
	end

	-- обновления темы склеиваются: не чаще раза в кадр
	local dirty, flushQueued = {}, false
	local function flush()
		flushQueued = false
		for key in pairs(dirty) do
			dirty[key] = nil
			local list = themeBindings[key]
			if list then
				for obj, props in pairs(list) do
					for prop in pairs(props) do
						setProp(obj, key, prop)
					end
				end
			end
		end
	end

	function ctx.UpdateTheme(themeKey, value)
		if THEME[themeKey] == value then return end
		THEME[themeKey] = value
		dirty[themeKey] = true
		if not flushQueued then
			flushQueued = true
			ctx.TrackConnection(RS.RenderStepped:Once(flush))
		end
	end

	function ctx.RegisterCorner(corner, kind, offset)
		local list = cornerRegistry[kind]
		if not list then return end
		offset = offset or 0
		list[corner] = offset
		local base = kind == "Main" and ctx.MainRadius or (kind == "HUD" and ctx.HUDRadius or ctx.ElementRadius)
		local r = (base == 0 and offset > 0) and 0 or math.max(0, base + offset)
		corner.CornerRadius = UDim.new(0, r)
	end

	function ctx.UpdateCorners(kind, radius)
		if kind == "Main" then ctx.MainRadius = radius
		elseif kind == "HUD" then ctx.HUDRadius = radius
		else ctx.ElementRadius = radius end
		local list = cornerRegistry[kind]
		if not list then return end
		for corner, off in pairs(list) do
			local r = (radius == 0 and off > 0) and 0 or math.max(0, radius + off)
			corner.CornerRadius = UDim.new(0, r)
		end
	end

	-- lazy = true: рамка создаётся только когда реально нужна (Double Outline включён)
	function ctx.AttachDoubleOutline(host, primaryStroke, cornerKind, fixedRadius, containerOverride, lazy)
		local rec = { primary = primaryStroke }

		local function build()
			local df = Instance.new("Frame")
			df.Name = "DoubleOutlineFrame"
			df.Size = UDim2.new(1, 2, 1, 2)
			df.AnchorPoint = Vector2.new(0.5, 0.5)
			df.Position = UDim2.new(0.5, 0, 0.5, 0)
			df.BackgroundTransparency = 1
			df.BorderSizePixel = 0
			df.ZIndex = math.max(0, host.ZIndex)
			df.Parent = containerOverride or host

			local dc = Instance.new("UICorner")
			dc.Parent = df
			if cornerKind == "Pill" then
				dc.CornerRadius = UDim.new(1, 0)
			elseif cornerKind then
				ctx.RegisterCorner(dc, cornerKind, 1)
			else
				local r = fixedRadius or 0
				dc.CornerRadius = UDim.new(0, r == 0 and 0 or (r + 1))
			end

			local ds = Instance.new("UIStroke")
			ds.Name = "DoubleOutlineStroke"
			ds.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ds.Thickness = 1
			ds.Enabled = false
			ds.Parent = df
			ctx.ApplyTheme(ds, "Background", "Color")
			rec.frame, rec.stroke = df, ds
		end

		function rec.sync()
			local want = (THEME.DoubleOutline == true) and primaryStroke.Enabled
			if want then
				if not rec.frame then build() end
				rec.stroke.Enabled = true
			elseif rec.stroke then
				rec.stroke.Enabled = false
			end
		end

		if not lazy then build() end

		doubleCounter = doubleCounter + 1
		if doubleCounter % 64 == 0 then
			for i = #doubleOutlines, 1, -1 do
				if not doubleOutlines[i].primary.Parent then table.remove(doubleOutlines, i) end
			end
		end
		table.insert(doubleOutlines, rec)

		ctx.TrackConnection(primaryStroke:GetPropertyChangedSignal("Enabled"):Connect(rec.sync))
		rec.sync()
		return rec.stroke, rec.frame
	end

	function ctx.UpdateDoubleOutlineMode(enabled)
		THEME.DoubleOutline = (enabled == true)
		for i = #doubleOutlines, 1, -1 do
			local rec = doubleOutlines[i]
			if not rec.primary.Parent then
				table.remove(doubleOutlines, i)
			else
				rec.sync()
			end
		end
	end

	function ctx.AttachStroke(obj, kind, cornerKind)
		local s = Instance.new("UIStroke")
		s.Name = obj.Name .. "Stroke"
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Thickness = 1
		if kind == "Block" then
			s.Enabled = (THEME.InternalOutlines == "Only Blocks" or THEME.InternalOutlines == "All")
			strokeRegistry.Block[s] = true
		elseif kind == "MainOutline" then
			s.Enabled = THEME.MainOutlineEnabled
			strokeRegistry.MainOutline[s] = true
		elseif kind == "Always" then
			s.Enabled = true
		else
			s.Enabled = (THEME.InternalOutlines == "Only Elements" or THEME.InternalOutlines == "All")
			strokeRegistry.Element[s] = true
		end
		s.Parent = obj
		ctx.ApplyTheme(s, "Outlines", "Color")
		ctx.AttachDoubleOutline(obj, s, cornerKind or "Element", nil, nil, kind ~= "MainOutline")
		return s
	end

	function ctx.UpdateInternalOutlines(opt)
		THEME.InternalOutlines = opt
		local showBlocks = (opt == "Only Blocks" or opt == "All")
		local showElems = (opt == "Only Elements" or opt == "All")
		for s in pairs(strokeRegistry.Block) do
			local blockFrame = s.Parent
			if blockFrame and not blockFrame:GetAttribute("IsDetached") then
				s.Enabled = showBlocks
			end
		end
		for s in pairs(strokeRegistry.Element) do
			if s.Parent then s.Enabled = showElems end
		end
	end

	function ctx.UpdateMainOutline(enabled)
		THEME.MainOutlineEnabled = enabled
		for s in pairs(strokeRegistry.MainOutline) do
			if s.Parent then s.Enabled = enabled end
		end
		if ctx.OnMainOutlineChanged then
			ctx.OnMainOutlineChanged(enabled)
		end
	end

	function ctx.BindLayout(group, obj)
		if layoutBindings[group] then
			table.insert(layoutBindings[group], obj)
		end
	end

	function ctx.UpdateTogglePosition(posMode)
		THEME.TogglePosition = posMode
		local isCompact = (THEME.ElementStyle == 3 or THEME.ElementStyle == 4)
		local edge = isCompact and 5 or 7
		local boxSize = isCompact and 18 or 24
		for i = #layoutBindings.ToggleBox, 1, -1 do
			local tb = layoutBindings.ToggleBox[i]
			if not tb or not tb.Parent then
				table.remove(layoutBindings.ToggleBox, i)
			elseif posMode == "Left" then
				tb.AnchorPoint = Vector2.new(0, 0.5)
				tb.Position = UDim2.new(0, edge, 0.5, 0)
			else
				tb.AnchorPoint = Vector2.new(1, 0.5)
				tb.Position = UDim2.new(1, -edge, 0.5, 0)
			end
		end
		for i = #layoutBindings.ToggleLabel, 1, -1 do
			local lbl = layoutBindings.ToggleLabel[i]
			if not lbl or not lbl.Parent then
				table.remove(layoutBindings.ToggleLabel, i)
			elseif posMode == "Left" then
				lbl.Position = UDim2.new(0, edge + boxSize + 7, 0, 0)
				lbl.Size = UDim2.new(1, -(edge + boxSize + 15), 1, 0)
			else
				lbl.Position = UDim2.new(0, 15, 0, 0)
				lbl.Size = UDim2.new(1, -60, 1, 0)
			end
		end
		for i = #layoutBindings.ComboToggle, 1, -1 do
			local c = layoutBindings.ComboToggle[i]
			if not c or not c.Parent then
				table.remove(layoutBindings.ComboToggle, i)
			else
				c:SetAttribute("TogglePos", posMode)
			end
		end
	end

	function ctx.UpdateTopbarAlign(align)
		THEME.TopbarAlign = align
		for _, l in ipairs(layoutBindings.TopbarLayout) do
			l.HorizontalAlignment = (align == "Left") and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Right
		end
		for _, p in ipairs(layoutBindings.TopbarPadding) do
			p.PaddingLeft = UDim.new(0, align == "Left" and 14 or 0)
			p.PaddingRight = UDim.new(0, align == "Left" and 0 or 14)
		end
		for _, s in ipairs(layoutBindings.SearchContainer) do
			s.LayoutOrder = (align == "Left") and 3 or 1
		end
		for _, p in ipairs(layoutBindings.ProfileBlock) do
			p.LayoutOrder = 2
		end
		for _, b in ipairs(layoutBindings.CloseBtn) do
			b.LayoutOrder = (align == "Left") and 1 or 3
		end
		for _, d in ipairs(layoutBindings.TopbarDesc) do
			if align == "Left" then
				d.Position = UDim2.new(0, 440, 0, 0)
				d.Size = UDim2.new(1, -455, 1, 0)
				d.TextXAlignment = Enum.TextXAlignment.Right
			else
				d.Position = UDim2.new(0, 15, 0, 0)
				d.Size = UDim2.new(1, -455, 1, 0)
				d.TextXAlignment = Enum.TextXAlignment.Left
			end
		end
	end

	function ctx.CleanupThemeSystem()
		table.clear(themeBindings)
		table.clear(activeProps)
		table.clear(dirty)
		for _, list in pairs(layoutBindings) do table.clear(list) end
		table.clear(doubleOutlines)
		table.clear(cornerRegistry.Main)
		table.clear(cornerRegistry.Element)
		table.clear(cornerRegistry.HUD)
		table.clear(strokeRegistry.Block)
		table.clear(strokeRegistry.Element)
		table.clear(strokeRegistry.MainOutline)
	end
end

local function createInputController(ctx)
	local dragHandler = nil
	local dragEndHandler = nil
	local dragEndType = nil
	local keyListeners = {}

	function ctx.StartDrag(endType, moveFn, endFn)
		dragEndType = endType
		dragHandler = moveFn
		dragEndHandler = endFn
	end

	function ctx.RegisterKeyListener(fn)
		table.insert(keyListeners, fn)
	end

	ctx.TrackConnection(UIS.InputChanged:Connect(function(input)
		if dragHandler and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			dragHandler(input)
		end
	end))

	ctx.TrackConnection(UIS.InputEnded:Connect(function(input)
		if dragHandler and (input.UserInputType == dragEndType or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
			if dragEndType == Enum.UserInputType.MouseButton2 and input.UserInputType ~= Enum.UserInputType.MouseButton2 then
				return
			end
			local cb = dragEndHandler
			dragHandler = nil
			dragEndHandler = nil
			dragEndType = nil
			if cb then cb(input) end
		end
	end))

	ctx.TrackConnection(UIS.InputBegan:Connect(function(input, gameProcessed)
		if ctx.ActiveKeyBinder then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				local binder = ctx.ActiveKeyBinder
				ctx.ActiveKeyBinder = nil
				binder(input.KeyCode)
			end
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == ctx.OpenKeybind and not UIS:GetFocusedTextBox() then
			ctx.ToggleUI()
			return
		end

		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			for i = 1, #keyListeners do
				keyListeners[i](input.KeyCode)
			end
		end
	end))
end

local function createNotificationSystem(ctx, notifPosition)
	local THEME = ctx.THEME
	local notifHolder = Instance.new("Frame")
	notifHolder.Name = "NotificationHolder"
	notifHolder.BackgroundTransparency = 1
	notifHolder.Size = isMobile and UDim2.new(0, 280, 1, -120) or UDim2.new(0, 300, 1, -40)
	notifHolder.ZIndex = 100000
	notifHolder.Parent = ctx.screenGui

	local notifLayout = Instance.new("UIListLayout")
	notifLayout.Padding = UDim.new(0, 10)
	notifLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local notifScale = Instance.new("UIScale")
	notifScale.Scale = isMobile and 0.65 or 1
	notifScale.Parent = notifHolder

	local isTop = string.find(notifPosition, "Top") ~= nil
	local isLeft = string.find(notifPosition, "Left") ~= nil

	if isTop and isLeft then
		notifHolder.AnchorPoint = Vector2.new(0, 0)
		notifHolder.Position = isMobile and UDim2.new(0, 12, 0, 70) or UDim2.new(0, 20, 0, 20)
		notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	elseif isTop and not isLeft then
		notifHolder.AnchorPoint = Vector2.new(1, 0)
		notifHolder.Position = isMobile and UDim2.new(1, -12, 0, 70) or UDim2.new(1, -20, 0, 20)
		notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	elseif not isTop and isLeft then
		notifHolder.AnchorPoint = Vector2.new(0, 1)
		notifHolder.Position = isMobile and UDim2.new(0, 12, 1, -90) or UDim2.new(0, 20, 1, -20)
		notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	else
		notifHolder.AnchorPoint = Vector2.new(1, 1)
		notifHolder.Position = isMobile and UDim2.new(1, -12, 1, -90) or UDim2.new(1, -20, 1, -20)
		notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	end
	notifLayout.Parent = notifHolder

	local notifCount = 0
	local activeNotifs = {}
	local notifHeartbeat = nil

	local function ensureTimerLoop()
		if notifHeartbeat then return end
		notifHeartbeat = RS.Heartbeat:Connect(function()
			if #activeNotifs == 0 then
				notifHeartbeat:Disconnect()
				notifHeartbeat = nil
				return
			end
			local now = os.clock()
			for i = #activeNotifs, 1, -1 do
				local item = activeNotifs[i]
				local rem = math.max(0, item.EndTime - now)
				local fmt = string.format("%.1fs", rem)
				if fmt ~= item.LastFmt then
					item.LastFmt = fmt
					item.Label.Text = fmt
				end
				if rem <= 0 then
					table.remove(activeNotifs, i)
					item.Close()
				end
			end
		end)
		ctx.TrackConnection(notifHeartbeat)
	end

	function ctx.Window:Notify(notifConfig)
		local nTitle = notifConfig.Title or "Notification"
		local nContent = notifConfig.Description or notifConfig.Content or ""
		local nDuration = notifConfig.Duration or 5
		local nIcon = parseAsset(notifConfig.Icon)
		local isCompact = (THEME.ElementStyle == 3 or THEME.ElementStyle == 4)
		notifCount = notifCount + 1

		local notifWrapper = Instance.new("Frame")
		notifWrapper.Name = "NotifWrapper"
		notifWrapper.BackgroundTransparency = 1
		notifWrapper.Size = UDim2.new(1, 0, 0, 80)
		notifWrapper.LayoutOrder = isTop and -notifCount or notifCount
		notifWrapper.Parent = notifHolder

		local notif = Instance.new("Frame")
		notif.Name = "Notification"
		notif.Size = UDim2.new(1, 0, 0, 80)
		notif.BackgroundTransparency = 1
		notif.Parent = notifWrapper
		ctx.ApplyTheme(notif, "Background", "BackgroundColor3")
		ctx.ApplyTheme(notif, "HUDTransparency", "BackgroundTransparency")

		local corner = Instance.new("UICorner")
		corner.Parent = notif
		ctx.RegisterCorner(corner, "HUD")

		local stroke = ctx.AttachStroke(notif, "MainOutline", "HUD")

		local notifInner = Instance.new("Frame")
		notifInner.Size = UDim2.new(1, 0, 0, 0)
		notifInner.AutomaticSize = Enum.AutomaticSize.Y
		notifInner.BackgroundTransparency = 1
		notifInner.ZIndex = 2
		notifInner.Parent = notif

		local function syncNotifH()
			if not notifInner.Parent then return end
			local h = math.max(40, notifInner.AbsoluteSize.Y)
			notif.Size = UDim2.new(1, 0, 0, h)
			notifWrapper.Size = UDim2.new(1, 0, 0, h)
		end
		ctx.TrackConnection(notifInner:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncNotifH))

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, isCompact and 10 or 15)
		pad.PaddingBottom = UDim.new(0, isCompact and 10 or 15)
		pad.PaddingLeft = UDim.new(0, isCompact and 11 or 15)
		pad.PaddingRight = UDim.new(0, isCompact and 11 or 15)
		pad.Parent = notifInner

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.Padding = UDim.new(0, isCompact and 8 or 12)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = notifInner

		local topContent = Instance.new("Frame")
		topContent.Size = UDim2.new(1, 0, 0, 0)
		topContent.AutomaticSize = Enum.AutomaticSize.Y
		topContent.BackgroundTransparency = 1
		topContent.LayoutOrder = 1
		topContent.Parent = notifInner

		local topLayout = Instance.new("UIListLayout")
		topLayout.FillDirection = Enum.FillDirection.Horizontal
		topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		topLayout.Padding = UDim.new(0, isCompact and 9 or 12)
		topLayout.SortOrder = Enum.SortOrder.LayoutOrder
		topLayout.Parent = topContent

		local hasIcon = (nIcon and nIcon ~= "")
		local iconSize = isCompact and 28 or 36
		local iconImg
		if hasIcon then
			iconImg = Instance.new("ImageLabel")
			iconImg.Size = UDim2.new(0, iconSize, 0, iconSize)
			iconImg.BackgroundTransparency = 1
			iconImg.Image = nIcon
			iconImg.LayoutOrder = isLeft and 2 or 1
			iconImg.Parent = topContent
			ctx.ApplyTheme(iconImg, "Text", "ImageColor3")
		end

		local txtFrame = Instance.new("Frame")
		txtFrame.BackgroundTransparency = 1
		txtFrame.Size = UDim2.new(1, hasIcon and -(iconSize + (isCompact and 9 or 12)) or 0, 0, 0)
		txtFrame.AutomaticSize = Enum.AutomaticSize.Y
		txtFrame.LayoutOrder = isLeft and 1 or 2
		txtFrame.Parent = topContent

		local txtLayout = Instance.new("UIListLayout")
		txtLayout.FillDirection = Enum.FillDirection.Vertical
		txtLayout.Padding = UDim.new(0, 3)
		txtLayout.Parent = txtFrame

		local titleLbl = Instance.new("TextLabel")
		titleLbl.BackgroundTransparency = 1
		titleLbl.Size = UDim2.new(1, 0, 0, 0)
		titleLbl.AutomaticSize = Enum.AutomaticSize.Y
		titleLbl.TextWrapped = true
		titleLbl.TextXAlignment = isLeft and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
		titleLbl.TextSize = isCompact and 13 or 15
		titleLbl.Text = nTitle
		titleLbl.Parent = txtFrame
		ctx.ApplyTheme(titleLbl, "Text", "TextColor3")
		ctx.ApplyTheme(titleLbl, "TextFont", "Font")

		local descLbl = Instance.new("TextLabel")
		descLbl.BackgroundTransparency = 1
		descLbl.Size = UDim2.new(1, 0, 0, 0)
		descLbl.AutomaticSize = Enum.AutomaticSize.Y
		descLbl.TextWrapped = true
		descLbl.TextXAlignment = isLeft and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
		descLbl.TextSize = isCompact and 11 or 13
		descLbl.Text = nContent
		descLbl.Parent = txtFrame
		ctx.ApplyTheme(descLbl, "TextMuted", "TextColor3")
		ctx.ApplyTheme(descLbl, "SubtextFont", "Font")

		local bottomContainer = Instance.new("Frame")
		bottomContainer.Size = UDim2.new(1, 0, 0, isCompact and 16 or 20)
		bottomContainer.BackgroundTransparency = 1
		bottomContainer.LayoutOrder = 2
		bottomContainer.Parent = notifInner

		local badgeW = isCompact and 36 or 40
		local track = Instance.new("Frame")
		track.Size = UDim2.new(1, -(badgeW + 8), 0, isCompact and 3 or 4)
		track.AnchorPoint = Vector2.new(0, 0.5)
		track.Position = UDim2.new(0, 0, 0.5, 0)
		track.BorderSizePixel = 0
		track.Parent = bottomContainer
		ctx.ApplyTheme(track, "Input", "BackgroundColor3")
		ctx.ApplyTheme(track, "InputTrans", "BackgroundTransparency")

		local trackCorner = Instance.new("UICorner")
		trackCorner.CornerRadius = UDim.new(1, 0)
		trackCorner.Parent = track

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(1, 0, 1, 0)
		fill.BorderSizePixel = 0
		fill.Parent = track
		ctx.ApplyTheme(fill, "Accent", "BackgroundColor3")

		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(1, 0)
		fillCorner.Parent = fill

		local timeBadge = Instance.new("Frame")
		timeBadge.Size = UDim2.new(0, badgeW, 1, 0)
		timeBadge.AnchorPoint = Vector2.new(1, 0.5)
		timeBadge.Position = UDim2.new(1, 0, 0.5, 0)
		timeBadge.BorderSizePixel = 0
		timeBadge.Parent = bottomContainer
		ctx.ApplyTheme(timeBadge, "Input", "BackgroundColor3")
		ctx.ApplyTheme(timeBadge, "InputTrans", "BackgroundTransparency")

		local timeBadgeCorner = Instance.new("UICorner")
		timeBadgeCorner.Parent = timeBadge
		ctx.RegisterCorner(timeBadgeCorner, "HUD")

		local timeBadgeStroke = Instance.new("UIStroke")
		timeBadgeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		timeBadgeStroke.Thickness = 1
		timeBadgeStroke.Parent = timeBadge
		ctx.ApplyTheme(timeBadgeStroke, "Outlines", "Color")

		local timeLabel = Instance.new("TextLabel")
		timeLabel.Size = UDim2.new(1, 0, 1, 0)
		timeLabel.Position = UDim2.new(0, 0, 0, -1)
		timeLabel.BackgroundTransparency = 1
		timeLabel.TextSize = isCompact and 10 or 11
		timeLabel.TextXAlignment = Enum.TextXAlignment.Center
		timeLabel.Text = string.format("%.1fs", nDuration)
		timeLabel.Parent = timeBadge
		ctx.ApplyTheme(timeLabel, "TextMuted", "TextColor3")
		ctx.ApplyTheme(timeLabel, "SubtextFont", "Font")

		syncNotifH()
		task.defer(syncNotifH)

		local closed = false
		local doubleFrame = notif:FindFirstChild("DoubleOutlineFrame")
		local doubleStroke = doubleFrame and doubleFrame:FindFirstChild("DoubleOutlineStroke")

		local function closeNotification()
			if closed then return end
			closed = true
			local fadeOut = TS:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1,
				Position = isLeft and UDim2.new(0, -350, 0, 0) or UDim2.new(0, 350, 0, 0)
			})
			TS:Create(stroke, T_MED, { Transparency = 1 }):Play()
			if doubleStroke then TS:Create(doubleStroke, T_MED, { Transparency = 1 }):Play() end
			fadeOut:Play()
			fadeOut.Completed:Once(function()
				notifWrapper:Destroy()
			end)
		end

		notif.Position = isLeft and UDim2.new(0, -350, 0, 0) or UDim2.new(0, 350, 0, 0)
		notif.BackgroundTransparency = 1
		stroke.Transparency = 1
		if doubleStroke then doubleStroke.Transparency = 1 end

		TS:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			BackgroundTransparency = THEME.HUDTransparency,
			Position = UDim2.new(0, 0, 0, 0)
		}):Play()
		TS:Create(stroke, T_MED, { Transparency = 0 }):Play()
		if doubleStroke then TS:Create(doubleStroke, T_MED, { Transparency = 0 }):Play() end

		TS:Create(fill, TweenInfo.new(nDuration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 1, 0)
		}):Play()

		table.insert(activeNotifs, {
			EndTime = os.clock() + nDuration,
			LastFmt = "",
			Label = timeLabel,
			Close = closeNotification
		})
		ensureTimerLoop()

		local api = {}
		function api:SetTitle(newTitle) if titleLbl then titleLbl.Text = newTitle end end
		function api:SetDescription(newDesc) if descLbl then descLbl.Text = newDesc end end
		function api:SetIcon(newIcon) if iconImg then iconImg.Image = parseAsset(newIcon) end end
		function api:Close() closeNotification() end
		return api
	end
end

local function createWatermarkSystem(ctx, watermarkEnabled, logoIconId)
	local wmH = isMobile and 34 or 40

	local wmHolder = Instance.new("Frame")
	wmHolder.Name = "WatermarkHolder"
	wmHolder.AnchorPoint = Vector2.new(0.5, 0)
	wmHolder.Position = isMobile and UDim2.new(0.5, 0, 0, 8) or UDim2.new(0.5, 0, 0, 20)
	wmHolder.Size = UDim2.new(0, 200, 0, wmH)
	wmHolder.BackgroundTransparency = 1
	wmHolder.Active = true
	wmHolder.ZIndex = 99999
	wmHolder.Visible = watermarkEnabled
	wmHolder.Parent = ctx.screenGui

	local wmBar = Instance.new("Frame")
	wmBar.Name = "WatermarkBar"
	wmBar.Size = UDim2.fromScale(1, 1)
	wmBar.BorderSizePixel = 0
	wmBar.ZIndex = 2
	wmBar.Parent = wmHolder
	ctx.ApplyTheme(wmBar, "Background", "BackgroundColor3")
	ctx.ApplyTheme(wmBar, "HUDTransparency", "BackgroundTransparency")

	local wmCorner = Instance.new("UICorner")
	wmCorner.Parent = wmBar
	ctx.RegisterCorner(wmCorner, "HUD")
	ctx.AttachStroke(wmBar, "MainOutline", "HUD")

	local wmInner = Instance.new("Frame")
	wmInner.Size = UDim2.new(0, 0, 1, 0)
	wmInner.AutomaticSize = Enum.AutomaticSize.X
	wmInner.BackgroundTransparency = 1
	wmInner.ZIndex = 3
	wmInner.Parent = wmBar

	local function syncWMSize()
		if wmInner.AbsoluteSize.X > 0 then
			wmHolder.Size = UDim2.new(0, wmInner.AbsoluteSize.X, 0, wmH)
		end
	end
	ctx.TrackConnection(wmInner:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncWMSize))

	local wmPadding = Instance.new("UIPadding")
	wmPadding.PaddingLeft = UDim.new(0, isMobile and 9 or 14)
	wmPadding.PaddingRight = UDim.new(0, isMobile and 10 or 16)
	wmPadding.Parent = wmInner

	local wmLayout = Instance.new("UIListLayout")
	wmLayout.FillDirection = Enum.FillDirection.Horizontal
	wmLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	wmLayout.SortOrder = Enum.SortOrder.LayoutOrder
	wmLayout.Padding = UDim.new(0, isMobile and 7 or 10)
	wmLayout.Parent = wmInner

	local wmLogo = Instance.new("ImageLabel")
	wmLogo.Name = "WMLogo"
	wmLogo.Size = UDim2.new(0, isMobile and 18 or 22, 0, isMobile and 18 or 22)
	wmLogo.BackgroundTransparency = 1
	wmLogo.Image = (logoIconId and logoIconId ~= "") and logoIconId or SEARCH_ICON_ID
	wmLogo.LayoutOrder = 1
	wmLogo.Parent = wmInner
	ctx.ApplyTheme(wmLogo, "Accent", "ImageColor3")

	local function createDiv(order)
		local div = Instance.new("Frame")
		div.Size = UDim2.new(0, 1, 0, isMobile and 14 or 18)
		div.BorderSizePixel = 0
		div.LayoutOrder = order
		div.Parent = wmInner
		ctx.ApplyTheme(div, "Outlines", "BackgroundColor3")
	end

	createDiv(2)
	local wmFps = Instance.new("TextLabel")
	wmFps.AutomaticSize = Enum.AutomaticSize.X
	wmFps.Size = UDim2.new(0, 0, 1, 0)
	wmFps.BackgroundTransparency = 1
	wmFps.TextSize = isMobile and 11 or 14
	wmFps.Text = "60 fps"
	wmFps.LayoutOrder = 3
	wmFps.Parent = wmInner
	ctx.ApplyTheme(wmFps, "Text", "TextColor3")
	ctx.ApplyTheme(wmFps, "TextFont", "Font")

	createDiv(4)
	local wmPing = Instance.new("TextLabel")
	wmPing.AutomaticSize = Enum.AutomaticSize.X
	wmPing.Size = UDim2.new(0, 0, 1, 0)
	wmPing.BackgroundTransparency = 1
	wmPing.TextSize = isMobile and 11 or 14
	wmPing.Text = "0 ms"
	wmPing.LayoutOrder = 5
	wmPing.Parent = wmInner
	ctx.ApplyTheme(wmPing, "Text", "TextColor3")
	ctx.ApplyTheme(wmPing, "TextFont", "Font")

	createDiv(6)
	local wmUser = Instance.new("TextLabel")
	wmUser.AutomaticSize = Enum.AutomaticSize.X
	wmUser.Size = UDim2.new(0, 0, 1, 0)
	wmUser.BackgroundTransparency = 1
	wmUser.TextSize = isMobile and 11 or 14
	wmUser.Text = LP.DisplayName
	wmUser.LayoutOrder = 7
	wmUser.Parent = wmInner
	ctx.ApplyTheme(wmUser, "Text", "TextColor3")
	ctx.ApplyTheme(wmUser, "TextFont", "Font")

	task.defer(syncWMSize)

	local wmTargetPos = wmHolder.Position
	local wmDragging = false
	local wmDragConn = nil

	local function startWMLoop()
		if wmDragConn then return end
		wmDragConn = RS.RenderStepped:Connect(function(dt)
			if not wmHolder.Parent then
				if wmDragConn then wmDragConn:Disconnect(); wmDragConn = nil end
				return
			end
			local diffX = math.abs(wmHolder.Position.X.Offset - wmTargetPos.X.Offset)
			local diffY = math.abs(wmHolder.Position.Y.Offset - wmTargetPos.Y.Offset)
			if diffX > 0.1 or diffY > 0.1 then
				wmHolder.Position = wmHolder.Position:Lerp(wmTargetPos, 1 - math.exp(-28 * dt))
			else
				wmHolder.Position = wmTargetPos
				if not wmDragging then
					wmDragConn:Disconnect()
					wmDragConn = nil
				end
			end
		end)
		ctx.TrackConnection(wmDragConn)
	end

	ctx.TrackConnection(wmHolder.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			wmDragging = true
			local startMouse = input.Position
			local startPos = wmTargetPos
			startWMLoop()
			ctx.StartDrag(input.UserInputType, function(moveInput)
				local delta = moveInput.Position - startMouse
				wmTargetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				startWMLoop()
			end, function()
				wmDragging = false
			end)
		end
	end))

	local fpsFrames, fpsElapsed = 0, 0
	ctx.TrackConnection(RS.RenderStepped:Connect(function(dt)
		if not wmHolder.Visible then
			fpsFrames, fpsElapsed = 0, 0
			return
		end
		fpsFrames = fpsFrames + 1
		fpsElapsed = fpsElapsed + dt
		if fpsElapsed >= 0.5 then
			wmFps.Text = tostring(math.round(fpsFrames / fpsElapsed)) .. " fps"
			fpsFrames, fpsElapsed = 0, 0
		end
	end))

	task.spawn(function()
		while wmHolder.Parent do
			task.wait(2.0)
			if not wmHolder.Parent then break end
			if wmHolder.Visible then
				local pingVal = 0
				pcall(function()
					local netStats = StatsService:FindFirstChild("Network")
					if netStats and netStats:FindFirstChild("ServerStatsItem") then
						local pingItem = netStats.ServerStatsItem:FindFirstChild("Data Ping")
						if pingItem then pingVal = math.round(pingItem:GetValue()) end
					end
					if pingVal == 0 then
						local perf = StatsService:FindFirstChild("PerformanceStats")
						if perf and perf:FindFirstChild("Ping") then pingVal = math.round(perf.Ping:GetValue()) end
					end
					if pingVal == 0 then
						local rawPing = LP:GetNetworkPing()
						if rawPing and rawPing > 0 then pingVal = math.round(rawPing * 2000) end
					end
				end)
				wmPing.Text = tostring(pingVal) .. " ms"
			end
		end
	end)

	ctx.GetWatermarkPos = function()
		return { wmTargetPos.X.Scale, wmTargetPos.X.Offset, wmTargetPos.Y.Scale, wmTargetPos.Y.Offset }
	end
	ctx.SetWatermarkPos = function(arr)
		if type(arr) == "table" and #arr == 4 then
			wmTargetPos = UDim2.new(arr[1], arr[2], arr[3], arr[4])
			wmHolder.Position = wmTargetPos
		end
	end

	ctx.Window.Watermark = {
		SetVisible = function(self, state)
			wmHolder.Visible = state
			local control = ctx.Window._themeControls["Layout & Styles~Show Watermark"]
			if control then control.API:Set(state == true) end
		end,
		SetLogo = function(self, id)
			wmLogo.Image = parseAsset(id)
		end
	}
	return wmHolder
end

local function createKeybindsHUD(ctx, keybindsEnabled)
	local KB_WIDTH = 195
	local VISIBLE_EDGE = 14
	local kbDockSide = "Right"
	local kbIsOpen = false
	local kbOffsetY = 0
	local kbDragging = false

	local kbHolder = Instance.new("Frame")
	kbHolder.Name = "KeybindsHUD"
	kbHolder.Size = UDim2.new(0, KB_WIDTH, 0, 61)
	kbHolder.AnchorPoint = Vector2.new(0, 0.5)
	kbHolder.BackgroundTransparency = 1
	kbHolder.ZIndex = 9000
	kbHolder.Visible = keybindsEnabled
	kbHolder.Parent = ctx.screenGui

	ctx.Window.Keybinds = {
		SetVisible = function(self, state)
			kbHolder.Visible = state
			local control = ctx.Window._themeControls["Layout & Styles~Show Keybinds HUD"]
			if control then control.API:Set(state == true) end
		end
	}

	local kbMain = Instance.new("Frame")
	kbMain.Name = "MainCard"
	kbMain.Size = UDim2.fromScale(1, 1)
	kbMain.BorderSizePixel = 0
	kbMain.ZIndex = 9001
	kbMain.Parent = kbHolder
	ctx.ApplyTheme(kbMain, "Background", "BackgroundColor3")
	ctx.ApplyTheme(kbMain, "HUDTransparency", "BackgroundTransparency")

	local kbCorner = Instance.new("UICorner")
	kbCorner.Parent = kbMain
	ctx.RegisterCorner(kbCorner, "HUD")
	ctx.AttachStroke(kbMain, "MainOutline", "HUD")

	local kbBar = Instance.new("Frame")
	kbBar.Size = UDim2.new(0, 3, 0, 44)
	kbBar.BorderSizePixel = 0
	kbBar.ZIndex = 9003
	kbBar.Parent = kbMain
	ctx.ApplyTheme(kbBar, "Accent", "BackgroundColor3")

	local kbBarCorner = Instance.new("UICorner")
	kbBarCorner.CornerRadius = UDim.new(1, 0)
	kbBarCorner.Parent = kbBar

	local kbEdgeBtn = Instance.new("TextButton")
	kbEdgeBtn.BackgroundTransparency = 1
	kbEdgeBtn.Text = ""
	kbEdgeBtn.ZIndex = 9004
	kbEdgeBtn.Parent = kbMain

	local kbHeader = Instance.new("TextButton")
	kbHeader.Size = UDim2.new(1, 0, 0, 28)
	kbHeader.BackgroundTransparency = 1
	kbHeader.Text = ""
	kbHeader.ZIndex = 9002
	kbHeader.Parent = kbMain

	local kbTitle = Instance.new("TextLabel")
	kbTitle.Size = UDim2.new(1, -20, 1, 0)
	kbTitle.Position = UDim2.new(0, 16, 0, 0)
	kbTitle.BackgroundTransparency = 1
	kbTitle.Text = "Keybinds"
	kbTitle.TextSize = 12
	kbTitle.TextXAlignment = Enum.TextXAlignment.Left
	kbTitle.Parent = kbHeader
	ctx.ApplyTheme(kbTitle, "Text", "TextColor3")
	ctx.ApplyTheme(kbTitle, "TextFont", "Font")

	local kbDivider = Instance.new("Frame")
	kbDivider.Size = UDim2.new(1, -20, 0, 1)
	kbDivider.Position = UDim2.new(0.5, 0, 1, -1)
	kbDivider.AnchorPoint = Vector2.new(0.5, 1)
	kbDivider.BorderSizePixel = 0
	kbDivider.Parent = kbHeader
	ctx.ApplyTheme(kbDivider, "Outlines", "BackgroundColor3")

	local kbEntries = Instance.new("ScrollingFrame")
	kbEntries.Size = UDim2.new(1, 0, 0, 32)
	kbEntries.Position = UDim2.new(0, 0, 0, 29)
	kbEntries.BackgroundTransparency = 1
	kbEntries.BorderSizePixel = 0
	kbEntries.ScrollBarThickness = 2
	kbEntries.CanvasSize = UDim2.new(0, 0, 0, 0)
	kbEntries.AutomaticCanvasSize = Enum.AutomaticSize.Y
	kbEntries.ZIndex = 9002
	kbEntries.Parent = kbMain
	ctx.ApplyTheme(kbEntries, "Outlines", "ScrollBarImageColor3")

	local kbLayout = Instance.new("UIListLayout")
	kbLayout.SortOrder = Enum.SortOrder.LayoutOrder
	kbLayout.Padding = UDim.new(0, 4)
	kbLayout.Parent = kbEntries

	local kbPad = Instance.new("UIPadding")
	kbPad.PaddingTop = UDim.new(0, 6)
	kbPad.PaddingBottom = UDim.new(0, 8)
	kbPad.PaddingLeft = UDim.new(0, 14)
	kbPad.PaddingRight = UDim.new(0, 8)
	kbPad.Parent = kbEntries

	local kbTargetPos = UDim2.new(1, -VISIBLE_EDGE, 0.5, kbOffsetY)

	local function UpdateKBDocking()
		if kbDockSide == "Right" then
			kbBar.AnchorPoint = Vector2.new(0, 0.5)
			kbBar.Position = UDim2.new(0, 5, 0.5, 0)
			kbEdgeBtn.AnchorPoint = Vector2.new(0, 0)
			kbEdgeBtn.Position = UDim2.new(0, 0, 0, 0)
			kbEdgeBtn.Size = UDim2.new(0, VISIBLE_EDGE + 6, 1, 0)
			kbTitle.Position = UDim2.new(0, 16, 0, 0)
			kbPad.PaddingLeft = UDim.new(0, 15)
			kbPad.PaddingRight = UDim.new(0, 8)
			kbTargetPos = kbIsOpen and UDim2.new(1, -KB_WIDTH - 8, 0.5, kbOffsetY) or UDim2.new(1, -VISIBLE_EDGE, 0.5, kbOffsetY)
		else
			kbBar.AnchorPoint = Vector2.new(1, 0.5)
			kbBar.Position = UDim2.new(1, -5, 0.5, 0)
			kbEdgeBtn.AnchorPoint = Vector2.new(1, 0)
			kbEdgeBtn.Position = UDim2.new(1, 0, 0, 0)
			kbEdgeBtn.Size = UDim2.new(0, VISIBLE_EDGE + 6, 1, 0)
			kbTitle.Position = UDim2.new(0, 10, 0, 0)
			kbPad.PaddingLeft = UDim.new(0, 8)
			kbPad.PaddingRight = UDim.new(0, 15)
			kbTargetPos = kbIsOpen and UDim2.new(0, 8, 0.5, kbOffsetY) or UDim2.new(0, -KB_WIDTH + VISIBLE_EDGE, 0.5, kbOffsetY)
		end
	end

	local kbStepConn = nil
	local function startKBLoop()
		if kbStepConn then return end
		kbStepConn = RS.RenderStepped:Connect(function(dt)
			if not kbHolder.Parent then
				if kbStepConn then kbStepConn:Disconnect(); kbStepConn = nil end
				return
			end
			local diffX = math.abs(kbHolder.Position.X.Offset - kbTargetPos.X.Offset)
			local diffY = math.abs(kbHolder.Position.Y.Offset - kbTargetPos.Y.Offset)
			if diffX > 0.1 or diffY > 0.1 then
				kbHolder.Position = kbHolder.Position:Lerp(kbTargetPos, 1 - math.exp(-26 * dt))
			else
				kbHolder.Position = kbTargetPos
				if not kbDragging then
					kbStepConn:Disconnect()
					kbStepConn = nil
				end
			end
		end)
		ctx.TrackConnection(kbStepConn)
	end

	UpdateKBDocking()
	kbHolder.Position = kbTargetPos

	ctx.TrackConnection(kbEdgeBtn.MouseButton1Click:Connect(function()
		kbIsOpen = not kbIsOpen
		UpdateKBDocking()
		startKBLoop()
	end))

	ctx.TrackConnection(kbHeader.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			kbDragging = true
			local startMouseX, startMouseY = input.Position.X, input.Position.Y
			local startPosX, startPosY = kbHolder.Position.X.Offset, kbHolder.Position.Y.Offset
			startKBLoop()
			ctx.StartDrag(input.UserInputType, function(moveInput)
				kbTargetPos = UDim2.new(kbHolder.Position.X.Scale, startPosX + (moveInput.Position.X - startMouseX), 0.5, startPosY + (moveInput.Position.Y - startMouseY))
				startKBLoop()
			end, function(endInput)
				kbDragging = false
				local screenW = ctx.screenGui.AbsoluteSize.X
				local screenH = ctx.screenGui.AbsoluteSize.Y
				kbDockSide = (endInput.Position.X < screenW / 2) and "Left" or "Right"
				kbOffsetY = math.clamp(kbTargetPos.Y.Offset, -screenH / 2 + 60, screenH / 2 - 60)
				UpdateKBDocking()
				startKBLoop()
			end)
		end
	end))

	local lastSig = nil
	local function UpdateKeybindList()
		local items = {}
		for uniqueId, element in pairs(ctx.Window._configElements) do
			local t = element.Type
			if t == "Toggle" or t == "Keybind" or t == "ButtonKeybind" then
				local api = element.API
				local success, data = pcall(api.Save, api)
				if success and type(data) == "table" and data.Bind and data.Bind ~= "" and data.Bind ~= "Unknown" and data.Bind ~= "None" then
					local keyTxt = shortKeys[data.Bind] or tostring(data.Bind)
					if keyTxt ~= "" and keyTxt ~= "None" and keyTxt ~= "Unknown" then
						table.insert(items, {
							Id = uniqueId,
							Name = tostring(uniqueId:match("~[^~]+~([^~]+)$") or uniqueId),
							Key = keyTxt,
							Active = (t == "Toggle" and data.State == true)
						})
					end
				end
			end
		end
		table.sort(items, function(a, b) return a.Id < b.Id end)

		local parts = {}
		for i, it in ipairs(items) do
			parts[i] = it.Id .. "|" .. it.Key .. "|" .. (it.Active and "1" or "0")
		end
		local sig = table.concat(parts, ";")
		if sig == lastSig then return end
		lastSig = sig

		for _, child in ipairs(kbEntries:GetChildren()) do
			if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
		end

		for _, it in ipairs(items) do
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 22)
			row.BackgroundTransparency = 1
			row.Parent = kbEntries

			local rowTitle = Instance.new("TextLabel")
			rowTitle.Size = UDim2.new(1, -40, 1, 0)
			rowTitle.BackgroundTransparency = 1
			rowTitle.TextSize = 12
			rowTitle.Text = it.Name
			rowTitle.TextXAlignment = Enum.TextXAlignment.Left
			rowTitle.TextTruncate = Enum.TextTruncate.AtEnd
			rowTitle.Parent = row
			ctx.ApplyTheme(rowTitle, "Text", "TextColor3")
			ctx.ApplyTheme(rowTitle, "TextFont", "Font")

			local badge = Instance.new("Frame")
			badge.Size = UDim2.new(0, 26, 0, 18)
			badge.AnchorPoint = Vector2.new(1, 0.5)
			badge.Position = UDim2.new(1, 0, 0.5, 0)
			badge.AutomaticSize = Enum.AutomaticSize.X
			badge.BorderSizePixel = 0
			badge.Parent = row
			ctx.ApplyTheme(badge, "Input", "BackgroundColor3")
			ctx.ApplyTheme(badge, "InputTrans", "BackgroundTransparency")

			local badgeCorner = Instance.new("UICorner")
			badgeCorner.Parent = badge
			ctx.RegisterCorner(badgeCorner, "HUD")

			local badgeStroke = Instance.new("UIStroke")
			badgeStroke.Thickness = 1
			badgeStroke.Parent = badge
			ctx.ApplyTheme(badgeStroke, it.Active and "Accent" or "Outlines", "Color")

			local badgeTxt = Instance.new("TextLabel")
			badgeTxt.Size = UDim2.new(1, 0, 1, 0)
			badgeTxt.BackgroundTransparency = 1
			badgeTxt.TextSize = 11
			badgeTxt.Text = it.Key
			badgeTxt.Parent = badge
			ctx.ApplyTheme(badgeTxt, "SubtextFont", "Font")
			ctx.ApplyTheme(badgeTxt, it.Active and "Accent" or "TextMuted", "TextColor3")

			local badgePad = Instance.new("UIPadding")
			badgePad.PaddingLeft = UDim.new(0, 5)
			badgePad.PaddingRight = UDim.new(0, 5)
			badgePad.Parent = badgeTxt
		end

		local count = #items
		local entriesH
		if count == 0 then
			local emptyLbl = Instance.new("TextLabel")
			emptyLbl.Size = UDim2.new(1, 0, 0, 18)
			emptyLbl.BackgroundTransparency = 1
			emptyLbl.TextSize = 11
			emptyLbl.Text = "No active binds"
			emptyLbl.Parent = kbEntries
			ctx.ApplyTheme(emptyLbl, "TextMuted", "TextColor3")
			ctx.ApplyTheme(emptyLbl, "SubtextFont", "Font")
			entriesH = 32
		else
			local visibleCount = math.min(count, 10)
			entriesH = 14 + (visibleCount * 22) + ((visibleCount - 1) * 4)
		end
		kbEntries.Size = UDim2.new(1, 0, 0, entriesH)
		kbHolder.Size = UDim2.new(0, KB_WIDTH, 0, 29 + entriesH)
	end

	local isUpdatingKB = false
	ctx.Window.UpdateKeybinds = function()
		if isUpdatingKB then return end
		isUpdatingKB = true
		task.delay(0.08, function()
			isUpdatingKB = false
			if kbHolder.Parent then UpdateKeybindList() end
		end)
	end

	task.spawn(function()
		task.wait(1.2)
		if kbHolder.Parent then UpdateKeybindList() end
	end)
end

local function createEditModeSystem(ctx)
	local THEME = ctx.THEME

	local editBackdrop = Instance.new("Frame")
	editBackdrop.Name = "EditModeBackdrop"
	editBackdrop.Position = UDim2.new(0, -20, 0, -100)
	editBackdrop.Size = UDim2.new(1, 40, 1, 200)
	editBackdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	editBackdrop.BackgroundTransparency = 1
	editBackdrop.BorderSizePixel = 0
	editBackdrop.ZIndex = 1
	editBackdrop.Visible = false
	editBackdrop.Parent = ctx.screenGui

	local editBlur = Instance.new("BlurEffect")
	editBlur.Name = "UI_EditMode_Blur"
	editBlur.Size = 0
	editBlur.Enabled = false
	editBlur.Parent = Lighting
	ctx.EditBlur = editBlur

	local editorPanel = Instance.new("Frame")
	editorPanel.Name = "ThemeEditorPanel"
	editorPanel.AnchorPoint = Vector2.new(0, 0.5)
	editorPanel.Size = UDim2.new(0, 560, 0, 520)
	editorPanel.Position = UDim2.new(0, 20, 0.5, 0)
	editorPanel.BorderSizePixel = 0
	editorPanel.Visible = false
	editorPanel.Active = true
	editorPanel.ZIndex = 15
	editorPanel.Parent = ctx.screenGui
	ctx.ApplyTheme(editorPanel, "Background", "BackgroundColor3")
	ctx.ApplyTheme(editorPanel, "BackgroundTrans", "BackgroundTransparency")

	local panelScale = Instance.new("UIScale")
	panelScale.Scale = isMobile and 0.65 or 1
	panelScale.Parent = editorPanel

	local panelCorner = Instance.new("UICorner")
	panelCorner.Parent = editorPanel
	ctx.RegisterCorner(panelCorner, "Main")

	local panelStroke = ctx.AttachStroke(editorPanel, "MainOutline", "Main")

	local editorHeader = Instance.new("Frame")
	editorHeader.Name = "EditorHeader"
	editorHeader.Size = UDim2.new(1, 0, 0, 42)
	editorHeader.BackgroundTransparency = 1
	editorHeader.Active = true
	editorHeader.ZIndex = 16
	editorHeader.Parent = editorPanel

	local headerDivider = Instance.new("Frame")
	headerDivider.Size = UDim2.new(1, 0, 0, 1)
	headerDivider.Position = UDim2.new(0, 0, 1, -1)
	headerDivider.BorderSizePixel = 0
	headerDivider.Parent = editorHeader
	ctx.ApplyTheme(headerDivider, "Outlines", "BackgroundColor3")

	local headerTitleRow = Instance.new("Frame")
	headerTitleRow.Size = UDim2.new(1, -170, 1, 0)
	headerTitleRow.Position = UDim2.new(0, 14, 0, 0)
	headerTitleRow.BackgroundTransparency = 1
	headerTitleRow.Parent = editorHeader

	local hLayout = Instance.new("UIListLayout")
	hLayout.FillDirection = Enum.FillDirection.Horizontal
	hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	hLayout.Padding = UDim.new(0, 8)
	hLayout.Parent = headerTitleRow

	local accentDot = Instance.new("Frame")
	accentDot.Size = UDim2.new(0, 8, 0, 8)
	accentDot.BorderSizePixel = 0
	accentDot.Parent = headerTitleRow
	ctx.ApplyTheme(accentDot, "Accent", "BackgroundColor3")
	local dotC = Instance.new("UICorner")
	dotC.CornerRadius = UDim.new(1, 0)
	dotC.Parent = accentDot

	local editorTitle = Instance.new("TextLabel")
	editorTitle.AutomaticSize = Enum.AutomaticSize.X
	editorTitle.Size = UDim2.new(0, 0, 1, 0)
	editorTitle.BackgroundTransparency = 1
	editorTitle.Text = "Theme & Layout Editor"
	editorTitle.TextSize = 13
	editorTitle.TextXAlignment = Enum.TextXAlignment.Left
	editorTitle.Parent = headerTitleRow
	ctx.ApplyTheme(editorTitle, "Text", "TextColor3")
	ctx.ApplyTheme(editorTitle, "TextFont", "Font")

	local headerActions = Instance.new("Frame")
	headerActions.Size = UDim2.new(0, 150, 1, 0)
	headerActions.AnchorPoint = Vector2.new(1, 0)
	headerActions.Position = UDim2.new(1, -10, 0, 0)
	headerActions.BackgroundTransparency = 1
	headerActions.Parent = editorHeader

	local actLayout = Instance.new("UIListLayout")
	actLayout.FillDirection = Enum.FillDirection.Horizontal
	actLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	actLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	actLayout.Padding = UDim.new(0, 6)
	actLayout.Parent = headerActions

	local dockMode = "Left"
	local snapBtn = Instance.new("TextButton")
	snapBtn.Size = UDim2.new(0, 96, 0, 26)
	snapBtn.AutoButtonColor = false
	snapBtn.TextSize = 11
	snapBtn.Text = "Snap: Left"
	snapBtn.Parent = headerActions
	ctx.ApplyTheme(snapBtn, "Card", "BackgroundColor3")
	ctx.ApplyTheme(snapBtn, "CardTrans", "BackgroundTransparency")
	ctx.ApplyTheme(snapBtn, "Text", "TextColor3")
	ctx.ApplyTheme(snapBtn, "TextFont", "Font")
	local snapC = Instance.new("UICorner")
	snapC.Parent = snapBtn
	ctx.RegisterCorner(snapC, "Element")
	ctx.AttachStroke(snapBtn, "Element", "Element")

	local closeEditBtn = Instance.new("TextButton")
	closeEditBtn.Size = UDim2.new(0, 26, 0, 26)
	closeEditBtn.AutoButtonColor = false
	closeEditBtn.Text = ""
	closeEditBtn.Parent = headerActions
	ctx.ApplyTheme(closeEditBtn, "Card", "BackgroundColor3")
	ctx.ApplyTheme(closeEditBtn, "CardTrans", "BackgroundTransparency")
	local ceC = Instance.new("UICorner")
	ceC.Parent = closeEditBtn
	ctx.RegisterCorner(ceC, "Element")
	ctx.AttachStroke(closeEditBtn, "Element", "Element")

	local x1 = Instance.new("Frame")
	x1.Size = UDim2.new(0, 10, 0, 1)
	x1.Position = UDim2.fromScale(0.5, 0.5)
	x1.AnchorPoint = Vector2.new(0.5, 0.5)
	x1.Rotation = 45
	x1.BorderSizePixel = 0
	x1.Parent = closeEditBtn
	ctx.ApplyTheme(x1, "TextMuted", "BackgroundColor3")
	local x2 = x1:Clone()
	x2.Rotation = -45
	x2.Parent = closeEditBtn

	local themeScroll = Instance.new("ScrollingFrame")
	themeScroll.Name = "ThemeEditorContainer"
	themeScroll.Size = UDim2.new(1, 0, 1, -42)
	themeScroll.Position = UDim2.new(0, 0, 0, 42)
	themeScroll.BackgroundTransparency = 1
	themeScroll.BorderSizePixel = 0
	themeScroll.ScrollBarThickness = 3
	themeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	themeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	themeScroll.Parent = editorPanel
	ctx.ApplyTheme(themeScroll, "Outlines", "ScrollBarImageColor3")

	local themePad = Instance.new("UIPadding")
	themePad.PaddingTop = UDim.new(0, 12)
	themePad.PaddingBottom = UDim.new(0, 12)
	themePad.PaddingLeft = UDim.new(0, 12)
	themePad.PaddingRight = UDim.new(0, 12)
	themePad.Parent = themeScroll

	local themeLayout = Instance.new("UIListLayout")
	themeLayout.FillDirection = Enum.FillDirection.Horizontal
	themeLayout.Padding = UDim.new(0, 12)
	themeLayout.SortOrder = Enum.SortOrder.LayoutOrder
	themeLayout.Parent = themeScroll

	local themeLeft = Instance.new("Frame")
	themeLeft.Size = UDim2.new(0.5, -6, 0, 0)
	themeLeft.AutomaticSize = Enum.AutomaticSize.Y
	themeLeft.BackgroundTransparency = 1
	themeLeft.Parent = themeScroll
	local tlLayout = Instance.new("UIListLayout")
	tlLayout.Padding = UDim.new(0, 12)
	tlLayout.Parent = themeLeft

	local themeRight = Instance.new("Frame")
	themeRight.Size = UDim2.new(0.5, -6, 0, 0)
	themeRight.AutomaticSize = Enum.AutomaticSize.Y
	themeRight.BackgroundTransparency = 1
	themeRight.Parent = themeScroll
	local trLayout = Instance.new("UIListLayout")
	trLayout.Padding = UDim.new(0, 12)
	trLayout.Parent = themeRight

	local function snapEditorLeft(animate)
		local sw = ctx.screenGui.AbsoluteSize.X
		local sh = ctx.screenGui.AbsoluteSize.Y
		local scale = isMobile and 0.65 or 1
		if sw > 0 and sh > 0 then
			local panelW = math.min(560, (sw - 40) / scale)
			local panelH = math.clamp((sh - 60) / scale, 340, 560)
			editorPanel.Size = UDim2.new(0, panelW, 0, panelH)
		end
		local dest = UDim2.new(0, 20, 0.5, 0)
		if animate then
			TS:Create(editorPanel, T_MED, { Position = dest }):Play()
		else
			editorPanel.Position = dest
		end
	end

	ctx.TrackConnection(snapBtn.MouseEnter:Connect(function()
		ctx.TweenTheme(snapBtn, "ElementHover", "BackgroundColor3", T_FAST)
	end))
	ctx.TrackConnection(snapBtn.MouseLeave:Connect(function()
		ctx.TweenTheme(snapBtn, "Card", "BackgroundColor3", T_FAST)
	end))
	ctx.TrackConnection(snapBtn.MouseButton1Click:Connect(function()
		dockMode = "Left"
		snapBtn.Text = "Snap: Left"
		snapEditorLeft(true)
	end))

	ctx.TrackConnection(closeEditBtn.MouseEnter:Connect(function()
		TS:Create(x1, T_FAST, { BackgroundColor3 = THEME.CloseBtn }):Play()
		TS:Create(x2, T_FAST, { BackgroundColor3 = THEME.CloseBtn }):Play()
	end))
	ctx.TrackConnection(closeEditBtn.MouseLeave:Connect(function()
		ctx.TweenTheme(x1, "TextMuted", "BackgroundColor3", T_FAST)
		ctx.TweenTheme(x2, "TextMuted", "BackgroundColor3", T_FAST)
	end))
	ctx.TrackConnection(closeEditBtn.MouseButton1Click:Connect(function()
		if ctx.EditToggleAPI then
			ctx.EditToggleAPI:Set(false)
		else
			ctx.Window.ToggleEditMode(false)
		end
	end))

	ctx.TrackConnection(editorHeader.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dockMode = "Free"
			snapBtn.Text = "Snap: Free"
			local dragStart = input.Position
			local startPos = editorPanel.Position
			ctx.StartDrag(input.UserInputType, function(moveInput)
				local delta = moveInput.Position - dragStart
				editorPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end)
		end
	end))

	table.insert(ctx.Window._styleCallbacks, function(style)
		if style == 3 or style == 4 then
			themePad.PaddingTop, themePad.PaddingBottom = UDim.new(0, 8), UDim.new(0, 8)
			themePad.PaddingLeft, themePad.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
			themeLayout.Padding = UDim.new(0, 8)
			tlLayout.Padding = UDim.new(0, 8)
			trLayout.Padding = UDim.new(0, 8)
		else
			themePad.PaddingTop, themePad.PaddingBottom = UDim.new(0, 12), UDim.new(0, 12)
			themePad.PaddingLeft, themePad.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
			themeLayout.Padding = UDim.new(0, 12)
			tlLayout.Padding = UDim.new(0, 12)
			trLayout.Padding = UDim.new(0, 12)
		end
	end)

	local editModeLoop = nil
	local function setEditMode(state)
		ctx.Window.IsEditMode = state
		if state then
			if not editModeLoop then
				editModeLoop = RS.RenderStepped:Connect(function()
					UIS.MouseIconEnabled = true
					UIS.MouseBehavior = Enum.MouseBehavior.Default
				end)
			end
			CAS:BindAction("AxiomEditSink", function() return Enum.ContextActionResult.Sink end, false,
				Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3,
				Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space
			)
			editBackdrop.Visible = true
			editBlur.Enabled = true
			TS:Create(editBackdrop, T_EDIT, { BackgroundTransparency = 0.45 }):Play()
			TS:Create(editBlur, T_EDIT, { Size = 14 }):Play()

			if dockMode == "Left" then
				snapEditorLeft(false)
			end
			local targetPos = editorPanel.Position
			editorPanel.Position = UDim2.new(targetPos.X.Scale, targetPos.X.Offset - 16, targetPos.Y.Scale, targetPos.Y.Offset)
			editorPanel.Visible = true
			TS:Create(editorPanel, T_EDIT, { Position = targetPos }):Play()
		else
			if editModeLoop then editModeLoop:Disconnect(); editModeLoop = nil end
			CAS:UnbindAction("AxiomEditSink")
			local bdTween = TS:Create(editBackdrop, T_MED, { BackgroundTransparency = 1 })
			bdTween:Play()
			bdTween.Completed:Once(function()
				if not ctx.Window.IsEditMode and editBackdrop.Parent then
					editBackdrop.Visible = false
				end
			end)
			local blTween = TS:Create(editBlur, T_MED, { Size = 0 })
			blTween:Play()
			blTween.Completed:Once(function()
				if not ctx.Window.IsEditMode and editBlur.Parent then
					editBlur.Enabled = false
				end
			end)
			editorPanel.Visible = false
		end
	end

	ctx.Window.ToggleEditMode = setEditMode
	ctx.ThemeEditorLeft = themeLeft
	ctx.ThemeEditorRight = themeRight
	ctx.EditorPanelStroke = panelStroke
end

local function attachColorPicker(ctx, previewBox, initialColor, callback)
	local h, s, v = initialColor:ToHSV()
	local currentColor = initialColor

	local popupHolder = Instance.new("Frame")
	popupHolder.Name = "ColorPopupHolder"
	popupHolder.Size = UDim2.new(0, 180, 0, 244)
	popupHolder.AnchorPoint = Vector2.new(1, 0)
	popupHolder.BackgroundTransparency = 1
	popupHolder.Visible = false
	popupHolder.ZIndex = 100000
	popupHolder.Parent = ctx.screenGui

	local popup = Instance.new("CanvasGroup")
	popup.Name = "ColorPopup"
	popup.Size = UDim2.fromScale(1, 1)
	popup.Position = UDim2.fromScale(0.5, 0.5)
	popup.AnchorPoint = Vector2.new(0.5, 0.5)
	popup.BorderSizePixel = 0
	popup.GroupTransparency = 1
	popup.ZIndex = 100000
	popup.Parent = popupHolder
	ctx.ApplyTheme(popup, "Background", "BackgroundColor3")
	ctx.ApplyTheme(popup, "BackgroundTrans", "BackgroundTransparency")

	local popupCorner = Instance.new("UICorner")
	popupCorner.Parent = popup
	ctx.RegisterCorner(popupCorner, "Element")

	local popupStroke = Instance.new("UIStroke")
	popupStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	popupStroke.Thickness = 1
	popupStroke.Enabled = (ctx.THEME.InternalOutlines == "Only Elements" or ctx.THEME.InternalOutlines == "All")
	popupStroke.Parent = popupHolder
	ctx.ApplyTheme(popupStroke, "Outlines", "Color")
	local holderCorner = Instance.new("UICorner")
	holderCorner.Parent = popupHolder
	ctx.RegisterCorner(holderCorner, "Element")
	local _, doubleFrame = ctx.AttachDoubleOutline(popupHolder, popupStroke, "Element")
	local doubleStroke = doubleFrame and doubleFrame:FindFirstChild("DoubleOutlineStroke")

	local popupPadding = Instance.new("UIPadding")
	popupPadding.PaddingTop, popupPadding.PaddingBottom = UDim.new(0, 10), UDim.new(0, 10)
	popupPadding.PaddingLeft, popupPadding.PaddingRight = UDim.new(0, 10), UDim.new(0, 10)
	popupPadding.Parent = popup

	local popupLayout = Instance.new("UIListLayout")
	popupLayout.SortOrder = Enum.SortOrder.LayoutOrder
	popupLayout.Padding = UDim.new(0, 10)
	popupLayout.Parent = popup

	local rgbContainer = Instance.new("Frame")
	rgbContainer.Size = UDim2.new(1, 0, 0, 24)
	rgbContainer.BackgroundTransparency = 1
	rgbContainer.LayoutOrder = 1
	rgbContainer.Parent = popup

	local rgbLayout = Instance.new("UIListLayout")
	rgbLayout.FillDirection = Enum.FillDirection.Horizontal
	rgbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	rgbLayout.Padding = UDim.new(0, 8)
	rgbLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rgbLayout.Parent = rgbContainer

	local function createRGBBox(order, prefix)
		local box = Instance.new("Frame")
		box.Size = UDim2.new(0, 48, 1, 0)
		box.LayoutOrder = order
		box.Parent = rgbContainer
		ctx.ApplyTheme(box, "Input", "BackgroundColor3")
		ctx.ApplyTheme(box, "InputTrans", "BackgroundTransparency")

		local corner = Instance.new("UICorner")
		corner.Parent = box
		ctx.RegisterCorner(corner, "Element")
		ctx.AttachStroke(box, "Element", "Element")

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 16, 1, 0)
		lbl.Position = UDim2.new(0, 4, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = prefix
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = box
		ctx.ApplyTheme(lbl, "TextMuted", "TextColor3")
		ctx.ApplyTheme(lbl, "TextFont", "Font")

		local inp = Instance.new("TextBox")
		inp.Size = UDim2.new(1, -20, 1, 0)
		inp.Position = UDim2.new(0, 16, 0, 0)
		inp.BackgroundTransparency = 1
		inp.Text = "255"
		inp.TextSize = 11
		inp.TextXAlignment = Enum.TextXAlignment.Center
		inp.Parent = box
		ctx.ApplyTheme(inp, "Text", "TextColor3")
		ctx.ApplyTheme(inp, "TextFont", "Font")
		return inp
	end

	local rInput = createRGBBox(1, "R:")
	local gInput = createRGBBox(2, "G:")
	local bInput = createRGBBox(3, "B:")

	local svSquare = Instance.new("TextButton")
	svSquare.Size = UDim2.new(1, 0, 0, 160)
	svSquare.BackgroundColor3 = Color3.new(1, 1, 1)
	svSquare.BorderSizePixel = 0
	svSquare.AutoButtonColor = false
	svSquare.Text = ""
	svSquare.LayoutOrder = 2
	svSquare.Parent = popup
	local svC = Instance.new("UICorner")
	svC.CornerRadius = UDim.new(0, 6)
	svC.Parent = svSquare
	ctx.RegisterCorner(svC, "Element")

	local hueOverlay = Instance.new("Frame")
	hueOverlay.Size = UDim2.fromScale(1, 1)
	hueOverlay.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
	hueOverlay.BorderSizePixel = 0
	hueOverlay.Parent = svSquare
	local hoC = Instance.new("UICorner")
	hoC.CornerRadius = UDim.new(0, 6)
	hoC.Parent = hueOverlay
	ctx.RegisterCorner(hoC, "Element")

	local hueGrad = Instance.new("UIGradient")
	hueGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
	hueGrad.Parent = hueOverlay

	local blackOverlay = Instance.new("Frame")
	blackOverlay.Size = UDim2.fromScale(1, 1)
	blackOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
	blackOverlay.BorderSizePixel = 0
	blackOverlay.Parent = svSquare
	local boC = Instance.new("UICorner")
	boC.CornerRadius = UDim.new(0, 6)
	boC.Parent = blackOverlay
	ctx.RegisterCorner(boC, "Element")

	local blackGrad = Instance.new("UIGradient")
	blackGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
	blackGrad.Rotation = 90
	blackGrad.Parent = blackOverlay

	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 10, 0, 10)
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Position = UDim2.new(s, 0, 1 - v, 0)
	dot.BackgroundColor3 = Color3.new(1, 1, 1)
	dot.BorderSizePixel = 0
	dot.Parent = svSquare
	local dotC = Instance.new("UICorner")
	dotC.CornerRadius = UDim.new(1, 0)
	dotC.Parent = dot
	local dotS = Instance.new("UIStroke")
	dotS.Color = Color3.new(0, 0, 0)
	dotS.Thickness = 1
	dotS.Parent = dot

	local hueSlider = Instance.new("TextButton")
	hueSlider.Size = UDim2.new(1, 0, 0, 12)
	hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
	hueSlider.BorderSizePixel = 0
	hueSlider.AutoButtonColor = false
	hueSlider.Text = ""
	hueSlider.LayoutOrder = 3
	hueSlider.Parent = popup
	local hsC = Instance.new("UICorner")
	hsC.CornerRadius = UDim.new(0, 6)
	hsC.Parent = hueSlider
	ctx.RegisterCorner(hsC, "Element")

	local rainbowGrad = Instance.new("UIGradient")
	rainbowGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
	})
	rainbowGrad.Parent = hueSlider

	local hueKnob = Instance.new("Frame")
	hueKnob.Size = UDim2.new(0, 4, 1, 4)
	hueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
	hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
	hueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
	hueKnob.BorderSizePixel = 0
	hueKnob.Parent = hueSlider
	local hkC = Instance.new("UICorner")
	hkC.CornerRadius = UDim.new(1, 0)
	hkC.Parent = hueKnob
	local hkS = Instance.new("UIStroke")
	hkS.Color = Color3.new(0, 0, 0)
	hkS.Parent = hueKnob

	local function updateColors(fromRGB)
		currentColor = Color3.fromHSV(h, s, v)
		if not fromRGB then
			rInput.Text = tostring(math.round(currentColor.R * 255))
			gInput.Text = tostring(math.round(currentColor.G * 255))
			bInput.Text = tostring(math.round(currentColor.B * 255))
		end
		previewBox.BackgroundColor3 = currentColor
		hueOverlay.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		dot.Position = UDim2.new(s, 0, 1 - v, 0)
		hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
		callback(currentColor)
	end
	updateColors(false)

	local function onRGBFocusLost()
		local r = math.clamp(tonumber(rInput.Text) or math.round(currentColor.R * 255), 0, 255)
		local g = math.clamp(tonumber(gInput.Text) or math.round(currentColor.G * 255), 0, 255)
		local b = math.clamp(tonumber(bInput.Text) or math.round(currentColor.B * 255), 0, 255)
		rInput.Text, gInput.Text, bInput.Text = tostring(r), tostring(g), tostring(b)
		h, s, v = Color3.fromRGB(r, g, b):ToHSV()
		updateColors(true)
	end
	ctx.TrackConnection(rInput.FocusLost:Connect(onRGBFocusLost))
	ctx.TrackConnection(gInput.FocusLost:Connect(onRGBFocusLost))
	ctx.TrackConnection(bInput.FocusLost:Connect(onRGBFocusLost))

	local popupToken = 0
	ctx.TrackConnection(previewBox.MouseButton1Click:Connect(function()
		local Window = ctx.Window
		if Window.ActivePopup == popupHolder then return Window.ClosePopup() end
		Window.ClosePopup()
		popupToken = popupToken + 1

		popupStroke.Enabled = (ctx.THEME.InternalOutlines == "Only Elements" or ctx.THEME.InternalOutlines == "All")
		local absX = previewBox.AbsolutePosition.X - Window.Overlay.AbsolutePosition.X + previewBox.AbsoluteSize.X + 10
		local absY = previewBox.AbsolutePosition.Y - Window.Overlay.AbsolutePosition.Y
		popupHolder.Parent = Window.Overlay
		popupHolder.Position = UDim2.new(0, absX, 0, absY)
		popupHolder.Size = UDim2.new(0, 162, 0, 220)
		popup.GroupTransparency = 1
		popupStroke.Transparency = 1
		if doubleStroke then doubleStroke.Transparency = 1 end
		popupHolder.Visible = true

		Window.Overlay.Visible = true
		Window.ActivePopup = popupHolder
		Window.ActivePopupClose = function()
			popupToken = popupToken + 1
			local token = popupToken
			TS:Create(popupHolder, T_FAST, { Size = UDim2.new(0, 162, 0, 220) }):Play()
			local fadeT = TS:Create(popup, T_FAST, { GroupTransparency = 1 })
			fadeT:Play()
			TS:Create(popupStroke, T_FAST, { Transparency = 1 }):Play()
			if doubleStroke then TS:Create(doubleStroke, T_FAST, { Transparency = 1 }):Play() end
			fadeT.Completed:Once(function()
				if token == popupToken then
					popupHolder.Visible = false
					if not Window.ActivePopup then Window.Overlay.Visible = false end
				end
			end)
		end

		TS:Create(popupHolder, T_BACK, { Size = UDim2.new(0, 180, 0, 244) }):Play()
		TS:Create(popup, T_MED, { GroupTransparency = 0 }):Play()
		TS:Create(popupStroke, T_MED, { Transparency = 0 }):Play()
		if doubleStroke then TS:Create(doubleStroke, T_MED, { Transparency = 0 }):Play() end
	end))

	local function moveSV(input)
		s = math.clamp((input.Position.X - svSquare.AbsolutePosition.X) / math.max(svSquare.AbsoluteSize.X, 1), 0, 1)
		v = 1 - math.clamp((input.Position.Y - svSquare.AbsolutePosition.Y) / math.max(svSquare.AbsoluteSize.Y, 1), 0, 1)
		updateColors(false)
	end
	ctx.TrackConnection(svSquare.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			moveSV(input)
			ctx.StartDrag(input.UserInputType, moveSV)
		end
	end))

	local function moveHue(input)
		h = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / math.max(hueSlider.AbsoluteSize.X, 1), 0, 1)
		updateColors(false)
	end
	ctx.TrackConnection(hueSlider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			moveHue(input)
			ctx.StartDrag(input.UserInputType, moveHue)
		end
	end))

	local api = {}
	function api:SetColor(c)
		h, s, v = c:ToHSV()
		updateColors(false)
	end
	return api
end

local function createElementBase(ctx, blockContainer, height)
	local elContainer = Instance.new("Frame")
	elContainer.Name = "ElementContainer"
	elContainer.Size = UDim2.new(1, 0, 0, height or 38)
	elContainer.BorderSizePixel = 0
	elContainer.LayoutOrder = 2
	elContainer.Parent = blockContainer
	ctx.ApplyTheme(elContainer, "Element", "BackgroundColor3")
	ctx.ApplyTheme(elContainer, "ElementTrans", "BackgroundTransparency")

	local corner = Instance.new("UICorner")
	corner.Parent = elContainer
	ctx.RegisterCorner(corner, "Element")

	ctx.AttachStroke(elContainer, "Element", "Element")
	return elContainer
end

local function buildDropdownElement(ctx, reg, dropConfig)
	local dropName = dropConfig.Name or "Dropdown"
	local rawOptions = dropConfig.Options or {}
	local iconMap = dropConfig.Icons
	local callback = dropConfig.Callback or function() end
	local maxSelections = dropConfig.MaxSelections or math.huge
	local defaultOpt = dropConfig.Default
	local isMulti = dropConfig.Multi or false
	local isSearch = dropConfig.Search or false

	local parsedOptions = {}
	local optionNames = {}
	local optionIconMap = {}
	local hasAnyIcon = false

	local function ingestOptions(list)
		table.clear(parsedOptions)
		table.clear(optionNames)
		table.clear(optionIconMap)
		hasAnyIcon = false
		for _, opt in ipairs(list or {}) do
			local oName, oIcon = parseDropdownOption(opt, iconMap)
			table.insert(parsedOptions, { Name = oName, Icon = oIcon })
			table.insert(optionNames, oName)
			if oIcon ~= "" then
				optionIconMap[oName] = oIcon
				hasAnyIcon = true
			end
		end
	end
	ingestOptions(rawOptions)

	local selectedItems = isMulti and {} or nil
	local selectedItem = nil
	local customWidthRatio = nil

	local container = createElementBase(ctx, reg.Container, 38)

	local topBar = Instance.new("TextButton")
	topBar.Size = UDim2.fromScale(1, 1)
	topBar.BackgroundTransparency = 1
	topBar.Text = ""
	topBar.Parent = container

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.52, -15, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)
	label.BackgroundTransparency = 1
	label.TextSize = 13
	label.TextTruncate = Enum.TextTruncate.None
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = dropName
	label.ZIndex = 2
	label.Parent = topBar
	ctx.ApplyTheme(label, "Text", "TextColor3")
	ctx.ApplyTheme(label, "TextFont", "Font")

	local selectedBox = Instance.new("Frame")
	selectedBox.Size = UDim2.new(0.44, 0, 0, 28)
	selectedBox.AnchorPoint = Vector2.new(1, 0.5)
	selectedBox.Position = UDim2.new(1, -7, 0.5, 0)
	selectedBox.BorderSizePixel = 0
	selectedBox.ZIndex = 4
	selectedBox.Parent = topBar
	ctx.ApplyTheme(selectedBox, "Input", "BackgroundColor3")
	ctx.ApplyTheme(selectedBox, "InputTrans", "BackgroundTransparency")

	local sbCorner = Instance.new("UICorner")
	sbCorner.Parent = selectedBox
	ctx.RegisterCorner(sbCorner, "Element")
	local selectedBoxStroke = ctx.AttachStroke(selectedBox, "Element", "Element")

	local resizeHandle = Instance.new("TextButton")
	resizeHandle.Name = "ResizeHandle"
	resizeHandle.Size = UDim2.new(0, 16, 1, 0)
	resizeHandle.Position = UDim2.new(0, 0, 0, 0)
	resizeHandle.BackgroundTransparency = 1
	resizeHandle.Text = ""
	resizeHandle.AutoButtonColor = false
	resizeHandle.Active = true
	resizeHandle.ZIndex = 6
	resizeHandle.Parent = selectedBox

	local rArrowTop = Instance.new("Frame")
	rArrowTop.Size = UDim2.new(0, 5, 0, 1)
	rArrowTop.Position = UDim2.new(0.5, 0, 0.5, -2)
	rArrowTop.AnchorPoint = Vector2.new(0.5, 0.5)
	rArrowTop.Rotation = -45
	rArrowTop.BorderSizePixel = 0
	rArrowTop.Parent = resizeHandle
	ctx.ApplyTheme(rArrowTop, "TextMuted", "BackgroundColor3")

	local rArrowBot = Instance.new("Frame")
	rArrowBot.Size = UDim2.new(0, 5, 0, 1)
	rArrowBot.Position = UDim2.new(0.5, 0, 0.5, 2)
	rArrowBot.AnchorPoint = Vector2.new(0.5, 0.5)
	rArrowBot.Rotation = 45
	rArrowBot.BorderSizePixel = 0
	rArrowBot.Parent = resizeHandle
	ctx.ApplyTheme(rArrowBot, "TextMuted", "BackgroundColor3")

	local arrow = Instance.new("ImageLabel")
	arrow.Size = UDim2.new(0, 14, 0, 14)
	arrow.AnchorPoint = Vector2.new(1, 0.5)
	arrow.Position = UDim2.new(1, -8, 0.5, 0)
	arrow.BackgroundTransparency = 1
	arrow.Image = "rbxassetid://10709790948"
	arrow.Rotation = 180
	arrow.ZIndex = 5
	arrow.Parent = selectedBox
	ctx.ApplyTheme(arrow, "TextMuted", "ImageColor3")

	local selectedIcon = Instance.new("ImageLabel")
	selectedIcon.Size = UDim2.new(0, 16, 0, 16)
	selectedIcon.AnchorPoint = Vector2.new(0, 0.5)
	selectedIcon.Position = UDim2.new(0, 18, 0.5, 0)
	selectedIcon.BackgroundTransparency = 1
	selectedIcon.ScaleType = Enum.ScaleType.Fit
	selectedIcon.Visible = false
	selectedIcon.ZIndex = 5
	selectedIcon.Parent = selectedBox

	local selectedText = Instance.new("TextLabel")
	selectedText.Size = UDim2.new(1, -36, 1, 0)
	selectedText.Position = UDim2.new(0, 16, 0, 0)
	selectedText.BackgroundTransparency = 1
	selectedText.TextSize = 12
	selectedText.Text = "Select..."
	selectedText.TextXAlignment = Enum.TextXAlignment.Center
	selectedText.TextTruncate = Enum.TextTruncate.AtEnd
	selectedText.ZIndex = 5
	selectedText.Parent = selectedBox
	ctx.ApplyTheme(selectedText, "Text", "TextColor3")
	ctx.ApplyTheme(selectedText, "TextFont", "Font")

	local dropPopup = Instance.new("Frame")
	dropPopup.Name = "DropdownPopup"
	dropPopup.BorderSizePixel = 0
	dropPopup.AnchorPoint = Vector2.new(0, 0)
	dropPopup.Visible = false
	dropPopup.ZIndex = 100000
	dropPopup.Parent = ctx.screenGui
	ctx.ApplyTheme(dropPopup, "Input", "BackgroundColor3")
	ctx.ApplyTheme(dropPopup, "InputTrans", "BackgroundTransparency")

	local dpCorner = Instance.new("UICorner")
	dpCorner.Parent = dropPopup
	ctx.RegisterCorner(dpCorner, "Element")
	ctx.AttachStroke(dropPopup, "Element", "Element")

	local dropClip = Instance.new("Frame")
	dropClip.Size = UDim2.fromScale(1, 1)
	dropClip.BackgroundTransparency = 1
	dropClip.ClipsDescendants = true
	dropClip.ZIndex = 100001
	dropClip.Parent = dropPopup

	local headerBtn = Instance.new("TextButton")
	headerBtn.Size = UDim2.new(1, 0, 0, 28)
	headerBtn.BackgroundTransparency = 1
	headerBtn.Text = ""
	headerBtn.ZIndex = 100001
	headerBtn.Parent = dropClip

	local headerArrow = Instance.new("ImageLabel")
	headerArrow.Size = UDim2.new(0, 14, 0, 14)
	headerArrow.AnchorPoint = Vector2.new(1, 0.5)
	headerArrow.Position = UDim2.new(1, -8, 0.5, 0)
	headerArrow.BackgroundTransparency = 1
	headerArrow.Image = "rbxassetid://10709790948"
	headerArrow.Rotation = 180
	headerArrow.ZIndex = 100002
	headerArrow.Parent = headerBtn
	ctx.ApplyTheme(headerArrow, "TextMuted", "ImageColor3")

	local headerIcon = Instance.new("ImageLabel")
	headerIcon.Size = UDim2.new(0, 16, 0, 16)
	headerIcon.AnchorPoint = Vector2.new(0, 0.5)
	headerIcon.Position = UDim2.new(0, 7, 0.5, 0)
	headerIcon.BackgroundTransparency = 1
	headerIcon.ScaleType = Enum.ScaleType.Fit
	headerIcon.Visible = false
	headerIcon.ZIndex = 100002
	headerIcon.Parent = headerBtn

	local headerText = Instance.new("TextLabel")
	headerText.Size = UDim2.new(1, -26, 1, 0)
	headerText.Position = UDim2.new(0, 6, 0, 0)
	headerText.BackgroundTransparency = 1
	headerText.TextSize = 12
	headerText.Text = "Select..."
	headerText.TextXAlignment = Enum.TextXAlignment.Center
	headerText.TextTruncate = Enum.TextTruncate.AtEnd
	headerText.ZIndex = 100002
	headerText.Parent = headerBtn
	ctx.ApplyTheme(headerText, "Text", "TextColor3")
	ctx.ApplyTheme(headerText, "TextFont", "Font")

	local function syncHeaderDisplay(txt)
		selectedText.Text = txt
		headerText.Text = txt
		local ic = (not isMulti and selectedItem) and optionIconMap[selectedItem] or nil
		if ic and ic ~= "" then
			selectedIcon.Image = ic
			selectedIcon.Visible = true
			selectedText.Position = UDim2.new(0, 38, 0, 0)
			selectedText.Size = UDim2.new(1, -58, 1, 0)
			selectedText.TextXAlignment = Enum.TextXAlignment.Left

			headerIcon.Image = ic
			headerIcon.Visible = true
			headerText.Position = UDim2.new(0, 26, 0, 0)
			headerText.Size = UDim2.new(1, -48, 1, 0)
			headerText.TextXAlignment = Enum.TextXAlignment.Left
		else
			selectedIcon.Visible = false
			selectedText.Position = UDim2.new(0, 16, 0, 0)
			selectedText.Size = UDim2.new(1, -36, 1, 0)
			selectedText.TextXAlignment = Enum.TextXAlignment.Center

			headerIcon.Visible = false
			headerText.Position = UDim2.new(0, 6, 0, 0)
			headerText.Size = UDim2.new(1, -26, 1, 0)
			headerText.TextXAlignment = Enum.TextXAlignment.Center
		end
	end

	if defaultOpt then
		if isMulti and type(defaultOpt) == "table" then
			for _, opt in ipairs(defaultOpt) do
				local oName = parseDropdownOption(opt, iconMap)
				if table.find(optionNames, oName) and #selectedItems < maxSelections then
					table.insert(selectedItems, oName)
				end
			end
			if #selectedItems > 0 then
				syncHeaderDisplay(table.concat(selectedItems, ", "))
			end
		elseif not isMulti then
			local oName = parseDropdownOption(defaultOpt, iconMap)
			if table.find(optionNames, oName) then
				selectedItem = oName
				syncHeaderDisplay(oName)
			end
		end
	end

	local dividerLine = Instance.new("Frame")
	dividerLine.Size = UDim2.new(1, -16, 0, 1)
	dividerLine.Position = UDim2.new(0.5, 0, 0, 28)
	dividerLine.AnchorPoint = Vector2.new(0.5, 0)
	dividerLine.BorderSizePixel = 0
	dividerLine.ZIndex = 100001
	dividerLine.Parent = dropClip
	ctx.ApplyTheme(dividerLine, "Outlines", "BackgroundColor3")

	local scroll = Instance.new("ScrollingFrame")
	scroll.Position = UDim2.new(0, 0, 0, 31)
	scroll.Size = UDim2.new(1, 0, 1, -(33 + (isSearch and 34 or 0)))
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 2
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ZIndex = 100001
	scroll.Parent = dropClip
	ctx.ApplyTheme(scroll, "Outlines", "ScrollBarImageColor3")

	local scrollLayout = Instance.new("UIListLayout")
	scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
	scrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	scrollLayout.Padding = UDim.new(0, 2)
	scrollLayout.Parent = scroll

	local scrollPad = Instance.new("UIPadding")
	scrollPad.PaddingTop, scrollPad.PaddingBottom = UDim.new(0, 3), UDim.new(0, 4)
	scrollPad.PaddingLeft, scrollPad.PaddingRight = UDim.new(0, 4), UDim.new(0, 4)
	scrollPad.Parent = scroll

	local optionRows = {}
	local optionConns = {}

	local searchInputBar, sf
	if isSearch then
		sf = Instance.new("Frame")
		sf.Size = UDim2.new(1, -12, 0, 24)
		sf.AnchorPoint = Vector2.new(0.5, 1)
		sf.BorderSizePixel = 0
		sf.ZIndex = 100001
		sf.Parent = dropClip
		ctx.ApplyTheme(sf, "Element", "BackgroundColor3")
		local sfc = Instance.new("UICorner")
		sfc.Parent = sf
		ctx.RegisterCorner(sfc, "Element")
		ctx.AttachStroke(sf, "Element", "Element")

		searchInputBar = Instance.new("TextBox")
		searchInputBar.Size = UDim2.new(1, -12, 1, 0)
		searchInputBar.Position = UDim2.new(0, 6, 0, 0)
		searchInputBar.ClipsDescendants = true
		searchInputBar.BackgroundTransparency = 1
		searchInputBar.TextSize = 12
		searchInputBar.PlaceholderText = "Search..."
		searchInputBar.Text = ""
		searchInputBar.TextXAlignment = Enum.TextXAlignment.Left
		searchInputBar.ZIndex = 100002
		searchInputBar.Parent = sf
		ctx.ApplyTheme(searchInputBar, "Text", "TextColor3")
		ctx.ApplyTheme(searchInputBar, "TextMuted", "PlaceholderColor3")
		ctx.ApplyTheme(searchInputBar, "TextFont", "Font")

		ctx.TrackConnection(searchInputBar:GetPropertyChangedSignal("Text"):Connect(function()
			local q = string.lower(searchInputBar.Text)
			for _, row in ipairs(optionRows) do
				row.Btn.Visible = (q == "" or string.find(row.LowerName, q, 1, true) ~= nil)
			end
		end))
	end

	local function updateVisuals()
		for _, row in ipairs(optionRows) do
			local isSel = (isMulti and table.find(selectedItems, row.Name) ~= nil) or (not isMulti and selectedItem == row.Name)
			ctx.TweenTheme(row.Label, isSel and "Accent" or "Text", "TextColor3", T_FAST)
		end
	end

	local function buildOptions(list)
		for _, c in ipairs(optionConns) do
			if c.Connected then c:Disconnect() end
		end
		table.clear(optionConns)
		for _, row in ipairs(optionRows) do
			row.Btn:Destroy()
		end
		table.clear(optionRows)

		ingestOptions(list)

		for idx, opt in ipairs(parsedOptions) do
			local btn = Instance.new("TextButton")
			btn.Name = "Option_" .. tostring(idx)
			btn.Size = UDim2.new(1, 0, 0, 24)
			btn.BackgroundTransparency = 1
			btn.BorderSizePixel = 0
			btn.AutoButtonColor = false
			btn.Text = ""
			btn.ZIndex = 100002
			btn.Parent = scroll

			local btnC = Instance.new("UICorner")
			btnC.Parent = btn
			ctx.RegisterCorner(btnC, "Element")

			local textLbl
			if hasAnyIcon then
				local bPad = Instance.new("UIPadding")
				bPad.PaddingLeft, bPad.PaddingRight = UDim.new(0, 6), UDim.new(0, 6)
				bPad.Parent = btn

				if opt.Icon ~= "" then
					local img = Instance.new("ImageLabel")
					img.Size = UDim2.new(0, 16, 0, 16)
					img.Position = UDim2.new(0, 0, 0.5, 0)
					img.AnchorPoint = Vector2.new(0, 0.5)
					img.BackgroundTransparency = 1
					img.ScaleType = Enum.ScaleType.Fit
					img.Image = opt.Icon
					img.ZIndex = 100003
					img.Parent = btn
				end

				textLbl = Instance.new("TextLabel")
				textLbl.Size = UDim2.new(1, -22, 1, 0)
				textLbl.Position = UDim2.new(0, 22, 0, 0)
				textLbl.BackgroundTransparency = 1
				textLbl.TextSize = 12
				textLbl.Text = opt.Name
				textLbl.TextXAlignment = Enum.TextXAlignment.Left
				textLbl.TextTruncate = Enum.TextTruncate.AtEnd
				textLbl.ZIndex = 100003
				textLbl.Parent = btn
			else
				textLbl = Instance.new("TextLabel")
				textLbl.Size = UDim2.fromScale(1, 1)
				textLbl.BackgroundTransparency = 1
				textLbl.TextSize = 12
				textLbl.Text = opt.Name
				textLbl.TextXAlignment = Enum.TextXAlignment.Center
				textLbl.TextTruncate = Enum.TextTruncate.AtEnd
				textLbl.ZIndex = 100003
				textLbl.Parent = btn
			end
			ctx.ApplyTheme(textLbl, "TextFont", "Font")
			ctx.ApplyTheme(textLbl, "Text", "TextColor3")

			table.insert(optionRows, {
				Btn = btn,
				Label = textLbl,
				Name = opt.Name,
				LowerName = string.lower(opt.Name)
			})

			table.insert(optionConns, btn.MouseEnter:Connect(function()
				ctx.ApplyTheme(btn, "ElementHover", "BackgroundColor3")
				TS:Create(btn, T_FAST, { BackgroundTransparency = ctx.THEME.ElementTrans }):Play()
			end))
			table.insert(optionConns, btn.MouseLeave:Connect(function()
				TS:Create(btn, T_FAST, { BackgroundTransparency = 1 }):Play()
			end))
			table.insert(optionConns, btn.MouseButton1Click:Connect(function()
				if isMulti then
					local foundIdx = table.find(selectedItems, opt.Name)
					if foundIdx then
						table.remove(selectedItems, foundIdx)
					elseif #selectedItems < maxSelections then
						table.insert(selectedItems, opt.Name)
					end
					local txt = #selectedItems > 0 and table.concat(selectedItems, ", ") or "Select..."
					syncHeaderDisplay(txt)
					callback(selectedItems)
					updateVisuals()
				else
					selectedItem = opt.Name
					syncHeaderDisplay(opt.Name)
					updateVisuals()
					callback(opt.Name)
					ctx.Window.ClosePopup()
				end
			end))
		end
		updateVisuals()
	end
	buildOptions(rawOptions)

	local function getStyleMetrics(style)
		if style == 2 then return 56, 13, 26, 8, false, 22, 6, 16
		elseif style == 3 then return 30, 12, 22, 5, true, 0, 0, 0
		elseif style == 4 then return 46, 12, 22, 6, false, 18, 4, 14
		else return 38, 13, 28, 7, true, 0, 0, 0 end
	end

	local function applyDropdownLayout()
		local style = ctx.THEME.ElementStyle
		local elH, lblTxtSize, boxH, edge, isInline, boxY, lblY, lblH = getStyleMetrics(style)
		container.Size = UDim2.new(1, 0, 0, elH)
		label.TextSize = lblTxtSize

		local uiScaleVal = isMobile and 0.65 or 1
		local containerW = container.AbsoluteSize.X / uiScaleVal
		local font = Enum.Font[ctx.THEME.TextFont] or Enum.Font.Gotham

		if containerW <= 12 then
			if isInline then
				selectedBox.AnchorPoint, selectedBox.Position = Vector2.new(1, 0.5), UDim2.new(1, -edge, 0.5, 0)
				selectedBox.Size = customWidthRatio and UDim2.new(customWidthRatio, -(edge * 2), 0, boxH) or UDim2.new(0.44, 0, 0, boxH)
				label.Position, label.Size = UDim2.new(0, 15, 0, 0), UDim2.new(0.52, -15, 1, 0)
				label.Visible = true
				label.Text = dropName
			else
				selectedBox.AnchorPoint, selectedBox.Position = Vector2.new(1, 0), UDim2.new(1, -edge, 0, boxY)
				selectedBox.Size = customWidthRatio and UDim2.new(customWidthRatio, -(edge * 2), 0, boxH) or UDim2.new(1, -(edge * 2), 0, boxH)
				label.Position, label.Size = UDim2.new(0, 12, 0, lblY), UDim2.new(1, -24, 0, lblH)
				label.Visible = true
				label.Text = dropName
			end
			return
		end

		local maxW = math.max(76, containerW - (edge * 2))
		local minW = math.min(maxW, 68)
		local boxW
		if customWidthRatio then
			boxW = math.clamp(math.round(maxW * customWidthRatio), minW, maxW)
		else
			boxW = isInline and math.clamp(math.round(containerW * 0.44), minW, maxW) or maxW
		end

		if isInline then
			selectedBox.AnchorPoint = Vector2.new(1, 0.5)
			selectedBox.Position = UDim2.new(1, -edge, 0.5, 0)
			selectedBox.Size = UDim2.new(0, boxW, 0, boxH)

			local availLabelW = (containerW - edge - boxW) - 15 - 8
			if availLabelW < 18 then
				label.Visible = false
			else
				label.Visible = true
				label.Position = UDim2.new(0, 15, 0, 0)
				label.Size = UDim2.new(0, availLabelW, 1, 0)
				label.Text = truncateTwoDots(dropName, font, lblTxtSize, availLabelW)
			end
		else
			selectedBox.AnchorPoint = Vector2.new(1, 0)
			selectedBox.Position = UDim2.new(1, -edge, 0, boxY)
			selectedBox.Size = UDim2.new(0, boxW, 0, boxH)

			local availTopW = math.max(0, containerW - 24)
			label.Visible = true
			label.Position = UDim2.new(0, 12, 0, lblY)
			label.Size = UDim2.new(0, availTopW, 0, lblH)
			label.Text = truncateTwoDots(dropName, font, lblTxtSize, availTopW)
		end
	end

	table.insert(ctx.Window._styleCallbacks, function() applyDropdownLayout() end)
	ctx.TrackConnection(container:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyDropdownLayout))
	ctx.TrackConnection(label:GetPropertyChangedSignal("Font"):Connect(applyDropdownLayout))
	applyDropdownLayout()

	local resizingDrop = false
	ctx.TrackConnection(resizeHandle.MouseEnter:Connect(function()
		ctx.TweenTheme(rArrowTop, "Accent", "BackgroundColor3", T_FAST)
		ctx.TweenTheme(rArrowBot, "Accent", "BackgroundColor3", T_FAST)
	end))
	ctx.TrackConnection(resizeHandle.MouseLeave:Connect(function()
		if not resizingDrop then
			ctx.TweenTheme(rArrowTop, "TextMuted", "BackgroundColor3", T_FAST)
			ctx.TweenTheme(rArrowBot, "TextMuted", "BackgroundColor3", T_FAST)
		end
	end))
	ctx.TrackConnection(resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if ctx.Window.ActivePopup == dropPopup then ctx.Window.ClosePopup() end
			resizingDrop = true
			ctx.TweenTheme(rArrowTop, "Accent", "BackgroundColor3", T_FAST)
			ctx.TweenTheme(rArrowBot, "Accent", "BackgroundColor3", T_FAST)

			local uiScaleVal = isMobile and 0.65 or 1
			local startMouseX = input.Position.X
			local startW = selectedBox.AbsoluteSize.X / uiScaleVal
			local _, _, _, edge = getStyleMetrics(ctx.THEME.ElementStyle)
			local containerW = container.AbsoluteSize.X / uiScaleVal
			local maxW = math.max(76, containerW - (edge * 2))
			local minW = math.min(maxW, 68)

			ctx.StartDrag(input.UserInputType, function(moveInput)
				local delta = (startMouseX - moveInput.Position.X) / uiScaleVal
				local newW = math.clamp(startW + delta, minW, maxW)
				customWidthRatio = math.clamp(newW / maxW, minW / maxW, 1)
				applyDropdownLayout()
			end, function()
				resizingDrop = false
				ctx.TweenTheme(rArrowTop, "TextMuted", "BackgroundColor3", T_FAST)
				ctx.TweenTheme(rArrowBot, "TextMuted", "BackgroundColor3", T_FAST)
			end)
		end
	end))

	ctx.TrackConnection(headerBtn.MouseButton1Click:Connect(function()
		ctx.Window.ClosePopup()
	end))

	local dropTrackConn = nil
	ctx.TrackConnection(topBar.MouseButton1Click:Connect(function()
		local Window = ctx.Window
		if Window.ActivePopup == dropPopup then
			Window.ClosePopup()
			return
		end
		Window.ClosePopup()
		if searchInputBar then searchInputBar.Text = "" end

		local absX = selectedBox.AbsolutePosition.X - Window.Overlay.AbsolutePosition.X
		local absY = selectedBox.AbsolutePosition.Y - Window.Overlay.AbsolutePosition.Y
		local boxW, boxH = selectedBox.AbsoluteSize.X, selectedBox.AbsoluteSize.Y

		dropPopup.Parent = Window.Overlay
		dropPopup.Position = UDim2.new(0, absX, 0, absY)

		local visibleCount = math.clamp(#parsedOptions, 1, 5)
		local extraH = isSearch and 34 or 0
		local targetH = boxH + 3 + (visibleCount * 26) + 6 + extraH
		if sf then sf.Position = UDim2.new(0.5, 0, 0, targetH - 6) end

		dropPopup.Size = UDim2.new(0, boxW, 0, boxH)
		dropPopup.Visible = true
		selectedBox.BackgroundTransparency = 1
		selectedText.Visible = false
		selectedIcon.Visible = false
		arrow.Visible = false
		resizeHandle.Visible = false
		selectedBoxStroke.Enabled = false

		headerBtn.Size = UDim2.new(1, 0, 0, boxH)
		dividerLine.Position = UDim2.new(0.5, 0, 0, boxH)
		scroll.Position = UDim2.new(0, 0, 0, boxH + 3)
		scroll.Size = UDim2.new(1, 0, 1, -(boxH + 5 + extraH))

		Window.Overlay.Visible = true
		Window.ActivePopup = dropPopup

		if dropTrackConn then dropTrackConn:Disconnect() end
		dropTrackConn = RS.RenderStepped:Connect(function()
			if not dropPopup.Visible or not selectedBox.Parent then
				if dropTrackConn then dropTrackConn:Disconnect(); dropTrackConn = nil end
				return
			end
			dropPopup.Position = UDim2.new(0, selectedBox.AbsolutePosition.X - Window.Overlay.AbsolutePosition.X, 0, selectedBox.AbsolutePosition.Y - Window.Overlay.AbsolutePosition.Y)
			local scrollParent = selectedBox:FindFirstAncestorWhichIsA("ScrollingFrame")
			if scrollParent then
				local sTop = scrollParent.AbsolutePosition.Y - 15
				local sBottom = scrollParent.AbsolutePosition.Y + scrollParent.AbsoluteSize.Y + 15
				if selectedBox.AbsolutePosition.Y < sTop or selectedBox.AbsolutePosition.Y > sBottom then
					Window.ClosePopup()
				end
			end
		end)

		Window.ActivePopupClose = function()
			if dropTrackConn then dropTrackConn:Disconnect(); dropTrackConn = nil end
			local closeTween = TS:Create(dropPopup, T_MED, { Size = UDim2.new(0, boxW, 0, boxH) })
			closeTween:Play()
			TS:Create(arrow, T_MED, { Rotation = 180 }):Play()
			TS:Create(headerArrow, T_MED, { Rotation = 180 }):Play()
			closeTween.Completed:Once(function()
				dropPopup.Visible = false
				ctx.ApplyTheme(selectedBox, "InputTrans", "BackgroundTransparency")
				selectedText.Visible = true
				if not isMulti and selectedItem and optionIconMap[selectedItem] then
					selectedIcon.Visible = true
				end
				arrow.Visible = true
				resizeHandle.Visible = true
				selectedBoxStroke.Enabled = (ctx.THEME.InternalOutlines == "Only Elements" or ctx.THEME.InternalOutlines == "All")
				if not Window.ActivePopup then Window.Overlay.Visible = false end
			end)
		end

		TS:Create(dropPopup, T_MED, { Size = UDim2.new(0, boxW, 0, targetH) }):Play()
		headerArrow.Rotation = 180
		arrow.Rotation = 180
		TS:Create(arrow, T_MED, { Rotation = 0 }):Play()
		TS:Create(headerArrow, T_MED, { Rotation = 0 }):Play()
	end))

	reg.RegisterElement(dropName, container)

	local api = {}
	function api:Set(newSelection)
		if isMulti then
			if type(newSelection) == "table" then
				table.clear(selectedItems)
				for _, opt in ipairs(newSelection) do
					local oName = parseDropdownOption(opt, iconMap)
					if table.find(optionNames, oName) and #selectedItems < maxSelections then
						table.insert(selectedItems, oName)
					end
				end
			end
			local txt = #selectedItems > 0 and table.concat(selectedItems, ", ") or "Select..."
			if selectedText.Text ~= txt then
				syncHeaderDisplay(txt)
				updateVisuals()
				callback(selectedItems)
			end
		else
			if newSelection == nil then
				selectedItem = nil
				syncHeaderDisplay("Select...")
				updateVisuals()
				return
			end
			local oName = parseDropdownOption(newSelection, iconMap)
			if selectedItem == oName then return end
			if table.find(optionNames, oName) then
				selectedItem = oName
				syncHeaderDisplay(oName)
				updateVisuals()
				callback(oName)
			end
		end
	end
	function api:SetOptions(newOpts)
		buildOptions(newOpts)
		if searchInputBar and searchInputBar.Text ~= "" then
			local q = string.lower(searchInputBar.Text)
			for _, row in ipairs(optionRows) do
				row.Btn.Visible = (q == "" or string.find(row.LowerName, q, 1, true) ~= nil)
			end
		end
	end
	function api:Save()
		return {
			Selected = isMulti and selectedItems or selectedItem,
			Width = customWidthRatio
		}
	end
	function api:Load(val)
		if type(val) ~= "table" then return end
		if val.Selected ~= nil then api:Set(val.Selected) end
		if type(val.Width) == "number" then
			customWidthRatio = math.clamp(val.Width, 0.15, 1)
		else
			customWidthRatio = nil
		end
		applyDropdownLayout()
	end
	reg.RegisterAPI("Dropdown", dropName, api)
	return api
end

local function buildSliderElement(ctx, reg, slConfig)
	local slName = slConfig.Name or "Slider"
	local min = slConfig.Min or 0
	local max = slConfig.Max or 100
	local span = math.max(max - min, 1e-9)
	local rawStep = slConfig.Step or 1
	local step = (type(rawStep) == "number" and rawStep > 0) and rawStep or 1

	local stepStr = tostring(step)
	local decimals = 0
	local exp = stepStr:match("[eE]%-(%d+)")
	if exp then
		local mantissa = stepStr:match("^(.-)[eE]")
		local mantissaDecs = (mantissa and mantissa:find("%.")) and #mantissa:split(".")[2] or 0
		decimals = tonumber(exp) + mantissaDecs
	elseif stepStr:find("%.") then
		decimals = #stepStr:split(".")[2]
	end
	decimals = math.clamp(decimals, 0, 14)

	local function roundVal(val)
		val = math.clamp(val, min, max)
		local snapped = math.round(val / step) * step
		return math.clamp(tonumber(string.format("%." .. decimals .. "f", snapped)) or snapped, min, max)
	end
	local function formatVal(val)
		local s = string.format("%." .. decimals .. "f", val)
		if decimals > 0 then
			s = s:gsub("0+$", "")
			s = s:gsub("%.$", "")
		end
		if s == "-0" or s == "" then s = "0" end
		return s
	end

	local default = roundVal(slConfig.Default or min)
	local callback = slConfig.Callback or function() end
	local currentValue = default

	local container = createElementBase(ctx, reg.Container, 38)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.35, 0, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)
	label.BackgroundTransparency = 1
	label.TextSize = 13
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = slName
	label.Parent = container
	ctx.ApplyTheme(label, "Text", "TextColor3")
	ctx.ApplyTheme(label, "TextFont", "Font")

	local valueBox = Instance.new("Frame")
	valueBox.Size = UDim2.new(0, 52, 0, 24)
	valueBox.AnchorPoint = Vector2.new(1, 0.5)
	valueBox.Position = UDim2.new(1, -7, 0.5, 0)
	valueBox.BorderSizePixel = 0
	valueBox.Parent = container
	ctx.ApplyTheme(valueBox, "Input", "BackgroundColor3")
	ctx.ApplyTheme(valueBox, "InputTrans", "BackgroundTransparency")
	local vbC = Instance.new("UICorner")
	vbC.Parent = valueBox
	ctx.RegisterCorner(vbC, "Element")
	ctx.AttachStroke(valueBox, "Element", "Element")

	local valueInput = Instance.new("TextBox")
	valueInput.Size = UDim2.fromScale(1, 1)
	valueInput.BackgroundTransparency = 1
	valueInput.TextSize = 12
	valueInput.Text = formatVal(default)
	valueInput.TextTruncate = Enum.TextTruncate.AtEnd
	valueInput.Parent = valueBox
	ctx.ApplyTheme(valueInput, "Text", "TextColor3")
	ctx.ApplyTheme(valueInput, "TextFont", "Font")

	local track = Instance.new("Frame")
	track.Size = UDim2.new(0.52, -64, 0, 6)
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.Position = UDim2.new(1, -64, 0.5, 0)
	track.BorderSizePixel = 0
	track.Parent = container
	ctx.ApplyTheme(track, "Input", "BackgroundColor3")
	ctx.ApplyTheme(track, "InputTrans", "BackgroundTransparency")

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track
	ctx.AttachStroke(track, "Always", "Pill")

	local initAlpha = math.clamp((default - min) / span, 0, 1)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(initAlpha, 0, 1, 0)
	fill.BorderSizePixel = 0
	fill.ZIndex = 2
	fill.Parent = track
	ctx.ApplyTheme(fill, "Accent", "BackgroundColor3")
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 12, 0, 12)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(initAlpha, 0, 0.5, 0)
	knob.BorderSizePixel = 0
	knob.ZIndex = 3
	knob.Parent = track
	ctx.ApplyTheme(knob, "Accent", "BackgroundColor3")
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob
	local knobStroke = Instance.new("UIStroke")
	knobStroke.Thickness = 1.5
	knobStroke.Color = Color3.fromRGB(255, 255, 255)
	knobStroke.Parent = knob

	local baseKnobSize = 12
	local function updateStyle(style)
		if style == 1 then
			container.Size = UDim2.new(1, 0, 0, 38)
			label.Size, label.Position, label.TextSize = UDim2.new(0.35, 0, 1, 0), UDim2.new(0, 15, 0, 0), 13
			valueBox.Size, valueBox.AnchorPoint, valueBox.Position = UDim2.new(0, 52, 0, 24), Vector2.new(1, 0.5), UDim2.new(1, -7, 0.5, 0)
			track.Size, track.AnchorPoint, track.Position = UDim2.new(0.52, -64, 0, 6), Vector2.new(1, 0.5), UDim2.new(1, -64, 0.5, 0)
			baseKnobSize = 12
		elseif style == 2 then
			container.Size = UDim2.new(1, 0, 0, 44)
			label.Size, label.Position, label.TextSize = UDim2.new(0.5, 0, 0, 16), UDim2.new(0, 12, 0, 6), 13
			valueBox.Size, valueBox.AnchorPoint, valueBox.Position = UDim2.new(0, 52, 0, 20), Vector2.new(1, 0), UDim2.new(1, -12, 0, 4)
			track.Size, track.AnchorPoint, track.Position = UDim2.new(1, -24, 0, 6), Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 28)
			baseKnobSize = 12
		elseif style == 3 then
			container.Size = UDim2.new(1, 0, 0, 30)
			label.Size, label.Position, label.TextSize = UDim2.new(0.35, 0, 1, 0), UDim2.new(0, 15, 0, 0), 12
			valueBox.Size, valueBox.AnchorPoint, valueBox.Position = UDim2.new(0, 52, 0, 20), Vector2.new(1, 0.5), UDim2.new(1, -5, 0.5, 0)
			track.Size, track.AnchorPoint, track.Position = UDim2.new(0.52, -64, 0, 4), Vector2.new(1, 0.5), UDim2.new(1, -61, 0.5, 0)
			baseKnobSize = 10
		elseif style == 4 then
			container.Size = UDim2.new(1, 0, 0, 38)
			label.Size, label.Position, label.TextSize = UDim2.new(0.5, 0, 0, 14), UDim2.new(0, 12, 0, 4), 12
			valueBox.Size, valueBox.AnchorPoint, valueBox.Position = UDim2.new(0, 52, 0, 18), Vector2.new(1, 0), UDim2.new(1, -12, 0, 3)
			track.Size, track.AnchorPoint, track.Position = UDim2.new(1, -24, 0, 4), Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 24)
			baseKnobSize = 10
		end
		knob.Size = UDim2.new(0, baseKnobSize, 0, baseKnobSize)
	end
	table.insert(ctx.Window._styleCallbacks, updateStyle)
	updateStyle(ctx.THEME.ElementStyle)

	local function applyVisual(val, anim)
		local alpha = math.clamp((val - min) / span, 0, 1)
		valueInput.Text = formatVal(val)
		if anim then
			TS:Create(fill, T_SLIDER, { Size = UDim2.new(alpha, 0, 1, 0) }):Play()
			TS:Create(knob, T_SLIDER, { Position = UDim2.new(alpha, 0, 0.5, 0) }):Play()
		else
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		end
	end

	local function updateSliderFromX(posX)
		local rel = math.clamp((posX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local val = roundVal(min + span * rel)
		if val ~= currentValue then
			currentValue = val
			applyVisual(val, false)
			callback(val)
		end
	end

	ctx.TrackConnection(track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			TS:Create(knob, T_FAST, { Size = UDim2.new(0, baseKnobSize + 3, 0, baseKnobSize + 3) }):Play()
			updateSliderFromX(input.Position.X)
			ctx.StartDrag(input.UserInputType, function(moveInput)
				updateSliderFromX(moveInput.Position.X)
			end, function()
				TS:Create(knob, T_FAST, { Size = UDim2.new(0, baseKnobSize, 0, baseKnobSize) }):Play()
			end)
		end
	end))

	ctx.TrackConnection(valueInput.FocusLost:Connect(function()
		local num = tonumber(valueInput.Text)
		if not num or num ~= num or math.abs(num) == math.huge then
			valueInput.Text = formatVal(currentValue)
			return
		end
		local target = roundVal(num)
		currentValue = target
		applyVisual(target, true)
		callback(target)
	end))

	reg.RegisterElement(slName, container)

	local api = {}
	function api:Set(newVal)
		local v = roundVal(newVal)
		if currentValue == v then return end
		currentValue = v
		applyVisual(v, true)
		callback(v)
	end
	function api:Save() return { Value = currentValue } end
	function api:Load(val)
		if val and val.Value ~= nil then api:Set(val.Value) end
	end
	reg.RegisterAPI("Slider", slName, api)
	return api
end

local function buildRangeSliderElement(ctx, reg, slConfig)
	local slName = slConfig.Name or "Range Slider"
	local min = slConfig.Min or 0
	local max = slConfig.Max or 100
	local span = math.max(max - min, 1e-9)
	local rawStep = slConfig.Step or 1
	local step = (type(rawStep) == "number" and rawStep > 0) and rawStep or 1

	local stepStr = tostring(step)
	local decimals = 0
	local exp = stepStr:match("[eE]%-(%d+)")
	if exp then
		local mantissa = stepStr:match("^(.-)[eE]")
		local mantissaDecs = (mantissa and mantissa:find("%.")) and #mantissa:split(".")[2] or 0
		decimals = tonumber(exp) + mantissaDecs
	elseif stepStr:find("%.") then
		decimals = #stepStr:split(".")[2]
	end
	decimals = math.clamp(decimals, 0, 14)

	local function roundVal(val)
		val = math.clamp(val, min, max)
		local snapped = math.round(val / step) * step
		return math.clamp(tonumber(string.format("%." .. decimals .. "f", snapped)) or snapped, min, max)
	end
	local function formatVal(val)
		local s = string.format("%." .. decimals .. "f", val)
		if decimals > 0 then
			s = s:gsub("0+$", "")
			s = s:gsub("%.$", "")
		end
		if s == "-0" or s == "" then s = "0" end
		return s
	end
	local function formatPair(a, b)
		return formatVal(a) .. " - " .. formatVal(b)
	end

	local defMin, defMax = min, max
	if type(slConfig.Default) == "table" then
		defMin = slConfig.Default.Min or slConfig.Default[1] or min
		defMax = slConfig.Default.Max or slConfig.Default[2] or max
	end
	local curMin = roundVal(defMin)
	local curMax = roundVal(defMax)
	if curMin > curMax then curMin, curMax = curMax, curMin end

	local callback = slConfig.Callback or function() end
	local container = createElementBase(ctx, reg.Container, 38)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.32, 0, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)
	label.BackgroundTransparency = 1
	label.TextSize = 13
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = slName
	label.Parent = container
	ctx.ApplyTheme(label, "Text", "TextColor3")
	ctx.ApplyTheme(label, "TextFont", "Font")

	local valueBox = Instance.new("Frame")
	valueBox.Size = UDim2.new(0, 76, 0, 24)
	valueBox.AnchorPoint = Vector2.new(1, 0.5)
	valueBox.Position = UDim2.new(1, -7, 0.5, 0)
	valueBox.BorderSizePixel = 0
	valueBox.Parent = container
	ctx.ApplyTheme(valueBox, "Input", "BackgroundColor3")
	ctx.ApplyTheme(valueBox, "InputTrans", "BackgroundTransparency")
	local vbC = Instance.new("UICorner")
	vbC.Parent = valueBox
	ctx.RegisterCorner(vbC, "Element")
	ctx.AttachStroke(valueBox, "Element", "Element")

	local valueInput = Instance.new("TextBox")
	valueInput.Size = UDim2.fromScale(1, 1)
	valueInput.BackgroundTransparency = 1
	valueInput.TextSize = 11
	valueInput.Text = formatPair(curMin, curMax)
	valueInput.TextTruncate = Enum.TextTruncate.AtEnd
	valueInput.Parent = valueBox
	ctx.ApplyTheme(valueInput, "Text", "TextColor3")
	ctx.ApplyTheme(valueInput, "TextFont", "Font")

	local track = Instance.new("Frame")
	track.Size = UDim2.new(0.55, -88, 0, 6)
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.Position = UDim2.new(1, -88, 0.5, 0)
	track.BorderSizePixel = 0
	track.Parent = container
	ctx.ApplyTheme(track, "Input", "BackgroundColor3")
	ctx.ApplyTheme(track, "InputTrans", "BackgroundTransparency")

	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track
	ctx.AttachStroke(track, "Always", "Pill")

	local minAlpha = math.clamp((curMin - min) / span, 0, 1)
	local maxAlpha = math.clamp((curMax - min) / span, 0, 1)

	local fill = Instance.new("Frame")
	fill.Position = UDim2.new(minAlpha, 0, 0, 0)
	fill.Size = UDim2.new(math.max(0, maxAlpha - minAlpha), 0, 1, 0)
	fill.BorderSizePixel = 0
	fill.ZIndex = 2
	fill.Parent = track
	ctx.ApplyTheme(fill, "Accent", "BackgroundColor3")
	local fillC = Instance.new("UICorner")
	fillC.CornerRadius = UDim.new(1, 0)
	fillC.Parent = fill

	local function createKnob(alpha)
		local k = Instance.new("Frame")
		k.Size = UDim2.new(0, 12, 0, 12)
		k.AnchorPoint = Vector2.new(0.5, 0.5)
		k.Position = UDim2.new(alpha, 0, 0.5, 0)
		k.BorderSizePixel = 0
		k.ZIndex = 3
		k.Parent = track
		ctx.ApplyTheme(k, "Accent", "BackgroundColor3")
		local kc = Instance.new("UICorner")
		kc.CornerRadius = UDim.new(1, 0)
		kc.Parent = k
		local ks = Instance.new("UIStroke")
		ks.Thickness = 1.5
		ks.Color = Color3.fromRGB(255, 255, 255)
		ks.Parent = k
		return k
	end

	local minKnob = createKnob(minAlpha)
	local maxKnob = createKnob(maxAlpha)
	local baseKnobSize = 12

	local function updateStyle(style)
		if style == 1 then
			container.Size = UDim2.new(1, 0, 0, 38)
			label.Size, label.Position, label.TextSize = UDim2.new(0.32, 0, 1, 0), UDim2.new(0, 15, 0, 0), 13
			valueBox.Size, valueBox.AnchorPoint, valueBox.Position = UDim2.new(0, 76, 0, 24), Vector2.new(1, 0.5), UDim2.new(1, -7, 0.5, 0)
			track.Size, track.AnchorPoint, track.Position = UDim2.new(0.55, -88, 0, 6), Vector2.new(1, 0.5), UDim2.new(1, -88, 0.5, 0)
			baseKnobSize = 12
		elseif style == 2 then
			container.Size = UDim2.new(1, 0, 0, 44)
			label.Size, label.Position, label.TextSize = UDim2.new(0.48, 0, 0, 16), UDim2.new(0, 12, 0, 6), 13
			valueBox.Size, valueBox.AnchorPoint, valueBox.Position = UDim2.new(0, 78, 0, 20), Vector2.new(1, 0), UDim2.new(1, -12, 0, 4)
			track.Size, track.AnchorPoint, track.Position = UDim2.new(1, -24, 0, 6), Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 28)
			baseKnobSize = 12
		elseif style == 3 then
			container.Size = UDim2.new(1, 0, 0, 30)
			label.Size, label.Position, label.TextSize = UDim2.new(0.32, 0, 1, 0), UDim2.new(0, 15, 0, 0), 12
			valueBox.Size, valueBox.AnchorPoint, valueBox.Position = UDim2.new(0, 72, 0, 20), Vector2.new(1, 0.5), UDim2.new(1, -5, 0.5, 0)
			track.Size, track.AnchorPoint, track.Position = UDim2.new(0.55, -84, 0, 4), Vector2.new(1, 0.5), UDim2.new(1, -82, 0.5, 0)
			baseKnobSize = 10
		elseif style == 4 then
			container.Size = UDim2.new(1, 0, 0, 38)
			label.Size, label.Position, label.TextSize = UDim2.new(0.48, 0, 0, 14), UDim2.new(0, 12, 0, 4), 12
			valueBox.Size, valueBox.AnchorPoint, valueBox.Position = UDim2.new(0, 74, 0, 18), Vector2.new(1, 0), UDim2.new(1, -12, 0, 3)
			track.Size, track.AnchorPoint, track.Position = UDim2.new(1, -24, 0, 4), Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 24)
			baseKnobSize = 10
		end
		minKnob.Size = UDim2.new(0, baseKnobSize, 0, baseKnobSize)
		maxKnob.Size = UDim2.new(0, baseKnobSize, 0, baseKnobSize)
	end
	table.insert(ctx.Window._styleCallbacks, updateStyle)
	updateStyle(ctx.THEME.ElementStyle)

	local function applyVisual(a, b, anim)
		local a1 = math.clamp((a - min) / span, 0, 1)
		local a2 = math.clamp((b - min) / span, 0, 1)
		valueInput.Text = formatPair(a, b)
		if anim then
			TS:Create(fill, T_SLIDER, { Position = UDim2.new(a1, 0, 0, 0), Size = UDim2.new(math.max(0, a2 - a1), 0, 1, 0) }):Play()
			TS:Create(minKnob, T_SLIDER, { Position = UDim2.new(a1, 0, 0.5, 0) }):Play()
			TS:Create(maxKnob, T_SLIDER, { Position = UDim2.new(a2, 0, 0.5, 0) }):Play()
		else
			fill.Position = UDim2.new(a1, 0, 0, 0)
			fill.Size = UDim2.new(math.max(0, a2 - a1), 0, 1, 0)
			minKnob.Position = UDim2.new(a1, 0, 0.5, 0)
			maxKnob.Position = UDim2.new(a2, 0, 0.5, 0)
		end
	end

	ctx.TrackConnection(track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			local clickedVal = min + span * rel
			local activeHandle
			if math.abs(clickedVal - curMin) < math.abs(clickedVal - curMax) then
				activeHandle = "min"
			elseif math.abs(clickedVal - curMin) > math.abs(clickedVal - curMax) then
				activeHandle = "max"
			else
				activeHandle = (clickedVal <= curMin) and "min" or "max"
			end

			local activeKnob = (activeHandle == "min") and minKnob or maxKnob
			activeKnob.ZIndex = 4
			TS:Create(activeKnob, T_FAST, { Size = UDim2.new(0, baseKnobSize + 3, 0, baseKnobSize + 3) }):Play()

			local function handleMove(posX)
				local r = math.clamp((posX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
				local v = roundVal(min + span * r)
				if activeHandle == "min" then
					v = math.min(v, curMax)
					if v ~= curMin then
						curMin = v
						applyVisual(curMin, curMax, true)
						callback(curMin, curMax)
					end
				else
					v = math.max(v, curMin)
					if v ~= curMax then
						curMax = v
						applyVisual(curMin, curMax, true)
						callback(curMin, curMax)
					end
				end
			end

			handleMove(input.Position.X)
			ctx.StartDrag(input.UserInputType, function(moveInput)
				handleMove(moveInput.Position.X)
			end, function()
				activeKnob.ZIndex = 3
				TS:Create(activeKnob, T_FAST, { Size = UDim2.new(0, baseKnobSize, 0, baseKnobSize) }):Play()
			end)
		end
	end))

	ctx.TrackConnection(valueInput.FocusLost:Connect(function()
		local nums = {}
		for m in string.gmatch(valueInput.Text, "[-+]?%d*%.?%d+") do
			local n = tonumber(m)
			if n then table.insert(nums, n) end
		end
		if #nums >= 2 then
			local a, b = roundVal(nums[1]), roundVal(nums[2])
			if a > b then a, b = b, a end
			curMin, curMax = a, b
			applyVisual(curMin, curMax, true)
			callback(curMin, curMax)
		elseif #nums == 1 then
			local v = roundVal(nums[1])
			if math.abs(v - curMin) <= math.abs(v - curMax) then
				curMin = math.min(v, curMax)
			else
				curMax = math.max(v, curMin)
			end
			applyVisual(curMin, curMax, true)
			callback(curMin, curMax)
		else
			valueInput.Text = formatPair(curMin, curMax)
		end
	end))

	reg.RegisterElement(slName, container)

	local api = {}
	function api:Set(newMin, newMax)
		if type(newMin) == "table" then
			newMax = newMin.Max or newMin[2]
			newMin = newMin.Min or newMin[1]
		end
		local a = roundVal(newMin or curMin)
		local b = roundVal(newMax or curMax)
		if a > b then a, b = b, a end
		if a == curMin and b == curMax then return end
		curMin, curMax = a, b
		applyVisual(curMin, curMax, true)
		callback(curMin, curMax)
	end
	function api:Get() return curMin, curMax end
	function api:Save() return { Min = curMin, Max = curMax } end
	function api:Load(val)
		if type(val) == "table" and val.Min ~= nil and val.Max ~= nil then
			api:Set(val.Min, val.Max)
		end
	end
	reg.RegisterAPI("RangeSlider", slName, api)
	return api
end

local function buildToggleElement(ctx, reg, cfg)
	local tglName = cfg.Name or "Toggle"
	local state = cfg.Default or false
	local callback = cfg.Callback or function() end

	local hasCP = cfg.Colorpicker or (cfg.Color ~= nil)
	local hasCP2 = cfg.Colorpicker2 or (cfg.Color2 ~= nil)
	local hasKB = (cfg.Keybind ~= nil)
	local bind = typeof(cfg.Keybind) == "EnumItem" and cfg.Keybind or (cfg.Keybind == true and Enum.KeyCode.Unknown or nil)

	local currentColor = cfg.Color or Color3.fromRGB(255, 255, 255)
	local currentColor2 = cfg.Color2 or Color3.fromRGB(255, 255, 255)
	local isCombo = hasCP or hasCP2 or hasKB

	local container = createElementBase(ctx, reg.Container, 38)
	if isCombo then
		container:SetAttribute("TogglePos", ctx.THEME.TogglePosition)
		ctx.BindLayout("ComboToggle", container)
	end

	local fullBarBtn = Instance.new("TextButton")
	fullBarBtn.Size = UDim2.fromScale(1, 1)
	fullBarBtn.BackgroundTransparency = 1
	fullBarBtn.Text = ""
	fullBarBtn.ZIndex = 2
	fullBarBtn.Parent = container

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)
	label.BackgroundTransparency = 1
	label.TextSize = 13
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = tglName
	label.ZIndex = 3
	label.Parent = container
	ctx.ApplyTheme(label, "Text", "TextColor3")
	ctx.ApplyTheme(label, "TextFont", "Font")
	if not isCombo then ctx.BindLayout("ToggleLabel", label) end

	local toggleBox = Instance.new("Frame")
	toggleBox.Size = UDim2.new(0, 24, 0, 24)
	toggleBox.AnchorPoint = Vector2.new(1, 0.5)
	toggleBox.Position = UDim2.new(1, -7, 0.5, 0)
	toggleBox.BackgroundTransparency = 1
	toggleBox.ZIndex = 3
	toggleBox.Parent = container
	if not isCombo then ctx.BindLayout("ToggleBox", toggleBox) end

	local tbCorner = Instance.new("UICorner")
	tbCorner.Parent = toggleBox
	ctx.RegisterCorner(tbCorner, "Element")

	local toggleStroke = Instance.new("UIStroke")
	toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	toggleStroke.Thickness = 1
	toggleStroke.Parent = toggleBox
	ctx.ApplyTheme(toggleStroke, state and "Accent" or "Outlines", "Color")

	local fill = Instance.new("Frame")
	fill.Position = UDim2.fromScale(0.5, 0.5)
	fill.AnchorPoint = Vector2.new(0.5, 0.5)
	fill.BorderSizePixel = 0
	fill.ZIndex = 4
	fill.Size = state and UDim2.new(1, -10, 1, -10) or UDim2.new(0, 0, 0, 0)
	fill.Parent = toggleBox
	ctx.ApplyTheme(fill, "Accent", "BackgroundColor3")
	local fCorner = Instance.new("UICorner")
	fCorner.Parent = fill
	ctx.RegisterCorner(fCorner, "Element")

	local function fireCallback()
		if hasCP and hasCP2 and hasKB then callback(state, currentColor, currentColor2, bind)
		elseif hasCP and hasCP2 then callback(state, currentColor, currentColor2)
		elseif hasCP and hasKB then callback(state, currentColor, bind)
		elseif hasCP2 and hasKB then callback(state, currentColor2, bind)
		elseif hasCP then callback(state, currentColor)
		elseif hasCP2 then callback(state, currentColor2)
		elseif hasKB then callback(state, bind)
		else callback(state) end
	end

	local previewBox, previewBox2, kbBox, kbBtn, updateColors, updateColors2, mobileToggle, getMobileBtn

	if hasCP then
		previewBox = Instance.new("TextButton")
		previewBox.BackgroundColor3 = currentColor
		previewBox.BorderSizePixel = 0
		previewBox.Text = ""
		previewBox.ZIndex = 5
		previewBox.Parent = container
		local pc = Instance.new("UICorner")
		pc.Parent = previewBox
		ctx.RegisterCorner(pc, "Element")
		local ps = Instance.new("UIStroke")
		ps.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ps.Thickness = 2
		ps.Parent = previewBox
		ctx.ApplyTheme(ps, "Outlines", "Color")
		updateColors = attachColorPicker(ctx, previewBox, currentColor, function(col)
			currentColor = col
			fireCallback()
		end)
	end

	if hasCP2 then
		previewBox2 = Instance.new("TextButton")
		previewBox2.BackgroundColor3 = currentColor2
		previewBox2.BorderSizePixel = 0
		previewBox2.Text = ""
		previewBox2.ZIndex = 5
		previewBox2.Parent = container
		local pc2 = Instance.new("UICorner")
		pc2.Parent = previewBox2
		ctx.RegisterCorner(pc2, "Element")
		local ps2 = Instance.new("UIStroke")
		ps2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ps2.Thickness = 2
		ps2.Parent = previewBox2
		ctx.ApplyTheme(ps2, "Outlines", "Color")
		updateColors2 = attachColorPicker(ctx, previewBox2, currentColor2, function(col)
			currentColor2 = col
			fireCallback()
		end)
	end

	if hasKB then
		kbBox = Instance.new("Frame")
		kbBox.Size = UDim2.new(0, 30, 0, 24)
		kbBox.BorderSizePixel = 0
		kbBox.ZIndex = 5
		kbBox.Parent = container
		ctx.ApplyTheme(kbBox, "Input", "BackgroundColor3")
		ctx.ApplyTheme(kbBox, "InputTrans", "BackgroundTransparency")
		local kc = Instance.new("UICorner")
		kc.Parent = kbBox
		ctx.RegisterCorner(kc, "Element")
		ctx.AttachStroke(kbBox, "Element", "Element")

		kbBtn = Instance.new("TextButton")
		kbBtn.Size = UDim2.fromScale(1, 1)
		kbBtn.BackgroundTransparency = 1
		kbBtn.Text = getShortKey(bind)
		kbBtn.TextSize = 12
		kbBtn.ZIndex = 6
		kbBtn.Parent = kbBox
		ctx.ApplyTheme(kbBtn, "TextMuted", "TextColor3")
		ctx.ApplyTheme(kbBtn, "TextFont", "Font")
	end

	local function updateStyle(style)
		local isCompact = (style == 3 or style == 4)
		container.Size = UDim2.new(1, 0, 0, isCompact and 30 or 38)
		label.TextSize = isCompact and 12 or 13
		local boxSize = isCompact and 18 or 24
		toggleBox.Size = UDim2.new(0, boxSize, 0, boxSize)
		local edge = isCompact and 5 or 7
		local tPos = isCombo and (container:GetAttribute("TogglePos") or ctx.THEME.TogglePosition) or ctx.THEME.TogglePosition

		if not isCombo then
			if tPos == "Left" then
				toggleBox.AnchorPoint, toggleBox.Position = Vector2.new(0, 0.5), UDim2.new(0, edge, 0.5, 0)
				label.Position, label.Size = UDim2.new(0, edge + boxSize + 7, 0, 0), UDim2.new(1, -(edge + boxSize + 15), 1, 0)
			else
				toggleBox.AnchorPoint, toggleBox.Position = Vector2.new(1, 0.5), UDim2.new(1, -edge, 0.5, 0)
				label.Position, label.Size = UDim2.new(0, 15, 0, 0), UDim2.new(1, -60, 1, 0)
			end
		else
			if previewBox then previewBox.Size = UDim2.new(0, boxSize, 0, boxSize) end
			if previewBox2 then previewBox2.Size = UDim2.new(0, boxSize, 0, boxSize) end
			local kbW = 0
			if kbBox then
				kbBtn.TextSize = isCompact and 11 or 12
				kbW = syncKeyBoxWidth(kbBox, kbBtn, isCompact and 20 or 24)
			end
			local gap = 6
			if tPos == "Left" then
				toggleBox.AnchorPoint, toggleBox.Position = Vector2.new(0, 0.5), UDim2.new(0, edge, 0.5, 0)
				local rightOffset = edge
				if kbBox then kbBox.AnchorPoint = Vector2.new(1, 0.5); kbBox.Position = UDim2.new(1, -rightOffset, 0.5, 0); rightOffset = rightOffset + kbW + gap end
				if previewBox2 then previewBox2.AnchorPoint = Vector2.new(1, 0.5); previewBox2.Position = UDim2.new(1, -rightOffset, 0.5, 0); rightOffset = rightOffset + boxSize + gap end
				if previewBox then previewBox.AnchorPoint = Vector2.new(1, 0.5); previewBox.Position = UDim2.new(1, -rightOffset, 0.5, 0); rightOffset = rightOffset + boxSize + gap end
				if mobileToggle then mobileToggle.AnchorPoint = Vector2.new(1, 0.5); mobileToggle.Position = UDim2.new(1, -rightOffset, 0.5, 0); rightOffset = rightOffset + 22 + gap end
				local leftOffset = edge + boxSize + gap
				label.Position = UDim2.new(0, leftOffset, 0, 0)
				label.Size = UDim2.new(1, -(leftOffset + rightOffset + 5), 1, 0)
			else
				toggleBox.AnchorPoint, toggleBox.Position = Vector2.new(1, 0.5), UDim2.new(1, -edge, 0.5, 0)
				local offset = edge + boxSize + gap
				if previewBox then previewBox.AnchorPoint = Vector2.new(1, 0.5); previewBox.Position = UDim2.new(1, -offset, 0.5, 0); offset = offset + boxSize + gap end
				if previewBox2 then previewBox2.AnchorPoint = Vector2.new(1, 0.5); previewBox2.Position = UDim2.new(1, -offset, 0.5, 0); offset = offset + boxSize + gap end
				if kbBox then kbBox.AnchorPoint = Vector2.new(1, 0.5); kbBox.Position = UDim2.new(1, -offset, 0.5, 0); offset = offset + kbW + gap end
				label.Position = UDim2.new(0, 15, 0, 0)
				label.Size = UDim2.new(1, -offset - 20, 1, 0)
			end
		end
	end
	table.insert(ctx.Window._styleCallbacks, updateStyle)
	if isCombo then
		ctx.TrackConnection(container:GetAttributeChangedSignal("TogglePos"):Connect(function() updateStyle(ctx.THEME.ElementStyle) end))
	end
	updateStyle(ctx.THEME.ElementStyle)

	local function updateToggle(anim)
		if state then
			ctx.TweenTheme(toggleStroke, "Accent", "Color", T_FAST)
			if anim then
				TS:Create(fill, T_BACK, { Size = UDim2.new(1, -10, 1, -10) }):Play()
			else
				fill.Size = UDim2.new(1, -10, 1, -10)
			end
		else
			ctx.TweenTheme(toggleStroke, "Outlines", "Color", T_FAST)
			if anim then
				TS:Create(fill, T_FAST, { Size = UDim2.new(0, 0, 0, 0) }):Play()
			else
				fill.Size = UDim2.new(0, 0, 0, 0)
			end
		end
		fireCallback()
		if hasKB and ctx.Window.UpdateKeybinds then ctx.Window.UpdateKeybinds() end
	end

	if isMobile and hasKB then
		mobileToggle, _, getMobileBtn = ctx.CreateMobileToggle(container, function(enabled, removeBtn, saveBtn)
			if enabled then
				saveBtn(ctx.CreateMobileBindButton(getShortKey(bind), function()
					state = not state
					updateToggle(true)
				end))
			else
				removeBtn()
			end
		end)
		updateStyle(ctx.THEME.ElementStyle)
	end

	ctx.TrackConnection(fullBarBtn.MouseEnter:Connect(function()
		ctx.TweenTheme(container, "ElementHover", "BackgroundColor3", T_FAST)
	end))
	ctx.TrackConnection(fullBarBtn.MouseLeave:Connect(function()
		ctx.TweenTheme(container, "Element", "BackgroundColor3", T_FAST)
	end))
	ctx.TrackConnection(fullBarBtn.MouseButton1Click:Connect(function()
		state = not state
		updateToggle(true)
	end))

	if hasKB then
		ctx.TrackConnection(kbBtn.MouseButton1Click:Connect(function()
			kbBtn.Text = "..."
			ctx.TweenTheme(kbBtn, "Accent", "TextColor3", T_FAST)
			updateStyle(ctx.THEME.ElementStyle)
			ctx.ActiveKeyBinder = function(keyCode)
				bind = keyCode
				kbBtn.Text = getShortKey(bind)
				ctx.TweenTheme(kbBtn, "TextMuted", "TextColor3", T_FAST)
				updateStyle(ctx.THEME.ElementStyle)
				local mb = getMobileBtn and getMobileBtn()
				if mb then mb.Text = getShortKey(bind) end
				fireCallback()
				if ctx.Window.UpdateKeybinds then ctx.Window.UpdateKeybinds() end
			end
		end))
		ctx.RegisterKeyListener(function(keyCode)
			if bind and bind ~= Enum.KeyCode.Unknown and keyCode == bind then
				state = not state
				updateToggle(true)
			end
		end)
	end

	reg.RegisterElement(tglName, container)

	local api = {}
	function api:Set(newState)
		if state == newState then return end
		state = newState
		updateToggle(true)
	end
	function api:SetColor(newColor)
		if not hasCP then return end
		currentColor = newColor
		if updateColors then updateColors:SetColor(newColor) end
	end
	function api:SetColor2(newColor)
		if not hasCP2 then return end
		currentColor2 = newColor
		if updateColors2 then updateColors2:SetColor(newColor) end
	end
	function api:SetKeybind(newKey)
		if not hasKB then return end
		bind = newKey
		kbBtn.Text = getShortKey(bind)
		updateStyle(ctx.THEME.ElementStyle)
		local mb = getMobileBtn and getMobileBtn()
		if mb then mb.Text = getShortKey(bind) end
	end
	function api:Save()
		return {
			State = state,
			Color = hasCP and { currentColor.R, currentColor.G, currentColor.B } or nil,
			Color2 = hasCP2 and { currentColor2.R, currentColor2.G, currentColor2.B } or nil,
			Bind = hasKB and (bind and bind.Name) or nil
		}
	end
	function api:Load(val)
		if not val then return end
		if val.State ~= nil then api:Set(val.State) end
		if hasCP and val.Color then api:SetColor(Color3.new(unpack(val.Color))) end
		if hasCP2 and val.Color2 then api:SetColor2(Color3.new(unpack(val.Color2))) end
		if hasKB and val.Bind then api:SetKeybind(Enum.KeyCode[val.Bind]) end
	end
	reg.RegisterAPI("Toggle", tglName, api)
	if state then task.spawn(fireCallback) end
	return api
end

local function buildInputElement(ctx, reg, inpConfig)
	local inpName = inpConfig.Name or "Input"
	local placeholder = inpConfig.Placeholder or "..."
	local defaultText = inpConfig.Default or ""
	local callback = inpConfig.Callback or function() end

	local container = createElementBase(ctx, reg.Container, 38)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.52, -15, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)
	label.BackgroundTransparency = 1
	label.TextSize = 13
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = inpName
	label.Parent = container
	ctx.ApplyTheme(label, "Text", "TextColor3")
	ctx.ApplyTheme(label, "TextFont", "Font")

	local inputBox = Instance.new("Frame")
	inputBox.Size = UDim2.new(0.44, 0, 0, 28)
	inputBox.AnchorPoint = Vector2.new(1, 0.5)
	inputBox.Position = UDim2.new(1, -7, 0.5, 0)
	inputBox.BorderSizePixel = 0
	inputBox.Parent = container
	ctx.ApplyTheme(inputBox, "Input", "BackgroundColor3")
	ctx.ApplyTheme(inputBox, "InputTrans", "BackgroundTransparency")
	local ibC = Instance.new("UICorner")
	ibC.Parent = inputBox
	ctx.RegisterCorner(ibC, "Element")
	local ibStroke = ctx.AttachStroke(inputBox, "Element", "Element")

	local textClip = Instance.new("Frame")
	textClip.Size = UDim2.fromScale(1, 1)
	textClip.BackgroundTransparency = 1
	textClip.ClipsDescendants = true
	textClip.ZIndex = 2
	textClip.Parent = inputBox

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(1, -10, 1, 0)
	textBox.Position = UDim2.new(0, 5, 0, 0)
	textBox.BackgroundTransparency = 1
	textBox.TextSize = 12
	textBox.PlaceholderText = placeholder
	textBox.Text = defaultText
	textBox.TextXAlignment = Enum.TextXAlignment.Center
	textBox.TextTruncate = Enum.TextTruncate.AtEnd
	textBox.Parent = textClip
	ctx.ApplyTheme(textBox, "Text", "TextColor3")
	ctx.ApplyTheme(textBox, "TextMuted", "PlaceholderColor3")
	ctx.ApplyTheme(textBox, "TextFont", "Font")

	local function updateStyle(style)
		if style == 1 then
			container.Size = UDim2.new(1, 0, 0, 38)
			label.Size, label.Position, label.TextSize = UDim2.new(0.52, -15, 1, 0), UDim2.new(0, 15, 0, 0), 13
			inputBox.Size, inputBox.AnchorPoint, inputBox.Position = UDim2.new(0.44, 0, 0, 28), Vector2.new(1, 0.5), UDim2.new(1, -7, 0.5, 0)
		elseif style == 2 then
			container.Size = UDim2.new(1, 0, 0, 56)
			label.Size, label.Position, label.TextSize = UDim2.new(1, -24, 0, 16), UDim2.new(0, 12, 0, 6), 13
			inputBox.Size, inputBox.AnchorPoint, inputBox.Position = UDim2.new(1, -16, 0, 26), Vector2.new(0, 0), UDim2.new(0, 8, 0, 22)
		elseif style == 3 then
			container.Size = UDim2.new(1, 0, 0, 30)
			label.Size, label.Position, label.TextSize = UDim2.new(0.52, -15, 1, 0), UDim2.new(0, 15, 0, 0), 12
			inputBox.Size, inputBox.AnchorPoint, inputBox.Position = UDim2.new(0.44, 0, 0, 22), Vector2.new(1, 0.5), UDim2.new(1, -5, 0.5, 0)
		elseif style == 4 then
			container.Size = UDim2.new(1, 0, 0, 46)
			label.Size, label.Position, label.TextSize = UDim2.new(1, -24, 0, 14), UDim2.new(0, 12, 0, 4), 12
			inputBox.Size, inputBox.AnchorPoint, inputBox.Position = UDim2.new(1, -12, 0, 22), Vector2.new(0, 0), UDim2.new(0, 6, 0, 18)
		end
	end
	table.insert(ctx.Window._styleCallbacks, updateStyle)
	updateStyle(ctx.THEME.ElementStyle)

	ctx.TrackConnection(textBox.Focused:Connect(function()
		if ibStroke.Enabled then ctx.TweenTheme(ibStroke, "Accent", "Color", T_FAST) end
	end))
	ctx.TrackConnection(textBox.FocusLost:Connect(function()
		if ibStroke.Enabled then ctx.TweenTheme(ibStroke, "Outlines", "Color", T_FAST) end
		callback(textBox.Text)
	end))
	reg.RegisterElement(inpName, container)

	local api = {}
	function api:SetText(txt)
		textBox.Text = txt
		callback(txt)
	end
	function api:Save() return { Text = textBox.Text } end
	function api:Load(val)
		if val and val.Text ~= nil then api:SetText(val.Text) end
	end
	reg.RegisterAPI("Input", inpName, api)
	return api
end

local function buildButtonElement(ctx, reg, btnConfig)
	local btnName = btnConfig.Name or "Button"
	local callback = btnConfig.Callback or function() end

	local btn = createElementBase(ctx, reg.Container, 38)
	local btnInteractive = Instance.new("TextButton")
	btnInteractive.Size = UDim2.fromScale(1, 1)
	btnInteractive.BackgroundTransparency = 1
	btnInteractive.TextSize = 13
	btnInteractive.Text = btnName
	btnInteractive.TextTruncate = Enum.TextTruncate.AtEnd
	btnInteractive.Parent = btn
	ctx.ApplyTheme(btnInteractive, "Text", "TextColor3")
	ctx.ApplyTheme(btnInteractive, "TextFont", "Font")

	local function updateStyle(style)
		if style == 3 or style == 4 then
			btn.Size = UDim2.new(1, 0, 0, 30)
			btnInteractive.TextSize = 12
		else
			btn.Size = UDim2.new(1, 0, 0, 38)
			btnInteractive.TextSize = 13
		end
	end
	table.insert(ctx.Window._styleCallbacks, updateStyle)
	updateStyle(ctx.THEME.ElementStyle)

	local hovering = false
	ctx.TrackConnection(btnInteractive.MouseEnter:Connect(function()
		hovering = true
		ctx.TweenTheme(btn, "ElementHover", "BackgroundColor3", T_FAST)
	end))
	ctx.TrackConnection(btnInteractive.MouseLeave:Connect(function()
		hovering = false
		ctx.TweenTheme(btn, "Element", "BackgroundColor3", T_FAST)
	end))
	ctx.TrackConnection(btnInteractive.MouseButton1Down:Connect(function()
		ctx.TweenTheme(btn, "CardHover", "BackgroundColor3", T_FAST)
	end))
	ctx.TrackConnection(btnInteractive.MouseButton1Up:Connect(function()
		ctx.TweenTheme(btn, hovering and "ElementHover" or "Element", "BackgroundColor3", T_FAST)
		callback()
	end))
	reg.RegisterElement(btnName, btn)

	local api = {}
	function api:SetText(txt) btnInteractive.Text = txt end
	function api:SetCallback(cb) callback = cb end
	return api
end

local function buildButtonKeybindElement(ctx, reg, cfg)
	local btnName = cfg.Name or "Button"
	local callback = cfg.Callback or function() end
	local bind = cfg.Default

	local el = createElementBase(ctx, reg.Container, 38)
	local btnInteractive = Instance.new("TextButton")
	btnInteractive.Size = UDim2.new(1, -50, 1, 0)
	btnInteractive.BackgroundTransparency = 1
	btnInteractive.TextSize = 13
	btnInteractive.Text = btnName
	btnInteractive.TextTruncate = Enum.TextTruncate.AtEnd
	btnInteractive.Parent = el
	ctx.ApplyTheme(btnInteractive, "Text", "TextColor3")
	ctx.ApplyTheme(btnInteractive, "TextFont", "Font")

	local box = Instance.new("Frame")
	box.Size = UDim2.new(0, 30, 0, 24)
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.Position = UDim2.new(1, -7, 0.5, 0)
	box.ZIndex = 5
	box.Parent = el
	ctx.ApplyTheme(box, "Input", "BackgroundColor3")
	ctx.ApplyTheme(box, "InputTrans", "BackgroundTransparency")
	local boxC = Instance.new("UICorner")
	boxC.Parent = box
	ctx.RegisterCorner(boxC, "Element")
	ctx.AttachStroke(box, "Element", "Element")

	local bBtn = Instance.new("TextButton")
	bBtn.Size = UDim2.fromScale(1, 1)
	bBtn.BackgroundTransparency = 1
	bBtn.TextSize = 12
	bBtn.Text = getShortKey(bind)
	bBtn.ZIndex = 6
	bBtn.Parent = box
	ctx.ApplyTheme(bBtn, "TextMuted", "TextColor3")
	ctx.ApplyTheme(bBtn, "TextFont", "Font")

	local mobileToggle, getMobileBtn
	if isMobile then
		mobileToggle, _, getMobileBtn = ctx.CreateMobileToggle(el, function(enabled, removeBtn, saveBtn)
			if enabled then
				saveBtn(ctx.CreateMobileBindButton(getShortKey(bind), function() callback() end))
			else
				removeBtn()
			end
		end)
	end

	local function updateStyle(style)
		local edge = (style == 3 or style == 4) and 5 or 7
		local boxH
		if style == 3 or style == 4 then
			el.Size = UDim2.new(1, 0, 0, 30)
			btnInteractive.TextSize = 12
			bBtn.TextSize = 11
			boxH = 20
		else
			el.Size = UDim2.new(1, 0, 0, 38)
			btnInteractive.TextSize = 13
			bBtn.TextSize = 12
			boxH = 24
		end
		local boxW = syncKeyBoxWidth(box, bBtn, boxH)
		box.AnchorPoint = Vector2.new(1, 0.5)
		box.Position = UDim2.new(1, -edge, 0.5, 0)
		btnInteractive.Position = UDim2.new(0, mobileToggle and 36 or 0, 0, 0)
		btnInteractive.Size = UDim2.new(1, -(boxW + 18 + (mobileToggle and 36 or 0)), 1, 0)
		if mobileToggle then
			mobileToggle.AnchorPoint = Vector2.new(0, 0.5)
			mobileToggle.Position = UDim2.new(0, 12, 0.5, 0)
			mobileToggle.Size = UDim2.new(0, 20, 0, 20)
		end
	end
	table.insert(ctx.Window._styleCallbacks, updateStyle)
	updateStyle(ctx.THEME.ElementStyle)

	local hovering = false
	ctx.TrackConnection(btnInteractive.MouseEnter:Connect(function()
		hovering = true
		ctx.TweenTheme(el, "ElementHover", "BackgroundColor3", T_FAST)
	end))
	ctx.TrackConnection(btnInteractive.MouseLeave:Connect(function()
		hovering = false
		ctx.TweenTheme(el, "Element", "BackgroundColor3", T_FAST)
	end))
	ctx.TrackConnection(btnInteractive.MouseButton1Down:Connect(function()
		ctx.TweenTheme(el, "CardHover", "BackgroundColor3", T_FAST)
	end))
	ctx.TrackConnection(btnInteractive.MouseButton1Up:Connect(function()
		ctx.TweenTheme(el, hovering and "ElementHover" or "Element", "BackgroundColor3", T_FAST)
		callback()
	end))

	ctx.TrackConnection(bBtn.MouseButton1Click:Connect(function()
		bBtn.Text = "..."
		ctx.TweenTheme(bBtn, "Accent", "TextColor3", T_FAST)
		updateStyle(ctx.THEME.ElementStyle)
		ctx.ActiveKeyBinder = function(keyCode)
			bind = keyCode
			bBtn.Text = getShortKey(bind)
			ctx.TweenTheme(bBtn, "TextMuted", "TextColor3", T_FAST)
			updateStyle(ctx.THEME.ElementStyle)
			local mb = getMobileBtn and getMobileBtn()
			if mb then mb.Text = getShortKey(bind) end
		end
	end))

	ctx.RegisterKeyListener(function(keyCode)
		if bind and bind ~= Enum.KeyCode.Unknown and keyCode == bind then
			callback()
		end
	end)

	reg.RegisterElement(btnName, el)

	local api = {}
	function api:SetText(txt) btnInteractive.Text = txt end
	function api:SetKeybind(k)
		bind = k
		bBtn.Text = getShortKey(k)
		updateStyle(ctx.THEME.ElementStyle)
		local mb = getMobileBtn and getMobileBtn()
		if mb then mb.Text = getShortKey(k) end
	end
	function api:SetCallback(cb) callback = cb end
	function api:Save() return { Bind = bind and bind.Name or nil } end
	function api:Load(val)
		if val and val.Bind then api:SetKeybind(Enum.KeyCode[val.Bind]) end
	end
	reg.RegisterAPI("ButtonKeybind", btnName, api)
	return api
end

local function buildKeybindElement(ctx, reg, cfg, isSettings)
	local el = createElementBase(ctx, reg.Container, 38)
	local bind = cfg.Default

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -120, 1, 0)
	lbl.Position = UDim2.new(0, 15, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextSize = 13
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = cfg.Name
	lbl.Parent = el
	ctx.ApplyTheme(lbl, "Text", "TextColor3")
	ctx.ApplyTheme(lbl, "TextFont", "Font")

	local box = Instance.new("Frame")
	box.Size = UDim2.new(0, 30, 0, 24)
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.Position = UDim2.new(1, -7, 0.5, 0)
	box.Parent = el
	ctx.ApplyTheme(box, "Input", "BackgroundColor3")
	ctx.ApplyTheme(box, "InputTrans", "BackgroundTransparency")
	local boxC = Instance.new("UICorner")
	boxC.Parent = box
	ctx.RegisterCorner(boxC, "Element")
	ctx.AttachStroke(box, "Element", "Element")

	local bBtn = Instance.new("TextButton")
	bBtn.Size = UDim2.fromScale(1, 1)
	bBtn.BackgroundTransparency = 1
	bBtn.TextSize = 12
	bBtn.Text = getShortKey(bind)
	bBtn.Parent = box
	ctx.ApplyTheme(bBtn, "TextMuted", "TextColor3")
	ctx.ApplyTheme(bBtn, "TextFont", "Font")

	local mobileToggle, getMobileBtn
	if isMobile then
		mobileToggle, _, getMobileBtn = ctx.CreateMobileToggle(el, function(enabled, removeBtn, saveBtn)
			if enabled then
				saveBtn(ctx.CreateMobileBindButton(getShortKey(bind), function()
					if cfg.Callback then pcall(function() cfg.Callback(bind) end) end
				end))
			else
				removeBtn()
			end
		end)
	end

	local function updateStyle(style)
		local edge = (style == 3 or style == 4) and 5 or 7
		local boxH
		if style == 3 or style == 4 then
			el.Size = UDim2.new(1, 0, 0, 30)
			lbl.TextSize = 12
			bBtn.TextSize = 11
			boxH = 20
		else
			el.Size = UDim2.new(1, 0, 0, 38)
			lbl.TextSize = 13
			bBtn.TextSize = 12
			boxH = 24
		end
		local boxW = syncKeyBoxWidth(box, bBtn, boxH)
		box.AnchorPoint = Vector2.new(1, 0.5)
		box.Position = UDim2.new(1, -edge, 0.5, 0)
		lbl.Position = UDim2.new(0, mobileToggle and 38 or 15, 0, 0)
		lbl.Size = UDim2.new(1, -(boxW + 30 + (mobileToggle and 30 or 0)), 1, 0)
		if mobileToggle then
			mobileToggle.AnchorPoint = Vector2.new(0, 0.5)
			mobileToggle.Position = UDim2.new(0, 12, 0.5, 0)
			mobileToggle.Size = UDim2.new(0, 20, 0, 20)
		end
	end
	table.insert(ctx.Window._styleCallbacks, updateStyle)
	updateStyle(ctx.THEME.ElementStyle)

	ctx.TrackConnection(bBtn.MouseButton1Click:Connect(function()
		bBtn.Text = "..."
		ctx.TweenTheme(bBtn, "Accent", "TextColor3", T_FAST)
		updateStyle(ctx.THEME.ElementStyle)
		ctx.ActiveKeyBinder = function(keyCode)
			bind = keyCode
			bBtn.Text = getShortKey(bind)
			ctx.TweenTheme(bBtn, "TextMuted", "TextColor3", T_FAST)
			updateStyle(ctx.THEME.ElementStyle)
			local mb = getMobileBtn and getMobileBtn()
			if mb then mb.Text = getShortKey(bind) end
			if cfg.Callback then pcall(function() cfg.Callback(bind) end) end
			if ctx.Window.UpdateKeybinds then ctx.Window.UpdateKeybinds() end
		end
	end))

	if not (isSettings and cfg.Name == "Open GUI Keybind") then
		ctx.RegisterKeyListener(function(keyCode)
			if bind and bind ~= Enum.KeyCode.Unknown and keyCode == bind then
				if cfg.Callback then pcall(function() cfg.Callback(bind) end) end
			end
		end)
	end

	reg.RegisterElement(cfg.Name, el)

	local api = {}
	function api:SetKeybind(k)
		bind = k
		bBtn.Text = getShortKey(k)
		updateStyle(ctx.THEME.ElementStyle)
		local mb = getMobileBtn and getMobileBtn()
		if mb then mb.Text = getShortKey(bind) end
	end
	function api:Save() return { Bind = bind and bind.Name or nil } end
	function api:Load(val)
		if val and val.Bind then
			local resolved = resolveKeycode(val.Bind)
			if resolved then
				api:SetKeybind(resolved)
				if isSettings and cfg.Name == "Open GUI Keybind" then
					ctx.Window:SetOpenKeybind(resolved)
				end
			end
		end
	end
	reg.RegisterAPI("Keybind", cfg.Name, api)
	return api
end

local function buildColorpickerElement(ctx, reg, cpConfig)
	local cpName = cpConfig.Name or "Colorpicker"
	local defaultColor = cpConfig.Default or Color3.fromRGB(255, 255, 255)
	local callback = cpConfig.Callback or function() end
	local currentColor = defaultColor

	local container = createElementBase(ctx, reg.Container, 38)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.new(0, 15, 0, 0)
	label.BackgroundTransparency = 1
	label.TextSize = 13
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = cpName
	label.Parent = container
	ctx.ApplyTheme(label, "Text", "TextColor3")
	ctx.ApplyTheme(label, "TextFont", "Font")

	local previewBox = Instance.new("TextButton")
	previewBox.Size = UDim2.new(0, 24, 0, 24)
	previewBox.AnchorPoint = Vector2.new(1, 0.5)
	previewBox.Position = UDim2.new(1, -7, 0.5, 0)
	previewBox.BackgroundColor3 = defaultColor
	previewBox.BorderSizePixel = 0
	previewBox.Text = ""
	previewBox.Parent = container
	local pC = Instance.new("UICorner")
	pC.Parent = previewBox
	ctx.RegisterCorner(pC, "Element")
	local pStroke = Instance.new("UIStroke")
	pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pStroke.Thickness = 2
	pStroke.Parent = previewBox
	ctx.ApplyTheme(pStroke, "Outlines", "Color")

	local function updateStyle(style)
		if style == 3 or style == 4 then
			container.Size = UDim2.new(1, 0, 0, 30)
			label.TextSize = 12
			previewBox.Size = UDim2.new(0, 18, 0, 18)
			previewBox.Position = UDim2.new(1, -5, 0.5, 0)
		else
			container.Size = UDim2.new(1, 0, 0, 38)
			label.TextSize = 13
			previewBox.Size = UDim2.new(0, 24, 0, 24)
			previewBox.Position = UDim2.new(1, -7, 0.5, 0)
		end
	end
	table.insert(ctx.Window._styleCallbacks, updateStyle)
	updateStyle(ctx.THEME.ElementStyle)

	local innerAPI = attachColorPicker(ctx, previewBox, defaultColor, function(c)
		currentColor = c
		callback(c)
	end)
	reg.RegisterElement(cpName, container)

	local api = {}
	function api:SetColor(c)
		currentColor = c
		innerAPI:SetColor(c)
	end
	function api:Save() return { Color = { currentColor.R, currentColor.G, currentColor.B } } end
	function api:Load(val)
		if val and val.Color then api:SetColor(Color3.new(unpack(val.Color))) end
	end
	reg.RegisterAPI("Colorpicker", cpName, api)
	return api
end

local function buildPictureElement(ctx, reg, picConfig)
	local name = picConfig.Name or "Picture"
	local imgId = parseAsset(picConfig.Image)
	local sizePct = math.clamp(picConfig.Size or 100, 0, 100)
	local desc = picConfig.Description or ""

	local container = createElementBase(ctx, reg.Container, 60)

	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, 0, 0, 0)
	contentFrame.AutomaticSize = Enum.AutomaticSize.Y
	contentFrame.BackgroundTransparency = 1
	contentFrame.ZIndex = 2
	contentFrame.Parent = container

	local function syncPicH()
		if contentFrame.Parent then
			container.Size = UDim2.new(1, 0, 0, math.max(30, contentFrame.AbsoluteSize.Y))
		end
	end

	local pad = Instance.new("UIPadding")
	pad.PaddingTop, pad.PaddingBottom, pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12)
	pad.Parent = contentFrame

	local img = Instance.new("ImageLabel")
	img.BackgroundTransparency = 1
	img.Image = imgId
	img.ScaleType = Enum.ScaleType.Crop
	img.Parent = contentFrame
	local imgC = Instance.new("UICorner")
	imgC.Parent = img
	ctx.RegisterCorner(imgC, "Element")

	local rightTextLbl = Instance.new("TextLabel")
	rightTextLbl.BackgroundTransparency = 1
	rightTextLbl.TextWrapped = true
	rightTextLbl.TextXAlignment = Enum.TextXAlignment.Left
	rightTextLbl.TextYAlignment = Enum.TextYAlignment.Top
	rightTextLbl.TextSize = 13
	rightTextLbl.Parent = contentFrame
	ctx.ApplyTheme(rightTextLbl, "TextMuted", "TextColor3")
	ctx.ApplyTheme(rightTextLbl, "SubtextFont", "Font")

	local bottomTextLbl = Instance.new("TextLabel")
	bottomTextLbl.BackgroundTransparency = 1
	bottomTextLbl.TextWrapped = true
	bottomTextLbl.TextXAlignment = Enum.TextXAlignment.Left
	bottomTextLbl.TextYAlignment = Enum.TextYAlignment.Top
	bottomTextLbl.TextSize = 13
	bottomTextLbl.Parent = contentFrame
	ctx.ApplyTheme(bottomTextLbl, "TextMuted", "TextColor3")
	ctx.ApplyTheme(bottomTextLbl, "SubtextFont", "Font")

	local function updateLayout()
		if not contentFrame.Parent then return end
		local fullW = contentFrame.AbsoluteSize.X - 24
		if fullW <= 0 then return end
		local imgW = math.floor(fullW * (sizePct / 100))
		local imgH = imgW
		img.Size = UDim2.new(0, imgW, 0, imgH)
		local availRightW = fullW - imgW - 14

		if sizePct == 100 or sizePct == 0 or availRightW < 40 or desc == "" then
			rightTextLbl.Visible = false
			bottomTextLbl.Visible = (desc ~= "")
			img.Visible = (sizePct > 0)
			bottomTextLbl.Size = UDim2.new(1, 0, 0, 0)
			bottomTextLbl.Position = UDim2.new(0, 0, 0, sizePct > 0 and (imgH + 10) or 0)
			bottomTextLbl.Text = desc
			bottomTextLbl.AutomaticSize = Enum.AutomaticSize.Y
		else
			rightTextLbl.Visible = true
			img.Visible = true
			local len = string.len(desc)
			local l, r, splitIdx = 1, len, len
			while l <= r do
				local m = math.floor((l + r) / 2)
				local bounds = TextService:GetTextSize(string.sub(desc, 1, m), 13, Enum.Font.Gotham, Vector2.new(availRightW, 10000))
				if bounds.Y > imgH then r = m - 1 else splitIdx = m; l = m + 1 end
			end
			if splitIdx < len then
				local safeIdx = splitIdx
				while safeIdx > 0 and string.sub(desc, safeIdx, safeIdx):match("%S") do safeIdx = safeIdx - 1 end
				if safeIdx > 0 then splitIdx = safeIdx end
			end
			rightTextLbl.Position = UDim2.new(0, imgW + 14, 0, 0)
			rightTextLbl.Size = UDim2.new(0, availRightW, 0, imgH)
			rightTextLbl.Text = string.sub(desc, 1, splitIdx)
			rightTextLbl.AutomaticSize = Enum.AutomaticSize.None
			local bottomText = string.gsub(string.sub(desc, splitIdx + 1), "^%s+", "")
			if bottomText ~= "" then
				bottomTextLbl.Visible = true
				bottomTextLbl.Position = UDim2.new(0, 0, 0, imgH + 10)
				bottomTextLbl.Size = UDim2.new(1, 0, 0, 0)
				bottomTextLbl.Text = bottomText
				bottomTextLbl.AutomaticSize = Enum.AutomaticSize.Y
			else
				bottomTextLbl.Visible = false
			end
		end
		syncPicH()
	end

	ctx.TrackConnection(contentFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		updateLayout()
		syncPicH()
	end))
	task.defer(updateLayout)
	reg.RegisterElement(name, container)

	local api = {}
	function api:SetImage(id) img.Image = parseAsset(id) end
	function api:SetSize(pct) sizePct = math.clamp(pct, 0, 100); updateLayout() end
	function api:SetDescription(txt) desc = txt; updateLayout() end
	return api
end

local function buildObjectElement(ctx, reg, objConfig)
	local name = objConfig.Name or "Object Preview"
	local rawObj = objConfig.Object
	local sizePct = math.clamp(objConfig.Size or 100, 0, 100)
	local desc = objConfig.Description or ""

	local container = createElementBase(ctx, reg.Container, 60)

	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, 0, 0, 0)
	contentFrame.AutomaticSize = Enum.AutomaticSize.Y
	contentFrame.BackgroundTransparency = 1
	contentFrame.ZIndex = 2
	contentFrame.Parent = container

	local function syncObjH()
		if contentFrame.Parent then
			container.Size = UDim2.new(1, 0, 0, math.max(30, contentFrame.AbsoluteSize.Y))
		end
	end

	local pad = Instance.new("UIPadding")
	pad.PaddingTop, pad.PaddingBottom, pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12)
	pad.Parent = contentFrame

	local viewport = Instance.new("ViewportFrame")
	viewport.BackgroundTransparency = 1
	viewport.BorderSizePixel = 0
	viewport.ClipsDescendants = true
	viewport.Ambient = Color3.fromRGB(220, 220, 220)
	viewport.LightColor = Color3.fromRGB(255, 255, 255)
	viewport.LightDirection = Vector3.new(-1, -2, -1)
	viewport.Parent = contentFrame

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport

	local camera = Instance.new("Camera")
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = 50
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	local rightTextLbl = Instance.new("TextLabel")
	rightTextLbl.BackgroundTransparency = 1
	rightTextLbl.TextWrapped = true
	rightTextLbl.TextXAlignment = Enum.TextXAlignment.Left
	rightTextLbl.TextYAlignment = Enum.TextYAlignment.Top
	rightTextLbl.TextSize = 13
	rightTextLbl.Parent = contentFrame
	ctx.ApplyTheme(rightTextLbl, "TextMuted", "TextColor3")
	ctx.ApplyTheme(rightTextLbl, "SubtextFont", "Font")

	local bottomTextLbl = Instance.new("TextLabel")
	bottomTextLbl.BackgroundTransparency = 1
	bottomTextLbl.TextWrapped = true
	bottomTextLbl.TextXAlignment = Enum.TextXAlignment.Left
	bottomTextLbl.TextYAlignment = Enum.TextYAlignment.Top
	bottomTextLbl.TextSize = 13
	bottomTextLbl.Parent = contentFrame
	ctx.ApplyTheme(bottomTextLbl, "TextMuted", "TextColor3")
	ctx.ApplyTheme(bottomTextLbl, "SubtextFont", "Font")

	local function resolveInstance(input)
		if typeof(input) == "Instance" then
			if input:IsA("Player") then return input.Character or input.CharacterAdded:Wait() end
			return input
		elseif type(input) == "string" then
			local clean = input:match("^%s*['\"]?(.-)['\"]?%s*$") or input
			local lower = string.lower(clean)
			if lower == "character" or lower == "localplayer" or lower == "me" or lower == "player"
				or lower == "game.players.localplayer" or lower == "game.players.localplayer.character"
				or lower == "players.localplayer" or lower == "players.localplayer.character" then
				return LP.Character or LP.CharacterAdded:Wait()
			end
			if workspace:FindFirstChild(clean) then return workspace:FindFirstChild(clean) end
			if Players:FindFirstChild(clean) then
				local p = Players:FindFirstChild(clean)
				return p.Character or p.CharacterAdded:Wait()
			end
			local current = game
			for seg in string.gmatch(clean, "[^%.]+") do
				local segLower = string.lower(seg)
				if segLower == "game" then current = game
				elseif segLower == "workspace" then current = workspace
				elseif segLower == "players" then current = Players
				elseif segLower == "localplayer" and current == Players then current = LP.Character or LP.CharacterAdded:Wait()
				elseif segLower == "character" and current:IsA("Player") then current = current.Character or current.CharacterAdded:Wait()
				else current = current and current:FindFirstChild(seg) end
			end
			if current and current ~= game then
				if current:IsA("Player") then return current.Character or current.CharacterAdded:Wait() end
				return current
			end
			if input == LP.Name and LP.Character then return LP.Character end
		end
		return nil
	end

	local currentClone, currentCenter, currentDistance, rotX, rotY, renderConn = nil, Vector3.new(0, 1.5, 0), 7.5, 0, math.pi, nil
	local function updateCamera()
		local rotCFrame = CFrame.Angles(0, rotY, 0) * CFrame.Angles(rotX, 0, 0)
		camera.CFrame = CFrame.lookAt(currentCenter + (rotCFrame * Vector3.new(0, 0, currentDistance)), currentCenter)
	end

	local function loadTargetObject(target)
		if renderConn then renderConn:Disconnect(); renderConn = nil end
		if currentClone then currentClone:Destroy(); currentClone = nil end

		local src = resolveInstance(target)
		if not src and (target == nil or target == "Character") then
			src = LP.Character or LP.CharacterAdded:Wait()
		end
		if not src then return end

		local isChar = (src == LP.Character or src:FindFirstChildOfClass("Humanoid") ~= nil)
		if isChar and src == LP.Character then
			local t = 0
			while not LP:HasAppearanceLoaded() and t < 2 do task.wait(0.1); t = t + 0.1 end
		end

		local archCache = { [src] = src.Archivable }
		src.Archivable = true
		for _, d in ipairs(src:GetDescendants()) do
			archCache[d] = d.Archivable
			pcall(function() d.Archivable = true end)
		end
		local clone = src:Clone()
		for obj, arch in pairs(archCache) do
			if obj and obj.Parent then pcall(function() obj.Archivable = arch end) end
		end
		if not clone then return end

		if not clone:IsA("Model") and not clone:IsA("BasePart") then
			local wrap = Instance.new("Model")
			wrap.Name = clone.Name
			for _, child in ipairs(clone:GetChildren()) do child.Parent = wrap end
			clone:Destroy()
			clone = wrap
		end

		if isChar then
			for _, child in ipairs(clone:GetChildren()) do
				if child:IsA("Tool") or child:IsA("Folder") or child:IsA("Model") then child:Destroy()
				elseif child:IsA("BasePart") and not VALID_CHAR_PARTS[child.Name] then child:Destroy() end
			end
			for _, desc in ipairs(clone:GetDescendants()) do
				if desc:IsA("BasePart") and not VALID_CHAR_PARTS[desc.Name] and not desc:FindFirstAncestorOfClass("Accessory") then
					desc:Destroy()
				elseif desc:IsA("BillboardGui") or desc:IsA("SurfaceGui") or desc:IsA("Highlight") or desc:IsA("ParticleEmitter") or desc:IsA("Sound") or desc:IsA("LuaSourceContainer") then
					desc:Destroy()
				end
			end
		else
			for _, desc in ipairs(clone:GetDescendants()) do
				if desc:IsA("LuaSourceContainer") or desc:IsA("Sound") then desc:Destroy() end
			end
		end

		local motorMap = {}
		if isChar then
			for _, cd in ipairs(clone:GetDescendants()) do
				if cd:IsA("Motor6D") then
					local rd = src:FindFirstChild(cd.Name, true)
					if rd and rd:IsA("Motor6D") then table.insert(motorMap, { Real = rd, Clone = cd }) end
				end
			end
		end

		for _, d in ipairs(clone:GetDescendants()) do
			if d:IsA("BasePart") then
				d.CanCollide = false
				if isChar then
					d.Anchored = (d.Name == "HumanoidRootPart")
					if d.Name == "HumanoidRootPart" then d.Transparency = 1
					else
						d.LocalTransparencyModifier = 0
						if (VALID_CHAR_PARTS[d.Name] or d:IsA("MeshPart") or d:FindFirstChildWhichIsA("DataModelMesh")) and d.Transparency >= 1 then
							d.Transparency = 0
						end
					end
				else
					d.Anchored = true
				end
			end
		end

		local hum = clone:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		end

		clone.Parent = worldModel
		currentClone = clone
		local srcRoot = src:FindFirstChild("HumanoidRootPart") or (src:IsA("Model") and src.PrimaryPart) or src:FindFirstChildWhichIsA("BasePart") or (src:IsA("BasePart") and src)
		local cloneRoot = clone:FindFirstChild("HumanoidRootPart") or (clone:IsA("Model") and clone.PrimaryPart) or clone:FindFirstChildWhichIsA("BasePart") or (clone:IsA("BasePart") and clone)

		local cf, size
		if isChar then
			if cloneRoot then cloneRoot.CFrame = CFrame.new(0, 0, 0) end
			for _, pair in ipairs(motorMap) do
				pair.Clone.Transform, pair.Clone.C0, pair.Clone.C1 = pair.Real.Transform, pair.Real.C0, pair.Real.C1
			end
			cf, size = clone:GetBoundingBox()
			currentCenter = cf.Position
		elseif clone:IsA("Model") then
			clone.PrimaryPart = nil
			local tempCF = clone:GetBoundingBox()
			clone:PivotTo(clone:GetPivot() + (-tempCF.Position))
			cf, size = clone:GetBoundingBox()
			currentCenter = cf.Position
		else
			clone.CFrame = CFrame.new(0, 0, 0)
			size = clone.Size
			currentCenter = Vector3.new(0, 0, 0)
		end

		local maxDim = math.max(size.X, size.Y, size.Z, 0.1)
		currentDistance = (maxDim / 2) / math.tan(math.rad(camera.FieldOfView / 2)) * 1.45
		rotX, rotY = 0, math.pi
		updateCamera()

		local ownerPage = nil
		renderConn = RS.RenderStepped:Connect(function()
			if not viewport.Parent then
				if renderConn then renderConn:Disconnect(); renderConn = nil end
				return
			end
			if not ctx.IsUIOpen or not viewport.Visible or viewport.AbsoluteSize.X <= 0 then return end
			if not ownerPage then
				local p = viewport.Parent
				while p and p ~= ctx.main do
					if p.Name:sub(1, 5) == "Page_" or p.Name == "SearchPage" then ownerPage = p; break end
					p = p.Parent
				end
			end
			if ownerPage and ownerPage.Parent and not ownerPage.Visible then return end
			if not src or not src.Parent then return end

			if isChar then
				if cloneRoot then cloneRoot.CFrame = CFrame.new(0, 0, 0) end
				for _, pair in ipairs(motorMap) do
					pair.Clone.Transform, pair.Clone.C0, pair.Clone.C1 = pair.Real.Transform, pair.Real.C0, pair.Real.C1
				end
			elseif srcRoot and srcRoot.Parent then
				local rot = srcRoot.CFrame - srcRoot.CFrame.Position
				if clone:IsA("Model") then clone:PivotTo(CFrame.new(currentCenter) * rot)
				elseif clone:IsA("BasePart") then clone.CFrame = CFrame.new(currentCenter) * rot end
			end
			updateCamera()
		end)
		ctx.TrackConnection(renderConn)
	end

	task.spawn(function()
		task.wait(0.2)
		loadTargetObject(rawObj)
	end)

	ctx.TrackConnection(LP.CharacterAdded:Connect(function(newChar)
		if rawObj == nil or rawObj == "Character" or rawObj == LP.Character or (type(rawObj) == "string" and string.find(string.lower(rawObj), "character")) then
			task.wait(0.5)
			loadTargetObject(newChar)
		end
	end))

	ctx.TrackConnection(viewport.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			local lastPos = Vector2.new(input.Position.X, input.Position.Y)
			ctx.StartDrag(Enum.UserInputType.MouseButton2, function(moveInput)
				local curPos = Vector2.new(moveInput.Position.X, moveInput.Position.Y)
				local delta = curPos - lastPos
				lastPos = curPos
				rotY = rotY - (delta.X * 0.015)
				rotX = math.clamp(rotX - (delta.Y * 0.015), -math.rad(80), math.rad(80))
			end)
		end
	end))

	local function updateLayout()
		if not contentFrame.Parent then return end
		local fullW = contentFrame.AbsoluteSize.X - 24
		if fullW <= 0 then return end
		local vpW = math.floor(fullW * (sizePct / 100))
		local vpH = vpW
		viewport.Size = UDim2.new(0, vpW, 0, vpH)
		local availRightW = fullW - vpW - 14

		if sizePct == 100 or sizePct == 0 or availRightW < 40 or desc == "" then
			rightTextLbl.Visible = false
			bottomTextLbl.Visible = (desc ~= "")
			viewport.Visible = (sizePct > 0)
			bottomTextLbl.Size = UDim2.new(1, 0, 0, 0)
			bottomTextLbl.Position = UDim2.new(0, 0, 0, sizePct > 0 and (vpH + 10) or 0)
			bottomTextLbl.Text = desc
			bottomTextLbl.AutomaticSize = Enum.AutomaticSize.Y
		else
			rightTextLbl.Visible = true
			viewport.Visible = true
			local len = string.len(desc)
			local l, r, splitIdx = 1, len, len
			while l <= r do
				local m = math.floor((l + r) / 2)
				local bounds = TextService:GetTextSize(string.sub(desc, 1, m), 13, Enum.Font.Gotham, Vector2.new(availRightW, 10000))
				if bounds.Y > vpH then r = m - 1 else splitIdx = m; l = m + 1 end
			end
			if splitIdx < len then
				local safeIdx = splitIdx
				while safeIdx > 0 and string.sub(desc, safeIdx, safeIdx):match("%S") do safeIdx = safeIdx - 1 end
				if safeIdx > 0 then splitIdx = safeIdx end
			end
			rightTextLbl.Position = UDim2.new(0, vpW + 14, 0, 0)
			rightTextLbl.Size = UDim2.new(0, availRightW, 0, vpH)
			rightTextLbl.Text = string.sub(desc, 1, splitIdx)
			rightTextLbl.AutomaticSize = Enum.AutomaticSize.None
			local bottomText = string.gsub(string.sub(desc, splitIdx + 1), "^%s+", "")
			if bottomText ~= "" then
				bottomTextLbl.Visible = true
				bottomTextLbl.Position = UDim2.new(0, 0, 0, vpH + 10)
				bottomTextLbl.Size = UDim2.new(1, 0, 0, 0)
				bottomTextLbl.Text = bottomText
				bottomTextLbl.AutomaticSize = Enum.AutomaticSize.Y
			else
				bottomTextLbl.Visible = false
			end
		end
		syncObjH()
	end

	ctx.TrackConnection(contentFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		updateLayout()
		syncObjH()
	end))
	task.defer(updateLayout)
	reg.RegisterElement(name, container)

	local api = {}
	function api:SetObject(newObj) rawObj = newObj; loadTargetObject(newObj) end
	function api:SetSize(pct) sizePct = math.clamp(pct, 0, 100); updateLayout() end
	function api:SetDescription(txt) desc = txt; updateLayout() end
	function api:ResetRotation() rotX = 0; rotY = math.pi end
	return api
end

local function buildLabelElement(ctx, reg, text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 0)
	lbl.AutomaticSize = Enum.AutomaticSize.Y
	lbl.BackgroundTransparency = 1
	lbl.TextSize = 13
	lbl.Text = text
	lbl.TextWrapped = true
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.LayoutOrder = 2
	lbl.Parent = reg.Container
	ctx.ApplyTheme(lbl, "TextMuted", "TextColor3")
	ctx.ApplyTheme(lbl, "SubtextFont", "Font")

	local function updateStyle(style)
		lbl.TextSize = (style == 3 or style == 4) and 12 or 13
	end
	table.insert(ctx.Window._styleCallbacks, updateStyle)
	updateStyle(ctx.THEME.ElementStyle)
	reg.RegisterElement(text, lbl)

	local api = {}
	function api:SetText(txt) lbl.Text = txt end
	return api
end

local function buildSectionElement(ctx, reg, text)
	local hasText = type(text) == "string" and text ~= ""
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 24)
	container.BackgroundTransparency = 1
	container.ClipsDescendants = true
	container.LayoutOrder = 2
	container.Parent = reg.Container

	local function updateStyle(style)
		container.Size = UDim2.new(1, 0, 0, (style == 3 or style == 4) and 16 or 24)
	end
	table.insert(ctx.Window._styleCallbacks, updateStyle)
	updateStyle(ctx.THEME.ElementStyle)

	local label, leftLine, rightLine
	local function updateLines()
		if not label or not container.Parent then return end
		local totalW = container.AbsoluteSize.X
		if totalW <= 0 then return end
		local textWidth = label.AbsoluteSize.X
		local lineW = math.max(0, (totalW / 2) - (textWidth / 2) - 12)
		if leftLine then
			leftLine.Size = UDim2.new(0, lineW, 0, 1)
			leftLine.Position = UDim2.new(0.5, -((textWidth / 2) + 8), 0.5, 0)
		end
		if rightLine then
			rightLine.Size = UDim2.new(0, lineW, 0, 1)
			rightLine.Position = UDim2.new(0.5, ((textWidth / 2) + 8), 0.5, 0)
		end
	end

	if not hasText then
		local line = Instance.new("Frame")
		line.Size = UDim2.new(1, -8, 0, 1)
		line.Position = UDim2.fromScale(0.5, 0.5)
		line.AnchorPoint = Vector2.new(0.5, 0.5)
		line.BorderSizePixel = 0
		line.Parent = container
		ctx.ApplyTheme(line, "Outlines", "BackgroundColor3")
	else
		label = Instance.new("TextLabel")
		label.AutomaticSize = Enum.AutomaticSize.X
		label.Size = UDim2.new(0, 0, 1, 0)
		label.Position = UDim2.fromScale(0.5, 0.5)
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.BackgroundTransparency = 1
		label.TextSize = 11
		label.Text = text
		label.ZIndex = 2
		label.Parent = container
		ctx.ApplyTheme(label, "TextMuted", "TextColor3")
		ctx.ApplyTheme(label, "SubtextFont", "Font")

		leftLine = Instance.new("Frame")
		leftLine.AnchorPoint = Vector2.new(1, 0.5)
		leftLine.BorderSizePixel = 0
		leftLine.Parent = container
		ctx.ApplyTheme(leftLine, "Outlines", "BackgroundColor3")

		rightLine = Instance.new("Frame")
		rightLine.AnchorPoint = Vector2.new(0, 0.5)
		rightLine.BorderSizePixel = 0
		rightLine.Parent = container
		ctx.ApplyTheme(rightLine, "Outlines", "BackgroundColor3")

		ctx.TrackConnection(label:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLines))
		ctx.TrackConnection(container:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLines))
		task.defer(updateLines)
	end
	reg.RegisterElement(text or "Section", container)

	local api = {}
	function api:SetText(txt)
		if label then label.Text = txt; task.defer(updateLines) end
	end
	return api
end

local function buildElementAPI(ctx, blockContainer, bName, bIcon, bSide, tabName, isSettings)
	local BlockObj = {}
	local elementCount = 2

	local reg = {
		Container = blockContainer,
		RegisterAPI = function(elType, elName, api)
			if not bName or not tabName or not elName then return end
			local uniqueId = tabName .. "~" .. bName .. "~" .. elName
			if isSettings then
				ctx.Window._themeElements[uniqueId] = { Type = elType, API = api }
				ctx.Window._themeControls[bName .. "~" .. elName] = { Type = elType, API = api }
			else
				ctx.Window._configElements[uniqueId] = { Type = elType, API = api }
			end
		end,
		RegisterElement = function(name, container)
			elementCount = elementCount + 1
			container.LayoutOrder = elementCount
			if bName and bSide and not isSettings then
				table.insert(ctx.Window._searchRegistry, {
					Name = string.lower(tostring(name)),
					UI = container,
					OriginalParent = blockContainer,
					BlockName = bName,
					BlockIcon = bIcon,
					BlockSide = bSide
				})
			end
		end
	}

	function BlockObj:CreatePicture(c) return buildPictureElement(ctx, reg, c) end
	function BlockObj:CreateObject(c) return buildObjectElement(ctx, reg, c) end
	function BlockObj:CreateButton(c) return buildButtonElement(ctx, reg, c) end
	function BlockObj:CreateButtonKeybind(c) return buildButtonKeybindElement(ctx, reg, c) end
	function BlockObj:CreateToggle(c) return buildToggleElement(ctx, reg, c) end
	function BlockObj:CreateInput(c) return buildInputElement(ctx, reg, c) end
	function BlockObj:CreateDropdown(c) return buildDropdownElement(ctx, reg, c) end
	function BlockObj:CreateSlider(c) return buildSliderElement(ctx, reg, c) end
	function BlockObj:CreateRangeSlider(c) return buildRangeSliderElement(ctx, reg, c) end
	function BlockObj:CreateColorpicker(c) return buildColorpickerElement(ctx, reg, c) end
	function BlockObj:CreateLabel(t) return buildLabelElement(ctx, reg, t) end
	function BlockObj:CreateSection(t) return buildSectionElement(ctx, reg, t) end
	function BlockObj:CreateKeybind(c) return buildKeybindElement(ctx, reg, c, isSettings) end

	return BlockObj
end

local function populateSettingsTab(ctx)
	local Window = ctx.Window
	local THEME = ctx.THEME
	local settingsTab = Window.SettingsTab

	local MainSettingsBlock = settingsTab:CreateBlock({ Name = "UI Configuration", Side = "Left" })
	local editToggle = MainSettingsBlock:CreateToggle({
		Name = "GUI Edit",
		Default = false,
		Callback = function(state)
			Window.ToggleEditMode(state)
		end
	})
	ctx.EditToggleAPI = editToggle
	MainSettingsBlock:CreateLabel("Enable GUI Edit to visually customize the menu with a blurred backdrop. Drag the editor header or Snap it near the GUI.")

	local ThemeSaveBlock = settingsTab:CreateBlock({ Name = "Theme Management", Side = "Left" })
	safeMakeFolder(Window.ThemeFolder)

	local function getThemes()
		local list = {}
		safeMakeFolder(Window.ThemeFolder)
		for _, file in pairs(safeListFiles(Window.ThemeFolder)) do
			local clean = tostring(file):gsub("[%z\r\n%s]+$", "")
			if clean:lower():match("%.json$") then
				local name = clean:match("([^/\\]+)%.[jJ][sS][oO][nN]$")
				if name and name ~= "" then table.insert(list, name) end
			end
		end
		return list
	end

	local themeAutoLoadPath = Window.ThemeFolder .. "/autoload_theme.txt"
	local currentThemeAutoLoad = safeReadFile(themeAutoLoadPath)
	currentThemeAutoLoad = currentThemeAutoLoad and currentThemeAutoLoad:match("^%s*(.-)%s*$") or ""

	local themeNameInput = ThemeSaveBlock:CreateInput({ Name = "Theme Name", Placeholder = "Enter theme name..." })
	local themeDropdown = ThemeSaveBlock:CreateDropdown({
		Name = "Select Theme",
		Options = getThemes(),
		Default = (currentThemeAutoLoad ~= "" and currentThemeAutoLoad or nil)
	})

	ThemeSaveBlock:CreateButton({
		Name = "Load Theme",
		Callback = function()
			local tName = themeDropdown:Save().Selected
			if tName and tName ~= "" then
				local raw = safeReadFile(Window.ThemeFolder .. "/" .. tName .. ".json")
				if raw and raw ~= "" then
					local ok, res = pcall(function() return HttpService:JSONDecode(raw) end)
					if ok and type(res) == "table" then
						for id, val in pairs(res) do
							if id == "SidebarWidth" then ctx.UpdateSidebarWidth(val)
							elseif Window._themeElements[id] then Window._themeElements[id].API:Load(val) end
						end
						Window:Notify({ Title = "Theme System", Description = "Loaded theme: " .. tName, Duration = 3, Icon = SETTINGS_ICON_ID })
					end
				end
			end
		end
	})

	ThemeSaveBlock:CreateButton({
		Name = "Save Theme",
		Callback = function()
			local tName = themeNameInput:Save().Text
			if not tName or tName == "" then tName = themeDropdown:Save().Selected end
			if tName and tName ~= "" then
				local data = {}
				for id, el in pairs(Window._themeElements) do
					if not string.find(id, "~Configuration~") and not string.find(id, "~Theme Management~") and not string.find(id, "~UI Configuration~") then
						local sd = el.API:Save()
						if sd then data[id] = sd end
					end
				end
				data["SidebarWidth"] = ctx.CurrentSidebarWidth
				safeMakeFolder(Window.ThemeFolder)
				safeWriteFile(Window.ThemeFolder .. "/" .. tName .. ".json", HttpService:JSONEncode(data))
				themeDropdown:SetOptions(getThemes())
				themeDropdown:Set(tName)
				Window:Notify({ Title = "Theme System", Description = "Saved theme: " .. tName, Duration = 3, Icon = SETTINGS_ICON_ID })
			else
				Window:Notify({ Title = "Theme Error", Description = "Enter a theme name first.", Duration = 3 })
			end
		end
	})

	ThemeSaveBlock:CreateButton({
		Name = "Refresh List",
		Callback = function()
			themeDropdown:SetOptions(getThemes())
			Window:Notify({ Title = "Theme System", Description = "Theme list refreshed.", Duration = 2 })
		end
	})

	ThemeSaveBlock:CreateButton({
		Name = "Delete Theme",
		Callback = function()
			local tName = themeDropdown:Save().Selected
			if tName and tName ~= "" then
				safeDelFile(Window.ThemeFolder .. "/" .. tName .. ".json")
				themeDropdown:SetOptions(getThemes())
				themeDropdown:Set(nil)
				Window:Notify({ Title = "Theme System", Description = "Deleted theme: " .. tName, Duration = 3, Icon = SETTINGS_ICON_ID })
			end
		end
	})

	local initTAuto = true
	ThemeSaveBlock:CreateToggle({
		Name = "Auto-Load Selected Theme",
		Default = (currentThemeAutoLoad ~= ""),
		Callback = function(state)
			if initTAuto then return end
			if state then
				local tName = themeDropdown:Save().Selected
				if tName and tName ~= "" then safeWriteFile(themeAutoLoadPath, tName)
				else Window:Notify({ Title = "Error", Description = "Please select a theme first to auto-load.", Duration = 3 }) end
			else
				safeDelFile(themeAutoLoadPath)
			end
		end
	})
	initTAuto = false

	local function createEditorBlock(name, sideName)
		local blockContainer = Instance.new("Frame")
		blockContainer.Size = UDim2.new(1, 0, 0, 40)
		blockContainer.Parent = (sideName == "Right") and ctx.ThemeEditorRight or ctx.ThemeEditorLeft
		ctx.ApplyTheme(blockContainer, "Card", "BackgroundColor3")
		ctx.ApplyTheme(blockContainer, "CardTrans", "BackgroundTransparency")

		local corner = Instance.new("UICorner")
		corner.Parent = blockContainer
		ctx.RegisterCorner(corner, "Element")
		ctx.AttachStroke(blockContainer, "Block", "Element")

		local blockInner = Instance.new("Frame")
		blockInner.Size = UDim2.new(1, 0, 0, 0)
		blockInner.AutomaticSize = Enum.AutomaticSize.Y
		blockInner.BackgroundTransparency = 1
		blockInner.ZIndex = 2
		blockInner.Parent = blockContainer

		local function syncEditorBlock()
			if blockContainer.Parent then
				blockContainer.Size = UDim2.new(1, 0, 0, math.max(30, blockInner.AbsoluteSize.Y))
			end
		end
		ctx.TrackConnection(blockInner:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncEditorBlock))
		task.defer(syncEditorBlock)

		local blockPadding = Instance.new("UIPadding")
		blockPadding.PaddingTop, blockPadding.PaddingBottom, blockPadding.PaddingLeft, blockPadding.PaddingRight = UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12)
		blockPadding.Parent = blockInner

		local blockLayout = Instance.new("UIListLayout")
		blockLayout.FillDirection = Enum.FillDirection.Vertical
		blockLayout.SortOrder = Enum.SortOrder.LayoutOrder
		blockLayout.Padding = UDim.new(0, 6)
		blockLayout.Parent = blockInner

		local titleLbl = Instance.new("TextLabel")
		titleLbl.Size = UDim2.new(1, 0, 0, 20)
		titleLbl.BackgroundTransparency = 1
		titleLbl.TextSize = 13
		titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.Text = name
		titleLbl.Parent = blockInner
		ctx.ApplyTheme(titleLbl, "Text", "TextColor3")
		ctx.ApplyTheme(titleLbl, "TextFont", "Font")

		local div = Instance.new("Frame")
		div.Size = UDim2.new(1, 0, 0, 1)
		div.BorderSizePixel = 0
		div.Parent = blockInner
		ctx.ApplyTheme(div, "Outlines", "BackgroundColor3")

		local function updateStyle(style)
			if style == 3 or style == 4 then
				blockPadding.PaddingTop, blockPadding.PaddingBottom = UDim.new(0, 8), UDim.new(0, 8)
				blockPadding.PaddingLeft, blockPadding.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
				blockLayout.Padding = UDim.new(0, 4)
				titleLbl.Size = UDim2.new(1, 0, 0, 16)
			else
				blockPadding.PaddingTop, blockPadding.PaddingBottom = UDim.new(0, 12), UDim.new(0, 12)
				blockPadding.PaddingLeft, blockPadding.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
				blockLayout.Padding = UDim.new(0, 6)
				titleLbl.Size = UDim2.new(1, 0, 0, 20)
			end
		end
		table.insert(Window._styleCallbacks, updateStyle)
		updateStyle(THEME.ElementStyle)

		return buildElementAPI(ctx, blockInner, name, "", sideName, "SettingsTab", true)
	end

	local colorsBlock = createEditorBlock("Colors", "Left")
	colorsBlock:CreateColorpicker({ Name = "Accent Color", Default = THEME.Accent, Callback = function(c) ctx.UpdateTheme("Accent", c) end })
	colorsBlock:CreateColorpicker({ Name = "Background", Default = THEME.Background, Callback = function(c) ctx.UpdateTheme("Background", c) end })
	colorsBlock:CreateColorpicker({ Name = "Sidebar", Default = THEME.Sidebar, Callback = function(c) ctx.UpdateTheme("Sidebar", c) end })
	colorsBlock:CreateColorpicker({ Name = "Cards & Panels", Default = THEME.Card, Callback = function(c) ctx.UpdateTheme("Card", c) end })
	colorsBlock:CreateColorpicker({ Name = "Elements", Default = THEME.Element, Callback = function(c) ctx.UpdateTheme("Element", c) end })
	colorsBlock:CreateColorpicker({ Name = "Inputs & Highlights", Default = THEME.Input, Callback = function(c) ctx.UpdateTheme("Input", c) end })
	colorsBlock:CreateColorpicker({ Name = "Outlines & Borders", Default = THEME.Outlines, Callback = function(c) ctx.UpdateTheme("Outlines", c) end })
	colorsBlock:CreateColorpicker({ Name = "Main Text", Default = THEME.Text, Callback = function(c) ctx.UpdateTheme("Text", c) end })
	colorsBlock:CreateColorpicker({ Name = "Subtext", Default = THEME.TextMuted, Callback = function(c) ctx.UpdateTheme("TextMuted", c) end })

	local transBlock = createEditorBlock("Transparency", "Left")
	transBlock:CreateSlider({ Name = "Background", Min = 0, Max = 100, Step = 1, Default = math.round(THEME.BackgroundTrans * 100), Callback = function(v) ctx.UpdateTheme("BackgroundTrans", v / 100) end })
	transBlock:CreateSlider({ Name = "Bg Image", Min = 0, Max = 100, Step = 1, Default = math.round(THEME.BgImageTrans * 100), Callback = function(v) ctx.UpdateTheme("BgImageTrans", v / 100) end })
	transBlock:CreateSlider({ Name = "Cards & Panels", Min = 0, Max = 100, Step = 1, Default = math.round(THEME.CardTrans * 100), Callback = function(v) ctx.UpdateTheme("CardTrans", v / 100) end })
	transBlock:CreateSlider({ Name = "Elements", Min = 0, Max = 100, Step = 1, Default = math.round(THEME.ElementTrans * 100), Callback = function(v) ctx.UpdateTheme("ElementTrans", v / 100) end })
	transBlock:CreateSlider({ Name = "Inputs", Min = 0, Max = 100, Step = 1, Default = math.round(THEME.InputTrans * 100), Callback = function(v) ctx.UpdateTheme("InputTrans", v / 100) end })
	transBlock:CreateSlider({ Name = "HUD", Min = 0, Max = 100, Step = 1, Default = math.round(THEME.HUDTransparency * 100), Callback = function(v) ctx.UpdateTheme("HUDTransparency", v / 100) end })

	local miscBlock = createEditorBlock("Fonts & Extras", "Left")
	miscBlock:CreateInput({ Name = "Bg Image ID", Placeholder = "rbxassetid://...", Default = THEME.BackgroundImage or "", Callback = function(t) ctx.UpdateTheme("BackgroundImage", t) end })
	miscBlock:CreateDropdown({ Name = "Primary Font", Options = FontsList, Default = THEME.TextFont, Callback = function(v) ctx.UpdateTheme("TextFont", v) end })
	miscBlock:CreateDropdown({ Name = "Subtext Font", Options = FontsList, Default = THEME.SubtextFont, Callback = function(v) ctx.UpdateTheme("SubtextFont", v) end })

	local layoutBlock = createEditorBlock("Layout & Styles", "Right")
	layoutBlock:CreateSlider({
		Name = "Sidebar Width",
		Min = ctx.MIN_SIDEBAR_WIDTH,
		Max = ctx.MAX_SIDEBAR_WIDTH,
		Step = 1,
		Default = math.clamp(ctx.CurrentSidebarWidth, ctx.MIN_SIDEBAR_WIDTH, ctx.MAX_SIDEBAR_WIDTH),
		Callback = function(width) ctx.UpdateSidebarWidth(width) end
	})
	layoutBlock:CreateKeybind({
		Name = "Open GUI Keybind",
		Default = ctx.OpenKeybind,
		Callback = function(key) Window:SetOpenKeybind(key) end
	})
	layoutBlock:CreateToggle({
		Name = "Main GUI Outline",
		Default = THEME.MainOutlineEnabled,
		Callback = function(s) ctx.UpdateMainOutline(s) end
	})
	layoutBlock:CreateToggle({
		Name = "Double Outline",
		Default = THEME.DoubleOutline,
		Callback = function(s) ctx.UpdateDoubleOutlineMode(s) end
	})
	layoutBlock:CreateDropdown({
		Name = "Internal Outlines",
		Options = { "Off", "Only Blocks", "Only Elements", "All" },
		Default = THEME.InternalOutlines,
		Callback = function(opt) ctx.UpdateInternalOutlines(opt) end
	})
	layoutBlock:CreateDropdown({
		Name = "GUI Style",
		Options = { "Style 1", "Style 2", "Style 3", "Style 4" },
		Default = "Style " .. tostring(THEME.ElementStyle or 1),
		Callback = function(opt)
			THEME.ElementStyle = tonumber(opt:match("%d+")) or 1
			for _, cb in ipairs(Window._styleCallbacks) do cb(THEME.ElementStyle) end
			ctx.FullUpdateLayout()
		end
	})
	layoutBlock:CreateDropdown({
		Name = "Close Animation",
		Options = { "Fade Slide Down", "Fade Slide Up", "Zoom Fade", "Slide Right" },
		Default = (THEME.CloseAnimation == 2 and "Fade Slide Up") or (THEME.CloseAnimation == 3 and "Zoom Fade") or (THEME.CloseAnimation == 4 and "Slide Right") or "Fade Slide Down",
		Callback = function(opt)
			THEME.CloseAnimation = (opt == "Fade Slide Up" and 2) or (opt == "Zoom Fade" and 3) or (opt == "Slide Right" and 4) or 1
		end
	})
	layoutBlock:CreateToggle({
		Name = "Show Watermark",
		Default = ctx.InitFlags.Watermark,
		Callback = function(s) ctx.WatermarkHolder.Visible = s end
	})
	layoutBlock:CreateToggle({
		Name = "Show Keybinds HUD",
		Default = ctx.InitFlags.Keybinds,
		Callback = function(s) if Window.Keybinds then Window.Keybinds:SetVisible(s) end end
	})
	layoutBlock:CreateDropdown({
		Name = "Topbar Elements Pos",
		Options = { "Right", "Left" },
		Default = THEME.TopbarAlign or "Right",
		Callback = function(opt) ctx.UpdateTopbarAlign(opt) end
	})
	layoutBlock:CreateToggle({
		Name = "Show Search Bar",
		Default = ctx.InitFlags.SearchBar,
		Callback = function(s) ctx.SearchContainer.Visible = s end
	})
	layoutBlock:CreateToggle({
		Name = "Show Profile",
		Default = ctx.InitFlags.Profile,
		Callback = function(s) ctx.ProfileBlock.Visible = s end
	})
	layoutBlock:CreateSlider({
		Name = "Main Corner Radius",
		Min = 0, Max = 30, Step = 1,
		Default = ctx.MainRadius,
		Callback = function(v) ctx.UpdateCorners("Main", v); ctx.FullUpdateLayout() end
	})
	layoutBlock:CreateSlider({
		Name = "Elements Corner Radius",
		Min = 0, Max = 30, Step = 1,
		Default = ctx.ElementRadius,
		Callback = function(v) ctx.UpdateCorners("Element", v) end
	})
	layoutBlock:CreateSlider({
		Name = "HUD Corner Radius",
		Min = 0, Max = 30, Step = 1,
		Default = ctx.HUDRadius,
		Callback = function(v) ctx.UpdateCorners("HUD", v) end
	})
	layoutBlock:CreateDropdown({
		Name = "Sidebar Position",
		Options = { "Left", "Right", "Top", "Bottom" },
		Default = ctx.SIDEBAR_STATE.Position or "Left",
		Callback = function(opt) ctx.SIDEBAR_STATE.Position = opt; ctx.FullUpdateLayout() end
	})
	layoutBlock:CreateToggle({
		Name = "Detached Sidebar",
		Default = ctx.SIDEBAR_STATE.Detached or false,
		Callback = function(s) ctx.SIDEBAR_STATE.Detached = s; ctx.FullUpdateLayout() end
	})
	layoutBlock:CreateDropdown({
		Name = "Toggle Checkbox Pos",
		Options = { "Right", "Left" },
		Default = THEME.TogglePosition or "Right",
		Callback = function(opt) ctx.UpdateTogglePosition(opt) end
	})

	local configBlock = settingsTab:CreateBlock({ Name = "Configuration", Side = "Right" })
	safeMakeFolder(Window.ConfigFolder)

	local function getConfigs()
		local list = {}
		safeMakeFolder(Window.ConfigFolder)
		for _, file in pairs(safeListFiles(Window.ConfigFolder)) do
			local clean = tostring(file):gsub("[%z\r\n%s]+$", "")
			if clean:lower():match("%.json$") then
				local name = clean:match("([^/\\]+)%.[jJ][sS][oO][nN]$")
				if name and name ~= "" then table.insert(list, name) end
			end
		end
		return list
	end

	local autoLoadPath = Window.ConfigFolder .. "/autoload.txt"
	local currentAutoLoad = safeReadFile(autoLoadPath)
	currentAutoLoad = currentAutoLoad and currentAutoLoad:match("^%s*(.-)%s*$") or ""

	local configNameInput = configBlock:CreateInput({ Name = "Config Name", Placeholder = "Enter name..." })
	local configDropdown = configBlock:CreateDropdown({
		Name = "Select Config",
		Options = getConfigs(),
		Default = (currentAutoLoad ~= "" and currentAutoLoad or nil)
	})

	local function applyConfigTable(res)
		for id, val in pairs(res) do
			if id ~= "_layoutState" and Window._configElements[id] then
				pcall(function() Window._configElements[id].API:Load(val) end)
			end
		end
		if type(res._layoutState) == "table" then
			ctx.ApplyLayoutState(res._layoutState)
		end
	end

	configBlock:CreateButton({
		Name = "Load Config",
		Callback = function()
			local cfgName = configDropdown:Save().Selected
			if not cfgName or cfgName == "" then
				Window:Notify({ Title = "Config Error", Description = "No config selected.", Duration = 3 })
				return
			end
			local raw = safeReadFile(Window.ConfigFolder .. "/" .. cfgName .. ".json")
			if not raw or raw == "" then
				Window:Notify({ Title = "Config Error", Description = "File is empty or cannot be read.", Duration = 3 })
				return
			end
			local ok, res = pcall(function() return HttpService:JSONDecode(raw) end)
			if ok and type(res) == "table" then
				applyConfigTable(res)
				Window:Notify({ Title = "Config System", Description = "Loaded config: " .. cfgName, Duration = 3, Icon = SETTINGS_ICON_ID })
			else
				Window:Notify({ Title = "Config Error", Description = "Failed to parse JSON file.", Duration = 3 })
			end
		end
	})

	configBlock:CreateButton({
		Name = "Save Config",
		Callback = function()
			local cfgName = configNameInput:Save().Text
			if not cfgName or cfgName == "" then cfgName = configDropdown:Save().Selected end
			if not cfgName or cfgName == "" then
				Window:Notify({ Title = "Config Error", Description = "Enter a config name first.", Duration = 3 })
				return
			end
			safeMakeFolder(Window.ConfigFolder)
			local data = {}
			for id, el in pairs(Window._configElements) do
				local s, sd = pcall(function() return el.API:Save() end)
				if s and sd ~= nil then data[id] = sd end
			end
			data._layoutState = ctx.CaptureLayoutState()

			local sEnc, json = pcall(function() return HttpService:JSONEncode(data) end)
			if not sEnc then
				Window:Notify({ Title = "Config Error", Description = "JSON serialization failed.", Duration = 3 })
				return
			end
			local sWrite, err = safeWriteFile(Window.ConfigFolder .. "/" .. cfgName .. ".json", json)
			if sWrite then
				configDropdown:SetOptions(getConfigs())
				configDropdown:Set(cfgName)
				Window:Notify({ Title = "Config System", Description = "Saved config: " .. cfgName, Duration = 3, Icon = SETTINGS_ICON_ID })
			else
				Window:Notify({ Title = "Config Error", Description = "Executor blocked writing file: " .. tostring(err), Duration = 4 })
			end
		end
	})

	configBlock:CreateButton({
		Name = "Refresh List",
		Callback = function()
			configDropdown:SetOptions(getConfigs())
			Window:Notify({ Title = "Config System", Description = "Config list refreshed.", Duration = 2 })
		end
	})

	configBlock:CreateButton({
		Name = "Delete Config",
		Callback = function()
			local cfgName = configDropdown:Save().Selected
			if cfgName and cfgName ~= "" then
				safeDelFile(Window.ConfigFolder .. "/" .. cfgName .. ".json")
				configDropdown:SetOptions(getConfigs())
				configDropdown:Set(nil)
				Window:Notify({ Title = "Config System", Description = "Deleted config: " .. cfgName, Duration = 3, Icon = SETTINGS_ICON_ID })
			end
		end
	})

	local initCAuto = true
	configBlock:CreateToggle({
		Name = "Auto-Load Selected Config",
		Default = (currentAutoLoad ~= ""),
		Callback = function(state)
			if initCAuto then return end
			if state then
				local cfgName = configDropdown:Save().Selected
				if cfgName and cfgName ~= "" then safeWriteFile(autoLoadPath, cfgName)
				else Window:Notify({ Title = "Error", Description = "Please select a config first to auto-load.", Duration = 3 }) end
			else
				safeDelFile(autoLoadPath)
			end
		end
	})
	initCAuto = false

	task.spawn(function()
		task.wait(1.2)
		local tAuto = safeReadFile(themeAutoLoadPath)
		if tAuto and tAuto ~= "" then
			tAuto = tAuto:match("^%s*(.-)%s*$")
			local rawT = safeReadFile(Window.ThemeFolder .. "/" .. tAuto .. ".json")
			if rawT and rawT ~= "" then
				local ok, tRes = pcall(function() return HttpService:JSONDecode(rawT) end)
				if ok and type(tRes) == "table" then
					for id, val in pairs(tRes) do
						if id == "SidebarWidth" then ctx.UpdateSidebarWidth(val)
						elseif Window._themeElements[id] then Window._themeElements[id].API:Load(val) end
					end
					themeDropdown:Set(tAuto)
					Window:Notify({ Title = "Theme System", Description = "Auto-loaded theme: " .. tAuto, Duration = 3, Icon = SETTINGS_ICON_ID })
				end
			end
		end

		task.wait(0.35)
		local cAuto = safeReadFile(autoLoadPath)
		if cAuto and cAuto ~= "" then
			cAuto = cAuto:match("^%s*(.-)%s*$")
			local rawC = safeReadFile(Window.ConfigFolder .. "/" .. cAuto .. ".json")
			if rawC and rawC ~= "" then
				local ok, res = pcall(function() return HttpService:JSONDecode(rawC) end)
				if ok and type(res) == "table" then
					applyConfigTable(res)
					configDropdown:Set(cAuto)
					Window:Notify({ Title = "Config System", Description = "Auto-loaded config: " .. cAuto, Duration = 3, Icon = SETTINGS_ICON_ID })
				end
			end
		end
	end)
end

function Library.CreateWindow(arg1, arg2)
	local config = (arg1 == Library and arg2) or (type(arg1) == "table" and arg1) or {}
	local title = config.Title or "iu"
	local searchPlaceholder = config.SearchPlaceholder or "Search components..."
	local logoIconId = (config.Logo or config.LogoIcon) and parseAsset(config.Logo or config.LogoIcon) or nil
	local description = config.Description
	local isInitiallyCollapsed = (config.Collapsed == true) or (config.SidebarCollapsed == true)
	local notifPosition = config.NotificationPosition or "BottomRight"

	local THEME = copyThemeDefaults()
	local customTheme = type(config.Theme) == "table" and config.Theme or {}
	local function getSetting(key, fallback)
		if customTheme[key] ~= nil then return customTheme[key] end
		if config[key] ~= nil then return config[key] end
		return fallback
	end
	for k in pairs(THEME) do
		local v = getSetting(k)
		if v ~= nil then THEME[k] = v end
	end
	THEME.HUDTransparency = math.clamp(tonumber(THEME.HUDTransparency) or 0, 0, 1)

	local keybindsEnabled = getSetting("ShowKeybindsHUD", nil)
	if keybindsEnabled == nil then
		if config.Keybinds ~= nil then keybindsEnabled = config.Keybinds
		elseif config.KeybindsMenu ~= nil then keybindsEnabled = config.KeybindsMenu
		elseif config.KeybindsHUD ~= nil then keybindsEnabled = config.KeybindsHUD
		else keybindsEnabled = true end
	end

	local initFlags = {
		Watermark = getSetting("ShowWatermark", config.Watermark ~= false),
		SearchBar = getSetting("ShowSearchBar", true),
		Profile = getSetting("ShowProfile", true),
		Keybinds = keybindsEnabled
	}

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ModernDashboardGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local okCore = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
	if not okCore then screenGui.Parent = LP:WaitForChild("PlayerGui") end

	local Window = {
		Tabs = {},
		CurrentTab = nil,
		_connections = {},
		_styleCallbacks = {},
		_detachedBlocks = {},
		ActivePopupClose = nil,
		IsEditMode = false,
		_searchRegistry = {},
		_configElements = {},
		_themeElements = {},
		_themeControls = {},
		ConfigFolder = config.ConfigFolder or "AxiomConfigs",
		ThemeFolder = "AxiomUIThemes"
	}

	local mainCornerNum = tonumber(getSetting("CornerRadius", 20)) or 20
	local elCornerNum = tonumber(getSetting("ElementsCornerRadius", mainCornerNum)) or mainCornerNum
	local hudCornerNum = tonumber(getSetting("HUDCornerRadius", 10)) or 10

	local MIN_SIDEBAR_WIDTH = isMobile and 48 or 58
	local MAX_SIDEBAR_WIDTH = isMobile and 150 or 210

	local ctx = {
		Library = Library,
		Window = Window,
		THEME = THEME,
		screenGui = screenGui,
		MainRadius = mainCornerNum,
		ElementRadius = elCornerNum,
		HUDRadius = hudCornerNum,
		OpenKeybind = resolveKeycode(getSetting("OpenKeybind")) or Enum.KeyCode.RightShift,
		IsUIOpen = true,
		InitFlags = initFlags,
		MIN_SIDEBAR_WIDTH = MIN_SIDEBAR_WIDTH,
		MAX_SIDEBAR_WIDTH = MAX_SIDEBAR_WIDTH,
		CurrentSidebarWidth = getSetting("SidebarWidth", isInitiallyCollapsed and MIN_SIDEBAR_WIDTH or MAX_SIDEBAR_WIDTH),
		SIDEBAR_STATE = {
			Position = customTheme.SidebarPosition or config.SidebarPosition or "Left",
			Detached = getSetting("DetachedSidebar", false)
		}
	}

	local trackCount = 0
	function ctx.TrackConnection(conn)
		local list = Window._connections
		list[#list + 1] = conn
		trackCount = trackCount + 1
		if trackCount >= 300 then
			trackCount = 0
			local n, j = #list, 0
			for i = 1, n do
				local c = list[i]
				if c.Connected then
					j = j + 1
					list[j] = c
				end
			end
			for i = j + 1, n do list[i] = nil end
		end
		return conn
	end

	createThemeSystem(ctx)
	createInputController(ctx)
	createNotificationSystem(ctx, notifPosition)

	local mobileBindOrder = 0
	function ctx.CreateMobileBindButton(text, callback)
		local btn = Instance.new("TextButton")
		btn.Name = "MobileBindButton"
		btn.Size = UDim2.new(0, 48, 0, 48)
		btn.AnchorPoint = Vector2.new(0.5, 0.5)
		mobileBindOrder = mobileBindOrder + 1
		btn.Position = UDim2.new(1, -78, 1, -180 - ((mobileBindOrder - 1) * 54))
		btn.AutoButtonColor = false
		btn.Text = text or "None"
		btn.TextSize = 13
		btn.TextWrapped = true
		btn.Active = true
		btn.ZIndex = 100001
		btn.Parent = screenGui
		ctx.ApplyTheme(btn, "Element", "BackgroundColor3")
		ctx.ApplyTheme(btn, "ElementTrans", "BackgroundTransparency")
		ctx.ApplyTheme(btn, "Text", "TextColor3")
		ctx.ApplyTheme(btn, "TextFont", "Font")
		local c = Instance.new("UICorner")
		c.Parent = btn
		ctx.RegisterCorner(c, "Element")
		ctx.AttachStroke(btn, "Element", "Element")

		local moved = false
		ctx.TrackConnection(btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				moved = false
				local dragStart, startPos = input.Position, btn.Position
				ctx.StartDrag(input.UserInputType, function(moveInput)
					local delta = moveInput.Position - dragStart
					if delta.Magnitude > 8 then moved = true end
					btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end)
			end
		end))
		ctx.TrackConnection(btn.MouseButton1Click:Connect(function()
			if not moved then callback() end
		end))
		return btn
	end

	function ctx.CreateMobileToggle(parent, callback)
		local box = Instance.new("TextButton")
		box.Size = UDim2.new(0, 20, 0, 20)
		box.BackgroundTransparency = 1
		box.Text = ""
		box.ZIndex = 5
		box.Parent = parent
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = box
		ctx.ApplyTheme(stroke, "Outlines", "Color")

		local fill = Instance.new("Frame")
		fill.AnchorPoint = Vector2.new(0.5, 0.5)
		fill.Position = UDim2.fromScale(0.5, 0.5)
		fill.BorderSizePixel = 0
		fill.Size = UDim2.new(0, 0, 0, 0)
		fill.Parent = box
		ctx.ApplyTheme(fill, "Accent", "BackgroundColor3")

		local c1 = Instance.new("UICorner")
		c1.Parent = box
		ctx.RegisterCorner(c1, "Element")
		local c2 = Instance.new("UICorner")
		c2.Parent = fill
		ctx.RegisterCorner(c2, "Element")

		local enabled, mobileBtn = false, nil
		local function setEnabled(val)
			enabled = val
			ctx.TweenTheme(stroke, enabled and "Accent" or "Outlines", "Color", T_FAST)
			TS:Create(fill, T_FAST, { Size = enabled and UDim2.new(1, -6, 1, -6) or UDim2.new(0, 0, 0, 0) }):Play()
			callback(enabled, function()
				if mobileBtn then mobileBtn:Destroy(); mobileBtn = nil end
			end, function(b) mobileBtn = b end)
		end
		ctx.TrackConnection(box.MouseButton1Click:Connect(function() setEnabled(not enabled) end))
		return box, setEnabled, function() return mobileBtn end
	end

	local uiScaleValue = isMobile and 0.65 or 1
	local finalW, finalH
	do
		local targetSize = config.WindowSize or Vector2.new(950, 600)
		local reqW = typeof(targetSize) == "Vector2" and targetSize.X or targetSize[1] or 950
		local reqH = typeof(targetSize) == "Vector2" and targetSize.Y or targetSize[2] or 600
		local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
		local maxAvailW = (viewport.X / uiScaleValue) - 40
		local maxAvailH = (viewport.Y / uiScaleValue) - 40
		local minUIW, minUIH = isMobile and 350 or 500, isMobile and 250 or 350
		finalW = math.clamp(reqW, minUIW, math.max(minUIW, maxAvailW))
		finalH = math.clamp(reqH, minUIH, math.max(minUIH, maxAvailH))
	end

	local wrapper = Instance.new("Frame")
	wrapper.Name = "Wrapper"
	wrapper.AnchorPoint = Vector2.new(0.5, 0.5)
	wrapper.Size = UDim2.new(0, finalW, 0, finalH)
	wrapper.Position = UDim2.fromScale(0.5, 0.5)
	wrapper.BackgroundTransparency = 1
	wrapper.Active = true
	wrapper.ZIndex = 5
	wrapper.Parent = screenGui
	ctx.wrapper = wrapper

	local uiScale = Instance.new("UIScale")
	uiScale.Scale = uiScaleValue
	uiScale.Parent = wrapper

	local contentWrapper = Instance.new("Frame")
	contentWrapper.Name = "ContentWrapper"
	contentWrapper.Size = UDim2.fromScale(1, 1)
	contentWrapper.BackgroundTransparency = 1
	contentWrapper.Parent = wrapper

	local main = Instance.new("Frame")
	main.ClipsDescendants = true
	main.Name = "MainFrame"
	main.Size = UDim2.fromScale(1, 1)
	main.BorderSizePixel = 0
	main.ZIndex = 2
	main.BackgroundTransparency = 1
	main.Parent = contentWrapper
	ctx.main = main

	local mainCorner = Instance.new("UICorner")
	mainCorner.Parent = main
	ctx.RegisterCorner(mainCorner, "Main")

	local mainOutlineStroke = Instance.new("UIStroke")
	mainOutlineStroke.Name = "MainOutlineStroke"
	mainOutlineStroke.Enabled = THEME.MainOutlineEnabled
	mainOutlineStroke.Thickness = 1
	mainOutlineStroke.Parent = main
	ctx.ApplyTheme(mainOutlineStroke, "Outlines", "Color")

	local mainDoubleHolder = Instance.new("Frame")
	mainDoubleHolder.Size = UDim2.fromScale(1, 1)
	mainDoubleHolder.BackgroundTransparency = 1
	mainDoubleHolder.ZIndex = 2
	mainDoubleHolder.Parent = contentWrapper
	local _, mainDoubleFrame = ctx.AttachDoubleOutline(main, mainOutlineStroke, "Main", nil, mainDoubleHolder)
	local mainDoubleStroke = mainDoubleFrame:FindFirstChild("DoubleOutlineStroke")

	local bgImage = Instance.new("ImageLabel")
	bgImage.Size = UDim2.fromScale(1, 1)
	bgImage.ZIndex = 0
	bgImage.BackgroundTransparency = 1
	bgImage.ScaleType = Enum.ScaleType.Crop
	bgImage.Parent = main
	local bgImageCorner = Instance.new("UICorner")
	bgImageCorner.Parent = bgImage
	ctx.RegisterCorner(bgImageCorner, "Main")
	ctx.ApplyTheme(bgImage, "BgImageTrans", "ImageTransparency")
	ctx.ApplyTheme(bgImage, "BackgroundImage", "Image")

	local bgColorOverlay = Instance.new("Frame")
	bgColorOverlay.Size = UDim2.fromScale(1, 1)
	bgColorOverlay.ZIndex = 1
	bgColorOverlay.BorderSizePixel = 0
	bgColorOverlay.Parent = main
	local bgColorOverlayCorner = Instance.new("UICorner")
	bgColorOverlayCorner.Parent = bgColorOverlay
	ctx.RegisterCorner(bgColorOverlayCorner, "Main")
	ctx.ApplyTheme(bgColorOverlay, "Background", "BackgroundColor3")
	ctx.ApplyTheme(bgColorOverlay, "BackgroundTrans", "BackgroundTransparency")

	local dragArea = Instance.new("Frame")
	dragArea.Size = UDim2.new(1, 0, 0, 60)
	dragArea.BackgroundTransparency = 1
	dragArea.Active = true
	dragArea.ZIndex = 10
	dragArea.Parent = wrapper

	local targetPos = wrapper.Position
	local draggingWindow = false
	local dragConn = nil

	local function startDragLoop()
		if dragConn then return end
		dragConn = RS.RenderStepped:Connect(function(dt)
			if not wrapper.Parent then
				if dragConn then dragConn:Disconnect(); dragConn = nil end
				return
			end
			local diffX = math.abs(wrapper.Position.X.Offset - targetPos.X.Offset)
			local diffY = math.abs(wrapper.Position.Y.Offset - targetPos.Y.Offset)
			if diffX > 0.1 or diffY > 0.1 then
				wrapper.Position = wrapper.Position:Lerp(targetPos, 1 - math.exp(-28 * dt))
			else
				if wrapper.Position ~= targetPos then wrapper.Position = targetPos end
				if not draggingWindow then
					dragConn:Disconnect()
					dragConn = nil
				end
			end
		end)
		ctx.TrackConnection(dragConn)
	end

	ctx.TrackConnection(dragArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingWindow = true
			local dragStart, startPos = input.Position, targetPos
			startDragLoop()
			ctx.StartDrag(input.UserInputType, function(moveInput)
				local delta = moveInput.Position - dragStart
				targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				startDragLoop()
			end, function()
				draggingWindow = false
				if ctx.PositionEditorNearGUI then ctx.PositionEditorNearGUI() end
			end)
		end
	end))

	local resizeHitbox = Instance.new("TextButton")
	resizeHitbox.Size = UDim2.new(0, isMobile and 64 or 50, 0, isMobile and 64 or 50)
	resizeHitbox.Position = UDim2.new(1, 10, 1, 10)
	resizeHitbox.AnchorPoint = Vector2.new(1, 1)
	resizeHitbox.BackgroundTransparency = 1
	resizeHitbox.Text = ""
	resizeHitbox.Active = true
	resizeHitbox.ZIndex = 20
	resizeHitbox.Parent = wrapper

	local arcOuterStroke
	do
		local GAP, STROKE_THICK = 5, 4
		local R_CENTER = mainCornerNum + GAP
		local FRAME_R = R_CENTER - (STROKE_THICK / 2)
		local OUTER_R = R_CENTER + (STROKE_THICK / 2)
		local CAP_OFF = 4
		local CAP_X = math.sqrt(math.max(0, R_CENTER^2 - CAP_OFF^2)) + 0.5
		local CAP_SIZE = STROKE_THICK + 0.6

		local arcMaster = Instance.new("Frame")
		arcMaster.Size = UDim2.new(0, OUTER_R, 0, OUTER_R)
		arcMaster.Position = UDim2.new(1, -mainCornerNum, 1, -mainCornerNum)
		arcMaster.BackgroundTransparency = 1
		arcMaster.ZIndex = 3
		arcMaster.Parent = contentWrapper

		local arcClipped = Instance.new("Frame")
		arcClipped.Size = UDim2.new(1, -CAP_OFF, 1, -CAP_OFF)
		arcClipped.Position = UDim2.new(0, CAP_OFF, 0, CAP_OFF)
		arcClipped.BackgroundTransparency = 1
		arcClipped.ClipsDescendants = true
		arcClipped.Parent = arcMaster

		local arcOuter = Instance.new("Frame")
		arcOuter.Size = UDim2.new(0, FRAME_R * 2, 0, FRAME_R * 2)
		arcOuter.Position = UDim2.new(0, -CAP_OFF, 0, -CAP_OFF)
		arcOuter.AnchorPoint = Vector2.new(0.5, 0.5)
		arcOuter.BackgroundTransparency = 1
		arcOuter.Parent = arcClipped

		local aC = Instance.new("UICorner")
		aC.Parent = arcOuter
		ctx.RegisterCorner(aC, "Main", GAP - (STROKE_THICK / 2))

		arcOuterStroke = Instance.new("UIStroke")
		arcOuterStroke.Thickness = STROKE_THICK
		arcOuterStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		arcOuterStroke.Parent = arcOuter
		ctx.ApplyTheme(arcOuterStroke, "TextMuted", "Color")

		local topCap = Instance.new("Frame")
		topCap.Size = UDim2.new(0, CAP_SIZE, 0, CAP_SIZE)
		topCap.Position = UDim2.new(0, CAP_X, 0, CAP_OFF)
		topCap.AnchorPoint = Vector2.new(0.5, 0.5)
		topCap.BorderSizePixel = 0
		topCap.Parent = arcMaster
		ctx.ApplyTheme(topCap, "TextMuted", "BackgroundColor3")
		local tcC = Instance.new("UICorner")
		tcC.CornerRadius = UDim.new(1, 0)
		tcC.Parent = topCap

		local leftCap = topCap:Clone()
		leftCap.Position = UDim2.new(0, CAP_OFF, 0, CAP_X)
		leftCap.Parent = arcMaster
		ctx.ApplyTheme(leftCap, "TextMuted", "BackgroundColor3")
	end

	ctx.TrackConnection(resizeHitbox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local startPos = input.Position
			local startSize = wrapper.AbsoluteSize
			ctx.StartDrag(input.UserInputType, function(moveInput)
				local delta = (moveInput.Position - startPos) / uiScaleValue
				local sw, sh = screenGui.AbsoluteSize.X, screenGui.AbsoluteSize.Y
				local minW, minH = isMobile and 350 or 500, isMobile and 250 or 350
				local maxW = math.max(minW, (sw / uiScaleValue) - 40)
				local maxH = math.max(minH, (sh / uiScaleValue) - 40)
				wrapper.Size = UDim2.new(0, math.clamp(startSize.X + (delta.X * 2), minW, maxW), 0, math.clamp(startSize.Y + (delta.Y * 2), minH, maxH))
				if ctx.PositionEditorNearGUI then ctx.PositionEditorNearGUI() end
			end)
		end
	end))

	Window.Overlay = Instance.new("TextButton")
	Window.Overlay.Name = "PopupOverlay"
	Window.Overlay.Size = UDim2.fromScale(1, 1)
	Window.Overlay.BackgroundTransparency = 1
	Window.Overlay.Text = ""
	Window.Overlay.ZIndex = 100000
	Window.Overlay.Visible = false
	Window.Overlay.Parent = screenGui

	Window.ClosePopup = function()
		if Window.ActivePopup then
			local p = Window.ActivePopup
			Window.ActivePopup = nil
			if Window.ActivePopupClose then
				Window.ActivePopupClose()
				Window.ActivePopupClose = nil
			else
				p.Visible = false
				if not Window.ActivePopup then Window.Overlay.Visible = false end
			end
		end
	end
	ctx.TrackConnection(Window.Overlay.MouseButton1Click:Connect(Window.ClosePopup))

	local sidebarVisuals = Instance.new("Frame")
	sidebarVisuals.Size = UDim2.new(0, ctx.CurrentSidebarWidth, 1, 0)
	sidebarVisuals.BorderSizePixel = 0
	sidebarVisuals.ZIndex = 3
	sidebarVisuals.BackgroundTransparency = 1
	sidebarVisuals.Parent = main
	local svCorner = Instance.new("UICorner")
	svCorner.Parent = sidebarVisuals

	local sidebarBgImage = Instance.new("ImageLabel")
	sidebarBgImage.Size = UDim2.fromScale(1, 1)
	sidebarBgImage.ZIndex = 0
	sidebarBgImage.BackgroundTransparency = 1
	sidebarBgImage.ScaleType = Enum.ScaleType.Crop
	sidebarBgImage.Visible = false
	sidebarBgImage.Parent = sidebarVisuals
	local sidebarBgCorner = Instance.new("UICorner")
	sidebarBgCorner.Parent = sidebarBgImage
	ctx.ApplyTheme(sidebarBgImage, "BgImageTrans", "ImageTransparency")
	ctx.ApplyTheme(sidebarBgImage, "BackgroundImage", "Image")

	local sidebarBase = Instance.new("Frame")
	sidebarBase.Size = UDim2.fromScale(1, 1)
	sidebarBase.ZIndex = 1
	sidebarBase.BorderSizePixel = 0
	sidebarBase.Parent = sidebarVisuals
	ctx.ApplyTheme(sidebarBase, "Sidebar", "BackgroundColor3")
	ctx.ApplyTheme(sidebarBase, "BackgroundTrans", "BackgroundTransparency")
	local sbCorner = Instance.new("UICorner")
	sbCorner.Parent = sidebarBase

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, ctx.CurrentSidebarWidth, 1, 0)
	sidebar.BackgroundTransparency = 1
	sidebar.ZIndex = 5
	sidebar.Parent = main
	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.Parent = sidebar

	local sidebarOutlineStroke = Instance.new("UIStroke")
	sidebarOutlineStroke.Enabled = false
	sidebarOutlineStroke.Thickness = 1
	sidebarOutlineStroke.Parent = sidebar
	ctx.ApplyTheme(sidebarOutlineStroke, "Outlines", "Color")
	local _, sbDoubleFrame = ctx.AttachDoubleOutline(sidebar, sidebarOutlineStroke, "Main")
	local sidebarDoubleStroke = sbDoubleFrame:FindFirstChild("DoubleOutlineStroke")

	local logoContainer = Instance.new("Frame")
	logoContainer.Size = UDim2.new(1, 0, 0, 60)
	logoContainer.Position = UDim2.new(0, 0, 0, -2)
	logoContainer.BackgroundTransparency = 1
	logoContainer.ClipsDescendants = true
	logoContainer.Parent = sidebar

	local logoLayout = Instance.new("UIListLayout")
	logoLayout.FillDirection = Enum.FillDirection.Horizontal
	logoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	logoLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	logoLayout.SortOrder = Enum.SortOrder.LayoutOrder
	logoLayout.Padding = UDim.new(0, 10)
	logoLayout.Parent = logoContainer

	local logoPadding = Instance.new("UIPadding")
	logoPadding.Parent = logoContainer

	local logoImage, logoLabel
	if logoIconId and logoIconId ~= "" then
		logoImage = Instance.new("ImageLabel")
		logoImage.Size = UDim2.new(0, 32, 0, 32)
		logoImage.BackgroundTransparency = 1
		logoImage.Image = logoIconId
		logoImage.LayoutOrder = 1
		logoImage.Parent = logoContainer
	end

	logoLabel = Instance.new("TextLabel")
	logoLabel.AutomaticSize = Enum.AutomaticSize.X
	logoLabel.Size = UDim2.new(0, 0, 1, 0)
	logoLabel.BackgroundTransparency = 1
	logoLabel.TextSize = 30
	logoLabel.Text = title
	logoLabel.TextTruncate = Enum.TextTruncate.AtEnd
	logoLabel.LayoutOrder = 2
	logoLabel.Parent = logoContainer
	ctx.ApplyTheme(logoLabel, "Text", "TextColor3")
	ctx.ApplyTheme(logoLabel, "TextFont", "Font")

	local sidebarDivider = Instance.new("Frame")
	sidebarDivider.Size = UDim2.new(1, 0, 0, 1)
	sidebarDivider.Position = UDim2.new(0, 0, 0, 60)
	sidebarDivider.BorderSizePixel = 0
	sidebarDivider.ZIndex = 6
	sidebarDivider.Parent = sidebar
	ctx.ApplyTheme(sidebarDivider, "Outlines", "BackgroundColor3")

	local tabList = Instance.new("ScrollingFrame")
	tabList.Size = UDim2.new(1, -20, 1, (description and type(description) == "string") and -140 or -90)
	tabList.Position = UDim2.new(0, 10, 0, 75)
	tabList.BackgroundTransparency = 1
	tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabList.ScrollBarThickness = 2
	tabList.Parent = sidebar
	ctx.ApplyTheme(tabList, "Outlines", "ScrollBarImageColor3")

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	tabListLayout.Padding = UDim.new(0, 4)
	tabListLayout.Parent = tabList

	local tabListPadding = Instance.new("UIPadding")
	tabListPadding.PaddingTop, tabListPadding.PaddingBottom = UDim.new(0, 2), UDim.new(0, 2)
	tabListPadding.PaddingLeft, tabListPadding.PaddingRight = UDim.new(0, 2), UDim.new(0, 2)
	tabListPadding.Parent = tabList

	local settingsContainer = Instance.new("Frame")
	settingsContainer.Size = UDim2.new(0, 70, 1, 0)
	settingsContainer.Position = UDim2.new(1, -70, 0, 0)
	settingsContainer.BackgroundTransparency = 1
	settingsContainer.Visible = false
	settingsContainer.Parent = sidebar

	local settingsLayout = Instance.new("UIListLayout")
	settingsLayout.FillDirection = Enum.FillDirection.Horizontal
	settingsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	settingsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	settingsLayout.Padding = UDim.new(0, 4)
	settingsLayout.Parent = settingsContainer

	local dividerContainer = Instance.new("Frame")
	dividerContainer.Size = UDim2.new(1, 0, 0, 16)
	dividerContainer.BackgroundTransparency = 1
	dividerContainer.LayoutOrder = 9998
	dividerContainer.Parent = tabList

	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(0.8, 0, 0, 1)
	divider.Position = UDim2.fromScale(0.5, 0.5)
	divider.AnchorPoint = Vector2.new(0.5, 0.5)
	divider.BorderSizePixel = 0
	divider.Parent = dividerContainer
	ctx.ApplyTheme(divider, "Outlines", "BackgroundColor3")

	local descLabel = nil
	if description and type(description) == "string" then
		descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(1, -16, 0, 36)
		descLabel.Position = UDim2.new(0, 8, 1, -44)
		descLabel.BackgroundTransparency = 1
		descLabel.TextSize = 11
		descLabel.TextWrapped = true
		descLabel.ClipsDescendants = true
		descLabel.TextXAlignment = Enum.TextXAlignment.Center
		descLabel.TextYAlignment = Enum.TextYAlignment.Bottom
		descLabel.Text = description
		descLabel.Parent = sidebar
		ctx.ApplyTheme(descLabel, "TextMuted", "TextColor3")
		ctx.ApplyTheme(descLabel, "SubtextFont", "Font")
	end

	local topbar = Instance.new("Frame")
	topbar.Size = UDim2.new(1, -ctx.CurrentSidebarWidth, 0, 60)
	topbar.Position = UDim2.new(0, ctx.CurrentSidebarWidth, 0, 0)
	topbar.BackgroundTransparency = 1
	topbar.ClipsDescendants = true
	topbar.ZIndex = 5
	topbar.Parent = main

	local topbarDivider = Instance.new("Frame")
	topbarDivider.Size = UDim2.new(1, -ctx.CurrentSidebarWidth, 0, 1)
	topbarDivider.Position = UDim2.new(0, ctx.CurrentSidebarWidth, 0, 60)
	topbarDivider.BorderSizePixel = 0
	topbarDivider.ZIndex = 6
	topbarDivider.Parent = main
	ctx.ApplyTheme(topbarDivider, "Outlines", "BackgroundColor3")

	local topbarDescLabel = nil
	if description and type(description) == "string" then
		topbarDescLabel = Instance.new("TextLabel")
		topbarDescLabel.Size = UDim2.new(1, -455, 1, 0)
		topbarDescLabel.Position = UDim2.new(0, 15, 0, 0)
		topbarDescLabel.BackgroundTransparency = 1
		topbarDescLabel.TextSize = 11
		topbarDescLabel.TextWrapped = true
		topbarDescLabel.TextTruncate = Enum.TextTruncate.AtEnd
		topbarDescLabel.ClipsDescendants = true
		topbarDescLabel.TextXAlignment = Enum.TextXAlignment.Left
		topbarDescLabel.Text = description
		topbarDescLabel.ZIndex = 6
		topbarDescLabel.Visible = false
		topbarDescLabel.Parent = topbar
		ctx.ApplyTheme(topbarDescLabel, "TextMuted", "TextColor3")
		ctx.ApplyTheme(topbarDescLabel, "SubtextFont", "Font")
		ctx.BindLayout("TopbarDesc", topbarDescLabel)
	end

	local topbarControls = Instance.new("Frame")
	topbarControls.Size = UDim2.fromScale(1, 1)
	topbarControls.BackgroundTransparency = 1
	topbarControls.ZIndex = 5
	topbarControls.Parent = topbar

	local topbarLayout = Instance.new("UIListLayout")
	topbarLayout.FillDirection = Enum.FillDirection.Horizontal
	topbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	topbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	topbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	topbarLayout.Padding = UDim.new(0, 15)
	topbarLayout.Parent = topbarControls
	ctx.BindLayout("TopbarLayout", topbarLayout)

	local topbarPadding = Instance.new("UIPadding")
	topbarPadding.PaddingRight = UDim.new(0, 14)
	topbarPadding.Parent = topbarControls
	ctx.BindLayout("TopbarPadding", topbarPadding)

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 42, 0, 42)
	closeBtn.Text = ""
	closeBtn.AutoButtonColor = false
	closeBtn.LayoutOrder = 3
	closeBtn.ZIndex = 50
	closeBtn.Parent = topbarControls
	ctx.ApplyTheme(closeBtn, "Card", "BackgroundColor3")
	ctx.ApplyTheme(closeBtn, "CardTrans", "BackgroundTransparency")
	ctx.BindLayout("CloseBtn", closeBtn)
	local cbC = Instance.new("UICorner")
	cbC.Parent = closeBtn
	ctx.RegisterCorner(cbC, "Main")
	ctx.AttachStroke(closeBtn, "Block", "Main")

	local crossLine1 = Instance.new("Frame")
	crossLine1.Size = UDim2.new(0, 14, 0, 1)
	crossLine1.Position = UDim2.fromScale(0.5, 0.5)
	crossLine1.AnchorPoint = Vector2.new(0.5, 0.5)
	crossLine1.Rotation = 45
	crossLine1.BorderSizePixel = 0
	crossLine1.Parent = closeBtn
	ctx.ApplyTheme(crossLine1, "TextMuted", "BackgroundColor3")
	local crossLine2 = crossLine1:Clone()
	crossLine2.Rotation = -45
	crossLine2.Parent = closeBtn

	local profileBlock = Instance.new("Frame")
	profileBlock.Size = UDim2.new(0, 120, 0, 42)
	profileBlock.LayoutOrder = 2
	profileBlock.Parent = topbarControls
	ctx.ApplyTheme(profileBlock, "Card", "BackgroundColor3")
	ctx.ApplyTheme(profileBlock, "CardTrans", "BackgroundTransparency")
	ctx.BindLayout("ProfileBlock", profileBlock)
	local pbC = Instance.new("UICorner")
	pbC.Parent = profileBlock
	ctx.RegisterCorner(pbC, "Main")
	ctx.AttachStroke(profileBlock, "Block", "Main")
	ctx.ProfileBlock = profileBlock

	do
		local profileInner = Instance.new("Frame")
		profileInner.AutomaticSize = Enum.AutomaticSize.X
		profileInner.Size = UDim2.new(0, 0, 1, 0)
		profileInner.BackgroundTransparency = 1
		profileInner.ZIndex = 2
		profileInner.Parent = profileBlock
		local function syncProf()
			if profileInner.AbsoluteSize.X > 0 then
				profileBlock.Size = UDim2.new(0, profileInner.AbsoluteSize.X, 0, 42)
			end
		end
		ctx.TrackConnection(profileInner:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncProf))
		task.defer(syncProf)

		local pPad = Instance.new("UIPadding")
		pPad.PaddingLeft, pPad.PaddingRight = UDim.new(0, 15), UDim.new(0, 5)
		pPad.Parent = profileInner
		local pLay = Instance.new("UIListLayout")
		pLay.FillDirection = Enum.FillDirection.Horizontal
		pLay.VerticalAlignment = Enum.VerticalAlignment.Center
		pLay.SortOrder = Enum.SortOrder.LayoutOrder
		pLay.Padding = UDim.new(0, 10)
		pLay.Parent = profileInner

		local namesC = Instance.new("Frame")
		namesC.AutomaticSize = Enum.AutomaticSize.X
		namesC.Size = UDim2.new(0, 0, 1, 0)
		namesC.BackgroundTransparency = 1
		namesC.LayoutOrder = 1
		namesC.Parent = profileInner
		local nLay = Instance.new("UIListLayout")
		nLay.FillDirection = Enum.FillDirection.Vertical
		nLay.VerticalAlignment = Enum.VerticalAlignment.Center
		nLay.HorizontalAlignment = Enum.HorizontalAlignment.Right
		nLay.Padding = UDim.new(0, 2)
		nLay.Parent = namesC

		local dispName = Instance.new("TextLabel")
		dispName.AutomaticSize = Enum.AutomaticSize.X
		dispName.Size = UDim2.new(0, 0, 0, 14)
		dispName.BackgroundTransparency = 1
		dispName.TextSize = 13
		dispName.Text = LP.DisplayName
		dispName.TextTruncate = Enum.TextTruncate.AtEnd
		dispName.Parent = namesC
		ctx.ApplyTheme(dispName, "Text", "TextColor3")
		ctx.ApplyTheme(dispName, "TextFont", "Font")

		local uName = Instance.new("TextLabel")
		uName.AutomaticSize = Enum.AutomaticSize.X
		uName.Size = UDim2.new(0, 0, 0, 12)
		uName.BackgroundTransparency = 1
		uName.TextSize = 11
		uName.Text = "@" .. LP.Name
		uName.TextTruncate = Enum.TextTruncate.AtEnd
		uName.Parent = namesC
		ctx.ApplyTheme(uName, "TextMuted", "TextColor3")
		ctx.ApplyTheme(uName, "SubtextFont", "Font")

		local avatar = Instance.new("ImageLabel")
		avatar.Size = UDim2.new(0, 32, 0, 32)
		avatar.BackgroundTransparency = 1
		pcall(function()
			avatar.Image = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		avatar.LayoutOrder = 2
		avatar.Parent = profileInner
		local avC = Instance.new("UICorner")
		avC.CornerRadius = UDim.new(1, 0)
		avC.Parent = avatar
	end

	local searchContainer = Instance.new("Frame")
	searchContainer.Size = UDim2.new(0, 230, 0, 42)
	searchContainer.LayoutOrder = 1
	searchContainer.Parent = topbarControls
	ctx.ApplyTheme(searchContainer, "Card", "BackgroundColor3")
	ctx.ApplyTheme(searchContainer, "CardTrans", "BackgroundTransparency")
	ctx.BindLayout("SearchContainer", searchContainer)
	local scC = Instance.new("UICorner")
	scC.Parent = searchContainer
	ctx.RegisterCorner(scC, "Main")
	ctx.AttachStroke(searchContainer, "Block", "Main")
	ctx.SearchContainer = searchContainer

	local searchInput = Instance.new("TextBox")
	searchInput.Size = UDim2.new(1, -45, 1, 0)
	searchInput.Position = UDim2.new(0, 15, 0, 0)
	searchInput.BackgroundTransparency = 1
	searchInput.TextSize = 13
	searchInput.PlaceholderText = searchPlaceholder
	searchInput.Text = ""
	searchInput.ClipsDescendants = true
	searchInput.TextXAlignment = Enum.TextXAlignment.Left
	searchInput.Parent = searchContainer
	ctx.ApplyTheme(searchInput, "Text", "TextColor3")
	ctx.ApplyTheme(searchInput, "TextMuted", "PlaceholderColor3")
	ctx.ApplyTheme(searchInput, "TextFont", "Font")

	local searchIcon = Instance.new("ImageLabel")
	searchIcon.Size = UDim2.new(0, 20, 0, 20)
	searchIcon.Position = UDim2.new(1, -32, 0.5, -10)
	searchIcon.BackgroundTransparency = 1
	searchIcon.Image = SEARCH_ICON_ID
	searchIcon.Parent = searchContainer
	ctx.ApplyTheme(searchIcon, "TextMuted", "ImageColor3")

	local pagesFolder = Instance.new("Frame")
	pagesFolder.Size = UDim2.new(1, -ctx.CurrentSidebarWidth, 1, -60)
	pagesFolder.Position = UDim2.new(0, ctx.CurrentSidebarWidth, 0, 60)
	pagesFolder.BackgroundTransparency = 1
	pagesFolder.ClipsDescendants = true
	pagesFolder.ZIndex = 5
	pagesFolder.Parent = main

	local searchPage = Instance.new("Frame")
	searchPage.Name = "SearchPage"
	searchPage.Size = UDim2.fromScale(1, 1)
	searchPage.BackgroundTransparency = 1
	searchPage.ClipsDescendants = true
	searchPage.Visible = false
	searchPage.Parent = pagesFolder

	local searchPageContent = Instance.new("ScrollingFrame")
	searchPageContent.Size = UDim2.fromScale(1, 1)
	searchPageContent.BackgroundTransparency = 1
	searchPageContent.ScrollBarThickness = 0
	searchPageContent.CanvasSize = UDim2.new(0, 0, 0, 0)
	searchPageContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
	searchPageContent.Parent = searchPage

	local spPadding = Instance.new("UIPadding")
	spPadding.PaddingTop, spPadding.PaddingBottom = UDim.new(0, 14), UDim.new(0, 14)
	spPadding.PaddingLeft, spPadding.PaddingRight = UDim.new(0, 14), UDim.new(0, 14)
	spPadding.Parent = searchPageContent

	local spLayout = Instance.new("UIListLayout")
	spLayout.FillDirection = Enum.FillDirection.Horizontal
	spLayout.SortOrder = Enum.SortOrder.LayoutOrder
	spLayout.Padding = UDim.new(0, 14)
	spLayout.Parent = searchPageContent

	local searchLeftCol = Instance.new("Frame")
	searchLeftCol.Size = UDim2.new(0.5, -7, 0, 0)
	searchLeftCol.AutomaticSize = Enum.AutomaticSize.Y
	searchLeftCol.BackgroundTransparency = 1
	searchLeftCol.Parent = searchPageContent
	local slLayout = Instance.new("UIListLayout")
	slLayout.SortOrder = Enum.SortOrder.LayoutOrder
	slLayout.Padding = UDim.new(0, 14)
	slLayout.Parent = searchLeftCol

	local searchRightCol = Instance.new("Frame")
	searchRightCol.Size = UDim2.new(0.5, -7, 0, 0)
	searchRightCol.AutomaticSize = Enum.AutomaticSize.Y
	searchRightCol.BackgroundTransparency = 1
	searchRightCol.Parent = searchPageContent
	local srLayout = Instance.new("UIListLayout")
	srLayout.SortOrder = Enum.SortOrder.LayoutOrder
	srLayout.Padding = UDim.new(0, 14)
	srLayout.Parent = searchRightCol

	local function updateSearchTabStyle(style)
		local compact = (style == 3 or style == 4)
		local pad = compact and 8 or 14
		local colOff = compact and -4 or -7
		searchLeftCol.Size = UDim2.new(0.5, colOff, 0, 0)
		searchRightCol.Size = UDim2.new(0.5, colOff, 0, 0)
		spPadding.PaddingTop, spPadding.PaddingBottom = UDim.new(0, pad), UDim.new(0, pad)
		spPadding.PaddingLeft, spPadding.PaddingRight = UDim.new(0, pad), UDim.new(0, pad)
		spLayout.Padding = UDim.new(0, pad)
		slLayout.Padding = UDim.new(0, pad)
		srLayout.Padding = UDim.new(0, pad)
	end
	table.insert(Window._styleCallbacks, updateSearchTabStyle)
	updateSearchTabStyle(THEME.ElementStyle)

	local function constructMockBlock(bName, bIcon, parent)
		local bc = Instance.new("Frame")
		bc.Size = UDim2.new(1, 0, 0, 40)
		bc.Parent = parent
		ctx.ApplyTheme(bc, "Card", "BackgroundColor3")
		ctx.ApplyTheme(bc, "CardTrans", "BackgroundTransparency")
		local bcC = Instance.new("UICorner")
		bcC.Parent = bc
		ctx.RegisterCorner(bcC, "Element")
		ctx.AttachStroke(bc, "Block", "Element")

		local bcInner = Instance.new("Frame")
		bcInner.Size = UDim2.new(1, 0, 0, 0)
		bcInner.AutomaticSize = Enum.AutomaticSize.Y
		bcInner.BackgroundTransparency = 1
		bcInner.ZIndex = 2
		bcInner.Parent = bc
		ctx.TrackConnection(bcInner:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if bc.Parent then bc.Size = UDim2.new(1, 0, 0, math.max(30, bcInner.AbsoluteSize.Y)) end
		end))

		local compact = (THEME.ElementStyle == 3 or THEME.ElementStyle == 4)
		local bp = Instance.new("UIPadding")
		local pVal = compact and 8 or 12
		bp.PaddingTop, bp.PaddingBottom, bp.PaddingLeft, bp.PaddingRight = UDim.new(0, pVal), UDim.new(0, pVal), UDim.new(0, pVal), UDim.new(0, pVal)
		bp.Parent = bcInner

		local bl = Instance.new("UIListLayout")
		bl.FillDirection = Enum.FillDirection.Vertical
		bl.SortOrder = Enum.SortOrder.LayoutOrder
		bl.Padding = UDim.new(0, compact and 4 or 6)
		bl.Parent = bcInner

		local header = Instance.new("Frame")
		header.Size = UDim2.new(1, 0, 0, compact and 22 or 26)
		header.BackgroundTransparency = 1
		header.LayoutOrder = 0
		header.Parent = bcInner

		local hl = Instance.new("UIListLayout")
		hl.FillDirection = Enum.FillDirection.Horizontal
		hl.VerticalAlignment = Enum.VerticalAlignment.Center
		hl.SortOrder = Enum.SortOrder.LayoutOrder
		hl.Padding = UDim.new(0, 8)
		hl.Parent = header

		if bIcon and bIcon ~= "" then
			local bi = Instance.new("ImageLabel")
			local s = compact and 22 or 26
			bi.Size = UDim2.new(0, s, 0, s)
			bi.BackgroundTransparency = 1
			bi.Image = bIcon
			bi.Parent = header
			ctx.ApplyTheme(bi, "Text", "ImageColor3")
		end

		local bt = Instance.new("TextLabel")
		bt.AutomaticSize = Enum.AutomaticSize.X
		bt.Size = UDim2.new(0, 0, 1, 0)
		bt.BackgroundTransparency = 1
		bt.TextSize = 13
		bt.TextTruncate = Enum.TextTruncate.AtEnd
		bt.Text = bName
		bt.Parent = header
		ctx.ApplyTheme(bt, "Text", "TextColor3")
		ctx.ApplyTheme(bt, "TextFont", "Font")

		local bd = Instance.new("Frame")
		bd.Size = UDim2.new(1, 0, 0, 1)
		bd.BorderSizePixel = 0
		bd.LayoutOrder = 1
		bd.Parent = bcInner
		ctx.ApplyTheme(bd, "Outlines", "BackgroundColor3")
		return bcInner
	end

	local lastSearchQuery = ""
	ctx.TrackConnection(searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		local q = string.lower(searchInput.Text)
		if q == lastSearchQuery then return end
		lastSearchQuery = q

		for _, entry in ipairs(Window._searchRegistry) do
			entry.UI.Parent = entry.OriginalParent
		end
		for _, b in ipairs(searchLeftCol:GetChildren()) do if b:IsA("Frame") then b:Destroy() end end
		for _, b in ipairs(searchRightCol:GetChildren()) do if b:IsA("Frame") then b:Destroy() end end

		if q == "" then
			searchPage.Visible = false
			if Window.CurrentTab and Window.CurrentTab.Page then
				Window.CurrentTab.Page.Visible = true
			end
			return
		end

		if Window.CurrentTab and Window.CurrentTab.Page then
			Window.CurrentTab.Page.Visible = false
		end

		local matched = { Left = {}, Right = {} }
		local order = { Left = {}, Right = {} }
		for _, entry in ipairs(Window._searchRegistry) do
			if string.find(entry.Name, q, 1, true) then
				local side = entry.BlockSide
				local bName = entry.BlockName
				if not matched[side][bName] then
					matched[side][bName] = { Icon = entry.BlockIcon, Elements = {} }
					table.insert(order[side], bName)
				end
				table.insert(matched[side][bName].Elements, entry)
			end
		end

		for side, col in pairs({ Left = searchLeftCol, Right = searchRightCol }) do
			for _, bName in ipairs(order[side]) do
				local data = matched[side][bName]
				local mockInner = constructMockBlock(bName, data.Icon, col)
				for _, entry in ipairs(data.Elements) do
					entry.UI.Parent = mockInner
				end
			end
		end
		searchPage.Visible = true
	end))

	local sidebarResizer = Instance.new("TextButton")
	sidebarResizer.Size = UDim2.new(0, 12, 1, 0)
	sidebarResizer.Position = UDim2.new(0, ctx.CurrentSidebarWidth, 0, 0)
	sidebarResizer.AnchorPoint = Vector2.new(0.5, 0)
	sidebarResizer.BackgroundTransparency = 1
	sidebarResizer.Text = ""
	sidebarResizer.AutoButtonColor = false
	sidebarResizer.ZIndex = 25
	sidebarResizer.Parent = main

	local resizerLine = Instance.new("Frame")
	resizerLine.Size = UDim2.new(0, 1, 1, 0)
	resizerLine.Position = UDim2.fromScale(0.5, 0)
	resizerLine.AnchorPoint = Vector2.new(0.5, 0)
	resizerLine.BorderSizePixel = 0
	resizerLine.Parent = sidebarResizer
	ctx.ApplyTheme(resizerLine, "Outlines", "BackgroundColor3")

	function ctx.FullUpdateLayout()
		local SIDEBAR_STATE = ctx.SIDEBAR_STATE
		local isTopOrBottom = (SIDEBAR_STATE.Position == "Top" or SIDEBAR_STATE.Position == "Bottom")
		local effWidth = isTopOrBottom and MIN_SIDEBAR_WIDTH or ctx.CurrentSidebarWidth
		local isCollapsed = (effWidth < 115) or isTopOrBottom

		tabListLayout.Padding = UDim.new(0, (THEME.ElementStyle == 3 or THEME.ElementStyle == 4) and 2 or 4)
		sidebarResizer.Visible = not SIDEBAR_STATE.Detached

		if SIDEBAR_STATE.Detached then
			sidebarBgImage.Visible = true
			local rUDim = UDim.new(0, ctx.MainRadius)
			svCorner.CornerRadius, sbCorner.CornerRadius, sidebarCorner.CornerRadius = rUDim, rUDim, rUDim
			sidebarBgCorner.CornerRadius = rUDim
			sidebar.Parent, sidebarVisuals.Parent = contentWrapper, contentWrapper
			sidebarOutlineStroke.Enabled = THEME.MainOutlineEnabled
			sidebarOutlineStroke.Transparency = 0
			topbar.Size, topbar.Position = UDim2.new(1, 0, 0, 60), UDim2.new(0, 0, 0, 0)
			pagesFolder.Size, pagesFolder.Position = UDim2.new(1, 0, 1, -60), UDim2.new(0, 0, 0, 60)
			topbarDivider.Size, topbarDivider.Position = UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 60)

			if SIDEBAR_STATE.Position == "Left" then
				sidebar.Size, sidebar.Position = UDim2.new(0, effWidth, 1, 0), UDim2.new(0, -effWidth - 15, 0, 0)
			elseif SIDEBAR_STATE.Position == "Right" then
				sidebar.Size, sidebar.Position = UDim2.new(0, effWidth, 1, 0), UDim2.new(1, 15, 0, 0)
			elseif SIDEBAR_STATE.Position == "Top" then
				sidebar.Size, sidebar.Position = UDim2.new(1, 0, 0, MIN_SIDEBAR_WIDTH), UDim2.new(0, 0, 0, -MIN_SIDEBAR_WIDTH - 15)
			elseif SIDEBAR_STATE.Position == "Bottom" then
				sidebar.Size, sidebar.Position = UDim2.new(1, 0, 0, MIN_SIDEBAR_WIDTH), UDim2.new(0, 0, 1, 15)
			end
			sidebarVisuals.Size, sidebarVisuals.Position = sidebar.Size, sidebar.Position
		else
			sidebarBgImage.Visible = false
			local zUDim = UDim.new(0, 0)
			svCorner.CornerRadius, sbCorner.CornerRadius, sidebarCorner.CornerRadius = zUDim, UDim.new(0, ctx.MainRadius), zUDim
			sidebarBgCorner.CornerRadius = zUDim
			sidebar.Parent, sidebarVisuals.Parent = main, main
			sidebarOutlineStroke.Enabled = false

			if SIDEBAR_STATE.Position == "Left" then
				sidebar.Size, sidebar.Position = UDim2.new(0, effWidth, 1, 0), UDim2.new(0, 0, 0, 0)
				topbar.Size, topbar.Position = UDim2.new(1, -effWidth, 0, 60), UDim2.new(0, effWidth, 0, 0)
				pagesFolder.Size, pagesFolder.Position = UDim2.new(1, -effWidth, 1, -60), UDim2.new(0, effWidth, 0, 60)
				topbarDivider.Size, topbarDivider.Position = UDim2.new(1, -effWidth, 0, 1), UDim2.new(0, effWidth, 0, 60)
				sidebarResizer.Size, sidebarResizer.Position, sidebarResizer.AnchorPoint = UDim2.new(0, 12, 1, 0), UDim2.new(0, effWidth, 0, 0), Vector2.new(0.5, 0)
				resizerLine.Size, resizerLine.Position, resizerLine.AnchorPoint = UDim2.new(0, 1, 1, 0), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5)
			elseif SIDEBAR_STATE.Position == "Right" then
				sidebar.Size, sidebar.Position = UDim2.new(0, effWidth, 1, 0), UDim2.new(1, -effWidth, 0, 0)
				topbar.Size, topbar.Position = UDim2.new(1, -effWidth, 0, 60), UDim2.new(0, 0, 0, 0)
				pagesFolder.Size, pagesFolder.Position = UDim2.new(1, -effWidth, 1, -60), UDim2.new(0, 0, 0, 60)
				topbarDivider.Size, topbarDivider.Position = UDim2.new(1, -effWidth, 0, 1), UDim2.new(0, 0, 0, 60)
				sidebarResizer.Size, sidebarResizer.Position, sidebarResizer.AnchorPoint = UDim2.new(0, 12, 1, 0), UDim2.new(1, -effWidth, 0, 0), Vector2.new(0.5, 0)
				resizerLine.Size, resizerLine.Position, resizerLine.AnchorPoint = UDim2.new(0, 1, 1, 0), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5)
			elseif SIDEBAR_STATE.Position == "Top" then
				sidebar.Size, sidebar.Position = UDim2.new(1, 0, 0, MIN_SIDEBAR_WIDTH), UDim2.new(0, 0, 0, 0)
				topbar.Size, topbar.Position = UDim2.new(1, 0, 0, 60), UDim2.new(0, 0, 0, MIN_SIDEBAR_WIDTH)
				pagesFolder.Size, pagesFolder.Position = UDim2.new(1, 0, 1, -60 - MIN_SIDEBAR_WIDTH), UDim2.new(0, 0, 0, 60 + MIN_SIDEBAR_WIDTH)
				topbarDivider.Size, topbarDivider.Position = UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 60 + MIN_SIDEBAR_WIDTH)
				sidebarResizer.Size, sidebarResizer.Position, sidebarResizer.AnchorPoint = UDim2.new(1, 0, 0, 12), UDim2.new(0, 0, 0, MIN_SIDEBAR_WIDTH), Vector2.new(0, 0.5)
				resizerLine.Size, resizerLine.Position, resizerLine.AnchorPoint = UDim2.new(1, 0, 0, 1), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5)
			elseif SIDEBAR_STATE.Position == "Bottom" then
				sidebar.Size, sidebar.Position = UDim2.new(1, 0, 0, MIN_SIDEBAR_WIDTH), UDim2.new(0, 0, 1, -MIN_SIDEBAR_WIDTH)
				topbar.Size, topbar.Position = UDim2.new(1, 0, 0, 60), UDim2.new(0, 0, 0, 0)
				pagesFolder.Size, pagesFolder.Position = UDim2.new(1, 0, 1, -60 - MIN_SIDEBAR_WIDTH), UDim2.new(0, 0, 0, 60)
				topbarDivider.Size, topbarDivider.Position = UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 60)
				sidebarResizer.Size, sidebarResizer.Position, sidebarResizer.AnchorPoint = UDim2.new(1, 0, 0, 12), UDim2.new(0, 0, 1, -MIN_SIDEBAR_WIDTH), Vector2.new(0, 0.5)
				resizerLine.Size, resizerLine.Position, resizerLine.AnchorPoint = UDim2.new(1, 0, 0, 1), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5)
			end
			sidebarVisuals.Size, sidebarVisuals.Position = sidebar.Size, sidebar.Position
		end

		if isTopOrBottom then
			logoContainer.Size, logoContainer.Position = UDim2.new(0, 60, 1, 0), UDim2.new(0, 0, 0, 0)
			logoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			logoPadding.PaddingLeft = UDim.new(0, 15)
			settingsContainer.Visible = true
			settingsContainer.Position = UDim2.new(1, -120, 0, 0)
			tabList.Position, tabList.Size = UDim2.new(0, 60, 0, 0), UDim2.new(1, -120, 1, 0)
			tabListLayout.FillDirection = Enum.FillDirection.Horizontal
			tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			tabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			tabList.AutomaticCanvasSize = Enum.AutomaticSize.X
			if Window.SettingsTab and Window.SettingsTab.Button then
				Window.SettingsTab.Button.Parent = settingsContainer
				dividerContainer.Parent = settingsContainer
				dividerContainer.Size = UDim2.new(0, 16, 1, 0)
				divider.Size = UDim2.new(0, 1, 0.6, 0)
			end
		else
			logoContainer.Size, logoContainer.Position = UDim2.new(1, 0, 0, 60), UDim2.new(0, 0, 0, -2)
			logoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			logoPadding.PaddingLeft = UDim.new(0, 0)
			settingsContainer.Visible = false
			local hOff = (description and type(description) == "string") and -140 or -90
			if isCollapsed then
				tabList.Position, tabList.Size = UDim2.new(0, 0, 0, 75), UDim2.new(1, 0, 1, hOff)
			else
				tabList.Position, tabList.Size = UDim2.new(0, 10, 0, 75), UDim2.new(1, -20, 1, hOff)
			end
			tabListLayout.FillDirection = Enum.FillDirection.Vertical
			tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			tabListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
			tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
			if Window.SettingsTab and Window.SettingsTab.Button then
				Window.SettingsTab.Button.Parent = tabList
				dividerContainer.Parent = tabList
				dividerContainer.Size = UDim2.new(1, 0, 0, 16)
				divider.Size = UDim2.new(0.8, 0, 0, 1)
			end
		end

		if logoImage then
			logoImage.Visible = true
			if logoLabel then logoLabel.Visible = not isCollapsed end
		elseif logoLabel then
			logoLabel.Visible = true
			logoLabel.Text = isCollapsed and getFirstChar(title) or title
		end
		if descLabel then descLabel.Visible = not isCollapsed end
		if topbarDescLabel then topbarDescLabel.Visible = isCollapsed end

		local isCompact = (THEME.ElementStyle == 3 or THEME.ElementStyle == 4)
		local btnSizeList = isCompact and 30 or 38
		local iconSizeList = isCompact and 22 or 26
		local letterSizeList = isCompact and 16 or 18

		for _, tab in ipairs(Window.Tabs) do
			local hasIcon = (tab.Icon ~= nil)
			if isTopOrBottom or isCollapsed then
				tab.Button.Size = UDim2.new(0, 36, 0, 36)
				tab.Padding.PaddingLeft, tab.Padding.PaddingRight = UDim.new(0, 0), UDim.new(0, 0)
				tab.Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				tab.Label.Visible = false
				if hasIcon then
					tab.Icon.Visible = true
					tab.Icon.Size = UDim2.new(0, 30, 0, 30)
					if tab.LetterLabel then tab.LetterLabel.Visible = false end
				elseif tab.LetterLabel then
					tab.LetterLabel.Visible = true
					tab.LetterLabel.Size = UDim2.new(0, 30, 0, 30)
					tab.LetterLabel.TextSize = 24
				end
			else
				tab.Button.Size = UDim2.new(1, -4, 0, btnSizeList)
				local isCurrent = (Window.CurrentTab == tab)
				tab.Padding.PaddingLeft = isCurrent and UDim.new(0, 22) or UDim.new(0, 15)
				tab.Padding.PaddingRight = UDim.new(0, 15)
				tab.Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				tab.Label.Visible = true
				tab.Label.Text = tab.Name
				if hasIcon then tab.Icon.Visible = true; tab.Icon.Size = UDim2.new(0, iconSizeList, 0, iconSizeList) end
				if tab.LetterLabel then
					tab.LetterLabel.Visible = false
					tab.LetterLabel.Size = UDim2.new(0, iconSizeList, 0, iconSizeList)
					tab.LetterLabel.TextSize = letterSizeList
				end
			end
		end
	end

	function ctx.UpdateSidebarWidth(newWidth)
		ctx.CurrentSidebarWidth = math.clamp(newWidth, MIN_SIDEBAR_WIDTH, MAX_SIDEBAR_WIDTH)
		local bound = Window._themeControls["Layout & Styles~Sidebar Width"]
		if bound and bound.API:Save().Value ~= ctx.CurrentSidebarWidth then
			bound.API:Set(ctx.CurrentSidebarWidth)
		end
		ctx.FullUpdateLayout()
	end

	local resizingSidebar = false
	ctx.TrackConnection(sidebarResizer.InputBegan:Connect(function(input)
		if ctx.SIDEBAR_STATE.Position == "Top" or ctx.SIDEBAR_STATE.Position == "Bottom" then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizingSidebar = true
			local startX, startW = input.Position.X, ctx.CurrentSidebarWidth
			ctx.TweenTheme(resizerLine, "Accent", "BackgroundColor3", T_FAST)
			ctx.StartDrag(input.UserInputType, function(moveInput)
				local delta = moveInput.Position.X - startX
				if ctx.SIDEBAR_STATE.Position == "Right" then delta = -delta end
				ctx.UpdateSidebarWidth(startW + delta)
			end, function()
				resizingSidebar = false
				ctx.TweenTheme(resizerLine, "Outlines", "BackgroundColor3", T_FAST)
			end)
		end
	end))
	ctx.TrackConnection(sidebarResizer.MouseEnter:Connect(function()
		if ctx.SIDEBAR_STATE.Position ~= "Top" and ctx.SIDEBAR_STATE.Position ~= "Bottom" and not resizingSidebar then
			ctx.TweenTheme(resizerLine, "Accent", "BackgroundColor3", T_FAST)
		end
	end))
	ctx.TrackConnection(sidebarResizer.MouseLeave:Connect(function()
		if ctx.SIDEBAR_STATE.Position ~= "Top" and ctx.SIDEBAR_STATE.Position ~= "Bottom" and not resizingSidebar then
			ctx.TweenTheme(resizerLine, "Outlines", "BackgroundColor3", T_FAST)
		end
	end))

	local isDestroyed = false
	local currentActiveTween = nil
	local animInfo = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

	local function getAnimHideTransform(animType)
		if animType == 2 then return UDim2.new(0, 0, 0, -20), UDim2.fromScale(1, 1)
		elseif animType == 3 then return UDim2.new(0, 0, 0, 8), UDim2.fromScale(1, 1)
		elseif animType == 4 then return UDim2.new(0, 25, 0, 0), UDim2.fromScale(1, 1)
		else return UDim2.new(0, 0, 0, 20), UDim2.fromScale(1, 1) end
	end

	local function PlayFadeAnim(show)
		if currentActiveTween then currentActiveTween:Cancel(); currentActiveTween = nil end
		local hidePos, hideSize = getAnimHideTransform(THEME.CloseAnimation or 1)
		if show then
			wrapper.Visible = true
			contentWrapper.Position, contentWrapper.Size = hidePos, hideSize
			currentActiveTween = TS:Create(contentWrapper, animInfo, { Position = UDim2.new(0, 0, 0, 0), Size = UDim2.fromScale(1, 1) })
			currentActiveTween:Play()

			if THEME.MainOutlineEnabled then
				mainOutlineStroke.Enabled = true
				TS:Create(mainOutlineStroke, animInfo, { Transparency = 0 }):Play()
				if THEME.DoubleOutline and mainDoubleStroke then
					mainDoubleStroke.Enabled = true
					TS:Create(mainDoubleStroke, animInfo, { Transparency = 0 }):Play()
				end
				if ctx.SIDEBAR_STATE.Detached then
					sidebarOutlineStroke.Enabled = true
					TS:Create(sidebarOutlineStroke, animInfo, { Transparency = 0 }):Play()
					if THEME.DoubleOutline and sidebarDoubleStroke then
						sidebarDoubleStroke.Enabled = true
						TS:Create(sidebarDoubleStroke, animInfo, { Transparency = 0 }):Play()
					end
				end
			end
			TS:Create(arcOuterStroke, animInfo, { Transparency = 0 }):Play()
			TS:Create(topbarDivider, animInfo, { BackgroundTransparency = 0 }):Play()
			TS:Create(sidebarDivider, animInfo, { BackgroundTransparency = 0 }):Play()
		else
			Window.ClosePopup()
			currentActiveTween = TS:Create(contentWrapper, animInfo, { Position = hidePos, Size = hideSize })
			currentActiveTween:Play()

			TS:Create(mainOutlineStroke, animInfo, { Transparency = 1 }):Play()
			if mainDoubleStroke then TS:Create(mainDoubleStroke, animInfo, { Transparency = 1 }):Play() end
			if sidebarOutlineStroke.Enabled then TS:Create(sidebarOutlineStroke, animInfo, { Transparency = 1 }):Play() end
			if sidebarDoubleStroke and sidebarDoubleStroke.Enabled then TS:Create(sidebarDoubleStroke, animInfo, { Transparency = 1 }):Play() end
			TS:Create(arcOuterStroke, animInfo, { Transparency = 1 }):Play()
			TS:Create(topbarDivider, animInfo, { BackgroundTransparency = 1 }):Play()
			TS:Create(sidebarDivider, animInfo, { BackgroundTransparency = 1 }):Play()

			local animRef = currentActiveTween
			animRef.Completed:Once(function()
				if not ctx.IsUIOpen and currentActiveTween == animRef then
					wrapper.Visible = false
				end
			end)
		end
	end

	function ctx.ToggleUI()
		ctx.IsUIOpen = not ctx.IsUIOpen
		PlayFadeAnim(ctx.IsUIOpen)
	end

	ctx.TrackConnection(closeBtn.Activated:Connect(function()
		if isDestroyed then return end
		isDestroyed = true
		if Window.IsEditMode then CAS:UnbindAction("AxiomEditSink") end
		pcall(function() Window.ToggleEditMode(false) end)
		PlayFadeAnim(false)
		for _, conn in ipairs(Window._connections) do
			if conn.Connected then conn:Disconnect() end
		end
		table.clear(Window._connections)
		ctx.CleanupThemeSystem()
		task.delay(0.4, function()
			if ctx.EditBlur then pcall(function() ctx.EditBlur:Destroy() end) end
			pcall(function() screenGui:Destroy() end)
		end)
	end))

	ctx.TrackConnection(closeBtn.MouseEnter:Connect(function()
		TS:Create(crossLine1, T_FAST, { BackgroundColor3 = THEME.CloseBtn }):Play()
		TS:Create(crossLine2, T_FAST, { BackgroundColor3 = THEME.CloseBtn }):Play()
	end))
	ctx.TrackConnection(closeBtn.MouseLeave:Connect(function()
		ctx.TweenTheme(crossLine1, "TextMuted", "BackgroundColor3", T_FAST)
		ctx.TweenTheme(crossLine2, "TextMuted", "BackgroundColor3", T_FAST)
	end))

	if isMobile then
		local mtBtn = Instance.new("ImageButton")
		mtBtn.Size = UDim2.new(0, 40, 0, 40)
		mtBtn.AnchorPoint = Vector2.new(0.5, 0.5)
		mtBtn.Position = UDim2.new(0.5, 0, 0, 30)
		mtBtn.Image = (logoIconId and logoIconId ~= "") and logoIconId or SEARCH_ICON_ID
		mtBtn.ZIndex = 999999
		mtBtn.Parent = screenGui
		ctx.ApplyTheme(mtBtn, "Sidebar", "BackgroundColor3")
		local mtC = Instance.new("UICorner")
		mtC.CornerRadius = UDim.new(0, 10)
		mtC.Parent = mtBtn
		ctx.AttachStroke(mtBtn, "Always", "HUD")

		local mtMoved = false
		ctx.TrackConnection(mtBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				mtMoved = false
				local ds, sp = input.Position, mtBtn.Position
				ctx.StartDrag(input.UserInputType, function(mi)
					local d = mi.Position - ds
					if d.Magnitude > 5 then mtMoved = true end
					mtBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
				end)
			end
		end))
		ctx.TrackConnection(mtBtn.Activated:Connect(function()
			if not mtMoved then ctx.ToggleUI() end
		end))
	end

	function Window:CreateTab(tabConfig, legacyIcon, legacyIsSettings)
		local name, icon, isSettings
		if type(tabConfig) == "table" then
			name = tabConfig.Name or "Tab"
			icon = tabConfig.Icon
			isSettings = tabConfig.IsSettings or false
		else
			name = tostring(tabConfig or "Tab")
			icon = legacyIcon
			isSettings = legacyIsSettings or false
		end

		local tabData = { Name = name, IsSettings = isSettings }
		local iconAsset = parseAsset(icon)
		local hasIcon = (iconAsset and iconAsset ~= "")
		local isCollapsed = (ctx.CurrentSidebarWidth < 115)

		local tabButton = Instance.new("TextButton")
		tabButton.Name = "TabButton_" .. name
		tabButton.Size = isCollapsed and UDim2.new(0, 36, 0, 36) or UDim2.new(1, -4, 0, 38)
		tabButton.AutoButtonColor = false
		tabButton.Text = ""
		tabButton.BackgroundTransparency = 1
		tabButton.BorderSizePixel = 0
		tabButton.LayoutOrder = isSettings and 9999 or (#Window.Tabs + 1)
		tabButton.Parent = tabList

		local tabStroke = Instance.new("UIStroke")
		tabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		tabStroke.Thickness = 1
		tabStroke.Transparency = 1
		tabStroke.Parent = tabButton
		ctx.ApplyTheme(tabStroke, "Outlines", "Color")

		local tbC = Instance.new("UICorner")
		tbC.Parent = tabButton
		ctx.RegisterCorner(tbC, "Element")

		local tabBtnPadding = Instance.new("UIPadding")
		tabBtnPadding.PaddingLeft = isCollapsed and UDim.new(0, 0) or UDim.new(0, 15)
		tabBtnPadding.PaddingRight = isCollapsed and UDim.new(0, 0) or UDim.new(0, 15)
		tabBtnPadding.Parent = tabButton

		local tabLayout = Instance.new("UIListLayout")
		tabLayout.FillDirection = Enum.FillDirection.Horizontal
		tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		tabLayout.HorizontalAlignment = isCollapsed and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left
		tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabLayout.Padding = UDim.new(0, 10)
		tabLayout.Parent = tabButton

		local tabIconLabel, tabLetterLabel
		if hasIcon then
			tabIconLabel = Instance.new("ImageLabel")
			tabIconLabel.Size = isCollapsed and UDim2.new(0, 30, 0, 30) or UDim2.new(0, 26, 0, 26)
			tabIconLabel.BackgroundTransparency = 1
			tabIconLabel.Image = iconAsset
			tabIconLabel.LayoutOrder = 1
			tabIconLabel.Parent = tabButton
			ctx.ApplyTheme(tabIconLabel, "TextMuted", "ImageColor3")
		else
			tabLetterLabel = Instance.new("TextLabel")
			tabLetterLabel.Size = isCollapsed and UDim2.new(0, 30, 0, 30) or UDim2.new(0, 26, 0, 26)
			tabLetterLabel.BackgroundTransparency = 1
			tabLetterLabel.TextSize = isCollapsed and 24 or 18
			tabLetterLabel.Text = getFirstChar(name)
			tabLetterLabel.LayoutOrder = 1
			tabLetterLabel.Visible = isCollapsed
			tabLetterLabel.Parent = tabButton
			ctx.ApplyTheme(tabLetterLabel, "TextMuted", "TextColor3")
			ctx.ApplyTheme(tabLetterLabel, "TextFont", "Font")
		end

		local tabBtnTitle = Instance.new("TextLabel")
		tabBtnTitle.AutomaticSize = Enum.AutomaticSize.X
		tabBtnTitle.Size = UDim2.new(0, 0, 1, 0)
		tabBtnTitle.BackgroundTransparency = 1
		tabBtnTitle.TextSize = 13
		tabBtnTitle.TextXAlignment = Enum.TextXAlignment.Left
		tabBtnTitle.Text = name
		tabBtnTitle.TextTruncate = Enum.TextTruncate.AtEnd
		tabBtnTitle.Visible = not isCollapsed
		tabBtnTitle.LayoutOrder = 2
		tabBtnTitle.Parent = tabButton
		ctx.ApplyTheme(tabBtnTitle, "TextMuted", "TextColor3")
		ctx.ApplyTheme(tabBtnTitle, "TextFont", "Font")

		local page = Instance.new("Frame")
		page.Name = "Page_" .. name
		page.Size = UDim2.fromScale(1, 1)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.Parent = pagesFolder

		local pageContent = Instance.new("ScrollingFrame")
		pageContent.Size = UDim2.fromScale(1, 1)
		pageContent.BackgroundTransparency = 1
		pageContent.ScrollBarThickness = 0
		pageContent.CanvasSize = UDim2.new(0, 0, 0, 0)
		pageContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
		pageContent.Parent = page

		local pagePadding = Instance.new("UIPadding")
		pagePadding.PaddingTop, pagePadding.PaddingBottom, pagePadding.PaddingLeft, pagePadding.PaddingRight = UDim.new(0, 14), UDim.new(0, 14), UDim.new(0, 14), UDim.new(0, 14)
		pagePadding.Parent = pageContent

		local columnsLayout = Instance.new("UIListLayout")
		columnsLayout.FillDirection = Enum.FillDirection.Horizontal
		columnsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		columnsLayout.Padding = UDim.new(0, 14)
		columnsLayout.Parent = pageContent

		local leftColumn = Instance.new("Frame")
		leftColumn.Size = UDim2.new(0.5, -7, 0, 0)
		leftColumn.AutomaticSize = Enum.AutomaticSize.Y
		leftColumn.BackgroundTransparency = 1
		leftColumn.Parent = pageContent
		local leftColLayout = Instance.new("UIListLayout")
		leftColLayout.SortOrder = Enum.SortOrder.LayoutOrder
		leftColLayout.Padding = UDim.new(0, 14)
		leftColLayout.Parent = leftColumn

		local rightColumn = Instance.new("Frame")
		rightColumn.Size = UDim2.new(0.5, -7, 0, 0)
		rightColumn.AutomaticSize = Enum.AutomaticSize.Y
		rightColumn.BackgroundTransparency = 1
		rightColumn.Parent = pageContent
		local rightColLayout = Instance.new("UIListLayout")
		rightColLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rightColLayout.Padding = UDim.new(0, 14)
		rightColLayout.Parent = rightColumn

		local function updateTabStyle(style)
			local compact = (style == 3 or style == 4)
			local pad = compact and 8 or 14
			local off = compact and -4 or -7
			leftColumn.Size, rightColumn.Size = UDim2.new(0.5, off, 0, 0), UDim2.new(0.5, off, 0, 0)
			pagePadding.PaddingTop, pagePadding.PaddingBottom, pagePadding.PaddingLeft, pagePadding.PaddingRight = UDim.new(0, pad), UDim.new(0, pad), UDim.new(0, pad), UDim.new(0, pad)
			columnsLayout.Padding, leftColLayout.Padding, rightColLayout.Padding = UDim.new(0, pad), UDim.new(0, pad), UDim.new(0, pad)
		end
		table.insert(Window._styleCallbacks, updateTabStyle)
		updateTabStyle(THEME.ElementStyle)

		tabData.Button, tabData.Stroke, tabData.Label = tabButton, tabStroke, tabBtnTitle
		tabData.Icon, tabData.LetterLabel, tabData.Page = tabIconLabel, tabLetterLabel, page
		tabData.Padding, tabData.Layout = tabBtnPadding, tabLayout

		function tabData:SetTitle(newTitle)
			tabBtnTitle.Text = newTitle
			if tabLetterLabel then tabLetterLabel.Text = getFirstChar(newTitle) end
		end

		local function activateTab()
			if Window.CurrentTab == tabData then return end
			if searchInput and searchInput.Text ~= "" then searchInput.Text = "" end

			local prevTab = Window.CurrentTab
			Window.CurrentTab = tabData
			local isTopOrBottom = (ctx.SIDEBAR_STATE.Position == "Top" or ctx.SIDEBAR_STATE.Position == "Bottom")
			local collapsedNow = (ctx.CurrentSidebarWidth < 115) or isTopOrBottom

			if prevTab then
				TS:Create(prevTab.Stroke, T_SMOOTH, { Transparency = 1 }):Play()
				ctx.TweenTheme(prevTab.Stroke, "Outlines", "Color", T_SMOOTH)
				ctx.TweenTheme(prevTab.Label, "TextMuted", "TextColor3", T_MED)
				if prevTab.Icon then ctx.TweenTheme(prevTab.Icon, "TextMuted", "ImageColor3", T_MED) end
				if prevTab.LetterLabel then ctx.TweenTheme(prevTab.LetterLabel, "TextMuted", "TextColor3", T_MED) end
				TS:Create(prevTab.Padding, T_SMOOTH, { PaddingLeft = UDim.new(0, collapsedNow and 0 or 15) }):Play()
				prevTab.Page.Visible = false
			end

			TS:Create(tabStroke, T_SMOOTH, { Transparency = 0 }):Play()
			ctx.TweenTheme(tabStroke, "Accent", "Color", T_SMOOTH)
			ctx.TweenTheme(tabBtnTitle, "Text", "TextColor3", T_MED)
			if tabIconLabel then ctx.TweenTheme(tabIconLabel, "Accent", "ImageColor3", T_MED) end
			if tabLetterLabel then ctx.TweenTheme(tabLetterLabel, "Accent", "TextColor3", T_MED) end
			TS:Create(tabBtnPadding, T_SMOOTH, { PaddingLeft = UDim.new(0, collapsedNow and 0 or 22) }):Play()

			page.Position = UDim2.new(0, 0, 0, 12)
			page.Visible = true
			TS:Create(page, T_MED, { Position = UDim2.new(0, 0, 0, 0) }):Play()
		end

		ctx.TrackConnection(tabButton.MouseEnter:Connect(function()
			if Window.CurrentTab ~= tabData then
				ctx.TweenTheme(tabBtnTitle, "Text", "TextColor3", T_FAST)
			end
		end))
		ctx.TrackConnection(tabButton.MouseLeave:Connect(function()
			if Window.CurrentTab ~= tabData then
				ctx.TweenTheme(tabBtnTitle, "TextMuted", "TextColor3", T_FAST)
			end
		end))
		ctx.TrackConnection(tabButton.MouseButton1Click:Connect(activateTab))

		function tabData:CreateBlock(blockConfig, overrideParent)
			local bName = blockConfig.Name or "Block"
			local bSide = blockConfig.Side or "Left"
			local bIcon = parseAsset(blockConfig.Icon)
			local variants = blockConfig.Variants
			local originalParent = overrideParent or ((bSide == "Right") and rightColumn or leftColumn)

			local blockKey = bName
			if variants and type(variants) == "table" and #variants > 0 then
				local parts = {}
				for _, vd in ipairs(variants) do table.insert(parts, tostring(vd.Name or "Tab")) end
				blockKey = table.concat(parts, "|")
			end
			local blockId = name .. "~" .. blockKey

			local blockAnchor = Instance.new("Frame")
			blockAnchor.Size = UDim2.new(1, 0, 0, 0)
			blockAnchor.AutomaticSize = Enum.AutomaticSize.Y
			blockAnchor.BackgroundTransparency = 1
			blockAnchor.Parent = originalParent

			local dummyCard = Instance.new("Frame")
			dummyCard.Size = UDim2.new(1, 0, 0, 38)
			dummyCard.Visible = false
			dummyCard.Parent = blockAnchor
			ctx.ApplyTheme(dummyCard, "Card", "BackgroundColor3")
			ctx.ApplyTheme(dummyCard, "CardTrans", "BackgroundTransparency")
			local dcC = Instance.new("UICorner")
			dcC.Parent = dummyCard
			ctx.RegisterCorner(dcC, "Element")
			ctx.AttachStroke(dummyCard, "Block", "Element")

			local dummyTitle = Instance.new("TextLabel")
			dummyTitle.Size = UDim2.new(1, -40, 1, 0)
			dummyTitle.Position = UDim2.new(0, 16, 0, 0)
			dummyTitle.BackgroundTransparency = 1
			dummyTitle.Text = bName
			dummyTitle.TextSize = 13
			dummyTitle.TextXAlignment = Enum.TextXAlignment.Left
			dummyTitle.Parent = dummyCard
			ctx.ApplyTheme(dummyTitle, "TextMuted", "TextColor3")
			ctx.ApplyTheme(dummyTitle, "TextFont", "Font")

			local dummyReturnBtn = Instance.new("ImageButton")
			dummyReturnBtn.Size = UDim2.new(0, 24, 0, 24)
			dummyReturnBtn.AnchorPoint = Vector2.new(1, 0.5)
			dummyReturnBtn.Position = UDim2.new(1, -12, 0.5, 0)
			dummyReturnBtn.BackgroundTransparency = 1
			dummyReturnBtn.Image = "rbxassetid://10709790948"
			dummyReturnBtn.Rotation = 90
			dummyReturnBtn.Parent = dummyCard
			ctx.ApplyTheme(dummyReturnBtn, "TextMuted", "ImageColor3")

			local blockContainer = Instance.new("Frame")
			blockContainer.Name = bName .. "_Block"
			blockContainer.Size = UDim2.new(1, 0, 0, 40)
			blockContainer.ZIndex = 100
			blockContainer.Active = true
			blockContainer.Parent = blockAnchor
			ctx.ApplyTheme(blockContainer, "Card", "BackgroundColor3")
			ctx.ApplyTheme(blockContainer, "CardTrans", "BackgroundTransparency")
			local bcC = Instance.new("UICorner")
			bcC.Parent = blockContainer
			ctx.RegisterCorner(bcC, "Element")
			local blockStroke = ctx.AttachStroke(blockContainer, "Block", "Element")

			local blockInner = Instance.new("Frame")
			blockInner.Name = "BlockInner"
			blockInner.Size = UDim2.new(1, 0, 0, 0)
			blockInner.AutomaticSize = Enum.AutomaticSize.Y
			blockInner.BackgroundTransparency = 1
			blockInner.ZIndex = 101
			blockInner.Parent = blockContainer

			local blockPadding = Instance.new("UIPadding")
			blockPadding.PaddingTop, blockPadding.PaddingBottom, blockPadding.PaddingLeft, blockPadding.PaddingRight = UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12), UDim.new(0, 12)
			blockPadding.Parent = blockInner

			local blockLayout = Instance.new("UIListLayout")
			blockLayout.FillDirection = Enum.FillDirection.Vertical
			blockLayout.SortOrder = Enum.SortOrder.LayoutOrder
			blockLayout.Padding = UDim.new(0, 6)
			blockLayout.Parent = blockInner

			local detachBtn = Instance.new("ImageButton")
			detachBtn.Size = UDim2.new(0, 24, 0, 24)
			detachBtn.AnchorPoint = Vector2.new(1, 0.5)
			detachBtn.Position = UDim2.new(1, 0, 0.5, 0)
			detachBtn.BackgroundTransparency = 1
			detachBtn.Image = "rbxassetid://10709790948"
			detachBtn.Rotation = -90
			ctx.ApplyTheme(detachBtn, "Text", "ImageColor3")

			local isDetached = false

			local function syncBlockSize()
				if not blockInner.Parent then return end
				local h = math.max(30, blockInner.AbsoluteSize.Y)
				if isDetached then
					blockContainer.Size = UDim2.new(0, blockContainer.Size.X.Offset, 0, h)
				else
					blockContainer.Size = UDim2.new(1, 0, 0, h)
				end
			end
			ctx.TrackConnection(blockInner:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncBlockSize))
			task.defer(syncBlockSize)

			local function syncDetachedStroke()
				if isDetached then
					blockStroke.Enabled = THEME.MainOutlineEnabled or (THEME.InternalOutlines == "Only Blocks" or THEME.InternalOutlines == "All")
				else
					blockStroke.Enabled = (THEME.InternalOutlines == "Only Blocks" or THEME.InternalOutlines == "All")
				end
			end

			local function setDetachedState(targetState, customPos)
				if isDetached == targetState then
					if isDetached and customPos then
						blockContainer.Position = customPos
					end
					return
				end
				isDetached = targetState
				blockContainer:SetAttribute("IsDetached", isDetached)

				if isDetached then
					local absPos = blockContainer.AbsolutePosition
					local absW = blockContainer.AbsoluteSize.X
					if absW < 40 then
						absW = math.max(200, math.floor((wrapper.Size.X.Offset - ctx.CurrentSidebarWidth - 42) / 2))
					end
					blockContainer.Size = UDim2.new(0, absW, 0, math.max(40, blockInner.AbsoluteSize.Y))
					blockContainer.Position = customPos or UDim2.new(0, absPos.X, 0, absPos.Y + 15)
					blockContainer.Parent = screenGui

					ctx.ApplyTheme(blockContainer, "Background", "BackgroundColor3")
					ctx.ApplyTheme(blockContainer, "HUDTransparency", "BackgroundTransparency")
					syncDetachedStroke()
					dummyCard.Visible = true
					ctx.TweenTheme(detachBtn, "TextMuted", "ImageColor3", T_FAST)
					TS:Create(detachBtn, T_FAST, { Rotation = 90 }):Play()
				else
					blockContainer.Size = UDim2.new(1, 0, 0, math.max(40, blockInner.AbsoluteSize.Y))
					blockContainer.Position = UDim2.new(0, 0, 0, 0)
					blockContainer.Parent = blockAnchor
					ctx.ApplyTheme(blockContainer, "Card", "BackgroundColor3")
					ctx.ApplyTheme(blockContainer, "CardTrans", "BackgroundTransparency")
					syncDetachedStroke()
					dummyCard.Visible = false
					ctx.TweenTheme(detachBtn, "Text", "ImageColor3", T_FAST)
					TS:Create(detachBtn, T_FAST, { Rotation = -90 }):Play()
				end
			end

			local function attachDragTrigger(trigger)
				ctx.TrackConnection(trigger.InputBegan:Connect(function(input)
					if not isDetached then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						local dragStart, startPos = input.Position, blockContainer.Position
						ctx.StartDrag(input.UserInputType, function(moveInput)
							local delta = moveInput.Position - dragStart
							blockContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
						end)
					end
				end))
			end

			ctx.TrackConnection(detachBtn.MouseButton1Click:Connect(function() setDetachedState(not isDetached) end))
			ctx.TrackConnection(dummyReturnBtn.MouseButton1Click:Connect(function() setDetachedState(false) end))

			if not isSettings then
				Window._detachedBlocks[blockId] = {
					GetState = function()
						local p = blockContainer.Position
						return {
							Detached = isDetached,
							Position = isDetached and { p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset } or nil
						}
					end,
					SetState = function(st)
						if type(st) == "table" and st.Detached then
							local pos = (type(st.Position) == "table" and #st.Position == 4) and UDim2.new(st.Position[1], st.Position[2], st.Position[3], st.Position[4]) or nil
							setDetachedState(true, pos)
						else
							setDetachedState(false)
						end
					end,
					SyncStroke = syncDetachedStroke
				}
			end

			if variants and type(variants) == "table" and #variants > 1 then
				local headerWrapper = Instance.new("Frame")
				headerWrapper.Size = UDim2.new(1, 0, 0, 26)
				headerWrapper.BackgroundTransparency = 1
				headerWrapper.LayoutOrder = 0
				headerWrapper.Parent = blockInner
				attachDragTrigger(headerWrapper)
				detachBtn.Parent = headerWrapper

				local tabsContainer = Instance.new("Frame")
				tabsContainer.Size = UDim2.new(1, -32, 1, 0)
				tabsContainer.BackgroundTransparency = 1
				tabsContainer.Parent = headerWrapper

				local gap = 4
				local totalGaps = gap * (#variants - 1)
				local hl = Instance.new("UIListLayout")
				hl.FillDirection = Enum.FillDirection.Horizontal
				hl.SortOrder = Enum.SortOrder.LayoutOrder
				hl.Padding = UDim.new(0, gap)
				hl.Parent = tabsContainer

				local blockDivider = Instance.new("Frame")
				blockDivider.Size = UDim2.new(1, 0, 0, 1)
				blockDivider.BorderSizePixel = 0
				blockDivider.LayoutOrder = 1
				blockDivider.Parent = blockInner
				ctx.ApplyTheme(blockDivider, "Outlines", "BackgroundColor3")

				local activeIndex = 1
				local contentContainers, apis, tabs = {}, {}, {}

				local function updateVariantTabTexts()
					for _, tData in ipairs(tabs) do
						local maxW = tData.Btn.AbsoluteSize.X - (tData.HasIcon and 24 or 8) - 14
						local font = Enum.Font[THEME.TextFont] or Enum.Font.Gotham
						tData.Label.Text = truncateTwoDots(tData.RawName, font, tData.Label.TextSize, math.max(0, maxW))
					end
				end

				for i, vData in ipairs(variants) do
					local vName = vData.Name or ("Tab " .. i)
					local vIcon = parseAsset(vData.Icon)

					local tabBtn = Instance.new("TextButton")
					tabBtn.Size = UDim2.new(1 / #variants, -(totalGaps / #variants), 1, 0)
					tabBtn.BackgroundTransparency = 1
					tabBtn.AutoButtonColor = false
					tabBtn.Text = ""
					tabBtn.LayoutOrder = i
					tabBtn.Parent = tabsContainer
					attachDragTrigger(tabBtn)

					local tbC2 = Instance.new("UICorner")
					tbC2.Parent = tabBtn
					ctx.RegisterCorner(tbC2, "Element")

					local tStroke = Instance.new("UIStroke")
					tStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					tStroke.Thickness = 1
					tStroke.Transparency = (i == 1) and 0 or 1
					tStroke.Parent = tabBtn
					ctx.ApplyTheme(tStroke, "Outlines", "Color")

					local tPad = Instance.new("UIPadding")
					tPad.PaddingLeft, tPad.PaddingRight = UDim.new(0, 6), UDim.new(0, 6)
					tPad.Parent = tabBtn

					local bl = Instance.new("UIListLayout")
					bl.FillDirection = Enum.FillDirection.Horizontal
					bl.HorizontalAlignment = Enum.HorizontalAlignment.Center
					bl.VerticalAlignment = Enum.VerticalAlignment.Center
					bl.SortOrder = Enum.SortOrder.LayoutOrder
					bl.Padding = UDim.new(0, 6)
					bl.Parent = tabBtn

					local tIcon
					if vIcon and vIcon ~= "" then
						tIcon = Instance.new("ImageLabel")
						tIcon.Size = UDim2.new(0, 16, 0, 16)
						tIcon.BackgroundTransparency = 1
						tIcon.Image = vIcon
						tIcon.Parent = tabBtn
						ctx.ApplyTheme(tIcon, i == 1 and "Text" or "TextMuted", "ImageColor3")
					end

					local tLabel = Instance.new("TextLabel")
					tLabel.AutomaticSize = Enum.AutomaticSize.X
					tLabel.Size = UDim2.new(0, 0, 1, 0)
					tLabel.BackgroundTransparency = 1
					tLabel.TextSize = 12
					tLabel.TextTruncate = Enum.TextTruncate.AtEnd
					tLabel.Text = vName
					tLabel.Parent = tabBtn
					ctx.ApplyTheme(tLabel, i == 1 and "Text" or "TextMuted", "TextColor3")
					ctx.ApplyTheme(tLabel, i == 1 and "TextFont" or "SubtextFont", "Font")

					tabs[i] = { Btn = tabBtn, Stroke = tStroke, Label = tLabel, Icon = tIcon, RawName = vName, HasIcon = (vIcon and vIcon ~= "") }

					local contentFrame = Instance.new("Frame")
					contentFrame.Size = UDim2.new(1, 0, 0, 0)
					contentFrame.AutomaticSize = Enum.AutomaticSize.Y
					contentFrame.BackgroundTransparency = 1
					contentFrame.Visible = (i == 1)
					contentFrame.LayoutOrder = 2
					contentFrame.Parent = blockInner
					contentContainers[i] = contentFrame

					local cLayout = Instance.new("UIListLayout")
					cLayout.FillDirection = Enum.FillDirection.Vertical
					cLayout.SortOrder = Enum.SortOrder.LayoutOrder
					cLayout.Padding = UDim.new(0, 6)
					cLayout.Parent = contentFrame
					local cPad = Instance.new("UIPadding")
					cPad.PaddingTop = UDim.new(0, 6)
					cPad.Parent = contentFrame

					ctx.TrackConnection(tabBtn.MouseButton1Click:Connect(function()
						if activeIndex == i then return end
						local oldTab = tabs[activeIndex]
						if oldTab then
							TS:Create(oldTab.Stroke, T_MED, { Transparency = 1 }):Play()
							if oldTab.Icon then ctx.TweenTheme(oldTab.Icon, "TextMuted", "ImageColor3", T_FAST) end
							ctx.TweenTheme(oldTab.Label, "TextMuted", "TextColor3", T_FAST)
							ctx.ApplyTheme(oldTab.Label, "SubtextFont", "Font")
						end
						contentContainers[activeIndex].Visible = false

						activeIndex = i
						local newTab = tabs[i]
						if newTab then
							TS:Create(newTab.Stroke, T_MED, { Transparency = 0 }):Play()
							if newTab.Icon then ctx.TweenTheme(newTab.Icon, "Text", "ImageColor3", T_FAST) end
							ctx.TweenTheme(newTab.Label, "Text", "TextColor3", T_FAST)
							ctx.ApplyTheme(newTab.Label, "TextFont", "Font")
						end
						local targetFrame = contentContainers[activeIndex]
						targetFrame.Position = UDim2.new(0, 0, 0, 6)
						targetFrame.Visible = true
						TS:Create(targetFrame, T_MED, { Position = UDim2.new(0, 0, 0, 0) }):Play()
						task.defer(syncBlockSize)
					end))

					local bObj = buildElementAPI(ctx, contentFrame, vName, vIcon, bSide, name, tabData.IsSettings)
					function bObj:SetTitle(newTitle) tabs[i].RawName = newTitle; updateVariantTabTexts() end
					apis[i] = bObj
				end

				ctx.TrackConnection(tabsContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateVariantTabTexts))
				task.defer(updateVariantTabTexts)

				local function updateBlockStyle(style)
					updateVariantTabTexts()
					local compact = (style == 3 or style == 4)
					local p = compact and 8 or 12
					blockPadding.PaddingTop, blockPadding.PaddingBottom, blockPadding.PaddingLeft, blockPadding.PaddingRight = UDim.new(0, p), UDim.new(0, p), UDim.new(0, p), UDim.new(0, p)
					blockLayout.Padding = UDim.new(0, compact and 4 or 6)
					headerWrapper.Size = UDim2.new(1, 0, 0, compact and 22 or 26)
					dummyCard.Size = UDim2.new(1, 0, 0, compact and 30 or 38)
					dummyTitle.TextSize = compact and 12 or 13
					for _, c in pairs(contentContainers) do
						c.UIListLayout.Padding = UDim.new(0, compact and 4 or 6)
						c.UIPadding.PaddingTop = UDim.new(0, compact and 4 or 6)
					end
					task.defer(syncBlockSize)
				end
				table.insert(Window._styleCallbacks, updateBlockStyle)
				updateBlockStyle(THEME.ElementStyle)
				return unpack(apis)
			else
				local header = Instance.new("Frame")
				header.Size = UDim2.new(1, 0, 0, 20)
				header.BackgroundTransparency = 1
				header.LayoutOrder = 0
				header.Parent = blockInner
				attachDragTrigger(header)
				detachBtn.Parent = header

				local titleContainer = Instance.new("Frame")
				titleContainer.Size = UDim2.new(1, -22, 1, 0)
				titleContainer.BackgroundTransparency = 1
				titleContainer.Parent = header

				local hl = Instance.new("UIListLayout")
				hl.FillDirection = Enum.FillDirection.Horizontal
				hl.VerticalAlignment = Enum.VerticalAlignment.Center
				hl.SortOrder = Enum.SortOrder.LayoutOrder
				hl.Padding = UDim.new(0, 8)
				hl.Parent = titleContainer

				local blockIconLabel
				if bIcon and bIcon ~= "" then
					blockIconLabel = Instance.new("ImageLabel")
					blockIconLabel.Size = UDim2.new(0, 26, 0, 26)
					blockIconLabel.BackgroundTransparency = 1
					blockIconLabel.Image = bIcon
					blockIconLabel.Parent = titleContainer
					ctx.ApplyTheme(blockIconLabel, "Text", "ImageColor3")
				end

				local blockTitle = Instance.new("TextLabel")
				blockTitle.AutomaticSize = Enum.AutomaticSize.X
				blockTitle.Size = UDim2.new(0, 0, 1, 0)
				blockTitle.BackgroundTransparency = 1
				blockTitle.TextSize = 13
				blockTitle.TextTruncate = Enum.TextTruncate.AtEnd
				blockTitle.Text = bName
				blockTitle.Parent = titleContainer
				ctx.ApplyTheme(blockTitle, "Text", "TextColor3")
				ctx.ApplyTheme(blockTitle, "TextFont", "Font")

				local blockDivider = Instance.new("Frame")
				blockDivider.Size = UDim2.new(1, 0, 0, 1)
				blockDivider.BorderSizePixel = 0
				blockDivider.LayoutOrder = 1
				blockDivider.Parent = blockInner
				ctx.ApplyTheme(blockDivider, "Outlines", "BackgroundColor3")

				local function updateBlockStyle(style)
					local compact = (style == 3 or style == 4)
					local p = compact and 8 or 12
					blockPadding.PaddingTop, blockPadding.PaddingBottom, blockPadding.PaddingLeft, blockPadding.PaddingRight = UDim.new(0, p), UDim.new(0, p), UDim.new(0, p), UDim.new(0, p)
					blockLayout.Padding = UDim.new(0, compact and 4 or 6)
					header.Size = UDim2.new(1, 0, 0, compact and 22 or 26)
					dummyCard.Size = UDim2.new(1, 0, 0, compact and 30 or 38)
					dummyTitle.TextSize = compact and 12 or 13
					if blockIconLabel then
						local s = compact and 22 or 26
						blockIconLabel.Size = UDim2.new(0, s, 0, s)
					end
					task.defer(syncBlockSize)
				end
				table.insert(Window._styleCallbacks, updateBlockStyle)
				updateBlockStyle(THEME.ElementStyle)

				local bObj = buildElementAPI(ctx, blockInner, bName, bIcon, bSide, name, tabData.IsSettings)
				function bObj:SetTitle(newTitle) blockTitle.Text = newTitle end
				return bObj
			end
		end

		if not isSettings and not Window.CurrentTab then task.spawn(activateTab) end
		table.insert(Window.Tabs, tabData)
		ctx.FullUpdateLayout()
		return tabData
	end

	ctx.WatermarkHolder = createWatermarkSystem(ctx, initFlags.Watermark, logoIconId)
	createKeybindsHUD(ctx, initFlags.Keybinds)
	createEditModeSystem(ctx)

	ctx.OnMainOutlineChanged = function(enabled)
		mainOutlineStroke.Enabled = enabled
		mainOutlineStroke.Transparency = 0
		sidebarOutlineStroke.Enabled = (enabled and ctx.SIDEBAR_STATE.Detached)
		sidebarOutlineStroke.Transparency = 0
		for _, b in pairs(Window._detachedBlocks) do
			if b.SyncStroke then b.SyncStroke() end
		end
	end

	function ctx.CaptureLayoutState()
		local detached = {}
		for id, entry in pairs(Window._detachedBlocks) do
			detached[id] = entry.GetState()
		end
		return {
			WindowSize = { wrapper.Size.X.Scale, wrapper.Size.X.Offset, wrapper.Size.Y.Scale, wrapper.Size.Y.Offset },
			WindowPos = { targetPos.X.Scale, targetPos.X.Offset, targetPos.Y.Scale, targetPos.Y.Offset },
			WatermarkPos = ctx.GetWatermarkPos(),
			DetachedBlocks = detached
		}
	end

	function ctx.ApplyLayoutState(st)
		if type(st) ~= "table" then return end
		if type(st.WindowSize) == "table" and #st.WindowSize == 4 then
			local sw, sh = screenGui.AbsoluteSize.X, screenGui.AbsoluteSize.Y
			local minW, minH = isMobile and 350 or 500, isMobile and 250 or 350
			local maxW = math.max(minW, (sw / uiScaleValue) - 40)
			local maxH = math.max(minH, (sh / uiScaleValue) - 40)
			wrapper.Size = UDim2.new(st.WindowSize[1], math.clamp(st.WindowSize[2], minW, maxW), st.WindowSize[3], math.clamp(st.WindowSize[4], minH, maxH))
		end
		if type(st.WindowPos) == "table" and #st.WindowPos == 4 then
			targetPos = UDim2.new(st.WindowPos[1], st.WindowPos[2], st.WindowPos[3], st.WindowPos[4])
			wrapper.Position = targetPos
		end
		if st.WatermarkPos then
			ctx.SetWatermarkPos(st.WatermarkPos)
		end
		if type(st.DetachedBlocks) == "table" then
			for id, entry in pairs(Window._detachedBlocks) do
				entry.SetState(st.DetachedBlocks[id])
			end
		end
		if ctx.PositionEditorNearGUI then ctx.PositionEditorNearGUI() end
	end

	Window.SettingsTab = Window:CreateTab({ Name = "UI Settings", Icon = SETTINGS_ICON_ID, IsSettings = true })
	populateSettingsTab(ctx)

	function Window:SetOpenKeybind(key)
		local resolved = resolveKeycode(key)
		if not resolved then return false end
		ctx.OpenKeybind = resolved
		local control = self._themeControls["Layout & Styles~Open GUI Keybind"]
		if control then control.API:SetKeybind(resolved) end
		return true
	end

	function Window:GetOpenKeybind()
		return ctx.OpenKeybind
	end

	local controlBindings = {
		Accent = { "Colors~Accent Color", "Colorpicker" },
		Background = { "Colors~Background", "Colorpicker" },
		Sidebar = { "Colors~Sidebar", "Colorpicker" },
		Card = { "Colors~Cards & Panels", "Colorpicker" },
		Element = { "Colors~Elements", "Colorpicker" },
		Input = { "Colors~Inputs & Highlights", "Colorpicker" },
		Outlines = { "Colors~Outlines & Borders", "Colorpicker" },
		Text = { "Colors~Main Text", "Colorpicker" },
		TextMuted = { "Colors~Subtext", "Colorpicker" },
		BackgroundTrans = { "Transparency~Background", "Percent" },
		HUDTransparency = { "Transparency~HUD", "Percent" },
		BgImageTrans = { "Transparency~Bg Image", "Percent" },
		CardTrans = { "Transparency~Cards & Panels", "Percent" },
		ElementTrans = { "Transparency~Elements", "Percent" },
		InputTrans = { "Transparency~Inputs", "Percent" },
		BackgroundImage = { "Fonts & Extras~Bg Image ID", "Text" },
		TextFont = { "Fonts & Extras~Primary Font", "Dropdown" },
		SubtextFont = { "Fonts & Extras~Subtext Font", "Dropdown" },
		MainOutlineEnabled = { "Layout & Styles~Main GUI Outline", "Toggle" },
		DoubleOutline = { "Layout & Styles~Double Outline", "Toggle" },
		InternalOutlines = { "Layout & Styles~Internal Outlines", "Dropdown" },
		ElementStyle = { "Layout & Styles~GUI Style", "Style" },
		CloseAnimation = { "Layout & Styles~Close Animation", "Animation" },
		ShowWatermark = { "Layout & Styles~Show Watermark", "Toggle" },
		ShowKeybindsHUD = { "Layout & Styles~Show Keybinds HUD", "Toggle" },
		TopbarAlign = { "Layout & Styles~Topbar Elements Pos", "Dropdown" },
		ShowSearchBar = { "Layout & Styles~Show Search Bar", "Toggle" },
		ShowProfile = { "Layout & Styles~Show Profile", "Toggle" },
		SidebarWidth = { "Layout & Styles~Sidebar Width", "Slider" },
		CornerRadius = { "Layout & Styles~Main Corner Radius", "Slider" },
		ElementsCornerRadius = { "Layout & Styles~Elements Corner Radius", "Slider" },
		HUDCornerRadius = { "Layout & Styles~HUD Corner Radius", "Slider" },
		SidebarPosition = { "Layout & Styles~Sidebar Position", "Dropdown" },
		DetachedSidebar = { "Layout & Styles~Detached Sidebar", "Toggle" },
		TogglePosition = { "Layout & Styles~Toggle Checkbox Pos", "Dropdown" }
	}

	function Window:SetThemeOption(key, value)
		if key == "OpenKeybind" then return self:SetOpenKeybind(value) end
		if key == "DropShadows" then return true end
		local binding = controlBindings[key]
		if not binding then
			if THEME[key] ~= nil then
				ctx.UpdateTheme(key, value)
				return true
			end
			return false
		end
		local entry = self._themeControls[binding[1]]
		if not entry then return false end
		local kind = binding[2]
		if kind == "Percent" then
			if tonumber(value) == nil then return false end
			value = math.round(math.clamp(tonumber(value), 0, 1) * 100) / 100
			if THEME[key] ~= value then ctx.UpdateTheme(key, value) end
			entry.API:Set(math.round(value * 100))
		elseif kind == "Colorpicker" then
			if typeof(value) ~= "Color3" then return false end
			entry.API:SetColor(value)
		elseif kind == "Text" then
			entry.API:SetText(tostring(value))
		elseif kind == "Style" then
			local n = tonumber(value)
			if not n or n < 1 or n > 4 then return false end
			entry.API:Set("Style " .. tostring(math.floor(n)))
		elseif kind == "Animation" then
			if type(value) == "number" then
				value = ({ "Fade Slide Down", "Fade Slide Up", "Zoom Fade", "Slide Right" })[value]
			end
			if not value then return false end
			entry.API:Set(value)
		elseif kind == "Toggle" then
			entry.API:Set(value == true)
		else
			entry.API:Set(value)
		end
		return true
	end

	function Window:SetTheme(options)
		if type(options) ~= "table" then return false end
		local allApplied = true
		for key, value in pairs(options) do
			if not self:SetThemeOption(key, value) then allApplied = false end
		end
		return allApplied
	end

	function Window:SetHUDTransparency(value)
		return self:SetThemeOption("HUDTransparency", value)
	end

	searchContainer.Visible = initFlags.SearchBar
	profileBlock.Visible = initFlags.Profile
	ctx.UpdateCorners("Element", elCornerNum)
	ctx.UpdateTopbarAlign(THEME.TopbarAlign)
	ctx.UpdateTogglePosition(THEME.TogglePosition)
	ctx.UpdateMainOutline(THEME.MainOutlineEnabled)
	ctx.UpdateDoubleOutlineMode(THEME.DoubleOutline)
	ctx.UpdateInternalOutlines(THEME.InternalOutlines)
	ctx.UpdateSidebarWidth(ctx.CurrentSidebarWidth)

	return Window
end

return Library
