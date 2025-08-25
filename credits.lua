local Gamestate = require 'libs.hump.gamestate'

local credits = {}

local font = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 32)
function credits:draw()
    love.graphics.setFont(font)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Criado por: Wendel David Przygoda", 0, 480/2-20, 640, 'center')
end

function credits:keypressed(key)
    if key == 'escape' then
        Gamestate.switch(require('menu'))
    end
end

return credits
