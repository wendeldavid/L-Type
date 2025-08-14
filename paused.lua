local Gamestate = require 'libs.hump.gamestate'

local paused = {}

function paused:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Game Paused\nPress 'P' to Resume", 0, 480 / 2 - 20, 640, 'center')
end

function paused:keypressed(key)
    if key == 'p' then
        Gamestate.pop()
    end
end

return paused
