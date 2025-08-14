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
    self.world:addCollisionClass('PlayerProjectile')
    self.world:addCollisionClass('EnemyProjectile') -- Adicionada classe de colisão para projéteis inimigos

    self.player = Player:new(self.world, 50, 480/2 - 15)
    self.player.collider:setCollisionClass('Player') -- Configuração da classe de colisão do jogador
    self.enemies = {}
    self.player_bullets = {}
    self.enemy_bullets = {}
    self.spawn_timer = 0
    self.spawn_interval = 2
    self.enemy_shoot_interval = 5

    -- Callback de colisão
    self.world:setCallbacks(
        function(a, b, coll)
            local aClass = a:getUserData() and a:getUserData().collision_class
            local bClass = b:getUserData() and b:getUserData().collision_class

            -- print("Collision detected between:", aClass, bClass)

            if (aClass == 'Player' and bClass == 'Enemy') or
               (aClass == 'Enemy' and bClass == 'Player') then
                print("Player collided with Enemy")
                Gamestate.switch(game_over) -- Mudar para o estado de Game Over
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
                if collider and collider.collisionEventsClear then
                    collider:collisionEventsClear()
                end
            end
        end
    end

    self.world:update(dt) -- Atualizar o mundo de física
    self.player:update(dt)
    self:updateParticles(dt) -- Atualizar partículas

    for i = #self.enemy_bullets, 1, -1 do
        local bullet = self.enemy_bullets[i]
        if bullet.collider:isDestroyed() then
            table.remove(self.enemy_bullets, i)
        end
    end

    for i = #self.player_bullets, 1, -1 do
        local bullet = self.player_bullets[i]
        if bullet.collider:isDestroyed() then
            table.remove(self.player_bullets, i)
        else
            bullet.collider:setCollisionClass('PlayerProjectile')
        end
    end

    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        if enemy.collider:isDestroyed() then
            table.remove(self.enemies, i)
        else
            enemy.collider:setCollisionClass('Enemy')
        end
    end

    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        enemy:update(dt)
        -- Disparo do inimigo com intervalo variável
        if enemy:canShoot() then
            local ex, ey = enemy.collider:getPosition()
            local bullet = {}
            bullet.collider = self.world:newRectangleCollider(ex-15, ey-3, 12, 6)
            bullet.collider:setType('dynamic')
            bullet.collider:setCollisionClass('EnemyProjectile')
            bullet.speed = 180
            table.insert(self.enemy_bullets, bullet)
            enemy:resetShootTimer(math.random(1, 6)) -- Intervalo variável entre 1 e 6 segundos
        end
        if enemy.collider:getX() + 15 < 0 then
            enemy.collider:destroy()
            table.remove(self.enemies, i)
        end
    end
    -- Spawn de enemies
    self.spawn_timer = self.spawn_timer + dt
    if self.spawn_timer >= self.spawn_interval then
        self.spawn_timer = 0
        local iy = math.random(15, 480-15)
        table.insert(self.enemies, Enemy:new(self.world, 640-40, iy))
    end

    for _, enemy in ipairs(self.enemies) do
        enemy.collider:setCollisionClass('Enemy') -- Configuração da classe de colisão dos inimigos
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
