local Gamestate = require 'libs.hump.gamestate'

local menu = require('menu')

local options = {}

function options:draw()
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
