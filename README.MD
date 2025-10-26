# Factorio Screenshot Grid

## About

A Factorio mod that automatically detects the bounds of a factory and takes a grid of screenshots to achieve full coverage. Additional tools include a helper to stitch together a single image from the grid and steps to create a Deep Zoom image.

## Installation

- Clone this project into `<Factorio Data Dir>/mods/factorio-screenshot-grid`

## Stitch Tiles with Python

See [stitch.py](./stitch.py)

## Deep Zoom Image (DZI) Conversion

```bash
vips dzsave full_image.jpg map
```

## Libraries and Tools

- [Factorio Docs](https://lua-api.factorio.com/stable/)
- [Pillow](https://pillow.readthedocs.io/en/stable/)
- [OpenSeadragon](https://openseadragon.github.io)
- [libvips](https://www.libvips.org)