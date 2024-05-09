#!/bin/bash

# Directory containing your JSON data files
DATA_DIR="./values"

# Location of your Jinja2 template file
TEMPLATE_FILE="./template.j2.yaml"

# Output directory for the rendered YAML files
OUTPUT_DIR="./out-dir/"

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Loop through all JSON files in the data directory
for DATA_FILE in "$DATA_DIR"/*.yaml; do
    # Extract the filename without the extension to use for the output file
    FILENAME=$(basename "$DATA_FILE" .yaml)

    # Define the output filename
    OUTPUT_FILE="$OUTPUT_DIR/$FILENAME.yaml"

    # Render the template with the data file and write to the output file
    jinja2 "$TEMPLATE_FILE" "$DATA_FILE" > "$OUTPUT_FILE"

    echo "Rendered $DATA_FILE to $OUTPUT_FILE"
done

echo "All files processed."
