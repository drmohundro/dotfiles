local icons = require("icons")
local colors = require("colors")

local media_cover = sbar.add("item", "media.cover", {
  position = "right",
  background = {
    image = {
      string = "media.artwork",
      scale = 0.85,
    },
    color = colors.transparent,
  },
  label = { drawing = false },
  icon = { drawing = false },
  drawing = false,
  update_freq = 5,
  updates = true,
  popup = {
    align = "center",
    horizontal = true,
  }
})

local media_artist = sbar.add("item", "media.artist", {
  position = "right",
  drawing = false,
  padding_left = 3,
  padding_right = 0,
  width = 0,
  icon = { drawing = false },
  label = {
    width = 0,
    font = { size = 9 },
    color = colors.with_alpha(colors.white, 0.6),
    max_chars = 18,
    y_offset = 6,
  },
})

local media_title = sbar.add("item", "media.title", {
  position = "right",
  drawing = false,
  padding_left = 3,
  padding_right = 0,
  icon = { drawing = false },
  label = {
    font = { size = 11 },
    width = 0,
    max_chars = 16,
    y_offset = -5,
  },
})

sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon = { string = icons.media.back },
  label = { drawing = false },
  click_script = "nowplaying-cli previous",
})
sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon = { string = icons.media.play_pause },
  label = { drawing = false },
  click_script = "nowplaying-cli togglePlayPause",
})
sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon = { string = icons.media.forward },
  label = { drawing = false },
  click_script = "nowplaying-cli next",
})

local function update()
  sbar.exec("nowplaying-cli get title artist playbackRate", function(result)
    local lines = {}
    for line in result:gmatch("([^\n]*)\n") do
      table.insert(lines, line)
    end

    local title = lines[1]
    local artist = lines[2]
    local rate = lines[3]
    local playing = tonumber(rate) == 1 and title and title ~= ""

    if playing then
      media_artist:set({ drawing = true, label = { string = artist or "", width = "dynamic" } })
      media_title:set({ drawing = true, label = { string = title, width = "dynamic" } })
      media_cover:set({ drawing = true })
    else
      media_artist:set({ drawing = false })
      media_title:set({ drawing = false })
      media_cover:set({ drawing = false, popup = { drawing = false } })
    end
  end)
end

media_cover:subscribe({"routine", "system_woke"}, function(_)
  update()
end)

local function toggle_popup()
  media_cover:set({ popup = { drawing = "toggle" } })
end

media_cover:subscribe("mouse.clicked", toggle_popup)
media_title:subscribe("mouse.clicked", toggle_popup)
media_artist:subscribe("mouse.clicked", toggle_popup)

media_title:subscribe("mouse.exited.global", function(_)
  media_cover:set({ popup = { drawing = false } })
end)
