-- AeroSpace workspaces, DMS style:
--   [ 1 (2) 4 ]  [ app app app ]  [ App · Window title ]
-- Pills show visible workspaces and any with windows, numbered to match the
-- ctrl+opt+N shortcuts since the empty ones in between are hidden.

local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local AS = "/opt/homebrew/bin/aerospace"
local MAX_SPACES = 10
local MAX_APPS = 12
local PILL_W, PILL_ACTIVE_W = 18, 30

sbar.add("event", "aerospace_workspace_change")

local function shell_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- Workspace pills ---------------------------------------------------------------

local pills = {}
for i = 1, MAX_SPACES do
  local slot = { name = nil, width = nil }
  slot.item = sbar.add("item", "space." .. i, {
    position = "left",
    drawing = false,
    padding_left = 2,
    padding_right = 2,
    icon = { drawing = false },
    label = {
      string = " ",
      width = PILL_W,
      align = "center",
      padding_left = 0,
      padding_right = 0,
      color = colors.grey,
      font = { style = settings.font.style_map["Bold"], size = 10.0 },
    },
    background = { height = 18, corner_radius = 9, color = colors.bg2 },
  })
  slot.item:subscribe("mouse.clicked", function()
    if slot.name then sbar.exec(AS .. " workspace " .. shell_quote(slot.name)) end
  end)
  pills[i] = slot
end

sbar.add("bracket", "spaces.bracket", { "/space\\..*/" }, {
  background = { color = colors.bg1 },
})
sbar.add("item", "spaces.gap", { position = "left", width = settings.group_paddings })

-- App strip for the focused workspace --------------------------------------------

local strip = {}
for i = 1, MAX_APPS do
  local slot = { window_id = nil }
  slot.item = sbar.add("item", "space_app." .. i, {
    position = "left",
    drawing = false,
    padding_left = i == 1 and 6 or 0,
    padding_right = 0,
    icon = { drawing = false },
    label = {
      font = "sketchybar-app-font:Regular:15.0",
      color = colors.grey,
      padding_left = 4,
      padding_right = 4,
      y_offset = -1,
    },
  })
  slot.item:subscribe("mouse.clicked", function()
    if slot.window_id then sbar.exec(AS .. " focus --window-id " .. slot.window_id) end
  end)
  strip[i] = slot
end
sbar.add("item", "space_app.end", { position = "left", width = 6 })

sbar.add("bracket", "space_apps.bracket", { "/space_app\\..*/" }, {
  background = { color = colors.bg1 },
})
sbar.add("item", "space_apps.gap", { position = "left", width = settings.group_paddings })

-- Focused window: "App · Title" ---------------------------------------------------

local front_app = sbar.add("item", "front_app", {
  position = "left",
  icon = { drawing = false },
  label = {
    font = { style = settings.font.style_map["Semibold"], size = 12.0 },
    max_chars = 60,
    padding_left = 10,
    padding_right = 10,
  },
  background = { color = colors.bg1 },
})

-- State refresh -------------------------------------------------------------------

-- F<TAB>focused workspace, V<TAB>visible workspace, T<TAB>app<TAB>title,
-- W<TAB>workspace<TAB>window id<TAB>layout<TAB>app
local STATE_CMD = string.format([[
A=%s
printf 'F\t%%s\n' "$($A list-workspaces --focused)"
$A list-workspaces --monitor all --visible | sed 's/^/V	/'
$A list-windows --focused --format 'T%%{tab}%%{app-name}%%{tab}%%{window-title}' 2>/dev/null
$A list-windows --all --format 'W%%{tab}%%{workspace}%%{tab}%%{window-id}%%{tab}%%{window-layout}%%{tab}%%{app-name}'
]], AS)

local function is_shown(layout)
  return layout ~= "macos_native_window_of_hidden_app" and layout ~= "macos_native_minimized"
end

local function parse(out)
  local state = { focused = nil, visible = {}, app = nil, title = nil, windows = {}, occupied = {} }
  for line in tostring(out):gmatch("[^\n]+") do
    local kind, rest = line:match("^(%u)\t(.*)$")
    if kind == "F" then
      state.focused = rest
    elseif kind == "V" then
      state.visible[rest] = true
    elseif kind == "T" then
      state.app, state.title = rest:match("^([^\t]*)\t(.*)$")
    elseif kind == "W" then
      local ws, id, layout, app = rest:match("^([^\t]*)\t([^\t]*)\t([^\t]*)\t(.*)$")
      if ws then
        state.occupied[ws] = true
        table.insert(state.windows, { ws = ws, id = id, layout = layout, app = app })
      end
    end
  end
  return state
end

local function render_pills(state)
  local names = {}
  for name in pairs(state.occupied) do names[name] = true end
  for name in pairs(state.visible) do names[name] = true end
  local sorted = {}
  for name in pairs(names) do table.insert(sorted, name) end
  table.sort(sorted, function(a, b)
    local na, nb = tonumber(a), tonumber(b)
    if na and nb then return na < nb end
    return a < b
  end)

  for i = 1, MAX_SPACES do
    local slot, name = pills[i], sorted[i]
    if name then
      local focused = name == state.focused
      local width = focused and PILL_ACTIVE_W or PILL_W
      slot.name = name
      slot.item:set({
        drawing = true,
        label = {
          string = name,
          color = focused and colors.on_accent or (state.visible[name] and colors.white or colors.grey),
        },
      })
      if slot.width ~= width or slot.focused ~= focused then
        slot.width, slot.focused = width, focused
        sbar.animate("tanh", 12, function()
          slot.item:set({
            label = { width = width },
            background = { color = focused and colors.accent or colors.bg2 },
          })
        end)
      end
    else
      slot.name = nil
      slot.item:set({ drawing = false })
    end
  end
end

local function render_strip(state)
  local apps, seen = {}, {}
  for _, win in ipairs(state.windows) do
    if win.ws == state.focused and is_shown(win.layout) and not seen[win.app] then
      seen[win.app] = true
      table.insert(apps, win)
    end
  end

  for i = 1, MAX_APPS do
    local slot, win = strip[i], apps[i]
    slot.window_id = win and win.id or nil
    if win then
      slot.item:set({
        drawing = true,
        label = {
          string = app_icons[win.app] or app_icons["Default"],
          color = win.app == state.app and colors.accent or colors.grey,
        },
      })
    else
      slot.item:set({ drawing = false })
    end
  end
end

local function render_title(state)
  local label = state.app or ""
  if state.title and state.title ~= "" and state.title ~= state.app then
    label = label .. "  ·  " .. state.title
  end
  front_app:set({ drawing = label ~= "", label = { string = label } })
end

-- Execs can finish out of order; only the newest result is rendered
local latest = 0

local function refresh()
  latest = latest + 1
  local request = latest
  sbar.exec(STATE_CMD, function(out)
    if request ~= latest then return end
    local state = parse(out)
    render_pills(state)
    render_strip(state)
    render_title(state)
  end)
end

local ctrl = sbar.add("item", "spaces.ctrl", { drawing = false, updates = true, update_freq = 3 })
ctrl:subscribe({
  "aerospace_workspace_change",
  "front_app_switched",
  "routine",
  "forced",
  "system_woke",
  "display_change",
}, refresh)
refresh()
