#!/usr/bin/env python3
"""
Update version in both info.json and pyproject.toml
Usage: python update_version.py <new_version>
Example: python update_version.py 0.2.0
"""

import json
import sys
import re
from pathlib import Path


def update_info_json(version: str) -> None:
    """Update version in info.json"""
    info_path = Path(__file__).parent.parent / "info.json"
    
    with open(info_path, 'r') as f:
        data = json.load(f)
    
    old_version = data['version']
    data['version'] = version
    
    with open(info_path, 'w') as f:
        json.dump(data, f, indent=2)
        f.write('\n')
    
    print(f"✓ Updated info.json: {old_version} → {version}")


def update_pyproject_toml(version: str) -> None:
    """Update version in pyproject.toml"""
    pyproject_path = Path(__file__).parent.parent / "pyproject.toml"
    
    with open(pyproject_path, 'r') as f:
        content = f.read()
    
    # Find current version
    match = re.search(r'version\s*=\s*"([^"]+)"', content)
    if not match:
        raise ValueError("Could not find version in pyproject.toml")
    
    old_version = match.group(1)
    
    # Replace version
    new_content = re.sub(
        r'(version\s*=\s*)"[^"]+"',
        rf'\1"{version}"',
        content
    )
    
    with open(pyproject_path, 'w') as f:
        f.write(new_content)
    
    print(f"✓ Updated pyproject.toml: {old_version} → {version}")


def validate_version(version: str) -> bool:
    """Validate semantic version format (e.g., 0.1.0, 1.2.3)"""
    pattern = r'^\d+\.\d+\.\d+$'
    return bool(re.match(pattern, version))


def main():
    if len(sys.argv) != 2:
        print("Usage: python update_version.py <new_version>")
        print("Example: python update_version.py 0.2.0")
        sys.exit(1)
    
    new_version = sys.argv[1]
    
    if not validate_version(new_version):
        print(f"Error: Invalid version format '{new_version}'")
        print("Version must be in semantic versioning format: X.Y.Z")
        sys.exit(1)
    
    try:
        update_info_json(new_version)
        update_pyproject_toml(new_version)
        print(f"\n✓ Successfully updated version to {new_version}")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
