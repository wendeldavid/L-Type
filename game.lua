local Gamestate = require 'libs.hump.gamestate'
local wf = require 'libs.windfield.windfield'
local Player = require 'player'
local Enemy = require 'enemy'
local paused = require 'paused'
local game_over = require 'game_over' -- Importar o estado de Game Over

local game = {}

function game:enter()
    self.world = wf.newWorld(0, 0, true)
    self.world:setQueryDebugDrawing(false)

    -- Inicializar variáveis de partículas
    self.particle_timer = 0
    self.particle_interval = 0.1
    self.particles = {}

    -- Definir classes de colisão
    self.world:addCollisionClass('Player')
    self.world:addCollisionClass('Enemy', {ignores = {'Enemy'}}) -- Inimigos não colidem entre si
    self.world:addCollisionClass('PlayerProjectile', {ignores = {'Player'}}) -- Projéteis do jogador ignoram o jogador

    self.player = Player:new(self.world, 50, 480/2 - 15)
    self.enemies = {}
    self.spawn_timer = 0
    self.spawn_interval = 2

    -- Callback de colisão
    self.world:setCallbacks(
        function(a, b, coll)
            local aClass = a:getUserData() and a:getUserData().collision_class
            local bClass = b:getUserData() and b:getUserData().collision_class

            print("Collision detected between:", aClass, bClass)

            if (aClass == 'Player' and bClass == 'Enemy') or
               (aClass == 'Enemy' and bClass == 'Player') then
                print("Player collided with Enemy")
                Gamestate.switch(game_over) -- Mudar para o estado de Game Over
            end

            -- Callback de colisão para projéteis do jogador e inimigos
            if (aClass == 'PlayerProjectile' and bClass == 'Enemy') or
               (aClass == 'Enemy' and bClass == 'PlayerProjectile') then
                print("Player projectile hit an enemy")
                a:destroy()
                b:destroy()
                -- Remover inimigos corretamente após a colisão
                for i = #self.enemies, 1, -1 do
                    if self.enemies[i].collider == a or self.enemies[i].collider == b then
                        self.enemies[i].collider:destroy()
                        table.remove(self.enemies, i)
                        break
                    end
                end
            end
        end
    )
end

function game:updateParticles(dt)
    self.particle_timer = self.particle_timer + dt
    if self.particle_timer >= self.particle_interval then
        self.particle_timer = 0
        local particle = {
            x = 640,
            y = math.random(0, 480),
            size = math.random(1, 3),
            speed = math.random(30, 60)
        }
        table.insert(self.particles, particle)
    end

    for i = #self.particles, 1, -1 do
        local p = self.particles[i]
        p.x = p.x - p.speed * dt
        if p.x + p.size < 0 then
            table.remove(self.particles, i)
        end
    end
end

function game:update(dt)
    -- Garantir que eventos de colisão sejam limpos corretamente
    if self.world.collisionEvents then
        for i = #self.world.collisionEvents, 1, -1 do
            local event = self.world.collisionEvents[i]
            if not event.colliderA or not event.colliderB or 
               event.colliderA:isDestroyed() or event.colliderB:isDestroyed() then
                table.remove(self.world.collisionEvents, i)
            end
        end
    end

    -- Garantir que colliders sejam válidos antes de atualizar o mundo
    if self.world and self.world.getBodies then
        for _, body in ipairs(self.world:getBodies()) do
            local fixtures = body:getFixtures()
            if fixtures and #fixtures > 0 then
                local collider = fixtures[1]:getUserData()
                if collider and type(collider.collisionEventsClear) == 'function' then
                    collider:collisionEventsClear()
                end
            end
        end
    end

    self.world:update(dt) -- Atualizar o mundo de física
    self.player:update(dt)
    self:updateParticles(dt) -- Atualizar partículas

    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        if enemy.collider:isDestroyed() then
            table.remove(self.enemies, i)
        else
            enemy:update(dt)
        end
    end

    -- Spawn de enemies
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
    elseif key == 'p' then
        Gamestate.push(paused)
    else
        self.player:keypressed(key)
    end
end

function game:draw()
    -- Desenhar partículas
    love.graphics.setColor(1, 1, 1)
    for _, p in ipairs(self.particles) do
        love.graphics.circle('fill', p.x, p.y, p.size)
    end

    self.player:draw()
    for _, e in ipairs(self.enemies) do
        e:draw()
    end
end

return game
