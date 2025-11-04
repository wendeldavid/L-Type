-- Stage-01 herda comportamentos de game.lua e adiciona o mapa
local sti = require("libs.Simple-Tiled-Implementation.sti.init")

local Enemy = require 'enemy'

local stage = {
    map_offset = 0,
    colliders = {},
    planet_img = nil,
    planet_x = nil,
    planet_y = nil,
    particles = {},
    particle_timer = 0,
    particle_interval = 0.2,
    enemies = {},
    enemy_projectiles = {},
    spawn_timer = 0,
    spawn_interval = 6,
    map_width_pixels = 0,
    screen_width = 0,
    stage_finished = false
}

function stage:enter(world)
	self.map = sti("assets/stages/stg-01.lua")

    -- Calcular largura do mapa em pixels
    self.map_width_pixels = self.map.width * self.map.tilewidth
    self.screen_width = love.graphics.getWidth()
    self.stage_finished = false

    -- Carregar imagem do planeta
    self.planet_img = love.graphics.newImage('assets/sprites/planet_1.png')

    -- Inicializar posição do planeta
    local screen_w = love.graphics.getWidth()
    self.planet_x = screen_w - 50
    self.planet_y = 240

    -- Inicializar variáveis de partículas
    self.particle_timer = 0
    self.particle_interval = 0.2
    self.particles = {}

    -- Inicializar variáveis de inimigos
    self.enemies = {}
    self.enemy_projectiles = {}
    self.spawn_timer = 0
    self.spawn_interval = 20

    stage.terraincolliders = {}
    for _, obj in ipairs(self.map.layers["terrain_layer"].objects) do
        if obj.type == "Terrain" then
            if obj.shape == "polygon" then
                local vertices = {}
                for _, vertex in ipairs(obj.polygon) do
                    table.insert(vertices, vertex.x)
                    table.insert(vertices, vertex.y)
                end
                local collider = world:newPolygonCollider(vertices)
                collider:setType("static")
                collider:setCollisionClass(obj.type)
                table.insert(stage.colliders, collider)
            end
            if obj.shape == "rectangle" then
                local collider = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
                collider:setType("static")
                collider:setCollisionClass(obj.type)
                table.insert(stage.colliders, collider)
            end
        end
    end
end

function stage:update(dt, player, world)
	if self.map then self.map:update(dt) end

	-- Verificar se o estágio chegou ao fim
	-- O estágio termina quando todo o mapa já passou pela tela
	-- map_offset negativo = mapa rolando para a esquerda
	-- Quando -map_offset >= (largura_do_mapa - largura_da_tela), o estágio terminou
	local max_offset = -(self.map_width_pixels - self.screen_width)
	if not self.stage_finished and self.map_offset <= max_offset then
		self.stage_finished = true
		self.map_offset = max_offset -- Garantir que não passe do limite
	end

	-- Move o mapa da direita para a esquerda apenas se o estágio não terminou
	if not self.stage_finished then
		self.map_offset = self.map_offset - (dt * 10) -- velocidade 10px/s
	end

    -- Atualizar posição do planeta (mais devagar)
    if not self.stage_finished then
        self.planet_x = self.planet_x - dt * 2 -- velocidade de 2px/s para a esquerda
    end

    -- Atualizar partículas
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

    -- Mover colliders apenas se o estágio não terminou
    if not self.stage_finished then
        for _, collider in ipairs(stage.colliders) do
            local x, y = collider:getPosition()
            collider:setPosition(x - (dt * 10), y)
        end
    end

    -- Atualizar inimigos
    if player then
        local i = 1
        while i <= #self.enemies do
            local enemy = self.enemies[i]
            if enemy.collider and enemy.collider:isDestroyed() then
                table.remove(self.enemies, i)
            else
                enemy.shoot_timer = (enemy.shoot_timer or 0) + dt
                -- Apenas mover o inimigo, não atualizar projéteis aqui
                enemy.collider:setX(enemy.collider:getX() - enemy.speed * dt)
                if enemy.shoot_timer >= 2 then
                    enemy.shoot_timer = 0
                    local projectile = enemy:shootAtPlayer(player)
                    table.insert(self.enemy_projectiles, projectile)
                end
                i = i + 1
            end
        end

        -- Atualizar todos os projéteis inimigos independentemente do inimigo estar vivo
        for i = #self.enemy_projectiles, 1, -1 do
            local proj = self.enemy_projectiles[i]
            if proj.collider and not proj.collider:isDestroyed() then
                -- Verificar se o projétil foi marcado para destruição
                local ud = proj.collider:getUserData()
                if ud and ud._to_destroy then
                    proj.collider:destroy()
                    table.remove(self.enemy_projectiles, i)
                else
                    proj:update(dt)
                    -- projectile out of screen
                    if proj.collider:getX() < 0 or proj.collider:getX() > 640 or proj.collider:getY() < 0 or proj.collider:getY() > 480 then
                        proj.collider:destroy()
                        table.remove(self.enemy_projectiles, i)
                    end
                end
            else
                table.remove(self.enemy_projectiles, i)
            end
        end

        -- Spawn de enemies apenas se o estágio não terminou
        if not self.stage_finished then
            self.spawn_timer = self.spawn_timer + dt
            if self.spawn_timer >= self.spawn_interval then
                self.spawn_timer = 0
                local iy = math.random(15, 480-15)
                table.insert(self.enemies, Enemy:new(world, 640-40, iy))
            end
        end
    end
end

function stage:draw()
    -- Desenhar partículas maiores (atrás do planeta)
    love.graphics.setColor(1, 1, 1)
    for _, p in ipairs(self.particles) do
        if p.size > 2 then
            love.graphics.circle('fill', p.x, p.y, p.size)
        end
    end

    -- Desenhar o mapa com offset
    self.map:draw(self.map_offset, 0)

    -- Desenhar planeta
    if self.planet_img and self.planet_x and self.planet_y then
        local pw, ph = self.planet_img:getWidth(), self.planet_img:getHeight()
        local px, py = self.planet_x, self.planet_y
        local max_w = 128
        local scale = max_w / pw
        love.graphics.setColor(1,1,1,0.8)
        love.graphics.draw(self.planet_img, px, py, 0, scale, scale, pw/2, ph/2)
        love.graphics.setColor(1,1,1,1)
    end

    -- Desenhar partículas menores (à frente do planeta)
    for _, p in ipairs(self.particles) do
        if p.size <= 2 then
            love.graphics.circle('fill', p.x, p.y, p.size)
        end
    end

    -- Desenhar inimigos
    for _, e in ipairs(self.enemies) do
        e:draw()
    end

    -- Desenhar projéteis inimigos
    for _, proj in ipairs(self.enemy_projectiles) do
        if proj.collider and not proj.collider:isDestroyed() then
            proj:draw()
        end
    end

    love.graphics.push()
    love.graphics.translate(self.map_offset, 0)
    love.graphics.pop()
end

return stage
