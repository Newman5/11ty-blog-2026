---
title: "Unsplash Images in 11ty — Automatic Fetching & Attribution"
date: 2026-06-20
tags:
  - blog
  - images
  - unsplash
layout: post.njk
description: "How to use the unsplashImage shortcode to embed optimised, attributed photos from Unsplash in your Eleventy posts."
unsplash_photo_id: "phIFdC6lA4E"
unsplash_alt: "A dramatic mountain landscape bathed in golden sunrise light"
---

This post demonstrates the two ways you can embed Unsplash photos in your
Eleventy blog.

## Method 1 — Front-matter hero image (automatic)

Set two keys in any post's front matter and a full-width hero image appears
automatically above the post body, complete with photographer attribution:

```yaml
---
unsplash_photo_id: "phIFdC6lA4E"
unsplash_alt:      "A dramatic mountain landscape at sunrise"
---
```

The `post.njk` template detects these keys and calls the `unsplashImage`
shortcode for you.  No extra markup is needed.

## Method 2 — Inline shortcode

Use `{% raw %}{% unsplashImage "PHOTO_ID", "Alt text" %}{% endraw %}` anywhere
inside a markdown post or Nunjucks template to insert an optimised, attributed
image inline:

{% unsplashImage "TD4DBagg2wE", "A warm cup of coffee on a wooden table" %}

The shortcode:

1. Fetches photo metadata (photographer name, profile URL, photo link) from the
   Unsplash API using your `UNSPLASH_ACCESS_KEY` environment variable.
2. Downloads the image and runs it through **eleventy-img** to produce
   modern formats (AVIF, WebP, JPEG) at multiple widths.
3. Outputs a `<figure>` element containing a responsive `<picture>` tag and a
   `<figcaption>` with the mandatory Unsplash attribution link.

## Setup

1. Create a free account at <https://unsplash.com/developers> and register an
   application to get an **Access Key**.
2. Copy `.env.example` to `.env` in the project root and fill in your key:

   ```
   UNSPLASH_ACCESS_KEY=your_key_here
   ```

3. The `.env` file is already in `.gitignore` — your key will never be
   committed to version control.

## Finding a photo ID

Every Unsplash photo URL looks like:

```
https://unsplash.com/photos/phIFdC6lA4E
```

The last path segment (`phIFdC6lA4E`) is the photo ID.

## Offline / API-key-missing fallback

If `UNSPLASH_ACCESS_KEY` is not set, the shortcode falls back to a direct
Unsplash CDN URL and omits per-photographer metadata.  Your build will still
succeed — you will just see a warning in the console.
