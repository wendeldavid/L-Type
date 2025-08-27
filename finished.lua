local Gamestate = require 'libs.hump.gamestate'

local finished = {}

function finished:draw()
    local menuFont = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 32)
    love.graphics.setFont(menuFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf('Parabéns!!!', 0, love.graphics.getHeight()/2 - 20, love.graphics.getWidth(), 'center')
end

function finished:keypressed(key)
    if key == 'return' then
        Gamestate.switch(require('credits'), {from = 'finished'})
    end
end

function finished:leave()
    -- Limpar referências se necessário
end

return finished
