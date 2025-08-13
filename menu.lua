local Gamestate = require 'libs.hump.gamestate'
local menu = {selected = 1}

function menu:draw()
    love.graphics.setColor(1,1,1)
    love.graphics.printf("L-TYPE", 0, 480/2-80, 640, 'center')
    local items = {"Jogar", "Opções", "Créditos"}
    for i, item in ipairs(items) do
        if self.selected == i then
            love.graphics.setColor(1, 0.7, 0.2)
        else
            love.graphics.setColor(1,1,1)
        end
        love.graphics.printf(item, 0, 480/2-20 + (i-1)*40, 640, 'center')
    end
end

function menu:keypressed(key)
    if key == 'up' then
        self.selected = self.selected - 1
        if self.selected < 1 then self.selected = 3 end
    elseif key == 'down' then
        self.selected = self.selected + 1
        if self.selected > 3 then self.selected = 1 end
    elseif key == 'return' or key == 'kpenter' then
        if self.selected == 1 then
            Gamestate.switch(require('game'))
        elseif self.selected == 2 then
            Gamestate.switch(require('controls'))
        elseif self.selected == 3 then
            Gamestate.switch(require('credits'))
        end
    elseif key == 'escape' then
        love.event.quit()
    end
end

return menu
