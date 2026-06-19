---
name: architecture
description: Padrões de arquitetura, ciclo de vida e estrutura de estados do projeto L-Type usando LÖVE 2D.
---

# Arquitetura e Estrutura L-Type

Diretrizes arquiteturais para o projeto L-Type:

## 1. Gerenciamento de Estados (State Machine)
- O jogo é dividido em estados discretos localizados na raiz (ex: `game.lua`, `menu.lua`, `game_over.lua`, `paused.lua`).
- Cada estado deve exportar funções padrão de ciclo de vida (ex: `enter()`, `update(dt)`, `draw()`, `leave()`).
- O `main.lua` deve focar na inicialização geral, loop principal do framework e delegação de `update` e `draw` para o estado ativo no momento, evitando lógica de jogo pesada ali.

## 2. Responsabilidades por Domínio
- **Física vs Renderização**: A separação deve ser clara. `update(dt)` processa física, colisões e lógica. `draw()` APENAS lê os estados para enviar comandos ao `love.graphics.*`.
- **Entidades**: O código de um inimigo, do jogador ou de um objeto específico deve ser encapsulado no seu próprio arquivo/tabela. Não misture a lógica do Jogador dentro do `game.lua`. O `game.lua` apenas orquestra.

## 3. Manipulação de Input
- **Regra de Ouro**: Inputs são gerenciados por eventos através de `input.lua`.
- Estados e entidades ativas devem registrar (`input:set_callback`) seus manipuladores durante sua inicialização/entrada (`enter`) e desregistrar/limpar na saída (`leave`).

## 4. Bibliotecas e Assets Gerados
- A pasta `libs/` é exclusiva para dependências externas não-modificáveis.
- A pasta `animations/` contém código gerado por editores externos (Tiled). Não altere o código gerado manualmente, pois será sobrescrito em futuras exportações.

## 5. Tratamento de Tempo (Timers)
- Prefira usar bibliotecas de temporização (ex: cron, tick, hump.timer) caso já existam no projeto em vez de criar dezenas de `timer = timer - dt` locais. Se precisar fazer contadores manuais, isole-os bem na tabela da entidade.
