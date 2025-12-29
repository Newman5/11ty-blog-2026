#!/bin/bash
# Script Name: post-stats.sh
# Purpose: Shows statistics about your blog
# Usage: ./post-stats.sh
#
# This script will:
# 1. Count total posts and drafts
# 2. Calculate total words and average per post
# 3. Show posts grouped by year
# 4. Show top tags with counts
# 5. List the 5 most recent posts

echo ""
echo "Blog Statistics"
echo "==============="
echo ""

# ============================================
# COUNT POSTS AND DRAFTS
# ============================================
# Use find to count files, then wc to count the lines
# Each line from find is one file

# Count published posts
# find searches for files
#   src/posts/ = directory to search
#   -name "*.md" = files ending with .md
# wc -l counts lines (one per file)
post_count=$(find src/posts/ -name "*.md" 2>/dev/null | wc -l)

# Count drafts
draft_count=$(find src/drafts/ -name "*.md" 2>/dev/null | wc -l)

echo "Posts: $post_count"
echo "Drafts: $draft_count"
echo ""

# ============================================
# CALCULATE TOTAL WORDS
# ============================================
# Count words in all posts
# wc -w counts words
# We sum up words from all post files

total_words=0

# Loop through each post file
for file in src/posts/*.md; do
  # Check if file exists
  if [ ! -e "$file" ]; then
    continue
  fi
  
  # Count words in this file
  # wc -w < file counts words, awk extracts the number
  words=$(wc -w < "$file" | awk '{print $1}')
  
  # Add to total
  # $((...)) does arithmetic in bash
  total_words=$((total_words + words))
done

echo "Total words: $total_words"

# Calculate average words per post
# Only if we have posts (avoid division by zero)
if [ $post_count -gt 0 ]; then
  # Bash only does integer arithmetic
  # So we calculate average as: total / count
  average_words=$((total_words / post_count))
  echo "Average words per post: $average_words"
fi

echo ""

# ============================================
# POSTS BY YEAR
# ============================================
echo "Posts by Year:"
echo "---"

# We'll extract the year from each filename
# Filenames are like: 2026-01-15-title.md
# We want just the "2026" part

# Create a temporary file to store years
temp_years=$(mktemp)

# Extract year from each filename
for file in src/posts/*.md; do
  if [ ! -e "$file" ]; then
    continue
  fi
  
  # Get just the filename without the path
  filename=$(basename "$file")
  
  # Extract the first 4 characters (the year)
  # cut -c 1-4 takes characters 1 through 4
  year=$(echo "$filename" | cut -c 1-4)
  
  # Write the year to our temp file
  echo "$year" >> "$temp_years"
done

# Count posts per year
# sort sorts the years
# uniq -c counts how many times each year appears
#   (uniq only works on sorted input)
sort "$temp_years" | uniq -c | while read -r count year; do
  echo "  $year: $count posts"
done

# Clean up the temporary file
rm "$temp_years"

echo ""

# ============================================
# TOP TAGS
# ============================================
echo "Top 10 Tags:"
echo "---"

# Create a temporary file to store all tags
temp_tags=$(mktemp)

# Extract tags from all posts
for file in src/posts/*.md src/drafts/*.md; do
  if [ ! -e "$file" ]; then
    continue
  fi
  
  # Tags are in front matter like:
  # tags:
  #   - tag1
  #   - tag2
  #
  # We need to find these lines and extract the tag names
  
  # Use awk to extract tags
  # awk can process text line by line
  # We look for lines with '  - ' after we've seen 'tags:'
  awk '
    /^tags:/ { in_tags=1; next }
    in_tags && /^  - / { 
      # Remove the "  - " prefix and print the tag
      sub(/^  - /, ""); 
      print; 
      next 
    }
    in_tags && /^[^ ]/ { in_tags=0 }
  ' "$file" >> "$temp_tags"
done

# Count and sort tags
# sort sorts the tags alphabetically
# uniq -c counts occurrences
# sort -rn sorts numerically in reverse (highest first)
# head -n 10 takes only the first 10
sort "$temp_tags" | uniq -c | sort -rn | head -n 10 | while read -r count tag; do
  echo "  $tag: $count posts"
done

# Clean up
rm "$temp_tags"

echo ""

# ============================================
# MOST RECENT POSTS
# ============================================
echo "5 Most Recent Posts:"
echo "---"

# List post files, sort by filename (which includes date), take last 5
# ls -1 lists one file per line
# sort sorts alphabetically
# tail -n 5 takes the last 5 lines
# We then need to reverse to show newest first

ls -1 src/posts/*.md 2>/dev/null | sort -r | head -n 5 | while read -r file; do
  # Get filename and extract date
  filename=$(basename "$file")
  
  # Date is the first 10 characters (YYYY-MM-DD)
  date=$(echo "$filename" | cut -c 1-10)
  
  # Extract title from front matter
  title=$(grep '^title:' "$file" | head -n 1 | sed 's/title: "//' | sed 's/".*$//')
  
  echo "  $date - $title"
done

echo ""
