-- Now playing (via nowplaying-cli)
--   wide displays:  centered chip  [ Title · Artist  ◀ (▶) ▶ ]
--   notch display:  compact note icon on the right with a popup (call add_compact
--                   after the other right-side items so it sits leftmost)

local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local displays = require("helpers.displays")

local PLAY, PAUSE = "\u{100284}", "\u{100286}"

local M = {}

local wide = {}
local compact = nil
local compact_items = {}

local function control(name, position, icon, cmd, extra)
  local item = sbar.add("item", name, {
    position = position,
    drawing = false,
    padding_left = 0,
    padding_right = 0,
    icon = {
      string = icon,
      color = colors.white,
      font = { size = 11.0 },
      padding_left = 6,
      padding_right = 6,
    },
    label = { drawing = false },
    click_script = "nowplaying-cli " .. cmd,
  })
  if extra then item:set(extra) end
  return item
end

-- Wide (center) chip ------------------------------------------------------------

wide.label = sbar.add("item", "media.label", {
  position = "center",
  drawing = false,
  padding_left = 4,
  padding_right = 0,
  icon = { drawing = false },
  label = {
    color = colors.white,
    max_chars = 40,
    font = { style = settings.font.style_map["Semibold"], size = 12.0 },
    padding_left = 8,
    padding_right = 6,
  },
})

wide.back = control("media.back", "center", icons.media.back, "previous")
wide.play = control("media.play", "center", PLAY, "togglePlayPause", {
  icon = { color = colors.on_accent, padding_left = 8, padding_right = 8 },
  background = { color = colors.accent, height = 20, corner_radius = 10 },
})
wide.forward = control("media.forward", "center", icons.media.forward, "next", {
  padding_right = 4,
})

local bracket = sbar.add("bracket", "media.bracket", {
  wide.label.name, wide.back.name, wide.play.name, wide.forward.name,
}, {
  background = { color = colors.bg1 },
})
sbar.add("item", "media.gap", { position = "center", width = settings.group_paddings })

displays.register("wide", wide.label, wide.back, wide.play, wide.forward, bracket)

-- State -------------------------------------------------------------------------

local function render(title, artist, playing)
  local has_track = title ~= nil and title ~= ""
  local text = has_track and title or ""
  if has_track and artist and artist ~= "" then text = title .. "  ·  " .. artist end

  for _, item in pairs(wide) do item:set({ drawing = has_track }) end
  if has_track then
    wide.label:set({ label = { string = text } })
    wide.play:set({ icon = { string = playing and PAUSE or PLAY } })
  end

  if compact then
    compact:set({
      drawing = has_track,
      icon = { color = playing and colors.accent or colors.grey },
    })
    if not has_track then compact:set({ popup = { drawing = false } }) end
    compact_items.title:set({ label = { string = text } })
    compact_items.play:set({ icon = { string = playing and PAUSE or PLAY } })
  end
end

local function update()
  sbar.exec("nowplaying-cli get title artist playbackRate", function(result)
    local lines = {}
    for line in tostring(result):gmatch("([^\n]*)\n") do table.insert(lines, line) end
    local title, artist, rate = lines[1], lines[2], tonumber(lines[3])
    if title == "null" then title = nil end
    if artist == "null" then artist = nil end
    render(title, artist, rate == 1)
  end)
end

local watcher = sbar.add("item", "media.watcher", { drawing = false, updates = true, update_freq = 5 })
watcher:subscribe({ "routine", "forced", "system_woke" }, update)

-- Compact (notch display) -------------------------------------------------------

function M.add_compact()
  compact = sbar.add("item", "media.compact", {
    position = "right",
    drawing = false,
    icon = {
      string = ":music:",
      color = colors.grey,
      font = "sketchybar-app-font:Regular:14.0",
      padding_left = 10,
      padding_right = 10,
    },
    label = { drawing = false },
    background = { color = colors.bg1 },
    popup = { align = "center", horizontal = true },
  })
  local popup = "popup." .. compact.name
  compact_items.title = sbar.add("item", "media.compact.title", {
    position = popup,
    icon = { drawing = false },
    label = { max_chars = 40, padding_left = 10, padding_right = 6 },
  })
  control("media.compact.back", popup, icons.media.back, "previous", { drawing = true })
  compact_items.play = control("media.compact.play", popup, PLAY, "togglePlayPause", {
    drawing = true,
    icon = { color = colors.on_accent, padding_left = 8, padding_right = 8 },
    background = { color = colors.accent, height = 20, corner_radius = 10 },
  })
  control("media.compact.forward", popup, icons.media.forward, "next", { drawing = true, padding_right = 6 })
  sbar.add("item", "media.compact.gap", { position = "right", width = settings.group_paddings })

  compact:subscribe("mouse.clicked", function()
    compact:set({ popup = { drawing = "toggle" } })
  end)
  compact:subscribe("mouse.exited.global", function()
    compact:set({ popup = { drawing = false } })
  end)

  displays.register("notch", compact)
  update()
end

return M
