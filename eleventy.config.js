// Eleventy Configuration File
// This file tells Eleventy how to build your site
// Using ES6 module syntax for Eleventy 3.x

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
    return excerpt.substr(0, 200) + (excerpt.length > 200 ? "..." : "");
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
  // eleventyConfig.addPassthroughCopy("src/images");
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
