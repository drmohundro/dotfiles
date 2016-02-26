--
-- Window hints
--
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "h", function()
  hs.hints.windowHints()
end)


--
-- Automatic reload
--
function reload_config(files)
  hs.reload()
end
hs.pathwatcher.new(hs.configdir, reload_config):start()
hs.alert.show("Config Re-loaded")
