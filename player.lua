-- Variáveis para controle do retângulo giratório
local Player = {}
Player.__index = Player

function Player:new(world, x, y)
    local obj = setmetatable({}, self)
    obj.lives = 3
    obj.collider = world:newRectangleCollider(x, y, 30, 30)
    obj.collider:setType('dynamic')
    obj.collider:setFixedRotation(true) -- Garantir que o collider não gire
    obj.collider:setCollisionClass('Player') -- Configuração da classe de colisão do jogador
    obj.speed = 200
    obj.projectiles = {}
    obj.world = world -- Armazenar referência ao mundo para criar colisores de projéteis
    obj.repeller_orbital_angle = 0

    -- Repeller collider
    obj.repeller_length = 50
    obj.repeller_width = 10
    obj.repeller_collider = world:newRectangleCollider(x, y, obj.repeller_width, obj.repeller_length)
    obj.repeller_collider:setType('kinematic')
    obj.repeller_collider:setCollisionClass('Repeller')
    obj.repeller_collider:setAngle(0)
    obj.repeller_collider:setUserData({collision_class = 'Repeller', parent = obj})

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
    -- Alternativamente, use wheelmoved para cima/baixo
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
        if proj.collider and not proj.collider:isDestroyed() then
            proj.collider:setX(proj.collider:getX() + proj.speed * dt)
            -- Remove projétil se sair da tela
            if proj.collider:getX() > 640 then
                proj.collider:destroy()
                table.remove(self.projectiles, i)
            end
        else
            table.remove(self.projectiles, i)
        end
    end

    -- Atualizar ângulo do repeller para apontar para o mouse
    local mx, my = love.mouse.getPosition()
    self.repeller_orbital_angle = math.atan2(my - py, mx - px)

    -- Atualizar posição e rotação do repeller collider para coincidir com o desenho
    if self.repeller_collider then
        local angle = self.repeller_orbital_angle or 0
        local dist = 50
        local cx = px + math.cos(angle) * dist
        local cy = py + math.sin(angle) * dist
        self.repeller_collider:setPosition(cx, cy)
        self.repeller_collider:setAngle(angle)
    end
end

function Player:draw()
    local px, py = self.collider:getPosition()
    love.graphics.rectangle('line', px-15, py-15, 30, 30)

    -- Desenhar projéteis
    love.graphics.setColor(1, 0.5, 0)
    for _, proj in ipairs(self.projectiles) do
        if proj.collider and not proj.collider:isDestroyed() then
            local x, y = proj.collider:getPosition()
            love.graphics.rectangle('fill', x, y - 2, 10, 4)
        end
    end

    -- Exibir vidas
    love.graphics.setColor(1, 1, 1)
    love.graphics.print('Vidas: ' .. tostring(self.lives), 10, 10)

    -- Desenhar retângulo azul giratório como escudo
    local angle = self.repeller_orbital_angle or 0
    local rect_w, rect_h = 10, 50 -- largura altura (escudo)
    local dist = 50
    love.graphics.push()
    love.graphics.translate(px, py)
    love.graphics.rotate(angle)
    love.graphics.translate(dist, 0)
    love.graphics.setColor(0.2, 0.4, 1, 1)
    love.graphics.rectangle('fill', -rect_w/2, -rect_h/2, rect_w, rect_h)
    love.graphics.pop()
    love.graphics.setColor(0.4, 0.7, 1)
end

function Player:keypressed(key)
    if key == 'b' or key == 'y' then
        self:shoot()
    end
end

return Player
