#!/bin/bash

# Script to update .gitignore with files that have .tmpl counterparts

echo "# Secrets file (never commit)"
echo "zsh/.zsh_secrets"
echo ""
echo "# Generated files from .tmpl templates (contain real secrets)"
echo "# Auto-generated - do not edit manually"

# Find all .tmpl files and add their non-tmpl counterparts to gitignore
find . -name "*.tmpl" -type f | while read tmpl_file; do
    # Remove the .tmpl extension to get the target file
    target_file="${tmpl_file%.tmpl}"
    # Remove the leading ./ if present
    target_file="${target_file#./}"
    echo "$target_file"
done

echo ""
echo "# Other files"
echo ".env"
echo "*.bak"
echo "*.backup"
echo ".DS_Store"
echo "Thumbs.db"
