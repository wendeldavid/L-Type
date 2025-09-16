if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") then
    require("lldebugger").start()
end

local width, height = 640, 480
local Gamestate = require 'libs.hump.gamestate'
local credits = require('credits')
local options = require('options')
local game = require('game')
local menu = require('menu')
local build_type = require('build_type')

-- Register the options, credits, game, and menu states
Gamestate.registerState('options', options)
Gamestate.registerState('credits', credits)
Gamestate.registerState('game', game)
Gamestate.registerState('menu', menu)

function love.load()
    love.window.setMode(width, height)
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

BUILD_TYPE = build_type
