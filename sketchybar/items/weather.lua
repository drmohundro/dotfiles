local colors = require("colors")
local settings = require("settings")

-- Weather code → SF Symbol mapping
local function weather_icon(code)
  local c = tonumber(code)
  if c == 113 then return "􀆮"       -- sun.max.fill (Sunny/Clear)
  elseif c == 116 then return "􀇤"   -- cloud.sun.fill (Partly cloudy)
  elseif c == 119 then return "􀇧"   -- cloud.fill (Cloudy)
  elseif c == 122 then return "􀇧"   -- cloud.fill (Overcast)
  elseif c == 143 or c == 248 or c == 260 then return "􀇴" -- cloud.fog.fill
  elseif c >= 176 and c <= 186 then return "􀇵"  -- cloud.drizzle.fill
  elseif c >= 200 and c <= 202 then return "􀇼"  -- cloud.bolt.rain.fill (Thundery)
  elseif c >= 227 and c <= 230 then return "􀇸"  -- cloud.snow.fill
  elseif c >= 263 and c <= 266 then return "􀇵"  -- cloud.drizzle.fill (Light drizzle)
  elseif c >= 281 and c <= 284 then return "􀇵"  -- cloud.drizzle.fill (Freezing drizzle)
  elseif c >= 293 and c <= 296 then return "􀇶"  -- cloud.rain.fill (Light rain)
  elseif c >= 299 and c <= 305 then return "􀇶"  -- cloud.rain.fill (Moderate rain)
  elseif c >= 308 and c <= 314 then return "􀇷"  -- cloud.heavyrain.fill
  elseif c >= 317 and c <= 323 then return "􀇻"  -- cloud.sleet.fill
  elseif c >= 326 and c <= 338 then return "􀇸"  -- cloud.snow.fill
  elseif c >= 350 and c <= 353 then return "􀇵"  -- cloud.drizzle.fill
  elseif c >= 356 and c <= 359 then return "􀇶"  -- cloud.rain.fill
  elseif c >= 362 and c <= 368 then return "􀇻"  -- cloud.sleet.fill
  elseif c >= 371 and c <= 374 then return "􀇸"  -- cloud.snow.fill
  elseif c >= 386 and c <= 389 then return "􀇼"  -- cloud.bolt.rain.fill
  elseif c >= 392 and c <= 395 then return "􀇽"  -- cloud.bolt.snow.fill
  else return "􀇤" end
end

local weather = sbar.add("item", "weather", {
  position = "right",
  drawing = false,
  scroll_texts = false,
  update_freq = 900,
  icon = {
    color = colors.blue,
    font = { size = 14.0 },
    padding_left = 8,
    padding_right = 4,
  },
  label = {
    color = colors.white,
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 12.0,
    },
    padding_right = 8,
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
  popup = { align = "right" },
})

sbar.add("item", "weather.padding", {
  position = "right",
  width = settings.group_paddings,
})

local popup_items = {}

local function clear_popup()
  for _, item in ipairs(popup_items) do
    sbar.remove(item)
  end
  popup_items = {}
end

local CACHE = "/tmp/sketchybar_weather.json"
local CACHE_TTL = 900  -- seconds (15 min)

-- Shell extracts only needed fields, keeping exec output tiny
local PARSE_CMD = string.format([[
  CACHE=%s
  AGE=$(( $(date +%%s) - $(stat -f %%m "$CACHE" 2>/dev/null || echo 0) ))
  if [ ! -f "$CACHE" ] || [ "$AGE" -gt %d ]; then
    curl -sf 'https://wttr.in/?format=j1' > "$CACHE" || exit 1
  fi
  python3 -c "
import json, sys
d = json.load(open('$CACHE'))
cc = d['current_condition'][0]
w  = d['weather'][0]
print(cc['temp_F'])
print(cc['weatherCode'])
print(cc['weatherDesc'][0]['value'])
print(cc['humidity'])
print(cc['windspeedMiles'])
print(w['maxtempF'])
print(w['mintempF'])
"]], CACHE, CACHE_TTL)

local function update()
  sbar.exec(PARSE_CMD, function(result)
    local lines = {}
    for line in result:gmatch("[^\n]+") do table.insert(lines, line) end
    if #lines < 7 then return end

    local data = {
      temp_f   = lines[1],
      code     = lines[2],
      desc     = lines[3],
      humidity = lines[4],
      wind     = lines[5],
      max_f    = lines[6],
      min_f    = lines[7],
    }
    if not data.temp_f then return end

    weather:set({
      drawing = true,
      icon = { string = weather_icon(data.code) },
      label = { string = data.temp_f .. "°F" },
    })

    -- Rebuild popup
    clear_popup()

    local function add_popup(name, icon_str, label_str)
      local item = "weather.popup." .. name
      sbar.add("item", item, {
        position = "popup." .. weather.name,
        icon = { string = icon_str, color = colors.grey, width = 20 },
        label = { string = label_str, color = colors.white },
        click_script = "sketchybar --set weather popup.drawing=off",
      })
      table.insert(popup_items, item)
    end

    add_popup("desc",     "􀇤",  data.desc or "")
    add_popup("hilo",     "􀄨",  "H:" .. (data.max_f or "?") .. "°  L:" .. (data.min_f or "?") .. "°")
    add_popup("humidity", "􀇪",  "Humidity: " .. (data.humidity or "?") .. "%")
    add_popup("wind",     "􀇬",  "Wind: " .. (data.wind or "?") .. " mph")
  end)
end

weather:subscribe({"forced", "routine", "system_woke"}, function(_)
  update()
end)

weather:subscribe("mouse.clicked", function(_)
  weather:set({ popup = { drawing = "toggle" } })
end)

weather:subscribe("mouse.exited.global", function(_)
  weather:set({ popup = { drawing = false } })
end)
