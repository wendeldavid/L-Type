local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(world, x, y)
    local obj = setmetatable({}, self)
    obj.collider = world:newRectangleCollider(x, y, 30, 30)
    obj.collider:setType('dynamic')
    obj.speed = 80
    obj.tempo_tiro = 0
    return obj
end

function Enemy:update(dt)
    self.collider:setX(self.collider:getX() - self.speed * dt)
end

function Enemy:draw()
    local ex, ey = self.collider:getPosition()
    love.graphics.setColor(0.3, 1, 0.3)
    love.graphics.rectangle('line', ex-15, ey-15, 30, 30)
end

return Enemy
