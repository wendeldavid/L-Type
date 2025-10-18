-- Stage-01 herda comportamentos de game.lua e adiciona o mapa
local sti = require("libs.Simple-Tiled-Implementation.sti.init")

local stage = {
    map_offset = 0,
    colliders = {},
    planet_img = nil,
    planet_x = nil,
    planet_y = nil,
    particles = {},
    particle_timer = 0,
    particle_interval = 0.2
}

function stage:enter(world)
	self.map = sti("assets/stages/stg-01.lua")

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

function stage:update(dt)
	if self.map then self.map:update(dt) end

	-- Move o mapa da direita para a esquerda
	self.map_offset = self.map_offset - (dt * 10) -- velocidade 10px/s

    -- Atualizar posição do planeta (mais devagar)
    self.planet_x = self.planet_x - dt * 2 -- velocidade de 2px/s para a esquerda

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

    for _, collider in ipairs(stage.colliders) do
        local x, y = collider:getPosition()
        collider:setPosition(x - (dt * 10), y)
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

    love.graphics.push()
    love.graphics.translate(self.map_offset, 0)
    love.graphics.pop()
end

return stage
