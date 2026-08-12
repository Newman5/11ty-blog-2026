import fs from "fs";
import path from "path";
import yaml from "js-yaml";

const { load: yamlLoad } = yaml;

function escapeHtml(value = "") {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

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

function yamlEscape(value = "") {
  return String(value || "").replace(/\\/g, "\\\\").replace(/"/g, '\\"');
}

function extensionFromContentType(contentType = "") {
  if (contentType.includes("image/png")) return "png";
  if (contentType.includes("image/webp")) return "webp";
  if (contentType.includes("image/avif")) return "avif";
  return "jpg";
}

function normalizeRegistry(rawRegistry = {}) {
  if (rawRegistry.images) {
    return { images: rawRegistry.images || {} };
  }

  const images = {};
  for (const [key, entry] of Object.entries(rawRegistry.photos || {})) {
    images[key] = {
      provider: "unsplash",
      provider_id: entry?.id,
      alt: entry?.alt || "",
      description: entry?.description || "",
      credit: entry?.credit || {},
      source: {
        name: "Unsplash",
        url: entry?.id ? `https://unsplash.com/photos/${entry.id}` : ""
      }
    };
  }

  return { images };
}

function loadImageRegistry(registryPath) {
  try {
    const content = fs.readFileSync(registryPath, "utf8");
    return normalizeRegistry(yamlLoad(content) || { images: {} });
  } catch {
    return { images: {} };
  }
}

function findRegistryEntryByKey(registry, key) {
  const entry = registry?.images?.[key];
  return entry ? { key, entry } : null;
}

function findRegistryEntryByProviderId(registry, provider, providerId) {
  for (const [key, entry] of Object.entries(registry?.images || {})) {
    if (entry?.provider === provider && entry?.provider_id === providerId) {
      return { key, entry };
    }
  }
  return null;
}

function findCachedImageFile(imageDir, providerId) {
  if (!fs.existsSync(imageDir)) {
    return null;
  }

  const match = fs.readdirSync(imageDir).find(file => {
    const extensionIndex = file.lastIndexOf(".");
    if (extensionIndex === -1) return false;
    const base = file.slice(0, extensionIndex);
    return base === providerId || base.endsWith(`-${providerId}`);
  });

  return match || null;
}

function appendRegistryEntry(registryPath, key, image) {
  const provider = yamlEscape(image.provider || "local");
  const providerId = yamlEscape(image.provider_id || "");
  const alt = yamlEscape(image.alt || "");
  const description = yamlEscape(image.description || "");
  const creditName = yamlEscape(image.credit?.name || "");
  const creditUsername = yamlEscape(image.credit?.username || "");
  const creditUrl = yamlEscape(image.credit?.url || "");
  const sourceName = yamlEscape(image.source?.name || "");
  const sourceUrl = yamlEscape(image.source?.url || "");

  const block = [
    "",
    `  ${key}:`,
    `    provider: ${provider}`,
    `    provider_id: ${providerId}`,
    `    alt: "${alt}"`,
    `    description: "${description}"`,
    "    credit:",
    `      name: "${creditName}"`,
    `      username: "${creditUsername}"`,
    `      url: "${creditUrl}"`,
    "    source:",
    `      name: "${sourceName}"`,
    `      url: "${sourceUrl}"`,
    ""
  ].join("\n");

  if (!fs.existsSync(registryPath)) {
    fs.mkdirSync(path.dirname(registryPath), { recursive: true });
    fs.writeFileSync(registryPath, "# Image Asset Registry\n\nimages:\n", "utf8");
  }

  fs.appendFileSync(registryPath, block, "utf8");
  console.log(`[imageAsset] Added registry entry "${key}" for ${image.provider}:${image.provider_id}.`);
}

async function fetchUnsplashMetadata(providerId, accessKeyEnv) {
  const accessKey = process.env[accessKeyEnv];
  if (!accessKey) {
    return null;
  }

  try {
    const res = await fetch(`https://api.unsplash.com/photos/${providerId}`, {
      headers: { Authorization: `Client-ID ${accessKey}` }
    });
    if (!res.ok) {
      console.warn(`[imageAsset] Unsplash API returned ${res.status} for photo "${providerId}".`);
      return null;
    }
    return res.json();
  } catch (err) {
    console.warn(`[imageAsset] Failed to fetch Unsplash photo "${providerId}": ${err.message}`);
    return null;
  }
}

const providerAdapters = {
  unsplash: {
    imageDirectory: "unsplash",

    async getMetadata(entry, options) {
      const hasRegistryCredit = !!(entry?.credit?.name && entry?.credit?.username);
      if (hasRegistryCredit) {
        return null;
      }
      return fetchUnsplashMetadata(entry.provider_id, options.accessKeyEnv);
    },

    getDownloadUrl(entry, metadata) {
      return metadata?.urls?.regular || `https://unsplash.com/photos/${entry.provider_id}/download?force=true&w=1600`;
    },

    mapMetadata(entry, metadata) {
      return {
        alt: entry?.alt || metadata?.alt_description || "",
        credit: {
          name: entry?.credit?.name || metadata?.user?.name || "",
          username: entry?.credit?.username || metadata?.user?.username || "",
          url: entry?.credit?.url || ""
        },
        source: {
          name: entry?.source?.name || "Unsplash",
          url: entry?.source?.url || metadata?.links?.html || `https://unsplash.com/photos/${entry.provider_id}`
        }
      };
    },

    buildAttribution(entry, resolved) {
      const creditName = resolved.credit?.name;
      const creditUsername = resolved.credit?.username;
      const photoPageUrl = resolved.source?.url || `https://unsplash.com/photos/${entry.provider_id}`;

      if (creditName && creditUsername) {
        return `Photo by <a href="https://unsplash.com/@${escapeHtml(creditUsername)}?utm_source=${escapeHtml(resolved.utmSource)}&utm_medium=referral" target="_blank" rel="noopener">${escapeHtml(creditName)}</a> on <a href="${escapeHtml(photoPageUrl)}?utm_source=${escapeHtml(resolved.utmSource)}&utm_medium=referral" target="_blank" rel="noopener">Unsplash</a>`;
      }

      return `Photo from <a href="https://unsplash.com/photos/${escapeHtml(entry.provider_id)}?utm_source=${escapeHtml(resolved.utmSource)}&utm_medium=referral" target="_blank" rel="noopener">Unsplash</a>`;
    },

    buildFallback(entry, resolved) {
      return `<a href="https://unsplash.com/photos/${escapeHtml(entry.provider_id)}?utm_source=${escapeHtml(resolved.utmSource)}&utm_medium=referral" target="_blank" rel="noopener">View photo on Unsplash</a>`;
    }
  },

  local: {
    imageDirectory: "",

    async getMetadata() {
      return null;
    },

    getLocalSource(entry) {
      return entry?.src || entry?.provider_id || "";
    },

    mapMetadata(entry) {
      return {
        alt: entry?.alt || "",
        credit: entry?.credit || {},
        source: entry?.source || {}
      };
    },

    buildAttribution(_entry, resolved) {
      const creditName = resolved.credit?.name;
      const creditUrl = resolved.credit?.url;
      const sourceName = resolved.source?.name;
      const sourceUrl = resolved.source?.url;

      const linkedCredit = creditName
        ? (creditUrl
          ? `<a href="${escapeHtml(creditUrl)}" target="_blank" rel="noopener">${escapeHtml(creditName)}</a>`
          : escapeHtml(creditName))
        : "";
      const linkedSource = sourceName
        ? (sourceUrl
          ? `<a href="${escapeHtml(sourceUrl)}" target="_blank" rel="noopener">${escapeHtml(sourceName)}</a>`
          : escapeHtml(sourceName))
        : "";

      if (linkedCredit) {
        return `Image by ${linkedCredit}${linkedSource ? ` on ${linkedSource}` : ""}`;
      }
      return linkedSource ? `Source: ${linkedSource}` : "";
    },

    buildFallback() {
      return "";
    }
  },

  flickr: {
    imageDirectory: "flickr",

    async getMetadata() {
      throw new Error("Flickr image provider is not implemented yet.");
    }
  }
};

async function downloadRemoteImage(entry, adapter, imageDir, slug, metadata) {
  fs.mkdirSync(imageDir, { recursive: true });

  const imageUrl = adapter.getDownloadUrl(entry, metadata);
  const res = await fetch(imageUrl);
  if (!res.ok) {
    throw new Error(`download failed with status ${res.status}`);
  }

  const extension = extensionFromContentType(res.headers.get("content-type") || "");
  const fileName = `${slug}-${entry.provider_id}.${extension}`;
  const buffer = Buffer.from(await res.arrayBuffer());
  fs.writeFileSync(path.join(imageDir, fileName), buffer);
  console.log(`[imageAsset] Downloaded and cached "${fileName}" locally.`);
  return fileName;
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

function buildFigure(imageHtml, entry, resolved, adapter) {
  const providerClass = `image-provider-${escapeHtml(entry.provider || "local")}`;
  const attribution = resolved.credit === false
    ? ""
    : adapter.buildAttribution(entry, resolved);

  let captionText = "";
  if (resolved.caption === false) {
    captionText = "";
  } else if (typeof resolved.caption === "string") {
    captionText = resolved.caption;
  } else {
    captionText = entry.description || entry.alt || resolved.alt || "";
  }

  const captionHtml = (captionText || attribution)
    ? `<figcaption class="image-asset-caption">${captionText ? escapeHtml(captionText) : ""}${captionText && attribution ? ` <span class="image-asset-attribution">- ${attribution}</span>` : attribution ? `<span class="image-asset-attribution">${attribution}</span>` : ""}</figcaption>`
    : "";

  return `<figure class="image-asset-figure ${providerClass}">
  ${imageHtml}
  ${captionHtml}
</figure>`;
}

export function createImageAssets(options = {}) {
  const {
    projectRoot = process.cwd(),
    registryPath = "src/_data/images.yaml",
    imageDirectory = "src/images",
    publicPath = "/images",
    accessKeyEnv = "UNSPLASH_ACCESS_KEY",
    utmSource = "11ty_blog"
  } = options;

  const absoluteRegistryPath = path.resolve(projectRoot, registryPath);
  const absoluteImageDirectory = path.resolve(projectRoot, imageDirectory);

  async function renderRegistryMatch(registryMatch, altOverride = "", renderOptions = {}, options = {}) {
    const { key, entry } = registryMatch;
    const provider = entry.provider || "local";
    const adapter = providerAdapters[provider];
    if (!adapter) {
      console.warn(`[imageAsset] Unknown provider "${provider}" for image "${key}".`);
      return "";
    }

    let metadata = null;
    try {
      metadata = await adapter.getMetadata(entry, { accessKeyEnv });
    } catch (err) {
      console.warn(`[imageAsset] ${err.message}`);
      return "";
    }

    const mapped = adapter.mapMetadata?.(entry, metadata) || {};
    const resolvedAlt = altOverride || entry.alt || mapped.alt || "";
    const resolved = {
      alt: resolvedAlt,
      caption: Object.hasOwn(renderOptions, "caption") ? renderOptions.caption : undefined,
      credit: Object.hasOwn(renderOptions, "credit") ? renderOptions.credit : mapped.credit,
      source: mapped.source,
      utmSource,
      ...renderOptions
    };

    if (provider === "local") {
      const localSrc = adapter.getLocalSource(entry);
      const imageHtml = `<img src="${escapeHtml(localSrc)}" alt="${escapeHtml(resolvedAlt)}" loading="${escapeHtml(renderOptions.loading || "lazy")}" decoding="${escapeHtml(renderOptions.decoding || "async")}">`;
      return buildFigure(imageHtml, entry, resolved, adapter);
    }

    const providerImageDir = path.join(absoluteImageDirectory, adapter.imageDirectory || provider);
    const providerPublicPath = `${publicPath.replace(/\/$/, "")}/${adapter.imageDirectory || provider}`;
    const effectiveSlug = key || slugify(resolvedAlt) || "photo";
    let imageHtml = "";
    let hasLocalImage = false;

    try {
      const cachedFile = findCachedImageFile(providerImageDir, entry.provider_id);
      let localFile;
      if (cachedFile) {
        localFile = cachedFile;
      } else {
        localFile = await downloadRemoteImage(entry, adapter, providerImageDir, effectiveSlug, metadata);
      }
      hasLocalImage = true;

      imageHtml = `<img src="${escapeHtml(`${providerPublicPath}/${localFile}`)}" alt="${escapeHtml(resolvedAlt)}" sizes="${escapeHtml(renderOptions.sizes || "(max-width: 800px) 100vw, 800px")}" loading="${escapeHtml(renderOptions.loading || "lazy")}" decoding="${escapeHtml(renderOptions.decoding || "async")}">`;
    } catch (err) {
      console.warn(`[imageAsset] Could not cache image "${entry.provider_id}": ${err.message}`);
      imageHtml = adapter.buildFallback(entry, resolved);
    }

    if (hasLocalImage && options.appendIfNew) {
      appendRegistryEntry(absoluteRegistryPath, effectiveSlug, {
        provider,
        provider_id: entry.provider_id,
        alt: resolvedAlt,
        description: entry.description || "",
        credit: mapped.credit,
        source: mapped.source
      });
    }

    return buildFigure(imageHtml, entry, resolved, adapter);
  }

  async function buildImageAsset(keyOrId, altOverride = "", renderOptions = {}) {
    if (!keyOrId) {
      console.warn("[imageAsset] Called without an image key or ID.");
      return "";
    }

    const registry = loadImageRegistry(absoluteRegistryPath);
    const registryMatch = findRegistryEntryByKey(registry, keyOrId)
      || findRegistryEntryByProviderId(registry, "unsplash", keyOrId);

    if (!registryMatch) {
      return buildUnsplashImage(keyOrId, altOverride, renderOptions);
    }

    return renderRegistryMatch(registryMatch, altOverride, renderOptions);
  }

  async function buildUnsplashImage(photoId, altOverride = "", renderOptions = {}) {
    const registry = loadImageRegistry(absoluteRegistryPath);
    const registryMatch = findRegistryEntryByProviderId(registry, "unsplash", photoId);

    if (registryMatch) {
      return buildImageAsset(registryMatch.key, altOverride, {
        className: "unsplash-figure",
        ...renderOptions
      });
    }

    const tempKey = slugify(altOverride) || slugify(photoId) || "photo";
    const tempEntry = {
      provider: "unsplash",
      provider_id: photoId,
      alt: altOverride,
      description: "",
      credit: {},
      source: {
        name: "Unsplash",
        url: `https://unsplash.com/photos/${photoId}`
      }
    };

    return renderRegistryMatch(
      { key: tempKey, entry: tempEntry },
      altOverride,
      renderOptions,
      { appendIfNew: true }
    );
  }

  function registerShortcodes(eleventyConfig) {
    eleventyConfig.addAsyncShortcode("imageAsset", buildImageAsset);

    eleventyConfig.addAsyncShortcode("unsplashImage", async function(photoId, altText = "", shortcodeOptions = {}) {
      if (!photoId) {
        console.warn("[unsplashImage] Called without a photo ID.");
        return "";
      }
      const html = await buildUnsplashImage(photoId, altText, shortcodeOptions);
      return html
        .replace('class="image-asset-figure image-provider-unsplash"', 'class="image-asset-figure image-provider-unsplash unsplash-figure"')
        .replace('class="image-asset-caption"', 'class="image-asset-caption unsplash-attribution"');
    });

    eleventyConfig.addShortcode("imageFigure", buildLocalImageFigure);
  }

  return {
    buildImageAsset,
    buildUnsplashImage,
    buildLocalImageFigure,
    registerShortcodes
  };
}
