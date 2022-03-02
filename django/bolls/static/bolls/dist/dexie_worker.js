importScripts("/static/bolls/dist/dexie.min.js");
importScripts("/static/bolls/dist/jszip.min.js");

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



async function downloadZip(url, filename) {
	let data = await fetch(url)		// 1) fetch the url
		.then(function (response) {		// 2) filter on 200 OK
			if (response.status === 200 || response.status === 0) {
				return Promise.resolve(response.blob());
			} else {
				return Promise.reject(new Error(response.statusText));
			}
		})
		.then(JSZip.loadAsync)	// 3) chain with the zip promise
		.then(function (zip) {
			return zip.file(filename + '.json').async("string");	// 4) chain with the text content promise
		})
		.then(function success(text) {
			return JSON.parse(text)
		}, function error(e) {
			console.log(e)
			throw (filename);
		});
	return data
}

async function downloadTranslation(url) {
	let tranlslation = url.substring(21, url.length - 4)
	let data = await downloadZip(url, tranlslation)
	db.transaction("rw", db.verses, () => {
		db.verses.bulkPut(data)
			.then(() => {
				postMessage(['downloaded', tranlslation])
			});
	}).catch((e) => {
		throw (tranlslation);
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




async function downloadDictionary(request) {
	let data = await downloadZip(request.url, request.dictionary)
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
		console.log(e)
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
	}).catch((e) => {
		throw (search);
	})
}