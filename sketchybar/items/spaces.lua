local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Register the flashspace event so sketchybar knows to accept it
sbar.add("event", "flashspace_workspace_change")

local workspaces = {
  { name = "Coding",    icon = "󰘐" },
  { name = "Browser",   icon = "󰖟" },
  { name = "Messaging", icon = "󰒱" },
  { name = "Misc",      icon = "󰠦" },
  { name = "Gaming",    icon = "󰊖" },
}

local space_items = {}

-- Toggle button: always visible, clicking swaps between spaces view and app menus
local spaces_indicator = sbar.add("item", "spaces_indicator", {
  drawing = true,
  padding_left = 6,
  padding_right = 4,
  icon = {
    string = icons.switch.on,
    color = colors.grey,
    padding_left = 6,
    padding_right = 6,
  },
  label = { drawing = false },
  background = {
    color = colors.with_alpha(colors.grey, 0.0),
    border_color = colors.with_alpha(colors.bg1, 0.0),
  },
})

spaces_indicator:subscribe("mouse.clicked", function(_)
  sbar.trigger("swap_menus_and_spaces")
end)

spaces_indicator:subscribe("swap_menus_and_spaces", function(_)
  local currently_on = spaces_indicator:query().icon.value == icons.switch.on
  spaces_indicator:set({
    icon = { string = currently_on and icons.switch.off or icons.switch.on }
  })
end)

-- Helper: query running apps for a workspace and update its label
local function update_space_apps(ws_name, space_item)
  sbar.exec("flashspace list-apps " .. ws_name .. " --only-running", function(result)
    local icon_line = ""
    local has_app = false
    for app in string.gmatch(result, "[^\r\n]+") do
      if app ~= "" then
        has_app = true
        local lookup = app_icons[app]
        local icon = lookup ~= nil and lookup or app_icons["Default"]
        icon_line = icon_line .. icon
      end
    end
    space_item:set({
      label = {
        string = has_app and icon_line or " —",
      }
    })
  end)
end

for i, ws in ipairs(workspaces) do
  local space = sbar.add("item", "space." .. i, {
    position = "left",
    drawing = true,
    icon = {
      string = ws.icon,
      font = { family = "JetBrainsMono Nerd Font", style = "Regular", size = 14.0 },
      color = colors.white,
      padding_left = 8,
      padding_right = 4,
    },
    label = {
      string = " —",
      color = colors.grey,
      -- app icons font: install with `brew install --cask font-sketchybar-app-font`
      font = "sketchybar-app-font:Regular:14.0",
      padding_right = 10,
      y_offset = -1,
      drawing = false,
    },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.bg1,
      border_width = 1,
      height = 26,
      border_color = colors.black,
      corner_radius = 6,
    },
  })

  space_items[ws.name] = space

  -- Click to switch workspace
  local ws_name = ws.name
  space:subscribe("mouse.clicked", function(env)
    sbar.exec("flashspace workspace " .. ws_name)
  end)

  -- Highlight active space and refresh app icons on workspace change
  space:subscribe("flashspace_workspace_change", function(env)
    local active = env.WORKSPACE == ws_name
    space:set({
      icon = { color = active and colors.black or colors.white },
      label = { drawing = active, color = active and colors.black or colors.grey },
      background = {
        color = active and colors.magenta or colors.bg1,
        border_color = active and colors.magenta or colors.black,
      },
    })
    if active then
      update_space_apps(ws_name, space)
    end
  end)
end
