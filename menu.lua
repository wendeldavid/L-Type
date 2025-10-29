local Gamestate = require 'libs.hump.gamestate'
local options = require 'options'
local input = require 'input'
local jimmypeta_stage = require 'jimmypeta_stage'

local menu = {
    selected = 1,
    konami_progress = 0,
}
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

    -- Konami code local do menu
    if BUILD_TYPE == 'pc' then
        menu.konami_sequence = {'up', 'up', 'down', 'down', 'left', 'right', 'left', 'right', 'b', 'a'}
    elseif BUILD_TYPE == 'portable' or BUILD_TYPE == 'nx' then
        menu.konami_sequence = {'dpup', 'dpup', 'dpdown', 'dpdown', 'dpleft', 'dpright', 'dpleft', 'dpright', 'a', 'b'}
    end
end

function menu:leave()
    if music and music:isPlaying() then
        music:stop()
    end
    -- Limpar callbacks de input
    input:clear_callbacks()
end

function menu:update(dt)
    -- Atualizar sistema de input
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

    local items = {"Play", "Options", "Credits" }
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

-- Função para verificar Konami code localmente no menu
function menu:check_konami_code(input_value)

    -- Verificar se o input corresponde à próxima sequência do Konami code
    local expected_input = self.konami_sequence[self.konami_progress + 1]
    if expected_input and input_value == expected_input then
        self.konami_progress = self.konami_progress + 1

        if self.konami_progress == #self.konami_sequence then
            print("Konami code detected!")
            Gamestate.switch(jimmypeta_stage)
            self.konami_progress = 0
        end
        return true -- Input foi consumido pelo Konami code
    else
        -- Reset do progresso se não for o input esperado
        self.konami_progress = 0
        return false -- Input não foi consumido pelo Konami code
    end
end

-- Configurar callbacks de input
function menu:setup_input_callbacks()
    -- Callbacks de navegação (agnósticos ao dispositivo)
    -- Funciona com: ↑/W (teclado), dpup (gamepad), qualquer botão (joystick)
    input:set_callback('navigate_up', function()
        print("navigate_up")
        self.selected = self.selected - 1
        if self.selected < 1 then self.selected = 3 end
    end)

    -- Funciona com: ↓/S (teclado), dpdown (gamepad), qualquer botão (joystick)
    input:set_callback('navigate_down', function()
        print("navigate_down")
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

-- Handlers de input específicos do menu (com verificação de Konami code)
function menu:keypressed(key)
    -- Verificar Konami code primeiro
    if BUILD_TYPE == 'pc' then
        local konami_consumed = self:check_konami_code(key)
        -- Se o Konami code não consumiu o input, delegar para o sistema de input
        if not konami_consumed then
            -- input:keypressed(key)
        end
    end
end

function menu:joystickpressed(joystick, button)
    -- Verificar Konami code primeiro
    -- local konami_consumed = self:check_konami_code(button)
    -- Se o Konami code não consumiu o input, delegar para o sistema de input
    -- if not konami_consumed then
        -- input:joystickpressed(joystick, button)
    -- end
end

function menu:gamepadpressed(gamepad, button)
    -- Verificar Konami code primeiro
    local konami_consumed = self:check_konami_code(button)
    -- Se o Konami code não consumiu o input, delegar para o sistema de input
    if not konami_consumed then
        -- input:gamepadpressed(gamepad, button)
    end
end

return menu
