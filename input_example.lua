-- Exemplo de uso do sistema de input centralizado
-- Este arquivo demonstra como usar o sistema de input em qualquer gamestate

local input = require 'input'

local example_state = {}

function example_state:enter()
    -- Configurar callbacks de input específicos para este estado
    self:setup_input_callbacks()
end

function example_state:leave()
    -- Limpar callbacks quando sair do estado
    input:clear_callbacks()
end

function example_state:update(dt)
    -- Atualizar sistema de input (necessário para Konami code timeout)
    input:update(dt)
end

function example_state:setup_input_callbacks()
    -- Exemplo de callbacks para diferentes ações

    -- Navegação
    input:set_callback('navigate_up', function()
        print("Navegando para cima")
        -- Sua lógica aqui
    end)

    input:set_callback('navigate_down', function()
        print("Navegando para baixo")
        -- Sua lógica aqui
    end)

    input:set_callback('navigate_left', function()
        print("Navegando para esquerda")
        -- Sua lógica aqui
    end)

    input:set_callback('navigate_right', function()
        print("Navegando para direita")
        -- Sua lógica aqui
    end)

    -- Ações principais
    input:set_callback('confirm', function()
        print("Confirmando ação")
        -- Sua lógica aqui
    end)

    input:set_callback('cancel', function()
        print("Cancelando ação")
        -- Sua lógica aqui
    end)

    input:set_callback('pause', function()
        print("Pausando jogo")
        -- Sua lógica aqui
    end)

    input:set_callback('quit', function()
        print("Saindo do jogo")
        love.event.quit()
    end)

    -- Konami code (opcional)
    input:set_konami_callback(function()
        print("Konami code ativado!")
        -- Sua funcionalidade secreta aqui
    end)
end

-- Delegar todos os inputs para o sistema centralizado
function example_state:keypressed(key)
    input:keypressed(key)
end

function example_state:joystickpressed(joystick, button)
    input:joystickpressed(joystick, button)
end

function example_state:gamepadpressed(gamepad, button)
    input:gamepadpressed(gamepad, button)
end

function example_state:mousepressed(x, y, button)
    input:mousepressed(x, y, button)
end

function example_state:draw()
    love.graphics.print("Exemplo de uso do sistema de input centralizado", 10, 10)
    love.graphics.print("Use as setas/WASD para navegar", 10, 40)
    love.graphics.print("Use Enter/Esc para confirmar/cancelar", 10, 70)
    love.graphics.print("Tente o Konami code: ↑↑↓↓←→←→BA", 10, 100)
end

return example_state
