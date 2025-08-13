
local largura, altura = 640, 480
local Gamestate = require 'libs.hump.gamestate'

local jogo = {}
local menu = {}

function menu:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.printf("L-TYPE\nPressione ENTER para jogar", 0, altura/2-40, largura, 'center')
end

function menu:keypressed(key)
    if key == 'return' or key == 'kpenter' then
        Gamestate.switch(jogo)
    elseif key == 'escape' then
        love.event.quit()
    end
end


local pause = {}

function pause:draw()
    if pause.prev then pause.prev:draw() end
    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle('fill', 0, 0, largura, altura)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("PAUSADO\nPressione P para continuar", 0, altura/2-20, largura, 'center')
end

function pause:keypressed(key)
    if key == 'p' then
        Gamestate.pop()
    elseif key == 'escape' then
        love.event.quit()
    end
end
-- Partículas visuais (sem hitbox)
local particulas = {}
local tempo_particula = 0
local intervalo_particula = 0.15


-- Carrega libs externas

local wf = require 'libs.windfield.windfield'
local anim8 = require 'libs.anim8.anim8'

function jogo:enter()
    particulas = {}
    tempo_particula = 0
    love.window.setMode(largura, altura)
    love.graphics.setBackgroundColor(0,0,0)

    -- Mundo de física
    self.world = wf.newWorld(0, 0, true)
    self.world:setQueryDebugDrawing(false)

    -- Mapa STI (não utilizado, fundo preto)
    self.map = nil

    -- Jogador
    self.nave = self.world:newRectangleCollider(50, altura/2 - 15, 30, 30)
    self.nave:setType('dynamic')
    self.nave.speed = 200

    -- Tiros
    self.tiros = {}

    -- Inimigos
    self.inimigos = {}
    self.tiros_inimigos = {}
    self.tempo_spawn = 0
    self.intervalo_spawn = 2
    self.intervalo_tiro_inimigo = 5
end

function jogo:update(dt)
    -- Partículas brancas (sem hitbox)
    tempo_particula = tempo_particula + dt
    if tempo_particula >= intervalo_particula then
        tempo_particula = 0
        local py = math.random(0, altura)
        table.insert(particulas, {x = largura, y = py, r = math.random(1,3)})
    end
    for i = #particulas, 1, -1 do
        local p = particulas[i]
        p.x = p.x - 30 * dt
        if p.x < -5 then table.remove(particulas, i) end
    end
    self.world:update(dt)
    -- Movimento nave
    local vx, vy = 0, 0
    if love.keyboard.isDown('up') then vy = -self.nave.speed end
    if love.keyboard.isDown('down') then vy = self.nave.speed end
    if love.keyboard.isDown('left') then vx = -self.nave.speed end
    if love.keyboard.isDown('right') then vx = self.nave.speed end
    self.nave:setLinearVelocity(vx, vy)
    -- Limitar nave à tela
    local nx, ny = self.nave:getPosition()
    nx = math.max(15, math.min(largura-15, nx))
    ny = math.max(15, math.min(altura-15, ny))
    self.nave:setPosition(nx, ny)

    -- Atualiza tiros do jogador
    for i = #self.tiros, 1, -1 do
        local t = self.tiros[i]
        t.collider:setX(t.collider:getX() + t.speed * dt)
        if t.collider:getX() > largura then t.collider:destroy(); table.remove(self.tiros, i) end
    end

    -- Atualiza inimigos
    for i = #self.inimigos, 1, -1 do
        local e = self.inimigos[i]
        e.collider:setX(e.collider:getX() - e.speed * dt)
        if e.collider:getX() + 15 < 0 then e.collider:destroy(); table.remove(self.inimigos, i) end
    end

    -- Atualiza tiros dos inimigos
    for i = #self.tiros_inimigos, 1, -1 do
        local t = self.tiros_inimigos[i]
        t.collider:setX(t.collider:getX() - t.speed * dt)
        if t.collider:getX() + 6 < 0 then t.collider:destroy(); table.remove(self.tiros_inimigos, i) end
    end

    -- Spawn de inimigos
    self.tempo_spawn = self.tempo_spawn + dt
    if self.tempo_spawn >= self.intervalo_spawn then
        self.tempo_spawn = 0
        local iy = math.random(15, altura-15)
        local inimigo = {}
        inimigo.collider = self.world:newRectangleCollider(largura-40, iy, 30, 30)
        inimigo.collider:setType('dynamic')
        inimigo.speed = 80
        inimigo.tempo_tiro = 0
        table.insert(self.inimigos, inimigo)
    end

    -- Tiros dos inimigos
    for _, e in ipairs(self.inimigos) do
        e.tempo_tiro = (e.tempo_tiro or 0) + dt
        if e.tempo_tiro >= self.intervalo_tiro_inimigo then
            e.tempo_tiro = 0
            local ex, ey = e.collider:getPosition()
            local tiro = {}
            tiro.collider = self.world:newRectangleCollider(ex-15, ey-3, 12, 6)
            tiro.collider:setType('dynamic')
            tiro.speed = 180
            table.insert(self.tiros_inimigos, tiro)
        end
    end

    -- Colisão: tiro jogador vs inimigo
    for i = #self.tiros, 1, -1 do
        local t = self.tiros[i]
        local tx, ty = t.collider:getPosition()
        for j = #self.inimigos, 1, -1 do
            local e = self.inimigos[j]
            local ex, ey = e.collider:getPosition()
            -- Checagem manual de bounding box
            if math.abs(tx - ex) < (12+30)/2 and math.abs(ty - ey) < (6+30)/2 then
                t.collider:destroy(); table.remove(self.tiros, i)
                e.collider:destroy(); table.remove(self.inimigos, j)
                break
            end
        end
    end

    -- Colisão: tiro inimigo vs nave
    local nave_x, nave_y = self.nave:getPosition()
    for i = #self.tiros_inimigos, 1, -1 do
        local t = self.tiros_inimigos[i]
        local tx, ty = t.collider:getPosition()
        if math.abs(tx - nave_x) < (12+30)/2 and math.abs(ty - nave_y) < (6+30)/2 then
            t.collider:destroy(); table.remove(self.tiros_inimigos, i)
            Gamestate.switch(jogo)
            return
        end
    end

    -- Colisão: nave vs inimigos
    for i = #self.inimigos, 1, -1 do
        local e = self.inimigos[i]
        local ex, ey = e.collider:getPosition()
        if math.abs(nave_x - ex) < (30+30)/2 and math.abs(nave_y - ey) < (30+30)/2 then
            e.collider:destroy(); table.remove(self.inimigos, i)
            Gamestate.switch(jogo)
            return
        end
    end
end

function jogo:keypressed(key)
    if key == 'space' then
        local nx, ny = self.nave:getPosition()
        local tiro = {}
        tiro.collider = self.world:newRectangleCollider(nx+15, ny-3, 12, 6)
        tiro.collider:setType('dynamic')
        tiro.speed = 300
        table.insert(self.tiros, tiro)
    elseif key == 'p' then
        pause.prev = self
        Gamestate.push(pause)
    elseif key == 'escape' then
        Gamestate.switch(menu)
    end
end

function jogo:draw()
    -- Partículas brancas
    love.graphics.setColor(1,1,1,0.7)
    for _, p in ipairs(particulas) do
        love.graphics.circle('fill', p.x, p.y, p.r)
    end
    -- Nave (azul claro)
    local nx, ny = self.nave:getPosition()
    love.graphics.setColor(0.4, 0.7, 1)
    love.graphics.rectangle('line', nx-15, ny-15, 30, 30)

    -- Tiros do jogador (laranja)
    love.graphics.setColor(1, 0.5, 0)
    for _, t in ipairs(self.tiros) do
        local tx, ty = t.collider:getPosition()
        love.graphics.rectangle('line', tx-6, ty-3, 12, 6)
    end

    -- Inimigos (verde claro)
    love.graphics.setColor(0.3, 1, 0.3)
    for _, e in ipairs(self.inimigos) do
        local ex, ey = e.collider:getPosition()
        love.graphics.rectangle('line', ex-15, ey-15, 30, 30)
    end

    -- Tiros dos inimigos (laranja)
    love.graphics.setColor(1, 0.5, 0)
    for _, t in ipairs(self.tiros_inimigos) do
        local tx, ty = t.collider:getPosition()
        love.graphics.rectangle('line', tx-6, ty-3, 12, 6)
    end
end

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

