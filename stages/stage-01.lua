-- Stage-01 herda comportamentos de game.lua e adiciona o mapa
local sti = require("libs.Simple-Tiled-Implementation.sti.init")

local stage = {
    polygons = {},
    terrain_test_colliders = {}
}

stage.map_offset = 0
stage.terrain_collider = nil

function stage:enter(world)
	self.map = sti("assets/stages/stg-01.lua")
end

function stage:update(dt)
	if self.map then self.map:update(dt) end
	-- Move o mapa da direita para a esquerda
	self.map_offset = self.map_offset - (dt * 10) -- velocidade 10px/s
end

function stage:draw()
    -- Desenhar o mapa com offset
    self.map:draw(self.map_offset, 0)

    love.graphics.push()
    love.graphics.translate(self.map_offset, 0)

    -- Desenhar os polígonos de terreno
    self:drawTerrainPolygons()
    -- Desenhar os colliders TerrainTest para debug
    self:drawTerrainTestColliders()

    love.graphics.pop()
end

function stage:drawTerrainPolygons()
    -- Configurar cor e estilo para os polígonos
    love.graphics.setColor(0, 1, 0, 0.3) -- Verde semi-transparente
    love.graphics.setLineWidth(5)

    -- Desenhar cada polígono
    for _, polygon in ipairs(self.polygons) do
        if #polygon >= 6 then -- Mínimo 3 pontos (6 coordenadas)
            love.graphics.polygon("fill", polygon)
            love.graphics.setColor(0, 0.8, 0, 0.8) -- Verde mais escuro para as bordas
            love.graphics.polygon("line", polygon)
            love.graphics.setColor(0, 1, 0, 0.3) -- Voltar para a cor de preenchimento
        end
    end

    -- Resetar cor para não afetar outros desenhos
    love.graphics.setColor(1, 1, 1, 1)
end

function stage:drawTerrainTestColliders()
    -- Configurar cor e estilo para os colliders TerrainTest
    love.graphics.setColor(1, 0, 0, 0.5) -- Vermelho semi-transparente
    love.graphics.setLineWidth(3)
    -- Desenhar cada collider TerrainTest
    for _, collider in ipairs(self.terrain_test_colliders) do
        if collider and not collider:isDestroyed() then
            local x, y = collider:getPosition()
            local user_data = collider:getUserData()
            local w, h = user_data.width, user_data.height
            -- Desenhar retângulo preenchido
            love.graphics.rectangle("fill", x - w/2, y - h/2, w, h)
            -- Desenhar borda
            love.graphics.setColor(1, 0.2, 0.2, 0.8) -- Vermelho mais escuro para as bordas
            love.graphics.rectangle("line", x - w/2, y - h/2, w, h)
            love.graphics.setColor(1, 0, 0, 0.5) -- Voltar para a cor de preenchimento
        end
    end
    -- Resetar cor para não afetar outros desenhos
    love.graphics.setColor(1, 1, 1, 1)
end

function stage:leave()
    -- Limpar collider de terreno quando sair do stage
    if self.terrain_collider and not self.terrain_collider:isDestroyed() then
        self.terrain_collider:destroy()
    end
    self.terrain_collider = nil
    -- Limpar colliders TerrainTest
    for _, collider in ipairs(self.terrain_test_colliders) do
        if collider and not collider:isDestroyed() then
            collider:destroy()
        end
    end
    self.terrain_test_colliders = {}
end

return stage
