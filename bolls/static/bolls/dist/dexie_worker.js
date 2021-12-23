importScripts("/static/bolls/dist/dexie.min.js");

Dexie = Dexie.default

let db = new Dexie('versesdb')

db.version(2).stores({
	verses: '&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]',
	bookmarks: '&verse, *collections'
})


self.onmessage = function (msg) {
	if (typeof msg.data == 'object') {
		search(msg.data);
	} else if (msg.data.charAt(0) == '/') {
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
						postMessage(['downloaded', url.substring(21, url.length - 5)])}
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
		throw (translation);
	})
}



function stripVowels(rawString){
	// Clear Hebrew
	let res =  rawString.replace(/[\u0591-\u05C7]/g,"");
	// Replace some letters, which are not present in a given unicode range, manually.
	res = res.replace('שׁ', 'ש');
	res = res.replace('שׂ', 'ש');
	res = res.replace('‎', '');

	// Clear Greek
	res = res.normalize('NFD').replace(/[\u0300-\u036f]/g, "");
	return res
}

function dictionarySearch(search) {
	let query = stripVowels(search.query);
	db.transaction("r", db.dictionary, () => {
		db.dictionary.where("dictionary")
		.equals(search.dictionary)
		.filter((definition) => {
			let uppercase_query = search.query.toUpperCase()
			if (definition.topic.toUpperCase() == uppercase_query) {
				return true;
			}

			let short_definition = definition.short_definition.toUpperCase();
			if (uppercase_query.includes(short_definition) || short_definition.includes(uppercase_query)) {
				return true;
			}

			let lexeme = stripVowels(definition.lexeme)
			if (uppercase_query.includes(lexeme) || lexeme.includes(uppercase_query)) {
				return true;
			} else
				return false;
		}
		).toArray().then(data => { postMessage(['search', data]); });
	}).catch((e) => {
		throw (translation);
	})
}