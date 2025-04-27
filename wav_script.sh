#!/bin/bash

INPUT_DIR="./"

# Loop through subdirectories
for country_dir in "$INPUT_DIR"/*/; do
  if [ -d "$country_dir" ]; then
    for audio_file in "$country_dir"*.ogg; do
      if [ -f "$audio_file" ]; then
        # Extract the filename without extension
        filename=$(basename "$audio_file")
        filename_without_ext="${filename%.*}"
        country_name=$(basename "$country_dir")

        output_file_wav="${country_dir}${filename_without_ext}.wav"
        
        # Run FFmpeg command to convert to WAV
        echo "Converting $filename to ${filename_without_ext}.wav in $country_name..."
        ffmpeg -i "$audio_file" -vn -acodec pcm_s16le "$output_file_wav"
        if [ $? -eq 0 ]; then
          echo "Conversion of $filename to WAV in $country_name successful."
        else
          echo "Conversion of $filename to WAV in $country_name failed."
        fi

      fi
    done
  fi
done
