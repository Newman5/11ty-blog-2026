# Create 11ty Blog with Beginner-Friendly Bash Scripts

Create a pull request for the repository **Newman5/11ty-blog-2026** that sets up a complete 11ty blog starter with beginner-friendly, heavily-commented bash scripts for common blogging tasks.

## Important Context

**This is a learning template repository. ** All bash scripts must use SIMPLE, BEGINNER-FRIENDLY patterns with extensive comments explaining what the code does and why. Avoid complex bash features - keep everything straightforward for people learning bash scripting.

## What to Create

### 1. 11ty Setup
- `package.json` with 11ty dependency and npm scripts (start, build)
- `.eleventy.js` configuration file (HEAVILY COMMENTED for learners)
- `.gitignore` (node_modules, _site, .DS_Store, *.log)

### 2. Directory Structure

```
.
├── package.json
├── .eleventy. js
├── .gitignore
├── README.md
├── blog-cli.sh (main CLI wrapper)
├── scripts/
│   ├── new-post.sh
│   ├── new-link-post.sh
│   ├── list-drafts.sh
│   ├── edit-draft.sh
│   ├── publish-draft.sh
│   ├── check-links. sh
│   ├── post-stats.sh
│   ├── generate-summary.sh
│   └── find-post. sh
├── src/
│   ├── _includes/
│   │   ├── base.njk
│   │   ├── post.njk
│   │   └── link-post.njk
│   ├── posts/
│   │   └── 2026-01-01-welcome.md
│   ├── drafts/
│   │   └── .gitkeep
│   ├── index.njk
│   └── posts.njk
```

### 3. Bash Scripting Guidelines (CRITICAL)

**Use ONLY beginner-friendly patterns:**
- Simple, clear variable names (lowercase with underscores)
- NO complex bash features (no arrays, no advanced parameter expansions)
- Use straightforward if/else with `[ ]` test operators
- NO functions or keep them very simple
- Clear, verbose commands (no clever one-liners)
- EXTENSIVE COMMENTS explaining WHAT and WHY
- Show usage examples in script comments

**Example of the commenting style to use:**

```bash
#!/bin/bash
# Script Name: new-post.sh
# Purpose: Creates a new blog post with front matter
# Usage: ./new-post.sh "My Post Title"

# Get the title from the command line (first argument)
title="$1"

# Check if the user provided a title
# -z tests if the variable is empty
if [ -z "$title" ]; then
  echo "Error: Please provide a title"
  echo "Usage: $0 <title>"
  exit 1
fi

# Get today's date in YYYY-MM-DD format
# The +%Y-%m-%d tells date how to format the output
date=$(date +%Y-%m-%d)

# Create a URL-friendly slug from the title
# tr converts uppercase to lowercase, then spaces to hyphens
slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Build the complete filename with path
filename="src/posts/${date}-${slug}.md"

# Create the file with front matter using a "here document"
# Everything between << EOF and EOF goes into the file
cat > "$filename" << EOF
---
title:  "$title"
date: $date
tags: 
  - blog
---

Write your content here... 
EOF

echo "Created: $filename"

# Open the file in the user's preferred editor
# ${EDITOR:-vim} means "use $EDITOR if set, otherwise use vim"
${EDITOR:-vim} "$filename"
```

### 4. Script Descriptions

#### blog-cli.sh - Main command router
- Use simple case statement
- Routes to appropriate scripts in scripts/ directory
- Shows help with all commands and examples
- Heavily commented explaining how case statements work

#### scripts/new-post.sh - Create new blog post
- Accept title as argument
- Generate date-based filename (YYYY-MM-DD-slug. md)
- Create markdown file with front matter (title, date, tags)
- Open in editor
- Comment every step for learners

#### scripts/new-link-post.sh - Create link blog post
- Accept URL and optional description as arguments
- Try to fetch page title with curl (explain curl command)
- Create post with "link:" field in front matter
- Use link-post layout
- Auto-tag as "link" and "linkblog"
- Comment the curl/grep/sed commands for learners

#### scripts/list-drafts.sh - List all drafts
- Find all .md files in src/drafts/
- Extract title from front matter (explain grep/cut)
- Show word count with wc
- Simple for loop with extensive comments
- Handle case when no drafts exist

#### scripts/edit-draft.sh - Edit a draft
- Accept slug as argument
- Find and open draft file in editor
- Simple error checking if file doesn't exist
- Comment the test operators

#### scripts/publish-draft.sh - Move draft to posts
- Accept slug as argument
- Ask for user confirmation (explain read command)
- Move file from drafts/ to posts/
- Update date in front matter to today (explain sed command)
- Comment each step

#### scripts/check-links. sh - Find broken links
- Search for URLs in all markdown files (posts and drafts)
- Use curl to check HTTP status of each link (explain curl options)
- Report broken links (400+, timeouts)
- Skip relative links (/) and anchors (#)
- Count broken links with simple counter variable
- Show summary at end

#### scripts/post-stats.sh - Show blog statistics
- Count total posts and drafts (explain find and wc)
- Calculate total words and average per post (explain $((math)))
- Show posts grouped by year
- Show top 10 tags with counts
- List 5 most recent posts with dates
- Build up from simple to complex with comments explaining each section

#### scripts/generate-summary. sh - Generate monthly summary
- Accept month parameter in YYYY-MM format, default to current month
- Find all posts from that month
- Generate a new summary post listing all posts from that month
- Include tag statistics for the month
- Create in posts/ directory with current date
- Explain date formatting and manipulation

#### scripts/find-post.sh - Search posts by keyword
- Accept keyword as argument
- Use grep to search in post titles and content (explain grep options:  -i, -l, -H)
- Show matching posts with context
- Display results in readable format

### 5. Templates (Nunjucks)

#### src/_includes/base.njk - Base HTML layout
- Clean HTML5 structure with DOCTYPE
- Minimal inline CSS (commented explaining styles)
- Header with site title and navigation
- Footer with build date using 11ty variable
- Main content block
- Add comments explaining Nunjucks syntax (blocks, extends)

#### src/_includes/post. njk - Blog post template
- Extends base.njk
- Display post title as h1
- Show formatted date
- Display tags as links
- Render markdown content
- Add "Back to posts" link
- Comment template inheritance

#### src/_includes/link-post.njk - Link post template
- Similar to post. njk but title links to external URL
- Show arrow symbol (→) to indicate external link
- Display description/commentary below
- Different visual styling (maybe italics or blockquote for external content)
- Comment the differences from regular posts

#### src/index.njk - Homepage
- List 10 most recent posts (use collections. posts)
- Show title (linked), date, excerpt
- Link to full posts archive
- Add comments explaining 11ty collections

#### src/posts.njk - Posts archive page
- List ALL posts grouped by year
- Show title and date for each
- Clean, scannable layout
- Comment the grouping logic

### 6. README.md (Comprehensive Learning Guide)

Create a detailed, beginner-friendly README with these sections:

#### Introduction
- What this project is (11ty blog + bash scripts)
- Key features list
- Target audience:  beginners learning bash scripting and static sites
- Philosophy: Simple, commented, learning-focused

#### Prerequisites
- Node.js installed (link to nodejs.org)
- Basic command line knowledge
- Text editor (VS Code, vim, nano, etc.)
- macOS or Linux (Windows users can use Git Bash or WSL)

#### Installation

```bash
# Clone the repository
git clone https://github.com/Newman5/11ty-blog-2026.git
cd 11ty-blog-2026

# Install dependencies
npm install

# Make scripts executable
chmod +x blog-cli.sh
chmod +x scripts/*.sh
```

#### Quick Start

```bash
# Start the development server
npm start

# In another terminal, create your first post
./blog-cli.sh new "My First Post"

# View in browser at http://localhost:8080

# Build for production
npm run build
```

#### Blog CLI Commands

Document ALL commands with:
- Clear description
- Usage syntax
- Complete example with actual command
- Explanation of what happens when you run it
- Common use cases

**Example format:**

```
### Creating a New Post

./blog-cli.sh new "My First Post"

This command will:
1. Create a new file in src/posts/
2. Name it with today's date:  2026-01-01-my-first-post.md
3. Add front matter with title and date
4. Open it in your default editor

You can then write your post in Markdown format. 
```

Do this for ALL commands:  new, link, drafts, edit-draft, publish, check-links, stats, summary, find

#### Understanding the Scripts

- Brief introduction to bash scripting
- How to read the commented code
- Suggest starting with blog-cli.sh, then new-post.sh
- Explain common bash patterns used: 
  - Variables and command substitution
  - If statements and test operators
  - Loops (for, while)
  - Here documents (<<EOF)
  - Pipes and redirection
- Encourage users to modify and experiment with scripts
- Link to bash learning resources (bash.academy, shellcheck.net)

#### Project Structure Explained

Explain each directory and its purpose: 
- `src/` - Source files for the site
- `src/posts/` - Published blog posts
- `src/drafts/` - Work-in-progress posts
- `src/_includes/` - Nunjucks templates
- `scripts/` - Bash helper scripts
- `_site/` - Generated site (created by build)
- `node_modules/` - Dependencies (created by npm install)

Explain key files:
- `.eleventy.js` - 11ty configuration
- `package.json` - Node.js project file
- `blog-cli.sh` - Main command interface

Explain front matter and what fields mean

#### Common Workflows

Provide step-by-step workflows for: 

1. **Writing a Standard Blog Post**
   - Run new command
   - Write in markdown
   - Preview locally
   - Commit and deploy

2. **Creating a Link Post**
   - Find interesting link
   - Run link command
   - Add your commentary
   - Publish

3. **Working with Drafts**
   - Create post in drafts
   - Work on it over time
   - Check drafts list
   - Publish when ready

4. **Monthly Maintenance**
   - Check for broken links
   - Review stats
   - Generate monthly summary
   - Update and refresh old posts

#### Customization Ideas

Give users ideas for extending the blog:
- Add new post types (book reviews, weekly notes)
- Create custom scripts (backup, image processing)
- Modify templates (add comments, related posts)
- Add new front matter fields
- Integrate with external services

#### Troubleshooting

Common issues and solutions: 

**Permission Denied Errors**
```bash
# If you get "permission denied" when running scripts: 
chmod +x blog-cli.sh scripts/*.sh
```

**Editor Not Opening**
```bash
# Set your preferred editor: 
export EDITOR=nano
# Or add to ~/.bashrc or ~/.zshrc to make permanent
```

**Node/NPM Issues**
- Ensure Node.js is installed
- Try deleting node_modules and running npm install again

**Port Already in Use**
- Kill process on port 8080 or use:  npx @11ty/eleventy --serve --port=3000

#### Tips for Learning

- Start by reading `blog-cli.sh` - it's the simplest
- Then read `scripts/new-post.sh` - it shows core patterns
- Try modifying a script to add a small feature
- Use `shellcheck` to validate your bash scripts
- Read the comments carefully - they explain the "why"
- Experiment!  It's hard to break anything permanently
- Use version control (git) so you can undo changes

#### Learning Resources

- Bash:  https://www.bash.academy/
- ShellCheck (linter): https://www.shellcheck.net/
- 11ty Documentation: https://www.11ty.dev/docs/
- Nunjucks Templating: https://mozilla.github.io/nunjucks/
- Markdown Guide: https://www.markdownguide.org/

#### Contributing

- This is a learning project - contributions welcome!
- Keep scripts simple and well-commented
- Add examples to README for new features
- Test on both macOS and Linux

#### License

MIT License (or your choice)

### 7. Example Content

Create **src/posts/2026-01-01-welcome.md** with: 

```markdown
---
title: "Welcome to 11ty Blog 2026"
date: 2026-01-01
tags:  
  - welcome
  - tutorial
  - meta
---

Welcome to your new 11ty blog! This is a learning-focused blog starter that includes helpful bash scripts to make blogging easier and teach you bash scripting along the way.

## Features

This blog includes: 

- **Simple Bash Scripts**:  Create posts, manage drafts, check for broken links
- **Link Blog Support**: Special template for sharing interesting links with commentary
- **Blog Statistics**: Track your writing habits and output
- **Beginner-Friendly Code**: Every script is heavily commented for learning
- **Modern Static Site**: Built with 11ty (Eleventy), one of the best static site generators

## Quick Start

Try these commands to get started:

\`\`\`bash
# Create your first post
./blog-cli. sh new "My First Post"

# Create a link post
./blog-cli.sh link https://example.com "Check this out!"

# See all available commands
./blog-cli.sh

# View your blog statistics
./blog-cli.sh stats
\`\`\`

## Learning Bash Scripting

All the scripts in the `scripts/` directory are written with beginners in mind. They use simple, clear patterns and include extensive comments. 

Start by reading these files in order:
1. `blog-cli.sh` - The main command router (simplest)
2. `scripts/new-post.sh` - Creates blog posts (shows core patterns)
3. `scripts/list-drafts.sh` - Lists drafts (shows loops and text processing)

Then explore the others as you get comfortable! 

## Writing in Markdown

This blog uses Markdown for writing.  Here are some examples:

**Bold text** with `**Bold text**`
*Italic text* with `*Italic text*`

### Headings

Use # for headings (more # = smaller heading)

### Links

[Link text](https://example.com)

### Lists

- Item one
- Item two
- Item three

### Code

Inline `code` with backticks, or code blocks with triple backticks: 

\`\`\`javascript
console.log("Hello, world!");
\`\`\`

## Next Steps

1. Read the README. md for full documentation
2. Create your first post
3. Explore and modify the scripts
4. Make this blog your own!

Happy blogging and happy learning! 🚀
```

### 8. Configuration Files

#### . eleventy.js - HEAVILY COMMENTED

```javascript
// Eleventy Configuration File
// This file tells Eleventy how to build your site

module.exports = function(eleventyConfig) {
  
  // ========================================
  // FILTERS
  // ========================================
  // Filters let you transform data in templates
  // Usage in templates: {{ date | readableDate }}
  
  // Make dates readable (turns ISO date into "January 1, 2026")
  eleventyConfig.addFilter("readableDate", dateObj => {
    return new Date(dateObj).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  });
  
  // Create an excerpt from post content (first 200 characters)
  eleventyConfig.addFilter("excerpt", content => {
    const excerpt = content.replace(/(<([^>]+)>)/gi, ""); // Remove HTML tags
    return excerpt.substr(0, 200) + (excerpt.length > 200 ?  "..." : "");
  });
  
  // ========================================
  // COLLECTIONS
  // ========================================
  // Collections are groups of content
  // This creates a "posts" collection from all files in src/posts/
  
  eleventyConfig.addCollection("posts", function(collectionApi) {
    return collectionApi.getFilteredByGlob("src/posts/*.md")
      .sort((a, b) => b.date - a.date); // Sort by date, newest first
  });
  
  // ========================================
  // PASSTHROUGH COPY
  // ========================================
  // Copy these files directly to output without processing
  // Uncomment if you add CSS, images, etc. 
  
  // eleventyConfig.addPassthroughCopy("src/css");
  // eleventyConfig.addPassthroughCopy("src/images");
  
  // ========================================
  // CONFIGURATION
  // ========================================
  // Tell Eleventy where to find files and where to output
  
  return {
    // Where to look for source files
    dir: {
      input: "src",           // Read files from src/
      includes: "_includes",  // Templates are in src/_includes/
      output: "_site"         // Built site goes to _site/
    },
    
    // What template languages to use
    templateFormats:  ["md", "njk", "html"],
    
    // Use Nunjucks for markdown files too
    markdownTemplateEngine:  "njk",
    htmlTemplateEngine: "njk"
  };
};
```

#### package.json

```json
{
  "name": "11ty-blog-2026",
  "version": "1.0.0",
  "description": "Beginner-friendly 11ty blog with bash script helpers for common blogging tasks",
  "main":  ". eleventy.js",
  "scripts": {
    "start":  "eleventy --serve",
    "build": "eleventy"
  },
  "keywords":  ["blog", "11ty", "eleventy", "bash", "static-site", "learning"],
  "author": "Newman5",
  "license": "MIT",
  "dependencies": {
    "@11ty/eleventy": "^2.0.0"
  }
}
```

#### . gitignore

```
# Node.js dependencies
node_modules/

# Built site output
_site/

# Mac OS files
.DS_Store

# Log files
*.log
npm-debug.log*

# Editor files
. vscode/
. idea/
*.swp
*. swo
*~

# OS files
Thumbs.db
```

### 9. File Permissions

Ensure these files are created as executable (chmod +x):
- blog-cli.sh
- scripts/new-post.sh
- scripts/new-link-post.sh
- scripts/list-drafts.sh
- scripts/edit-draft. sh
- scripts/publish-draft.sh
- scripts/check-links.sh
- scripts/post-stats.sh
- scripts/generate-summary.sh
- scripts/find-post.sh

## Success Criteria

After this PR is merged and a user follows the README, they should be able to:

1. ✅ Clone and run `npm install` successfully
2. ✅ Run `npm start` and see the site at localhost:8080
3. ✅ Create a new post with `./blog-cli.sh new "Test"`
4. ✅ See the post appear on the site
5. ✅ Read any script and understand what it does
6. ✅ Modify a script to add a small feature
7. ✅ Create their own simple script based on the examples
8. ✅ Use all the blogging features effectively

## Key Principles

1. **Simplicity over cleverness** - Use basic bash patterns only, no advanced features
2. **Comments everywhere** - Almost every line should have explanation for learners
3. **Learning first** - The code is a teaching tool, not just a working blog
4. **Consistent style** - Same commenting and coding patterns across all scripts
5. **Clear errors** - Error messages should explain what went wrong and how to fix it
6. **Progressive complexity** - Start with simple scripts, build to more complex
7. **Real-world use** - Everything should actually work for blogging

## Final Notes

- All scripts should work on macOS and Linux (bash 3.2+)
- Test that all commands in the README actually work
- Ensure the site builds and serves without errors
- Make sure example post displays correctly
- Verify all scripts are executable
- Check that comments are accurate and helpful

This is a **TEMPLATE REPOSITORY for learners**. Make it exemplary for teaching bash scripting and modern static site development!  🎓