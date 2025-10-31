local Gamestate = require 'libs.hump.gamestate'

local game_over = {}

local font = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 32)

function game_over:draw()
    love.graphics.setFont(font)
    love.graphics.setColor(1, 0.2, 0.2)
    local key_name = 'START'
    if BUILD_TYPE == 'linux' then key_name = 'ENTER' end
    if BUILD_TYPE == 'nx' then key_name = '-' end
    love.graphics.printf("Fim de Jogo\nPressione '" .. key_name .. "' para voltar ao menu", 0, 480 / 2 - 20, 640, 'center')
end

function game_over:keypressed(key)
    if key == 'return' then
        Gamestate.switch(require('menu')) -- Voltar ao menu inicial
    end
end

function game_over:leave()
    -- Limpar referências se necessário
end

return game_over
