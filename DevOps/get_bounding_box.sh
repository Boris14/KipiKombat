#!/bin/bash

# Final, robust version of get_bounding_box.sh
# It prints helpful logs to Standard Error, so it does not interfere
# with the main output that other scripts need to capture.

# --- Argument Check ---
if [ "$#" -ne 1 ]; then
  # Print errors to stderr
  echo "Error: Incorrect number of arguments." >&2
  echo "Usage: $0 <input_image>" >&2
  exit 1
fi

INPUT_IMAGE="$1"

if [ ! -f "$INPUT_IMAGE" ]; then
  echo "Error: File not found: '$INPUT_IMAGE'" >&2
  exit 1
fi

# --- ImageMagick Check ---
if ! command -v magick &> /dev/null; then
  echo "Error: ImageMagick 'magick' command not found." >&2
  exit 1
fi

# The '>&2' redirects this echo command's output to Standard Error.
echo "LOG: Calculating bounding box..." >&2

# --- Create a temporary file for the trimmed image ---
TEMP_FILE=$(mktemp --suffix=.png)

# --- Set a trap to automatically clean up the temporary file on exit ---
trap 'rm -f "$TEMP_FILE"' EXIT

# --- Get the X and Y offsets from the original image ---
OFFSETS=$(magick "$INPUT_IMAGE" -trim -format "%[fx:page.x] %[fx:page.y]" info:)
read -r X Y <<< "$OFFSETS"

# --- Trim the image and save it to the temporary file ---
# THIS LINE HAS BEEN CORRECTED ($INPUT_eIMAGE -> $INPUT_IMAGE)
magick "$INPUT_IMAGE" -trim +repage "$TEMP_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create the temporary trimmed image." >&2
    exit 1
fi

# --- Get the Width and Height from the new temporary file ---
DIMENSIONS=$(magick "$TEMP_FILE" -format "%W %H" info:)
read -r WIDTH HEIGHT <<< "$DIMENSIONS"

# --- Final Check ---
if [[ -z "$WIDTH" || -z "$HEIGHT" || -z "$X" || -z "$Y" ]]; then
    echo "Error: Failed to calculate all geometry values." >&2
    exit 1
fi

# --- Final Output ---
# This is the ONLY thing that prints to Standard Output.
# This is what the master script will capture in its variable.
echo "$X $Y $WIDTH $HEIGHT"

exit 0