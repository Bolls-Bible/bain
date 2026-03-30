Dexie = Dexie.default

const db = new Dexie('versesdb')

db.version(2).stores({
	verses: '&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]',
	bookmarks: '&verse, *collections'
}).upgrade (do |tx|
	return tx.table("bookmarks").toCollection().modify (do |bookmark|
		bookmark.collections = bookmark.notes
		delete bookmark.notes))
db.version(3).stores({
	verses: '&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]',
	bookmarks: '&verse, *collections',
	dictionaries: '++, dictionary'
})

export default db
