importScripts("/static/bolls/jszip.min.js");
importScripts("/static/bolls/dexie.min.js");
importScripts("/static/bolls/scripts.js");

const CACHE_NAME = "v2.2.19";
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
              if (
                event.request.url.includes("get-chapter/") ||
                event.request.url.includes("get-text/") ||
                event.request.url.includes("search/") ||
                event.request.url.includes("dictionary-definition/") ||
                event.request.destination == "font" ||
                event.request.destination == "script" ||
                event.request.destination == "style" ||
                event.request.destination == "manifest" ||
                event.request.destination == "image"
              ) {
                console.log("Populating cache with ", event.request.url);
                caches.open(CACHE_NAME).then((cache) => {
                  cache.put(event.request, responseClone);
                });
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
  const expectedCaches = [CACHE_NAME];
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
