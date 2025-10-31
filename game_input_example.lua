-- Exemplo de uso do sistema de input centralizado no game.lua
-- Este arquivo demonstra como o sistema funciona com controles de jogo

local input = require 'input'

local game_example = {}

function game_example:enter()
    print("=== SISTEMA DE INPUT CENTRALIZADO - GAME.LUA ===")
    self:setup_input_callbacks()
    print("Controles configurados!")
    print("")
    print("Controles disponíveis:")
    print("- Tiro: B/Y (teclado), X/Y (gamepad) - SISTEMA CENTRALIZADO")
    print("- Repeller: 8/2/4/6 (teclado), Y/A/X/B (gamepad) - SISTEMA CENTRALIZADO")
    print("- Movimento: WASD/Setas (teclado), D-pad (gamepad) - SISTEMA CENTRALIZADO")
    print("- Pausa: P (teclado), Start (gamepad) - SISTEMA CENTRALIZADO")
    print("- Menu: Esc (teclado), Back (gamepad) - SISTEMA CENTRALIZADO")
    print("- Navegação Menu: ↑↓/WS (teclado), D-pad/Analógico (gamepad) - SISTEMA CENTRALIZADO")
end

function game_example:leave()
    input:clear_callbacks()
end

function game_example:update(dt)
    input:update(dt)
end

function game_example:setup_input_callbacks()
    -- Callbacks de tiro (normal e carregado)
    input:set_callback('fire_start', function()
        print("🔫 Iniciando carregamento do tiro...")
    end)
    
    input:set_callback('fire_end', function()
        print("💥 Tiro disparado!")
    end)
    
    -- Callbacks de controle do repeller (direcional)
    input:set_callback('repeller_up', function()
        print("⬆️ Repeller direcionado para cima")
    end)
    
    input:set_callback('repeller_down', function()
        print("⬇️ Repeller direcionado para baixo")
    end)
    
    input:set_callback('repeller_left', function()
        print("⬅️ Repeller direcionado para esquerda")
    end)
    
    input:set_callback('repeller_right', function()
        print("➡️ Repeller direcionado para direita")
    end)
    
    -- Callbacks de controle do jogo
    input:set_callback('pause', function()
        print("⏸️ Jogo pausado")
    end)
    
    input:set_callback('cancel', function()
        print("🚪 Voltando ao menu")
    end)
end

-- Delegar inputs para o sistema centralizado
function game_example:keypressed(key)
    input:keypressed(key)
end

function game_example:keyreleased(key)
    input:keyreleased(key)
end

function game_example:joystickpressed(joystick, button)
    input:joystickpressed(joystick, button)
end

function game_example:joystickreleased(joystick, button)
    input:joystickreleased(joystick, button)
end

function game_example:gamepadpressed(gamepad, button)
    input:gamepadpressed(gamepad, button)
end

function game_example:gamepadreleased(gamepad, button)
    input:gamepadreleased(gamepad, button)
end

function game_example:mousepressed(x, y, button)
    input:mousepressed(x, y, button)
end

function game_example:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("SISTEMA DE INPUT CENTRALIZADO - GAME.LUA", 10, 10)
    love.graphics.print("", 10, 30)
    love.graphics.print("Controles de Tiro:", 10, 50)
    love.graphics.print("  B/Y: Iniciar carregamento", 10, 70)
    love.graphics.print("  Soltar: Disparar", 10, 90)
    love.graphics.print("", 10, 110)
    love.graphics.print("Controles do Repeller:", 10, 130)
    love.graphics.print("  8/2/4/6: Direcionar", 10, 150)
    love.graphics.print("  Y/A/X/B: Direcionar (gamepad)", 10, 170)
    love.graphics.print("", 10, 190)
    love.graphics.print("Controles do Jogo:", 10, 210)
    love.graphics.print("  P/Start: Pausar", 10, 230)
    love.graphics.print("  Esc/Back: Menu", 10, 250)
    love.graphics.print("", 10, 270)
    love.graphics.print("• Tiro, Repeller, Movimento, Pausa, Menu", 10, 350)
    love.graphics.print("• Lógica movida para player.lua", 10, 370)
    love.graphics.print("• game.lua apenas delega para input.lua", 10, 390)
    love.graphics.print("• Direcional analógico para navegação", 10, 410)
    love.graphics.print("", 10, 430)
    love.graphics.print("Verifique o console para ver os resultados!", 10, 450)
end

return game_example
