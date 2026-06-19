# L-Type Project Guidelines

## Operating Mode
**Always use caveman mode** by default for all interactions. This compresses output ~75% while preserving technical accuracy.

## Code Style & Standards
Follow the Lua conventions in [`.agents/skills/code-style/`](./.agents/skills/code-style/SKILL.md):
- Consistent naming conventions
- Proper indentation and formatting
- Follow patterns in existing code

## Project Architecture
Understand L-Type structure from [`.agents/skills/architecture/`](./.agents/skills/architecture/SKILL.md):
- Game state lifecycle
- LÖVE 2D framework patterns
- Component interactions

## Project Rules
Respect constraints in [`.agents/skills/project-rules/`](./.agents/skills/project-rules/SKILL.md):
- Handle inputs and libs correctly
- Follow Tiled-generated code patterns


## Specialized Skills
Use these for specific tasks:
- **caveman-commit**: Commit messages
- **caveman-review**: Code reviews
- **caveman-compress**: Compress memory files

## Key Files
- Entry point: [`main.lua`](../../main.lua)
- Player: [`player.lua`](../../player.lua)
- Input: [`input.lua`](../../input.lua)
- GameState: [`game.lua`](../../game.lua)
- Enemy: [`enemy.lua`](../../enemy.lua)
- Enemy projectiles: [`enemy_projectile.lua`](../../enemy_projectile.lua)
- Input joystick: [`input.lua`](../../input.lua)
- Options: [`options.lua`](../../options.lua)
- Menu: [`menu.lua`](../../menu.lua)
- Stage01: [`stage-01.lua`](../../stage-01.lua)