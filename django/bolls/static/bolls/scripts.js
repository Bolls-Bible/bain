importScripts("/static/bolls/dexie.min.js");
importScripts("/static/bolls/jszip.min.js");

Dexie = Dexie.default;

let db = new Dexie("versesdb");

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
  let data = await fetch(url) // 1) fetch the url
    .then(function (response) {
      // 2) filter on 200 OK
      if (response.status === 200 || response.status === 0) {
        return Promise.resolve(response.blob());
      } else {
        return Promise.reject(new Error(response.statusText));
      }
    })
    .then(JSZip.loadAsync) // 3) chain with the zip promise
    .then(function (zip) {
      return zip.file(filename + ".json").async("string"); // 4) chain with the text content promise
    })
    .then(
      function success(text) {
        return JSON.parse(text);
      },
      function error(e) {
        console.error(e);
        throw filename;
      }
    );
  return data;
}

async function downloadTranslation(url) {
  const translation = url.split("/")[5];
  let data = await downloadZip(`${url}.zip`, translation);
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

async function searchVerses(url) {
  const url_parts = url.split("/");
  const translation = url_parts[5];
  const search_input = decodeURI(url_parts[6]);
  const search_input_parts = search_input.split(" ");
  return db
    .transaction("r", db.verses, () => {
      return db.verses
        .where({ translation: translation })
        .filter((verse) => {
          let lowercased_text = verse.text.toLowerCase();
          // If a few words are searched, all words must be present
          if (search_input_parts.length > 1)
            return search_input_parts
              .map((search_input_part) =>
                lowercased_text.includes(search_input_part)
              )
              .reduce((a, b) => a && b);
          return lowercased_text.includes(search_input);
        })
        .toArray()
        .then((data) => {
          return new Response(JSON.stringify(data), {
            status: 200,
            statusText: "Search verses",
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

async function downloadDictionary(url) {
  const dictionary = url.split("/")[5];
  let data = await downloadZip(`${url}.zip`, dictionary);
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
  let uppercase_query = query.toUpperCase();
  return db
    .transaction("r", db.dictionaries, () => {
      return db.dictionaries
        .where({ dictionary: dictionary })
        .filter((definition) => {
          if (definition.topic.toUpperCase() == uppercase_query) {
            return true;
          }

          if (definition.short_definition) {
            let short_definition = definition.short_definition.toUpperCase();
            if (
              uppercase_query.indexOf(short_definition) > -1 ||
              short_definition.indexOf(uppercase_query) > -1
            ) {
              return true;
            }
          }

          return query.includes(definition.lexeme) ||
            definition.lexeme.includes(query)
            ? true
            : false;
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
