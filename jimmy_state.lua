local pressed_keys = {}
-- Função utilitária para cortar string em UTF-8 corretamente
local function utf8_sub(str, start_char, end_char)
    local utf8 = require("utf8")
    local start_byte = utf8.offset(str, start_char)
    local end_byte = end_char and (utf8.offset(str, end_char+1) - 1) or #str
    if start_byte and end_byte then
        return str:sub(start_byte, end_byte)
    elseif start_byte then
        return str:sub(start_byte)
    else
        return ""
    end
end
local Gamestate = require 'libs.hump.gamestate'

local jimmy_state = {}
local dialogs = require 'dialogs'
local dialog_index = 1
local typewriter_timer = 0
local typewriter_pos = 0
local typewriter_speed = 0.2 -- segundos por caractere

function jimmy_state:enter()
    typewriter_timer = 0
    typewriter_pos = 0
end

function jimmy_state:update(dt)
    if dialogs and dialogs.dialogos and dialogs.dialogos[dialog_index] then
        local fala = dialogs.dialogos[dialog_index].fala or ""
        local utf8 = require("utf8")
        local total_chars = utf8.len(fala)
        if typewriter_pos < total_chars then
            typewriter_timer = typewriter_timer + dt
            while typewriter_timer >= typewriter_speed and typewriter_pos < total_chars do
                typewriter_timer = typewriter_timer - typewriter_speed
                typewriter_pos = typewriter_pos + 1
            end
        end
    end
end

function jimmy_state:draw()
    -- Renderizar o diálogo atual centralizado com efeito de digitação
    if dialogs and dialogs.dialogos and dialogs.dialogos[dialog_index] then
        local d = dialogs.dialogos[dialog_index]
        local w, h = love.graphics.getWidth(), love.graphics.getHeight()
        local font = love.graphics.newFont(28)
        love.graphics.setFont(font)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(d.personagem .. ':', 40, h/2 - 40, w-80, 'left')
        love.graphics.setColor(1,1,0.7)
    local fala = d.fala or ""
    local utf8 = require("utf8")
    local total_chars = utf8.len(fala)
    local chars_to_show = typewriter_pos
    if chars_to_show > total_chars then chars_to_show = total_chars end
    local text = utf8_sub(fala, 1, chars_to_show)
    love.graphics.printf('"' .. text .. '"', 0, h/2, w, 'center')
        love.graphics.setColor(1,1,1)
    end
end

function jimmy_state:keypressed(key)
    pressed_keys[key] = true
    if key == 'lshift' then
        if dialogs and dialogs.dialogos then
            local fala = dialogs.dialogos[dialog_index].fala or ""
            local utf8 = require("utf8")
            local total_chars = utf8.len(fala)
            if typewriter_pos < total_chars then
                -- Completa o texto imediatamente
                typewriter_pos = total_chars
            elseif typewriter_pos == total_chars then
                if dialog_index < #dialogs.dialogos then
                    dialog_index = dialog_index + 1
                    typewriter_pos = 0
                    typewriter_timer = 0
                else
                    Gamestate.switch(require('game'))
                end
            end
        end
    end

    -- Checa combinação simultânea l + x + y + r
    if pressed_keys['l'] and pressed_keys['x'] and pressed_keys['y'] and pressed_keys['r'] then
        Gamestate.switch(require('game'))
    end
end

function jimmy_state:keyreleased(key)
    pressed_keys[key] = false
end

return jimmy_state
