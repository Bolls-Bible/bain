var CACHE_NAME = "v1.3.35";
var urlsToCache = [
  '/',
  '/static/bolls/dist/index.js',
  '/static/bolls/dist/index.css',
  '/static/bolls/fonts/fontstylesheet.css',
  '/static/bolls/dist/mobile_styles.css',
];

self.addEventListener('install', function (event) {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME)
    .then(function (cache) {
      console.log('👷', 'Opened cache ', CACHE_NAME);
      return cache.addAll(urlsToCache);
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((resp) => {
      return resp || fetch(event.request).then((response) => {
        var responseClone = response.clone();
        if (event.request.url.includes("get-text") || event.request.url.includes("search") || event.request.destination == "font") {
          caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, responseClone);
          });
        }
        return response;
      });
    }).catch(() => {
      return caches.match('/');
    })
  );
});

self.addEventListener('activate', (event) => {
  const expectedCaches = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then(keys => Promise.all(
      keys.map(key => {
        if (!expectedCaches.includes(key)) {
          return caches.delete(key);
        }
      })
    )).then(() => {
      console.log('👷 SW is activated and now ready to handle fetches!. ', CACHE_NAME);
      return self.clients.claim();
    })
  );
});