local Gamestate = require 'libs.hump.gamestate'
local wf = require 'libs.windfield.windfield'
local Player = require 'player'
local Enemy = require 'enemy'

local game = {}


function game:enter()
    self.world = wf.newWorld(0, 0, true)
    self.world:setQueryDebugDrawing(false)
    self.player = Player:new(self.world, 50, 480/2 - 15)
    self.enemies = {}
    self.player_bullets = {}
    self.enemy_bullets = {}
    self.spawn_timer = 0
    self.spawn_interval = 2
    self.enemy_shoot_interval = 5
end


function game:update(dt)
    self.player:update(dt, require('controls'))
    for i = #self.enemies, 1, -1 do
        self.enemies[i]:update(dt)
        if self.enemies[i].collider:getX() + 15 < 0 then
            self.enemies[i].collider:destroy()
            table.remove(self.enemies, i)
        end
    end
    -- Spawn de inimigos
    self.spawn_timer = self.spawn_timer + dt
    if self.spawn_timer >= self.spawn_interval then
        self.spawn_timer = 0
        local iy = math.random(15, 480-15)
        table.insert(self.enemies, Enemy:new(self.world, 640-40, iy))
    end
end

function game:keypressed(key)
    if key == 'escape' then
        Gamestate.switch(require('menu'))
    end
end

function game:draw()
    self.player:draw()
    for _, e in ipairs(self.enemies) do
        e:draw()
    end
end

return game
