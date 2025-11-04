if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") then
    require("lldebugger").start()
end

local width, height = 640, 480
local Gamestate = require 'libs.hump.gamestate'
local credits = require('credits')
local options = require('options')
local input = require('input')
local game = require('game')
local menu = require('menu')
local build_type = require('build_type')

-- Sistema de rastreamento de inputs
local input_history = {}
local max_inputs = 10

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

function love.draw()
    Gamestate.draw()
    drawInputHistory()
end

--

-- Função para adicionar input ao histórico
function addInput(input)
    table.insert(input_history, 1, input)
    if #input_history > max_inputs then
        table.remove(input_history, max_inputs + 1)
    end
end

-- Função para exibir histórico de inputs
function drawInputHistory()
    if #input_history > 0 then
        love.graphics.setColor(1, 1, 1, 0.7)
        local y = height - 20
        local text = "Inputs: "
        for i, input in ipairs(input_history) do
            if i > 1 then
                text = text .. ", "
            end
            text = text .. input
        end
        love.graphics.print(text, 10, y)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function love.keypressed(key)
    addInput(key)
    input:keypressed(key)
end

function love.joystickpressed(joystick, button)
    addInput('joystick '..button)
    input:joystickpressed(joystick, button)
end

function love.gamepadpressed(gamepad, button)
    addInput('gamepad '..button)
    input:gamepadpressed(gamepad, button)
end

function love.gamepadaxis(joystick, axis, value)
    addInput('gamepad axis '..axis..' '..value)
	-- if axis == "leftx" then
	-- 	position.x = width/2 + value*width/2
	-- elseif axis == "lefty" then
	-- 	position.y = height/2 + value*height/2
	-- end
end

BUILD_TYPE = build_type
