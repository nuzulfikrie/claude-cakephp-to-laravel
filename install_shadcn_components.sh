#!/bin/bash


#------------------------------------------#
# About this script
#------------------------------------------# 

# This script is used to install the shadcn-ui components  
# the script will install the core components and additional components
# the script will create a components registry file
# the script will update the package.json scripts
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}==>${NC} $1"
}

# Function to print error
print_error() {
    echo -e "${RED}Error:${NC} $1"
}

# Common components that are often needed as dependencies
CORE_COMPONENTS=(
    "button"
    "input"
    "label"
    "card"
    "form"
)

# Additional components that might be needed based on the conversion
ADDITIONAL_COMPONENTS=(
    "select"
    "checkbox"
    "radio-group"
    "textarea"
    "alert"
    "dialog"
    "tabs"
    "toast"
    "tooltip"
    "toggle"
    "slider"
    "progress"
    "navigation-menu"
    "table"
    "avatar"
    "badge"
    "calendar"
    "command"
    "dropdown-menu"
    "popover"
    "separator"
    "sheet"
    "skeleton"
    "switch"
)

# Install core components first
print_status "Installing core components..."
for component in "${CORE_COMPONENTS[@]}"; do
    print_status "Installing $component component..."
    npx shadcn-ui@latest add $component --yes
done

# Check if we have a components list file from the conversion
if [ -f "required_components.txt" ]; then
    print_status "Installing project-specific components..."
    while IFS= read -r component; do
        # Skip if it's already in CORE_COMPONENTS
        if [[ ! " ${CORE_COMPONENTS[@]} " =~ " ${component} " ]]; then
            print_status "Installing $component component..."
            npx shadcn-ui@latest add $component --yes
        fi
    done < "required_components.txt"
else
    print_warning "No required_components.txt file found. Installing additional common components..."
    
    # Ask user if they want to install additional components
    read -p "Would you like to install additional common components? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for component in "${ADDITIONAL_COMPONENTS[@]}"; do
            read -p "Install $component component? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                print_status "Installing $component component..."
                npx shadcn-ui@latest add $component --yes
            fi
        done
    fi
fi

# Create a components registry file
print_status "Creating components registry..."
mkdir -p resources/js/Components
cat > resources/js/Components/index.ts << EOL
// Generated components registry
$(for component in "${CORE_COMPONENTS[@]}"; do
    echo "export * from '@/Components/ui/${component}'"
done)
$(if [ -f "required_components.txt" ]; then
    while IFS= read -r component; do
        echo "export * from '@/Components/ui/${component}'"
    done < "required_components.txt"
fi)
EOL

# Update package.json scripts
print_status "Updating package.json scripts..."
tmp=$(mktemp)
jq '.scripts += {
    "shadcn": "npx shadcn-ui@latest add",
    "shadcn:add": "npx shadcn-ui@latest add"
}' package.json > "$tmp" && mv "$tmp" package.json

print_status "Components installation completed!"
print_status "You can install additional components later using:"
echo "npm run shadcn <component-name>"
echo ""
print_status "Available components at: https://ui.shadcn.com/docs/components"