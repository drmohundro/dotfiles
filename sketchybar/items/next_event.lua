local colors = require("colors")
local settings = require("settings")

local next_event = sbar.add("item", "next_event", {
  position = "right",
  drawing = false,
  scroll_texts = false,
  update_freq = 60,
  icon = {
    string = "􀉉",  -- calendar SF symbol
    color = colors.yellow,
    font = { size = 12.0 },
    padding_left = 8,
    padding_right = 4,
  },
  label = {
    string = "...",
    color = colors.yellow,
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Semibold"],
      size = 12.0,
    },
    padding_right = 8,
    max_chars = 30,
  },
  background = {
    color = colors.bg1,
    border_color = colors.black,
    border_width = 1,
    corner_radius = 9,
    height = 26,
  },
  padding_left = 1,
  padding_right = 1,
  click_script = "open -a Calendar",
})

sbar.add("item", "next_event.padding", {
  position = "right",
  width = settings.group_paddings,
})

local function update()
  sbar.exec("$CONFIG_DIR/helpers/next_event/bin/next_event", function(result)
    local text = result:gsub("\n", "")
    if text ~= "" then
      next_event:set({ drawing = true, label = { string = text } })
    else
      next_event:set({ drawing = false })
    end
  end)
end

next_event:subscribe({"forced", "routine", "system_woke"}, function(_)
  update()
end)
