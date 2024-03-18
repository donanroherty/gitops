import os
from pathlib import Path
from fnmatch import fnmatch

def should_exclude(path, exclude_patterns):
    """Check if a file or directory should be excluded based on exclude patterns."""
    str_path = str(path)
    for pattern in exclude_patterns:
        if fnmatch(str_path, pattern) or any(fnmatch(part, pattern) for part in path.parts):
            return True
    return False

def process_files(folder, output_section, exclude_patterns):
    """Process files recursively and write their contents to the output file."""
    with open("output.txt", "a", encoding="utf-8") as output_file:
        output_file.write(f"{output_section}:\n")
        output_file.write("---\n")

        for root, dirs, files in os.walk(folder):
            # Exclude directories based on exclude patterns
            dirs[:] = [d for d in dirs if not should_exclude(Path(root) / d, exclude_patterns)]

            for file in files:
                file_path = Path(root) / file
                if not should_exclude(file_path, exclude_patterns):
                    output_file.write(f"File: {file_path}\n")
                    output_file.write("---\n")

                    with open(file_path, "r", encoding="utf-8", errors="replace") as f:
                        try:
                            content = f.read().split("\n")[:10]
                            output_file.write("\n".join(content) + "\n")
                        except UnicodeDecodeError:
                            output_file.write("(Skipped due to decoding error)\n")

                    output_file.write("\n")

        output_file.write("\n")

def main():
    # Exclude patterns (similar to .gitignore)
    exclude_patterns = [
        ".git",
        ".git/**",
        # ".env",
        "node_modules",
        "node_modules/**",
        "output.txt",
        "*.log",
        "tmp",
        "tmp/**",
        "terraform/.terraform",
        "terraform/.terraform/**",
        "terraform/.terraform.lock.hcl",
        "terraform/terraform.tfstate",
        "terraform/terraform.tfstate.backup",
        "scripts/dump-file-content.py",
    ]

    # Process files for the root folder and its subfolders
    root_folder = "."
    process_files(root_folder, "All files", exclude_patterns)

if __name__ == "__main__":
    main()