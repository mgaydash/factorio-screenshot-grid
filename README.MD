# Factorio Screenshot Grid

## About

A Factorio mod that automatically detects the bounds of a factory and takes a grid of screenshots to achieve full coverage. Additional tools include a helper to stitch together a single image from the grid and steps to create a Deep Zoom image.

## Installation

### Factorio Mod
- Clone this project into `<Factorio Data Dir>/mods/factorio-screenshot-grid`

### Python Stitcher Tool

Install the Python dependencies:

```bash
# Using pip
pip install pillow

# Or install the package in development mode
pip install -e .

# Or with dev dependencies
pip install -e ".[dev]"
```

## Usage

### 1. Capture Screenshots in Factorio

In-game, run:
```
/screenshot_grid
```

This will capture a grid of screenshots to Factorio's `script_output/` directory.

### 2. Stitch Tiles with Python

The stitcher will auto-detect the grid size:

```bash
python stitch.py

# Or if installed as a package
factorio-stitch
```

Advanced options:

```bash
# Specify input directory and output file
python stitch.py -i /path/to/script_output -o my_factory.jpg

# Manually specify grid dimensions
python stitch.py -x 10 -y 10

# Adjust JPEG quality and save metadata
python stitch.py -q 90 -m -v

# See all options
python stitch.py --help
```

## Deep Zoom Image (DZI) Conversion

```bash
vips dzsave full_image.jpg map
```

## Libraries and Tools

- [Factorio Docs](https://lua-api.factorio.com/stable/)
- [Pillow](https://pillow.readthedocs.io/en/stable/)
- [OpenSeadragon](https://openseadragon.github.io)
- [libvips](https://www.libvips.org)