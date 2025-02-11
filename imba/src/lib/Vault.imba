import db from './dexie'

import { getValue, setValue } from '../utils' 

import notifications from './Notifications'
import API from './Api'

import { translations } from '../constants.imba'
import dictionaries from '../data/dictionaries.json'

class Vault
	available = yes
	downloaded_translations\string[] = []
	translationsDownloadQueue\string[] = []
	deletingEverything = no
	translations_current_state = {}

	dictionariesDownloadQueue\string[] = []
	downloaded_dictionaries\string[] = []
	dictionaries_current_state = {}

	def constructor
		# Initialize the IndexedDB in order to be able to work with downloaded translations and offline bookmarks if such exist.

		checkDownloadedData()

		# # Update obsolete translations if such exist.
		setTimeout(&, 2048) do
			checkTranslationsUpdates()
			checkSavedBookmarks()

	def checkSavedBookmarks
		let offline_bookmarks = []
		db.transaction('rw', db.bookmarks, do
			const stored_bookmarks_count = await db.bookmarks.count()
			if stored_bookmarks_count == 0 || !window.navigator.onLine
				return

			offline_bookmarks = await db.bookmarks.toArray()
			console.log offline_bookmarks

			unless offline_bookmarks.length
				console.log 'Nothing to save'
				return

			let bookmarks = [{
				verses: [offline_bookmarks[0].verse]
				date: offline_bookmarks[0].date
				color: offline_bookmarks[0].color
				collections: offline_bookmarks[0].collections.join(' | ')
				note: offline_bookmarks[0].note
			}]

			for offline_bookmark in offline_bookmarks
				if offline_bookmark.date == bookmarks[-1].date
					bookmarks[-1].verses.push(offline_bookmark.verse)
				else
					bookmarks.push({
						verses: [offline_bookmark.verse]
						date: offline_bookmark.date
						color: offline_bookmark.color
						collections: offline_bookmark.collections.join(' | ')
						note: offline_bookmark.note
					})

			bookmarks.map(do |bookmark|
				try
					await API.post('/save-bookmarks/', {
						verses: bookmark.verses,
						color: bookmark.color,
						date: bookmark.date,
						collections: bookmark.collections
						note: bookmark.note
					})
				catch e
					console.error("sending offline bokmarks to server", e))
			db.transaction('rw', db.bookmarks, do
				db.bookmarks.clear())
		).catch do |e|
			available = no
			console.error('Uh oh : ' + e)

	def checkDownloadedData
		downloaded_translations = getValue('downloaded_translations') || []
		let checked_translations = await Promise.all(
			translations.map(
				do |translation|
					db.transaction('r', db.verses, do
						const result = await db.verses.get({translation: translation.short_name})
						return result.translation
					).catch(do
						return null
					)
			)
		)
		downloaded_translations = checked_translations.filter(do |item| return item != null) || []
		setValue('downloaded_translations', downloaded_translations)

		downloaded_dictionaries = getValue('downloaded_dictionaries') || []
		let checked_dictionaries = await Promise.all(
			dictionaries.map(
				do |dictionary|
					db.transaction('r', db.dictionaries, do
						const result = await db.dictionaries.get({dictionary: dictionary.abbr})
						return result.dictionary
					).catch(do
						return null
					)
			)
		)
		downloaded_dictionaries = checked_dictionaries.filter(do |item| return item != null) || []
		setValue('downloaded_dictionaries', downloaded_dictionaries)
		imba.commit!


	def checkTranslationsUpdates
		let stored_translations_updates = getValue('stored_translations_updates')
		for translation in translations
			if downloaded_translations.indexOf(translation.short_name) > -1
				translations_current_state[translation.short_name] = translation.updated
		if stored_translations_updates
			for translation in downloaded_translations
				if translations_current_state[translation] > stored_translations_updates[translation]
					console.log("Need to be updated")
					deleteTranslation(translation, yes)
			console.log "finish translations update check"
		else
			stored_translations_updates = translations_current_state
			setValue('stored_translations_updates', translations_current_state)

	def downloadTranslation translation
		if (downloaded_translations.includes(translation) || !window.navigator.onLine)
			return

		translationsDownloadQueue.push(translation)
		console.time("DOWNLOADED {translation}")
		try
			let response = await window.fetch('/static/translations/' + translation)
			if response.status == 200
				downloaded_translations.push(translation)
				setValue('downloaded_translations', downloaded_translations)
				translationsDownloadQueue.splice(translationsDownloadQueue.indexOf(translation), 1)
				translations_current_state[translation] = Date.now()
				setValue('stored_translations_updates', translations_current_state)
				console.timeEnd("DOWNLOADED {translation}")
				imba.commit!
			else
				handleDownloadingError(translation)
		catch e
			console.log e
			handleDownloadingError(translation)

	def handleDownloadingError translation
		translationsDownloadQueue.splice(translationsDownloadQueue.indexOf(translation), 1)
		notifications.push('error')

	def deleteTranslation translation, update = no
		downloaded_translations.splice(downloaded_translations.indexOf(translation), 1)
		translationsDownloadQueue.push(translation)
		console.time("DELETED {translation}")

		let response = await window.fetch('/sw/delete-translation/' + translation)
		if response.status == 200
			console.timeEnd("DELETED {translation}")
			translationsDownloadQueue.splice(translationsDownloadQueue.indexOf(translation), 1)
			delete translations_current_state[translation]
			setValue('stored_translations_updates', translations_current_state)
			imba.commit!
			if update
				downloadTranslation(translation)
		else
			handleDownloadingError(translation)


	def downloadDictionary dictionary
		if (downloaded_dictionaries.indexOf(dictionary) < 0 && window.navigator.onLine)
			dictionariesDownloadQueue.push(dictionary)
			console.time("DOWNLOADED {dictionary}")
			let url = '/static/dictionaries/' + dictionary

			let response = await window.fetch(url)
			if response.status == 200
				downloaded_dictionaries.push(dictionary)
				setValue('downloaded_dictionaries', JSON.stringify(downloaded_dictionaries))
				dictionaries_current_state[dictionary] = Date.now()
				setValue('stored_dictionaries_updates', JSON.stringify(dictionaries_current_state))
				console.timeEnd("DOWNLOADED {dictionary}")
				imba.commit!
			else
				notifications.push('error')
			dictionariesDownloadQueue.splice(dictionariesDownloadQueue.indexOf(dictionary), 1)

	def deleteDictionary dictionary, update = no
		downloaded_dictionaries.splice(downloaded_dictionaries.indexOf(dictionary), 1)
		dictionariesDownloadQueue.push(dictionary)
		console.time("DELETED {dictionary}")

		let url = '/sw/delete-dictionary/' + dictionary
		let response = await window.fetch(url)
		if response.status == 200
			console.timeEnd("DELETED {dictionary}")
			delete dictionaries_current_state[dictionary]
			setValue('stored_dictionaries_updates', JSON.stringify(dictionaries_current_state))
			imba.commit!
			if update
				deleteDictionary(dictionary)
		else
			notifications.push('error')
		dictionariesDownloadQueue.splice(dictionariesDownloadQueue.indexOf(dictionary), 1)


	def clearVersesTable
		deletingEverything = yes
		db.transaction("rw", db.verses, do
			await db.verses.clear()
			downloaded_translations = []
			translationsDownloadQueue = []
			deletingEverything = no
			imba.commit
		).catch do |e|
			console.error(e)

	def clearDictionariesTable
		deletingEverything = yes
		db.transaction("rw", db.dictionaries, do
			await db.dictionaries.clear()
			downloaded_dictionaries = []
			dictionariesDownloadQueue = []
			deletingEverything = no
			imba.commit
		).catch do |e|
			console.error(e)



	def deleteBookmarks pks\number[]
		console.time("DELETE {pks}")
		db.transaction("rw", db.bookmarks, do
			const res = await Promise.all(pks.map(do |pk|
				db.bookmarks.where({verse: pk}).delete().then(do |deleteCount|
					console.log( "Deleted ", deleteCount, " objects")
					console.time("DELETE {pks}")
				)
			))
		).catch(do |e|
			console.error(e)
		)

	def saveBookmarksToStorageUntilOnline bookmark
		let bookmarks_to_save = []
		let bookmarks = await db.transaction("r", db.bookmarks, do
			return db.bookmarks.toArray()
		).catch (do |e|
			console.error(e)
		)

		for verse in bookmark.verses
			# If a bookmark already exist -- first remove it, then add a new version
			if bookmarks.find(do |element| return element.verse == verse)
				deleteBookmarks([verse])
			bookmarks_to_save.push({
				verse: verse,
				date: bookmark.date,
				color: bookmark.color,
				collections: bookmark.collections
				note: bookmark.note
			})
		db.transaction("rw", db.bookmarks, do
			await db.bookmarks.bulkPut(bookmarks_to_save)
		).catch (do |e|
			console.error(e)
		)

	def getChapterBookmarks pks\number[]
		db.transaction("r", db.bookmarks, do
			let offline_bookmarks = await Promise.all(
				pks.map(do |versePK|
					await db.bookmarks.get(versePK)
				)
			)
			let bookmarks = []
			for bookmark in offline_bookmarks
				if bookmark
					bookmark.collection = bookmark.collections.join(' | ')
					bookmarks.push bookmark
			return bookmarks || []
		).catch (do |e|
			console.error(e)
			return []
		)

	def getChapter translation\string, book\number, chapter\number
		db.transaction("r", db.verses, do
			let data = await db.verses.where({translation: translation, book: book, chapter: chapter}).toArray()
			if data.length
				data.sort(do |a, b| return a.verse - b.verse)
				return data
			else
				return []
		).catch(do |e|
			console.error(e)
			return []
		)

	def getCompareVerses compare_translations\string[], chosen_for_comparison, compare_parallel_of_book, compare_parallel_of_chapter
		return Promise.all(compare_translations.map(do |translation|
			const found_verses = await Promise.all(chosen_for_comparison.map(do |verse|
				db.transaction("r", db.verses, do
					const wait_for_verses = await db.verses.get({translation: translation, book: compare_parallel_of_book, chapter: compare_parallel_of_chapter, verse: verse})
					return wait_for_verses ? wait_for_verses : {"translation": translation}
				).catch(do |e|
					console.error(e)
					return {"translation": translation}
				)))
			return found_verses
		))

	def search searchUrl\string
		console.time('OFFLINE_SEARCH')

		def resolveSearch result
			console.timeEnd("OFFLINE_SEARCH")
			return result

		const url = '/sw/search-verses/' + searchUrl
		let response = await window.fetch(url)
		if response.status == 200
			let data = await response.json()
			return resolveSearch(data)
		else
			return resolveSearch({ data:[], total:0, exact_matches:0 })

	# Used at Profile page
	def getBookmarks
		db.transaction("r", db.bookmarks, db.verses, do
			let bookmarks = await db.bookmarks.toArray()
			bookmarks = Promise.all(bookmarks.map(do |bookmark|
				bookmark.verse = await db.transaction("r", db.verses, do
					db.verses.get({pk: bookmark.verse})
				).catch (do |e|
					console.error(e)
				)
				return bookmark
			))
			return bookmarks
		).catch (do |e|
			console.error(e)
		)

	def searchDefinitions search\{dictionary: string, query: string}
		console.time('OFFLINE_DICTIONARY_SEARCH')

		def resolveSearch data
			console.log("Found ", data.length, " objects")
			console.timeEnd("OFFLINE_DICTIONARY_SEARCH")
			return data

		const url = '/sw/search-definitions/' + search.dictionary + '/' + search.query
		let response = await window.fetch(url)
		if response.status == 200
			let data = await response.json()
			return resolveSearch(data)
		else
			return resolveSearch([])


const vault = new  Vault()

export default vault
