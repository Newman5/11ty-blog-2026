---
title: "what a difference a slash makes"
date: 2025-12-29
tags:
  - blog
layout: post.njk
---



## How does one teach this?

```html
  <header>
    <h1><a href="/" style="color: inherit; text-decoration: none;">11ty Blog 2026</a></h1>
    <nav>
      <a href="/">Home</a>
      <a href="posts/">All Posts</a>
      <a href="feed/feed.xml">RSS Feed</a>
    </nav>
  </header>
  ```
/posts/ and /feed/feed.xml doubled up the directory.  I think a / at the begining of a URL means home directory.  It's a neat trick and I learned it the hard way.  Now you don't have to