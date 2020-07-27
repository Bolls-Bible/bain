importScripts('/static/bolls/dist/dexie.min.js');

Dexie = Dexie.default

let db = new Dexie('versesdb')

db.version(1).stores({
	verses: '&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]',
	bookmarks: '&verse, *notes'
})

self.onmessage = function (msg) {
	console.log(msg.data);
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
					.then(() =>
						postMessage(url.substring(17, url.length - 1))
					);
			}).catch((e) => {
				console.error(e);
				throw (url.substring(17, url.length - 1));
			}
			)
		})
}

function deleteTranslation(translation) {
	db.transaction("rw", db.verses, () => {
		db.verses.where({ translation: translation }).delete().then((deleteCount) =>
			postMessage([deleteCount, translation]))
	}).catch((e) => {
		console.error(e);
		throw (translation);
	}
	)
}

function search(search) {
	db.transaction("r", db.verses, () => {
		db.verses.where({ translation: search.search_result_translation }).filter((verse) => { return verse.text.toLowerCase().includes(search.search_input); }
		).toArray().then(data => { postMessage(data); });
	})
}