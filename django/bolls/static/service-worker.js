importScripts("/static/bolls/jszip.min.js");
importScripts("/static/bolls/dexie.min.js");
importScripts("/static/bolls/scripts.js");

const CACHE_NAME = "v2.6.9";
const STATICS_CACHE = "statics-v1.0.1";
const TEXTS_CACHE = "texts-v1.0.4";

const urlsToCache = [
  "/",
  "/static/bolls/dist/assets/index.js",
  "/static/bolls/index.css",
  "/static/bolls/fonts/fontstylesheet.css",
  "/static/bolls/jszip.min.js",
  "/static/bolls/dexie.min.js",
  "/static/bolls/scripts.js",
];

self.addEventListener("install", function (event) {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then(function (cache) {
      console.log("👷 Opened cache ", CACHE_NAME);
      return cache.addAll(urlsToCache);
    })
  );
});

self.addEventListener("fetch", (event) => {
  const url = event.request.url;
  // Translations API
  if (url.includes("/static/translations/") && !url.includes(".zip")) {
    event.respondWith(downloadTranslation(url));
  } else if (url.includes("/sw/delete-translation/")) {
    event.respondWith(deleteTranslation(url));
  } else if (url.includes("/sw/search-verses/")) {
    event.respondWith(searchVerses(url));
    // Dictionaries API
  } else if (url.includes("/static/dictionaries/") && !url.includes(".zip")) {
    event.respondWith(downloadDictionary(url));
  } else if (url.includes("/sw/delete-dictionary/")) {
    event.respondWith(deleteDictionary(url));
  } else if (url.includes("/sw/search-definitions/")) {
    event.respondWith(dictionarySearch(url));
  } else if (url.includes("/sw/get-random-verse/")) {
    event.respondWith(getRandomVerse(url));
    // All the other stuff
  } else {
    event.respondWith(
      caches
        .match(event.request)
        .then((resp) => {
          return (
            resp ||
            fetch(event.request).then((response) => {
              var responseClone = response.clone();
              const texts_cache_eligible =
                event.request.url.includes("get-chapter/") ||
                event.request.url.includes("get-text/") ||
                event.request.url.includes("search/") ||
                event.request.url.includes("dictionary-definition/");
              const statics_cache_eligible =
                event.request.destination == "font" ||
                event.request.destination == "script" ||
                event.request.destination == "style" ||
                event.request.destination == "manifest" ||
                event.request.destination == "image";
              if (texts_cache_eligible || statics_cache_eligible) {
                console.log("Populating cache with ", event.request.url);
                if (texts_cache_eligible) {
                  caches.open(TEXTS_CACHE).then((cache) => {
                    cache.put(event.request, responseClone);
                  });
                } else if (statics_cache_eligible) {
                  caches.open(STATICS_CACHE).then((cache) => {
                    cache.put(event.request, responseClone);
                  });
                } else {
                  caches.open(CACHE_NAME).then((cache) => {
                    cache.put(event.request, responseClone);
                  });
                }
              }
              return response;
            })
          );
        })
        .catch(() => {
          return caches.match("/");
        })
    );
  }
});

self.addEventListener("activate", (event) => {
  const expectedCaches = [CACHE_NAME, STATICS_CACHE, TEXTS_CACHE];
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys.map((key) => {
            if (!expectedCaches.includes(key)) {
              return caches.delete(key);
            }
          })
        )
      )
      .then(() => {
        console.log("👷 activated!", CACHE_NAME);
        return self.clients.claim();
      })
  );
});
