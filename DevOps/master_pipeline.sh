#!/bin/bash

# Master script to coordinate the full GIF-to-sprite-atlas pipeline.
# This script will:
# 1. Run overlay_frames.sh to create a composite image.
# 2. Run get_bounding_box.sh on the composite to find the crop rectangle.
# 3. Run trim_gifs.sh with the calculated rectangle to trim all source GIFs.
# 4. Run gifs_to_atlas.sh on the trimmed GIFs to create the final sprite atlas.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
OVERLAY_FILE="all_gifs_overlayed.png"
TRIMMED_DIR="trimmed"
FINAL_ATLAS_NAME="final_atlas.png"

# --- Helper Script Verification ---
# Array of required script names
required_scripts=("overlay_frames.sh" "get_bounding_box.sh" "trim_gifs.sh" "gifs_to_atlas.sh")

echo "Verifying that all required helper scripts are present..."
for script in "${required_scripts[@]}"; do
    if [ ! -f "$script" ]; then
        echo "Error: Required script '$script' not found in the current directory."
        exit 1
    fi
    if [ ! -x "$script" ]; then
        echo "Error: Required script '$script' is not executable. Please run 'chmod +x $script'."
        exit 1
    fi
done
echo "All helper scripts found."
echo "---"


# --- STEP 1: Overlay all frames from all GIFs ---
echo "STEP 1: Creating composite overlay image from all GIFs..."
./overlay_frames.sh

if [ ! -f "$OVERLAY_FILE" ]; then
    echo "Error: overlay_frames.sh did not create the expected file '$OVERLAY_FILE'."
    exit 1
fi
echo "Successfully created '$OVERLAY_FILE'."
echo "---"


# --- STEP 2: Automatically determine the crop rectangle ---
echo "STEP 2: Calculating the precise crop rectangle from '$OVERLAY_FILE'..."
CROP_VALUES=$(./get_bounding_box.sh "$OVERLAY_FILE")

# Validate the output from the script
if [ -z "$CROP_VALUES" ] || [ "$(echo "$CROP_VALUES" | wc -w)" -ne 4 ]; then
    echo "Error: get_bounding_box.sh failed to return valid crop values."
    exit 1
fi
echo "Crop rectangle determined: $CROP_VALUES (X Y Width Height)"
echo "---"


# --- STEP 3: Trim all original GIFs using the crop rectangle ---
echo "STEP 3: Trimming all source GIFs and saving to './$TRIMMED_DIR/' directory..."
# The CROP_VALUES variable will be split by spaces into arguments for the script
./trim_gifs.sh $CROP_VALUES
echo "Trimming complete."
echo "---"


# --- STEP 4: Generate the final sprite atlas from the trimmed GIFs ---
echo "STEP 4: Generating sprite atlas from the trimmed GIFs..."
# Navigate into the trimmed directory to run the atlas creator
if [ ! -d "$TRIMMED_DIR" ]; then
    echo "Error: The '$TRIMMED_DIR' directory was not created by trim_gifs.sh."
    exit 1
fi

# Use a subshell to change directory, which is safer and cleaner
# than cd-ing and then cd-ing back.
(
  cd "$TRIMMED_DIR"
  echo "Entered './$TRIMMED_DIR/' directory."
  # The gifs_to_atlas script uses a default output name, which we will rename
  ../gifs_to_atlas.sh
  # The default output is "default_atlas.png", let's rename it to our configured name
  if [ -f "default_atlas.png" ]; then
    mv "default_atlas.png" "$FINAL_ATLAS_NAME"
    echo "Final atlas created: ./$TRIMMED_DIR/$FINAL_ATLAS_NAME"
  else
    echo "Error: gifs_to_atlas.sh did not produce the expected 'default_atlas.png'."
    # Since we are in a subshell, exit will only terminate the subshell
    exit 1
  fi
)

# Check the exit code of the subshell
if [ $? -ne 0 ]; then
    echo "Error occurred during atlas generation."
    exit 1
fi

echo "---"
echo "PIPELINE COMPLETED SUCCESSFULLY!"
echo "Your final sprite atlas is located at: $TRIMMED_DIR/$FINAL_ATLAS_NAME"

exit 0