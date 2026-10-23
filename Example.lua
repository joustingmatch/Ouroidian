--[[
	Ouroidian - Example
	A complete tour of the library, laid out the way a real script would be.

	Structure:
	  1. Setup       - load the library and addons, create the window
	  2. Interface   - tabs, groupboxes and every element type
	  3. Logic       - react to changes through Toggles / Options
	  4. Settings    - menu options, themes and configs

	Tip: build the whole UI first, then wire up behaviour with :OnChanged.
	Keeping UI and logic apart makes scripts much easier to maintain.
]]

--// 1. Setup \\--
local Repo = "https://raw.githubusercontent.com/joustingmatch/Ouroidian/main/"
local Library = loadstring(game:HttpGet(Repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(Repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false -- Render every AddToggle as a checkbox
Library.ShowToggleFrameInKeybinds = true -- Show toggle switches inside the keybind list (handy on mobile)

local Window = Library:CreateWindow({
	Title = "Ouroidian",
	Subtitle = "Example Hub",
	Footer = "v1.0.0  ·  example build",
	Icon = 95816097006870,
	NotifySide = "Right",

	-- Sidebar tab button look; Indicator adds an accent bar beside the active tab
	TabButtonsStyle = {
		Gap = 4,
		Padding = 6,
		CornerRadius = 6,
		Indicator = true,
		IndicatorWidth = 2,
		IndicatorHeight = 26,
	},

	-- Other useful options: Center, AutoShow, Resizable, Size, Position,
	-- MobileButtonsSide ("Left" / "Right"), AlwaysOnTop, DisableSearch
})

-- Icons come from https://lucide.dev
local Tabs = {
	Combat = Window:AddTab({ Name = "Combat", Icon = "swords", Description = "Aim assistance and weapon tweaks" }),
	Movement = Window:AddTab({ Name = "Movement", Icon = "footprints", Description = "Speed, flight and traversal" }),
	Visuals = Window:AddTab({ Name = "Visuals", Icon = "eye", Description = "ESP and world rendering" }),
	Automation = Window:AddTab({ Name = "Automation", Icon = "bot", Description = "Farming and repetitive tasks" }),
	Settings = Window:AddTab({ Name = "Settings", Icon = "settings", Description = "Menu, themes and configs" }),
}

-- Pinned to the bottom of the sidebar; opens a full "join our server" page
Tabs.Discord = Window:AddDiscordTab({
	Invite = "discord.gg/your-invite",
	Perks = {
		"Get notified the moment new updates drop",
		"Suggest features and report bugs directly",
		"Chat with the community and get support",
	},
})

--// 2. Interface \\--

--[[ Combat
	Toggles, sliders, dropdowns, key pickers, color pickers and dependency boxes.
]]
local AimGroup = Tabs.Combat:AddGroupbox({
	Side = "Left", -- "Left" / "Right" (case-insensitive) or 1 / 2
	Name = "Aim Assist",
	Description = "Smoothly guides your crosshair",
	IconName = "crosshair",
	-- Collapsed = false,
	-- DisableCollapsing = false,
})

AimGroup:AddToggle("AimEnabled", {
	Text = "Enable Aim Assist",
	Tooltip = "Gently pulls your aim toward the nearest target",
	Default = false,
})
	-- Key pickers and color pickers can be chained onto toggles and labels
	:AddKeyPicker("AimKey", {
		Default = "MB2", -- MB1 / MB2 for mouse buttons, or any KeyCode name
		Mode = "Hold", -- Always, Toggle, Hold, Press
		SyncToggleState = false, -- When true, the key flips the toggle it's attached to
		Text = "Aim Assist", -- Name shown in the keybind list
		NoUI = false, -- Hide from the keybind list
	})

-- Dependency boxes only appear while their conditions are met
local AimSettings = AimGroup:AddDependencyBox()

AimSettings:AddSlider("AimSmoothness", {
	Text = "Smoothness",
	Default = 35,
	Min = 0,
	Max = 100,
	Rounding = 0,
	Suffix = "%",
})

AimSettings:AddSlider("AimFOV", {
	Text = "Field of View",
	Default = 120,
	Min = 10,
	Max = 360,
	Rounding = 0,
	Suffix = "°",
})

AimSettings:AddDropdown("AimPart", {
	Text = "Target Part",
	Values = { "Head", "Torso", "Closest" },
	Default = "Head",
})

AimSettings:AddToggle("AimTeamCheck", {
	Text = "Ignore Teammates",
	Default = true,
})

AimSettings:SetupDependencies({
	{ Toggles.AimEnabled, true },
})

AimGroup:AddDivider("Trigger")

local TriggerBot = AimGroup:AddToggle("TriggerBot", {
	Text = "Trigger Bot",
	Tooltip = "Fires automatically when your crosshair is on a target",
	Risky = true, -- Highlights the text in the scheme's red
	Default = false,
})

-- AddSettingsPopup puts a gear beside the toggle; its config lives in a popup that
-- takes any groupbox element (sliders, dropdowns, toggles, ...)
local TriggerSettings = TriggerBot:AddSettingsPopup({ Width = 220, Tooltip = "Trigger Bot settings" })

TriggerSettings:AddSlider("TriggerHitChance", {
	Text = "Hit Chance",
	Default = 100,
	Min = 0,
	Max = 100,
	Rounding = 0,
	Suffix = "%",
})

TriggerSettings:AddDropdown("TriggerWeapons", {
	Text = "Weapons",
	Values = { "Rifles", "Pistols", "Snipers" },
	Default = { "Rifles" },
	Multi = true,
})

TriggerSettings:AddToggle("TriggerScopedOnly", { Text = "Only When Scoped", Default = false })

AimGroup:AddSlider("TriggerDelay", {
	Text = "Reaction Delay",
	Default = 0.12,
	Min = 0,
	Max = 1,
	Rounding = 2,
	Suffix = "s",
	-- Return a custom string, or nil to fall back to the default formatting
	FormatDisplayValue = function(Slider, Value)
		if Value == Slider.Min then
			return "Instant"
		end
	end,
})

local WeaponGroup = Tabs.Combat:AddGroupbox({
	Side = "Right",
	Name = "Weapon",
	IconName = "target",
})

WeaponGroup:AddCheckbox("NoRecoil", {
	Text = "No Recoil",
	Default = false,
})

WeaponGroup:AddCheckbox("NoSpread", {
	Text = "No Spread",
	Default = false,
})

WeaponGroup:AddCheckbox("InstantReload", {
	Text = "Instant Reload",
	Default = false,
	Disabled = true, -- Greyed out and unclickable
	DisabledTooltip = "Not supported in this game",
})

WeaponGroup:AddDropdown("FireModes", {
	Text = "Allowed Fire Modes",
	Values = { "Single", "Burst", "Automatic", "Charged" },
	Default = { "Single", "Automatic" },
	Multi = true, -- Multi dropdowns include a Select All / Deselect All row (SelectAll = false hides it)
})

WeaponGroup:AddButton({
	Text = "Equip Best Weapon",
	Tooltip = "Equips the highest damage weapon in your inventory",
	Func = function()
		Library:Notify({ Title = "Weapon", Description = "Equipped your best weapon.", Time = 3 })
	end,
})
	-- Buttons can carry a sub button beside them
	:AddButton({
		Text = "Drop All",
		Risky = true,
		DoubleClick = true, -- Requires a second click to confirm
		Tooltip = "Double click to drop every weapon",
		Func = function()
			Library:Notify({ Title = "Weapon", Description = "Dropped all weapons.", Time = 3 })
		end,
	})

--[[ Movement
	Tabboxes hold several pages inside one box; they accept the same elements as groupboxes.
]]
local MovementBox = Tabs.Movement:AddTabbox({ Side = "Left", Name = "Locomotion" })

local WalkPage = MovementBox:AddTab("Walk", "footprints")
local FlyPage = MovementBox:AddTab("Fly", "plane")

WalkPage:AddToggle("SpeedEnabled", {
	Text = "Speed Override",
	Default = false,
}):AddKeyPicker("SpeedKey", {
	Default = "LeftControl",
	Mode = "Toggle",
	SyncToggleState = true,
	Text = "Speed Override",
})

WalkPage:AddSlider("WalkSpeed", {
	Text = "Walk Speed",
	Default = 16,
	Min = 16,
	Max = 120,
	Rounding = 0,
})

WalkPage:AddSlider("JumpPower", {
	Text = "Jump Power",
	Default = 50,
	Min = 50,
	Max = 200,
	Rounding = 0,
	Compact = true, -- Hides the title and shows the text inside the bar
})

FlyPage:AddToggle("FlyEnabled", {
	Text = "Flight",
	Default = false,
}):AddKeyPicker("FlyKey", {
	Default = "F",
	Mode = "Toggle",
	SyncToggleState = true,
	Text = "Flight",
})

FlyPage:AddSlider("FlySpeed", {
	Text = "Flight Speed",
	Default = 60,
	Min = 10,
	Max = 300,
	Rounding = 0,
	HideMax = true,
})

local TravelGroup = Tabs.Movement:AddGroupbox({
	Side = "Right",
	Name = "Teleport",
	IconName = "map-pin",
})

TravelGroup:AddDropdown("TeleportPlayer", {
	Text = "Player",
	SpecialType = "Player", -- Fills itself with the server's players and stays up to date
	ExcludeLocalPlayer = true,
	EnablePlayerImages = true,
	Searchable = true,
})

TravelGroup:AddButton({
	Text = "Teleport to Player",
	Func = function()
		local Target = Options.TeleportPlayer.Value
		Library:Notify({
			Title = "Teleport",
			Description = Target and ("Teleporting to " .. Target.Name) or "Select a player first.",
			Time = 3,
		})
	end,
})

TravelGroup:AddInput("Waypoint", {
	Text = "Waypoint Name",
	Placeholder = "e.g. Spawn",
	Default = "",
	Finished = true, -- Only fires once Enter is pressed
	ClearTextOnFocus = false,
	-- Numeric = true, MaxLength = 32
})

--[[ Visuals
	Color pickers, dictionary dropdowns and labels.
]]
local EspGroup = Tabs.Visuals:AddGroupbox({
	Side = "Left",
	Name = "Player ESP",
	IconName = "scan-eye",
})

EspGroup:AddToggle("EspBoxes", { Text = "Boxes", Default = false })
	:AddColorPicker("EspBoxColor", {
		Default = Color3.fromRGB(125, 85, 255),
		Title = "Box Color",
	})

EspGroup:AddToggle("EspNames", { Text = "Names", Default = false })
	:AddColorPicker("EspNameColor", {
		Default = Color3.fromRGB(255, 255, 255),
		Title = "Name Color",
	})

EspGroup:AddToggle("EspHealth", { Text = "Health Bars", Default = false })

EspGroup:AddToggle("EspTracers", { Text = "Tracers", Default = false })
	:AddColorPicker("EspTracerColor", {
		Default = Color3.fromRGB(255, 80, 80),
		Title = "Tracer Color",
		Transparency = 0.25, -- Setting this enables the transparency slider
	})

EspGroup:AddSlider("EspDistance", {
	Text = "Max Distance",
	Default = 1500,
	Min = 100,
	Max = 5000,
	Rounding = 0,
	Suffix = " studs",
})

EspGroup:AddDropdown("EspTeams", {
	Text = "Show Teams",
	SpecialType = "Team",
	Multi = true,
})

local WorldGroup = Tabs.Visuals:AddGroupbox({
	Side = "Right",
	Name = "World",
	IconName = "sun",
})

WorldGroup:AddToggle("Fullbright", { Text = "Fullbright", Default = false })

WorldGroup:AddLabel("Ambient Color"):AddColorPicker("AmbientColor", {
	Default = Color3.fromRGB(140, 140, 160),
	Title = "Ambient",
})

-- Dictionary values: keys are what you read in code, values are what the user sees
WorldGroup:AddDropdown("Skybox", {
	Text = "Skybox",
	Values = {
		default = "Default",
		night = "Starry Night",
		sunset = "Sunset",
		void = "Void",
	},
	Default = "default",
	DisabledValues = { "void" },
})

WorldGroup:AddSlider("TimeOfDay", {
	Text = "Time of Day",
	Default = 14,
	Min = 0,
	Max = 24,
	Rounding = 1,
	FormatDisplayValue = function(_, Value)
		return string.format("%02d:%02d", math.floor(Value), math.floor((Value % 1) * 60))
	end,
})

WorldGroup:AddDivider()
WorldGroup:AddLabel("Rendering changes are local and only visible to you.", true) -- true = wrap text

--[[ Automation
	Sub tabs give a tab its own side panel; sections group them under collapsible headers.
]]
local FarmingSection = Tabs.Automation:AddSubTabSection("Farming")
local FieldsPage = FarmingSection:AddSubTab("Fields")
local CollectPage = FarmingSection:AddSubTab({ Name = "Collecting", Badge = "New" })

local QuestsSection = Tabs.Automation:AddSubTabSection("Progression")
local QuestsPage = QuestsSection:AddSubTab({ Name = "Quests", Badge = 3 })

local FieldGroup = FieldsPage:AddGroupbox({ Side = "Left", Name = "Autofarm", IconName = "sprout" })

FieldGroup:AddDropdown("FarmField", {
	Text = "Field",
	Values = { "Sunflower Field", "Dandelion Field", "Mushroom Field", "Clover Field", "Blue Flower Field", "Pine Tree Forest", "Rose Field", "Mountain Top" },
	Default = "Sunflower Field",
	Searchable = true,
	MaxVisibleDropdownItems = 6,
})

FieldGroup:AddToggle("FarmEnabled", { Text = "Enable Autofarm", Default = false })
FieldGroup:AddToggle("FarmAutoDig", { Text = "Auto Dig", Default = true })
FieldGroup:AddToggle("FarmConvert", { Text = "Convert When Full", Default = true })

local CollectGroup = CollectPage:AddGroupbox({ Side = "Left", Name = "Auto Collect", IconName = "magnet" })

CollectGroup:AddDropdown("CollectTargets", {
	Text = "Collect",
	Values = { "Tokens", "Bubbles", "Petals", "Sparkles", "Coconuts" },
	Default = { "Tokens", "Bubbles" },
	Multi = true,
	DragSelect = true, -- Click and drag across values to select a range (desktop only)
})

CollectGroup:AddSlider("CollectRadius", {
	Text = "Collect Radius",
	Default = 40,
	Min = 5,
	Max = 100,
	Rounding = 0,
	Suffix = " studs",
})

local QuestGroup = QuestsPage:AddGroupbox({ Side = "Left", Name = "Quests", IconName = "scroll-text" })

QuestGroup:AddToggle("AutoQuest", { Text = "Auto Accept Quests", Default = false })
QuestGroup:AddToggle("AutoClaim", { Text = "Auto Claim Rewards", Default = false })
QuestGroup:AddLabel("QuestStatus", { Text = "Status: idle", DoesWrap = true })

QuestGroup:AddButton({
	Text = "Clear Quest Badge",
	Func = function()
		QuestsPage:SetBadge(nil)
	end,
})

--// 3. Logic \\--
-- Every element is reachable through Toggles[Index] or Options[Index].

Toggles.AimEnabled:OnChanged(function()
	Library:Notify({
		Title = "Aim Assist",
		Description = Toggles.AimEnabled.Value and "Enabled" or "Disabled",
		Time = 2,
	})
end)

Toggles.AutoQuest:OnChanged(function()
	Options.QuestStatus:SetText(Toggles.AutoQuest.Value and "Status: looking for quests..." or "Status: idle")
end)

Options.CollectTargets:OnChanged(function()
	-- Multi dropdowns store { [Value] = true }
	local Count = Options.CollectTargets:GetActiveValues(true)
	CollectPage:SetBadge(Count > 0 and Count or nil)
end)

Options.Waypoint:OnChanged(function()
	if Options.Waypoint.Value ~= "" then
		Library:Notify({ Title = "Waypoint", Description = "Saved \"" .. Options.Waypoint.Value .. "\"", Time = 3 })
	end
end)

-- Hold / Always key pickers are polled with :GetState(); Toggle keys can also use :OnClick
task.spawn(function()
	while not Library.Unloaded do
		local Aiming = Toggles.AimEnabled.Value and Options.AimKey:GetState()
		if Aiming then
			-- Run aim assist here using Options.AimSmoothness.Value, Options.AimFOV.Value, ...
		end

		task.wait()
	end
end)

--// 4. Settings \\--
local MenuGroup = Tabs.Settings:AddGroupbox({
	Side = "Left",
	Name = "Menu",
	IconName = "wrench",
})

MenuGroup:AddToggle("KeybindMenuOpen", {
	Text = "Show Keybind List",
	Default = Library.KeybindFrame.Visible,
	Callback = function(Value)
		Library.KeybindFrame.Visible = Value
	end,
})

MenuGroup:AddToggle("KeybindMenuVisibilityControl", {
	Text = "Keybind List Follows Menu",
	Default = false,
	Callback = function(Value)
		Library.KeybindMenu:SetVisibilityControl(Value)
	end,
})

MenuGroup:AddToggle("AlwaysOnTop", {
	Text = "Always On Top",
	Default = Window.AlwaysOnTop,
	Callback = function(Value)
		Window:SetAlwaysOnTop(Value)
	end,
})

MenuGroup:AddDropdown("NotificationSide", {
	Text = "Notification Side",
	Values = { "Left", "Right" },
	Default = "Right",
	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})

MenuGroup:AddDropdown("DPIDropdown", {
	Text = "Interface Scale",
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Callback = function(Value)
		Library:SetDPIScale(tonumber((Value:gsub("%%", ""))))
	end,
})

MenuGroup:AddSlider("UICornerSlider", {
	Text = "Corner Radius",
	Default = Library.CornerRadius,
	Min = 0,
	Max = 20,
	Rounding = 0,
	Callback = function(Value)
		Window:SetCornerRadius(Value)
	end,
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Menu keybind",
})

MenuGroup:AddButton({
	Text = "Unload",
	Risky = true,
	Func = function()
		Library:Unload()
	end,
})

Library.ToggleKeybind = Options.MenuKeybind

Library:OnUnload(function()
	print("[Ouroidian] Unloaded")
end)

-- Themes and configs
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings() -- Configs shouldn't overwrite the user's theme
SaveManager:SetIgnoreIndexes({ "MenuKeybind" }) -- ...or their menu key

ThemeManager:SetFolder("OuroidianExample") -- Shared across games
SaveManager:SetFolder("OuroidianExample/example-game") -- One folder per game
-- SaveManager:SetSubFolder("lobby") -- Optional: separate configs per place

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

Library:Notify({
	Title = "Ouroidian",
	Description = "Loaded successfully. Press RightShift to toggle the menu.",
	Time = 5,
})
