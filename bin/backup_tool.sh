#!/bin/bash

archive() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 archive <path_to_directory> <path_to_output_tar>"
        exit 1
    fi

    local folder="$1"
    local output="$2"
    local temp_dir=$(mktemp -d)

    for repo in "$folder"/*; do
        if [ -d "$repo/.git" ]; then
            if git -C "$repo" rev-parse HEAD >/dev/null 2>&1; then
                git -C "$repo" archive --format=tar -o "$temp_dir/$(basename "$repo").tar" HEAD
            else
                echo "Repository $(basename "$repo") has no commits, skipping..."
            fi
        fi
    done

    cd "$temp_dir" && tar -cf "$output" *
    rm -rf "$temp_dir"
}

restore() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 restore <path_to_input_tar> <path_to_restore_directory>"
        exit 1
    fi

    local main_tar="$1"
    local restoration_dir="$2"

    if [ ! -f "$main_tar" ]; then
        echo "Error: The tarball $main_tar does not exist."
        exit 1
    fi

    mkdir -p "$restoration_dir"
    tar -xf "$main_tar" -C "$restoration_dir"

    cd "$restoration_dir"
    for repo_tar in *.tar; do
        local repo_dir="${repo_tar%.tar}"
        mkdir -p "$repo_dir"
        tar -xf "$repo_tar" -C "$repo_dir"
        rm "$repo_tar"
    done
}

if [ "$#" -lt 3 ]; then
    echo "Usage:"
    echo "  $0 archive <path_to_directory> <path_to_output_tar>"
    echo "  $0 restore <path_to_input_tar> <path_to_restore_directory>"
    exit 1
fi

case $1 in
    archive)
        shift
        archive "$@"
        ;;
    restore)
        shift
        restore "$@"
        ;;
    *)
        echo "Invalid command. Please use 'archive' or 'restore'."
        exit 1
        ;;
esac
