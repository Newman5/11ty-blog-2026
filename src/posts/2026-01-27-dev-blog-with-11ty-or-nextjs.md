---
title: "Dev Blog with 11ty or Next.js"
date: 2026-01-27
tags:
  - blog
layout: post.njk
og_image: /images/og/11ty-blog-OG-default.jpg
---

## Why a Dev Blog at All? 🛠️

I’m building an app — and thank the gods and the AIs that help us do this 🙏 — and somewhere along the way it clicked:

I want to document the *experience* of building it.

The highs and lows.  
The trials and tribulations.  
The wins, the losses.  
The smiles… and yes, occasionally the cries.

Not as a generic blog.  
Not as “thought leadership.”  

But as part of the project itself — a dev log that tells the story of *this thing* I’m making.

---

## The Fork in the Road 🤔

My first instinct was simple:

> “I’m already using Next.js — I’ll just drop a `blog/` folder in there and call it a day.”

Then I remembered how quickly **11ty (Eleventy)** can grab Markdown, images, and just *get out of the way*. That got me thinking:  
Should this dev blog be **part of the app**, or **alongside it**?

So I asked the AI for a clean comparison.

---

## Plan: 11ty vs Next.js for a Simple Dev Blog 🧭

**Goal:**  
A fully separate, Markdown-based dev blog with images.  
A separate build step is totally fine.

Here’s the breakdown.

---

## Option 1: 11ty (Eleventy) ⚡

- Simple static site generator, ideal for Markdown-first blogs
- Fully decoupled — lives in its own folder
- Markdown + images work out of the box
- Excellent plugin ecosystem (RSS, syntax highlighting, etc.)
- Outputs pure HTML — boring in the best way
- Separate, fast build (`npm run build` inside the blog folder)

---

## Option 2: Next.js Blog (MDX / Contentlayer) 🧩

- More complex to set up for a *fully separate* blog
- Tightly coupled to the app (routing, config, build)
- Markdown + images are possible, but image handling adds complexity
- RSS requires manual setup
- One build step if integrated — but more moving parts

---

## Pros & Cons at a Glance 📊

| Feature              | 11ty (Eleventy)       | Next.js Blog (MDX)      |
|----------------------|-----------------------|--------------------------|
| **Separation**       | Fully separate        | Tightly coupled          |
| **Simplicity**       | Very simple           | More complex             |
| **Markdown + Images**| Native support        | Needs configuration      |
| **RSS**              | Plugins available     | Manual setup             |
| **Reliability**      | Extremely high        | More dependencies        |
| **Build**            | Separate, fast        | Integrated, slower       |

---

## Further Considerations 🧠

- **11ty** shines when you want something boring, reliable, and easy to maintain.
- **Next.js** shines when the blog *is the app* — which isn’t my goal here.

---

## Recommendation ✅

For this dev blog:

> **Use 11ty in a subfolder.**

It keeps the blog:

- simple
- decoupled
- Markdown-native
- resistant to framework churn

The app can evolve.  
The dev blog can quietly do its job and tell the story.

And honestly?  
That separation feels right.
