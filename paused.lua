local Gamestate = require 'libs.hump.gamestate'

local paused = {}

function paused:draw()
    love.graphics.setColor(1, 1, 1)
    local resume_key = 'START'
    if BUILD_TYPE == 'linux' then resume_key = 'ENTER' end
    if BUILD_TYPE == 'nx' then resume_key = '-' end
    love.graphics.printf("Game Paused\nPress '" .. resume_key .. "' to Resume", 0, 480 / 2 - 20, 640, 'center')
end

function paused:keypressed(key)
    if key == 'p' then
        Gamestate.pop()
    end
end

function paused:gamepadpressed(gamepad, button)
    if button == 'start' then
        Gamestate.pop()
    end
end

function paused:leave()
    -- Limpar referências se necessário
end

return paused
