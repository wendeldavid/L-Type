---
name: project-rules
description: Regras do projeto L-Type. Lida com inputs, libs e código gerado (Tiled).
---

# Regras L-Type

Contexto do repo L-Type. Usar como base para próximos prompts.

## 1. Padrão de Inputs
- Tudo em `input.lua`.
- Orientado a eventos. Sistema de `input:set_callback('acao', func)`.
- `main.lua` escuta OS (`love.keypressed`, `love.gamepadpressed`) e passa pro `input.lua`.
- Estados (como `menu.lua`) e Entidades (como `player.lua`) registram e limpam seus callbacks.

## 2. Normalização de Inputs (Linux vs Consoles)
- Meta/Regra: Transição para priorizar a API de Joystick puro do LÖVE (`joystickpressed`, `joystickreleased`) em vez de Gamepad. Consoles portáteis Linux (ex: R36S, Anbernic) nem sempre detectam nativamente como gamepad.
- O sistema de input deve usar mapeamentos numéricos cruzados para suportar qualquer joystick plugado ou embutido de forma agnóstica sem depender de `BUILD_TYPE`.

## 3. Pasta `libs/`
- Código de terceiros (apis, frameworks).
- **NÃO MEXER**. Apenas consumir como dependência.

## 4. Pasta `animations/`
- Código gerado por software externo (Tiled).
- **NÃO MEXER**. Arquivos auto-gerados. Edição apenas via Tiled.
