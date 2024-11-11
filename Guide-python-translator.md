# CakePHP to Laravel Translation Guide

## Prerequisites
- Python 3.8 or higher
- pip (Python package manager)
- Git
- Composer
- Node.js and npm
- Anthropic API key

## Setup Steps

### 1. Create and Activate Virtual Environment
```bash
# Create a new directory for the project
mkdir cake-to-laravel
cd cake-to-laravel

# Create a virtual environment
python -m venv venv

# Activate the virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate
```

### 2. Install Required Packages
```bash
# Create requirements.txt
cat > requirements.txt << EOL
anthropic
argparse
EOL

# Install dependencies
pip install -r requirements.txt
```

### 3. Save the Converter Script
```bash
# Create the converter script
# Save the Python code into cake_to_laravel_converter.py
```

### 4. Run the Converter

#### Step 1: Extract CakePHP Content
First, run the shell script to extract your CakePHP project content:
```bash
# Make the script executable
chmod +x cakephp-extractor.sh

# Run the extractor
./cakephp-extractor.sh /path/to/your/cakephp/project
```

#### Step 2: Run the Converter
```bash
# Run the converter with your Anthropic API key
python cake_to_laravel_converter.py extracted_cakephp_[timestamp] --api-key your_anthropic_api_key
```

### 5. Post-Conversion Setup

After the conversion is complete, you'll find a new directory called `laravel_converted_project` with all the converted files and setup scripts.

```bash
cd laravel_converted_project

# Make the scripts executable
chmod +x init_project.sh
chmod +x install_components.sh

# Run the initialization script
./init_project.sh

# Install shadcn components
./install_components.sh

# Start the development server
npm run dev
```

## Project Structure After Conversion

```
laravel_converted_project/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   └── Requests/
│   └── Models/
├── resources/
│   ├── js/
│   │   ├── Components/
│   │   ├── Layouts/
│   │   ├── Pages/
│   │   └── types/
│   └── views/
├── routes/
├── components/
│   └── ui/
├── init_project.sh
└── install_components.sh
```

## Troubleshooting

1. If you get permission errors:
```bash
# Make sure the scripts are executable
chmod +x *.sh
```

2. If virtual environment activation fails:
```bash
# On Windows, try:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Then rerun the activation command
```

3. If Anthropic API calls fail:
- Verify your API key is correct
- Check your internet connection
- Ensure you have sufficient API credits

4. If Node.js dependencies fail to install:
```bash
# Clear npm cache and try again
npm cache clean --force
npm install
```

## Environment Cleanup

When you're done with the conversion:
```bash
# Deactivate the virtual environment
deactivate

# Optional: remove the virtual environment
rm -rf venv
```

## Additional Notes

- Make sure to backup your CakePHP project before starting the conversion
- The converter will preserve your business logic while modernizing the codebase
- Review the converted code to ensure it meets your requirements
- Test thoroughly before deploying to production
- The converter creates TypeScript interfaces for your models automatically
- shadcn components are installed based on your existing views' requirements

## Next Steps

After successful conversion:
1. Review the converted code
2. Update database configurations in `.env`
3. Run migrations: `php artisan migrate`
4. Test all routes and functionality
5. Update authentication configuration if needed
6. Review and test all React components
7. Check TypeScript type definitions