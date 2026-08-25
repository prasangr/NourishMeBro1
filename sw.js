/* Nourish me Bro — the offline shell.
 *
 * Navigation is network-first on purpose. Cache-first is the usual PWA advice
 * and it is exactly how you pin every user to an old build with no way to tell
 * them: their browser keeps serving a cached index.html forever and a fix you
 * push never arrives. Network-first means anyone online always gets the current
 * app, and anyone offline gets the last copy that loaded. The cost is a slightly
 * slower cold start; the benefit is that a bad deploy stays fixable.
 */
const CACHE = "nourish-v1";

// Only what is needed to open the app.
const SHELL = ["./", "./index.html", "./manifest.webmanifest",
  "./icon-192.png", "./icon-512.png"];

// The Supabase client comes off a CDN, and without it a cold offline start
// cannot restore the session — which means loadState() falls back to the
// device key and you open the app to an empty day instead of your own. So it
// is precached, but separately: addAll rejects the whole install if any one
// URL is unreachable, and a CDN blip must not leave the app with no shell.
const VENDOR = "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm";

self.addEventListener("install", e => {
  e.waitUntil(
    caches.open(CACHE)
      .then(c => c.addAll(SHELL).then(() =>
        c.add(VENDOR).catch(err => console.warn("[sw] vendor precache skipped", err))
      ))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);

  // The account is never cached. A stale log is worse than no log, and a
  // cached auth response is worse than both.
  if (url.hostname.endsWith(".supabase.co")) return;

  // Fonts are immutable in practice, so serve them from the cache and stop
  // paying for them on every launch.
  if (url.hostname === "fonts.googleapis.com" || url.hostname === "fonts.gstatic.com") {
    e.respondWith(
      caches.match(req).then(hit =>
        hit || fetch(req).then(r => {
          if (r && r.ok) { const copy = r.clone(); caches.open(CACHE).then(c => c.put(req, copy)); }
          return r;
        })
      )
    );
    return;
  }

  // Everything else, the app itself included: network first, cache as the
  // fallback. r.ok is false for opaque cross-origin responses, so those are
  // passed through rather than stored as an empty hit.
  e.respondWith(
    fetch(req)
      .then(r => {
        if (r && r.ok) { const copy = r.clone(); caches.open(CACHE).then(c => c.put(req, copy)); }
        return r;
      })
      // ignoreVary: the CDN sends Vary: Accept-Encoding, and a module import
      // does not carry the same headers as the plain fetch that cached it, so
      // a strict match would miss the very entry precached above.
      .catch(() =>
        caches.match(req, { ignoreVary: true }).then(hit =>
          hit || (req.mode === "navigate" ? caches.match("./index.html") : undefined)
        )
      )
  );
});
