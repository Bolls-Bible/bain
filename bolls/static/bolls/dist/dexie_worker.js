importScripts("/static/bolls/dist/dexie.min.js");

Dexie = Dexie.default

let db = new Dexie('versesdb')

db.version(2).stores({
	verses: '&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]',
	bookmarks: '&verse, *collections'
})
db.version(3).stores({
	verses: '&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]',
	bookmarks: '&verse, *collections',
	dictionaries: '++, dictionary'
})

self.onmessage = function (msg) {
	if (msg.data.search_input) {
		search(msg.data);
	} else if (msg.data.action == 'delete') {
		deleteDictionary(msg.data.dictionary)
	} else if (msg.data.action == 'download_dictionary') {
		downloadDictionary(msg.data);
	} else if (msg.data.query) {
		dictionarySearch(msg.data)
	} else if (msg.data.includes('/static/translations/')) {
		downloadTranslation(msg.data);
	} else {
		deleteTranslation(msg.data);
	}
}

function downloadTranslation(url) {
	fetch(url)
		.then(response => response.json())
		.then(data => {
			db.transaction("rw", db.verses, () => {
				db.verses.bulkPut(data)
					.then(() => {
						postMessage(['downloaded', url.substring(21, url.length - 5)])
					}
					);
			}).catch((e) => {
				throw (url.substring(21, url.length - 5));
			}
			)
		}).catch((e) => {
			throw (url.substring(21, url.length - 5));
		})
}

function deleteTranslation(translation) {
	db.transaction("rw", db.verses, () => {
		db.verses.where({ translation: translation }).delete().then((deleteCount) =>
			postMessage([deleteCount, translation]))
	}).catch((e) => {
		throw (translation);
	})
}

function search(search) {
	db.transaction("r", db.verses, () => {
		db.verses.where({ translation: search.search_result_translation }).filter((verse) => { return verse.text.toLowerCase().includes(search.search_input); }
		).toArray().then(data => { postMessage(['search', data]); });
	}).catch((e) => {
		throw (search.search_result_translation);
	})
}





function downloadDictionary(request) {
	fetch(request.url)
		.then(response => response.json())
		.then(data => {
			for (let i = 0; i < data.length; i++) {
				data[i].dictionary = request.dictionary;
			}
			db.transaction("rw", db.dictionaries, () => {
				db.dictionaries.bulkPut(data)
					.then(() => {
						postMessage(['downloaded_dictionary', request.dictionary])
					}
					);
			}).catch((e) => {
				throw (request.dictionary);
			})
		}).catch((e) => {
			throw (request.dictionary);
		})
}

function deleteDictionary(dictionary) {
	db.transaction("rw", db.dictionaries, () => {
		db.dictionaries.where({ dictionary: dictionary }).delete().then((deleteCount) =>
			postMessage([deleteCount, dictionary]))
	}).catch((e) => {
		throw (dictionary);
	})
}

function dictionarySearch(search) {
	let uppercase_query = search.query.toUpperCase()
	db.transaction("r", db.dictionaries, () => {
		db.dictionaries.where({ dictionary: search.dictionary })
			.filter((definition) => {
				if (definition.topic.toUpperCase() == uppercase_query) {
					return true;
				}

				if (definition.short_definition) {
					let short_definition = definition.short_definition.toUpperCase();
					if (uppercase_query.indexOf(short_definition) > -1 || short_definition.indexOf(uppercase_query) > -1) {
						return true;
					}
				}

				if (search.query.includes(definition.lexeme) || definition.lexeme.includes(search.query)) {
					return true;
				} else
					return false;
			})
			.toArray().then(data => { postMessage(['search', data]); });
	}).catch((e) => {v
		throw (search);
	})
}