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

local gp = {
    button = nil,
    pressed = false,
    vibrating = false
}

function love.load()
    love.window.setMode(width, height)
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

function love.draw()
    Gamestate.draw()
    drawInputHistory()
    local joystick_print_index = 100
    if love.joystick.getJoystickCount() > 0 then
        for i = 1, love.joystick.getJoystickCount() do
            local gamepad = love.joystick.getJoysticks()[i]
            love.graphics.print(gamepad:getName() .. " - " .. "Vibration: " .. tostring(gamepad:isVibrationSupported()), 10, joystick_print_index)
            joystick_print_index = joystick_print_index + 20
        end
        love.graphics.print("pressed: " .. (gp.button or "none"), 10, 60)
        if gp.pressed then
            love.graphics.print("vibration ON: " .. tostring(gp.vibrating), 10, 80)
        else
            love.graphics.print("vibration OFF: " .. tostring(gp.vibrating), 10, 80)
        end
    else
        love.graphics.print("No joysticks found", 10, 50)
    end
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

-- function love.keypressed(key)
--     -- TODO: rever como fazer uso do teclado
--     addInput(key)
--     input:keypressed(key)
-- end

function love.joystickpressed(joystick, button)
    addInput('joystick '..button)
    input:joystickpressed(joystick, button)

    gp.button = button
    gp.pressed = true
    gp.vibrating = joystick:setVibration(1, 1)
end

function love.joystickreleased(joystick, button)
    addInput('joystick released '..button)
    input:joystickreleased(joystick, button)

    gp.button = button
    gp.pressed = false
    gp.vibrating = joystick:setVibration(0, 0)
end

function love.gamepadpressed(gamepad, button)
    addInput('gamepad '..button)
    input:gamepadpressed(gamepad, button)

    gp.button = button
    if button == 'x' and gamepad:isVibrationSupported() then
        gp.pressed = true
        gamepad:setVibration(1, 1)
    end
end

function love.gamepadreleased(gamepad, button)
    addInput('gamepad released '..button)
    input:gamepadreleased(gamepad, button)

    gp.button = nil
    if button == 'x' and gamepad:isVibrationSupported() then
        gp.pressed = false
        gamepad:setVibration(0, 0)
    end
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

DEBUG_MODE = false