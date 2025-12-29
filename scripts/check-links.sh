#!/bin/bash
# Script Name: check-links.sh
# Purpose: Checks for broken external links in blog posts
# Usage: ./check-links.sh
#
# This script will:
# 1. Find all URLs in posts and drafts
# 2. Test each URL with curl to see if it's accessible
# 3. Report which links are broken
# 4. Show a summary at the end

echo ""
echo "Checking Links in Blog Posts"
echo "============================="
echo ""

# ============================================
# INITIALIZE COUNTERS
# ============================================
# We'll track how many links we check and how many are broken
# Variables in bash are just assigned with =
total_links=0
broken_links=0

# ============================================
# FIND ALL MARKDOWN FILES
# ============================================
# Look in both posts/ and drafts/ directories
# We use a simple for loop to process each file

for file in src/posts/*.md src/drafts/*.md; do
  # Check if file exists (handles case of no files)
  if [ ! -e "$file" ]; then
    continue
  fi
  
  # ==========================================
  # EXTRACT URLs FROM THE FILE
  # ==========================================
  # We use grep to find URLs
  # grep -o shows only the matching part (not the whole line)
  # grep -E uses extended regex for better pattern matching
  #
  # The pattern matches http:// or https:// URLs
  # [^])]* matches any characters except ] or ) (for markdown links)
  
  urls=$(grep -o -E 'https?://[^])> ]+' "$file")
  
  # Skip if no URLs found in this file
  if [ -z "$urls" ]; then
    continue
  fi
  
  # ==========================================
  # CHECK EACH URL
  # ==========================================
  # Loop through each URL we found
  # The while read loop processes each line
  
  echo "Checking links in: $file"
  echo ""
  
  echo "$urls" | while read -r url; do
    # Skip empty lines
    if [ -z "$url" ]; then
      continue
    fi
    
    # Increment total counter
    total_links=$((total_links + 1))
    
    # ========================================
    # TEST THE URL WITH CURL
    # ========================================
    # curl can check if a URL is accessible
    #   -s = silent (no progress bar)
    #   -o /dev/null = discard the output (we don't need the page content)
    #   -w "%{http_code}" = write out the HTTP status code
    #   -L = follow redirects
    #   -m 10 = timeout after 10 seconds
    #   --fail = return error code for HTTP errors
    
    echo -n "  Testing: $url ... "
    
    # Get the HTTP status code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" -L -m 10 "$url")
    
    # ========================================
    # CHECK THE STATUS CODE
    # ========================================
    # HTTP status codes:
    #   200-299 = success
    #   300-399 = redirect (curl follows these with -L)
    #   400-499 = client error (broken link, page not found)
    #   500-599 = server error
    #   000 = connection failed or timeout
    
    # Check if the status code indicates success (2xx or 3xx)
    # We use -ge (greater than or equal) and -lt (less than)
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 400 ]; then
      echo "OK ($http_code)"
    else
      # Link is broken or inaccessible
      echo "BROKEN ($http_code)"
      broken_links=$((broken_links + 1))
    fi
  done
  
  echo ""
done

# ============================================
# SHOW SUMMARY
# ============================================
echo "---"
echo "Summary:"
echo "  Total links checked: $total_links"
echo "  Broken links: $broken_links"
echo ""

# ============================================
# EXIT WITH APPROPRIATE CODE
# ============================================
# Exit with error code if we found broken links
# This lets other scripts or CI tools detect the problem
if [ $broken_links -gt 0 ]; then
  echo "⚠ Found broken links. Please fix them."
  exit 1
else
  echo "✓ All links are working!"
  exit 0
fi
