local Gamestate = require 'libs.hump.gamestate'
local wf = require 'libs.windfield.windfield'
local Player = require 'player'
local Enemy = require 'enemy'
local paused = require 'paused'
local game_over = require 'game_over' -- Importar o estado de Game Over
local finished = require 'finished'

local game = {}
local music
local music_files = {
    'assets/st/Metal Storm.mp3',
    'assets/st/Infernal Machinery.mp3',
    'assets/st/Infernal Machinery (1).mp3'
}
game.score = 0

-- Variáveis para efeito de flash
game.flash_active = false
game.flash_timer = 0
game.flash_count = 0
game.flash_max = 3
game.flash_interval = 0.15 -- 3 flashes em ~0.45s
game.flash_on = false

function game:enter()
    if music and music:isPlaying() then
        music:stop()
    end
    local idx = love.math.random(1, #music_files)
    music = love.audio.newSource(music_files[idx], 'stream')
    music:setLooping(true)
    music:play()
function game:leave()
    if music and music:isPlaying() then
        music:stop()
    end
end
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
    self.world:addCollisionClass('EnemyProjectile', {ignores = {'Enemy', 'EnemyProjectile'}}) -- Projéteis inimigos não colidem entre si nem com outros inimigos

    self.player = Player:new(self.world, 50, 480/2 - 15)
    self.enemies = {}
    self.spawn_timer = 0
    self.spawn_interval = 2

    -- Callback de colisão seguro
    self.world:setCallbacks(game.beginContact)
end

game.beginContact = function(a, b, coll)
    local aUserData = a and type(a.getUserData) == 'function' and a:getUserData() or nil
    local bUserData = b and type(b.getUserData) == 'function' and b:getUserData() or nil

    local aClass = aUserData and aUserData.collision_class
    local bClass = bUserData and bUserData.collision_class

    print("Colisão detectada: %s - %s", aClass, bClass)

    if (aClass == 'Player' and bClass == 'Enemy') or
        (aClass == 'Enemy' and bClass == 'Player') then
        -- Lógica de colisão entre jogador e inimigo
        Gamestate.switch(game_over) -- Mudar para o estado de Game Over
        return
    end

    if (aClass == 'EnemyProjectile' and bClass == 'Player') or
        (aClass == 'Player' and bClass == 'EnemyProjectile') then
        -- Lógica de colisão entre jogador e projétil inimigo
        print("player levou dano")
        if not game.flash_active then
            game.flash_active = true
            game.flash_timer = 0
            game.flash_count = 0
            game.flash_on = false
        end
        -- Gamestate.switch(game_over) -- Remova ou comente para não trocar de estado imediatamente
        return
    end

    -- Exemplo: detectar colisão entre projétil do jogador e inimigo
    if (aClass == 'PlayerProjectile' and bClass == 'Enemy') or
        (aClass == 'Enemy' and bClass == 'PlayerProjectile') then
        -- Marcar ambos para destruição, ou lidar com lógica de dano
        aUserData:destroy()
        bUserData:destroy()
        game.score = game.score + 1
        print('Score:', game.score)
        return
    end
end

function game:update(dt)

    self.world:update(dt) -- Atualizar o mundo de física
    self.player:update(dt)

    -- Controle do efeito de flash
    if self.flash_active then
        self.flash_timer = self.flash_timer + dt
        if self.flash_timer >= self.flash_interval then
            self.flash_timer = self.flash_timer - self.flash_interval
            self.flash_on = not self.flash_on
            if self.flash_on then
                self.flash_count = self.flash_count + 1
                if self.flash_count >= self.flash_max then
                    self.flash_active = false
                    self.flash_on = false
                end
            end
        end
    end

    -- Troca para estado finished ao atingir score 10
    if self.score and self.score >= 3 then
        Gamestate.switch(finished)
        return
    end

    -- limpa memoria de inimigos destruidos
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        if enemy.collider:isDestroyed() then
            print('inimigo destruido: %s', enemy)
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

    -- Atualizar inimigos e disparar projéteis (controle agora está em enemy.lua)
    for i = #self.enemies, 1, -1 do
        local enemy = self.enemies[i]
        if enemy.collider and enemy.collider:isDestroyed() then
            table.remove(self.enemies, i)
        else
            enemy.shoot_timer = (enemy.shoot_timer or 0) + dt
            enemy:update(dt)
            if enemy.shoot_timer >= 2 then
                enemy.shoot_timer = 0
                enemy:shootAtPlayer(self.player)
            end
        end
    end

    self:updateParticles(dt) -- Atualizar partículas
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

function game:draw()
    -- Efeito de flash na tela
    if self.flash_on then
        love.graphics.clear(1, 1, 1) -- Branco
    else
        love.graphics.clear(0, 0, 0) -- Preto padrão
    end

    -- Desenhar partículas
    love.graphics.setColor(1, 1, 1)
    for _, p in ipairs(self.particles) do
        love.graphics.circle('fill', p.x, p.y, p.size)
    end


    -- Exibir score
    love.graphics.setColor(1, 1, 1)
    local scoreText = 'Score: ' .. tostring(self.score)
    local sw = love.graphics.getWidth()
    local fw = love.graphics.getFont():getWidth(scoreText)
    love.graphics.print(scoreText, sw - fw - 10, 10)

    self.player:draw()
    for _, e in ipairs(self.enemies) do
        e:draw()
    end

end

return game
