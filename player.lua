local Player = {}
Player.__index = Player

function Player:new(world, x, y)
    local obj = setmetatable({}, self)
    obj.collider = world:newRectangleCollider(x, y, 30, 30)
    obj.collider:setType('dynamic')
    obj.speed = 200
    return obj
end

function Player:update(dt, controls)
    local vx, vy = 0, 0
    if controls.up() then vy = -self.speed end
    if controls.down() then vy = self.speed end
    if controls.left() then vx = -self.speed end
    if controls.right() then vx = self.speed end
    self.collider:setLinearVelocity(vx, vy)
    local px, py = self.collider:getPosition()
    px = math.max(15, math.min(640-15, px))
    py = math.max(15, math.min(480-15, py))
    self.collider:setPosition(px, py)
end

function Player:draw()
    local px, py = self.collider:getPosition()
    love.graphics.setColor(0.4, 0.7, 1)
    love.graphics.rectangle('line', px-15, py-15, 30, 30)
end

return Player
