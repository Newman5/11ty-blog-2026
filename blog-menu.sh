#!/bin/bash
# Script Name: blog-cli.sh
# Purpose: Interactive command-line interface for managing blog posts
# Usage: ./blog-cli.sh [command] [arguments]
#
# This is the main entry point for all blog commands.
# It can be run interactively (menu mode) or with direct commands.

# ============================================
# SETUP - Change to script directory
# ============================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ============================================
# COLOR VARIABLES
# ============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ============================================
# HELPER FUNCTIONS
# ============================================

clear_screen() {
  clear
}

show_header() {
  clear_screen
  echo -e "${CYAN}${BOLD}"
  echo "╔════════════════════════════════════════════════════╗"
  echo "║        📝 11ty Blog CLI Dashboard 📝              ║"
  echo "╚════════════════════════════════════════════════════╝"
  echo -e "${RESET}"
}

handle_error() {
  local exit_code=$1
  if [ $exit_code -ne 0 ]; then
    echo ""
    echo -e "${RED}❌ Command failed with error code $exit_code${RESET}"
    echo ""
    echo -e "${YELLOW}What would you like to do?${RESET}"
    echo "  1) Try again"
    echo "  2) Return to main menu"
    echo ""
    read -p "Enter your choice (1-2): " retry_choice
    
    case $retry_choice in
      1)
        return 1
        ;;
      2)
        return 0
        ;;
      *)
        echo -e "${RED}Invalid choice. Returning to menu.${RESET}"
        sleep 1
        return 0
        ;;
    esac
  fi
  return 0
}

pause_for_user() {
  echo ""
  echo -e "${CYAN}Press Enter to continue...${RESET}"
  read
}

# ============================================
# COMMAND EXECUTION FUNCTIONS
# ============================================

execute_new_post() {
  while true; do
    echo -e "${BOLD}Create New Blog Post${RESET}"
    echo ""
    read -p "Enter post title: " post_title
    if [ -z "$post_title" ]; then
      echo -e "${RED}Title cannot be empty!${RESET}"
      sleep 1
      return
    fi
    read -p "Create as draft? (y/n): " create_draft
    draft_flag=""
    if [ "$create_draft" = "y" ] || [ "$create_draft" = "Y" ]; then
      draft_flag="--draft"
    fi
    ./scripts/new-post.sh "$post_title" $draft_flag
    handle_error $? || continue
    break
  done
  pause_for_user
}

execute_new_link() {
  while true; do
    echo -e "${BOLD}Create Link Blog Post${RESET}"
    echo ""
    read -p "Enter URL: " link_url
    if [ -z "$link_url" ]; then
      echo -e "${RED}URL cannot be empty!${RESET}"
      sleep 1
      return
    fi
    read -p "Enter description (optional): " link_desc
    ./scripts/new-link-post.sh "$link_url" "$link_desc"
    handle_error $? || continue
    break
  done
  pause_for_user
}

execute_list_drafts() {
  while true; do
    echo -e "${BOLD}Draft Posts${RESET}"
    echo ""
    ./scripts/list-drafts.sh
    handle_error $? || continue
    break
  done
  pause_for_user
}

execute_edit_draft() {
  while true; do
    echo -e "${BOLD}Edit Draft${RESET}"
    echo ""
    read -p "Enter draft slug: " draft_slug
    if [ -z "$draft_slug" ]; then
      echo -e "${RED}Slug cannot be empty!${RESET}"
      sleep 1
      return
    fi
    ./scripts/edit-draft.sh "$draft_slug"
    handle_error $? || continue
    break
  done
  pause_for_user
}

execute_publish_draft() {
  while true; do
    echo -e "${BOLD}Publish Draft${RESET}"
    echo ""
    read -p "Enter draft slug: " draft_slug
    if [ -z "$draft_slug" ]; then
      echo -e "${RED}Slug cannot be empty!${RESET}"
      sleep 1
      return
    fi
    ./scripts/publish-draft.sh "$draft_slug"
    handle_error $? || continue
    break
  done
  pause_for_user
}

execute_check_links() {
  while true; do
    echo -e "${BOLD}Check for Broken Links${RESET}"
    echo ""
    ./scripts/check-links.sh
    handle_error $? || continue
    break
  done
  pause_for_user
}

execute_stats() {
  while true; do
    echo -e "${BOLD}Blog Statistics${RESET}"
    echo ""
    ./scripts/post-stats.sh
    handle_error $? || continue
    break
  done
  pause_for_user
}

execute_summary() {
  while true; do
    echo -e "${BOLD}Generate Monthly Summary${RESET}"
    echo ""
    read -p "Enter month (YYYY-MM) or press Enter for current month: " month_input
    ./scripts/generate-summary.sh "$month_input"
    handle_error $? || continue
    break
  done
  pause_for_user
}

execute_find() {
  while true; do
    echo -e "${BOLD}Search Posts${RESET}"
    echo ""
    read -p "Enter keyword to search: " keyword
    if [ -z "$keyword" ]; then
      echo -e "${RED}Keyword cannot be empty!${RESET}"
      sleep 1
      return
    fi
    ./scripts/find-post.sh "$keyword"
    handle_error $? || continue
    break
  done
  pause_for_user
}

execute_build() {
  while true; do
    echo -e "${BOLD}Build Site${RESET}"
    echo ""
    (npm run build)
    handle_error $? || continue
    break
  done
  pause_for_user
}

execute_dev() {
  echo -e "${BOLD}Start Development Server${RESET}"
  echo ""
  echo -e "${YELLOW}Starting dev server... Press Ctrl+C to stop.${RESET}"
  echo ""
  (npm start)
  pause_for_user
}

execute_deploy() {
  while true; do
    echo -e "${BOLD}Deploy to Production${RESET}"
    echo ""
    echo -e "${YELLOW}This will deploy your site. Are you sure? (y/n)${RESET}"
    read -p "> " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
      echo -e "${CYAN}Deployment cancelled.${RESET}"
      sleep 1
      return
    fi
    echo "Deploy command not configured yet"
    # (cd blog && npm run deploy)
    handle_error $? || continue
    break
  done
  pause_for_user
}

execute_tests() {
  while true; do
    echo -e "${BOLD}Run Blog Smoke Tests${RESET}"
    echo ""
    ./scripts/test-blog.sh
    handle_error $? || continue
    break
  done
  pause_for_user
}

execute_import_days() {
  while true; do
    echo -e "${BOLD}Import Day Files as Posts${RESET}"
    echo ""
    ./scripts/import-day-files.sh
    handle_error $? || continue
    break
  done
  pause_for_user
}

# ============================================
# INTERACTIVE MENU
# ============================================

show_menu() {
  show_header
  echo -e "${GREEN}${BOLD}📄 CONTENT MANAGEMENT${RESET}"
  echo "  1) ✍️  Create new blog post"
  echo "  2) 🔗 Create link post"
  echo "  3) 📋 List drafts"
  echo "  4) ✏️  Edit draft"
  echo "  5) 🚀 Publish draft"
  echo ""
  echo -e "${BLUE}${BOLD}🔧 UTILITIES${RESET}"
  echo "  6) 🔍 Find posts by keyword"
  echo "  7) 🔗 Check for broken links"
  echo "  8) 📊 Show blog statistics"
  echo "  9) 📅 Generate monthly summary"
  echo "  14) 📥 Import Day files as posts"
  echo ""
  echo -e "${MAGENTA}${BOLD}🏗️  BUILD & DEPLOY${RESET}"
  echo "  10) 🔨 Build site"
  echo "  11) 🖥️  Start dev server"
  echo "  12) 🌐 Deploy to production"
  echo ""
  echo -e "${CYAN}${BOLD}🧪 TESTING${RESET}"
  echo "  13) ✅ Run blog smoke tests"
  echo ""
  echo -e "${YELLOW}${BOLD}OTHER${RESET}"
  echo "  0) 👋 Exit"
  echo ""
  echo -e "${CYAN}════════════════════════════════════════════════════${RESET}"
}

interactive_menu() {
  while true; do
    show_menu
    read -p "Enter your choice (0-14): " choice
    echo ""
    
    case $choice in
      1) execute_new_post ;;
      2) execute_new_link ;;
      3) execute_list_drafts ;;
      4) execute_edit_draft ;;
      5) execute_publish_draft ;;
      6) execute_find ;;
      7) execute_check_links ;;
      8) execute_stats ;;
      9) execute_summary ;;
      10) execute_build ;;
      11) execute_dev ;;
      12) execute_deploy ;;
      13) execute_tests ;;
      14) execute_import_days ;;
      0)
        echo -e "${GREEN}👋 Goodbye!${RESET}"
        exit 0
        ;;
      *)
        echo -e "${RED}Invalid choice. Please enter a number between 0-14.${RESET}"
        sleep 2
        ;;
    esac
  done
}

# ============================================
# COMMAND LINE MODE
# ============================================

show_help() {
  echo ""
  echo "11ty Blog CLI - Beginner-Friendly Blog Management"
  echo "=================================================="
  echo ""
  echo "Usage: ./blog-cli.sh [command] [arguments]"
  echo ""
  echo "Interactive Mode:"
  echo "  Run without arguments to launch interactive menu"
  echo ""
  echo "Direct Commands:"
  echo "  new <title> [--draft]    Create a new blog post (optionally as draft)"
  echo "  link <url> [description] Create a link blog post"
  echo "  drafts                   List all draft posts"
  echo "  edit <slug>              Edit a draft by its slug"
  echo "  publish <slug>           Publish a draft (move to posts/)"
  echo "  check-links              Check for broken links in posts"
  echo "  stats                    Show blog statistics"
  echo "  summary [YYYY-MM]        Generate monthly summary"
  echo "  find <keyword>           Search posts by keyword"
  echo "  import-days              Import Day .txt files as posts"
  echo "  build                    Build the site"
  echo "  dev                      Start development server"
  echo "  deploy                   Deploy to production"
  echo "  test                     Run blog smoke tests"
  echo ""
}

# ============================================
# MAIN EXECUTION
# ============================================

command="$1"

if [ -z "$command" ]; then
  interactive_menu
else
  case "$command" in
    new) ./scripts/new-post.sh "${@:2}" ;;
    link) ./scripts/new-link-post.sh "${@:2}" ;;
    drafts) ./scripts/list-drafts.sh ;;
    edit) ./scripts/edit-draft.sh "$2" ;;
    publish) ./scripts/publish-draft.sh "$2" ;;
    check-links) ./scripts/check-links.sh ;;
    stats) ./scripts/post-stats.sh ;;
    summary) ./scripts/generate-summary.sh "$2" ;;
    find) ./scripts/find-post.sh "$2" ;;
    import-days) ./scripts/import-day-files.sh ;;
    build) (npm run build) ;;
    dev) (npm start) ;;
    deploy) echo "Deploy command not configured yet" ;;
    test) ./scripts/test-blog.sh ;;
    --help|-h|help) show_help ;;
    *)
      echo "Error: Unknown command '$command'"
      echo ""
      show_help
      exit 1
      ;;
  esac
fi
