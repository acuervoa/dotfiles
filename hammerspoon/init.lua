local message = require('status-message')

-- Misc setup
hs.window.animationDuration = 0 -- instant window resizing
local vw = hs.inspect.inspect
local configFileWatcher = nil
local appWatcher = nil

-- Keyboard modifiers, Capslock bound to cmd+alt+ctrl+shift via Seil and Karabiner
local modNone  = {""}
local mAlt     = {"⌥"}
local modCmd   = {"⌘"}
local modShift = {"⇧"}
local modHyper = {"⌘", "⌥", "⌃", "⇧"}
local nudgekey = {"⌥", "⌃"}
local yankkey = {"⌥", "⌃","⇧"}
local pushkey = {"⌃", "⌘"}
local shiftpushkey= {"⌃", "⌘", "⇧"}

-- Reload config automatically
function reloadConfig()
  configFileWatcher:stop()
  configFileWatcher = nil
  appWatcher:stop()
  appWatcher = nil
  hs.reload()
 end

configFileWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
configFileWatcher:start()

-- Callback function for application events
function applicationWatcher(appName, eventType, appObject)
  if (eventType == hs.application.watcher.activated) then
    if (appName == "Finder") then
      -- Bring all Finder windows forward when one gets activated
      appObject:selectMenuItem({"Window", "Bring All to Front"})
    end
  end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

-- Cycle args for function when called repeatedly: cycleCalls( fn, { {args1...}, ... } )
function cycleCalls( fn, args )
  local argIndex = 0
  return function()
    argIndex = argIndex + 1
    if (argIndex > #args) then
      argIndex = 1;
    end
    fn( args[ argIndex ] );
  end
end

-- This method used to place a window to a position and size on the screen by using 
-- four floats instead of pixel sizes. Returns the window instance. Examples:
--   windowToGrid( window, 0, 0, 0.25, 0.5 );  -- top-left, width: 25%, height: 50%
--   windowToGrid( someWindow, 0.3, 0.2, 0.5, 0.35 ); -- top: 30%, left: 20%, width: 50%, height: 35%
function windowToGrid( window, rect )
  if not window then
    return window
  end

  local screen = hs.screen.mainScreen():fullFrame()
  window:setFrame( {
    x = math.floor( rect[1] * screen.w + .5 ) + screen.x,
    y = math.floor( rect[2] * screen.h + .5 ) + screen.y,
    w = math.floor( rect[3] * screen.w + .5 ),
    h = math.floor( rect[4] * screen.h + .5 )
  } )
  return window
end

function toGrid( x, y, w, h )
  windowToGrid( hs.window.focusedWindow(), x, y, w, h );
end

-- Toggle between full screen and orginial size. Returns the window instance.
local previousSizes = {}
function toggleMaximize( window )
  if not window then
    return window
  end

  local id = window:id()
  if previousSizes[ id ] == nil then
    previousSizes[ id ] = window:frame()
    window:maximize()
  else
    window:setFrame( previousSizes[ id ] )
    previousSizes[ id ] = nil
  end

  return window
end

windowManagerModal = hs.hotkey.modal.new(modHyper,'w')
windowManagerModal.statusMessage = message.new('Window manager active (Hyper + W)')	

function windowManagerModal:entered() 
  hs.alert.closeAll(); 
  windowManagerModal.statusMessage:show()
  --hs.alert.show( "Window manager active", 999999 )
end

function windowManagerModal:exited() 
  windowManagerModal.statusMessage:hide()
  hs.alert.closeAll() 
end

windowManagerModal:bind('','escape', function() windowManagerModal:exit() end)
windowManagerModal:bind('','return', function() windowManagerModal:exit() end)
windowManagerModal:bind(modHyper,'w', function() windowManagerModal:exit() end)

-- Modal keys
-- Centre window
windowManagerModal:bind('','c',cycleCalls( toGrid, {{0.1,0,0.8,1},{.04, 0, 0.92, 1},{0.22, 0.025, 0.56, 0.95}} ) )
-- Size/position to one side of the screen
windowManagerModal:bind('','left',cycleCalls( toGrid,{{0,0,0.5,1},{0,0,0.6,1},{0,0,0.4,1}}));
windowManagerModal:bind('','right',cycleCalls(toGrid,{{0.5,0,0.5,1},{0.4,0,0.6,1},{0.6,0,0.4,1}}));
windowManagerModal:bind('','up',    function() toGrid( {0, 0,   1, 0.3 } ) end )
windowManagerModal:bind('','down',  function() toGrid( {0, 0.7, 1, 0.3 } ) end )
windowManagerModal:bind('','space', function() toggleMaximize(hs.window.focusedWindow()) end )

-- Non-modal keys
hs.hotkey.bind(modHyper,'space', function() toggleMaximize(hs.window.focusedWindow()) end )


switcher = require "hs.window.switcher"
filter = require "hs.window.filter"
switcher = switcher.new(filter.new():setDefaultFilter{}, {
    selectedThumbnailSize = 288,
    thumbnailSize         = 128,
    showTitles            = false,
    textSize              = 8,
    textColor             = { 1.0, 1.0, 1.0, 0.75 },
    backgroundColor       = { 0.3, 0.3, 0.3, 0.75 },
    highlightColor        = { 0.8, 0.5, 0.0, 0.80 },
    titleBackgroundColor  = { 0.0, 0.0, 0.0, 0.75 },
})
hs.hotkey.bind('alt', 'tab', function() switcher:next() end)
hs.hotkey.bind('alt-shift', 'tab', function() switcher:previous() end)

-- Hints!
hs.hints.fontName           = 'Helvetica-Bold'
hs.hints.fontSize           = 22
hs.hints.showTitleThresh    = 0
hs.hints.hintChars          = { 'A', 'S', 'D', 'F', 'J', 'K', 'L', 'Q', 'W', 'E', 'R', 'Z', 'X', 'C' }
hs.hotkey.bind(modHyper, "H", function() hs.hints.windowHints() end)

-- Move a window between monitors
hs.hotkey.bind(modHyper, "left", function() hs.window.focusedWindow():moveOneScreenWest() end)
hs.hotkey.bind(modHyper, "right", function() hs.window.focusedWindow():moveOneScreenEast() end)
hs.hotkey.bind(modHyper, "down", function() hs.window.focusedWindow():moveOneScreenSouth() end)
hs.hotkey.bind(modHyper, "up", function() hs.window.focusedWindow():moveOneScreenNorth() end)


-- bind application hotkeys
hs.application.enableSpotlightForNameSearches(true)
hs.fnutils.each({
    { key = "t", app = "iTerm" },
    { key = "p", app = "Musicota" },
    { key = "e", app = "Sublime Text" },
    { key = "c", app = "Google Chrome" },
    { key = "f", app = "Finder" },
    { key = 's', app = 'Station'},
    { key = 'v', app = 'com.apple.ActivityMonitor'},
  }, function(item)

    local appActivation = function()
      hs.application.launchOrFocus(item.app)

      local app = hs.appfinder.appFromName(item.app)
      if app then
        app:activate()
        app:unhide()
      end
    end

    hs.hotkey.bind(modHyper, item.key, appActivation)
  end)

hs.alert("Hammerspoon configuration loaded")