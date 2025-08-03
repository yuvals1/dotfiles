#!/bin/bash

# Check if argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <pdf-file>"
    exit 1
fi

PDF_FILE="$1"

# Check if file exists
if [ ! -f "$PDF_FILE" ]; then
    echo "Error: File '$PDF_FILE' not found!"
    exit 1
fi

# Check if it's a PDF file
if [[ ! "$PDF_FILE" =~ \.pdf$ ]]; then
    echo "Error: File must be a PDF!"
    exit 1
fi

# Get the directory and base name
DIR=$(dirname "$PDF_FILE")
BASENAME=$(basename "$PDF_FILE" .pdf)
OUTPUT_DIR="$DIR/${BASENAME}-images"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Converting PDF to images using Ghostscript..."
echo "Input: $PDF_FILE"
echo "Output: $OUTPUT_DIR"

# Get absolute paths (Ghostscript doesn't handle ~ well)
ABS_PDF=$(cd "$(dirname "$PDF_FILE")" && pwd)/$(basename "$PDF_FILE")
ABS_OUTPUT_DIR=$(cd "$OUTPUT_DIR" && pwd)

# Convert PDF to images
gs -dNOPAUSE -dBATCH -sDEVICE=jpeg -r300 -dJPEGQ=95 \
   -sOutputFile="$ABS_OUTPUT_DIR/%03d.jpg" \
   "$ABS_PDF"

# Check if conversion was successful
if [ $? -eq 0 ]; then
    # Count the number of images created
    NUM_IMAGES=$(ls -1 "$OUTPUT_DIR"/*.jpg 2>/dev/null | wc -l)
    echo "Success! Created $NUM_IMAGES images in $OUTPUT_DIR"
else
    echo "Error: Conversion failed!"
    exit 1
fi