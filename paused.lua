local Gamestate = require 'libs.hump.gamestate'
local input = require 'input'

local paused = {}

function paused:draw()
    love.graphics.setColor(1, 1, 1)
    local resume_key = 'START'
    if BUILD_TYPE == 'linux' then resume_key = 'ENTER' end
    if BUILD_TYPE == 'nx' then resume_key = '+' end
    love.graphics.printf("Game Paused\nPress '" .. resume_key .. "' to Resume", 0, 480 / 2 - 20, 640, 'center')
end

function paused:enter()
    -- Limpar callbacks do jogo para não processar ações em pause
    input:clear_callbacks()

    -- Callback para sair do pause
    input:set_callback('pause', function()
        Gamestate.pop()
    end)
    
    -- Permitir sair do pause com o botão de confirmar/start também
    input:set_callback('confirm', function()
        Gamestate.pop()
    end)

    -- Callback para voltar ao menu principal
    input:set_callback('cancel', function()
        Gamestate.pop()
        Gamestate.switch(require('menu'))
    end)
end

function paused:leave()
    input:clear_callbacks()
end

return paused
