#!/bin/bash

# Function to process files recursively
process_files() {
    local folder="$1"
    local output_section="$2"
    local exclude_patterns="$3"
    
    echo "$output_section:" >> output.txt
    echo "---" >> output.txt
    
    # Recursively find all files within the folder, excluding specified patterns
    while IFS= read -r -d '' file; do
        file_path="${file#./}"
        echo "File: $file_path" >> output.txt
        echo "---" >> output.txt
        cat "$file" | head -n 10 >> output.txt
        echo >> output.txt
    done < <(find "$folder" -maxdepth 10 -type f -print0 | grep -zZvFf <(printf "%s\n" "${exclude_patterns[@]}"))
    
    echo >> output.txt
}

# Exclude patterns
exclude_patterns=(
    ".git"
    # ".env"
    "node_modules"
    "output.txt"
    "*.log"
    "tmp"
)

# Process files for the root folder and its subfolders
root_folder="."
process_files "$root_folder" "All files" "${exclude_patterns[@]}"