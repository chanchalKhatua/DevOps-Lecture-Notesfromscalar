#!/bin/bash

# Navigate to the folder
git pull origin main
# Add changes to Git
git add .

# Commit changes with a generic message
git commit -m "Auto-sync changes at $(date)"

# Push to the GitHub repository
git push origin main
