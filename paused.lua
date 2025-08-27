local Gamestate = require 'libs.hump.gamestate'

local paused = {}

function paused:draw()
    love.graphics.setColor(1, 1, 1)
    local resume_key = (BUILD_TYPE == 'portable') and 'START' or 'P'
    love.graphics.printf("Game Paused\nPress '" .. resume_key .. "' to Resume", 0, 480 / 2 - 20, 640, 'center')
end

function paused:keypressed(key)
    if key == 'p' then
        Gamestate.pop()
    end
end

function paused:leave()
    -- Limpar referências se necessário
end

return paused
