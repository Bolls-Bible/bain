import fs from "fs";

// import translations_books and languages
import BOOKS from "../bolls/static/bolls/app/views/translations_books.json" with { type: "json" };
import LANGUAGES from "../bolls/static/bolls/app/views/languages.json" with { type: "json" };

const sitemapHeader =
  '<?xml version="1.0" encoding="utf-8" ?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">';

/** @type {Array<{short_name: string, full_name: string, updated: number}>} */
let translations = [];
for (const language of LANGUAGES)
  translations = translations.concat(language.translations);

function generateSitemap() {
  let urls = [
    "<url><loc>https://bolls.life</loc></url>",
    "<url><loc>https://bolls.life/api/</loc></url>",
    "<url><loc>https://bolls.life/downloads/</loc></url>",
    "<url><loc>https://bolls.life/donate/</loc></url>",
  ];
  for (let translation of translations)
    for (let book of BOOKS[translation.short_name])
      for (const chapter of Array.from(Array(book.chapters).keys()))
        urls.push(
          `<url><loc>https://bolls.life/${translation.short_name}/${
            book.bookid
          }/${chapter + 1}</loc></url>`
        );

  // there may be only 50k urls in a sitemap
  const sitemaps = [
    sitemapHeader +
      "<url><loc>https://bolls.life</loc></url><url><loc>https://bolls.life/api/</loc></url><url><loc>https://bolls.life/downloads/</loc></url><url><loc>https://bolls.life/donate/</loc></url>",
  ];
  let i = 0;
  for (let url of urls) {
    if (i === 50000) {
      sitemaps.push(sitemapHeader);
      i = 0;
    }
    sitemaps[sitemaps.length - 1] += url;
    i++;
  }

  for (let i = 0; i < sitemaps.length; i++) {
    sitemaps[i] += "</urlset>";
    console.log(`Writing sitemap${i}.xml`);
    const dir = '/home/bohuslav/bain/django/bolls/static/';
    if (!fs.existsSync(dir)){
        fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(`${dir}sitemap${i}.xml`, sitemaps[i]);
  }
}

generateSitemap()