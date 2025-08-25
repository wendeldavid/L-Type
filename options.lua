local Gamestate = require 'libs.hump.gamestate'

local options = {}

local font = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 32)

function options:draw()
    love.graphics.setFont(font)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Opções", 0, 40, 640, 'center')
    love.graphics.printf("easy mode", 0, 480/2, 640, 'center')
end

function options:keypressed(key)
    if key == 'escape' then
        Gamestate.switch(require('menu'))
    end
end

return options
