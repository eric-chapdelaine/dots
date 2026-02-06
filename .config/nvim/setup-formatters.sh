#!/bin/bash

# Setup script for Neovim formatters
# Run this after installing the Neovim configuration

echo "Setting up formatters for Neovim..."

# Check if prettier is installed globally
if ! command -v prettier &> /dev/null; then
    echo "Installing prettier globally..."
    npm install -g prettier
else
    echo "✓ Prettier already installed"
fi

# Check if php-cs-fixer is available
if ! command -v php-cs-fixer &> /dev/null; then
    echo "Note: php-cs-fixer not found globally."
    echo "You can install it via: composer global require friendsofphp/php-cs-fixer"
    echo "Or use the project-local version in WFE"
else
    echo "✓ php-cs-fixer already installed"
fi

echo ""
echo "Formatter setup complete!"
echo ""
echo "Note: stylua (Lua formatter) will be auto-installed via Mason when you open Neovim"
echo ""
echo "To verify, open Neovim and run:"
echo "  :ConformInfo"
