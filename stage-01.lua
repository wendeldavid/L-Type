-- Stage-01 herda comportamentos de game.lua e adiciona o mapa
local sti = require("libs.Simple-Tiled-Implementation.sti.init")

local stage = {
    map_offset = 0,
    colliders = {}
}

function stage:enter(world)
	self.map = sti("assets/stages/stg-01.lua")

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

    for _, collider in ipairs(stage.colliders) do
        local x, y = collider:getPosition()
        collider:setPosition(x - (dt * 10), y)
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
