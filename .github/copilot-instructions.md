# Factorio Screenshot Grid Mod

## Project Overview

A Factorio 2.0 mod that automatically captures grid-based screenshots of a factory by detecting building boundaries. The mod consists of a Lua control script for in-game screenshot capture and a Python utility for image stitching.

## Architecture

- **control.lua**: Main mod logic with custom commands (`/screenshot_grid`, `/detect`, `/pos`, `/hello`)
- **info.json**: Factorio mod manifest (version 2.0 compatible)
- **stitch.py**: Post-processing tool to merge screenshot tiles into a single image

## Key Patterns

### Entity Detection for Bounds
The mod uses `surface.find_entities_filtered` to find production buildings, belts, and infrastructure that define factory boundaries. The `is_near_other()` function filters isolated entities by checking for neighbors within a 2-tile radius.

### Screenshot Grid Logic
- Calculates grid coverage based on detected bounds (`x_min`, `x_max`, `y_min`, `y_max`)
- Uses tile size (32) and configurable resolution (2000x2000) to determine grid dimensions
- Naming convention: `image_{y_index}_{x_index}.png` where indices start from 0

### Commands Structure
All commands follow pattern: `commands.add_command("name", nil, function(command) ... end)`

## Development Workflow

### Testing the Mod
1. Mod auto-loads from: `<Factorio Data Dir>/mods/factorio-screenshot-grid`
2. In-game: `/screenshot_grid` to capture, `/detect` to visualize bounds with inserters
3. Screenshots save to Factorio's `script_output/` directory

### Post-Processing
```bash
# Edit x, y values in stitch.py to match grid size
python stitch.py  # Creates full_map.jpg
vips dzsave full_map.jpg map  # Creates Deep Zoom Image tiles
```

## Factorio API Specifics

- Use `game.player.surface` for world interactions
- Positions are {x, y} tables, not objects
- `defines.direction.north` for entity orientation
- Clean up surface decoratives and set daytime=0 before screenshots for consistency
- Use `game.take_screenshot` with precise position calculations: `i * x_size / tile_size / zoom + x_center`

## Critical Implementation Details

### Coordinate System
- Grid indices loop from `-radius` to `+radius` in code
- Filename indices should be 0-based (achieved by adding radius to negative values)
- stitch.py expects row-major ordering with indices starting at 0

## Entity Types for Detection
The mod tracks 40+ entity types including assemblers, belts, power poles, refineries, and defensive structures. Add new types to the `find_entities_filtered` name array to expand detection coverage.
