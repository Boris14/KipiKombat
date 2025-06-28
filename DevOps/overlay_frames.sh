#!/bin/bash

# Script to overlay ALL frames from ALL GIF files in the current directory
# into ONE single output image.

# Check if ImageMagick is installed (either 'convert' or 'magick' command)
if ! command -v convert &> /dev/null && ! command -v magick &> /dev/null; then
    echo "ImageMagick (convert or magick command) not found."
    echo "Please install ImageMagick and ensure it's in your PATH."
    exit 1
fi

# Determine if to use 'magick convert' or just 'convert'
IM_CONVERT_CMD="convert"
if command -v magick &> /dev/null; then
    IM_CONVERT_CMD="magick convert"
fi

echo "Using ImageMagick command: $IM_CONVERT_CMD"
echo ""

# --- Configuration ---
OUTPUT_FILENAME="all_gifs_overlayed.png"
# --- End Configuration ---

# Array to hold the input arguments for ImageMagick
# Each GIF will be processed as: ( gif_file -coalesce )
gif_processing_args=()
gif_files_found=0

echo "Scanning for GIF files (*.[gG][iI][fF])..."

# Loop through all .gif files (case-insensitive for the extension)
for gif_file in *.[gG][iI][fF]; do
    # Check if the glob pattern actually matched a file.
    if [ ! -f "$gif_file" ]; then
        continue # Skip if not a regular file (e.g., if no GIFs are found, glob returns itself)
    fi

    echo "Adding '$gif_file' to the processing list."
    # Add the necessary ImageMagick processing for this specific GIF
    # Parentheses are used to group operations for this input file
    gif_processing_args+=("(" "$gif_file" "-coalesce" ")")
    gif_files_found=$((gif_files_found + 1))
done

if [ "$gif_files_found" -eq 0 ]; then
    echo "No GIF files found in the current directory (looking for *.[gG][iI][fF])."
    exit 0
fi

echo ""
echo "Found $gif_files_found GIF file(s)."
echo "Preparing to merge all frames into '$OUTPUT_FILENAME'..."

# Construct the full ImageMagick command
# The structure will be:
# $IM_CONVERT_CMD ( gif1.gif -coalesce ) ( gif2.gif -coalesce ) ... -layers flatten output.png
full_command_args=()
full_command_args+=($IM_CONVERT_CMD) # Add the base command
full_command_args+=("${gif_processing_args[@]}") # Add all the ( gif -coalesce ) parts
full_command_args+=("-layers" "flatten" "$OUTPUT_FILENAME") # Add the final flatten operation and output

echo "Executing ImageMagick command:"
# For debugging, print the command (properly quoted for clarity)
# This is a bit tricky to do perfectly for copy-paste, but gives an idea
printf "  %s" "${full_command_args[0]}"
for (( i=1; i<${#full_command_args[@]}; i++ )); do
    # Crude way to quote for display
    if [[ "${full_command_args[$i]}" == "(" || "${full_command_args[$i]}" == ")" ]]; then
        printf " %s" "${full_command_args[$i]}"
    else
        printf " '%s'" "${full_command_args[$i]}"
    fi
done
echo "" # Newline after printing command

# Execute the command
if "${full_command_args[@]}"; then
    echo ""
    echo "Successfully created '$OUTPUT_FILENAME' with all frames from $gif_files_found GIF(s) overlayed."
else
    echo ""
    echo "ERROR: ImageMagick failed to process the GIFs."
    echo "Please check the output above for any error messages from ImageMagick."
    exit 1
fi

exit 0