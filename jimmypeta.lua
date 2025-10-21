local Gamestate = require 'libs.hump.gamestate'
local input = require 'input'

local jimmypeta = {}

local font = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 32)
local jimmypeta_image

function jimmypeta:enter()
    -- Carregar a imagem jimmypeta.png
    jimmypeta_image = love.graphics.newImage('assets/jimmypeta.png')
    -- Configurar callbacks de input
    self:setup_input_callbacks()
end

function jimmypeta:leave()
    -- Limpar callbacks de input
    input:clear_callbacks()
end

function jimmypeta:update(dt)
    -- Atualizar sistema de input
    input:update(dt)
end

function jimmypeta:draw()
    love.graphics.setColor(1, 1, 1)
    -- Desenhar a imagem jimmypeta.png centralizada na tela
    local image_width = jimmypeta_image:getWidth()
    local image_height = jimmypeta_image:getHeight()
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    local x = (screen_width - image_width) / 2
    local y = (screen_height - image_height) / 2
    love.graphics.draw(jimmypeta_image, x, y)
    -- Adicionar texto de instrução para voltar
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 0.5)
    local key_name = (BUILD_TYPE == 'portable') and 'SELECT' or 'ESC'
    love.graphics.printf("Pressione " .. key_name .. " para voltar ao menu", 0, screen_height - 40, screen_width, 'center')
end

-- Configurar callbacks de input
function jimmypeta:setup_input_callbacks()
    -- Callback de cancelamento (voltar ao menu)
    input:set_callback('cancel', function()
        Gamestate.switch(require('menu'))
    end)
end

-- Delegar input para o sistema centralizado
function jimmypeta:keypressed(key)
    input:keypressed(key)
end

function jimmypeta:joystickpressed(joystick, button)
    input:joystickpressed(joystick, button)
end

function jimmypeta:gamepadpressed(gamepad, button)
    input:gamepadpressed(gamepad, button)
end

function jimmypeta:mousepressed(x, y, button)
    input:mousepressed(x, y, button)
end

return jimmypeta
