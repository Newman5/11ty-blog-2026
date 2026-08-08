---
title: "Tour de France, Solo RPG, Developer updates - this blog goes everywhere"
date: 2026-07-06
tags:
  - blog
layout: post.njk
og_image: /images/og/11ty-blog-OG-default.jpg
description: "How to use the unsplashImage shortcode to cache Unsplash images locally and reuse them in your Eleventy posts."
unsplash_photo_id: "people-riding-bicycle-on-road-during-daytime-lbVKwIAZ6EY"
unsplash_alt: "It's raining in NYC but NOT on the Tour.  It's a very hot start in Spain and today they pedal to the Mountains and the border with France."
---
It is July and as per my tradition for the past few ... when did I start watching the Tour de France? 2008 but I can remember the Tours de France in the 90s when I was living in Austria and the Lance Armstrong years being in Taiwan. We all read "it's not the bike" book . Anyway I thought that I want to lean into the whole open web thing and record my thoughts as I'm watching the tour. I think it would be pretty cool to have a record of what went on 2026. I would love to if I had a blog from when I was watching in 2009 in my apartment in Durham NC or that summer I watched in Key West at the breakfast Place off Catherine street. Also that time those summers in North Carolina in Lumberton basically watching the tour and working on websites and visiting my grandmother in the nursing home and paddling on the Lumber river. July is a great month so I have to figure out how to keep it all in and keep active and not just layer out zoning out to the riders and the drama. 


I have a bunch to say about the tour and I think I'll make another post about that . I have a bunch to say about another avenue that the blog might take and that is to record writing sessions with a solo RPG. I may do that here or I may do it on another blog hosted somewhere else maybe with 11 maybe with Bear blog or maybe even with Dave Winner blog solution I'm not sure what he calls it.


And then finally I definitely want to keep up with my developer builder upd I think that's sort of what the main thrust of this blog should be and it's cool if we do take a little side diversion and record some Tour de France. And really that is to give us a reason to make the workflows and everything for instance I worked on the Unsplash image workflow and we'll see how that works in this test post. 

{% imageFigure "/images/Screenshot 2026-07-06 at 09-38-57 Tour de France Stage 3 - Peacock.png", "Image with the 11ty image inline way", "Tour de France Stage 3 stream still", { attributionText: "Screenshot from Peacock broadcast" } %}

and... back to developer talk.  I created a shortcode for unsplash images to add caption and attribution.  So, now I'm creating another shortcode for general images I find.  Here is the [documentation for shortcodes in 11ty](https://www.11ty.dev/docs/shortcodes/)

this - 
{% raw %}
```html
{% imageFigure "/images/your-image.png", "Alt text", "Optional caption", { width: 600 } %}
```
{% endraw %}

will render - 
{% raw %}
```
<figure class="image-figure">
  <img src="/images/your-image.png" alt="Alt text" width="600" loading="lazy" decoding="async">
  <figcaption class="image-caption">Optional caption</figcaption>
</figure>
```
{% endraw %}

Tutorial references

Eleventy Shortcodes: https://www.11ty.dev/docs/shortcodes/ 
Eleventy Image plugin/transforms: https://www.11ty.dev/docs/plugins/image/

Current model

{% raw %}
```
Basic:
{% imageFigure "/images/file.png", "Alt", "Caption" %}

With attribution text:
{% imageFigure "/images/file.png", "Alt", "Caption", { width: 600, attributionText: "Screenshot from Peacock broadcast" } %}

With linked creator/source:
{% imageFigure "/images/file.png", "Alt", "Caption", { width: 600, attributionName: "Jane Doe", attributionUrl: "https://example.com/jane", sourceName: "Example Magazine", sourceUrl: "https://example.com" } %}
```
{% endraw %}