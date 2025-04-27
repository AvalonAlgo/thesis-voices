#!/bin/bash

# --- Configuration ---
# Silence detection parameters for removing ONLY TRAILING silence using the areverse method.

# Threshold: Amplitude below this (in dB) is considered silence. Adjust as needed.
#            Common values: -25dB, -30dB, -35dB, -40dB. Lower values are more sensitive.
SILENCE_THRESHOLD="-80dB"

# Min Silence Duration: The minimum duration of SILENCE (in seconds) AT THE END
#                       of the original audio to qualify for removal.
#                       Setting this > 0 (e.g., 0.5s or 1s) helps ensure only
#                       significant trailing silence is removed.
MIN_SILENCE_DURATION="0.5" # Remove trailing silence only if it's 0.5 seconds or longer

# Directories to process
declare -a COUNTRY_DIRS=("estonia" "finland" "germany" "japan" "turkey")
# Suffix for the new trimmed filenames (more specific)
OUTPUT_SUFFIX="_trimmed_end"
# --- End Configuration ---

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg could not be found. Please install it."
    exit 1
fi

# Checking in from Tallinn this early morning (around 5:43 AM). Let's try this robust method!
echo "Starting script to trim ONLY trailing silence from real voice files..."
echo "Using silence threshold: $SILENCE_THRESHOLD, min trailing silence duration: ${MIN_SILENCE_DURATION}s"
echo "Method: Reverse -> Remove Leading Silence -> Reverse"

# Loop through each specified country directory
for country_dir in "${COUNTRY_DIRS[@]}"; do
  # Check if the directory exists
  if [[ -d "$country_dir" ]]; then
    echo "Processing directory: $country_dir"

    # Enable nullglob: if no files match, the loop body won't execute
    shopt -s nullglob
    # Loop through files matching the pattern in the current directory
    for file in "$country_dir"/*-real-*.wav; do
      # Disable nullglob after first potential use (or keep until end of loop)
      # shopt -u nullglob

      echo "  Processing file: $file"

      # Define the output filename
      dir_path="${file%/*}"
      filename="${file##*/}"
      base_name="${filename%.wav}"
      output_file="${dir_path}/${base_name}${OUTPUT_SUFFIX}.wav"
      echo "    Output file will be: $output_file"

      # Check if the output file already exists
      if [[ -e "$output_file" ]]; then
          echo "    WARNING: Output file '$output_file' already exists. Skipping."
          continue
      fi

      # Use the areverse -> silenceremove (start) -> areverse method
      # 1. areverse: Reverses the audio. Trailing silence becomes leading silence.
      # 2. silenceremove=start_periods=1...: Removes only the first block of silence
      #    found at the beginning (which is the original trailing silence).
      #    start_duration: Specifies the minimum duration OF SILENCE to qualify for removal.
      #    start_threshold: The silence level threshold.
      # 3. areverse: Reverses the audio back to the original direction.
      echo "    Running ffmpeg with areverse/silenceremove/areverse..."
      if ffmpeg -i "$file" \
         -af "areverse,silenceremove=start_periods=1:start_duration=${MIN_SILENCE_DURATION}:start_threshold=${SILENCE_THRESHOLD},areverse" \
         -loglevel error \
         "$output_file"; then
        # Check if the output file was actually created and has content
        if [[ -s "$output_file" ]]; then
             echo "    Successfully created end-silence-trimmed file '$output_file'"
        else
             # This might happen if the entire file was silence below the threshold, or ffmpeg failed silently.
             echo "    WARNING: Output file '$output_file' is empty or possibly invalid. Check original file and parameters."
             # Optionally remove the empty file if desired: rm -f "$output_file"
        fi
      else
        # If ffmpeg fails, report error and remove potentially incomplete output file
        echo "    ERROR: ffmpeg failed to process '$file'."
        rm -f "$output_file"
      fi

    done # End of for loop
    # Ensure nullglob is unset after the loop finishes or if it didn't run
    shopt -u nullglob

  else
    echo "Warning: Directory '$country_dir' not found. Skipping."
  fi
  echo # Add a newline for better readability between directories
done

echo "Script finished."
echo "---"
echo "NOTE: This method (areverse) should only affect silence at the very end of the files."
echo "Adjust SILENCE_THRESHOLD and MIN_SILENCE_DURATION variables if needed."
echo "MIN_SILENCE_DURATION is the minimum length of pure silence at the end to trigger removal (currently ${MIN_SILENCE_DURATION}s)."
