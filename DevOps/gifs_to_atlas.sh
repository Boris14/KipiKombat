#!/bin/bash

# Usage: ./create_atlas.sh output.png gif1.gif gif2.gif ...
# If no arguments are provided, it processes all .gif files in the current directory
# and outputs to "default_atlas.png".

DEFAULT_OUTPUT_FILENAME="default_atlas.png"
declare -a gifs_to_process # This will hold the list of GIFs

if [ "$#" -eq 0 ]; then
    # No arguments: process all GIFs in current directory
    echo "No arguments provided. Processing all .gif files in current directory."
    echo "Output will be: $DEFAULT_OUTPUT_FILENAME"
    output_file="$DEFAULT_OUTPUT_FILENAME"
    
    shopt -s nullglob # Ensures that if no *.gif files are found, the array is empty
    gifs_to_process=(*.gif)
    shopt -u nullglob # Reset shell option
    
    if [ ${#gifs_to_process[@]} -eq 0 ]; then
        echo "No .gif files found in the current directory."
        exit 1
    fi
elif [ "$#" -lt 2 ]; then
    # Original argument check
    echo "Usage: $0 output.png gif1.gif gif2.gif ..."
    exit 1
else
    # Arguments provided as per original script
    output_file="$1"
    shift  # Remove output filename from args
    gifs_to_process=("$@")
fi

# Create a temporary directory in the current directory instead
temp_dir="./temp_atlas" # Your original temp directory name
mkdir -p "$temp_dir"
trap 'rm -rf "$temp_dir"' EXIT # Your original trap

echo "Working directory: $temp_dir"

# First, extract all frames from each GIF into separate folders
for gif in "${gifs_to_process[@]}"; do # Modified to use the determined list of GIFs
    if [ ! -f "$gif" ]; then # Basic check to see if the gif file exists
        echo "Warning: Input GIF '$gif' not found. Skipping."
        continue
    fi
    gif_name=$(basename "$gif" .gif)
    mkdir -p "$temp_dir/$gif_name"
    
    # Split GIF into frames
    magick convert "$gif" -coalesce PNG32:"$temp_dir/$gif_name/frame_%d.png" # Your original command
    
    # Create a row for this GIF's frames using absolute paths
    frames_pattern="$temp_dir/$gif_name/frame_*.png"
    # Check if any frames were created before attempting to append
    # Use a subshell to count files matching the pattern to avoid issues with nullglob state here
    if compgen -G "$frames_pattern" > /dev/null; then
        magick convert "$temp_dir/$gif_name"/frame_*.png +append PNG32:"$temp_dir/${gif_name}_row.png" # Your original command
    else
        echo "Warning: No frames found for $gif_name after extraction. Skipping row creation."
    fi
done

# Get the dimensions of each row for vertical stacking
declare -a rows=()
total_height=0 # Your original variable

for gif in "${gifs_to_process[@]}"; do # Modified to use the determined list of GIFs
    if [ ! -f "$gif" ]; then # Skip if original gif was not found
        continue
    fi
    gif_name=$(basename "$gif" .gif)
    row_file_path="$temp_dir/${gif_name}_row.png"
    if [ -f "$row_file_path" ]; then # Check if the row file was actually created
        rows+=("$row_file_path")
    else
        echo "Warning: Row file '$row_file_path' not created or not found for $gif_name. It will not be included in the atlas."
    fi
done

if [ ${#rows[@]} -eq 0 ]; then
    echo "No valid rows were created. Atlas generation aborted."
    # The trap will clean up $temp_dir
    exit 1
fi

# Stack all rows vertically
magick convert "${rows[@]}" -append PNG32:"$output_file" # Your original command

echo "Atlas created successfully: $output_file"