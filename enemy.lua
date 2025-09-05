local Enemy = {}
Enemy.__index = Enemy
local enemy_sprites = {
    love.graphics.newImage('assets/sprites/enemy_1.png'),
    love.graphics.newImage('assets/sprites/enemy_2.png')
}

function Enemy:new(world, x, y)
    local obj = setmetatable({}, self)
    obj.collider = world:newRectangleCollider(x, y, 60, 60)
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
    self:updateProjectiles(dt) -- Atualiza a posição dos projéteis
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
    self:drawProjectiles()
end

function Enemy:shootAtPlayer(player)
    local ex, ey = self.collider:getPosition()
    local px, py = player.collider:getPosition()
    local dx, dy = px - ex, py - ey
    local dist = math.sqrt(dx*dx + dy*dy)
    local speed = 80
    local vx, vy = (dx/dist)*speed, (dy/dist)*speed
    local projectile = {
        collider = self.collider.world:newRectangleCollider(ex, ey, 10, 4),
        speed = speed,
        vx = vx,
        vy = vy
    }
    projectile.collider:setType('dynamic')
    projectile.collider:setCollisionClass('EnemyProjectile')
    projectile.collider:setUserData({collision_class = 'EnemyProjectile'})
    projectile.collider:setRestitution(0.8)
    projectile.collider:applyAngularImpulse(5800)

    table.insert(self.projectiles, projectile)
end

function Enemy:updateProjectiles(dt)
    for i = #self.projectiles, 1, -1 do
        local proj = self.projectiles[i]
        if proj.collider and not proj.collider:isDestroyed() then
            proj.collider:setX(proj.collider:getX() + proj.vx * dt)
            proj.collider:setY(proj.collider:getY() + proj.vy * dt)
            if proj.collider:getX() < 0 or proj.collider:getX() > 640 or proj.collider:getY() < 0 or proj.collider:getY() > 480 then
                proj.collider:destroy()
                table.remove(self.projectiles, i)
            end
        else
            table.remove(self.projectiles, i)
        end
    end
end

function Enemy:drawProjectiles()
    love.graphics.setColor(1, 0, 0)
    for _, proj in ipairs(self.projectiles) do
        if proj.collider and not proj.collider:isDestroyed() then
            local x, y = proj.collider:getPosition()
            love.graphics.rectangle('fill', x, y - 2, 10, 4)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return Enemy
