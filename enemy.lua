local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(world, x, y)
    local obj = setmetatable({}, self)
    obj.collider = world:newRectangleCollider(x, y, 30, 30)
    obj.collider:setType('dynamic')
    obj.collider:setFixedRotation(true) -- Garantir que o collider não gire
    obj.collider:setCollisionClass('Enemy') -- Configuração da classe de colisão dos inimigos
    obj.collider:setUserData({collision_class = 'Enemy'})
    obj.speed = 20
    obj.projectiles = {} -- Tabela para armazenar os projéteis
    obj.world = world
    return obj
end

function Enemy:update(dt)
    self.collider:setX(self.collider:getX() - self.speed * dt)
    self:updateProjectiles(dt) -- Atualiza a posição dos projéteis
end

function Enemy:draw()
    local ex, ey = self.collider:getPosition()
    love.graphics.setColor(0.3, 1, 0.3)
    love.graphics.rectangle('line', ex-15, ey-15, 30, 30)
    self:drawProjectiles() -- Desenha os projéteis
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
