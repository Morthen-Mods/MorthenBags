#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

destination_folder="./build"

# Find the first .toc file in the current directory
toc_file=$(find . -maxdepth 1 -name '*.toc' -type f | sort | head -n 1)
if [ -z "$toc_file" ]; then
    echo "Error: No .toc file found in the current directory. Task will be terminated." >&2
    exit 1
fi
echo "Found TOC file: $(basename "$toc_file")"

echo "Reading metadata from '$(basename "$toc_file")'..."

addon_name=$(grep -E '^[[:space:]]*##[[:space:]]*Title:' "$toc_file" | head -n 1 | sed -E 's/^[^:]*:[[:space:]]*//; s/[[:space:]]+$//')
if [ -z "$addon_name" ]; then
    echo "Error: No '## Title:' found in .toc file. Cannot determine addon name. Task will be terminated." >&2
    exit 1
fi
echo "Addon name found: $addon_name"

version=$(grep -E '^[[:space:]]*##[[:space:]]*Version:' "$toc_file" | head -n 1 | sed -E 's/^[^:]*:[[:space:]]*//; s/[[:space:]]+$//')
if [ -z "$version" ]; then
    version="0.0.0-dev"
    echo "Warning: No '## Version:' found in .toc file. Using '$version' as fallback." >&2
else
    echo "Version found: $version"
fi

zip_file="$destination_folder/${addon_name}-${version}.zip"
echo "ZIP archive name: '$zip_file'"

# Collect source files, excluding the build folder itself
mapfile -t source_files < <(find . -type f \
    \( -name '*.lua' -o -name '*.toc' -o -name '*.tga' -o -name '*.png' \) \
    -not -path './build/*')

# Reset the build folder
rm -rf "$destination_folder"
mkdir -p "$destination_folder"

target_root="$destination_folder/$addon_name"

echo "Copying files and preserving directory structure..."
for item in "${source_files[@]}"; do
    relative_path="${item#./}"
    destination_path="$target_root/$relative_path"
    mkdir -p "$(dirname "$destination_path")"
    cp "$item" "$destination_path"
    echo "Copied '$relative_path'"
done

rm -f "$zip_file"

# Create the archive with the addon folder at its root
(cd "$destination_folder" && zip -r -q "${addon_name}-${version}.zip" "$addon_name")

echo "Delete temporary data..."
rm -rf "$target_root"

echo "ZIP archive created: $zip_file"