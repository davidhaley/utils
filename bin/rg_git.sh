#!/bin/bash

# From the current directory, recursively search .git directories
# using ripgrep. Additionally, shows the git commits since the
# <date> for each repository with at least one match.
#
# Dependencies: ripgrep (rg), git
#
# Usage: rg_git <pattern> <rg options> YYYY-MM-DD
# NOTE: use single quotes around each argument - see below for an example
#
# Example:
#   rggit 'organizations/find' '!.map' '2023-04-01'
#     - Recursively searches for 'organizations/find' in all files except .map files.
#     - Displays the matched lines from each repository.
#     - Shows git commits since 2023-04-01 for each matched repository.
#
# Arguments:
#   - <pattern>: The pattern to search for using ripgrep.
#   - <rg options>: Additional options to pass to ripgrep.
#   - <date>: The date in YYYY-MM-DD format. Only git commits since this date will be shown.
#
# Notes:
#   - Requires ripgrep (rg) and git to be installed and accessible in the system.
#   - The output includes colored formatting for improved readability.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Last argument is the date
date="${@: -1}"

# All other arguments are passed to ripgrep
ripgrep_args=("${@:1:$#-2}")

# Perform the ripgrep and store the result in an array
IFS=$'\n' read -rd '' -a rg_results <<< "$(rg "${ripgrep_args[@]}" --with-filename --vimgrep .)"

# Create an associative array to store the results by repository
declare -A repo_results

# Loop over each match
for match in "${rg_results[@]}"; do
# Extract the repository name and file path from the result
file="${match%%:*}"
dir="${file%/*}"
repo=$(git -C "$dir" rev-parse --show-toplevel)
file="${file#$repo/}"

# Add the match to the repository's results array
repo_results["$repo"]+="$file ($match)"$'\n'
done

# Loop over the repositories and print the results
for repo in "${!repo_results[@]}"; do
# Print the repository name
printf "\n${YELLOW}${repo}:${NC}\n"

# Loop over the matches for the repository
while IFS= read -r match; do
    # Print each match
    echo "$match"
done <<< "${repo_results["$repo"]}"

echo

# Check if the repository is a git repository
if [ -d "$repo/.git" ]; then
    # Retrieve all commits since the given date
    # commits=$(git -C "$repo" log --since="$date" --pretty=format:'%C(dim green)(%ad - %cr) %C(magenta)%h%Creset -%C(red)%d%Creset %s %C(cyan)<%an>%Creset' --abbrev-commit --date=short --color=always)

    commits=$(git -C "$repo" log --since="$date" \
        --pretty=format:'%C(dim green)%ad (%cr ago) %C(magenta)%h%Creset -%C(red)%d%Creset %s %C(cyan)<%an>%Creset' \
        --abbrev-commit --date=format:'%Y-%m-%d' --color=always \
        | sed -E 's/([0-9]+) weeks? ago/\1w/g' \
        | sed -E 's/([0-9]+) months? ago/\1m/g' \
        | sed -E 's/([0-9]+) years? ago/\1y/g' \
        | sed -E 's/([0-9]+) days? ago/\1d/g' \
        | sed -E 's/([0-9]+) hours? ago/\1h/g' \
        | sed -E 's/([0-9]+) minutes? ago/\1m/g' \
        | awk '{print}'
    )

    if [ -n "$commits" ]; then
    echo "$commits"
    else
    printf "\n${RED}No commits since ${date}${NC}\n"
    fi
else
    printf "\n${RED}Not a git repository${NC}\n"
fi

echo
done
