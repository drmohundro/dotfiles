local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_width = 250

local volume = sbar.add("item", "widgets.volume", {
  position = "right",
  icon = {
    string = icons.volume._100,
    color = colors.grey,
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
  },
  label = {
    string = "??%",
    width = 0,
    font = { family = settings.font.numbers },
  },
})

local volume_bracket = sbar.add("bracket", "widgets.volume.bracket", {
  volume.name
}, {
  background = { color = colors.bg1 },
  popup = { align = "center" }
})

sbar.add("item", "widgets.volume.padding", {
  position = "right",
  width = settings.group_paddings
})

local volume_slider = sbar.add("slider", popup_width, {
  position = "popup." .. volume_bracket.name,
  slider = {
    highlight_color = colors.blue,
    background = {
      height = 6,
      corner_radius = 3,
      color = colors.bg2,
    },
    knob = {
      string = "􀀁",
      drawing = true,
    },
  },
  background = { color = colors.bg1, height = 2, y_offset = -20 },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"'
})

volume:subscribe("volume_change", function(env)
  local vol = tonumber(env.INFO)
  local icon = icons.volume._0
  if vol > 60 then
    icon = icons.volume._100
  elseif vol > 30 then
    icon = icons.volume._66
  elseif vol > 10 then
    icon = icons.volume._33
  elseif vol > 0 then
    icon = icons.volume._10
  end

  local lead = vol < 10 and "0" or ""
  volume:set({
    icon = { string = icon },
    label = { string = lead .. vol .. "%" },
  })
  volume_slider:set({ slider = { percentage = vol } })
end)

volume:subscribe("mouse.entered", function(_)
  volume:set({ label = { width = "dynamic" } })
end)

volume:subscribe("mouse.exited", function(_)
  if volume_bracket:query().popup.drawing == "off" then
    volume:set({ label = { width = 0 } })
  end
end)

local function volume_collapse_details()
  local drawing = volume_bracket:query().popup.drawing == "on"
  if not drawing then return end
  volume_bracket:set({ popup = { drawing = false } })
  sbar.remove('/volume.device\\.*/')
  volume:set({ label = { width = 0 } })
end

volume:subscribe("mouse.exited.global", volume_collapse_details)

volume:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
    return
  end

  if volume_bracket:query().popup.drawing == "off" then
    volume_bracket:set({ popup = { drawing = true } })
    sbar.exec("SwitchAudioSource -t output -c", function(result)
      local current = result:sub(1, -2)
      sbar.exec("SwitchAudioSource -a -t output", function(available)
        local counter = 0
        for device in string.gmatch(available, '[^\r\n]+') do
          local color = current == device and colors.white or colors.grey
          sbar.add("item", "volume.device." .. counter, {
            position = "popup." .. volume_bracket.name,
            width = popup_width,
            align = "center",
            label = { string = device, color = color },
            click_script = 'SwitchAudioSource -s "' .. device .. '" && sketchybar --set /volume.device\\.*/ label.color=' .. colors.grey .. ' --set $NAME label.color=' .. colors.white
          })
          counter = counter + 1
        end
      end)
    end)
  else
    volume_collapse_details()
  end
end)

volume:subscribe("mouse.scrolled", function(env)
  local delta = env.INFO.delta
  if not (env.INFO.modifier == "ctrl") then delta = delta * 10.0 end
  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end)
