local Gamestate = require 'libs.hump.gamestate'

local options = {}

local font = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 32)

local getControls = function()
    if BUILD_TYPE == 'portable' then
        return {
            {key = "Direcional ou Analógico esquerdo", action = "Mover a nave"},
            {key = "Y/R2", action = "Atirar"},
            {key = "Analógico direito", action = "Direção do escudo defletor"},
            {key = "Start", action = "Menu/Pausa"},
            {key = "Select", action = "Sair do jogo"},
            {key = "A", action = "Selecionar no menu"},
        }
    end

    if BUILD_TYPE == 'pc' then
        return {
            {key = "Setas/WASD", action = "Mover a nave"},
            {key = "B/Y", action = "Atirar"},
            {key = "Mouse", action = "Direção do escudo defletor"},
            {key = "ESC", action = "Menu/Pausa"},
            {key = "P", action = "Pausar o jogo"},
            {key = "Espaço/Enter", action = "Selecionar no menu"},
        }
    end

    -- TODO touch
end

function options:draw()
    love.graphics.setFont(font)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Opções", 0, 40, 640, 'center')
    love.graphics.printf("easy mode", 0, 100, 640, 'center')

    -- Instruções dos controles do jogo (alinhamento justificado)
    local controls = getControls()
    local fontControls = love.graphics.newFont(16)
    love.graphics.setFont(fontControls)
    love.graphics.setColor(1,1,0.7)
    love.graphics.printf("Controles:", 0, 140, 640, 'center')
    love.graphics.setColor(1,1,1)
    local x1, x2 = 50, 400
    for i, c in ipairs(controls) do
        local y = 180 + (i-1) * 22
        love.graphics.printf(c.key, x1, y, 380, 'left')
        love.graphics.printf(c.action, x2, y, 460, 'left')
    end
end

function options:keypressed(key)
    if key == 'escape' then
        Gamestate.switch(require('menu'))
    end
end

return options
