local input = {
    direction = 'idle',
    fire = false,
    collider_direction = '',

    -- Callbacks para diferentes ações
    callbacks = {
        -- Navegação de menu
        navigate_up = nil,
        navigate_down = nil,
        navigate_left = nil,
        navigate_right = nil,
        confirm = nil,
        cancel = nil,
        pause = nil,
        quit = nil,

        -- Controles de jogo
        move_up = nil,
        move_down = nil,
        move_left = nil,
        move_right = nil,
        move_up_release = nil,
        move_down_release = nil,
        move_left_release = nil,
        move_right_release = nil,
        fire_start = nil,
        fire_end = nil,
        repeller_up = nil,
        repeller_down = nil,
        repeller_left = nil,
        repeller_right = nil
    },

    -- Controle do direcional analógico
    analog_last_state = {x = 0, y = 0},
    analog_cooldown = 0,
    analog_cooldown_duration = 0.2 -- 200ms entre movimentos
}

-- Mapeamento de teclas para ações
local key_mappings = {
    -- Navegação de menu
    navigate_up = {'up', 'w'},
    navigate_down = {'down', 's'},
    navigate_left = {'left', 'a'},
    navigate_right = {'right', 'd'},

    -- Ações de menu
    confirm = {'return', 'kpenter', 'space'},
    cancel = {'escape'},
    pause = {'p'},
    quit = {'q'},

    -- Controles de jogo - movimento
    move_up = {'up', 'w'},
    move_down = {'down', 's'},
    move_left = {'left', 'a'},
    move_right = {'right', 'd'},

    -- Controles de jogo - movimento release
    move_up_release = {'up', 'w'},
    move_down_release = {'down', 's'},
    move_left_release = {'left', 'a'},
    move_right_release = {'right', 'd'},

    -- Controles de jogo - tiro
    fire_start = {'b', 'y'},
    fire_end = {'b', 'y'},

    -- Controles de jogo - repeller (teclas numéricas)
    repeller_up = {'8'},
    repeller_down = {'2'},
    repeller_left = {'4'},
    repeller_right = {'6'}
}

-- Mapeamento de botões de gamepad para ações
local gamepad_mappings = {
    -- Navegação de menu
    navigate_up = {'dpup'},
    navigate_down = {'dpdown'},
    navigate_left = {'dpleft'},
    navigate_right = {'dpright'},

    -- Ações de menu
    confirm = {'start'},
    cancel = {'back', 'select'},
    pause = {'start'},
    quit = {'back'},

    -- Controles de jogo - movimento
    move_up = {'dpup'},
    move_down = {'dpdown'},
    move_left = {'dpleft'},
    move_right = {'dpright'},

    -- Controles de jogo - movimento release
    move_up_release = {'dpup'},
    move_down_release = {'dpdown'},
    move_left_release = {'dpleft'},
    move_right_release = {'dpright'},

    -- Controles de jogo - tiro
    fire_start = {'x', 'y'},
    fire_end = {'x', 'y'},

    -- Controles de jogo - repeller (botões do gamepad)
    repeller_up = {'y'},
    repeller_down = {'a'},
    repeller_left = {'x'},
    repeller_right = {'b'}
}

-- Mapeamento de botões de joystick para ações
local joystick_mappings = {
    -- Navegação de menu (botões numéricos comuns)
    navigate_up = {'1', '2', '3', '4', '5', '6', '7', '8'},
    navigate_down = {'1', '2', '3', '4', '5', '6', '7', '8'},
    navigate_left = {'1', '2', '3', '4', '5', '6', '7', '8'},
    navigate_right = {'1', '2', '3', '4', '5', '6', '7', '8'},

    -- Ações de menu
    confirm = {'1', '2'},
    cancel = {'3', '4'},
    pause = {'5', '6'},
    quit = {'7', '8'},

    -- Controles de jogo - movimento
    move_up = {'1', '2', '3', '4', '5', '6', '7', '8'},
    move_down = {'1', '2', '3', '4', '5', '6', '7', '8'},
    move_left = {'1', '2', '3', '4', '5', '6', '7', '8'},
    move_right = {'1', '2', '3', '4', '5', '6', '7', '8'},

    -- Controles de jogo - movimento release
    move_up_release = {'1', '2', '3', '4', '5', '6', '7', '8'},
    move_down_release = {'1', '2', '3', '4', '5', '6', '7', '8'},
    move_left_release = {'1', '2', '3', '4', '5', '6', '7', '8'},
    move_right_release = {'1', '2', '3', '4', '5', '6', '7', '8'},

    -- Controles de jogo - tiro
    fire_start = {'1', '2'},
    fire_end = {'1', '2'},

    -- Controles de jogo - repeller
    repeller_up = {'1', '2'},
    repeller_down = {'3', '4'},
    repeller_left = {'5', '6'},
    repeller_right = {'7', '8'}
}

-- Função para verificar movimento do direcional analógico esquerdo
function input:check_analog_stick()
    local gamepad = love.joystick.getJoysticks()[1] -- Primeiro gamepad conectado
    if not gamepad then return end

    local left_x = gamepad:getAxis(1) -- Eixo X do direcional esquerdo
    local left_y = gamepad:getAxis(2) -- Eixo Y do direcional esquerdo

    -- Aplicar deadzone para evitar movimento involuntário
    local deadzone = 0.3
    local threshold = 0.5 -- Threshold para considerar movimento significativo

    -- Verificar se há movimento significativo
    local has_movement = math.abs(left_x) > deadzone or math.abs(left_y) > deadzone

    -- Se não há movimento, resetar o estado
    if not has_movement then
        self.analog_last_state.x = 0
        self.analog_last_state.y = 0
        return
    end

    -- Verificar cooldown
    if self.analog_cooldown > 0 then
        return
    end

    -- Verificar movimento vertical (navegação up/down)
    if math.abs(left_y) > deadzone then
        if left_y < -threshold and self.analog_last_state.y >= -threshold then
            -- Movimento para cima (transição de não-cima para cima)
            if self.callbacks.navigate_up then
                self:execute_callback('navigate_up')
                self.analog_cooldown = self.analog_cooldown_duration
            end
        elseif left_y > threshold and self.analog_last_state.y <= threshold then
            -- Movimento para baixo (transição de não-baixo para baixo)
            if self.callbacks.navigate_down then
                self:execute_callback('navigate_down')
                self.analog_cooldown = self.analog_cooldown_duration
            end
        end
    end

    -- Verificar movimento horizontal (navegação left/right)
    if math.abs(left_x) > deadzone then
        if left_x < -threshold and self.analog_last_state.x >= -threshold then
            -- Movimento para esquerda (transição de não-esquerda para esquerda)
            if self.callbacks.navigate_left then
                self:execute_callback('navigate_left')
                self.analog_cooldown = self.analog_cooldown_duration
            end
        elseif left_x > threshold and self.analog_last_state.x <= threshold then
            -- Movimento para direita (transição de não-direita para direita)
            if self.callbacks.navigate_right then
                self:execute_callback('navigate_right')
                self.analog_cooldown = self.analog_cooldown_duration
            end
        end
    end

    -- Atualizar estado anterior
    self.analog_last_state.x = left_x
    self.analog_last_state.y = left_y
end

-- Função para verificar se uma tecla/botão corresponde a uma ação
function input:is_action_pressed(input_value, action)
    -- Verificar teclas
    if key_mappings[action] then
        for _, key in ipairs(key_mappings[action]) do
            if input_value == key then
                return true
            end
        end
    end

    -- Verificar gamepad
    if gamepad_mappings[action] then
        for _, button in ipairs(gamepad_mappings[action]) do
            -- Aplicar swap de botões para Nintendo Switch (NX)
            local mapped_button = button
            if BUILD_TYPE == 'nx' then
                if button == 'a' then
                    mapped_button = 'b'
                elseif button == 'b' then
                    mapped_button = 'a'
                elseif button == 'x' then
                    mapped_button = 'y'
                elseif button == 'y' then
                    mapped_button = 'x'
                end
            end
            if input_value == mapped_button then
                return true
            end
        end
    end

    -- Verificar joystick
    if joystick_mappings[action] then
        for _, button in ipairs(joystick_mappings[action]) do
            if input_value == button then
                return true
            end
        end
    end

    return false
end

-- Função para executar callback se existir
function input:execute_callback(action)
    if self.callbacks[action] and type(self.callbacks[action]) == 'function' then
        self.callbacks[action]()
    end
end

-- Função para configurar callbacks
function input:set_callback(action, callback_func)
    self.callbacks[action] = callback_func
end

-- Função para limpar todos os callbacks
function input:clear_callbacks()
    for action, _ in pairs(self.callbacks) do
        self.callbacks[action] = nil
    end
end

-- Função para adicionar mapeamento customizado
function input:add_custom_mapping(input_value, action)
    -- Adicionar ao mapeamento de teclas
    if not key_mappings[action] then
        key_mappings[action] = {}
    end
    table.insert(key_mappings[action], input_value)

    -- Adicionar ao mapeamento de gamepad
    if not gamepad_mappings[action] then
        gamepad_mappings[action] = {}
    end
    table.insert(gamepad_mappings[action], input_value)

    -- Adicionar ao mapeamento de joystick
    if not joystick_mappings[action] then
        joystick_mappings[action] = {}
    end
    table.insert(joystick_mappings[action], input_value)
end

-- Função para debug - mostrar todos os mapeamentos de uma ação
function input:get_action_mappings(action)
    local mappings = {
        keys = key_mappings[action] or {},
        gamepad = gamepad_mappings[action] or {},
        joystick = joystick_mappings[action] or {}
    }
    return mappings
end

-- Função para debug - mostrar todas as ações disponíveis
function input:get_all_actions()
    local actions = {}
    for action, _ in pairs(self.callbacks) do
        actions[action] = self:get_action_mappings(action)
    end
    return actions
end

-- Função para atualizar sistema de input
function input:update(dt)
    -- Atualizar cooldown do direcional analógico
    if self.analog_cooldown > 0 then
        self.analog_cooldown = self.analog_cooldown - dt
    end

    -- Verificar movimento do direcional analógico esquerdo
    self:check_analog_stick()
end

-- Handlers de input
function input:keypressed(key)
    -- Verificar ações normais
    if BUILD_TYPE == 'pc' then
        for action, _ in pairs(self.callbacks) do
            if self:is_action_pressed(key, action) then
                self:execute_callback(action)
                break -- Evitar múltiplas execuções
            end
        end
    end
end

function input:joystickpressed(joystick, button)
    -- Verificar ações normais
    if BUILD_TYPE == 'portable' or BUILD_TYPE == 'nx' then
        for action, _ in pairs(self.callbacks) do
            if self:is_action_pressed(button, action) then
                self:execute_callback(action)
                break
            end
        end
    end
end

function input:gamepadpressed(gamepad, button)
    -- Verificar ações normais
    if BUILD_TYPE == 'portable' or BUILD_TYPE == 'nx' then
        for action, _ in pairs(self.callbacks) do
            if self:is_action_pressed(button, action) then
                self:execute_callback(action)
                break
            end
        end
    end
end

-- Handlers para eventos de soltar tecla/botão
function input:keyreleased(key)
    -- Ações que precisam de keyreleased (fire_end e movimento release)
    local release_actions = {'fire_end', 'move_up_release', 'move_down_release', 'move_left_release', 'move_right_release'}

    for _, action in ipairs(release_actions) do
        if self.callbacks[action] and self:is_action_pressed(key, action) then
            self:execute_callback(action)
            break
        end
    end
end

function input:gamepadreleased(gamepad, button)
    -- Ações que precisam de gamepadreleased (fire_end e movimento release)
    local release_actions = {'fire_end', 'move_up_release', 'move_down_release', 'move_left_release', 'move_right_release'}

    for _, action in ipairs(release_actions) do
        if self.callbacks[action] and self:is_action_pressed(button, action) then
            self:execute_callback(action)
            break
        end
    end
end

function input:joystickreleased(joystick, button)
    -- Ações que precisam de joystickreleased (fire_end e movimento release)
    local release_actions = {'fire_end', 'move_up_release', 'move_down_release', 'move_left_release', 'move_right_release'}

    for _, action in ipairs(release_actions) do
        if self.callbacks[action] and self:is_action_pressed(button, action) then
            self:execute_callback(action)
            break
        end
    end
end

-- Função para mouse (se necessário)
function input:mousepressed(x, y, button)
    if button == 1 then -- Botão esquerdo
        self:execute_callback('confirm')
    elseif button == 2 then -- Botão direito
        self:execute_callback('cancel')
    end
end

return input