importScripts("/sw/jszip.min.js");
importScripts("/sw/dexie.min.js");
importScripts("/sw/scripts.js");

const CACHE_NAME = "v3.1.13";
const STATICS_CACHE = "statics-v1.0.15";
const TEXTS_CACHE = "texts-v1.0.6";

const urlsToCache = [
  "/",
  "/sw/jszip.min.js",
  "/sw/dexie.min.js",
  "/sw/scripts.js",
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
              // if the response is not ok, do not cache it
              if (!response || response.status < 200 || response.status >= 300) {
                return response;
              }
              // if the response is a zip file, do not cache it
              if (response.headers.get("Content-Type") == "application/zip") {
                return response;
              }

              // if this is chrome-extension then return the response
              if (url.includes("chrome-extension")) {
                return response;
              }
              var responseClone = response.clone();
              const texts_cache_eligible =
                url.includes("get-chapter/") ||
                url.includes("get-text/") ||
                url.includes("search/") ||
                url.includes("dictionary-definition/");
              const statics_cache_eligible =
                event.request.destination == "font" ||
                event.request.destination == "script" ||
                event.request.destination == "style" ||
                event.request.destination == "manifest" ||
                event.request.destination == "image";
              if (texts_cache_eligible || statics_cache_eligible) {
                console.log("Populating cache with ", url);
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
