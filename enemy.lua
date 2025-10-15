local EnemyProjectile = require 'enemy_projectile'

local Enemy = {}
Enemy.__index = Enemy
local enemy_sprites = {
    love.graphics.newImage('assets/sprites/enemy_1.png'),
    love.graphics.newImage('assets/sprites/enemy_2.png')
}

function Enemy:new(world, x, y)
    local obj = setmetatable({}, self)
    obj.collider = world:newBSGRectangleCollider(x, y, 60, 60, 10)
    obj.collider:setType('dynamic')
    obj.collider:setFixedRotation(true)
    obj.collider:setCollisionClass('Enemy')
    obj.collider:setUserData({collision_class = 'Enemy'})
    obj.speed = 20
    obj.projectiles = {}
    obj.world = world
    obj.sprite = enemy_sprites[math.random(1, #enemy_sprites)]
    return obj
end

function Enemy:update(dt)
    self.collider:setX(self.collider:getX() - self.speed * dt)
end

function Enemy:draw()
    local ex, ey = self.collider:getPosition()
    if self.sprite then
        love.graphics.setColor(1, 1, 1, 0.5)
        local img_w, img_h = self.sprite:getWidth(), self.sprite:getHeight()
        love.graphics.draw(self.sprite, ex, ey, 0, 60/img_w, 60/img_h, img_w/2, img_h/2)
        love.graphics.setColor(1,1,1,1)
    else
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle('line', ex-30, ey-30, 60, 60)
        love.graphics.setColor(1,1,1,1)
    end
end

function Enemy:shootAtPlayer(player)
    local ex, ey = self.collider:getPosition()
    local px, py = player.collider:getPosition()
    local dx, dy = px - ex, py - ey
    local dist = math.sqrt(dx*dx + dy*dy)
    local speed = 80
    local vx, vy = (dx/dist)*speed, (dy/dist)*speed

    local projectile = EnemyProjectile:new(self.collider.world, ex, ey, vx, vy)
    return projectile
end

return Enemy
