/// <reference lib="webworker" />

importScripts("/sw/dexie.min.js");
importScripts("/sw/jszip.min.js");

Dexie = Dexie.default;

const db = new Dexie("versesdb");

db.version(2).stores({
  verses:
    "&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]",
  bookmarks: "&verse, *collections",
});
db.version(3).stores({
  verses:
    "&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]",
  bookmarks: "&verse, *collections",
  dictionaries: "++, dictionary",
});

async function downloadZip(url, filename) {
  const data = await fetch(url) // 1) fetch the url
    .then((response) => {
      // 2) filter on 200 OK
      if (response.status === 200 || response.status === 0) {
        return Promise.resolve(response.blob());
      }
      return Promise.reject(new Error(response.statusText));
    })
    .then(JSZip.loadAsync) // 3) chain with the zip promise
    .then((zip) => {
      return zip.file(`${filename}.json`).async("string"); // 4) chain with the text content promise
    })
    .then(
      (text) => {
        return JSON.parse(text);
      },
      (e) => {
        console.error(e);
        throw filename;
      }
    );
  return data;
}

async function downloadTranslation(url) {
  const translation = url.split("/")[5];
  const data = await downloadZip(`${url}.zip`, translation);
  return db
    .transaction("rw", db.verses, async () => {
      return db.verses.bulkPut(data).then(() => {
        return new Response(JSON.stringify(data), {
          status: 200,
          statusText: "Downloaded translation",
        });
      });
    })
    .catch((e) => {
      return new Response(translation, {
        status: 500,
        statusText: e.message,
      });
    });
}

async function deleteTranslation(url) {
  const translation = url.split("/")[5];
  return db
    .transaction("rw", db.verses, () => {
      return db.verses
        .where({ translation: translation })
        .delete()
        .then(
          () =>
            new Response(translation, {
              status: 200,
              statusText: "Deleted translation",
            })
        );
    })
    .catch((e) => {
      return new Response(translation, {
        status: 500,
        statusText: e.message,
      });
    });
}
function isNTBook(bookid) {
  return bookid >= 43 && bookid <= 66;
}
async function searchVerses(urlStr) {
  const url = new URL(urlStr);
  const url_parts = url.pathname.split("/");
  const translation = url_parts[3];
  const query = decodeURI(url_parts[4]);
  const query_parts = query.split(" ");
  const PAGE_SIZE = 128;
  const filterBook = url.searchParams.get("book");
  const page = Number.parseInt(url.searchParams.get("page") || "1");
  const filterNumber = Number.parseInt(filterBook);

  return db
    .transaction("r", db.verses, () => {
      return db.verses
        .where({ translation: translation })
        .filter((verse) => {
          if (filterBook) {
            if (!filterNumber) {
              if (filterBook === "ot") {
                if (isNTBook(verse.book)) return false;
              } else if (filterBook === "nt") {
                if (!isNTBook(verse.book)) return false;
              }
            } else if (filterNumber !== verse.book) return false;
          }
          const lowercased_text = verse.text.toLowerCase();

          // If a few words are searched, all words must be present
          if (query_parts.length > 1)
            return query_parts
              .map((query_part) => lowercased_text.includes(query_part))
              .reduce((a, b) => a && b);
          return lowercased_text.includes(query);
        })
        .toArray()
        .then((data) => {
          // get NUMBER of exact matches
          let exact_matches = 0;
          for (let i = 0; i < data.length; i++) {
            exact_matches += (data[i].text.match(new RegExp(query, "g")) || [])
              .length;
          }
          // highlight exact matches with <mark> tag
          for (const verse of data) {
            for (const query_part of query_parts) {
              verse.text = verse.text.replace(
                new RegExp(query_part, "gi"),
                (match) => `<mark>${match}</mark>`
              );
            }
          }
          return new Response(
            JSON.stringify({
              data: data.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE),
              exact_matches,
              total: data.length,
            }),
            {
              status: 200,
              statusText: "Search verses",
            }
          );
        });
    })
    .catch((e) => {
      return new Response(translation, {
        status: 500,
        statusText: e.message,
      });
    });
}

async function downloadDictionary(url) {
  const dictionary = url.split("/")[5];
  const data = await downloadZip(`${url}.zip`, dictionary);
  for (const element of data) {
    element.dictionary = dictionary;
  }

  return db
    .transaction("rw", db.dictionaries, () => {
      return db.dictionaries.bulkPut(data).then(() => {
        return new Response(JSON.stringify(data), {
          status: 200,
          statusText: "Downloaded dictionary",
        });
      });
    })
    .catch((e) => {
      return new Response(dictionary, {
        status: 500,
        statusText: e.message,
      });
    });
}

async function deleteDictionary(url) {
  const dictionary = url.split("/")[5];
  return db
    .transaction("rw", db.dictionaries, () => {
      return db.dictionaries
        .where({ dictionary: dictionary })
        .delete()
        .then(() => new Response(dictionary, { status: 200 }));
    })
    .catch((e) => {
      return new Response(dictionary, {
        status: 500,
        statusText: e.message,
      });
    });
}

async function dictionarySearch(url) {
  const url_parts = url.split("/");
  const dictionary = url_parts[5];
  const query = decodeURI(url_parts[6]);
  const uppercase_query = query.toUpperCase();
  return db
    .transaction("r", db.dictionaries, () => {
      return db.dictionaries
        .where({ dictionary: dictionary })
        .filter((definition) => {
          if (definition.topic.toUpperCase() === uppercase_query) {
            return true;
          }

          if (definition.short_definition) {
            const short_definition = definition.short_definition.toUpperCase();
            if (
              uppercase_query.indexOf(short_definition) > -1 ||
              short_definition.indexOf(uppercase_query) > -1
            ) {
              return true;
            }
          }

          return (
            query.includes(definition.lexeme) ||
            definition.lexeme.includes(query)
          );
        })
        .toArray()
        .then((data) => {
          return new Response(JSON.stringify(data), {
            status: 200,
            statusText: "Dictionary search",
          });
        });
    })
    .catch((e) => {
      return new Response(dictionary, {
        status: 500,
        statusText: e.message,
      });
    });
}

async function getRandomVerse(url) {
  const translation = url.split("/")[5];
  return db
    .transaction("r", db.verses, () => {
      return db.verses
        .where({ translation: translation })
        .count()
        .then((count) => {
          return db.verses
            .where({ translation: translation })
            .offset(Math.floor(Math.random() * count))
            .limit(1)
            .toArray()
            .then((data) => {
              return new Response(JSON.stringify(data[0]), {
                status: 200,
                statusText: "Random verse",
              });
            });
        });
    })
    .catch((e) => {
      return new Response(translation, {
        status: 500,
        statusText: e.message,
      });
    });
}
