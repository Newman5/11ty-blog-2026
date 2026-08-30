---
title: "Coding safari... but we need a map"
date: 2026-08-30
tags:
  - blog
layout: post.njk
og_image: /images/og/11ty-blog-OG-default.jpg
description: "A brief description of your post goes here."
image_key: "group-of-zebra-walking-on-wheat-field-Jgiv1rSIpVM"
image_alt: "Now you are on a real safari"
---

I went on a little day-off coding safari today.

I had a few hours while watching the Tour Championship at East Lake, and maps were on my mind.

Maps are one of those things I keep coming back to. I realized I now have three projects where they matter in very different ways.

There’s the Global Meeting Presence map we built for Gimbalabs meetings last year — showing where people are participating from around the world.

There’s AlaskaGold, where maps could become much more than decoration: a way to understand regions, activities, routes and travel times, and eventually perhaps an interface for planning an Alaska trip.

And there’s my Qigong journal, which I think is actually where I first started experimenting with Leaflet.js.

So my question for the afternoon was pretty simple: what has the Eleventy community already figured out about using Leaflet? Are there reusable helpers, components, plugins, or patterns that I could learn from rather than inventing everything again?

GPT and I found some examples, then decided the best way to understand them was to ask CoPilot to build a tiny version: Leaflet in an Eleventy site, with the map driven by YAML data and rendered through a reusable Nunjucks component.

Of course the simple experiment broke. 😄

That turned out to be the useful part. Thank you, CoPilot!

We followed the data from YAML → Eleventy → Nunjucks → generated HTML → JavaScript → Leaflet, figured out where it was breaking, and ended up with a cleaner reusable pattern than the first working solution.



Nothing revolutionary. Just a few hours wandering around the woods, learning how the pieces fit together and coming home with something I can reuse the next time one of these mapping projects comes calling.

A pretty good coding safari.
