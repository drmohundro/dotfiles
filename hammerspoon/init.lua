--
-- Window hints
--
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'h', function()
  hs.hints.windowHints()
end)


-- Screen switching
hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'Right', function()
  local win = hs.window.focusedWindow()
  win:moveOneScreenEast(true, true)
end)

hs.hotkey.bind({'ctrl', 'alt', 'cmd'}, 'Left', function()
  local win = hs.window.focusedWindow()
  win:moveOneScreenWest(true, true)
end)


--
-- Automatic reload
--
function reload_config(files)
  hs.reload()
end
hs.pathwatcher.new(hs.configdir, reload_config):start()
hs.alert.show('Config Re-loaded')
