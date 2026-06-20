/**
 * Unsplash Photo Registry
 *
 * This file defines which Unsplash photos are used across the blog.
 * Each entry maps a logical name to an Unsplash photo ID along with
 * metadata that serves as a fallback when the API is unavailable.
 *
 * To add a new photo:
 * 1. Find the photo on https://unsplash.com
 * 2. Copy the photo ID from the URL (e.g. https://unsplash.com/photos/[ID])
 * 3. Add an entry below with a descriptive key
 * 4. Reference it in your post front matter as: unsplash_photo_id: "[ID]"
 *    or use the shortcode directly: {% unsplashImage "[ID]", "alt text" %}
 *
 * Environment variable required:
 *   UNSPLASH_ACCESS_KEY — your Unsplash API access key
 *   Get one at https://unsplash.com/developers
 */

export default {
  // Example entries — replace with real photo IDs from unsplash.com
  photos: {
    // key: { id, alt, credit } — credit is used as fallback when API is down
    "mountains": {
      id: "phIFdC6lA4E",
      alt: "Mountain landscape at sunrise",
      credit: { name: "Nathan Anderson", username: "nathananderson" }
    },
    "coffee": {
      id: "TD4DBagg2wE",
      alt: "Close-up of a coffee cup",
      credit: { name: "Nathan Dumlao", username: "nate_dumlao" }
    },
    "coding": {
      id: "npxXWgQ33ZQ",
      alt: "Person coding on a laptop",
      credit: { name: "Emile Perron", username: "emilep" }
    }
  }
};
