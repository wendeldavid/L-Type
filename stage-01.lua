-- Stage-01 herda comportamentos de game.lua e adiciona o mapa
local sti = require("libs.Simple-Tiled-Implementation.sti.init")

local stage = {}

stage.map_offset = 0
stage.terrain = {}

function stage:enter(world)
	self.map = sti("assets/stages/stg-01.lua")

    for _, obj in ipairs(self.map.layers["terrain_layer"].objects) do
        if obj.type == "Terrain" then
            stage.terrain = obj
        end
    end

    -- Transladar o polígono para a posição do mapa
    stage.terrain.translated_polygon = {}
    for _, vertex in ipairs(stage.terrain.polygon) do
        table.insert(stage.terrain.translated_polygon, vertex.x)
        table.insert(stage.terrain.translated_polygon, vertex.y)
    end

    stage.terrain.collider = world:newPolygonCollider(stage.terrain.translated_polygon)
    stage.terrain.collider:setType("static")
    stage.terrain.collider:setCollisionClass(stage.terrain.type)
end

function stage:update(dt)
	if self.map then self.map:update(dt) end

	-- Move o mapa da direita para a esquerda
	self.map_offset = self.map_offset - (dt * 10) -- velocidade 10px/s

    if stage.terrain and stage.terrain.collider then
        local new_x = stage.terrain.width/2 + self.map_offset
        local new_y = stage.terrain.height/2
        stage.terrain.collider:setPosition(new_x, new_y)
    end
end

function stage:draw()
    -- Desenhar o mapa com offset
    self.map:draw(self.map_offset, 0)

    love.graphics.push()
    love.graphics.translate(self.map_offset, 0)
    love.graphics.pop()
end

return stage
