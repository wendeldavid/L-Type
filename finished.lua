local Gamestate = require 'libs.hump.gamestate'
local input = require 'input'

local finished = {}

local menuFont = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 32)

function finished:enter()
    input:clear_callbacks()
    finished.from = 'finished'
    local to_credits = function()
        Gamestate.switch(require('credits'))
    end
    input:set_callback('confirm', to_credits)
    input:set_callback('cancel', to_credits)
    input:set_callback('pause', to_credits)
end

function finished:update(dt)
    input:update(dt)
end

function finished:draw()
    love.graphics.setFont(menuFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf('Parabéns!!!', 0, love.graphics.getHeight()/2 - 20, love.graphics.getWidth(), 'center')
end


function finished:leave()
    input:clear_callbacks()
end

return finished
