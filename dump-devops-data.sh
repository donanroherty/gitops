#!/bin/bash

# Define an array of folder names
folders=(".argocd" "kubernetes" ".github/workflows")

# Function to process files recursively
process_files() {
    local folder="$1"
    local output_section="$2"

    echo "$output_section:" >> output.txt
    echo "---" >> output.txt

    # Recursively find all YAML files within the folder
    while IFS= read -r -d '' file; do
        echo "File: $file" >> output.txt
        echo "---" >> output.txt
        cat "$file" >> output.txt
        echo >> output.txt
    done < <(find "$folder" -type f -name '*.yaml' -print0)

    echo >> output.txt
}

# Process files for each folder
for folder in "${folders[@]}"; do
    case "$folder" in
        ".argocd")
            process_files "$folder" "ArgoCD YAML files"
            ;;
        "kubernetes")
            process_files "$folder" "Kubernetes YAML files"
            ;;
    esac

    case "$folder" in
        ".github/workflows")
            process_files "$folder" "Github workflow YAML files"
            ;;
    esac
done