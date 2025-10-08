local Gamestate = require 'libs.hump.gamestate'
local wf = require 'libs.windfield.windfield'
local Player = require 'player'
local Enemy = require 'enemy'
local paused = require 'paused'
local game_over = require 'game_over'
local finished = require 'finished'
local options = require 'options'

local stage_01 = require 'stage-01'

local game = {
    current_stage = stage_01
}
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
    self.fpsFont = love.graphics.newFont(28)
    -- Reforçar inicialização de variáveis essenciais
    self.enemies = {}
    self.particles = {}
    if music and music:isPlaying() then
        music:stop()
    end
    local idx = love.math.random(1, #music_files)
    music = love.audio.newSource(music_files[idx], 'stream')
    music:setVolume(options.master_volume)
    music:setLooping(true)
    music:play()

    self.world = wf.newWorld(0, 0, true)
    self.world:setQueryDebugDrawing(false)

    -- Inicializar variáveis de partículas
    self.particle_timer = 0
    self.particle_interval = 0.2
    self.particles = {}

    -- Definir classes de colisão
    self.world:addCollisionClass('Player')
    self.world:addCollisionClass('Enemy', {ignores = {'Enemy'}})
    self.world:addCollisionClass('PlayerProjectile', {ignores = {'Player'}})
    self.world:addCollisionClass('EnemyProjectile', {ignores = {'Enemy', 'EnemyProjectile'}})
    self.world:addCollisionClass('Repeller', {ignores = {'Player', 'PlayerProjectile'}})
    self.world:addCollisionClass('Terrain')

    self.player = Player:new(self.world, 50, 480/2 - 15)
    self.enemies = {}
    self.spawn_timer = 0
    self.spawn_interval = 6

    -- Callback de colisão seguro
    self.world:setCallbacks(game.beginContact)

    -- Carregar imagem do planeta e fonte do FPS uma vez
    self.planet_img = love.graphics.newImage('assets/sprites/planet_1.png')

    self.current_stage:enter(self.world)
end

game.beginContact = function(a, b, coll)
    local aUserData = a and type(a.getUserData) == 'function' and a:getUserData() or nil
    local bUserData = b and type(b.getUserData) == 'function' and b:getUserData() or nil

    local aClass = aUserData and aUserData.collision_class
    local bClass = bUserData and bUserData.collision_class

    if (aClass == 'Player' and bClass == 'Enemy') or
        (aClass == 'Enemy' and bClass == 'Player') then
        -- Marcar para trocar para o estado de Game Over
        game._switch_to_game_over = true
        return
    end

    if (aClass == 'EnemyProjectile' and bClass == 'Player') or
        (aClass == 'Player' and bClass == 'EnemyProjectile') then
        -- Lógica de colisão entre jogador e projétil inimigo
        if aClass == 'EnemyProjectile' and a and type(a.getUserData) == 'function' then
            local ud = a:getUserData() or {}
            ud._to_destroy = true
            a:setUserData(ud)
        elseif bClass == 'EnemyProjectile' and b and type(b.getUserData) == 'function' then
            local ud = b:getUserData() or {}
            ud._to_destroy = true
            b:setUserData(ud)
        end

        if not game.flash_active then
            game.flash_active = true
            game.flash_timer = 0
            game.flash_count = 0
            game.flash_on = false
        end
        return
    end

    -- Exemplo: detectar colisão entre projétil do jogador e inimigo
    if (aClass == 'PlayerProjectile' and bClass == 'Enemy') or
        (aClass == 'Enemy' and bClass == 'PlayerProjectile') then
        -- Marcar ambos para destruição, ou lidar com lógica de dano
        aUserData:destroy()
        bUserData:destroy()
        game.score = game.score + 1
        return
    end

    -- Detectar colisão entre projétil inimigo e repeller
    if (aClass == 'EnemyProjectile' and bClass == 'Repeller') or (aClass == 'Repeller' and bClass == 'EnemyProjectile') then
        -- Encontrar o player associado ao repeller
        local repellerUserData = (aClass == 'Repeller') and aUserData or bUserData
        if repellerUserData and repellerUserData.parent and repellerUserData.parent.showRepellerOnCollision then
            repellerUserData.parent:showRepellerOnCollision()
        end
        -- Marcar projétil inimigo para destruição
        if aClass == 'EnemyProjectile' and a and type(a.getUserData) == 'function' then
            local ud = a:getUserData() or {}
            a:setUserData(ud)
        elseif bClass == 'EnemyProjectile' and b and type(b.getUserData) == 'function' then
            local ud = b:getUserData() or {}
            b:setUserData(ud)
        end
        return
    end

    print(aClass, bClass)
end

function game:update(dt)
    self.world:update(dt) -- Atualizar o mundo de física
    self.player:update(dt)
    self.current_stage:update(dt)

    -- Atualizar posição do planeta (mais devagar)
    if not self.planet_x then
        local screen_w = love.graphics.getWidth()
        self.planet_x = screen_w - 50
    end
    if not self.planet_y then self.planet_y = 240 end
    self.planet_x = self.planet_x - dt * 2 -- velocidade de 2px/s para a esquerda

    -- Proteger contra update após leave
    if not self.enemies or not self.player or not self.world then return end

    -- Destruir projéteis inimigos marcados para destruição (seguro fora do callback)
    if not self.enemies then return end
    for _, enemy in ipairs(self.enemies) do
        if enemy.projectiles then
            for i = #enemy.projectiles, 1, -1 do
                local proj = enemy.projectiles[i]
                if proj.collider and type(proj.collider.getUserData) == 'function' then
                    local ud = proj.collider:getUserData()
                    if ud and ud._to_destroy then
                        proj.collider:destroy()
                        table.remove(enemy.projectiles, i)

                        game.player.lives = game.player.lives - 1
                    end
                end
            end
        end
    end

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

    -- Verifica se o jogador perdeu todas as vidas
    if game.player.lives <= 0 then
        Gamestate.switch(game_over)
    end

    -- Verifica se o jogador alcançou a pontuação para vencer
    if self.score and self.score >= 10 then
        self._switch_to_finished = true
    end

    -- Troca de estado (Game Over ou Finished) fora do callback
    if self._switch_to_game_over then
        self._switch_to_game_over = false
        Gamestate.switch(game_over)
        return
    end
    if self._switch_to_finished then
        self._switch_to_finished = false
        Gamestate.switch(finished)
        return
    end

    if not self.enemies then return end
    local i = 1
    while i <= #self.enemies do
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
            i = i + 1
        end
    end
    -- Spawn de enemies
    self.spawn_timer = self.spawn_timer + dt
    if self.spawn_timer >= self.spawn_interval then
        self.spawn_timer = 0
        local iy = math.random(15, 480-15)
        table.insert(self.enemies, Enemy:new(self.world, 640-40, iy))
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

function game:keyreleased(key)
    self.player:keyreleased(key)
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

    -- Desenhar partículas maiores (atrás do planeta)
    love.graphics.setColor(1, 1, 1)
    for _, p in ipairs(self.particles) do
        if p.size > 2 then
            love.graphics.circle('fill', p.x, p.y, p.size)
        end
    end

    self.current_stage:draw()

    -- Desenhar planeta entre partículas e objetos
    if not self.planet_x then self.planet_x = 320 end
    if not self.planet_y then self.planet_y = 240 end
    local planet_img = self.planet_img
    local pw, ph = planet_img:getWidth(), planet_img:getHeight()
    local px, py = self.planet_x or 320, self.planet_y or 240
    local max_w = 128
    local scale = max_w / pw
    love.graphics.setColor(1,1,1,0.8)
    love.graphics.draw(planet_img, px, py, 0, scale, scale, pw/2, ph/2)
    love.graphics.setColor(1,1,1,1)

    -- Desenhar partículas menores (à frente do planeta)
    for _, p in ipairs(self.particles) do
        if p.size <= 2 then
            love.graphics.circle('fill', p.x, p.y, p.size)
        end
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

    self:drawFPS()

    self.world:draw()
end

function game:drawFPS()
    local fps = love.timer.getFPS()
    local sh = love.graphics.getHeight()
    local oldFont = love.graphics.getFont()
    local fpsFont = self.fpsFont
    love.graphics.setFont(fpsFont)
    local ffh = fpsFont:getHeight()
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("FPS: " .. tostring(fps), 10, sh - ffh - 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(oldFont)
end

function game:leave()
    if music and music:isPlaying() then
        music:stop()
    end
    -- Limpar referências para liberar memória
    self.world = nil
    self.player = nil
    self.enemies = nil
    self.particles = nil
    self.score = 0
    self.flash_active = false
    self.flash_timer = 0
    self.flash_count = 0
    self.flash_on = false
    self._switch_to_game_over = nil
    self._switch_to_finished = nil
end

return game
