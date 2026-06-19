---
name: code-style
description: Padrões de codificação e estilo Lua para o projeto L-Type. Aplique essas regras ao escrever ou revisar código.
---

# Padrões de Código L-Type

Quando estiver escrevendo ou revisando código Lua neste projeto, siga estas regras estritamente:

## 1. Escopo
- Use SEMPRE `local` para variáveis e funções, a menos que seja estritamente necessário ser global.
- Se precisar usar uma variável global, adicione um comentário explicando o motivo.
- Evite poluir a tabela global `_G`.

## 2. Nomenclatura
- **Variáveis e Funções**: Use `snake_case` (ex: `player_speed`, `calculate_damage()`).
- **Constantes**: Use `UPPER_SNAKE_CASE` (ex: `MAX_HEALTH = 100`).
- **Classes/Módulos/Objetos**: Use `PascalCase` para o nome da tabela que representa uma classe ou módulo principal (ex: `Player`, `EnemyManager`).

## 3. Estruturas de Dados e Iteração
- **Arrays (tabelas sequenciais)**: Use `ipairs` para iterar sobre elas, pois garante a ordem e é mais rápido.
- **Dicionários (tabelas chave-valor)**: Use `pairs`.
- Limpe referências para objetos que não são mais necessários definindo-os como `nil`, ajudando o *garbage collector*.

## 4. Organização do Módulo
- No final de arquivos que atuam como módulos ou classes, retorne a tabela correspondente (`return Player`).
- Mantenha funções locais acima da tabela principal ou adicione-as diretamente na tabela para clareza estrutural.

## 5. Comentários
- O código deve ser legível por si só com bons nomes de variáveis.
- Use comentários para explicar **por que** algo está sendo feito de forma complexa (regras de negócio específicas) e não **o que** o código está fazendo.
