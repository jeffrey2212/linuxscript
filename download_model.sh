#!/bin/bash

# Check for required tools
if ! command -v curl &> /dev/null; then
    echo "curl is required but not installed. Please install it."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "jq is required but not installed. Please install it."
    exit 1
fi

# Set the base path (change this to your desired location)
base_path="/path/to/download/directory" 

# Read JSON input (you can provide this as a file or inline)
# Input JSON file (change this to the path of your JSON file)
json_file="/path/to/your/data.json"

# Check if the JSON file exists
if [ ! -f "$json_file" ]; then
    echo "JSON file not found: $json_file"
    exit 1
fi

# Process models from the JSON file
jq -c '.models[]' "$json_file" | while read -r model; do
    # ... (rest of the model processing is the same)
done

# Function to process a single model download
download_model() {
    url="$1"
    filename="$2"
    save_path="$3"

    target_file="${base_path}/${save_path}/${filename}"

    # Skip download if the file already exists
    if [ -f "$target_file" ]; then
        echo "Skipping download: $filename (file exists)"
    else
        mkdir -p "${base_path}/${save_path}"  # Create directories if needed
        echo "Downloading: $filename"
        curl -s -o "$target_file" "$url"  # Download, silent output unless there's an error
    fi
}

# Process models from the JSON
echo "$json_data" | jq -c '.models[]' | while read -r model; do
    url=$(echo "$model" | jq -r '.url')
    filename=$(echo "$model" | jq -r '.filename')
    save_path=$(echo "$model" | jq -r '.save_path')

    download_model "$url" "$filename" "$save_path"
done

echo "Download Summary:"
find "$base_path" -type f -printf "%T+ %p\n" | sort # Show downloaded files with timestamps
