local input = {
    direction = 'idle',
    fire = false,
    collider_direction = '',

    -- Callbacks para diferentes ações
    callbacks = {
        navigate_up = nil,
        navigate_down = nil,
        navigate_left = nil,
        navigate_right = nil,
        confirm = nil,
        cancel = nil,
        pause = nil,
        quit = nil
    },

    -- Konami code
    konami_sequence = {'up', 'up', 'down', 'down', 'left', 'right', 'left', 'right', 'b', 'a'},
    konami_progress = 0,
    konami_timeout = 0,
    konami_timeout_duration = 3,
    konami_callback = nil
}

-- Mapeamento de teclas para ações
local key_mappings = {
    -- Navegação
    navigate_up = {'up', 'w'},
    navigate_down = {'down', 's'},
    navigate_left = {'left', 'a'},
    navigate_right = {'right', 'd'},

    -- Ações
    confirm = {'return', 'kpenter', 'space'},
    cancel = {'escape'},
    pause = {'p'},
    quit = {'q'}
}

-- Mapeamento de botões de gamepad para ações
local gamepad_mappings = {
    -- Navegação
    navigate_up = {'dpup'},
    navigate_down = {'dpdown'},
    navigate_left = {'dpleft'},
    navigate_right = {'dpright'},

    -- Ações
    confirm = {'a', 'start'},
    cancel = {'back', 'select'},
    pause = {'start'},
    quit = {'back'}
}

-- Mapeamento de botões de joystick para ações
local joystick_mappings = {
    -- Navegação (botões numéricos comuns)
    navigate_up = {'1', '2', '3', '4', '5', '6', '7', '8'},
    navigate_down = {'1', '2', '3', '4', '5', '6', '7', '8'},
    navigate_left = {'1', '2', '3', '4', '5', '6', '7', '8'},
    navigate_right = {'1', '2', '3', '4', '5', '6', '7', '8'},

    -- Ações
    confirm = {'1', '2'},
    cancel = {'3', '4'},
    pause = {'5', '6'},
    quit = {'7', '8'}
}

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
            if input_value == button then
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

-- Função para configurar callback do Konami code
function input:set_konami_callback(callback_func)
    self.konami_callback = callback_func
end

-- Função para verificar Konami code
function input:check_konami_code(input_value)
    if self.konami_sequence[self.konami_progress + 1] == input_value then
        self.konami_progress = self.konami_progress + 1
        self.konami_timeout = 0

        if self.konami_progress == #self.konami_sequence then
            if self.konami_callback and type(self.konami_callback) == 'function' then
                self.konami_callback()
            end
            self.konami_progress = 0
        end
    else
        self.konami_progress = 0
        self.konami_timeout = 0
    end
end

-- Função para atualizar timeout do Konami code
function input:update(dt)
    if self.konami_progress > 0 then
        self.konami_timeout = self.konami_timeout + dt
        if self.konami_timeout >= self.konami_timeout_duration then
            self.konami_progress = 0
            self.konami_timeout = 0
        end
    end
end

-- Handlers de input
function input:keypressed(key)
    -- Verificar Konami code primeiro
    self:check_konami_code(key)

    -- Verificar ações normais
    for action, _ in pairs(self.callbacks) do
        if self:is_action_pressed(key, action) then
            self:execute_callback(action)
            break -- Evitar múltiplas execuções
        end
    end
end

function input:joystickpressed(joystick, button)
    -- Verificar Konami code primeiro
    self:check_konami_code(button)

    -- Verificar ações normais
    for action, _ in pairs(self.callbacks) do
        if self:is_action_pressed(button, action) then
            self:execute_callback(action)
            break
        end
    end
end

function input:gamepadpressed(gamepad, button)
    -- Verificar Konami code primeiro
    self:check_konami_code(button)

    -- Verificar ações normais
    for action, _ in pairs(self.callbacks) do
        if self:is_action_pressed(button, action) then
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