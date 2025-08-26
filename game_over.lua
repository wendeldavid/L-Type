local Gamestate = require 'libs.hump.gamestate'

local game_over = {}

local font = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 32)

function game_over:draw()
    love.graphics.setFont(font)
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("Game Over\nPress 'Start' to go back to the menu", 0, 480 / 2 - 20, 640, 'center')
end

function game_over:keypressed(key)
    if key == 'return' then
        Gamestate.switch(require('menu')) -- Voltar ao menu inicial
    end
end

return game_over
