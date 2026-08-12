---
title: "Image Assets in 11ty — Registry, Caching & Attribution"
date: 2026-06-20
tags:
  - blog
  - images
  - unsplash
layout: post.njk
description: "How to use the imageAsset shortcode to cache provider images locally and reuse them in your Eleventy posts."
image_key: "mountains"
image_alt: "A dramatic mountain landscape bathed in golden sunrise light"
---

This post demonstrates the two ways you can embed registered image assets in
your Eleventy blog.

## Method 1 — Front-matter hero image (automatic)

Set an image key in any post's front matter and a full-width hero image appears
automatically above the post body, complete with photographer attribution:

```yaml
---
image_key: "mountains"
image_alt: "A dramatic mountain landscape at sunrise"
---
```

The `post.njk` template detects these keys and calls the `imageAsset`
shortcode for you. No extra markup is needed.

## Method 2 — Inline shortcode

Use `{% raw %}{% imageAsset "coffee" %}{% endraw %}` anywhere inside a markdown
post or Nunjucks template to insert an attributed image inline:

{% imageAsset "coffee" %}

Override the registry alt text when the specific context needs it:

{% imageAsset "coffee", "A warm cup of coffee on a wooden table" %}

The shortcode:

1. Looks up the image in `src/_data/images.yaml`.
2. Downloads remote provider images once and stores them locally under
   `src/images/`.
3. Reuses the local file on future builds, so the image is not hotlinked.
4. Outputs a `<figure>` element with an `<img>` tag and a `<figcaption>` with
   provider attribution.

## Setup

1. (Optional) Create a free account at <https://unsplash.com/developers> and
   register an application to get an **Access Key** for richer attribution
   metadata.
2. Copy `.env.example` to `.env` in the project root and fill in your key:

   ```
   UNSPLASH_ACCESS_KEY=your_key_here
   ```

3. The `.env` file is already in `.gitignore` — your key will never be
   committed to version control.

## Finding a provider ID

Every Unsplash photo URL looks like:

```
https://unsplash.com/photos/phIFdC6lA4E
```

The last path segment (`phIFdC6lA4E`) is the photo ID.

Add it to `src/_data/images.yaml` with `provider: unsplash` and
`provider_id: phIFdC6lA4E`, then use the registry key in templates:

```yaml
images:
  mountains:
    provider: unsplash
    provider_id: phIFdC6lA4E
    alt: Mountain landscape at sunrise
```

{% raw %}```njk
{% imageAsset "mountains" %}
```{% endraw %}

## API-key-missing behavior

If `UNSPLASH_ACCESS_KEY` is not set, the image is still downloaded and cached
locally. The caption falls back to a generic Unsplash credit link.

The legacy `{% raw %}{% unsplashImage "PHOTO_ID", "Alt text" %}{% endraw %}`
shortcode still works for older posts, but new posts should prefer
`imageAsset`.
