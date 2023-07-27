#!/bin/bash

# Function to convert images to WebP
convert_to_webp() {
  local input_file="$1"
  local output_file="${input_file%.*}.webp"

  cwebp -q 5 -alpha_q 0 -pass 10 -mt -m 6 -sharpness 7 -f 100 -partition_limit 20 -strong -sharp_yuv -sns 100 -partition_limit 100 $input_file -o $output_file
  if [ $? -ne 0 ]; then
    echo "Failed to convert: $input_file"
  fi
}

# Function to process files and directories recursively
process_directory() {
  local directory="$1"

  # Loop through all files and directories in the specified directory
  for entry in "$directory"/*; do
    if [ -d "$entry" ]; then
      # If the entry is a directory, recursively process it
      process_directory "$entry"
    elif [ -f "$entry" ]; then
      # If the entry is a file, check if it's an image before converting it
      mimetype=$(file -b --mime-type "$entry")

      if [[ $mimetype != image/webp ]]; then
        if [[ $mimetype == image/* ]]; then
            echo "Converting: $entry"
            convert_to_webp "$entry"
        fi
      fi
    fi
  done
}

# Check if the script is called with a directory argument
if [ $# -eq 0 ]; then
  echo "Please provide a directory as an argument."
  exit 1
fi

# Get the absolute path of the specified directory
input_directory="$(realpath "$1")"

# Check if the input directory exists
if [ ! -d "$input_directory" ]; then
  echo "The specified directory does not exist."
  exit 1
fi

# Process the directory and its subdirectories
process_directory "$input_directory"

echo "Conversion complete!"
