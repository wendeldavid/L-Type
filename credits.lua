local Gamestate = require 'libs.hump.gamestate'
local credits = {}

function credits:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.printf("wendel", 0, 480/2-20, 640, 'center')
end

function credits:keypressed(key)
    if key == 'escape' then
        Gamestate.switch(require('menu'))
    end
end

return credits
