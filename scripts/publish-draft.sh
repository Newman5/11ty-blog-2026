#!/bin/bash
# Script Name: publish-draft.sh
# Purpose: Moves a draft from src/drafts/ to src/posts/ and updates the date
# Usage: ./publish-draft.sh <slug>
#
# This script will:
# 1. Find the draft file by slug
# 2. Ask for confirmation
# 3. Update the date in the front matter to today
# 4. Move the file to src/posts/ with today's date in filename
# 5. Confirm the publication

# ============================================
# GET THE SLUG
# ============================================
slug="$1"

# ============================================
# CHECK IF SLUG WAS PROVIDED
# ============================================
if [ -z "$slug" ]; then
  echo "Error: Please provide a draft slug"
  echo "Usage: $0 <slug>"
  echo ""
  echo "Example: $0 my-draft"
  echo ""
  echo "To see available drafts, run: ./blog-cli.sh drafts"
  exit 1
fi

# ============================================
# FIND THE DRAFT FILE
# ============================================
# Look for the draft file (try exact match first)
draft_file="src/drafts/${slug}.md"

if [ -e "$draft_file" ]; then
  echo "Found draft: $draft_file"
else
  # Try to find a file that ends with the slug
  draft_file=$(find src/drafts -name "*${slug}.md" | head -n 1)
  
  if [ -n "$draft_file" ]; then
    echo "Found draft: $draft_file"
  else
    echo "Error: Could not find draft with slug: $slug"
    echo ""
    echo "Available drafts:"
    ./scripts/list-drafts.sh
    exit 1
  fi
fi

# ============================================
# SHOW DRAFT INFO
# ============================================
# Extract the title so we can show it to the user
title=$(grep '^title:' "$draft_file" | head -n 1 | sed 's/title: "//' | sed 's/".*$//')

echo ""
echo "Draft title: $title"
echo "Draft file: $draft_file"
echo ""

# ============================================
# ASK FOR CONFIRMATION
# ============================================
# read command waits for user input
#   -p shows a prompt
#   -r treats backslashes literally (raw input)
# The user's input goes into the confirm variable

echo "This will:"
echo "  1. Update the date to today"
echo "  2. Move the file to src/posts/"
echo ""
read -p "Publish this draft? (y/n): " -r confirm
echo ""

# Check if the user confirmed
# We compare the input to "y" or "Y"
# If it doesn't match, exit without doing anything
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  echo "Publication cancelled."
  exit 0
fi

# ============================================
# GET TODAY'S DATE
# ============================================
date=$(date +%Y-%m-%d)

# ============================================
# CREATE NEW FILENAME
# ============================================
# The new filename includes today's date
new_filename="src/posts/${date}-${slug}.md"

# Check if a post with this name already exists
if [ -e "$new_filename" ]; then
  echo "Error: A post already exists with this name: $new_filename"
  echo "Choose a different slug or delete the existing post"
  exit 1
fi

# ============================================
# UPDATE THE DATE IN THE FILE
# ============================================
# We need to update the date: line in the front matter
# sed can edit files in place with the -i option
#
# The pattern '/^date:/s/.*/date: DATE/' means:
#   /^date:/ - find lines starting with 'date:'
#   s/.*/ - replace the entire line
#   date: DATE - with this text (we'll substitute DATE next)
#
# Then we use sed again to replace DATE with the actual date

# Create a temporary file with the updated date
# We'll use this instead of sed -i for better compatibility
temp_file=$(mktemp)

# Read through the file and update the date line
# awk is a text processing tool
# It can read line by line and make changes
awk -v newdate="$date" '
  /^date:/ { print "date: " newdate; next }
  { print }
' "$draft_file" > "$temp_file"

# ============================================
# MOVE THE FILE
# ============================================
# Move the temporary file to the posts directory
# mv moves (renames) files
mv "$temp_file" "$new_filename"

# Remove the old draft file
rm "$draft_file"

# ============================================
# CONFIRM PUBLICATION
# ============================================
echo "✓ Published: $new_filename"
echo ""
echo "The post is now live in src/posts/"
echo "Run 'npm start' to see it on your site"
echo ""
