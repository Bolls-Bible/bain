importScripts("/static/bolls/jszip.min.js");
importScripts("/static/bolls/dexie.min.js");
importScripts("/static/bolls/dexie_worker.js");

const CACHE_NAME = "v2.1.89";
const urlsToCache = [
  "/",
  "/static/bolls/dist/assets/languages.json.TKJQWQU4.js",
  "/static/bolls/dist/assets/dictionaries.json.QGP2BXEY.js",
  "/static/bolls/dist/assets/translations_books.json.VZWAXFQH.js",
  "/static/bolls/dist/assets/client.R2G6MXUY.js",
  "/static/bolls/dist/assets/client.MZJOTWIM.css",
  "/static/bolls/dist/assets/index.P2WWFJT8.css",
  "/static/bolls/dist/index.css",
  "/static/bolls/fonts/fontstylesheet.css",
  "/static/bolls/dexie.min.js",
  "/static/bolls/dexie_worker.js",
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
  console.log("👷 Fetching ", event.request.url);
  // Translations API
  if (event.request.url.includes("/static/translations/")) {
    event.respondWith(downloadTranslation(event.request.url));
  } else if (event.request.url.includes("/sw/delete-translation/")) {
    event.respondWith(deleteTranslation(event.request.url));
  } else if (event.request.url.includes("/sw/search-verses/")) {
    event.respondWith(searchVerses(event.request.url));
    // Dictionaries API
  } else if (event.request.url.includes("/static/dictionaries/")) {
    event.respondWith(downloadDictionary(event.request.url));
  } else if (event.request.url.includes("/sw/delete-dictionary/")) {
    event.respondWith(deleteDictionary(event.request.url));
  } else if (event.request.url.includes("/sw/search-definitions/")) {
    event.respondWith(dictionarySearch(event.request.url));
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
              console.log(event.request.destination);
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
