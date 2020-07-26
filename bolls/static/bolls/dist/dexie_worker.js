importScripts('/static/bolls/dist/dexie.min.js');

Dexie = Dexie.default

let db = new Dexie('versesdb')

db.version(1).stores({
	verses: '&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]',
	bookmarks: '&verse, *notes'
})

self.onmessage = function (msg) {
	console.log(msg.data);
	if (msg.data.charAt(0) == '/') {
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
			}).catch((e) =>
				console.error(e)
			)
		})
}

function deleteTranslation(translation) {
	db.transaction("rw", db.verses, () => {
		db.verses.where({ translation: translation }).delete().then((deleteCount) =>
			postMessage([deleteCount, translation]))
	}).catch((e) =>
		console.error(e)
	)
}