local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(world, x, y)
    local obj = setmetatable({}, self)
    obj.collider = world:newRectangleCollider(x, y, 30, 30)
    obj.collider:setType('dynamic')
    obj.speed = 80
    obj.shoot_timer = 0
    obj.shoot_interval = math.random(2, 7)
    return obj
end

function Enemy:update(dt)
    self.collider:setX(self.collider:getX() - self.speed * dt)
    self.shoot_timer = self.shoot_timer + dt
end
function Enemy:canShoot()
    return self.shoot_timer >= self.shoot_interval
end
function Enemy:resetShootTimer()
    self.shoot_timer = 0
    self.shoot_interval = math.random(2, 7)
end

function Enemy:draw()
    local ex, ey = self.collider:getPosition()
    love.graphics.setColor(0.3, 1, 0.3)
    love.graphics.rectangle('line', ex-15, ey-15, 30, 30)
end

return Enemy
