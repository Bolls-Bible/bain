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