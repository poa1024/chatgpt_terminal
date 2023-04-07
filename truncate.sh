#!/usr/bin/env zsh

filename=$1
N=$2

# Count the number of lines in the file
num_lines=$(wc -l <"$filename")

# If the file has more than N lines, cut it
if [ "$num_lines" -gt "$N" ]; then
  # Find the line number of the first empty line
  first_empty_line=$(awk '/^$/{print NR;exit;}' "$filename")

  # If there is no empty line, terminate the script
  if [ -z "$first_empty_line" ]; then
    echo "Error: file cannot be cut as there is no empty line." >&2
    exit 1
  fi

  # Loop to find an appropriate empty line to cut
  while true; do
    # Calculate the number of lines to keep
    num_lines_to_keep=$(($num_lines - $first_empty_line))

    # Check if cutting at this empty line will result in less than or equal to N lines
    if [ "$num_lines_to_keep" -le "$N" ]; then
      break
    else
      # Find the next empty line
      first_empty_line=$(awk -v start_line=$((first_empty_line + 1)) 'NR > start_line && /^$/{print NR;exit;}' "$filename")

      # If there is no more empty line, terminate the script
      if [ -z "$first_empty_line" ]; then
        echo "Error: file cannot be cut as there is no suitable empty line." >&2
        exit 1
      fi
    fi
  done

  # Cut the file and keep only the lines following the appropriate empty line
  tail -n "$num_lines_to_keep" "$filename" | sed '1,/^$/d' >"$filename.temp"
  mv "$filename.temp" "$filename"
fi
