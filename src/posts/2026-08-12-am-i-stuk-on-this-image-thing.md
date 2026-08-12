---
title: "Am I stuk on this image thing?"
date: 2026-08-12
tags:
  - blog
layout: post.njk
og_image: /images/og/11ty-blog-OG-default.jpg
description: "A brief description of your post goes here."
image_key: "snow-covered-mountains-above-a"
image_alt: "Snow-covered mountains above a lake"
---

Reminder: Put post images in src/images/posts/2026-08-12-am-i-stuk-on-this-image-thing/ and add them with the imageFigure shortcode, for example: {% raw %}{% imageFigure "/images/posts/2026-08-12-am-i-stuk-on-this-image-thing/your-image.png", "Alt text", "Optional caption" %}{% endraw %}
Reminder: For a registered hero image, set image_key in front matter. For inline use, add {% raw %}{% imageAsset "snow-covered-mountains-above-a" %}{% endraw %} in the post body.

Write your content here...

## This all started when
... I saw this image on unsplash

{% imageAsset "snow-covered-mountains-above-a" %}

let's see how this previews.

I'd like to add the image workflow to Alaskagold and I have an 11ty implementation over there but... It's kinda a big step, it feels. oh man - I'm thinking like yoga time for a break.


{% imageAsset "8ac1LqavRh4" %}

okay - The first image is of the Worthington Glacier in Thompson Pass. The second is of Mount Billy Mitchell around 45 Mile of the Richardson Highway . These are truly landmarks of my Alaska experience. I live in the late 90s. And I would like to use these images on the Alaska Gold site. But Alaska Gold is yet to become and 11T site... But I might be able to shoehorn it in.
Codex sez:
Yes, you can now use a simple shortcode:

  {% imageAsset "a-snow-covered-mountain-range-with-a-lake-below-RgXVWf0WgoU", "Snow-covered mountains above a
  lake" %}

  On build, it downloads the image, caches it, appends the registry entry, and renders attribution. I also ran it
  for your image. It created:

- Registry key: snow-covered-mountains-above-a
- Cached file: src/images/unsplash/snow-covered-mountains-above-a-a-snow-covered-mountain-range-with-a-lake-
    below-RgXVWf0WgoU.jpg

- Registry entry in src/_data/images.yaml

  After import, use the shorter registry key:

  {% imageAsset "snow-covered-mountains-above-a" %}

  I updated README.md with this workflow, adjusted the shortcode implementation so unknown IDs fall back to
  Unsplash for now, and fixed the new-post scaffold so placeholder shortcode examples do not execute during builds.
