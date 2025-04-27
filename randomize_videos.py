#!/usr/bin/env python3
import os
import random
import sys

# --- Configuration ---
base_dir = '.'  # Use '.' for the current directory
output_file = 'randomized_survey_list.txt'
# --- End Configuration ---

# Get potential country directories (items in the base directory that are directories)
try:
    all_items = os.listdir(base_dir)
    country_dirs = [d for d in all_items if os.path.isdir(os.path.join(base_dir, d))]
except FileNotFoundError:
    print(f"Error: Base directory '{base_dir}' not found.")
    sys.exit(1)
except Exception as e:
    print(f"Error listing directories: {e}")
    sys.exit(1)


if not country_dirs:
    print("Error: No country subdirectories found in the base directory.")
    sys.exit(1)

print(f"Found country directories: {', '.join(country_dirs)}")

# Dictionary to hold lists of mp4 files for each country
files_by_country = {}
total_files = 0

# Populate the dictionary with mp4 files
for country in country_dirs:
    country_path = os.path.join(base_dir, country)
    try:
        files_in_country = [
            os.path.join(country, f) # Store relative path from base_dir
            for f in os.listdir(country_path)
            if os.path.isfile(os.path.join(country_path, f)) and f.lower().endswith('.mp4')
        ]
        if files_in_country:
            files_by_country[country] = files_in_country
            total_files += len(files_in_country)
            print(f" - Found {len(files_in_country)} mp4 files in '{country}'")
        else:
             print(f" - Found 0 mp4 files in '{country}'")
    except Exception as e:
        print(f"Error processing directory '{country}': {e}")
        # Optionally continue or exit: continue

if not files_by_country or total_files == 0:
    print("\nError: No MP4 files found in any country subdirectories.")
    sys.exit(1)

print(f"\nTotal MP4 files found: {total_files}")

# --- Randomization Logic ---
randomized_list = []
last_country = None

while len(randomized_list) < total_files:
    # Countries that still have files left
    available_countries = [c for c, files in files_by_country.items() if files]

    if not available_countries:
        # Should not happen if total_files > 0 and loop condition is correct
        print("Error: No more available countries but not all files processed.")
        break

    # Filter out the last country if possible
    eligible_countries = [c for c in available_countries if c != last_country]

    # If filtering leaves no options (only the last country remains), allow it
    if not eligible_countries:
        eligible_countries = available_countries

    # Choose a country randomly from the eligible ones
    current_country = random.choice(eligible_countries)

    # Choose a file randomly from the selected country's list
    selected_file = random.choice(files_by_country[current_country])

    # Add the selected file to the final list
    randomized_list.append(selected_file)

    # Remove the selected file from its country's list
    files_by_country[current_country].remove(selected_file)

    # Update the last country
    last_country = current_country

# --- Write Output File ---
try:
    with open(output_file, 'w') as f:
        for file_path in randomized_list:
            f.write(f"{file_path}\n")
    print(f"\nSuccessfully created randomized list in '{output_file}'")
    print(f"Total files in list: {len(randomized_list)}")
except IOError as e:
    print(f"\nError writing to output file '{output_file}': {e}")
    sys.exit(1)

# Optional: Print the first few items to verify
print("\nFirst 5 items in the list:")
for item in randomized_list[:5]:
    print(item)
