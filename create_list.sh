#!/bin/bash

# Directories containing the audio samples
declare -a SOURCE_DIRS=("estonia" "finland" "germany" "japan" "turkey")

# Output file for the randomized list
OUTPUT_FILE="randomized_survey_list.txt"

echo "Generating a randomized list of all .wav audio samples for the survey..."
echo "Looking in directories: ${SOURCE_DIRS[*]}"

# Check if shuf command exists
if ! command -v shuf &> /dev/null; then
    echo "Error: 'shuf' command not found."
    exit 1
fi

# Use find to locate all .wav files within the specified directories (non-recursively)
# Pipe the list of files to 'shuf' to randomize the order
# Redirect the randomized list to the output file, overwriting if it exists
find "${SOURCE_DIRS[@]}" -maxdepth 1 -type f -name '*.wav' | shuf > "$OUTPUT_FILE"

