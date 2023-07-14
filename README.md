## Utils

A collection of useful utility functions (mostly written by ChatGPT <3).

### Instructions

Clone the repo somewhere and then add its bin folder to your path.

E.g. in `.bashrc`:

```
export PATH="$PATH:<repo_path>/bin"
```

### Utils

#### diff_json

Dependencies: jq, delta, termshot

```
# This function compares two JSON files and optionally takes a screenshot of the diff.
#
# It sorts the keys of the JSON objects recursively, then uses `delta` to compare the sorted files.
# By default, `delta` uses a width of 200 and a max line wrap of 0.
# You can pass additional `delta` command line options to override these defaults.
# If you pass the `-s` flag, the function takes a screenshot of the diff with `termshot`.
#
# Dependencies: jq, delta, termshot
#
# Usage:
#   diff_json <file1> <file2> [delta options] [-s]
#
# Arguments:
#   <file1> and <file2> - The paths of the JSON files to compare.
#   [delta options] - Optional. Any command line options to pass to `delta`.
#     These options must be in the format `--option=value`.
#   -s - Optional. If present, the function takes a screenshot of the diff.

Usage:
  diff_json <file1> <file2> [delta options] [-s]

Arguments:
  <file1> and <file2> - The paths of the JSON files to compare.
  [delta options] - Optional. Any command line options to pass to `delta`.
    These options must be in the format `--option=value`.
  -s - Optional. If present, the function takes a screenshot of the diff.
```

#### rg_git

Dependencies: ripgrep (rg), git

```
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
```
