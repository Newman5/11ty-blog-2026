# 11ty Blog 2026

A beginner-friendly 11ty blog starter with heavily-commented bash scripts for common blogging tasks. Perfect for learning bash scripting while building your blog!

## Features

- **Simple Bash Scripts**: Create posts, manage drafts, check for broken links, and more
- **Link Blog Support**: Special template for sharing interesting links with your commentary
- **Blog Statistics**: Track your writing habits with word counts and tag analytics
- **Beginner-Friendly Code**: Every script is extensively commented for learning
- **Modern Static Site**: Built with [11ty (Eleventy)](https://www.11ty.dev/), a powerful static site generator
- **Clean Templates**: Responsive Nunjucks templates with minimal, well-commented CSS

## Prerequisites

Before you begin, make sure you have:

- **Node.js** (version 14 or higher) - [Download from nodejs.org](https://nodejs.org/)
- **Basic command line knowledge** - You should know how to navigate directories and run commands
- **Text editor** - VS Code, vim, nano, or any editor you prefer
- **macOS or Linux** - Windows users can use Git Bash or WSL (Windows Subsystem for Linux)

## Installation

```bash
# Clone the repository
git clone https://github.com/Newman5/11ty-blog-2026.git
cd 11ty-blog-2026

# Install dependencies
npm install

# Make scripts executable (if not already)
chmod +x blog-cli.sh
chmod +x scripts/*.sh
```

## Quick Start

```bash
# Start the development server
npm start

# In another terminal, create your first post
./blog-cli.sh new "My First Post"

# View in browser at http://localhost:8080

# Build for production
npm run build
```

## Blog CLI Commands

The `blog-cli.sh` script is your main interface for managing the blog. Here are all the available commands:

### Creating a New Post

```bash
./blog-cli.sh new "My First Post"
```

**What this does:**
1. Creates a new file in `src/posts/` with today's date
2. Names it like: `2026-01-15-my-first-post.md`
3. Adds front matter (title, date, tags)
4. Opens it in your default editor

**Example output:**
```
✓ Created: src/posts/2026-01-15-my-first-post.md
Opening in vim...
```

You can then write your post in Markdown format. The file will look like:

```markdown
---
title: "My First Post"
date: 2026-01-15
tags:
  - blog
layout: post.njk
---

Write your content here...
```

### Creating a Link Post

```bash
./blog-cli.sh link https://example.com "Check this out!"
```

**What this does:**
1. Tries to fetch the page title from the URL
2. Creates a link post in `src/posts/`
3. Uses the link-post layout (title links to external URL)
4. Automatically tags it as "link" and "linkblog"
5. Opens it for you to add your commentary

**Use cases:**
- Sharing interesting articles you found
- Building a curated link blog
- Commenting on external resources

### Listing Drafts

```bash
./blog-cli.sh drafts
```

**What this does:**
1. Finds all `.md` files in `src/drafts/`
2. Extracts the title from each file
3. Counts words in each draft
4. Displays them in a readable format

**Example output:**
```
Draft Posts
===========

• My Work in Progress
  File: my-draft.md
  Words: 342

---
Total drafts: 1
```

### Editing a Draft

```bash
./blog-cli.sh edit my-draft
```

**What this does:**
1. Finds the draft file matching the slug
2. Opens it in your editor

**Tip:** Run `./blog-cli.sh drafts` first to see available draft slugs.

### Publishing a Draft

```bash
./blog-cli.sh publish my-draft
```

**What this does:**
1. Finds the draft file
2. Asks for confirmation
3. Updates the date to today
4. Moves the file from `src/drafts/` to `src/posts/`
5. Renames it with today's date

**Example output:**
```
Draft title: My Work in Progress
Draft file: src/drafts/my-draft.md

This will:
  1. Update the date to today
  2. Move the file to src/posts/

Publish this draft? (y/n): y

✓ Published: src/posts/2026-01-15-my-draft.md
```

### Checking for Broken Links

```bash
./blog-cli.sh check-links
```

**What this does:**
1. Searches for URLs in all posts and drafts
2. Tests each URL with curl to check if it's accessible
3. Reports HTTP status codes
4. Shows a summary of broken links

**Example output:**
```
Checking Links in Blog Posts
=============================

Checking links in: src/posts/2026-01-01-welcome.md

  Testing: https://example.com ... OK (200)
  Testing: https://broken-link.com ... BROKEN (404)

---
Summary:
  Total links checked: 2
  Broken links: 1
```

**When to use:**
- Before publishing your site
- Monthly maintenance checks
- After updating old posts

### Viewing Blog Statistics

```bash
./blog-cli.sh stats
```

**What this does:**
1. Counts total posts and drafts
2. Calculates total words and average per post
3. Shows posts grouped by year
4. Lists top 10 tags with counts
5. Shows your 5 most recent posts

**Example output:**
```
Blog Statistics
===============

Posts: 5
Drafts: 2

Total words: 3420
Average words per post: 684

Posts by Year:
---
  2026: 5 posts

Top 10 Tags:
---
  blog: 3 posts
  tutorial: 2 posts
  welcome: 1 posts

5 Most Recent Posts:
---
  2026-01-15 - My Latest Post
  2026-01-10 - Another Great Post
  2026-01-05 - Getting Started
```

### Generating a Monthly Summary

```bash
# Generate summary for current month
./blog-cli.sh summary

# Or specify a month
./blog-cli.sh summary 2026-01
```

**What this does:**
1. Finds all posts from the specified month
2. Creates a new summary post listing all posts
3. Includes word counts and tags for each post
4. Adds tag statistics for the month
5. Saves as a new post with today's date

**Use cases:**
- Monthly retrospectives
- Content planning and review
- Building a blog archive

### Searching Posts

```bash
./blog-cli.sh find bash
```

**What this does:**
1. Searches for the keyword in post titles and content
2. Shows matching posts with context
3. Displays line numbers where matches occur
4. Shows surrounding lines for context

**Example output:**
```
Searching for: bash
====================

Posts with 'bash' in title:
---
  [2026-01-05] Learning Bash Scripting
  File: src/posts/2026-01-05-learning-bash-scripting.md

Posts with 'bash' in content:
---
  Welcome to 11ty Blog 2026
  File: src/posts/2026-01-01-welcome.md
  Matches:
    45: All the scripts use bash for automation
    46: You can learn bash by reading the comments
```

### Getting Help

```bash
./blog-cli.sh
```

Running the CLI without a command shows the help message with all available commands and examples.

## Understanding the Scripts

This project is designed as a learning tool. All scripts use **simple, beginner-friendly bash patterns** with extensive comments.

### Where to Start

1. **`blog-cli.sh`** - Start here! It's the simplest script and shows how to route commands.
2. **`scripts/new-post.sh`** - Shows core patterns like variables, date formatting, and here documents.
3. **`scripts/list-drafts.sh`** - Demonstrates loops and text processing.
4. **Other scripts** - Explore these as you get comfortable with bash.

### Common Bash Patterns Used

#### Variables and Command Substitution

```bash
# Simple variable assignment
title="My Post"

# Command substitution - store command output in variable
date=$(date +%Y-%m-%d)
```

#### If Statements and Test Operators

```bash
# Check if variable is empty
if [ -z "$title" ]; then
  echo "Error: No title provided"
fi

# Check if file exists
if [ -e "$filename" ]; then
  echo "File exists"
fi
```

#### Loops

```bash
# Loop through files
for file in src/posts/*.md; do
  echo "Processing $file"
done

# While loop reading lines
while read -r line; do
  echo "$line"
done < input.txt
```

#### Here Documents

```bash
# Write multiple lines to a file
cat > file.md << EOF
Line 1
Line 2
Line 3
EOF
```

#### Pipes and Redirection

```bash
# Pipe output from one command to another
cat file.txt | grep "pattern"

# Redirect output to a file
echo "text" > file.txt

# Append to a file
echo "more text" >> file.txt
```

### Tips for Learning

- **Read the comments carefully** - They explain both WHAT the code does and WHY
- **Modify the scripts** - Try adding small features or changing behavior
- **Use ShellCheck** - Run `shellcheck script.sh` to find potential issues
- **Experiment** - It's hard to break anything! Use git to undo changes
- **Start simple** - Don't try to understand everything at once

### Learning Resources

- **Bash Academy**: https://www.bash.academy/ - Comprehensive bash tutorial
- **ShellCheck**: https://www.shellcheck.net/ - Online bash script linter
- **Explain Shell**: https://explainshell.com/ - Explains bash commands
- **11ty Documentation**: https://www.11ty.dev/docs/ - Learn about the static site generator
- **Markdown Guide**: https://www.markdownguide.org/ - Master markdown syntax

## Project Structure

```
.
├── .eleventy.js          # 11ty configuration (heavily commented)
├── .gitignore            # Files to ignore in git
├── package.json          # Node.js project configuration
├── blog-cli.sh           # Main CLI wrapper script
├── README.md             # This file
├── scripts/              # All helper scripts
│   ├── new-post.sh       # Create new blog posts
│   ├── new-link-post.sh  # Create link blog posts
│   ├── list-drafts.sh    # List draft posts
│   ├── edit-draft.sh     # Edit a draft
│   ├── publish-draft.sh  # Publish a draft
│   ├── check-links.sh    # Check for broken links
│   ├── post-stats.sh     # Show blog statistics
│   ├── generate-summary.sh # Generate monthly summaries
│   └── find-post.sh      # Search posts by keyword
├── src/                  # Source files for your site
│   ├── _includes/        # Nunjucks templates
│   │   ├── base.njk      # Base HTML layout
│   │   ├── post.njk      # Blog post template
│   │   └── link-post.njk # Link post template
│   ├── posts/            # Published blog posts
│   │   └── 2026-01-01-welcome.md
│   ├── drafts/           # Work-in-progress posts
│   │   └── .gitkeep      # Keeps directory in git
│   ├── index.njk         # Homepage
│   └── posts.njk         # Posts archive page
├── _site/                # Generated site (created by build)
└── node_modules/         # Dependencies (created by npm install)
```

### Directory Purposes

- **`src/`** - All your source files (posts, templates, pages)
- **`src/posts/`** - Published blog posts that appear on your site
- **`src/drafts/`** - Work-in-progress posts not yet published
- **`src/_includes/`** - Nunjucks templates used to build pages
- **`scripts/`** - Bash helper scripts for managing your blog
- **`_site/`** - The generated static site (don't edit files here)
- **`node_modules/`** - Node.js dependencies (don't commit to git)

### Key Files

- **`.eleventy.js`** - Configures how 11ty builds your site. Defines filters, collections, and paths.
- **`package.json`** - Node.js project file. Lists dependencies and scripts.
- **`blog-cli.sh`** - Main command interface. Routes commands to appropriate scripts.
- **`.gitignore`** - Tells git which files to ignore (build artifacts, dependencies).

### Front Matter

Posts use YAML front matter between `---` markers at the top of the file:

```markdown
---
title: "Post Title"       # Required: Post title
date: 2026-01-15         # Required: Publication date
tags:                     # Optional: Tags for categorization
  - tag1
  - tag2
layout: post.njk         # Required: Which template to use
---

Your post content here...
```

For link posts, add a `link:` field:

```markdown
---
title: "Interesting Article"
date: 2026-01-15
link: "https://example.com"
tags:
  - link
  - linkblog
layout: link-post.njk
---

Your commentary here...
```

## Common Workflows

### Writing a Standard Blog Post

1. **Create the post:**
   ```bash
   ./blog-cli.sh new "My Blog Post Title"
   ```

2. **Write your content** in the opened editor using Markdown

3. **Preview locally:**
   ```bash
   npm start
   # Visit http://localhost:8080
   ```

4. **Commit and deploy:**
   ```bash
   git add .
   git commit -m "Add new post"
   git push
   ```

### Creating a Link Post

1. **Find an interesting link** you want to share

2. **Create the link post:**
   ```bash
   ./blog-cli.sh link https://example.com "Brief description"
   ```

3. **Add your commentary** in the opened editor

4. **Preview and publish** as above

### Working with Drafts

1. **Start a post as a draft** by saving it in `src/drafts/` instead of `src/posts/`

2. **Work on it over time:**
   ```bash
   ./blog-cli.sh edit my-draft
   ```

3. **Check your drafts:**
   ```bash
   ./blog-cli.sh drafts
   ```

4. **Publish when ready:**
   ```bash
   ./blog-cli.sh publish my-draft
   ```

### Monthly Maintenance

1. **Check for broken links:**
   ```bash
   ./blog-cli.sh check-links
   ```

2. **Review statistics:**
   ```bash
   ./blog-cli.sh stats
   ```

3. **Generate monthly summary:**
   ```bash
   ./blog-cli.sh summary 2026-01
   ```

4. **Update old posts** if needed and refresh broken links

## Customization Ideas

Want to extend your blog? Here are some ideas:

### Add New Post Types

Create templates for specific content types:
- Book reviews
- Weekly notes
- Project updates
- Photo posts

### Create Custom Scripts

Add new scripts to the `scripts/` directory:
- **backup.sh** - Backup posts to another location
- **image-resize.sh** - Automatically resize images
- **tweet-post.sh** - Share new posts on social media
- **deploy.sh** - Automated deployment script

### Modify Templates

Customize the Nunjucks templates:
- Add comments section
- Include related posts
- Add author bio
- Create tag archive pages
- Add RSS feed

### Extend Front Matter

Add custom fields to your front matter:
- `author:` for multi-author blogs
- `featured: true` for highlighting posts
- `image:` for post thumbnails
- `description:` for SEO meta descriptions

### Integrate External Services

Connect your blog to:
- Analytics (Google Analytics, Plausible)
- Comments (Disqus, utterances)
- Newsletter (Mailchimp, Buttondown)
- Search (Algolia, Lunr.js)

## Troubleshooting

### Permission Denied Errors

If you get "permission denied" when running scripts:

```bash
chmod +x blog-cli.sh scripts/*.sh
```

This makes the scripts executable.

### Editor Not Opening

Scripts try to open files in your default editor. Set your preferred editor:

```bash
# Temporarily for this session
export EDITOR=nano

# Or add to ~/.bashrc or ~/.zshrc to make permanent
echo 'export EDITOR=nano' >> ~/.bashrc
```

Popular editor options:
- `nano` - Simple, beginner-friendly
- `vim` - Powerful but steep learning curve
- `code` - Visual Studio Code
- `subl` - Sublime Text

### Node/NPM Issues

**Problem:** `npm install` fails or `npm start` doesn't work

**Solutions:**
1. Make sure Node.js is installed: `node --version`
2. Try deleting `node_modules` and reinstalling:
   ```bash
   rm -rf node_modules
   npm install
   ```
3. Clear npm cache: `npm cache clean --force`
4. Update npm: `npm install -g npm@latest`

### Port Already in Use

**Problem:** Error says port 8080 is already in use

**Solutions:**
1. Kill the process using the port
2. Or use a different port:
   ```bash
   npx @11ty/eleventy --serve --port=3000
   ```

### Scripts Not Finding Files

**Problem:** Scripts can't find posts or drafts

**Solutions:**
1. Make sure you're in the project root directory
2. Check that files are in the correct directories:
   - Published posts go in `src/posts/`
   - Drafts go in `src/drafts/`
3. Verify filenames end with `.md`

### Date Command Differences (macOS vs Linux)

Some scripts use the `date` command, which works differently on macOS and Linux.

**If you see date-related errors on macOS:**
- The scripts include fallback options for macOS
- Make sure you have the latest version of bash

## Tips for Success

### For Writing

- **Write regularly** - Even short posts build momentum
- **Use drafts** - Don't pressure yourself to publish immediately
- **Tag consistently** - Helps readers find related content
- **Check stats** - Track your progress and patterns

### For Learning

- **Start with `blog-cli.sh`** - It's the simplest script
- **Then read `scripts/new-post.sh`** - Shows core patterns
- **Try modifying a script** - Add a small feature
- **Use `shellcheck`** - Validates your bash scripts
- **Read comments carefully** - They explain the "why"
- **Experiment!** - It's hard to break anything permanently
- **Use git** - Commit often so you can undo changes

### For Code Quality

- **Run ShellCheck** on your scripts:
  ```bash
  shellcheck blog-cli.sh
  shellcheck scripts/*.sh
  ```
- **Test changes** before committing
- **Keep scripts simple** - Favor readability over cleverness
- **Add comments** when you modify scripts

## Contributing

This is a learning project - contributions are welcome!

### Guidelines

- **Keep scripts simple** - Use beginner-friendly bash patterns
- **Add extensive comments** - Explain what the code does AND why
- **Include examples** in README for new features
- **Test on both macOS and Linux** if possible
- **Follow the existing style** - Consistency helps learners

### How to Contribute

1. Fork the repository
2. Create a feature branch: `git checkout -b my-feature`
3. Make your changes
4. Test thoroughly
5. Commit with clear messages: `git commit -m "Add feature X"`
6. Push to your fork: `git push origin my-feature`
7. Open a pull request

## License

MIT License - Feel free to use this for your own blog!

## Acknowledgments

- Built with [11ty (Eleventy)](https://www.11ty.dev/)
- Inspired by the need for beginner-friendly bash examples
- Thanks to the static site and IndieWeb communities

---

**Happy blogging and happy learning!** 🚀

If you have questions or suggestions, please open an issue on GitHub.
