import os
import json
import re
from anthropic import Anthropic
import argparse
from typing import Dict, List, Optional
import shutil

class CakeToLaravelConverter:
    def __init__(self, api_key: str):
        self.anthropic = Anthropic(api_key=api_key)
        self.output_dir = "laravel_converted_project"
        self.components_to_install: set = set()
        
    def setup_output_directories(self):
        """Create necessary Laravel project directories"""
        directories = [
            f"{self.output_dir}/app/Http/Controllers",
            f"{self.output_dir}/app/Models",
            f"{self.output_dir}/app/Http/Requests",
            f"{self.output_dir}/resources/js/Pages",
            f"{self.output_dir}/resources/js/Components",
            f"{self.output_dir}/resources/js/Layouts",
            f"{self.output_dir}/routes",
            f"{self.output_dir}/config",
            f"{self.output_dir}/components/ui",  # For shadcn components
        ]
        for directory in directories:
            os.makedirs(directory, exist_ok=True)

    def initialize_laravel_project(self):
        """Initialize Laravel project with Jetstream and Inertia"""
        commands = [
            "composer create-project laravel/laravel .",
            "composer require laravel/jetstream",
            "php artisan jetstream:install inertia --teams",
            "npm install",
            "npm install @inertiajs/inertia @inertiajs/inertia-react",
            "npm install -D tailwindcss postcss autoprefixer",
            "npm install @radix-ui/react-icons lucide-react",
            "npx shadcn-ui@latest init",
        ]
        
        # Create initialization script
        with open(f"{self.output_dir}/init_project.sh", 'w') as f:
            f.write("#!/bin/bash\n\n")
            f.write("# Initialize Laravel project with Jetstream and Inertia\n")
            for cmd in commands:
                f.write(f"{cmd}\n")
            f.write("\n# Install required shadcn components\n")
            f.write("npx shadcn-ui@latest add\n")
        
        os.chmod(f"{self.output_dir}/init_project.sh", 0o755)

    def read_extracted_content(self, input_dir: str) -> Dict[str, str]:
        """Read the extracted CakePHP content"""
        content = {}
        file_types = ['models', 'controllers', 'templates', 'config', 'routes', 'components']
        
        for file_type in file_types:
            file_path = f"{input_dir}/{file_type}.txt"
            if os.path.exists(file_path):
                with open(file_path, 'r') as f:
                    content[file_type] = f.read()
            else:
                content[file_type] = ""
        return content

    def convert_model(self, cake_model_content: str) -> str:
        """Convert CakePHP model to Laravel model"""
        prompt = f"""
        Convert this CakePHP model to Laravel Eloquent model:
        {cake_model_content}
        
        Requirements:
        1. Use Laravel 10+ conventions
        2. Convert CakePHP associations to Laravel relationships
        3. Convert validation rules to Laravel format
        4. Include proper namespace and use statements
        5. Maintain the same business logic
        6. Add Laravel PHPDoc blocks for proper IDE support
        7. Include fillable and hidden attributes
        8. Convert any CakePHP behaviors to Laravel traits or custom implementations
        """
        
        response = self.anthropic.messages.create(
            model="claude-3-sonnet-20240229",
            max_tokens=4000,
            temperature=0,
            messages=[{"role": "user", "content": prompt}]
        )
        return response.content

    def convert_controller(self, cake_controller_content: str) -> str:
        """Convert CakePHP controller to Laravel controller with Inertia"""
        prompt = f"""
        Convert this CakePHP controller to Laravel controller using Inertia.js and Jetstream:
        {cake_controller_content}
        
        Requirements:
        1. Use Laravel 10+ and Jetstream conventions
        2. Implement Inertia responses with proper typehints
        3. Convert CakePHP methods to Laravel equivalents
        4. Include proper error handling and validation
        5. Use Form Request Validation classes
        6. Implement proper authentication and authorization
        7. Use Laravel's response macros where appropriate
        8. Include proper PHPDoc blocks
        9. Implement proper status codes and response formats
        10. Handle file uploads using Laravel's storage system
        """
        
        response = self.anthropic.messages.create(
            model="claude-3-sonnet-20240229",
            max_tokens=4000,
            temperature=0,
            messages=[{"role": "user", "content": prompt}]
        )
        return response.content

    def detect_required_shadcn_components(self, jsx_content: str) -> List[str]:
        """Detect which shadcn components are needed based on the JSX content"""
        components = set()
        
        # Map of common UI elements to shadcn components
        component_patterns = {
            r'button': 'button',
            r'input|textfield': 'input',
            r'select|dropdown': 'select',
            r'checkbox': 'checkbox',
            r'radio': 'radio-group',
            r'textarea': 'textarea',
            r'alert|notification': 'alert',
            r'modal|dialog': 'dialog',
            r'tab': 'tabs',
            r'toast': 'toast',
            r'tooltip': 'tooltip',
            r'card': 'card',
            r'form': 'form',
            r'toggle': 'toggle',
            r'slider': 'slider',
            r'progress': 'progress',
            r'navigation|navbar': 'navigation-menu',
            r'table': 'table',
        }
        
        for pattern, component in component_patterns.items():
            if re.search(pattern, jsx_content, re.IGNORECASE):
                components.add(component)
                
        return list(components)

    def convert_view_to_react(self, cake_view_content: str, view_name: str) -> Dict[str, str]:
        """Convert CakePHP view to React component using shadcn/ui"""
        # First, analyze the view to determine required shadcn components
        needed_components = self.detect_required_shadcn_components(cake_view_content)
        self.components_to_install.update(needed_components)

        # Create the prompt with specific shadcn components
        prompt = f"""
        Convert this CakePHP view to a React component using Inertia.js and shadcn/ui components:
        {cake_view_content}
        
        Requirements:
        1. Use the following shadcn/ui components: {', '.join(needed_components)}
        2. Follow React 18+ best practices
        3. Use TypeScript for better type safety
        4. Implement proper Inertia.js patterns
        5. Use React hooks for state management
        6. Implement proper form handling with proper validation
        7. Use proper loading states and error handling
        8. Implement proper accessibility features
        9. Use Tailwind CSS for custom styling
        10. Create reusable components where appropriate
        11. Include proper prop types and interfaces
        12. Use Layout components from Jetstream
        13. Implement proper authentication checks
        
        Return both the main component and any necessary auxiliary components.
        """
        
        response = self.anthropic.messages.create(
            model="claude-3-sonnet-20240229",
            max_tokens=4000,
            temperature=0,
            messages=[{"role": "user", "content": prompt}]
        )
        
        return {
            'main': response.content,
            'components': needed_components
        }

    def create_typescript_interfaces(self, models: List[str]) -> str:
        """Create TypeScript interfaces based on Laravel models"""
        prompt = f"""
        Create TypeScript interfaces for these Laravel models:
        {models}
        
        Requirements:
        1. Include proper types for all attributes
        2. Add proper documentation comments
        3. Include relationship types
        4. Use proper date types
        5. Include proper nullable types
        6. Add utility types where appropriate
        """
        
        response = self.anthropic.messages.create(
            model="claude-3-sonnet-20240229",
            max_tokens=4000,
            temperature=0,
            messages=[{"role": "user", "content": prompt}]
        )
        return response.content

    def save_converted_file(self, content: str, file_path: str):
        """Save converted content to file"""
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        with open(file_path, 'w') as f:
            f.write(content)

    def create_shadcn_installation_script(self):
        """Create script to install required shadcn components"""
        install_commands = [f"npx shadcn-ui@latest add {component}" for component in self.components_to_install]
        
        with open(f"{self.output_dir}/install_components.sh", 'w') as f:
            f.write("#!/bin/bash\n\n")
            f.write("# Install required shadcn components\n")
            for cmd in install_commands:
                f.write(f"{cmd}\n")
        
        os.chmod(f"{self.output_dir}/install_components.sh", 0o755)

    def convert_project(self, input_dir: str):
        """Main conversion process"""
        print("Starting conversion process...")
        
        # Setup project structure
        self.setup_output_directories()
        self.initialize_laravel_project()
        
        # Read extracted content
        content = self.read_extracted_content(input_dir)
        
        # Convert and save models
        print("Converting models...")
        if content.get('models'):
            converted_model = self.convert_model(content['models'])
            self.save_converted_file(
                converted_model,
                f"{self.output_dir}/app/Models/ConvertedModel.php"
            )

        # Convert and save controllers
        print("Converting controllers...")
        if content.get('controllers'):
            converted_controller = self.convert_controller(content['controllers'])
            self.save_converted_file(
                converted_controller,
                f"{self.output_dir}/app/Http/Controllers/ConvertedController.php"
            )

        # Convert and save views to React components
        print("Converting views to React components...")
        if content.get('templates'):
            view_sections = content['templates'].split('=== File:')
            for section in view_sections[1:]:  # Skip first empty section
                # Extract view name from section header
                view_name = section.split('\n')[0].strip()
                view_content = section.split('\n', 1)[1]
                
                converted_view = self.convert_view_to_react(view_content, view_name)
                
                # Save main component
                component_name = os.path.basename(view_name).replace('.php', '')
                self.save_converted_file(
                    converted_view['main'],
                    f"{self.output_dir}/resources/js/Pages/{component_name}.tsx"
                )

        # Create TypeScript interfaces
        print("Creating TypeScript interfaces...")
        if content.get('models'):
            interfaces = self.create_typescript_interfaces([content['models']])
            self.save_converted_file(
                interfaces,
                f"{self.output_dir}/resources/js/types/models.ts"
            )

        # Create shadcn component installation script
        self.create_shadcn_installation_script()

        print(f"""
Conversion completed! Check the {self.output_dir} directory for converted files.

To set up the project:
1. Navigate to the project directory
2. Run ./init_project.sh to initialize the Laravel project with Jetstream
3. Run ./install_components.sh to install required shadcn components
4. Run 'npm run dev' to start the development server

Required shadcn components: {', '.join(self.components_to_install)}
        """)

def main():
    parser = argparse.ArgumentParser(description='Convert CakePHP project to Laravel with React/Inertia')
    parser.add_argument('input_dir', help='Directory containing extracted CakePHP content')
    parser.add_argument('--api-key', required=True, help='Anthropic API key')
    
    args = parser.parse_args()
    
    converter = CakeToLaravelConverter(args.api_key)
    converter.convert_project(args.input_dir)

if __name__ == "__main__":
    main()