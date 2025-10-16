local animation = require('animations/player_ship')
local options = require 'options'

local Player = {
    movingUp = false,
    movingDown = false,
    movingLeft = false,
    movingRight = false
}
Player.__index = Player

function Player:new(world, x, y)
    local obj = setmetatable({}, self)

    obj.shoot_sound = love.audio.newSource('assets/sound/retro-laser-1-236669.mp3', 'static')
    obj.shoot_sound:setVolume(options.sfx_volume)
    obj.charged_shoot_sound = love.audio.newSource('assets/sound/laser-zap-90575.mp3', 'static')
    obj.charged_shoot_sound:setVolume(options.sfx_volume)
    obj.lives = 3
    obj.collider = world:newBSGRectangleCollider(x, y, 48, 48, 10)
    obj.collider:setType('dynamic')
    obj.collider:setFixedRotation(true)
    obj.collider:setCollisionClass('Player')
    obj.speed = 200
    obj.projectiles = {}
    obj.world = world
    obj.repeller_orbital_angle = 0
    obj.repeller_length = 50
    obj.repeller_width = 10
    obj.repeller_collider = world:newRectangleCollider(x, y, obj.repeller_width, obj.repeller_length)
    obj.repeller_collider:setType('kinematic')
    obj.repeller_collider:setCollisionClass('Repeller')
    obj.repeller_collider:setAngle(obj.repeller_orbital_angle)
    obj.repeller_collider:setUserData({collision_class = 'Repeller', parent = obj})
    obj.repeller_visible = false
    obj.repeller_timer = 0
    obj._last_angle = 0
    obj.charging = false
    obj.charge_timer = 0
    obj.charge_ready = false
    return obj
end

function Player:shoot(isCharged)
    if isCharged then
        if self.charged_shoot_sound then
            self.charged_shoot_sound:stop()
            self.charged_shoot_sound:play()
        end
    else
        if self.shoot_sound then
            self.shoot_sound:stop()
            self.shoot_sound:play()
        end
    end
    local px, py = self.collider:getPosition()
    local projectile
    if isCharged then
        projectile = {
            x = px + 15,
            y = py,
            speed = 500,
            charged = true,
            radius = 18
        }
        projectile.collider = self.world:newCircleCollider(px + 15, py, projectile.radius)
        projectile.collider:setType('dynamic')
        projectile.collider:setCollisionClass('PlayerProjectile')
        projectile.collider:setUserData({collision_class = 'PlayerProjectile'})
    else
        projectile = {
            x = px + 15,
            y = py,
            speed = 300
        }
        projectile.collider = self.world:newRectangleCollider(px + 15, py, 10, 4)
        projectile.collider:setType('dynamic')
        projectile.collider:setCollisionClass('PlayerProjectile')
        projectile.collider:setUserData({collision_class = 'PlayerProjectile'})
    end
    table.insert(self.projectiles, projectile)
end

function Player:isMovingUp()
    return love.keyboard.isDown('up') or love.keyboard.isDown('w') or self.movingUp
end

function Player:isMovingDown()
    return love.keyboard.isDown('down') or love.keyboard.isDown('s') or self.movingDown
end

function Player:isMovingLeft()
    return love.keyboard.isDown('left') or love.keyboard.isDown('a') or self.movingLeft
end

function Player:isMovingRight()
    return love.keyboard.isDown('right') or love.keyboard.isDown('d') or self.movingRight
end

function Player:update(dt)
    local vx, vy = 0, 0
    if self:isMovingUp() then vy = -self.speed end
    if self:isMovingDown() then vy = self.speed end
    if self:isMovingLeft() then vx = -self.speed end
    if self:isMovingRight() then vx = self.speed end
    self.collider:setLinearVelocity(vx, vy)

    local px, py = self.collider:getPosition()
    if px < 15 then self.collider:setX(15)
    elseif px > 640 - 15 then self.collider:setX(640 - 15) end
    if py < 15 then self.collider:setY(15)
    elseif py > 480 - 15 then self.collider:setY(480 - 15) end

    self:updatePlayerProjectiles(dt)

    self:updateCharging(dt)

    self:updateRepeller(dt, px, py)
end

function Player:updatePlayerProjectiles(dt)
    for i = #self.projectiles, 1, -1 do
        local proj = self.projectiles[i]
        if proj.collider and not proj.collider:isDestroyed() then
            proj.collider:setX(proj.collider:getX() + proj.speed * dt)
            if proj.collider:getX() > 640 then
                proj.collider:destroy()
                table.remove(self.projectiles, i)
            end
        else
            table.remove(self.projectiles, i)
        end
    end
end

function Player:updateCharging(dt)
    -- Controle de carregamento do tiro
    if self.charging then
        self.charge_timer = self.charge_timer + dt
        if self.charge_timer >= 3 then
            self.charge_ready = true
        end
    end
end

function Player:updateRepeller(dt, px, py)
    -- Atualizar ângulo do repeller para apontar para o mouse
    local mx, my = love.mouse.getPosition()
    local new_angle = math.atan2(my - py, mx - px)
    -- Detectar movimento do ângulo
    if math.abs(new_angle - (self._last_angle or 0)) > 0.01 then
        self.repeller_visible = true
        self.repeller_timer = 2
    end
    self.repeller_orbital_angle = new_angle
    self._last_angle = new_angle

    -- Atualizar posição e rotação do repeller collider
    if self.repeller_collider then
        local angle = self.repeller_orbital_angle or 0
        local dist = 50
        local cx = px + math.cos(angle) * dist
        local cy = py + math.sin(angle) * dist
        self.repeller_collider:setPosition(cx, cy)
        self.repeller_collider:setAngle(angle)
    end

    -- Timer para ocultar o repeller
    if self.repeller_visible then
        self.repeller_timer = self.repeller_timer - dt
        if self.repeller_timer <= 0 then
            self.repeller_visible = false
            self.repeller_timer = 0
        end
    end
end


function Player:draw()
    local px, py = self.collider:getPosition()

    -- Desenhar a imagem da nave centralizada e ajustada sobre o player
    love.graphics.setColor(1, 1, 1)

    local ship_img = animation.sprite
    local img_w, img_h = ship_img:getWidth(), ship_img:getHeight()
    -- Ajustar para 48x48 (tamanho do player)
    love.graphics.draw(ship_img, px, py, 0, 48/img_w, 48/img_h, img_w/2, img_h/2)

    -- Desenhar projéteis
    for _, proj in ipairs(self.projectiles) do
        if proj.collider and not proj.collider:isDestroyed() then
            local x, y = proj.collider:getPosition()
            if proj.charged then
                local r = proj.radius or 18
                -- Círculo principal
                love.graphics.setColor(0, 1, 1)
                love.graphics.circle('fill', x, y, r)
                -- Arco à esquerda (semicírculo)
                love.graphics.setColor(0, 0.2, 1)
                love.graphics.arc('fill', x - r * 0.7, y, r * 0.7, math.pi/2, math.pi*3/2)
                -- Contorno do círculo
                love.graphics.setColor(1, 0.2, 0.2)
                love.graphics.setLineWidth(2)
                love.graphics.circle('line', x, y, r)
                love.graphics.setLineWidth(1)
            else
                love.graphics.setColor(1, 0.7, 0)
                love.graphics.rectangle('fill', x, y - 2, 10, 4)
            end
        end
    end

    -- Exibir vidas
    love.graphics.setColor(1, 1, 1)
    love.graphics.print('Vidas: ' .. tostring(self.lives), 10, 10)

    -- Desenhar repeller apenas se visível
    if self.repeller_visible then
        local angle = self.repeller_orbital_angle or 0
        local rect_w, rect_h = 10, 50
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
end
-- Chame este método quando ocorrer uma colisão com o repeller
function Player:showRepellerOnCollision()
    self.repeller_visible = true
    self.repeller_timer = 2
end

function Player:fireDown()
    self.charging = true
    self.charge_timer = 0
    self.charge_ready = false
end

function Player:fireUp()
    if self.charge_ready then
        self:shoot(true)
    else
        self:shoot(false)
    end
    self.charging = false
    self.charge_timer = 0
    self.charge_ready = false
end
function Player:keypressed(key)
    if key == 'b' or key == 'y' then
        self:fireDown()
    end
end

function Player:keyreleased(key)
    if (key == 'b' or key == 'y') then
        self:fireUp()
    end
end

function Player:gamepadpressed(joystick, button)
    if button == 'dpup' then
        self.movingUp = true
    elseif button == 'dpdown' then
        self.movingDown = true
    elseif button == 'dpleft' then
        self.movingLeft = true
    elseif button == 'dpright'then
        self.movingRight = true
    elseif button == 'x' then
        self:fireDown()
    end
end

function Player:gamepadreleased(joystick, button)
    if button == 'dpup' then
        self.movingUp = false
    elseif button == 'dpdown' then
        self.movingDown = false
    elseif button == 'dpleft' then
        self.movingLeft = false
    elseif button == 'dpright'then
        self.movingRight = false
    elseif button == 'x' then
        self:fireUp()
    end
end

function Player:joystickpressed(joystick, button)
    -- Implementação vazia
end

function Player:joystickreleased(joystick, button)
    -- Implementação vazia
end

return Player
