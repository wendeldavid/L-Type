# L-Type

L-Type is an R-Type clone developed in Lua using the [Love2D](https://love2d.org/) framework.

## Libraries used (folder `libs/`)

- **anim8**: Sprite animation library for Love2D. [anim8](https://github.com/kikito/anim8)
- **hump**: Utility collection for Love2D games (gamestate, timer, vector, camera, etc). [hump](https://github.com/vrld/hump)
- **Simple-Tiled-Implementation (STI)**: Tiled map loader and renderer for Love2D. [STI](https://github.com/karai17/Simple-Tiled-Implementation)
- **windfield**: Physics module for Love2D, simplifies Box2D usage. [windfield](https://github.com/SSYGEN/windfield)

All libraries are included in the project's `libs/` folder.

## How to run

1. Install Love2D on your system.
2. Run the project with:
	```bash
	love .
	```

## How to package

To create a binary or `.love` file, run `make`. This will package "L-Type.love" locally.

## Copy to R36S

If you develop on linux, and want to install this game on R36S partition, just run `make deploy`