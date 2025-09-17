-- Stage-01 herda comportamentos de game.lua e adiciona o mapa
local sti = require("libs.Simple-Tiled-Implementation.sti.init")

local stage = {}

stage.map_offset = 0

function stage:enter()
	self.map = sti("assets/stages/stg-01.lua")
end

function stage:update(dt)
	if self.map then self.map:update(dt) end
	-- Move o mapa da direita para a esquerda
	self.map_offset = self.map_offset - (dt * 60) -- velocidade 60px/s
    print(self.map_offset)
end

function stage:draw()
    love.graphics.push()
    love.graphics.translate(self.map_offset, 0)
    self.map:draw()
    love.graphics.pop()
end

return stage
