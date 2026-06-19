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

-- Mapeamento de botões de joystick para ações
local joystick_mappings = {
    -- Navegação de menu (botões numéricos comuns)
    navigate_up = {},
    navigate_down = {},
    navigate_left = {'11'},
    navigate_right = {'12'},

    -- Ações de menu
    confirm = {'1', '2', '10'},
    cancel = {'3', '4', '13', '9'},
    pause = {'5', '6', '8', '14', '10'},
    quit = {'7'},

    -- Controles de jogo - movimento
    move_up = {},
    move_down = {},
    move_left = {'11'},
    move_right = {'12'},

    -- Controles de jogo - movimento release
    move_up_release = {},
    move_down_release = {},
    move_left_release = {'11'},
    move_right_release = {'12'},

    -- Controles de jogo - tiro
    fire_start = {'1', '2', '3', '4', '6', '8'},
    fire_end = {'1', '2', '3', '4', '6', '8'},

    -- Controles de jogo - repeller
    repeller_up = {},
    repeller_down = {},
    repeller_left = {},
    repeller_right = {}
}

-- Função para verificar movimento do direcional analógico esquerdo
function input:check_analog_stick()
    local joystick = love.joystick.getJoysticks()[1] -- Primeiro joystick conectado
    if not joystick then return end

    local left_x = joystick:getAxis(1) -- Eixo X do direcional esquerdo
    local left_y = joystick:getAxis(2) -- Eixo Y do direcional esquerdo

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

    -- Verificar D-Pad (Hat)
    if joystick:getHatCount() > 0 then
        local hat = joystick:getHat(1)
        if hat ~= 'c' and self.analog_cooldown <= 0 then
            if hat == 'u' or hat == 'lu' or hat == 'ru' then
                if self.callbacks.navigate_up then self:execute_callback('navigate_up') end
            elseif hat == 'd' or hat == 'ld' or hat == 'rd' then
                if self.callbacks.navigate_down then self:execute_callback('navigate_down') end
            end

            if hat == 'l' or hat == 'lu' or hat == 'ld' then
                if self.callbacks.navigate_left then self:execute_callback('navigate_left') end
            elseif hat == 'r' or hat == 'ru' or hat == 'rd' then
                if self.callbacks.navigate_right then self:execute_callback('navigate_right') end
            end

            self.analog_cooldown = self.analog_cooldown_duration
        end
    end
end

function input:check_trigger_stick()
    local joystick = love.joystick.getJoysticks()[1] -- Primeiro joystick conectado
    if not joystick then return end

    local trigger_x = joystick:getAxis(3) -- Eixo X do trigger esquerdo
    local trigger_y = joystick:getAxis(4) -- Eixo Y do trigger esquerdo
    -- TODO: Implementar trigger stick para tiro
end
-- Função para verificar se um botão de joystick corresponde a uma ação
function input:is_action_pressed(input_type, input_value, action)
    if input_type == 'joystick' then
        if joystick_mappings[action] then
            for _, button in ipairs(joystick_mappings[action]) do
                if input_value == button then
                    return true
                end
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

-- Função para adicionar mapeamento customizado de joystick
function input:add_custom_mapping(input_value, action)
    if not joystick_mappings[action] then
        joystick_mappings[action] = {}
    end
    table.insert(joystick_mappings[action], input_value)
end

-- Função para debug - mostrar todos os mapeamentos de uma ação
function input:get_action_mappings(action)
    local mappings = {
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

-- Função para fazer o controle vibrar
function input:vibrate(duration, left, right)
    local joystick = love.joystick.getJoysticks()[1]
    if joystick and joystick:isVibrationSupported() then
        joystick:setVibration(left or 1, right or 1, duration or 0.1)
    end
end

-- Função para parar a vibração do controle
function input:stop_vibration()
    local joystick = love.joystick.getJoysticks()[1]
    if joystick and joystick:isVibrationSupported() then
        joystick:setVibration(0, 0, 0)
    end
end

function input:update(dt)
    -- Atualizar cooldown do direcional analógico
    if self.analog_cooldown > 0 then
        self.analog_cooldown = self.analog_cooldown - dt
    end

    -- Verificar movimento do direcional analógico esquerdo
    self:check_analog_stick()
    self:check_trigger_stick()
end


function input:joystickpressed(joystick, button)
    -- Verificar ações normais
    for action, _ in pairs(self.callbacks) do
        if self:is_action_pressed('joystick', tostring(button), action) then
            self:execute_callback(action)
            break
        end
    end
end


-- Handlers para eventos de soltar tecla/botão


function input:joystickreleased(joystick, button)
    -- Ações que precisam de joystickreleased (fire_end e movimento release)
    local release_actions = {'fire_end', 'move_up_release', 'move_down_release', 'move_left_release', 'move_right_release'}

    for _, action in ipairs(release_actions) do
        if self.callbacks[action] and self:is_action_pressed('joystick', tostring(button), action) then
            self:execute_callback(action)
            break
        end
    end
end


return input