// Eleventy Configuration File
// This file tells Eleventy how to build your site
// Using ES6 module syntax for Eleventy 3.x

// Load .env values into process.env for local development
import "dotenv/config";

// Import the RSS plugin to generate RSS/Atom feeds
// This allows readers to subscribe to your blog in their favorite feed reader
import { feedPlugin } from "@11ty/eleventy-plugin-rss";

// Import eleventy-img for optimized image generation
// File system and path utilities
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { load as yamlLoad } from "js-yaml";
import { eleventyImageTransformPlugin } from "@11ty/eleventy-img";



// ========================================
// UNSPLASH HELPERS
// ========================================

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const localUnsplashDir = path.join(__dirname, "src", "images", "unsplash");
const unsplashYamlPath = path.join(__dirname, "src", "_data", "unsplash.yaml");

function escapeHtml(value = "") {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function buildLocalImageFigure(src, altText = "", caption = "", options = {}) {
  if (!src) return "";

  const {
    width,
    className = "image-figure",
    loading = "lazy",
    decoding = "async",
    sizes,
    attributionText = "",
    attributionName = "",
    attributionUrl = "",
    sourceName = "",
    sourceUrl = ""
  } = options;

  const widthAttr = width ? ` width="${escapeHtml(String(width))}"` : "";
  const sizesAttr = sizes ? ` sizes="${escapeHtml(String(sizes))}"` : "";
  const figureClass = className ? ` class="${escapeHtml(className)}"` : "";
  const safeAlt = escapeHtml(altText);
  const safeCaption = escapeHtml(caption || altText);

  const linkedAttributionName = attributionName
    ? (attributionUrl
      ? `<a href="${escapeHtml(attributionUrl)}" target="_blank" rel="noopener">${escapeHtml(attributionName)}</a>`
      : escapeHtml(attributionName))
    : "";

  const linkedSourceName = sourceName
    ? (sourceUrl
      ? `<a href="${escapeHtml(sourceUrl)}" target="_blank" rel="noopener">${escapeHtml(sourceName)}</a>`
      : escapeHtml(sourceName))
    : "";

  const generatedAttribution = linkedAttributionName
    ? `Image by ${linkedAttributionName}${linkedSourceName ? ` on ${linkedSourceName}` : ""}`
    : (linkedSourceName ? `Source: ${linkedSourceName}` : "");

  const resolvedAttribution = attributionText
    ? escapeHtml(attributionText)
    : generatedAttribution;

  const figcaptionHtml = (safeCaption || resolvedAttribution)
    ? `<figcaption class="image-caption">${safeCaption}${safeCaption && resolvedAttribution ? ` <span class="image-attribution">- ${resolvedAttribution}</span>` : resolvedAttribution ? `<span class="image-attribution">${resolvedAttribution}</span>` : ""}</figcaption>`
    : "";

  return `<figure${figureClass}>\n  <img src="${escapeHtml(src)}" alt="${safeAlt}"${widthAttr}${sizesAttr} loading="${escapeHtml(loading)}" decoding="${escapeHtml(decoding)}">\n  ${figcaptionHtml}\n</figure>`;
}

/** Turn a string into a lowercase hyphen-separated slug (max 5 words). */
function slugify(text = "") {
  return String(text)
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
    .split("-")
    .filter(Boolean)
    .slice(0, 5)
    .join("-");
}

/**
 * Load the unsplash.yaml registry.
 * Returns { photos: { <key>: { id, alt, description, credit } } }
 */
function loadUnsplashRegistry() {
  try {
    const content = fs.readFileSync(unsplashYamlPath, "utf8");
    return yamlLoad(content) || { photos: {} };
  } catch {
    return { photos: {} };
  }
}

/**
 * Find the YAML registry entry whose `id` matches photoId.
 * Returns { key, entry } or null.
 */
function findRegistryEntryByPhotoId(registry, photoId) {
  for (const [key, entry] of Object.entries(registry?.photos || {})) {
    if (entry?.id === photoId) {
      return { key, entry };
    }
  }
  return null;
}

/**
 * Append a new entry to unsplash.yaml for a freshly-downloaded photo.
 * Called only when no existing registry entry exists for the photo.
 */
function appendYamlEntry(photoId, key, altText, photo) {
  // Escape backslashes first, then double-quotes, for safe YAML double-quoted strings.
  const yamlEscape = str => String(str || "").replace(/\\/g, "\\\\").replace(/"/g, '\\"');
  const safeAlt    = yamlEscape(altText);
  const name       = yamlEscape(photo?.user?.name     || "");
  const username   = yamlEscape(photo?.user?.username || "");
  const block = [
    ``,
    `  ${key}:`,
    `    id: ${photoId}`,
    `    alt: "${safeAlt}"`,
    `    description: ""`,
    `    credit:`,
    `      name: "${name}"`,
    `      username: "${username}"`,
    ``
  ].join("\n");
  fs.appendFileSync(unsplashYamlPath, block, "utf8");
  console.log(`[unsplashImage] Added YAML entry "${key}" for photo "${photoId}".`);
}

/**
 * Search src/images/unsplash/ for a previously cached file for photoId.
 * Handles both legacy naming (<id>.ext) and SEO naming (<slug>-<id>.ext).
 */
function findCachedImageFile(photoId) {
  if (!fs.existsSync(localUnsplashDir)) {
    return null;
  }
  const match = fs.readdirSync(localUnsplashDir).find(file => {
    const base = file.slice(0, file.lastIndexOf("."));
    return base === photoId || base.endsWith(`-${photoId}`);
  });
  return match || null;
}

function extensionFromContentType(contentType = "") {
  if (contentType.includes("image/png")) return "png";
  if (contentType.includes("image/webp")) return "webp";
  if (contentType.includes("image/avif")) return "avif";
  return "jpg";
}

/**
 * Fetch photo metadata from Unsplash API when an API key is available.
 * Returns null if the API key is missing or the request fails.
 */
async function fetchUnsplashPhoto(photoId) {
  const accessKey = process.env.UNSPLASH_ACCESS_KEY;
  if (!accessKey) {
    return null;
  }
  try {
    const res = await fetch(
      `https://api.unsplash.com/photos/${photoId}`,
      { headers: { Authorization: `Client-ID ${accessKey}` } }
    );
    if (!res.ok) {
      console.warn(`[unsplashImage] Unsplash API returned ${res.status} for photo "${photoId}".`);
      return null;
    }
    return res.json();
  } catch (err) {
    console.warn(`[unsplashImage] Failed to fetch photo "${photoId}": ${err.message}`);
    return null;
  }
}

/**
 * Download a photo from Unsplash and save it locally.
 * The filename uses a SEO-friendly slug prefix: <slug>-<photoId>.<ext>
 * @param {string} photoId
 * @param {string} slug    - Descriptive slug (from YAML key or alt text)
 * @param {object} [photo] - Optional API response (provides urls.regular)
 * @returns {Promise<string>} The saved filename
 */
async function downloadUnsplashImage(photoId, slug, photo = null) {
  fs.mkdirSync(localUnsplashDir, { recursive: true });

  const imageUrl = photo?.urls?.regular || `https://unsplash.com/photos/${photoId}/download?force=true&w=1600`;
  const res = await fetch(imageUrl);
  if (!res.ok) {
    throw new Error(`download failed with status ${res.status}`);
  }

  const extension = extensionFromContentType(res.headers.get("content-type") || "");
  const fileName = `${slug}-${photoId}.${extension}`;
  const buffer = Buffer.from(await res.arrayBuffer());
  fs.writeFileSync(path.join(localUnsplashDir, fileName), buffer);
  console.log(`[unsplashImage] Downloaded and cached "${fileName}" locally.`);
  return fileName;
}

/**
 * Build a <figure> element containing a local cached <img> and
 * the mandatory Unsplash attribution <figcaption>.
 *
 * Resolution order for alt text:  shortcode param → YAML alt → API alt_description
 * Resolution order for credit:    YAML credit → API user data → generic link
 * The Unsplash API is only called when YAML credit data is absent.
 *
 * @param {string} photoId   - Unsplash photo ID (from URL: unsplash.com/photos/[ID])
 * @param {string} altText   - Accessible alt text for the image
 * @param {object} [options] - Optional overrides: { sizes }
 * @returns {Promise<string>} HTML string
 */
async function buildUnsplashFigure(photoId, altText, options = {}) {
  const {
   sizes = "(max-width: 800px) 100vw, 800px"
  } = options;

  // Load the YAML registry and look up an entry for this photo ID.
  const registry = loadUnsplashRegistry();
  const registryMatch = findRegistryEntryByPhotoId(registry, photoId);
  const yamlKey   = registryMatch?.key   || null;
  const yamlEntry = registryMatch?.entry || null;

  // Skip the API when the YAML already has photographer credit — this avoids
  // hitting the rate-limit on every build for already-catalogued photos.
  const hasYamlCredit = !!(yamlEntry?.credit?.name && yamlEntry?.credit?.username);
  const photo = hasYamlCredit ? null : await fetchUnsplashPhoto(photoId);

  // Resolve alt text: shortcode param > YAML alt > API alt_description
  const resolvedAlt = altText || yamlEntry?.alt || photo?.alt_description || "";

  // Determine the slug to use as the filename prefix.
  // Prefer the YAML key (human-chosen, e.g. "mountains"), then fall back to a
  // slug derived from the alt text so the filename is always descriptive.
  const generatedSlug = slugify(resolvedAlt) || "photo";
  const effectiveSlug = yamlKey || generatedSlug;

  let imageHtml = "";
  let isNewDownload = false;

  try {
    const cachedFile = findCachedImageFile(photoId);
    let localFile;
    if (cachedFile) {
      localFile = cachedFile;
    } else {
      localFile = await downloadUnsplashImage(photoId, effectiveSlug, photo);
      isNewDownload = true;
    }
    const src = `/images/unsplash/${localFile}`;
    imageHtml = `<img src="${src}" alt="${escapeHtml(resolvedAlt)}" sizes="${escapeHtml(sizes)}" loading="lazy" decoding="async">`;
  } catch (err) {
    console.warn(`[unsplashImage] Could not cache image "${photoId}": ${err.message}`);
    // Degrade gracefully: show a direct link instead of an <img>
    imageHtml = `<a href="https://unsplash.com/photos/${photoId}?utm_source=11ty_blog&utm_medium=referral" target="_blank" rel="noopener">View photo on Unsplash</a>`;
  }

  // Auto-append a YAML entry the first time an image is downloaded so every
  // cached photo has a corresponding registry record.
  if (isNewDownload && !yamlEntry) {
    appendYamlEntry(photoId, effectiveSlug, resolvedAlt, photo);
  }

  // Build attribution — prefer YAML credit, fall back to API data, then generic.
  const creditName     = photo?.user?.name     || yamlEntry?.credit?.name;
  const creditUsername = photo?.user?.username || yamlEntry?.credit?.username;
  const photoPageUrl   = photo?.links?.html    || `https://unsplash.com/photos/${photoId}`;

  const attribution = (creditName && creditUsername)
    ? `Photo by <a href="https://unsplash.com/@${creditUsername}?utm_source=11ty_blog&utm_medium=referral" target="_blank" rel="noopener">${escapeHtml(creditName)}</a> on <a href="${photoPageUrl}?utm_source=11ty_blog&utm_medium=referral" target="_blank" rel="noopener">Unsplash</a>`
    : `Photo from <a href="https://unsplash.com/photos/${photoId}?utm_source=11ty_blog&utm_medium=referral" target="_blank" rel="noopener">Unsplash</a>`;

  return `<figure class="unsplash-figure">
  ${imageHtml}
  <figcaption class="unsplash-attribution">${resolvedAlt ? `${escapeHtml(resolvedAlt)} — ` : ""}${attribution}</figcaption>
</figure>`;
}

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
  // UNSPLASH SHORTCODE
  // ========================================
  // Usage in any template or markdown file:
  //   {% unsplashImage "PHOTO_ID", "Descriptive alt text" %}
  //
  // Images are downloaded once to src/images/unsplash/ and reused locally.

  eleventyConfig.addAsyncShortcode("unsplashImage", async function(photoId, altText = "", options = {}) {
    if (!photoId) {
      console.warn("[unsplashImage] Called without a photo ID — skipping.");
      return "";
    }
    return buildUnsplashFigure(photoId, altText, options);
  });

  // Usage in markdown/nunjucks:
  // {% imageFigure "/images/example.png", "Alt text", "Optional caption", { width: 600 } %}
  eleventyConfig.addShortcode("imageFigure", function (src, altText = "", caption = "", options = {}) {
    return buildLocalImageFigure(src, altText, caption, options);
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
  // This plugin optimizes generic HTML <img> tags.
  eleventyConfig.addPlugin(eleventyImageTransformPlugin);

  // Tell Eleventy where to find files and where to output.
  return {
    dir: {
      input: "src",           // Read files from src/
      includes: "_includes",  // Templates are in src/_includes/
      output: "_site"         // Built site goes to _site/
    },
    templateFormats: ["md", "njk", "html"],
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk"
  };
}
