// Eleventy Configuration File
// This file tells Eleventy how to build your site
// Using ES6 module syntax for Eleventy 3.x

// Import the RSS plugin to generate RSS/Atom feeds
// This allows readers to subscribe to your blog in their favorite feed reader
import { feedPlugin } from "@11ty/eleventy-plugin-rss";

/** @param {import("@11ty/eleventy").UserConfig} eleventyConfig */
export default function(eleventyConfig) {
  
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
    return excerpt.substring(0, 200) + (excerpt.length > 200 ? "..." : "");
  });
  
  // Format dates in various ways
  // This filter can format dates like "2026" or "Jan 15"
  eleventyConfig.addFilter("date", (dateObj, format) => {
    const date = new Date(dateObj);
    
    // Format options based on the requested format
    if (format === 'YYYY') {
      return date.getFullYear().toString();
    } else if (format === 'MMM DD') {
      return date.toLocaleDateString('en-US', { month: 'short', day: '2-digit' });
    }
    
    // Default: return ISO date string
    return date.toISOString();
  });
  
  // Get the first `n` elements of a collection
  // This filter is used to limit the number of posts shown
  // Example: collections.posts | head(10) shows only 10 posts
  // Negative numbers work from the end: head(-3) gets last 3 items
  // Pattern from official eleventy-base-blog
  eleventyConfig.addFilter("head", (array, n) => {
    if(!Array.isArray(array) || array.length === 0) {
      return [];
    }
    if( n < 0 ) {
      return array.slice(n);
    }
    return array.slice(0, n);
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
  eleventyConfig.addPassthroughCopy("src/images");
  
  // Copy the RSS feed XSL stylesheet to the output
  // This makes the RSS feed look nice when viewed in a browser
  eleventyConfig.addPassthroughCopy("src/feed/pretty-atom-feed.xsl");
  
  // ========================================
  // RSS FEED PLUGIN
  // ========================================
  // This plugin generates an RSS/Atom feed for your blog
  // Readers can subscribe to your blog using feed readers like Feedly, NewsBlur, etc.
  // Learn more: https://aboutfeeds.com/
  
  eleventyConfig.addPlugin(feedPlugin, {
    // Type of feed to generate - atom is modern and well-supported
    type: "atom",
    
    // Where to save the generated feed file
    outputPath: "/feed/feed.xml",
    
    // Use the pretty stylesheet to make the feed human-readable in browsers
    // This shows an explanation about feeds and links to aboutfeeds.com
    stylesheet: "pretty-atom-feed.xsl",
    
    // Which collection of posts to include in the feed
    collection: {
      name: "posts",    // Use the "posts" collection
      limit: 10,        // Include only the 10 most recent posts
    },
    
    // Metadata about your blog
    // UPDATE THESE VALUES to match your blog!
    metadata: {
      language: "en",
      title: "Newman's 11ty Blog 2026",
      subtitle: "A beginner-friendly blog with bash scripting helpers",
      base: "https://newmanure.com/",  // Your blog URL
      author: {
        name: "Newman5"
      }
    }
  });
}

// ========================================
// CONFIGURATION
// ========================================
// Tell Eleventy where to find files and where to output
// Exported separately for Eleventy 3.x

export const config = {
  // Where to look for source files
  dir: {
    input: "src",           // Read files from src/
    includes: "_includes",  // Templates are in src/_includes/
    output: "_site"         // Built site goes to _site/
  },
  
  // What template languages to use
  templateFormats: ["md", "njk", "html"],
  
  // Use Nunjucks for markdown files too
  markdownTemplateEngine: "njk",
  htmlTemplateEngine: "njk"
};
