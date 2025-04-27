#!/bin/bash

INPUT_DIR="./"
OUTPUT_DIR="./"
IMAGE_FILE="./black.jpg"

# Loop through subdirectories
for country_dir in "$INPUT_DIR"/*/; do
    if [ -d "$country_dir" ]; then
        # Loop through WAV files in each subdirectory
        for audio_file in "$country_dir"*.opus; do
            if [ -f "$audio_file" ]; then
                # Extract the filename without extension
                filename=$(basename "$audio_file")
                filename_without_ext="${filename%.*}"
                country_name=$(basename "$country_dir")

                # Construct the output filename, keeping files within their country subdirectories
                output_file="${country_dir}${filename_without_ext}.mp4"

                # Run FFmpeg command - using AAC for audio at 320kbps
                ffmpeg -loop 1 -i "$IMAGE_FILE" -i "$audio_file" -c:v libx264 -c:a copy -shortest "$output_file"
            fi
        done
    fi
done