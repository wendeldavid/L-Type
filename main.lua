local width, height = 640, 480
local Gamestate = require 'libs.hump.gamestate'

local game = {}
local menu = {selected = 1}
local options = {}
local credits = {}

function menu:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.printf("L-TYPE", 0, height/2-80, width, 'center')
    local items = {"Jogar", "Opções", "Créditos"}
    for i, item in ipairs(items) do
        if self.selected == i then
            love.graphics.setColor(1, 0.7, 0.2)
        else
            love.graphics.setColor(1,1,1)
        end
        love.graphics.printf(item, 0, height/2-20 + (i-1)*40, width, 'center')
    end
end

function menu:keypressed(key)
    if key == 'up' or key == 'w' then
        self.selected = self.selected - 1
        if self.selected < 1 then self.selected = 3 end
    elseif key == 'down' or key == 's' then
        self.selected = self.selected + 1
        if self.selected > 3 then self.selected = 1 end
    elseif key == 'return' or key == 'kpenter' then
        if self.selected == 1 then
            Gamestate.switch(game)
        elseif self.selected == 2 then
            Gamestate.switch(options)
        elseif self.selected == 3 then
            Gamestate.switch(credits)
        end
    elseif key == 'escape' then
        love.event.quit()
    end
function options:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Opções", 0, 40, width, 'center')
end

function options:keypressed(key)
    if key == 'escape' then
        Gamestate.switch(menu)
    end
end

function credits:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Criado por: Wendel David Przygoda", 0, height/2-20, width, 'center')
end

function credits:keypressed(key)
    if key == 'escape' then
        Gamestate.switch(menu)
    end
end
end


local pause = {}

function pause:draw()
    if pause.prev then pause.prev:draw() end
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle('fill', 0, 0, width, height)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("PAUSADO\nPressione START para continuar", 0, height/2-20, width, 'center')
end

function pause:keypressed(key)
    if key == 'return' then
        Gamestate.pop()
    elseif key == 'escape' then
        love.event.quit()
    end
end
-- Partículas visuais (sem hitbox)
local moving_particles = {}
local particle_time = 0
local particle_interval = 0.15


-- Carrega libs externas

local wf = require 'libs.windfield.windfield'
local anim8 = require 'libs.anim8.anim8'

function game:enter()
    moving_particles = {}
    particle_time = 0
    love.graphics.setBackgroundColor(0,0,0)

    -- Mundo de física
    self.world = wf.newWorld(0, 0, true)
    self.world:setQueryDebugDrawing(false)

    -- Define collision classes
    self.world:addCollisionClass('Player')
    self.world:addCollisionClass('Enemy')
    self.world:addCollisionClass('PlayerProjectile', {ignores = {'Player', 'PlayerProjectile'}})
    self.world:addCollisionClass('EnemyProjectile', {ignores = {'Enemy', 'EnemyProjectile'}})

    -- Mapa STI (não utilizado, fundo preto)
    self.map = nil

    -- Jogador
    self.player_ship = self.world:newRectangleCollider(50, height/2 - 15, 30, 30)
    self.player_ship:setType('dynamic')
    self.player_ship.speed = 200
    self.player_ship:setCollisionClass('Player')

    -- player_projectile
    self.player_projectile = {}

    -- enemies
    self.enemies = {}
    self.enemy_projectile = {}
    self.enemy_spawn_time = 0
    self.enemy_spawn_interval = 2
    self.enemy_projectile_interval = 2
end

function game:update(dt)
    -- Partículas brancas (sem hitbox)
    particle_time = particle_time + dt
    if particle_time >= particle_interval then
        particle_time = 0
        local py = math.random(0, height)
        table.insert(moving_particles, {x = width, y = py, r = math.random(1,3)})
    end
    for i = #moving_particles, 1, -1 do
        local p = moving_particles[i]
        p.x = p.x - 30 * dt
        if p.x < -5 then table.remove(moving_particles, i) end
    end
    self.world:update(dt)
    -- Movimento player_ship
    local vx, vy = 0, 0
    if love.keyboard.isDown('up') or love.keyboard.isDown('w') then vy = -self.player_ship.speed end
    if love.keyboard.isDown('down') or love.keyboard.isDown('s') then vy = self.player_ship.speed end
    if love.keyboard.isDown('left') or love.keyboard.isDown('a') then vx = -self.player_ship.speed end
    if love.keyboard.isDown('right') or love.keyboard.isDown('d') then vx = self.player_ship.speed end
    self.player_ship:setLinearVelocity(vx, vy)
    -- Limitar player_ship à tela
    local nx, ny = self.player_ship:getPosition()
    nx = math.max(15, math.min(width-15, nx))
    ny = math.max(15, math.min(height-15, ny))
    self.player_ship:setPosition(nx, ny)

    -- Atualiza player_projectile do jogador
    for i = #self.player_projectile, 1, -1 do
        local t = self.player_projectile[i]
        t.collider:setX(t.collider:getX() + t.speed * dt)
        if t.collider:getX() > width then t.collider:destroy(); table.remove(self.player_projectile, i) end
    end

    -- Atualiza enemies
    for i = #self.enemies, 1, -1 do
        local e = self.enemies[i]
        e.collider:setX(e.collider:getX() - e.speed * dt)
        if e.collider:getX() + 15 < 0 then e.collider:destroy(); table.remove(self.enemies, i) end
    end

    -- Atualiza player_projectile dos enemies
    for i = #self.enemy_projectile, 1, -1 do
        local t = self.enemy_projectile[i]
        t.collider:setX(t.collider:getX() - t.speed * dt)
        if t.collider:getX() + 6 < 0 then t.collider:destroy(); table.remove(self.enemy_projectile, i) end
    end

    -- Spawn de enemies
    self.enemy_spawn_time = self.enemy_spawn_time + dt
    if self.enemy_spawn_time >= self.enemy_spawn_interval then
        self.enemy_spawn_time = 0
        local iy = math.random(15, height-15)
        local inimigo = {}
        inimigo.collider = self.world:newRectangleCollider(width-40, iy, 30, 30)
        inimigo.collider:setType('dynamic')
        inimigo.speed = 80
        inimigo.tempo_tiro = 0
        inimigo.collider:setCollisionClass('Enemy')
        table.insert(self.enemies, inimigo)
    end

    -- projetil dos inimigos
    for _, e in ipairs(self.enemies) do
        e.tempo_tiro = (e.tempo_tiro or 0) + dt
        if e.tempo_tiro >= self.enemy_projectile_interval then
            e.tempo_tiro = 0
            local ex, ey = e.collider:getPosition()
            local tiro = {}
            tiro.collider = self.world:newRectangleCollider(ex-15, ey-3, 12, 6)
            tiro.collider:setType('dynamic')
            tiro.speed = 180
            tiro.collider:setCollisionClass('EnemyProjectile')
            table.insert(self.enemy_projectile, tiro)
        end
    end

    -- Colisão: tiro jogador vs inimigo
    for i = #self.player_projectile, 1, -1 do
        local t = self.player_projectile[i]
        local tx, ty = t.collider:getPosition()
        for j = #self.enemies, 1, -1 do
            local e = self.enemies[j]
            local ex, ey = e.collider:getPosition()
            -- Checagem manual de bounding box
            if math.abs(tx - ex) < (12+30)/2 and math.abs(ty - ey) < (6+30)/2 then
                t.collider:destroy(); table.remove(self.player_projectile, i)
                e.collider:destroy(); table.remove(self.enemies, j)
                break
            end
        end
    end

    -- Colisão: tiro inimigo vs player_ship
    local player_ship_x, player_ship_y = self.player_ship:getPosition()
    for i = #self.enemy_projectile, 1, -1 do
        local t = self.enemy_projectile[i]
        local tx, ty = t.collider:getPosition()
        if math.abs(tx - player_ship_x) < (12+30)/2 and math.abs(ty - player_ship_y) < (6+30)/2 then
            t.collider:destroy(); table.remove(self.enemy_projectile, i)
            Gamestate.switch(game)
            return
        end
    end

    -- Colisão: player_ship vs enemies
    for i = #self.enemies, 1, -1 do
        local e = self.enemies[i]
        local ex, ey = e.collider:getPosition()
        if math.abs(player_ship_x - ex) < (30+30)/2 and math.abs(player_ship_y - ey) < (30+30)/2 then
            e.collider:destroy(); table.remove(self.enemies, i)
            Gamestate.switch(game)
            return
        end
    end
end

function game:keypressed(key)
    if key == 'b' then
        local nx, ny = self.player_ship:getPosition()
        local tiro = {}
        tiro.collider = self.world:newRectangleCollider(nx+15, ny-3, 12, 6)
        tiro.collider:setType('dynamic')
        tiro.speed = 300
        tiro.collider:setCollisionClass('PlayerProjectile')
        table.insert(self.player_projectile, tiro)
    elseif key == 'return' then
        pause.prev = self
        Gamestate.push(pause)
    elseif key == 'escape' then
        Gamestate.switch(menu)
    end
end

function game:draw()
    -- Partículas brancas
    love.graphics.setColor(1,1,1,0.7)
    for _, p in ipairs(moving_particles) do
        love.graphics.circle('fill', p.x, p.y, p.r)
    end
    -- player_ship (azul claro)
    local nx, ny = self.player_ship:getPosition()
    love.graphics.setColor(0.4, 0.7, 1)
    love.graphics.rectangle('line', nx-15, ny-15, 30, 30)

    -- player_projectile do jogador (laranja)
    love.graphics.setColor(1, 0.5, 0)
    for _, t in ipairs(self.player_projectile) do
        local tx, ty = t.collider:getPosition()
        love.graphics.rectangle('line', tx-6, ty-3, 12, 6)
    end

    -- enemies (verde claro)
    love.graphics.setColor(0.3, 1, 0.3)
    for _, e in ipairs(self.enemies) do
        local ex, ey = e.collider:getPosition()
        love.graphics.rectangle('line', ex-15, ey-15, 30, 30)
    end

    -- player_projectile dos enemies (laranja)
    love.graphics.setColor(1, 0.5, 0)
    for _, t in ipairs(self.enemy_projectile) do
        local tx, ty = t.collider:getPosition()
        love.graphics.rectangle('line', tx-6, ty-3, 12, 6)
    end
end

function love.load()
    love.window.setMode(width, height)
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

