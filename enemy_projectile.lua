local EnemyProjectile = {}
EnemyProjectile.__index = EnemyProjectile

function EnemyProjectile:new(world, x, y, vx, vy)
    local obj = setmetatable({}, self)
    obj.collider = world:newRectangleCollider(x, y, 10, 4)
    obj.collider:setType('dynamic')
    obj.collider:setFixedRotation(false) -- Permitir rotação para ricochete
    obj.collider:setCollisionClass('EnemyProjectile')
    obj.collider:setUserData({collision_class = 'EnemyProjectile'})
    obj.collider:setRestitution(0.6) -- Reduzir restituição para melhor controle
    obj.collider:setLinearDamping(0.1) -- Adicionar amortecimento linear
    obj.collider:setAngularDamping(0.5) -- Adicionar amortecimento angular

    obj.vx = vx or 0
    obj.vy = vy or 0
    obj.speed = 100

    -- Aplicar velocidade inicial
    obj.collider:setLinearVelocity(vx or 0, vy or 0)

    return obj
end

function EnemyProjectile:update(dt)
    -- Não precisamos mais mover manualmente, o Box2D cuida da física
    -- Apenas verificamos se ainda está na tela
end

function EnemyProjectile:draw()
    if self.collider and not self.collider:isDestroyed() then
        local x, y = self.collider:getPosition()
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle('fill', x - 5, y - 2, 10, 4)
        love.graphics.setColor(1, 1, 1)
    end
end

return EnemyProjectile