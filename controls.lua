local controls = {}

function controls.up() return love.keyboard.isDown('up') or love.keyboard.isDown('w') end
function controls.down() return love.keyboard.isDown('down') or love.keyboard.isDown('s') end
function controls.left() return love.keyboard.isDown('left') or love.keyboard.isDown('a') end
function controls.right() return love.keyboard.isDown('right') or love.keyboard.isDown('d') end

return controls
