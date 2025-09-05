#!/bin/bash

# Dotfiles setup script - generates config files from .tmpl templates with secrets

set -e

echo "🔧 Setting up dotfiles with secrets..."

# Path to secrets file in dotfiles repo
SECRETS_FILE="$HOME/dotfiles/zsh/.zsh_secrets"

# Function to substitute environment variables in .tmpl files
substitute_tmpl() {
    local tmpl_file="$1"
    local output_file="${tmpl_file%.tmpl}"  # Remove .tmpl extension
    
    if [ -f "$tmpl_file" ]; then
        echo "📄 Generating $(basename "$output_file") from $(basename "$tmpl_file")..."
        
        # Source secrets first
        source "$SECRETS_FILE" 2>/dev/null || {
            echo "❌ Error: Cannot source $SECRETS_FILE"
            return 1
        }
        
        # Use envsubst to replace variables
        envsubst < "$tmpl_file" > "$output_file"
        echo "✅ Generated $output_file"
    else
        echo "⚠️  Warning: Template $tmpl_file not found"
    fi
}

# Function to find and process all .tmpl files
process_all_templates() {
    echo "🔍 Searching for .tmpl files..."
    
    # Find all .tmpl files in the dotfiles directory
    find "$HOME/dotfiles" -name "*.tmpl" -type f | while read -r tmpl_file; do
        substitute_tmpl "$tmpl_file"
    done
}

# Function to update .gitignore
update_gitignore() {
    echo "📝 Updating .gitignore..."
    "$HOME/dotfiles/update-gitignore.sh" > "$HOME/dotfiles/.gitignore"
    echo "✅ Updated .gitignore with current .tmpl files"
}

# Check if secrets file exists
if [ ! -f "$SECRETS_FILE" ]; then
    echo "❌ Error: $SECRETS_FILE not found. Please create it first."
    exit 1
fi

# Update gitignore to match current .tmpl files
update_gitignore

# Process all template files
process_all_templates

echo ""
echo "🎉 Setup complete! Next steps:"
echo "1. Run 'stow code git terminal tmux zsh' to link your dotfiles"
echo "2. Restart your shell or run 'source ~/.zshrc'"
echo "3. Test your applications"
echo ""
echo "🔒 Security reminder:"
echo "- Only .tmpl files are committed to git"
echo "- Generated files (without .tmpl) contain real secrets"
echo "- .gitignore is auto-updated to ignore generated files"