#!/bin/bash
# Script Name: new-link-post.sh
# Purpose: Creates a link blog post (for sharing interesting links)
# Usage: ./new-link-post.sh <url> [description]
#
# This script will:
# 1. Take a URL and optional description as input
# 2. Try to fetch the page title from the URL
# 3. Create a markdown file with front matter including the link
# 4. Open it in your editor

# ============================================
# GET THE URL AND DESCRIPTION
# ============================================
url="$1"
description="$2"

# ============================================
# CHECK IF URL WAS PROVIDED
# ============================================
# -z checks if the variable is empty
if [ -z "$url" ]; then
  echo "Error: Please provide a URL"
  echo "Usage: $0 <url> [description]"
  echo ""
  echo "Example: $0 https://example.com \"Interesting article\""
  exit 1
fi

# ============================================
# TRY TO FETCH THE PAGE TITLE
# ============================================
# We'll use curl to download the page and extract the title
# This is optional - if it fails, we'll ask the user for a title

echo "Fetching page title..."

# curl downloads web pages
#   -s = silent (don't show progress)
#   -L = follow redirects
#   -m 10 = timeout after 10 seconds
#
# grep searches for text
#   -o = only show the matching part
#   -i = case insensitive
#   -m 1 = stop after first match
#
# sed modifies text
#   This removes the <title> tags to leave just the text

page_title=$(curl -s -L -m 10 "$url" | grep -o -i '<title>[^<]*</title>' | sed -e 's/<title>//I' -e 's/<\/title>//I' | head -n 1)

# ============================================
# USE DESCRIPTION OR FETCHED TITLE
# ============================================
# If we got a description, use that as the title
# Otherwise, use the fetched page title
# If both fail, use a generic title

if [ -n "$description" ]; then
  title="$description"
elif [ -n "$page_title" ]; then
  title="$page_title"
  echo "✓ Found title: $title"
else
  # If we couldn't get a title, use a generic one
  # The user can change it in the file
  title="Interesting Link"
  echo "! Could not fetch page title. Using generic title."
  echo "  You can edit the title in the file."
fi

# ============================================
# GENERATE THE DATE
# ============================================
date=$(date +%Y-%m-%d)

# ============================================
# CREATE A URL-FRIENDLY SLUG
# ============================================
# Convert title to lowercase and replace spaces with hyphens
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Remove any characters that aren't letters, numbers, or hyphens
slug=$(echo "$slug" | sed 's/[^a-z0-9-]//g')

# Limit slug length to 50 characters to keep filenames reasonable
# cut -c 1-50 takes characters 1 through 50
slug=$(echo "$slug" | cut -c 1-50)

# ============================================
# BUILD THE IMG DIRECTORY PATH
# check if directory exists and create it if not
# ============================================
img_dir="src/images/posts/${date}-${slug}"
if ! mkdir -p "$img_dir"; then
  echo "Error: Could not create image directory $img_dir"
  exit 1
fi
echo "✓ Image directory created: $img_dir"


# ============================================
# BUILD THE FILENAME
# ============================================
filename="src/posts/${date}-${slug}.md"

# ============================================
# CHECK IF FILE ALREADY EXISTS
# ============================================
if [ -e "$filename" ]; then
  echo "Error: File already exists: $filename"
  echo "Try a different title or delete the existing file"
  exit 1
fi

# ============================================
# CREATE THE FILE WITH FRONT MATTER
# ============================================
# Link posts have a special "link:" field in front matter
# They also use the link-post.njk layout
# They're automatically tagged as "link" and "linkblog"

cat > "$filename" << EOF
---
title: "$title"
date: $date
link: "$url"
tags:
  - link
  - linkblog
layout: link-post.njk
---

Your commentary about this link goes here...

Why is this link interesting? What did you learn from it?

Add your thoughts below:

EOF

# ============================================
# CONFIRM CREATION
# ============================================
echo ""
echo "✓ Created: $filename"
echo "  Link: $url"
echo ""

# ============================================
# OPEN IN EDITOR
# ============================================
# Open the file so the user can add their commentary
if [ -n "$EDITOR" ]; then
  echo "Opening in $EDITOR..."
  $EDITOR "$filename"
else
  echo "Opening in code (set \$EDITOR to use a different editor)..."
  code "$filename"
fi
