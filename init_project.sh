#!/bin/bash




#------------------------------------------#
# About this script
#------------------------------------------# 

# This script is used to initialize the laravel project 
# the script will install the composer and npm dependencies
# the script will install the laravel jetstream and inertia 
# the script will initialize the shadcn-ui
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

# Function to print warning
print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

# Function to check command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 is required but not installed."
        exit 1
    fi
}

# Check required commands
print_status "Checking required commands..."
check_command "php"
check_command "composer"
check_command "npm"
check_command "git"

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    print_status "Creating .env file..."
    cp .env.example .env
    php artisan key:generate
fi

# Install Composer dependencies
print_status "Installing Composer dependencies..."
composer install

# Install Laravel Jetstream
print_status "Installing Laravel Jetstream..."
composer require laravel/jetstream
php artisan jetstream:install inertia --teams

# Install and configure Node dependencies
print_status "Installing Node dependencies..."
npm install

# Install development dependencies
print_status "Installing development dependencies..."
npm install -D tailwindcss @tailwindcss/forms @tailwindcss/typography postcss autoprefixer

# Install React and Inertia dependencies
print_status "Installing React and Inertia dependencies..."
npm install @inertiajs/react @inertiajs/inertia @inertiajs/progress
npm install react react-dom @types/react @types/react-dom
npm install class-variance-authority clsx tailwind-merge
npm install @radix-ui/react-icons lucide-react

# Install TypeScript dependencies
print_status "Installing TypeScript dependencies..."
npm install -D typescript @typescript-eslint/parser @typescript-eslint/eslint-plugin
npm install -D @types/node

# Initialize TypeScript
print_status "Initializing TypeScript..."
cat > tsconfig.json << EOL
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["resources/js/*"],
      "~/*": ["resources/*"]
    }
  },
  "include": ["resources/js/**/*.ts", "resources/js/**/*.tsx"],
  "exclude": ["node_modules"]
}
EOL

# Initialize shadcn-ui
print_status "Initializing shadcn-ui..."
npx shadcn-ui@latest init

# Update tailwind.config.js
print_status "Updating Tailwind configuration..."
cat > tailwind.config.js << EOL
const defaultTheme = require('tailwindcss/defaultTheme')

/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: ["class"],
  content: [
    './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
    './vendor/laravel/jetstream/**/*.blade.php',
    './storage/framework/views/*.php',
    './resources/views/**/*.blade.php',
    './resources/js/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    container: {
      center: true,
      padding: "2rem",
      screens: {
        "2xl": "1400px",
      },
    },
    extend: {
      fontFamily: {
        sans: ['Figtree', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "accordion-down": {
          from: { height: 0 },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: 0 },
        },
      },
      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },
  plugins: [require("tailwindcss-animate"), require('@tailwindcss/forms'), require('@tailwindcss/typography')],
}
EOL

# Create components.json for shadcn
print_status "Creating components.json..."
cat > components.json << EOL
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": false,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.js",
    "css": "resources/css/app.css",
    "baseColor": "slate",
    "cssVariables": true
  },
  "aliases": {
    "components": "@/Components",
    "utils": "@/lib/utils"
  }
}
EOL

# Create utils.ts for shadcn
print_status "Creating utility functions..."
mkdir -p resources/js/lib
cat > resources/js/lib/utils.ts << EOL
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"
 
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
EOL

# Update Laravel configuration
print_status "Updating Laravel configuration..."
php artisan config:cache
php artisan view:cache
php artisan route:cache

# Build assets
print_status "Building assets..."
npm run build

print_status "Initial project setup completed successfully!"
print_warning "Don't forget to:"
echo "1. Configure your database in .env"
echo "2. Run migrations with: php artisan migrate"
echo "3. Install required shadcn components using ./install_components.sh"
echo "4. Start the development server with: npm run dev"