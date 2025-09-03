local audio_files = {
    "assets/st/jimmy/Bolsonaro - Tarado.mp3",
    "assets/st/jimmy/Alexandre Frota - O negocio é come cu e buceta.mp3",
    "assets/st/jimmy/especialista - skylab.mp3",
    "assets/st/jimmy/NENHO - Desça Daí Seu Corno, desça saí short meme.mp3",
    "assets/st/jimmy/pegue_no_meu_pau.mp3",
    "assets/st/jimmy/PODER360 - Bolsonaro - Imbrochável, imbrochável.mp3",
    "assets/st/jimmy/The Weather Girls - Its Raining Men trecho short meme.mp3",
    "assets/st/jimmy/ORIGINAL - nada sai do anus completa.mp3",
    "assets/st/jimmy/Lula - Tirar a camisa, ir pro boteco, pedir uma cerveja gelada e ficar conversando.mp3",
    "assets/st/jimmy/Olavo de Carvalho - Toda piroca se torna invisível a partir do momento que ela entra no seu cu short curto.mp3",
    "assets/st/jimmy/Molejo - Samba Diferente - Faz carinha de quem tá gostando demais.mp3"
}
local audio_queue = {}
local current_audio = nil
local audio_timer = 0
local audio_delay = 1 -- segundos entre áudios
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
    -- Embaralhar áudios
    audio_queue = {}
    for i, v in ipairs(audio_files) do audio_queue[i] = v end
    for i = #audio_queue, 2, -1 do
        local j = math.random(i)
        audio_queue[i], audio_queue[j] = audio_queue[j], audio_queue[i]
    end
    current_audio = nil
    audio_timer = 0
end

function jimmy_state:update(dt)
    -- Controle de áudio
    if (not current_audio or not current_audio:isPlaying()) and #audio_queue > 0 then
        audio_timer = audio_timer + dt
        if audio_timer >= audio_delay then
            audio_timer = 0
            local next_file = table.remove(audio_queue, 1)
            current_audio = love.audio.newSource(next_file, 'static')
            current_audio:play()
        end
    end
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
