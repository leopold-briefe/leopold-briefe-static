#!/bin/bash

set -euo pipefail

SOURCE_DIR="/home/csae8092/Schreibtisch/ACDH_DHRI_leopoldBriefe/scans/OÖLA"
TARGET_DIR="./html/facs"

if [[ ! -d "$SOURCE_DIR" ]]; then
	echo "Source directory not found: $SOURCE_DIR" >&2
	exit 1
fi

mkdir -p "$TARGET_DIR"

echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_DIR"
echo "Searching for images..."

if command -v magick >/dev/null 2>&1; then
	IMG_CMD=(magick)
elif command -v convert >/dev/null 2>&1; then
	IMG_CMD=(convert)
else
	echo "ImageMagick not found (neither 'magick' nor 'convert' is available)." >&2
	exit 1
fi

processed=0

while IFS= read -r -d '' file; do
	base_name="$(basename "$file")"
	out_file="$TARGET_DIR/${base_name%.*}.jpg"

	echo "Processing: $file"
	echo "-> $out_file"

	"${IMG_CMD[@]}" "$file" \
		-strip \
		-colorspace Gray \
		-quality 80 \
		-resize x1200 \
		"$out_file"

	processed=$((processed + 1))
done < <(
	find "$SOURCE_DIR" -type f \( \
		-iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o \
		-iname "*.tif" -o -iname "*.tiff" -o -iname "*.webp" \
	\) -print0
)

echo "Done. Processed $processed images."