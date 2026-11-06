local colors = require("colors")
local settings = require("settings")

sbar.exec("killall memory_load >/dev/null; $CONFIG_DIR/helpers/event_providers/memory_load/bin/memory_load memory_update 5.0")

local memory = sbar.add("item", "widgets.memory", {
  position = "right",
  icon = {
    string = "RAM",
    color = colors.grey,
    font = { style = settings.font.style_map["Bold"], size = 10.0 },
    padding_left = 10,
    padding_right = 4,
  },
  label = {
    string = "??G",
    font = { style = settings.font.style_map["Semibold"], size = 12.0 },
    padding_right = 10,
  },
  background = { color = colors.bg1 },
  click_script = "open -a 'Activity Monitor'",
})

memory:subscribe("memory_update", function(env)
  local load = tonumber(env.load) or 0
  local color = colors.grey
  if load >= 90 then color = colors.red elseif load >= 75 then color = colors.orange end
  memory:set({ icon = { color = color }, label = env.used_gb .. "G" })
end)

sbar.add("item", "widgets.memory.padding", { position = "right", width = settings.group_paddings })
