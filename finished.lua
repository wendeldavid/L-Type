local Gamestate = require 'libs.hump.gamestate'

local finished = {}

function finished:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf('parabéns', 0, love.graphics.getHeight()/2 - 20, love.graphics.getWidth(), 'center')
end

function finished:keypressed(key)
    if key == 'return' then
        Gamestate.switch(require('menu')) -- Voltar ao menu inicial
    end
end

return finished
