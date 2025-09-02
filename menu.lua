local Gamestate = require 'libs.hump.gamestate'
local options = require 'options'

local menu = {selected = 1}
local music

function menu:enter()
    if not music then
        music = love.audio.newSource('assets/st/main_menu.mp3', 'stream')
        music:setVolume(options.master_volume)
        music:setLooping(true)
    end
    if not music:isPlaying() then
        music:play()
    end
end
function menu:leave()
    if music and music:isPlaying() then
        music:stop()
    end
end

function menu:draw()
    local oldFont = love.graphics.getFont()

    local menuTitleFont = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 64)
    love.graphics.setFont(menuTitleFont)
    love.graphics.setColor(0.2, 0.2, 1)
    love.graphics.printf("L-TYPE", 0, 480/2-150, 640, 'center')

    local menuFont = love.graphics.newFont('assets/fonts/starkwalker_classic/StarkwalkerClassic.otf', 32)
    love.graphics.setFont(menuFont)

    local items = {"Play", "Options", "Credits"}
    for i, item in ipairs(items) do
        if self.selected == i then
            love.graphics.setColor(1, 0.7, 0.2)
        else
            love.graphics.setColor(1,1,1)
        end
        love.graphics.printf(item, 0, 480/2-20 + (i-1)*40, 640, 'center')
    end
    love.graphics.setFont(oldFont)
end

function menu:keypressed(key)
    if key == 'up' or key == 'w' then
        self.selected = self.selected - 1
        if self.selected < 1 then self.selected = 3 end
    elseif key == 'down' or key == 's' then
        self.selected = self.selected + 1
        if self.selected > 3 then self.selected = 1 end
    elseif key == 'return' or key == 'kpenter' then
        if self.selected == 1 then
            Gamestate.switch(require('game'))
        elseif self.selected == 2 then
            Gamestate.switch(require('options'))
        elseif self.selected == 3 then
            Gamestate.switch(require('credits'))
        end
    elseif key == 'escape' then
        love.event.quit()
    end
end

return menu
