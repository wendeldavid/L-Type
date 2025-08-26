if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") then
    require("lldebugger").start()
end

local width, height = 640, 480
local Gamestate = require 'libs.hump.gamestate'

local credits = require('credits')
local options = require('options')
local game = require('game')
local menu = require('menu')

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
-- Lê o arquivo build.type e define build_type global
local function load_build_type()
    local f = io.open("build.type", "r")
    if f then
        local t = f:read("*l")
        f:close()
        return t or "desktop"
    end
    return "desktop"
end

BUILD_TYPE = load_build_type()
