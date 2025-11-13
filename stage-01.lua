-- Stage-01 herda comportamentos de game.lua e adiciona o mapa
local sti = require("libs.Simple-Tiled-Implementation.sti.init")

local Enemy = require 'enemy'

local stage = {}

function stage:enter(world)
	self.map = sti("assets/stages/stg-01.lua")
    self.colliders = {}

    self.map_offset = 0

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
    self.max_enemies = 5
    self.spawn_points = {} -- Pontos de spawn definidos no mapa

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
        if obj.type == "enemy_spawn" then
            -- Coletar pontos de spawn do mapa com flag para rastrear se já foi usado
            table.insert(self.spawn_points, {x = obj.x, y = obj.y, spawned = false})
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

    for particle_idx = #self.particles, 1, -1 do
        local p = self.particles[particle_idx]
        p.x = p.x - p.speed * dt
        if p.x + p.size < 0 then
            table.remove(self.particles, particle_idx)
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
        local enemy_idx = 1
        while enemy_idx <= #self.enemies do
            local enemy = self.enemies[enemy_idx]
            if enemy.collider and enemy.collider:isDestroyed() then
                table.remove(self.enemies, enemy_idx)
            else
                enemy.shoot_timer = (enemy.shoot_timer or 0) + dt
                -- Apenas mover o inimigo, não atualizar projéteis aqui
                enemy.collider:setX(enemy.collider:getX() - enemy.speed * dt)
                if enemy.shoot_timer >= 2 then
                    enemy.shoot_timer = 0
                    local projectile = enemy:shootAtPlayer(player)
                    table.insert(self.enemy_projectiles, projectile)
                end
                enemy_idx = enemy_idx + 1
            end
        end

        -- Atualizar todos os projéteis inimigos independentemente do inimigo estar vivo
        for projectile_idx = #self.enemy_projectiles, 1, -1 do
            local proj = self.enemy_projectiles[projectile_idx]
            if proj.collider and not proj.collider:isDestroyed() then
                -- Verificar se o projétil foi marcado para destruição
                local ud = proj.collider:getUserData()
                if ud and ud._to_destroy then
                    proj.collider:destroy()
                    table.remove(self.enemy_projectiles, projectile_idx)
                else
                    proj:update(dt)
                    -- projectile out of screen
                    if proj.collider:getX() < 0 or proj.collider:getX() > 640 or proj.collider:getY() < 0 or proj.collider:getY() > 480 then
                        proj.collider:destroy()
                        table.remove(self.enemy_projectiles, projectile_idx)
                    end
                end
            else
                table.remove(self.enemy_projectiles, projectile_idx)
            end
        end

        -- Spawn de enemies quando pontos de inimigos aparecem na tela
        if not self.stage_finished and #self.enemies < self.max_enemies then
            -- Verificar cada ponto de spawn para ver se entrou na área visível
            for _, spawn_point in ipairs(self.spawn_points) do
                if not spawn_point.spawned then
                    -- Calcular posição do ponto na tela considerando o scroll do mapa
                    -- map_offset negativo = mapa rolando para a esquerda
                    -- Quando map_offset = -100, o que estava em x=100 no mapa agora está em x=0 na tela
                    -- Então: posição_na_tela = posição_no_mapa + map_offset
                    local screen_x = spawn_point.x + self.map_offset

                    -- Verificar se o ponto está prestes a entrar na tela ou já está visível
                    -- Spawnar quando o ponto está próximo do lado direito da tela
                    -- Como o mapa rola da direita para a esquerda, queremos spawnar quando o ponto
                    -- está prestes a aparecer pela direita (screen_x próximo de screen_width)
                    local spawn_trigger_x = self.screen_width + 50 -- Spawnar quando ponto está 50px à direita da tela
                    if screen_x <= spawn_trigger_x and screen_x >= self.screen_width - 200 then
                        -- Marcar ponto como usado e spawnar inimigo
                        spawn_point.spawned = true
                        -- Spawnar na posição Y do ponto, do lado direito da tela
                        local spawn_x = self.screen_width - 40 -- Lado direito da tela (com margem)
                        local spawn_y = spawn_point.y
                        table.insert(self.enemies, Enemy:new(world, spawn_x, spawn_y))

                        -- Parar após spawnar um inimigo por frame para evitar múltiplos spawns
                        break
                    end
                end
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
