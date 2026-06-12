-- -----------------------------------------------------------------------
--                         ** Something Global **                       --
-- -----------------------------------------------------------------------
-- Comment out this following line if you wish to see animations
local windowMeta = {}
window = require('hs.window')
hs.window.animationDuration = 0
grid = require('hs.grid')
grid.setMargins('8, 8')

module = {}

-- Height of sketchybar on external screens where macOS doesn't inset it automatically
local sketchybarHeight = 37

local lastFrames = {}

local function setupScreens()
  screens = hs.screen.allScreens()
  screenArr = {}
  indexDiff = 0
  lastFrames = {}

  for index = 1, #screens do
    local xIndex, yIndex = screens[index]:position()
    screenArr[xIndex] = screens[index]
  end

  hs.fnutils.each(screenArr, function(e)
    local currentIndex = hs.fnutils.indexOf(screenArr, e)
    if currentIndex < 0 and currentIndex < indexDiff then
      indexDiff = currentIndex
    end
  end)

  for _index, screen in pairs(screens) do
    local sf = screen:frame()
    local ratio = sf.w / sf.h

    local gridSize
    if ratio > 2 then
      gridSize = '10 * 4'
    elseif sf.w < sf.h then
      gridSize = '4 * 8'
    else
      gridSize = '8 * 4'
    end

    local alreadyInset = screen:frame().y - screen:fullFrame().y
    local extraPadding = math.max(0, sketchybarHeight - alreadyInset)
    if extraPadding > 0 then
      local paddedFrame = hs.geometry(sf.x, sf.y + extraPadding, sf.w, sf.h - extraPadding)
      grid.setGrid(gridSize, screen, paddedFrame)
    else
      grid.setGrid(gridSize, screen)
    end

    lastFrames[screen:getUUID()] = sf
  end
end

-- Set screen watcher, in case you connect a new monitor, or unplug a monitor
screens = {}
screenArr = {}
local screenwatcher = hs.screen.watcher.new(setupScreens)
screenwatcher:start()

setupScreens()

-- Some constructors, just for programming
function Cell(x, y, w, h)
  return hs.geometry(x, y, w, h)
end

local function isGridStale(screen)
  local cached = lastFrames[screen:getUUID()]
  if not cached then return true end
  local current = screen:frame()
  return cached.x ~= current.x
    or cached.y ~= current.y
    or cached.w ~= current.w
    or cached.h ~= current.h
end

-- Bind new method to windowMeta
function windowMeta.new()
  local self = setmetatable(windowMeta, {
    -- Treat table like a function
    -- Event listener when windowMeta() is called
    __call = function(cls, ...)
      return cls.new(...)
    end,
  })

  local focused = window.focusedWindow()
  if not focused then
    return nil
  end

  self.window = focused
  self.screen = focused:screen()

  if isGridStale(self.screen) then
    setupScreens()
  end

  self.windowGrid = grid.get(self.window)
  self.screenGrid = grid.getGrid(self.screen)

  return self
end

-- -----------------------------------------------------------------------
--                   ** ALERT: GEEKS ONLY, GLHF  :C **                  --
--            ** Keybinding configurations locate at bottom **          --
-- -----------------------------------------------------------------------

module.maximizeWindow = function()
  local this = windowMeta.new()
  if not this then return end
  hs.grid.maximizeWindow(this.window)
end

module.centerOnScreen = function()
  local this = windowMeta.new()
  if not this then return end
  this.window:centerOnScreen(this.screen)
end

module.throwLeft = function()
  local this = windowMeta.new()
  if not this then return end
  this.window:moveToScreen(this.screen:toWest())
end

module.throwRight = function()
  local this = windowMeta.new()
  if not this then return end
  this.window:moveToScreen(this.screen:toEast())
end

module.leftHalf = function()
  local this = windowMeta.new()
  if not this then return end
  local cell = Cell(0, 0, 0.5 * this.screenGrid.w, this.screenGrid.h)
  grid.set(this.window, cell, this.screen)
end

module.rightHalf = function()
  local this = windowMeta.new()
  if not this then return end
  local cell = Cell(0.5 * this.screenGrid.w, 0, 0.5 * this.screenGrid.w, this.screenGrid.h)
  grid.set(this.window, cell, this.screen)
end

-- Windows-like cycle left
module.cycleLeft = function()
  local this = windowMeta.new()
  if not this then return end
  -- Check if this window is on left or right
  if this.windowGrid.x == 0 then
    local currentIndex = hs.fnutils.indexOf(screenArr, this.screen)
    local previousScreen = screenArr[(currentIndex - indexDiff - 1) % #hs.screen.allScreens() + indexDiff]
    this.window:moveToScreen(previousScreen)
    module.rightHalf()
  else
    module.leftHalf()
  end
end

-- Windows-like cycle right
module.cycleRight = function()
  local this = windowMeta.new()
  if not this then return end
  -- Check if this window is on left or right
  if this.windowGrid.x == 0 then
    module.rightHalf()
  else
    local currentIndex = hs.fnutils.indexOf(screenArr, this.screen)
    local nextScreen = screenArr[(currentIndex - indexDiff + 1) % #hs.screen.allScreens() + indexDiff]
    this.window:moveToScreen(nextScreen)
    module.leftHalf()
  end
end

module.topHalf = function()
  local this = windowMeta.new()
  if not this then return end
  local cell = Cell(0, 0, this.screenGrid.w, 0.5 * this.screenGrid.h)
  grid.set(this.window, cell, this.screen)
end

module.bottomHalf = function()
  local this = windowMeta.new()
  if not this then return end
  local cell = Cell(0, 0.5 * this.screenGrid.h, this.screenGrid.w, 0.5 * this.screenGrid.h)
  grid.set(this.window, cell, this.screen)
end

module.rightToLeft = function()
  local this = windowMeta.new()
  if not this then return end
  local cell = Cell(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w - 1, this.windowGrid.h)
  if this.windowGrid.w > 1 then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show('Small Enough :)')
  end
end

module.rightToRight = function()
  local this = windowMeta.new()
  if not this then return end
  local cell = Cell(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w + 1, this.windowGrid.h)
  if this.windowGrid.w < this.screenGrid.w - this.windowGrid.x then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show('Touching Right Edge :|')
  end
end

module.bottomUp = function()
  local this = windowMeta.new()
  if not this then return end
  local cell = Cell(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w, this.windowGrid.h - 1)
  if this.windowGrid.h > 1 then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show('Small Enough :)')
  end
end

module.bottomDown = function()
  local this = windowMeta.new()
  if not this then return end
  local cell = Cell(this.windowGrid.x, this.windowGrid.y, this.windowGrid.w, this.windowGrid.h + 1)
  if this.windowGrid.h < this.screenGrid.h - this.windowGrid.y then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show('Touching Bottom Edge :|')
  end
end

module.leftToLeft = function()
  local this = windowMeta.new()
  if not this then return end
  local cell = Cell(this.windowGrid.x - 1, this.windowGrid.y, this.windowGrid.w + 1, this.windowGrid.h)
  if this.windowGrid.x > 0 then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show('Touching Left Edge :|')
  end
end

module.leftToRight = function()
  local this = windowMeta.new()
  if not this then return end
  local cell = Cell(this.windowGrid.x + 1, this.windowGrid.y, this.windowGrid.w - 1, this.windowGrid.h)
  if this.windowGrid.w > 1 then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show('Small Enough :)')
  end
end

module.topUp = function()
  local this = windowMeta.new()
  if not this then return end
  local cell = Cell(this.windowGrid.x, this.windowGrid.y - 1, this.windowGrid.w, this.windowGrid.h + 1)
  if this.windowGrid.y > 0 then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show('Touching Top Edge :|')
  end
end

module.topDown = function()
  local this = windowMeta.new()
  if not this then return end
  local cell = Cell(this.windowGrid.x, this.windowGrid.y + 1, this.windowGrid.w, this.windowGrid.h - 1)
  if this.windowGrid.h > 1 then
    grid.set(this.window, cell, this.screen)
  else
    hs.alert.show('Small Enough :)')
  end
end

return module
