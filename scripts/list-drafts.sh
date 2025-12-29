#!/bin/bash
# Script Name: list-drafts.sh
# Purpose: Lists all draft blog posts with their word counts
# Usage: ./list-drafts.sh
#
# This script will:
# 1. Find all markdown files in src/drafts/
# 2. Extract the title from each file's front matter
# 3. Count the words in each draft
# 4. Display them in a readable format

# ============================================
# FIND ALL DRAFTS
# ============================================
# Look for all .md files in src/drafts/ directory
# We use a simple pattern to match files

echo ""
echo "Draft Posts"
echo "==========="
echo ""

# Count how many drafts we find
# We'll use this to show a message if there are no drafts
draft_count=0

# ============================================
# LOOP THROUGH EACH DRAFT FILE
# ============================================
# The for loop iterates over each .md file in src/drafts/
# The pattern src/drafts/*.md expands to all matching files

for draft_file in src/drafts/*.md; do
  # Check if the file actually exists
  # The -e test returns true if the file exists
  # This handles the case where there are no .md files
  # (the pattern would literally be "src/drafts/*.md")
  if [ ! -e "$draft_file" ]; then
    # No draft files found
    continue
  fi
  
  # Increment the counter
  # $((...)) is arithmetic evaluation in bash
  draft_count=$((draft_count + 1))
  
  # ==========================================
  # EXTRACT THE TITLE
  # ==========================================
  # The title is in the front matter in a line like: title: "My Title"
  # We use grep to find that line, then sed to extract just the title
  
  # grep searches for lines matching a pattern
  #   '^title:' means lines starting with 'title:'
  #   ^ means start of line
  
  # head -n 1 takes only the first match
  #   (in case 'title:' appears in the content too)
  
  # sed modifies the text
  #   's/title: "//' removes 'title: "' from the start
  #   's/".*$//' removes the closing quote and anything after
  
  title=$(grep '^title:' "$draft_file" | head -n 1 | sed 's/title: "//' | sed 's/".*$//')
  
  # If we couldn't find a title, use the filename instead
  if [ -z "$title" ]; then
    # basename removes the directory path
    # We get just the filename without the path
    title=$(basename "$draft_file")
  fi
  
  # ==========================================
  # COUNT WORDS
  # ==========================================
  # wc (word count) counts lines, words, and characters
  #   -w means only count words
  #
  # awk extracts the first field (the number)
  #   awk '{print $1}' means print the first column
  
  word_count=$(wc -w < "$draft_file" | awk '{print $1}')
  
  # ==========================================
  # GET THE FILENAME (for reference)
  # ==========================================
  # basename gets just the filename without the directory
  filename=$(basename "$draft_file")
  
  # ==========================================
  # DISPLAY THE DRAFT INFO
  # ==========================================
  # Show the title, filename, and word count
  echo "• $title"
  echo "  File: $filename"
  echo "  Words: $word_count"
  echo ""
done

# ============================================
# SHOW SUMMARY
# ============================================
# If we didn't find any drafts, show a message
if [ $draft_count -eq 0 ]; then
  echo "No drafts found in src/drafts/"
  echo ""
  echo "To create a draft, add a .md file to src/drafts/"
  echo "Or use: ./blog-cli.sh new \"Title\" and save it in drafts/"
else
  # Show the total count
  echo "---"
  echo "Total drafts: $draft_count"
fi

echo ""
