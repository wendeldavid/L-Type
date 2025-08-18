local Player = {}
Player.__index = Player

function Player:new(world, x, y)
    local obj = setmetatable({}, self)
    obj.collider = world:newRectangleCollider(x, y, 30, 30)
    obj.collider:setType('dynamic')
    obj.collider:setFixedRotation(true) -- Garantir que o collider não gire
    obj.collider:setCollisionClass('Player') -- Configuração da classe de colisão do jogador
    obj.speed = 200
    obj.projectiles = {}
    obj.world = world -- Armazenar referência ao mundo para criar colisores de projéteis
    return obj
end

function Player:shoot()
    local px, py = self.collider:getPosition()
    local projectile = {
        x = px + 15, -- Posição inicial do projétil à frente do jogador
        y = py,
        speed = 300 -- Velocidade do projétil
    }

    -- Configurar UserData para projéteis do jogador
    projectile.collider = self.world:newRectangleCollider(px + 15, py, 10, 4)
    projectile.collider:setType('dynamic')
    projectile.collider:setCollisionClass('PlayerProjectile')
    projectile.collider:setUserData({collision_class = 'PlayerProjectile'})

    table.insert(self.projectiles, projectile)
end

function Player:isMovingUp()
    return love.keyboard.isDown('up') or love.keyboard.isDown('w')
end

function Player:isMovingDown()
    return love.keyboard.isDown('down') or love.keyboard.isDown('s')
end

function Player:isMovingLeft()
    return love.keyboard.isDown('left') or love.keyboard.isDown('a')
end

function Player:isMovingRight()
    return love.keyboard.isDown('right') or love.keyboard.isDown('d')
end

function Player:update(dt)
    local vx, vy = 0, 0
    if self:isMovingUp() then vy = -self.speed end
    if self:isMovingDown() then vy = self.speed end
    if self:isMovingLeft() then vx = -self.speed end
    if self:isMovingRight() then vx = self.speed end

    self.collider:setLinearVelocity(vx, vy)

    -- Impedir que o jogador saia da janela
    local px, py = self.collider:getPosition()
    if px < 15 then
        self.collider:setX(15)
    elseif px > 640 - 15 then
        self.collider:setX(640 - 15)
    end

    if py < 15 then
        self.collider:setY(15)
    elseif py > 480 - 15 then
        self.collider:setY(480 - 15)
    end

    -- Atualizar projéteis
    for i = #self.projectiles, 1, -1 do
        local proj = self.projectiles[i]
        proj.x = proj.x + proj.speed * dt
        if proj.x > 640 then -- Remover projéteis que saem da tela
            table.remove(self.projectiles, i)
        end
    end
end

function Player:draw()
    local px, py = self.collider:getPosition()
    love.graphics.setColor(0.4, 0.7, 1)
    love.graphics.rectangle('line', px-15, py-15, 30, 30)

    -- Desenhar projéteis
    love.graphics.setColor(1, 0.5, 0)
    for _, proj in ipairs(self.projectiles) do
        love.graphics.rectangle('fill', proj.x, proj.y - 2, 10, 4)
    end
end

function Player:keypressed(key)
    if key == 'b' then
        self:shoot()
    end
end

return Player
