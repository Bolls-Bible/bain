import languages from "./views/languages.json"
import dictionaries from "./views/dictionaries.json"
import {english, ukrainian, russian, portuguese, espanol, german} from './langdata'

export class State
	db_is_available
	db

	downloaded_translations
	translations_in_downloading
	deleting_of_all_transllations
	translations_current_state = {}

	dictionaries_in_downloading
	downloaded_dictionaries
	deleting_of_all_dictionaries
	dictionaries_current_state = {}

	show_languages
	language
	lang
	notifications = []
	user = {}

	addBtn = no
	hideInstallPromotion = no
	deferredPrompt
	pswv = no # Play Store Web View

	translations = []
	timeoutID = undefined
	intouch = no

	set dictionary new_value
		#dictionary = new_value
		setCookie('dictionary', new_value)

	get dictionary
		return #dictionary


	def constructor
		for lngg in languages
			translations = translations.concat(lngg.translations)

		show_languages = no
		db_is_available = yes

		downloaded_translations = []
		translations_in_downloading = []
		deleting_of_all_transllations = no

		downloaded_dictionaries = []
		dictionaries_in_downloading = []
		deleting_of_all_dictionaries = no


		# Initialize the IndexedDB in order to be able to work with downloaded translations and offline bookmarks if such exist.
		db = new Dexie('versesdb')
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

		# To know as fast as possible if the user possibly is logged in.
		user.username = getCookie('username') || ''
		user.name = getCookie('name') || ''


		if window.navigator.userAgent.indexOf('Android') > -1 && window.navigator.userAgent.indexOf(' Bolls.2.1') > -1
			pswv = yes
			english["SUPPORT"].length = 4
			ukrainian["SUPPORT"].length = 4
			russian["SUPPORT"].length = 4
			portuguese["SUPPORT"].length = 4
			espanol["SUPPORT"].length = 4
			german["SUPPORT"].length = 4

		# If the user defined his language -- use it.
		if getCookie('language')
			setLanguage(getCookie('language'))
		# Otherwise, set the default language and translation in dependence with his browser navigator settings.
		else
			switch window.navigator.language.toLowerCase().slice(0, 2)
				when 'uk'
					language = 'ukr'
					document.lastChild.lang = "uk"
					if !window.translation
						setCookie('translation', 'UBIO')
				when 'ru'
					language = 'ru'
					document.lastChild.lang = "ru-RU"
					if !window.translation
						setCookie('translation', 'SYNOD')
				when 'es'
					language = 'es'
					document.lastChild.lang = "es"
					if !window.translation
						setCookie('translation', 'BTX3')
				when 'pt'
					language = 'pt'
					document.lastChild.lang = "pt"
					if !window.translation
						setCookie('translation', 'ARA')
				when 'de'
					language = 'de'
					document.lastChild.lang = "de"
					if !window.translation
						setCookie('translation', 'MB')
				when 'no'
					setDefaultTranslation 'DNB'
				when 'nl'
					setDefaultTranslation 'NLD'
				when 'fr'
					setDefaultTranslation 'NBS'
				when 'it'
					setDefaultTranslation 'NR06'
				when 'he'
					setDefaultTranslation 'WLCC'
				when 'zh'
					setDefaultTranslation 'CUV'
				when 'pl'
					setDefaultTranslation 'BW'
				when 'ja'
					setDefaultTranslation 'NJB'
				else
					language = 'eng'
					document.lastChild.lang = "en"
			setLanguage(language)
		if getCookie('dictionary')
			dictionary = getCookie('dictionary')
		else
			if language == 'ru' or language = 'ukr'
				dictionary = 'RUSD'
			else
				dictionary = 'BDBT'

		checkDownloadedData()

		# Update obsole translations if such exist.
		setTimeout(&, 2048) do
			checkTranslationsUpdates()
			checkSavedBookmarks()

		window.addEventListener('beforeinstallprompt', do(e)
			e.preventDefault()
			deferredPrompt = e
			addBtn = yes
			imba.commit!
		)

		window.addEventListener('appinstalled', do(event)
			// Clear the deferredPrompt so it can be garbage collected
			window.deferredPrompt = null
			hideInstallPromotion = yes
		)

		#  Detect if the app is installed in order to prevent the install app button and its text
		
		let isStandalone
		try
			isStandalone = window.matchMedia('(display-mode: standalone)').matches
		catch error
			console.log('The browser doesn\'t support matchMedia API', error)
		if (document.referrer.startsWith('android-app://'))
			hideInstallPromotion = yes
		elif (window.navigator.standalone || window.isStandalone)
			hideInstallPromotion = yes


	def setDefaultTranslation translation
		language = 'eng'
		document.lastChild.lang = "en"
		if !window.translation
			setCookie('translation', translation)


	def get_cookie name
		let cookieValue = null
		if document.cookie && document.cookie !== ''
			let cookies = document.cookie.split(';')
			for i in cookies
				let cookie = i.trim()
				if (cookie.substring(0, name.length + 1) === (name + '='))
					cookieValue = window.decodeURIComponent(cookie.substring(name.length + 1))
					break
		return cookieValue

	def getCookie c_name
		return window.localStorage.getItem(c_name)

	def setCookie c_name, value
		window.localStorage.setItem(c_name, value)

	def loadData url
		let res = await window.fetch url
		return res.json


	def checkDownloadedData
		downloaded_translations = JSON.parse(getCookie('downloaded_translations')) || []
		let checked_translations = await Promise.all(
			translations.map(
				do |translation|
					db.transaction('r', db.verses, do
						const resd = await db.verses.get({translation: translation.short_name})
						return resd.translation
					).catch(do
						return null
					)
			)
		)
		downloaded_translations = checked_translations.filter(do |item| return item != null) || []
		setCookie('downloaded_translations', JSON.stringify(downloaded_translations))

		downloaded_dictionaries = JSON.parse(getCookie('downloaded_dictionaries')) || []
		let checked_dictionaries = await Promise.all(
			dictionaries.map(
				do |dictionary|
					db.transaction('r', db.dictionaries, do
						const resd = await db.dictionaries.get({dictionary: dictionary.abbr})
						return resd.dictionary
					).catch(do
						return null
					)
			)
		)
		downloaded_dictionaries = checked_dictionaries.filter(do |item| return item != null) || []
		setCookie('downloaded_dictionaries', JSON.stringify(downloaded_dictionaries))
		imba.commit()


	def checkTranslationsUpdates
		let stored_translations_updates = JSON.parse(window.localStorage.getItem('stored_translations_updates'))
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
			window.localStorage.setItem('stored_translations_updates', JSON.stringify(translations_current_state))


	def checkSavedBookmarks
		let offline_bookmarks = []
		db.transaction('rw', db.bookmarks, do
			const stored_bookmarks_count = await db.bookmarks.count()
			if stored_bookmarks_count > 0 && window.navigator.onLine
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
					window.fetch("/save-bookmarks/", {
						method: "POST",
						cache: "no-cache",
						headers: {
							'X-CSRFToken': get_cookie('csrftoken'),
							"Content-Type": "application/json"
						},
						body: JSON.stringify({
							verses: JSON.stringify(bookmark.verses),
							color: bookmark.color,
							date: bookmark.date,
							collections: bookmark.collections
							note: bookmark.note
						}),
					})
					.then(do |response| response.json())
					.catch(do |e| console.error("sending offline bokmarks to server", e))
				)
				db.transaction('rw', db.bookmarks, do
					db.bookmarks.clear())
		).catch(do |e|
			db_is_available = no
			console.error('Uh oh : ' + e)
		)

	def downloadTranslation translation
		if (downloaded_translations.indexOf(translation) < 0 && window.navigator.onLine)
			translations_in_downloading.push(translation)
			let begtime = Date.now()
			let url = '/static/translations/' + translation + '.zip'

			let response = await window.fetch(url)
			if response.status == 200
				db_is_available = yes
				downloaded_translations.push(translation)
				setCookie('downloaded_translations', JSON.stringify(downloaded_translations))
				translations_in_downloading.splice(translations_in_downloading.indexOf(translation), 1)
				translations_current_state[translation] = Date.now()
				setCookie('stored_translations_updates', JSON.stringify(translations_current_state))
				console.log("Translation ", translation, " is saved. Time: ", (Date.now() - begtime) / 1000, "s")
				imba.commit!
			else
				handleDownloadingError(translation)

	def handleDownloadingError translation
		translations_in_downloading.splice(translations_in_downloading.indexOf(translation), 1)
		showNotification('error')

	def deleteTranslation translation, update = no
		downloaded_translations.splice(downloaded_translations.indexOf(translation), 1)
		translations_in_downloading.push(translation)
		let begtime = Date.now()
		db_is_available = no

		let response = await window.fetch('/sw/delete-translation/' + translation)
		console.log response
		if response.status == 200
			db_is_available = yes
			console.log( "Deleted ", translation, ". Time: ", (Date.now() - begtime) / 1000)
			translations_in_downloading.splice(translations_in_downloading.indexOf(translation), 1)
			delete translations_current_state[translation]
			setCookie('stored_translations_updates', JSON.stringify(translations_current_state))
			imba.commit!
			if update
				downloadTranslation(translation)
		else
			handleDownloadingError(translation)


	def downloadDictionary dictionary
		if (downloaded_dictionaries.indexOf(dictionary) < 0 && window.navigator.onLine)
			dictionaries_in_downloading.push(dictionary)
			let begtime = Date.now()
			let url = '/static/dictionaries/' + dictionary + '.zip'

			let response = await window.fetch(url)
			if response.status == 200
				db_is_available = yes
				downloaded_dictionaries.push(dictionary)
				setCookie('downloaded_dictionaries', JSON.stringify(downloaded_dictionaries))
				dictionaries_current_state[dictionary] = Date.now()
				setCookie('stored_dictionaries_updates', JSON.stringify(dictionaries_current_state))
				console.log("Dictionary ", dictionary, " is saved. Time: ", (Date.now() - begtime) / 1000, "s")
				imba.commit!
			else
				showNotification('error')
			dictionaries_in_downloading.splice(dictionaries_in_downloading.indexOf(dictionary), 1)

	def deleteDictionary dictionary, update = no
		downloaded_dictionaries.splice(downloaded_dictionaries.indexOf(dictionary), 1)
		dictionaries_in_downloading.push(dictionary)
		let begtime = Date.now()
		db_is_available = no

		let url = '/sw/delete-dictionary/' + dictionary
		let response = await window.fetch(url)
		if response.status == 200
			db_is_available = yes
			console.log("Deleted ", dictionary, ". Time: ", (Date.now() - begtime) / 1000)
			delete dictionaries_current_state[dictionary]
			setCookie('stored_dictionaries_updates', JSON.stringify(dictionaries_current_state))
			imba.commit!
			if update
				deleteDictionary(dictionary)
		else
			showNotification('error')
		dictionaries_in_downloading.splice(dictionaries_in_downloading.indexOf(dictionary), 1)

	def searchDefinitionsOffline search
		let begtime = Date.now()
		db_is_available = no

		def resolveSearch data
			db_is_available = yes
			console.log("Found ", data.length, " objects. Time: ", (Date.now() - begtime) / 1000)
			return data
		
		const url = '/sw/search-definitions/' + search.dictionary + '/' + search.query
		let response = await window.fetch(url)
		if response.status == 200
			let data = await response.json()
			return resolveSearch(data)
		else
			return resolveSearch([])


	def deleteBookmarks pks
		let begtime = Date.now()
		db.transaction("rw", db.bookmarks, do
			const res = await Promise.all(pks.map(do |pk|
				db.bookmarks.where({verse: pk}).delete().then(do |deleteCount|
					console.log( "Deleted ", deleteCount, " objects. Time: ", (Date.now() - begtime) / 1000)
				)
			))
		).catch(do |e|
			console.error(e)
		)

	def clearVersesTable
		deleting_of_all_transllations = yes
		db.transaction("rw", db.verses, do
			await db.verses.clear()
			downloaded_translations = []
			translations_in_downloading = []
			deleting_of_all_transllations = no
			imba.commit!
		).catch(do |e|
			console.error(e)
		)

	def clearDictionariesTable
		deleting_of_all_dictionaries = yes
		db.transaction("rw", db.dictionaries, do
			await db.dictionaries.clear()
			downloaded_dictionaries = []
			dictionaries_in_downloading = []
			deleting_of_all_dictionaries = no
			imba.commit!
		).catch(do |e|
			console.error(e)
		)


	def saveBookmarksToStorageUntillOnline bookmarkobj
		let bookmarks_to_save = []
		let bookmarks = await db.transaction("r", db.bookmarks, do
			return db.bookmarks.toArray()
		).catch (do |e|
			console.error(e)
		)

		for verse in bookmarkobj.verses
			# If a bookmark already exist -- first remove it, then add a new version
			console.log bookmarkobj
			if bookmarks.find(do |element| return element.verse == verse)
				deleteBookmarks([verse])
			bookmarks_to_save.push({
				verse: verse,
				date: bookmarkobj.date,
				color: bookmarkobj.color,
				collections: bookmarkobj.collections
				note: bookmarkobj.note
			})
		db.transaction("rw", db.bookmarks, do
			await db.bookmarks.bulkPut(bookmarks_to_save)
		).catch (do |e|
			console.error(e)
		)

	def getChapterBookmarksFromStorage pks
		db.transaction("r", db.bookmarks, do
			let offline_bookmarks = await Promise.all(
				pks.map(do |versepk|
					await db.bookmarks.get(versepk)
				)
			)
			let bookmarks = []
			for bookmark in offline_bookmarks
				if bookmark
					bookmark.collection = bookmark.collections.join(' | ')
					bookmarks.push bookmark
			return bookmarks
		).catch (do |e|
			console.error(e)
		)

	def getChapterFromDB translation, book, chapter, verse
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

	def getParallelVersesFromStorage compare_translations, choosen_for_comparison, compare_parallel_of_book, compare_parallel_of_chapter
		return await Promise.all(compare_translations.map(do |translation|
			const finded_verses = await Promise.all(choosen_for_comparison.map(do |verse|
				db.transaction("r", db.verses, do
					const wait_for_verses = await db.verses.get({translation: translation, book: compare_parallel_of_book, chapter: compare_parallel_of_chapter, verse: verse})
					return wait_for_verses ? wait_for_verses : {"translation": translation}
				).catch(do |e|
					console.error(e)
					return {"translation": translation}
				)))
			return finded_verses
		))

	def getSearchedTextFromStorage search
		let begtime = Date.now()
		db_is_available = no

		def resolveSearch data
			db_is_available = yes
			console.log("Found ", data.length, " objects. Time: ", (Date.now() - begtime) / 1000)
			return data

		const url = '/sw/search-verses/' + search.translation + '/' + search.search_input.toLowerCase()
		let response = await window.fetch(url)
		if response.status == 200
			let data = await response.json()
			return resolveSearch(data)
		else
			return resolveSearch([])

	# Used at Profile page
	def getBookmarksFromStorage
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

	def setLanguage lngg
		language = lngg
		switch lngg
			when 'ukr' then lang = ukrainian
			when 'ru' then lang = russian
			when 'pt' then lang = portuguese
			when 'es' then lang = espanol
			when 'de' then lang = german
			else lang = english
		setCookie('language', lngg)

	def fallbackCopyTextToClipboard text
		let textArea = document.createElement("textarea")
		textArea.value = text
		textArea.style.top = "0"
		textArea.style.left = "0"
		textArea.style.position = "fixed"

		document.body.appendChild(textArea)
		textArea.focus()
		textArea.select()

		try
			let successful = document.execCommand('copy')
			let msg = successful ? 'successful' : 'unsuccessful'
			console.log('Fallback: Copying text command was ' + msg)
		catch err
			console.error('Fallback: Oops, unable to copy', err)

		document.body.removeChild(textArea)
		showNotification('copied')


	def copyTextToClipboard text
		if !window.navigator.clipboard
			fallbackCopyTextToClipboard(text)
			return
		window.navigator.clipboard.writeText(text).then(
			do console.log('Async: Copying to clipboard was successful!')
		).catch(do |err|
			console.error('Async: Could not copy text: ', err)
			fallbackCopyTextToClipboard(text)
		)
		showNotification('copied')

	def copyToClipboard copyobj
		let text = '«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title
		copyTextToClipboard(text)

	def shareCopying copyobj
		let text = '«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title + ' ' + copyobj.translation + ' ' + "https://bolls.life" + '/'+ copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + versePart(copyobj.verse) + '/'
		copyTextToClipboard(text)

	def internationalShareCopying copyobj
		let text = '«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title + ' ' + copyobj.translation + ' ' + "https://bolls.life/international" + '/'+ copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + versePart(copyobj.verse) + '/'
		copyTextToClipboard(text)

	def versePart verses
		verses.length > 1 ? (verses.sort(do |a, b| return a - b)[0] + '-' + verses.sort(do |a, b| return a - b)[verses.length - 1]) : (verses.sort(do |a, b| return a - b)[0])

	def showNotification ntfctn
		if typeof timeoutID === 'number'
			window.clearTimeout(timeoutID)
		let ntfc = {
			id: Math.round(Math.random() * 4294967296)
		}

		if lang[ntfctn]
			ntfc.title = lang[ntfctn]
		else
			ntfc.title = ntfctn

		notifications.push ntfc

		setTimeout(&, 4000) do
			hideNotification(ntfc)
		timeoutID = setTimeout(&, 4500) do
			notifications = []
			imba.commit!

		imba.commit!

	def hideNotification ntfctn
		notifications.find(|el| return el == ntfctn).className = 'hide-notification'
		imba.commit!



	def requestDeleteBookmark pks
		deleteBookmarks(pks)
		if window.navigator.onLine
			window.fetch("/delete-bookmarks/", {
				method: "POST",
				cache: "no-cache",
				headers: {
					'X-CSRFToken': get_cookie('csrftoken'),
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					verses: JSON.stringify(pks),
				}),
			})
			.then(do |response| response.json())
			.then(do showNotification('deleted'))
			.catch(do |err|
				console.log err
				deleteLater (pks)
			)
		else deleteLater (pks)

	def deleteLater pks
		let bookmarks-to-delete = getCookie('bookmarks-to-delete')
		setCookie('bookmarks-to-delete', JSON.stringify(bookmarks-to-delete.concat(pks)))

	def getUserName
		if user.username
			if user.name
				return user.name
			return user.username
		return undefined
