-- Notch-aware display targeting.
--
-- Items register as "notch" (shown only on displays with a camera notch, e.g. the
-- MacBook screen) or "wide" (shown only on displays without one). Assignments are
-- recomputed whenever displays change. Only `display` is touched, so items stay free
-- to toggle their own `drawing`.

local M = { items = { notch = {}, wide = {} } }

local NOTCH_BIN = "$CONFIG_DIR/helpers/notch/bin/notch"
-- Arrangement id that never exists: hides an item whose target set is empty
local NOWHERE = 16

local function apply(groups)
  for kind, items in pairs(M.items) do
    local ids = groups[kind]
    local display = #ids > 0 and table.concat(ids, ",") or NOWHERE
    for _, item in ipairs(items) do
      item:set({ display = display })
    end
  end
end

function M.refresh()
  sbar.exec(NOTCH_BIN, function(notch_out)
    local notched = {}
    for id in tostring(notch_out):gmatch("%d+") do notched[tonumber(id)] = true end

    sbar.exec("sketchybar --query displays", function(displays)
      local groups = { notch = {}, wide = {} }
      for _, d in ipairs(displays) do
        local kind = notched[d.DirectDisplayID] and "notch" or "wide"
        table.insert(groups[kind], d["arrangement-id"])
      end
      apply(groups)
    end)
  end)
end

function M.register(kind, ...)
  for _, item in ipairs({ ... }) do table.insert(M.items[kind], item) end
end

-- Call once after all items have registered
function M.start()
  local watcher = sbar.add("item", "displays.watcher", { drawing = false, updates = true })
  watcher:subscribe({ "display_change", "system_woke", "forced" }, M.refresh)
  M.refresh()
end

return M
