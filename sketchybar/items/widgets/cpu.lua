local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 2.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")

local cpu = sbar.add("item", "widgets.cpu", {
  position = "right",
  icon = {
    string = "CPU",
    color = colors.grey,
    font = { style = settings.font.style_map["Bold"], size = 10.0 },
    padding_left = 10,
    padding_right = 4,
  },
  label = {
    string = "??%",
    width = 34,
    align = "right",
    font = { style = settings.font.style_map["Semibold"], size = 12.0 },
    padding_right = 10,
  },
  background = { color = colors.bg1 },
  click_script = "open -a 'Activity Monitor'",
})

cpu:subscribe("cpu_update", function(env)
  local load = tonumber(env.total_load) or 0
  local color = colors.grey
  if load >= 80 then color = colors.red elseif load >= 50 then color = colors.orange end
  cpu:set({ icon = { color = color }, label = env.total_load .. "%" })
end)

sbar.add("item", "widgets.cpu.padding", { position = "right", width = settings.group_paddings })
