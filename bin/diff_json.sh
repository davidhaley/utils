#!/bin/bash

# This function compares two JSON files and optionally takes a screenshot of the diff.
#
# It sorts the keys of the JSON objects recursively, then uses `delta` to compare the sorted files.
# By default, `delta` uses a width of 200 and a max line wrap of 0.
# You can pass additional `delta` command line options to override these defaults.
# If you pass the `-s` flag, the function takes a screenshot of the diff with `termshot`.
#
# Usage:
#   diff_json <file1> <file2> [delta options] [-s]
#
# Arguments:
#   <file1> and <file2> - The paths of the JSON files to compare.
#   [delta options] - Optional. Any command line options to pass to `delta`.
#     These options must be in the format `--option=value`.
#   -s - Optional. If present, the function takes a screenshot of the diff.

# Check if two arguments are passed
if [ $# -lt 2 ]; then
  echo "Usage: sort_and_diff_json <file1> <file2> [delta options] [-s]"
  return 1
fi

# Check if jq, delta and termshot are installed
if ! command -v jq &> /dev/null; then
  echo "jq could not be found. Please install it."
  return 1
fi

if ! command -v delta &> /dev/null; then
  echo "delta could not be found. Please install it."
  return 1
fi

if ! command -v termshot &> /dev/null; then
  echo "termshot could not be found. Please install it."
  return 1
fi

# Temporary files to store the sorted JSON
temp1=$(mktemp)
temp2=$(mktemp)

# Sort the JSON files
jq 'walk(if type == "object" then to_entries | sort_by(.key) | from_entries else . end)' "$1" > "$temp1"
jq 'walk(if type == "object" then to_entries | sort_by(.key) | from_entries else . end)' "$2" > "$temp2"

# Set default delta options in an associative array
declare -A delta_opts=(["--width"]=200 ["--wrap-max-lines"]=0)

# Screenshot flag
screenshot=0

# Read the command line options
for ((i=3; i<=$#; i++)); do
  arg=${!i}
  if [[ $arg == --*=* ]]; then
    opt=${arg%%=*}
    val=${arg#*=}
    delta_opts[$opt]=$val
  elif [[ $arg == "-s" ]]; then
    screenshot=1
  else
    echo "Unrecognized option format: $arg"
    return 1
  fi
done

# Build the delta command
delta_cmd="delta"
for opt in "${!delta_opts[@]}"; do
  delta_cmd+=" $opt=${delta_opts[$opt]}"
done

# Run the diff and potentially take a screenshot
if (( $screenshot )); then
  screenshot_temp=$(mktemp)
  eval "$delta_cmd" "$temp1" "$temp2" > "$screenshot_temp"
  termshot -- cat "$screenshot_temp"
  rm "$screenshot_temp"
else
  eval "$delta_cmd" "$temp1" "$temp2"
fi

# Clean up the temp files
rm "$temp1"
rm "$temp2"
