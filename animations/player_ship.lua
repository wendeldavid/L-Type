local anim8 = require('libs/anim8/anim8')

local sprite = love.graphics.newImage('assets/sprites/ship_mkI.png')

local animation = {
    sprite = sprite
}

local g = anim8.newGrid(64, 64, sprite:getWidth(), sprite:getHeight())

animation.frames = {
    idle = g(1, 1),
    move = g(1, 2),
}

return animation