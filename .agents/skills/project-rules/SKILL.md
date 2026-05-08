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
- Atual: checa `BUILD_TYPE` duro. Frágil para portáteis (R36S, Anbernic).
- Meta/Regra: Transição para usar 100% a API de Gamepad do LÖVE (`gamepadpressed`, `love.joystick.setGamepadMapping`) no lugar do `joystickpressed` cru. 
- Mapeamento resolve diferenças de OS. Se controle não for lido como gamepad no Linux, usar `gamecontrollerdb.txt` da SDL.

## 3. Pasta `libs/`
- Código de terceiros (apis, frameworks).
- **NÃO MEXER**. Apenas consumir como dependência.

## 4. Pasta `animations/`
- Código gerado por software externo (Tiled).
- **NÃO MEXER**. Arquivos auto-gerados. Edição apenas via Tiled.
