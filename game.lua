local Gamestate = require 'libs.hump.gamestate'
local wf = require 'libs.windfield.windfield'
local Player = require 'player'
local paused = require 'paused'
local game_over = require 'game_over'
local finished = require 'finished'
local options = require 'options'
local input = require 'input'

local stage_01 = require 'stage-01'

local game = {
    current_stage = stage_01
}
local music
local music_files = {
    'assets/st/Metal Storm.mp3',
    'assets/st/Infernal Machinery.mp3',
    'assets/st/Infernal Machinery (1).mp3',
    'assets/st/Sepultura - Dead Embryonic Cells (Instrumental).mp3'
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

    -- Definir classes de colisão
    self.world:addCollisionClass('Player')
    self.world:addCollisionClass('Enemy', {ignores = {'Enemy'}})
    self.world:addCollisionClass('PlayerProjectile', {ignores = {'Player'}})
    self.world:addCollisionClass('EnemyProjectile', {ignores = {'Enemy', 'EnemyProjectile', 'PlayerProjectile'}})
    self.world:addCollisionClass('Repeller', {ignores = {'Player', 'PlayerProjectile'}})
    self.world:addCollisionClass('Terrain')

    self.player = Player:new(self.world, 50, 480/2 - 15)

    -- Callback de colisão seguro
    self.world:setCallbacks(game.beginContact)

    -- Carregar fonte do FPS uma vez

    self.current_stage:enter(self.world)

    -- Configurar callbacks de input
    self:setup_input_callbacks()
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

    -- Detectar colisão entre projétil inimigo e terreno
    if (aClass == 'EnemyProjectile' and bClass == 'Terrain') or
        (aClass == 'Terrain' and bClass == 'EnemyProjectile') then
        -- Marcar projétil inimigo para destruição ao colidir com terreno
        if aClass == 'EnemyProjectile' and a and type(a.getUserData) == 'function' then
            local ud = a:getUserData() or {}
            ud._to_destroy = true
            a:setUserData(ud)
        elseif bClass == 'EnemyProjectile' and b and type(b.getUserData) == 'function' then
            local ud = b:getUserData() or {}
            ud._to_destroy = true
            b:setUserData(ud)
        end
        return
    end

    -- Detectar colisão entre projétil inimigo e repeller
    if (aClass == 'EnemyProjectile' and bClass == 'Repeller') or (aClass == 'Repeller' and bClass == 'EnemyProjectile') then
        -- Encontrar o player associado ao repeller
        local repellerUserData = (aClass == 'Repeller') and aUserData or bUserData
        local projectileCollider = (aClass == 'EnemyProjectile') and a or b

        if repellerUserData and repellerUserData.parent and repellerUserData.parent.showRepellerOnCollision then
            repellerUserData.parent:showRepellerOnCollision()
        end

        -- Aplicar força de repulsão ao projétil
        if projectileCollider and projectileCollider.getPosition and repellerUserData.parent and repellerUserData.parent.collider then
            local px, py = projectileCollider:getPosition()
            local rx, ry = repellerUserData.parent.collider:getPosition()

            -- Calcular direção de repulsão (do repeller para o projétil)
            local dx, dy = px - rx, py - ry
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist > 0 then
                -- Normalizar direção
                local nx, ny = dx/dist, dy/dist

                -- Calcular força baseada na distância (mais próximo = mais força)
                local min_dist = 20 -- distância mínima para força máxima
                local max_dist = 60 -- distância máxima para força mínima
                local force_multiplier = math.max(0, math.min(1, (max_dist - dist) / (max_dist - min_dist)))

                -- Aplicar força de repulsão
                local base_force = 300
                local force = base_force * force_multiplier
                local fx, fy = nx * force, ny * force

                -- Aplicar impulso linear
                projectileCollider:applyLinearImpulse(fx, fy)

                -- Adicionar um pouco de rotação para efeito visual
                local angular_impulse = (math.random() - 0.5) * 1000
                projectileCollider:applyAngularImpulse(angular_impulse)
            end
        end

        return
    end

    -- print(aClass, bClass)
end

-- Configurar callbacks de input para o jogo
function game:setup_input_callbacks()
    -- Callbacks de controle do jogo (pausa e menu)
    input:set_callback('pause', function()
        Gamestate.push(paused)
    end)

    input:set_callback('cancel', function()
        Gamestate.switch(require('menu'))
    end)
end

function game:update(dt)
    input:update(dt)

    self.world:update(dt) -- Atualizar o mundo de física
    self.player:update(dt)
    self.current_stage:update(dt, self.player, self.world)

    -- Proteger contra update após leave
    if not self.player or not self.world then return end

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


end

function game:keypressed(key)
    -- Usar sistema centralizado para todas as ações
    input:keypressed(key)
end

function game:keyreleased(key)
    -- Usar sistema centralizado para todas as ações
    input:keyreleased(key)
end

function game:joystickpressed(joystick, button)
    -- Usar sistema centralizado para todas as ações
    input:joystickpressed(joystick, button)
end

function game:joystickreleased(joystick, button)
    -- Usar sistema centralizado para todas as ações
    input:joystickreleased(joystick, button)
end

function game:gamepadpressed(gamepad, button)
    -- Usar sistema centralizado para todas as ações
    input:gamepadpressed(gamepad, button)
end

function game:gamepadreleased(gamepad, button)
    -- Usar sistema centralizado para todas as ações
    input:gamepadreleased(gamepad, button)
end

function game:mousepressed(x, y, button)
    input:mousepressed(x, y, button)
end


function game:draw()
    -- Efeito de flash na tela
    if self.flash_on then
        love.graphics.clear(1, 1, 1) -- Branco
    else
        love.graphics.clear(0, 0, 0) -- Preto padrão
    end

    self.current_stage:draw()

    -- Exibir score
    love.graphics.setColor(1, 1, 1)
    local scoreText = 'Score: ' .. tostring(self.score)
    local sw = love.graphics.getWidth()
    local fw = love.graphics.getFont():getWidth(scoreText)
    love.graphics.print(scoreText, sw - fw - 10, 10)

    self.player:draw()

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
    -- Limpar callbacks de input
    input:clear_callbacks()
    -- Limpar referências para liberar memória
    self.world = nil
    self.player = nil
    self.score = 0
    self.flash_active = false
    self.flash_timer = 0
    self.flash_count = 0
    self.flash_on = false
    self._switch_to_game_over = nil
    self._switch_to_finished = nil
end

return game
