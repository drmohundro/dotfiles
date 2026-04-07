local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

sbar.exec("killall memory_load >/dev/null; $CONFIG_DIR/helpers/event_providers/memory_load/bin/memory_load memory_update 5.0")

local memory = sbar.add("graph", "widgets.memory", 64, {
  position = "right",
  graph = { color = colors.magenta },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { string = icons.cpu },
  label = {
    string = "mem ??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    align = "right",
    padding_right = 0,
    width = 0,
    y_offset = 4,
  },
  padding_right = settings.paddings + 6,
})

memory:subscribe("memory_update", function(env)
  local load = tonumber(env.load)
  memory:push({ load / 100. })

  local color = colors.magenta
  if load > 75 then
    color = colors.orange
  elseif load > 90 then
    color = colors.red
  end

  memory:set({
    graph = { color = color },
    label = "mem " .. env.used_gb .. "G",
  })
end)

memory:subscribe("mouse.clicked", function(_)
  sbar.exec("open -a 'Activity Monitor'")
end)

sbar.add("bracket", "widgets.memory.bracket", { memory.name }, {
  background = { color = colors.bg1 }
})

sbar.add("item", "widgets.memory.padding", {
  position = "right",
  width = settings.group_paddings,
})
