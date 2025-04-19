#!/bin/bash

# Generate a random filename
FILENAME="testfile_$(head /dev/urandom | tr -dc a-z0-9 | head -c 8).txt"

# Check if the file exists
if [ -f "$FILENAME" ]; then
    echo "File $FILENAME exists. Deleting it..."
    rm "$FILENAME"
fi

# Create the file
echo "Creating file $FILENAME..."
echo "Test content" > "$FILENAME"

# Git add, commit, and push
git add .
git commit -m "pushing test file $FILENAME"
git push
