#!/bin/bash

# Configuration
CAKE_PROJECT_PATH=$1  # First argument: Path to CakePHP project
OUTPUT_DIR="extracted_cakephp"
CURRENT_DATE=$(date +%Y%m%d_%H%M%S)

# Create output directory with timestamp
FINAL_OUTPUT_DIR="${OUTPUT_DIR}_${CURRENT_DATE}"
mkdir -p "$FINAL_OUTPUT_DIR"

# Function to extract content and preserve file structure in content
extract_content() {
    local file=$1
    local type=$2
    local relative_path=${file#$CAKE_PROJECT_PATH/}
    
    # Create subdirectory structure in output
    mkdir -p "$FINAL_OUTPUT_DIR/$type/$(dirname "$relative_path")"
    
    echo "=== File: $relative_path ===" >> "$FINAL_OUTPUT_DIR/$type.txt"
    echo "Original Path: $file" >> "$FINAL_OUTPUT_DIR/$type.txt"
    echo "" >> "$FINAL_OUTPUT_DIR/$type.txt"
    cat "$file" >> "$FINAL_OUTPUT_DIR/$type.txt"
    echo "" >> "$FINAL_OUTPUT_DIR/$type.txt"
    echo "=================================" >> "$FINAL_OUTPUT_DIR/$type.txt"
    echo "" >> "$FINAL_OUTPUT_DIR/$type.txt"
    
    # Also copy the file preserving directory structure
    cp "$file" "$FINAL_OUTPUT_DIR/$type/$relative_path"
}

# Function to extract composer dependencies
extract_composer_deps() {
    if [ -f "$CAKE_PROJECT_PATH/composer.json" ]; then
        mkdir -p "$FINAL_OUTPUT_DIR/dependencies"
        cp "$CAKE_PROJECT_PATH/composer.json" "$FINAL_OUTPUT_DIR/dependencies/"
        cp "$CAKE_PROJECT_PATH/composer.lock" "$FINAL_OUTPUT_DIR/dependencies/" 2>/dev/null
    fi
}

# Function to extract npm dependencies if any
extract_npm_deps() {
    if [ -f "$CAKE_PROJECT_PATH/package.json" ]; then
        mkdir -p "$FINAL_OUTPUT_DIR/dependencies"
        cp "$CAKE_PROJECT_PATH/package.json" "$FINAL_OUTPUT_DIR/dependencies/"
        cp "$CAKE_PROJECT_PATH/package-lock.json" "$FINAL_OUTPUT_DIR/dependencies/" 2>/dev/null
        cp "$CAKE_PROJECT_PATH/yarn.lock" "$FINAL_OUTPUT_DIR/dependencies/" 2>/dev/null
    fi
}

# Validate input
if [ -z "$CAKE_PROJECT_PATH" ]; then
    echo "Usage: $0 <path-to-cakephp-project>"
    exit 1
fi

if [ ! -d "$CAKE_PROJECT_PATH" ]; then
    echo "Error: CakePHP project directory not found!"
    exit 1
fi

# Initialize manifest file
echo "Extraction started at: $(date)" > "$FINAL_OUTPUT_DIR/manifest.txt"
echo "Source project path: $CAKE_PROJECT_PATH" >> "$FINAL_OUTPUT_DIR/manifest.txt"
echo "" >> "$FINAL_OUTPUT_DIR/manifest.txt"

# Extract all PHP files from src directory (Models, Controllers, Components, etc.)
echo "Extracting source files..."
find "$CAKE_PROJECT_PATH/src" -type f -name "*.php" | while read file; do
    if [[ $file == */Model/* ]]; then
        extract_content "$file" "models"
    elif [[ $file == */Controller/* ]]; then
        extract_content "$file" "controllers"
    elif [[ $file == */View/* ]]; then
        extract_content "$file" "view_classes"
    elif [[ $file == */Component/* ]]; then
        extract_content "$file" "components"
    elif [[ $file == */Helper/* ]]; then
        extract_content "$file" "helpers"
    elif [[ $file == */Shell/* || $file == */Command/* ]]; then
        extract_content "$file" "commands"
    else
        extract_content "$file" "other_src"
    fi
    echo "Extracted: $file" >> "$FINAL_OUTPUT_DIR/manifest.txt"
done

# Extract template files
echo "Extracting templates..."
find "$CAKE_PROJECT_PATH/templates" -type f | while read file; do
    extract_content "$file" "templates"
    echo "Extracted template: $file" >> "$FINAL_OUTPUT_DIR/manifest.txt"
done

# Extract webroot files (CSS, JS, images)
echo "Extracting webroot files..."
if [ -d "$CAKE_PROJECT_PATH/webroot" ]; then
    find "$CAKE_PROJECT_PATH/webroot" -type f | while read file; do
        extract_content "$file" "webroot"
        echo "Extracted webroot: $file" >> "$FINAL_OUTPUT_DIR/manifest.txt"
    done
fi

# Extract configuration files
echo "Extracting configuration..."
find "$CAKE_PROJECT_PATH/config" -type f -name "*.php" | while read file; do
    extract_content "$file" "config"
    echo "Extracted config: $file" >> "$FINAL_OUTPUT_DIR/manifest.txt"
done

# Extract tests if they exist
echo "Extracting tests..."
if [ -d "$CAKE_PROJECT_PATH/tests" ]; then
    find "$CAKE_PROJECT_PATH/tests" -type f -name "*.php" | while read file; do
        extract_content "$file" "tests"
        echo "Extracted test: $file" >> "$FINAL_OUTPUT_DIR/manifest.txt"
    done
fi

# Extract plugins if they exist
echo "Extracting plugins..."
if [ -d "$CAKE_PROJECT_PATH/plugins" ]; then
    find "$CAKE_PROJECT_PATH/plugins" -type f | while read file; do
        extract_content "$file" "plugins"
        echo "Extracted plugin: $file" >> "$FINAL_OUTPUT_DIR/manifest.txt"
    done
fi

# Extract locale files if they exist
echo "Extracting locale files..."
if [ -d "$CAKE_PROJECT_PATH/resources/locales" ]; then
    find "$CAKE_PROJECT_PATH/resources/locales" -type f | while read file; do
        extract_content "$file" "locales"
        echo "Extracted locale: $file" >> "$FINAL_OUTPUT_DIR/manifest.txt"
    done
fi

# Extract dependencies
echo "Extracting dependencies..."
extract_composer_deps
extract_npm_deps

# Create a summary file
echo "Creating summary..."
{
    echo "=== Project Structure Summary ==="
    echo "Generated at: $(date)"
    echo ""
    echo "Directory Structure:"
    tree "$FINAL_OUTPUT_DIR" >> "$FINAL_OUTPUT_DIR/summary.txt"
    echo ""
    echo "File Counts:"
    echo "Models: $(find "$FINAL_OUTPUT_DIR/models" -type f 2>/dev/null | wc -l)"
    echo "Controllers: $(find "$FINAL_OUTPUT_DIR/controllers" -type f 2>/dev/null | wc -l)"
    echo "Templates: $(find "$FINAL_OUTPUT_DIR/templates" -type f 2>/dev/null | wc -l)"
    echo "Components: $(find "$FINAL_OUTPUT_DIR/components" -type f 2>/dev/null | wc -l)"
    echo "Helpers: $(find "$FINAL_OUTPUT_DIR/helpers" -type f 2>/dev/null | wc -l)"
    echo "Config Files: $(find "$FINAL_OUTPUT_DIR/config" -type f 2>/dev/null | wc -l)"
    echo "Tests: $(find "$FINAL_OUTPUT_DIR/tests" -type f 2>/dev/null | wc -l)"
    echo "Plugin Files: $(find "$FINAL_OUTPUT_DIR/plugins" -type f 2>/dev/null | wc -l)"
    echo "Locale Files: $(find "$FINAL_OUTPUT_DIR/locales" -type f 2>/dev/null | wc -l)"
} > "$FINAL_OUTPUT_DIR/summary.txt"

echo "Extraction completed! Files are saved in $FINAL_OUTPUT_DIR"
echo "Check summary.txt and manifest.txt for detailed information about the extracted files."