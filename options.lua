local Gamestate = require 'libs.hump.gamestate'
local input = require 'input'

local options = {
    master_volume = 0.5,
    music_volume = 0.1,
    sfx_volume = 0.1
}

local font = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 32)

function options:enter()
    -- Configurar callbacks de input
    self:setup_input_callbacks()
end

function options:leave()
    -- Limpar callbacks de input
    input:clear_callbacks()
end

local getControls = function()
    if BUILD_TYPE == 'portable' then
        return {
            {key = "Direcional ou Analógico esquerdo", action = "Mover a nave"},
            {key = "Y/R2", action = "Atirar"},
            {key = "Analógico direito", action = "Direção do escudo defletor"},
            {key = "Start", action = "Menu/Pausa"},
            {key = "Select", action = "Sair do jogo"},
            {key = "A", action = "Selecionar no menu"},
        }
    end

    if BUILD_TYPE == 'linux' or BUILD_TYPE == 'macos' or BUILD_TYPE == 'windows' then
        return {
            {key = "Setas/WASD", action = "Mover a nave"},
            {key = "B/Y", action = "Atirar"},
            {key = "Mouse", action = "Direção do escudo defletor"},
            {key = "ESC", action = "Menu/Pausa"},
            {key = "P", action = "Pausar o jogo"},
            {key = "Espaço/Enter", action = "Selecionar no menu"},
        }
    end

    if BUILD_TYPE == 'nx' then
        return {
            {key = "Direcional ou Analógico esquerdo", action = "Mover a nave"},
            {key = "Y/ZR", action = "Atirar"},
            {key = "Analógico direito", action = "Direção do escudo defletor"},
            {key = "+", action = "Menu/Pausa"},
            {key = "-", action = "Sair do jogo"},
        }
    end

    -- TODO touch
end

function options:draw()
    love.graphics.setFont(font)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Opções", 0, 40, 640, 'center')
    love.graphics.printf("easy mode", 0, 100, 640, 'center')

    -- Instruções dos controles do jogo (alinhamento justificado)
    local controls = getControls()
    local fontControls = love.graphics.newFont(16)
    love.graphics.setFont(fontControls)
    love.graphics.setColor(1,1,0.7)
    love.graphics.printf("Controles:", 0, 140, 640, 'center')
    love.graphics.setColor(1,1,1)
    local x1, x2 = 50, 400
    for i, c in ipairs(controls) do
        local y = 180 + (i-1) * 22
        love.graphics.printf(c.key, x1, y, 380, 'left')
        love.graphics.printf(c.action, x2, y, 460, 'left')
    end

    options:drawVolumeSlider()
end

function options:drawVolumeSlider()
    -- Slider de volume
    local slider_x = 120
    local slider_y = 400
    local slider_w = 400
    local slider_h = 12
    local handle_radius = 12
    local value = options.master_volume or 0
    -- Desenhar trilho
    love.graphics.setColor(0.1, 0.8, 0.8)
    love.graphics.rectangle('fill', slider_x, slider_y, slider_w, slider_h, 6, 6)
    -- Desenhar handle
    local handle_x = slider_x + value * slider_w
    love.graphics.setColor(1 ,0.8, 0.1)
    love.graphics.circle('fill', handle_x, slider_y + slider_h/2, handle_radius)
    -- Texto do valor
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(font)
    love.graphics.printf(string.format("Volume", math.floor(value*100)), 0, slider_y - 36, 640, 'center')
end

-- Configurar callbacks de input
function options:setup_input_callbacks()
    -- Callback de cancelamento (voltar ao menu)
    input:set_callback('cancel', function()
        Gamestate.switch(require('menu'))
    end)

    -- Callbacks de navegação (ajustar volume)
    input:set_callback('navigate_left', function()
        options.master_volume = math.max(0, (options.master_volume or 0) - 0.05)
        love.audio.setVolume(options.master_volume)
    end)

    input:set_callback('navigate_right', function()
        options.master_volume = math.min(1, (options.master_volume or 0) + 0.05)
        love.audio.setVolume(options.master_volume)
    end)
end

-- Delegar input para o sistema centralizado
function options:keypressed(key)
    input:keypressed(key)
end

function options:joystickpressed(joystick, button)
    input:joystickpressed(joystick, button)
end

function options:gamepadpressed(gamepad, button)
    input:gamepadpressed(gamepad, button)
end

function options:mousepressed(x, y, button)
    input:mousepressed(x, y, button)
end

return options
