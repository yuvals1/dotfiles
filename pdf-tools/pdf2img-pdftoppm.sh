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

echo "Converting PDF to images using pdftoppm..."
echo "Input: $PDF_FILE"
echo "Output: $OUTPUT_DIR"

# Convert PDF to images
pdftoppm -jpeg -r 300 -jpegopt quality=95 "$PDF_FILE" "$OUTPUT_DIR/page"

# Check if conversion was successful
if [ $? -eq 0 ]; then
    # Rename files to match the format 001.jpg, 002.jpg, etc.
    cd "$OUTPUT_DIR"
    for file in page-*.jpg; do
        if [ -f "$file" ]; then
            # Extract page number and pad with zeros
            pagenum=$(echo "$file" | sed 's/page-\([0-9]*\)\.jpg/\1/')
            newname=$(printf "%03d.jpg" "$pagenum")
            mv "$file" "$newname"
        fi
    done
    
    # Count the number of images created
    NUM_IMAGES=$(ls -1 *.jpg 2>/dev/null | wc -l)
    echo "Success! Created $NUM_IMAGES images in $OUTPUT_DIR"
else
    echo "Error: Conversion failed!"
    exit 1
fi