#!/bin/bash
# Script Name: find-post.sh
# Purpose: Search for posts by keyword in titles or content
# Usage: ./find-post.sh <keyword>
#
# This script will:
# 1. Take a keyword as input
# 2. Search for it in post titles and content
# 3. Display matching posts with context
# 4. Show where the keyword was found

# ============================================
# GET THE KEYWORD
# ============================================
keyword="$1"

# ============================================
# CHECK IF KEYWORD WAS PROVIDED
# ============================================
if [ -z "$keyword" ]; then
  echo "Error: Please provide a keyword to search for"
  echo "Usage: $0 <keyword>"
  echo ""
  echo "Example: $0 bash"
  echo "Example: $0 \"static site\""
  exit 1
fi

echo ""
echo "Searching for: $keyword"
echo "===================="
echo ""

# ============================================
# SEARCH IN POSTS
# ============================================
# We'll search in both src/posts/ and src/drafts/
# grep is the search tool we'll use

# Counter for matches
match_count=0

# ============================================
# SEARCH IN POST TITLES FIRST
# ============================================
echo "Posts with '$keyword' in title:"
echo "---"

for file in src/posts/*.md src/drafts/*.md; do
  # Check if file exists
  if [ ! -e "$file" ]; then
    continue
  fi
  
  # Extract the title
  title=$(grep '^title:' "$file" | head -n 1 | sed 's/title: "//' | sed 's/".*$//')
  
  # Check if keyword is in the title
  # grep -i makes the search case-insensitive
  # grep -q is quiet mode (just returns success/failure, no output)
  if echo "$title" | grep -i -q "$keyword"; then
    # Get the filename for display
    filename=$(basename "$file")
    
    # Get the date from the filename
    date=$(echo "$filename" | cut -c 1-10)
    
    # Show the match
    echo "  [$date] $title"
    echo "  File: $file"
    echo ""
    
    match_count=$((match_count + 1))
  fi
done

if [ $match_count -eq 0 ]; then
  echo "  No matches in titles"
  echo ""
fi

# ============================================
# SEARCH IN POST CONTENT
# ============================================
echo "Posts with '$keyword' in content:"
echo "---"

# grep can search through files and show context
# grep options:
#   -i = case insensitive
#   -l = list filenames only (we'll process them ourselves)
#   -r = recursive (not needed, we specify files)
#
# We use grep to find files with matches, then show details

# Find all files containing the keyword
matching_files=$(grep -i -l "$keyword" src/posts/*.md src/drafts/*.md 2>/dev/null)

if [ -z "$matching_files" ]; then
  echo "  No matches in content"
  echo ""
else
  # Process each matching file
  echo "$matching_files" | while read -r file; do
    # Get file info
    filename=$(basename "$file")
    
    # Extract title
    title=$(grep '^title:' "$file" | head -n 1 | sed 's/title: "//' | sed 's/".*$//')
    
    echo "  $title"
    echo "  File: $file"
    
    # Show matching lines with context
    # grep options:
    #   -i = case insensitive
    #   -n = show line numbers
    #   -C 1 = show 1 line of context before and after match
    #   --color=never = don't use colors (for better readability)
    
    echo "  Matches:"
    grep -i -n -C 1 --color=never "$keyword" "$file" | head -n 10 | while read -r line; do
      echo "    $line"
    done
    echo ""
    
    match_count=$((match_count + 1))
  done
fi

# ============================================
# SHOW SUMMARY
# ============================================
echo "---"
if [ $match_count -eq 0 ]; then
  echo "No posts found containing '$keyword'"
else
  echo "Found '$keyword' in $match_count posts"
fi
echo ""
