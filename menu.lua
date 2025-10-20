local Gamestate = require 'libs.hump.gamestate'
local options = require 'options'
local input = require 'input'

local menu = {selected = 1}
local music

local menuTitleFont = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 64)
local menuFont = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 32)

function menu:enter()
    if not music then
        music = love.audio.newSource('assets/st/main_menu.mp3', 'stream')
        music:setVolume(options.master_volume)
        music:setLooping(true)
    end
    if not music:isPlaying() then
        music:play()
    end

    -- Configurar callbacks de input
    self:setup_input_callbacks()
end

function menu:leave()
    if music and music:isPlaying() then
        music:stop()
    end
    -- Limpar callbacks de input
    input:clear_callbacks()
end

function menu:update(dt)
    -- Atualizar sistema de input (Konami code timeout)
    input:update(dt)
end

function menu:draw()
    -- Render OS info in upper right corner
    love.graphics.setColor(0.7, 0.7, 0.7)
    local osText = "OS: " .. love.system.getOS()
    love.graphics.print(osText, 10, 10)

    local oldFont = love.graphics.getFont()

    love.graphics.setFont(menuTitleFont)
    love.graphics.setColor(0.2, 0.2, 1)
    love.graphics.printf("L-TYPE", 0, 480/2-150, 640, 'center')

    love.graphics.setFont(menuFont)

    local items = {"Play", "Options", "Credits"}
    for i, item in ipairs(items) do
        if self.selected == i then
            love.graphics.setColor(1, 0.7, 0.2)
        else
            love.graphics.setColor(1,1,1)
        end
        love.graphics.printf(item, 0, 480/2-20 + (i-1)*40, 640, 'center')
    end

    love.graphics.setFont(oldFont)
end

-- Configurar callbacks de input
function menu:setup_input_callbacks()
    -- Callback do Konami code
    input:set_konami_callback(function()
        print("Konami code detected")
    end)

    -- Callbacks de navegação (agnósticos ao dispositivo)
    -- Funciona com: ↑/W (teclado), dpup (gamepad), qualquer botão (joystick)
    input:set_callback('navigate_up', function()
        self.selected = self.selected - 1
        if self.selected < 1 then self.selected = 3 end
    end)

    -- Funciona com: ↓/S (teclado), dpdown (gamepad), qualquer botão (joystick)
    input:set_callback('navigate_down', function()
        self.selected = self.selected + 1
        if self.selected > 3 then self.selected = 1 end
    end)

    -- Callback de confirmação (agnóstico ao dispositivo)
    -- Funciona com: Enter/Space (teclado), A/Start (gamepad), botões 1/2 (joystick)
    input:set_callback('confirm', function()
        if self.selected == 1 then
            Gamestate.switch(require('game'))
        elseif self.selected == 2 then
            Gamestate.switch(require('options'))
        elseif self.selected == 3 then
            Gamestate.switch(require('credits'))
        end
    end)

    -- Callback de cancelamento (agnóstico ao dispositivo)
    -- Funciona com: Esc (teclado), Back/Select (gamepad), botões 3/4 (joystick)
    input:set_callback('cancel', function()
        love.event.quit()
    end)
end

return menu
