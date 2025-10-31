-- Demonstração de como o sistema de input é agnóstico
-- Este arquivo mostra que diferentes inputs executam a mesma ação

local input = require 'input'

local demo_state = {}

function demo_state:enter()
    self:setup_input_callbacks()
end

function demo_state:leave()
    input:clear_callbacks()
end

function demo_state:update(dt)
    input:update(dt)
end

function demo_state:setup_input_callbacks()
    -- Todas essas formas diferentes de input executam a MESMA ação:
    
    -- navigate_up pode ser ativado por:
    -- - Tecla 'up' ou 'w'
    -- - Gamepad 'dpup'
    -- - Joystick qualquer botão (mapeado)
    input:set_callback('navigate_up', function()
        print("↑ Navegando para cima (agnóstico ao input)")
    end)
    
    -- navigate_down pode ser ativado por:
    -- - Tecla 'down' ou 's'
    -- - Gamepad 'dpdown'
    -- - Joystick qualquer botão (mapeado)
    input:set_callback('navigate_down', function()
        print("↓ Navegando para baixo (agnóstico ao input)")
    end)
    
    -- confirm pode ser ativado por:
    -- - Tecla 'return', 'kpenter' ou 'space'
    -- - Gamepad 'a' ou 'start'
    -- - Joystick botões '1' ou '2'
    input:set_callback('confirm', function()
        print("✓ Confirmando ação (agnóstico ao input)")
    end)
    
    -- cancel pode ser ativado por:
    -- - Tecla 'escape'
    -- - Gamepad 'back' ou 'select'
    -- - Joystick botões '3' ou '4'
    input:set_callback('cancel', function()
        print("✗ Cancelando ação (agnóstico ao input)")
    end)
    
    -- Exemplo de mapeamento customizado
    -- Você pode adicionar qualquer tecla/botão para qualquer ação
    input:add_custom_mapping('f1', 'navigate_up')    -- F1 agora também navega para cima
    input:add_custom_mapping('f2', 'navigate_down')  -- F2 agora também navega para baixo
    input:add_custom_mapping('x', 'confirm')          -- X agora também confirma
    input:add_custom_mapping('z', 'cancel')          -- Z agora também cancela
end

-- Delegar todos os inputs para o sistema centralizado
function demo_state:keypressed(key)
    input:keypressed(key)
end

function demo_state:joystickpressed(joystick, button)
    input:joystickpressed(joystick, button)
end

function demo_state:gamepadpressed(gamepad, button)
    input:gamepadpressed(gamepad, button)
end

function demo_state:mousepressed(x, y, button)
    input:mousepressed(x, y, button)
end

function demo_state:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Sistema de Input Agnóstico - Demonstração", 10, 10)
    love.graphics.print("", 10, 30)
    love.graphics.print("Todas essas formas executam a MESMA ação:", 10, 50)
    love.graphics.print("", 10, 70)
    love.graphics.print("Navegar ↑: Setas ↑, W, dpup, F1", 10, 90)
    love.graphics.print("Navegar ↓: Setas ↓, S, dpdown, F2", 10, 110)
    love.graphics.print("Confirmar: Enter, Space, A, X", 10, 130)
    love.graphics.print("Cancelar: Esc, Back, Z", 10, 150)
    love.graphics.print("", 10, 170)
    love.graphics.print("O sistema é completamente agnóstico ao dispositivo!", 10, 190)
end

return demo_state
