#!/bin/bash
# Script Name: edit-draft.sh
# Purpose: Opens a draft file in your editor
# Usage: ./edit-draft.sh <slug>
#
# This script will:
# 1. Take a slug (filename without date or extension) as input
# 2. Find the matching draft file
# 3. Open it in your editor

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
# We need to find a file in src/drafts/ that matches the slug
# The filename might be just "slug.md" or "date-slug.md"

# First, try to find an exact match
draft_file="src/drafts/${slug}.md"

# Check if that exact file exists
if [ -e "$draft_file" ]; then
  # Found it!
  echo "Found draft: $draft_file"
else
  # Try to find a file that ends with the slug
  # Use a pattern like src/drafts/*-slug.md
  draft_file=$(find src/drafts -name "*${slug}.md" | head -n 1)
  
  # Check if we found a matching file
  # -n checks if the variable is not empty
  if [ -n "$draft_file" ]; then
    echo "Found draft: $draft_file"
  else
    # No matching file found
    echo "Error: Could not find draft with slug: $slug"
    echo ""
    echo "Available drafts:"
    ./scripts/list-drafts.sh
    exit 1
  fi
fi

# ============================================
# OPEN IN EDITOR
# ============================================
# Open the file in the user's preferred editor
echo ""
if [ -n "$EDITOR" ]; then
  echo "Opening in $EDITOR..."
  $EDITOR "$draft_file"
else
  echo "Opening in vim (set \$EDITOR to use a different editor)..."
  vim "$draft_file"
fi
