#!/bin/bash
# Script Name: blog-cli.sh
# Purpose: Main command-line interface for managing blog posts
# Usage: ./blog-cli.sh <command> [arguments]
#
# This is the main entry point for all blog commands.
# It routes commands to the appropriate script in the scripts/ directory.

# ============================================
# HELP MESSAGE
# ============================================
# This function shows all available commands
# Functions in bash let us reuse code
show_help() {
  echo ""
  echo "11ty Blog CLI - Beginner-Friendly Blog Management"
  echo "=================================================="
  echo ""
  echo "Usage: ./blog-cli.sh <command> [arguments]"
  echo ""
  echo "Available Commands:"
  echo ""
  echo "  new <title>              Create a new blog post"
  echo "                           Example: ./blog-cli.sh new \"My First Post\""
  echo ""
  echo "  link <url> [description] Create a link blog post"
  echo "                           Example: ./blog-cli.sh link https://example.com \"Cool site\""
  echo ""
  echo "  drafts                   List all draft posts"
  echo "                           Example: ./blog-cli.sh drafts"
  echo ""
  echo "  edit <slug>              Edit a draft by its slug"
  echo "                           Example: ./blog-cli.sh edit my-draft"
  echo ""
  echo "  publish <slug>           Publish a draft (move to posts/)"
  echo "                           Example: ./blog-cli.sh publish my-draft"
  echo ""
  echo "  check-links              Check for broken links in posts"
  echo "                           Example: ./blog-cli.sh check-links"
  echo ""
  echo "  stats                    Show blog statistics"
  echo "                           Example: ./blog-cli.sh stats"
  echo ""
  echo "  summary [YYYY-MM]        Generate monthly summary"
  echo "                           Example: ./blog-cli.sh summary 2026-01"
  echo ""
  echo "  find <keyword>           Search posts by keyword"
  echo "                           Example: ./blog-cli.sh find bash"
  echo ""
  echo "For more information, see README.md"
  echo ""
}

# ============================================
# GET THE COMMAND
# ============================================
# $1 is the first argument passed to this script
# This will be the command name (new, link, drafts, etc.)
command="$1"

# ============================================
# ROUTE TO THE APPROPRIATE SCRIPT
# ============================================
# The case statement is like a series of if/else statements
# It checks the value of $command and runs the matching block

case "$command" in
  # "new" command - create a new post
  new)
    # $2 is the second argument (the post title)
    # We pass it to the new-post.sh script using "$2"
    # The quotes preserve spaces in the title
    ./scripts/new-post.sh "$2"
    ;;
  
  # "link" command - create a link post
  link)
    # $2 is the URL, $3 is the optional description
    ./scripts/new-link-post.sh "$2" "$3"
    ;;
  
  # "drafts" command - list all drafts
  drafts)
    ./scripts/list-drafts.sh
    ;;
  
  # "edit" command - edit a draft
  edit)
    # $2 is the slug of the draft to edit
    ./scripts/edit-draft.sh "$2"
    ;;
  
  # "publish" command - publish a draft
  publish)
    # $2 is the slug of the draft to publish
    ./scripts/publish-draft.sh "$2"
    ;;
  
  # "check-links" command - check for broken links
  check-links)
    ./scripts/check-links.sh
    ;;
  
  # "stats" command - show blog statistics
  stats)
    ./scripts/post-stats.sh
    ;;
  
  # "summary" command - generate monthly summary
  summary)
    # $2 is the optional month (YYYY-MM format)
    ./scripts/generate-summary.sh "$2"
    ;;
  
  # "find" command - search posts
  find)
    # $2 is the keyword to search for
    ./scripts/find-post.sh "$2"
    ;;
  
  # Default case - if command doesn't match any above
  # This includes when no command is given, or an invalid command
  *)
    # Show the help message
    show_help
    
    # Exit with error code 1 if an invalid command was given
    # Exit code 0 means success, non-zero means error
    if [ -n "$command" ]; then
      echo "Error: Unknown command '$command'"
      exit 1
    fi
    ;;
esac

# If we got here, the command completed successfully
# Scripts exit with code 0 by default (success)
