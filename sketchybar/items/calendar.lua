local settings = require("settings")
local colors = require("colors")
local displays = require("helpers.displays")

-- Two copies of the clock: centered on displays without a notch, right-aligned on
-- the notch display (where the center is hidden behind the camera housing).
local function add_clock(name, position)
  local clock = sbar.add("item", name, {
    position = position,
    update_freq = 30,
    icon = {
      color = colors.white,
      padding_left = 12,
      padding_right = 6,
      font = { style = settings.font.style_map["Bold"], size = 13.0 },
    },
    label = {
      color = colors.grey,
      padding_right = 12,
      font = { style = settings.font.style_map["Semibold"], size = 12.0 },
    },
    background = { color = colors.bg1 },
    click_script = "open -a 'Calendar'",
  })

  clock:subscribe({ "forced", "routine", "system_woke" }, function()
    clock:set({
      -- Lua's os.date rejects the %-I / %-d flags, so trim leading zeros by hand
      icon = (os.date("%I:%M %p"):gsub("^0", "")),
      label = (os.date("%a %b %d"):gsub(" 0(%d)$", " %1")),
    })
  end)
  return clock
end

local center = add_clock("clock.center", "center")
local right = add_clock("clock.right", "right")
sbar.add("item", "clock.right.gap", { position = "right", width = settings.group_paddings })

displays.register("wide", center)
displays.register("notch", right)
