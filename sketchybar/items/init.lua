local displays = require("helpers.displays")

-- left: workspace pills, app strip, focused window
require("items.spaces")

-- center (wide displays only) and right; right items are laid out right-to-left
local media = require("items.media")
require("items.calendar")
require("items.widgets")
require("items.weather")
require("items.next_event")
media.add_compact()

displays.start()
