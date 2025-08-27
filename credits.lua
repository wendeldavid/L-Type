local Gamestate = require 'libs.hump.gamestate'

local credits = {}

local font = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 32)

local flip_timer = 0
local flip_state = true
local flips = 0
local from_finished = false
local can_return = true

function credits:enter(to, previous)
    from_finished = previous and previous.from == 'finished'
    flips = 0
    flip_timer = 0
    flip_state = false
    can_return = not from_finished -- só bloqueia se veio de finished
end

function credits:update(dt)
    flip_timer = flip_timer + dt
    if flip_timer >= 6 then
        flip_timer = flip_timer - 6
        flip_state = not flip_state
        flips = flips + 1
        if from_finished and flips >= 2 then
            can_return = true
        end
    end
end

function credits:draw()
    love.graphics.setFont(font)
    love.graphics.setColor(1,1,1)
    if not flip_state then
        love.graphics.printf("Criado por: Wendel David Przygoda", 0, 480/2-20, 640, 'center')
    else
        love.graphics.printf("Obrigado por jogar!", 0, 480/2-20, 640, 'center')
    end
    if can_return then
        love.graphics.setColor(1,1,0.5)
        local key_name = (BUILD_TYPE == 'portable') and 'SELECT' or 'ESC'
        love.graphics.printf("Pressione " .. key_name .. " para voltar ao menu", 0, 440, 640, 'center')
    end
end

function credits:keypressed(key)
    if key == 'escape' and can_return then
        Gamestate.switch(require('menu'))
    end
end

function credits:leave()
    -- Limpar referências se necessário
end

return credits
