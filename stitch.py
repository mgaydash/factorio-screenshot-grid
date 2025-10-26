#!/usr/bin/env python3
"""
Factorio Screenshot Grid Stitcher
Combines individual screenshot tiles into a single panoramic image.
"""

import argparse
import json
import os
import sys
from pathlib import Path
from PIL import Image
from typing import Tuple, List, Optional

def auto_detect_grid_size(input_dir: Path) -> Tuple[int, int]:
    """Auto-detect grid dimensions by scanning for image files."""
    max_row = -1
    max_col = -1
    
    for file in input_dir.glob('image_*_*.png'):
        parts = file.stem.split('_')
        if len(parts) == 3:  # image_row_col format
            try:
                row = int(parts[1])
                col = int(parts[2])
                max_row = max(max_row, row)
                max_col = max(max_col, col)
            except ValueError:
                continue
    
    if max_row == -1 or max_col == -1:
        raise ValueError(f"No valid image files found in {input_dir}")
    
    return max_col + 1, max_row + 1  # Convert to count from 0-based index

def load_images(input_dir: Path, x: int, y: int, verbose: bool = False) -> List[Image.Image]:
    """Load all images from the grid with validation."""
    images = []
    missing = []
    
    total = x * y
    for j in range(y):
        for i in range(x):
            filename = f'image_{j}_{i}.png'
            filepath = input_dir / filename
            
            if not filepath.exists():
                missing.append(filename)
                continue
            
            try:
                img = Image.open(filepath)
                images.append(img)
                if verbose and len(images) % 10 == 0:
                    print(f"Loaded {len(images)}/{total} images...", flush=True)
            except Exception as e:
                print(f"Error loading {filename}: {e}", file=sys.stderr)
                missing.append(filename)
    
    if missing:
        print(f"Warning: {len(missing)} missing images: {missing[:5]}{'...' if len(missing) > 5 else ''}", 
              file=sys.stderr)
    
    if len(images) == 0:
        raise ValueError("No images could be loaded")
    
    return images

def validate_images(images: List[Image.Image]) -> Tuple[int, int]:
    """Validate that all images have the same size."""
    if not images:
        raise ValueError("No images to validate")
    
    width, height = images[0].size
    for i, img in enumerate(images[1:], 1):
        if img.size != (width, height):
            raise ValueError(f"Image {i} has size {img.size}, expected {(width, height)}")
    
    return width, height

def stitch_images(images: List[Image.Image], x: int, y: int, width: int, height: int, 
                  verbose: bool = False) -> Image.Image:
    """Stitch images into a single panorama."""
    full_width = x * width
    full_height = y * height
    
    if verbose:
        print(f"Creating {full_width}x{full_height} image ({full_width * full_height / 1_000_000:.1f} MP)")
    
    full_image = Image.new('RGB', (full_width, full_height))
    images.reverse()
    
    for j in range(y):
        for i in range(x):
            if images:
                full_image.paste(images.pop(), (i * width, j * height))
    
    return full_image

def save_metadata(output_path: Path, x: int, y: int, width: int, height: int):
    """Save stitching metadata as JSON."""
    metadata = {
        "grid_size": {"x": x, "y": y},
        "tile_size": {"width": width, "height": height},
        "total_resolution": {
            "width": x * width,
            "height": y * height,
            "megapixels": round(x * width * y * height / 1_000_000, 2)
        }
    }
    
    metadata_path = output_path.with_suffix('.json')
    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"Metadata saved to {metadata_path}")

def main():
    parser = argparse.ArgumentParser(
        description="Stitch Factorio screenshot tiles into a panoramic image"
    )
    parser.add_argument(
        '-i', '--input-dir',
        type=Path,
        default=Path('script_output'),
        help='Input directory containing image tiles (default: script_output)'
    )
    parser.add_argument(
        '-o', '--output',
        type=Path,
        default=Path('full_map.jpg'),
        help='Output file path (default: full_map.jpg)'
    )
    parser.add_argument(
        '-x', '--width',
        type=int,
        help='Grid width (auto-detected if not specified)'
    )
    parser.add_argument(
        '-y', '--height',
        type=int,
        help='Grid height (auto-detected if not specified)'
    )
    parser.add_argument(
        '-q', '--quality',
        type=int,
        default=95,
        help='JPEG quality (1-100, default: 95)'
    )
    parser.add_argument(
        '-m', '--metadata',
        action='store_true',
        help='Save metadata JSON file'
    )
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Verbose output'
    )
    
    args = parser.parse_args()
    
    try:
        # Determine grid size
        if args.width and args.height:
            x, y = args.width, args.height
            if args.verbose:
                print(f"Using specified grid size: {x}x{y}")
        else:
            x, y = auto_detect_grid_size(args.input_dir)
            print(f"Auto-detected grid size: {x}x{y}")
        
        # Load images
        if args.verbose:
            print(f"Loading {x * y} images from {args.input_dir}...")
        
        images = load_images(args.input_dir, x, y, args.verbose)
        
        # Validate
        width, height = validate_images(images)
        if args.verbose:
            print(f"Tile size: {width}x{height}")
        
        # Stitch
        if args.verbose:
            print("Stitching images...")
        
        full_image = stitch_images(images, x, y, width, height, args.verbose)
        
        # Save
        if args.verbose:
            print(f"Saving to {args.output}...")
        
        save_kwargs = {}
        if args.output.suffix.lower() in ['.jpg', '.jpeg']:
            save_kwargs['quality'] = args.quality
            save_kwargs['optimize'] = True
        
        full_image.save(args.output, **save_kwargs)
        print(f"✓ Saved panorama to {args.output}")
        
        # Save metadata if requested
        if args.metadata:
            save_metadata(args.output, x, y, width, height)
        
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
