#!/bin/bash

# Script to trim all GIFs in the current directory and save them
# to a 'trimmed' subdirectory with their original names.
#
# Usage:
#   ./trim_gifs.sh <X> <Y> <Width> <Height>  (to use custom parameters)
#   ./trim_gifs.sh                          (to use default parameters)
#
# Default Parameters:
#   X: 115
#   Y: 536
#   Width: 779
#   Height: 917

# --- Configuration ---
OUTPUT_SUBDIR="trimmed" # Name of the subdirectory for trimmed GIFs

# Default trim parameters
DEFAULT_X=115
DEFAULT_Y=536
DEFAULT_WIDTH=779
DEFAULT_HEIGHT=917

# --- Argument Handling & Default Values ---
if [ "$#" -eq 0 ]; then
  echo "No arguments provided. Using default trim parameters:"
  X="$DEFAULT_X"
  Y="$DEFAULT_Y"
  WIDTH="$DEFAULT_WIDTH"
  HEIGHT="$DEFAULT_HEIGHT"
elif [ "$#" -eq 4 ]; then
  echo "Using provided trim parameters:"
  X="$1"
  Y="$2"
  WIDTH="$3"
  HEIGHT="$4"
else
  echo "Error: Incorrect number of arguments."
  echo "Usage: $0 [X Y Width Height]"
  echo "  If no arguments are provided, default values will be used:"
  echo "    Default X: $DEFAULT_X, Y: $DEFAULT_Y, Width: $DEFAULT_WIDTH, Height: $DEFAULT_HEIGHT"
  echo "  Example (custom): $0 10 20 300 200"
  echo "  Example (default): $0"
  exit 1
fi

echo "  X: $X, Y: $Y, Width: $WIDTH, Height: $HEIGHT"

# --- Argument Validation (check if numbers) ---
# We use an array of variable names to iterate and validate
param_names=("X" "Y" "WIDTH" "HEIGHT")
for name in "${param_names[@]}"; do
  # Indirect variable expansion to get the value of X, Y, WIDTH, HEIGHT
  value="${!name}"
  if ! [[ "$value" =~ ^[0-9]+$ ]]; then
    echo "Error: Parameter '$name' (value: '$value') must be a non-negative integer."
    exit 1
  fi
done

# --- ImageMagick Check ---
if ! command -v magick &> /dev/null; then
  echo "Error: ImageMagick 'magick' command not found."
  echo "Please ensure ImageMagick is installed and 'magick' is in your PATH."
  echo "On some older systems, you might need to use 'convert' instead of 'magick'."
  echo "If so, modify line containing 'magick \"\$gif_file\" ...' in this script."
  exit 1
fi

# --- Prepare Output Directory ---
if [ ! -d "$OUTPUT_SUBDIR" ]; then
  echo "Creating output directory: $OUTPUT_SUBDIR"
  mkdir -p "$OUTPUT_SUBDIR"
  if [ $? -ne 0 ]; then
    echo "Error: Could not create output directory '$OUTPUT_SUBDIR'."
    exit 1
  fi
else
  echo "Output directory: $OUTPUT_SUBDIR (already exists)"
fi

# --- Processing ---
CROP_GEOMETRY="${WIDTH}x${HEIGHT}+${X}+${Y}"
echo "Trimming GIFs with geometry: ${CROP_GEOMETRY}"
echo "Output will be saved in './${OUTPUT_SUBDIR}/' with original filenames."
echo "---"

# Use nullglob to prevent errors if no GIFs are found
shopt -s nullglob
gif_files=(*.gif) # Get GIFs from the current directory

if [ ${#gif_files[@]} -eq 0 ]; then
  echo "No GIF files (*.gif) found in the current directory."
  exit 0
fi

processed_count=0
error_count=0
skipped_count=0

for gif_file in "${gif_files[@]}"; do
  # Define the output path for the trimmed file
  output_file="${OUTPUT_SUBDIR}/${gif_file}"

  # Optional: Skip if the output file already exists and is newer than the source.
  # This is a more sophisticated skip than just existence.
  # If you want to always re-process, comment out this 'if' block.
  # if [ -f "$output_file" ] && [ "$output_file" -nt "$gif_file" ]; then
  #   echo "Skipping: $gif_file (newer version already exists in $OUTPUT_SUBDIR)"
  #   ((skipped_count++))
  #   continue
  # fi
  #
  # Simpler skip: just check if it exists. If you want to overwrite, remove this.
  # If you want to always process and potentially overwrite files in 'trimmed' folder,
  # you can remove this 'if' block. For safety, it's good to at least warn.
  # The current behavior is: if image.gif is processed, trimmed/image.gif is created.
  # If script runs again, it will re-process image.gif and overwrite trimmed/image.gif.
  # The skip below is for a *different* scenario: if you manually put a file
  # named `image.gif` into `trimmed/` which is NOT from `image.gif` in current dir.
  #
  # For the requested behavior ("copy all trimmed GIFs there with their names intact"),
  # we will generally *overwrite* if the script is run multiple times on the same source files.
  # The check below is more about not processing files that are *already in* the output dir
  # if they happen to share a name with a source file (less likely scenario).
  #
  # The primary intent is to process source GIFs and put their trimmed versions into 'trimmed'.
  # If 'trimmed/some.gif' exists from a previous run of this script on './some.gif',
  # running it again will re-trim './some.gif' and replace 'trimmed/some.gif'.

  echo "Processing: $gif_file  ->  $output_file"

  # The core ImageMagick command
  # -crop WxH+X+Y : Defines the crop area
  # +repage       : Crucial for animations. Resets the virtual canvas
  #                 to the new dimensions after cropping.
  magick "$gif_file" -crop "$CROP_GEOMETRY" +repage "$output_file"

  if [ $? -eq 0 ]; then
    echo "Successfully trimmed: $gif_file and saved to $output_file"
    ((processed_count++))
  else
    echo "Error trimming: $gif_file"
    ((error_count++))
  fi
  echo "---"
done

shopt -u nullglob # Reset nullglob

echo "Processing complete."
echo "Successfully processed: $processed_count file(s)."
# if [ $skipped_count -gt 0 ]; then
#   echo "Skipped (already up-to-date): $skipped_count file(s)."
# fi
if [ $error_count -gt 0 ]; then
  echo "Encountered errors with: $error_count file(s)."
fi

if [ $processed_count -eq 0 ] && [ $error_count -eq 0 ] && [ ${#gif_files[@]} -gt 0 ]; then
    echo "No new files were processed (or all source GIFs were processed into the '${OUTPUT_SUBDIR}' directory)."
fi

exit $error_count