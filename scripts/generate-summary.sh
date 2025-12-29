#!/bin/bash
# Script Name: generate-summary.sh
# Purpose: Generates a monthly summary post listing all posts from a month
# Usage: ./generate-summary.sh [YYYY-MM]
#
# This script will:
# 1. Take a month parameter (or use current month)
# 2. Find all posts from that month
# 3. Generate a summary post with the list of posts
# 4. Include tag statistics for the month
# 5. Save as a new post with today's date

# ============================================
# GET THE MONTH PARAMETER
# ============================================
# $1 is the month parameter (optional)
# If not provided, use the current month
month="$1"

# If no month provided, use current month
if [ -z "$month" ]; then
  # Get current month in YYYY-MM format
  # date +%Y-%m gives us something like "2026-01"
  month=$(date +%Y-%m)
  echo "No month specified, using current month: $month"
else
  echo "Generating summary for: $month"
fi

# ============================================
# VALIDATE MONTH FORMAT
# ============================================
# Check if month is in YYYY-MM format
# We use a simple regex pattern check
# grep -E uses extended regex
# ^[0-9]{4}-[0-9]{2}$ means:
#   ^ = start of string
#   [0-9]{4} = exactly 4 digits
#   - = literal hyphen
#   [0-9]{2} = exactly 2 digits
#   $ = end of string

if ! echo "$month" | grep -E '^[0-9]{4}-[0-9]{2}$' > /dev/null; then
  echo "Error: Month must be in YYYY-MM format"
  echo "Example: 2026-01"
  exit 1
fi

# ============================================
# FIND POSTS FROM THIS MONTH
# ============================================
# Look for all posts that start with the month prefix
# For example, if month is "2026-01", we want files like:
#   2026-01-05-post.md
#   2026-01-15-another.md

echo ""
echo "Finding posts from $month..."

# Create a temporary file to store matching posts
temp_posts=$(mktemp)

# Find all matching posts
for file in src/posts/${month}-*.md; do
  # Check if file exists (handles case of no matches)
  if [ ! -e "$file" ]; then
    continue
  fi
  
  # Add to our list
  echo "$file" >> "$temp_posts"
done

# Count how many posts we found
post_count=$(wc -l < "$temp_posts" | awk '{print $1}')

if [ $post_count -eq 0 ]; then
  echo "No posts found for $month"
  rm "$temp_posts"
  exit 0
fi

echo "Found $post_count posts"
echo ""

# ============================================
# EXTRACT MONTH NAME FOR TITLE
# ============================================
# Convert "2026-01" to "January 2026" for the title
# date command can parse and format dates

# Extract year and month number
year=$(echo "$month" | cut -d'-' -f1)
month_num=$(echo "$month" | cut -d'-' -f2)

# Create a date string that date can parse
# We use the first day of the month
date_str="${year}-${month_num}-01"

# Format it as "Month Year"
month_name=$(date -d "$date_str" +"%B %Y" 2>/dev/null || date -j -f "%Y-%m-%d" "$date_str" +"%B %Y" 2>/dev/null)

# Fallback if date parsing fails (use the YYYY-MM format)
if [ -z "$month_name" ]; then
  month_name="$month"
fi

# ============================================
# CREATE THE SUMMARY POST
# ============================================
# The summary will be a new post with today's date
today=$(date +%Y-%m-%d)
summary_slug="summary-${month}"
summary_file="src/posts/${today}-${summary_slug}.md"

# Check if summary already exists
if [ -e "$summary_file" ]; then
  echo "Warning: Summary already exists: $summary_file"
  read -p "Overwrite? (y/n): " -r confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Cancelled."
    rm "$temp_posts"
    exit 0
  fi
fi

# ============================================
# BUILD THE SUMMARY CONTENT
# ============================================
# Start writing the summary post

cat > "$summary_file" << EOF
---
title: "Monthly Summary: $month_name"
date: $today
tags:
  - summary
  - meta
layout: post.njk
---

Summary of blog posts from **$month_name**.

## Posts This Month ($post_count total)

EOF

# ============================================
# ADD EACH POST TO THE SUMMARY
# ============================================
# Read from our temp file and add each post
while read -r file; do
  # Extract information about each post
  filename=$(basename "$file")
  post_date=$(echo "$filename" | cut -c 1-10)
  
  # Get the title
  title=$(grep '^title:' "$file" | head -n 1 | sed 's/title: "//' | sed 's/".*$//')
  
  # Get the tags
  tags=$(awk '/^tags:/ { in_tags=1; next } in_tags && /^  - / { sub(/^  - /, ""); print; next } in_tags && /^[^ ]/ { in_tags=0 }' "$file" | tr '\n' ', ' | sed 's/, $//')
  
  # Get word count
  words=$(wc -w < "$file" | awk '{print $1}')
  
  # Add to summary
  echo "### [$title](/${filename%.md}/)" >> "$summary_file"
  echo "" >> "$summary_file"
  echo "- **Date:** $post_date" >> "$summary_file"
  echo "- **Words:** $words" >> "$summary_file"
  if [ -n "$tags" ]; then
    echo "- **Tags:** $tags" >> "$summary_file"
  fi
  echo "" >> "$summary_file"
  
done < "$temp_posts"

# ============================================
# ADD TAG STATISTICS
# ============================================
echo "## Tag Statistics" >> "$summary_file"
echo "" >> "$summary_file"

# Create temp file for tags
temp_tags=$(mktemp)

# Extract all tags from posts this month
while read -r file; do
  awk '/^tags:/ { in_tags=1; next } in_tags && /^  - / { sub(/^  - /, ""); print; next } in_tags && /^[^ ]/ { in_tags=0 }' "$file" >> "$temp_tags"
done < "$temp_posts"

# Count tags
echo "Tags used this month:" >> "$summary_file"
echo "" >> "$summary_file"

sort "$temp_tags" | uniq -c | sort -rn | while read -r count tag; do
  echo "- **$tag**: $count posts" >> "$summary_file"
done

# Clean up
rm "$temp_tags"
rm "$temp_posts"

# ============================================
# FINISH THE SUMMARY
# ============================================
echo "" >> "$summary_file"
echo "---" >> "$summary_file"
echo "" >> "$summary_file"
echo "*This summary was automatically generated.*" >> "$summary_file"

# ============================================
# CONFIRM CREATION
# ============================================
echo "✓ Created summary: $summary_file"
echo ""
echo "Summary includes:"
echo "  - $post_count posts from $month_name"
echo "  - Post titles and metadata"
echo "  - Tag statistics"
echo ""
