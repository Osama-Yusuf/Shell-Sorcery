#!/bin/bash

build(){
    # Create the build directory
    mkdir -p build

    # Define the output file
    output_script="build/pick.sh"

    # Initialize the output file with a shebang line
    echo -e "#!/bin/bash\n" > "$output_script"
    # echo "" >> "$output_script"

    # Append modules from the modules directory
    echo "# Including module functions" >> "$output_script"
    for module in modules/*.sh; do
        echo "# Start of $module" >> "$output_script"
        grep -v '^#!' "$module" >> "$output_script"
        echo "" >> "$output_script"
    done

    # Append the main script, excluding source lines
    echo "# Main script logic" >> "$output_script"
    grep -v '^#!' main.sh | grep -v '^source' >> "$output_script"

    # Make the final script executable
    chmod +x "$output_script"

    echo "Build complete. The combined script is $output_script."
}

# check if an arg called rm is passed
if [[ "$1" == "rm" ]]; then
    rm -fr build
    exit 0
else
    build
fi