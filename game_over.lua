local Gamestate = require 'libs.hump.gamestate'

local game_over = {}

function game_over:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Game Over\nPress 'Return' to go back to the menu", 0, 480 / 2 - 20, 640, 'center')
end

function game_over:keypressed(key)
    if key == 'return' then
        Gamestate.switch(require('menu')) -- Voltar ao menu inicial
    end
end

return game_over
