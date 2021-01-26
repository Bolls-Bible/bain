import languages from "./languages.json"
import {english, ukrainian, russian, portuguese, espanol, german} from './langdata'


export class State
	prop downloaded_translations
	prop db_is_available
	prop db
	prop downloading_of_this_translations
	prop deleting_of_all_transllations
	prop show_languages
	prop language
	prop lang
	prop notifications = []
	prop user = {}
	prop translations_current_state = {}
	prop addBtn = no
	prop deferredPrompt
	prop translations = []
	prop timeoutID = undefined

	def constructor
		for lngg in languages
			translations = translations.concat(lngg.translations)
		db_is_available = yes
		downloaded_translations = []
		downloading_of_this_translations = []
		deleting_of_all_transllations = no
		show_languages = no

		# Initialize the IndexedDB in order to be able to work with downloaded translations and offline bookmarks if such exist.
		db = new Dexie('versesdb')
		db.version(2).stores({
			verses: '&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]',
			bookmarks: '&verse, *collections'
		}).upgrade (do |tx|
			return tx.table("bookmarks").toCollection().modify (do |bookmark|
				bookmark.collections = bookmark.notes
				delete bookmark.notes))

		# To know as fast as possible if the user possibly is logged in.
		user.username = getCookie('username') || ''
		user.name = getCookie('name') || ''

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
		checkDownloadedTranslations()
		checkSavedBookmarks()

		# Update obsole translations if such exist.
		setTimeout(&, 2048) do
			checkTranslationsUpdates()
		window.addEventListener('beforeinstallprompt', do |e|
			e.preventDefault()
			deferredPrompt = e
			addBtn = yes
			imba.commit()
		)

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

	def checkDownloadedTranslations
		downloaded_translations = JSON.parse(getCookie('downloaded_translations')) || []
		let checked_translations = await Promise.all(
			translations.map(
				do |translation|
					db.transaction('r', db.verses, do
						const resd = await db.verses.get({translation: translation.short_name})
						return resd.translation
					).catch(do |e|
						return null
					)
			)
		)
		downloaded_translations = checked_translations.filter(do |item| return item != null)
		setCookie('downloaded_translations', JSON.stringify(downloaded_translations))

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
		else
			stored_translations_updates = translations_current_state
			window.localStorage.setItem('stored_translations_updates', JSON.stringify(translations_current_state))

	def checkSavedBookmarks
		db.transaction('rw', db.bookmarks, do
			const stored_bookmarks_count = await db.bookmarks.count()
			if stored_bookmarks_count > 0 &&  window.navigator.onLine
				const bookmarks_in_offline = await db.bookmarks.toArray()
				let verses = []
				let bookmarks = []
				let date = bookmarks_in_offline[0].date
				let color = bookmarks_in_offline[0].color
				let collections = ''
				let note = bookmarks_in_offline[0].note
				for category, key in bookmarks_in_offline[0].collections
					collections += category
					if key + 1 < bookmarks_in_offline[0].collections.length
						collections += " | "
				let bkmrk = {
					verses: verses,
					date: date,
					color: color,
					collections: collections
					note: note
				}
				for bookmark in bookmarks_in_offline
					if bookmark.date == date
						verses.push(bookmark.verse)
					else
						bookmarks.push(bkmrk)
						verses = [bookmark.verse]
						date = bookmark.date
						color = bookmark.color
						for category, key in bookmark.collections
							collections += category
							if key + 1 < bookmark.collections.length
								collections += " | "
					if bookmark == bookmarks_in_offline[bookmarks_in_offline.length - 1]
						bookmarks.push(bkmrk)
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
					.then(do |data| undefined)
					.catch(do |e| console.error(e))
				)
				db.transaction('rw', db.bookmarks, do
					db.bookmarks.clear()
				)
		).catch(do |e|
			db_is_available = no
			console.error('Uh oh : ' + e)
		)

	def downloadTranslation translation
		if (downloaded_translations.indexOf(translation) < 0 && window.navigator.onLine)
			downloading_of_this_translations.push(translation)
			let begtime = Date.now()
			let url = '/static/translations/' + translation + '.json'

			def resolveDownload translation
				db_is_available = yes
				downloaded_translations.push(translation)
				setCookie('downloaded_translations', JSON.stringify(downloaded_translations))
				downloading_of_this_translations.splice(downloading_of_this_translations.indexOf(translation), 1)
				translations_current_state[translation] = Date.now()
				setCookie('stored_translations_updates', JSON.stringify(translations_current_state))
				console.log("Translation is saved. Time: ", (Date.now() - begtime) / 1000, "s")
				imba.commit()

			if window.Worker
				let dexieWorker = new Worker('/static/bolls/public/dexie_worker.js')

				dexieWorker.postMessage(url)

				dexieWorker.addEventListener('message', do |event|
					if event.data[0] == 'downloaded'
						resolveDownload(event.data[1]))

				dexieWorker.addEventListener('error', do |event|
					console.error('error received from dexieWorker => ', event)
					handleDownloadingError(translation))
			else
				let array_of_verses = null
				try
					array_of_verses = await loadData(url)
					console.log("Translation is downloaded. Time: ", (Date.now() - begtime) / 1000, "s")
				catch e
					console.error(e)
					handleDownloadingError(translation)
				if array_of_verses
					db_is_available = no
					db.transaction("rw", db.verses, do
						await db.verses.bulkPut(array_of_verses)
						resolveDownload()
					).catch (do |e|
						handleDownloadingError(translation)
						console.error(e)
					)

	def handleDownloadingError translation
		downloading_of_this_translations.splice(downloading_of_this_translations.indexOf(translation), 1)
		showNotification('error')

	def deleteTranslation translation, update = no
		downloaded_translations.splice(downloaded_translations.indexOf(translation), 1)
		downloading_of_this_translations.push(translation)
		let begtime = Date.now()
		db_is_available = no

		def resolveDeletion deleteCount
			db_is_available = yes
			console.log( "Deleted ", deleteCount[1], " objects of ",  deleteCount[0], ". Time: ", (Date.now() - begtime) / 1000)
			downloading_of_this_translations.splice(downloading_of_this_translations.indexOf(deleteCount[1]), 1)
			delete translations_current_state[deleteCount[1]]
			setCookie('stored_translations_updates', JSON.stringify(translations_current_state))
			imba.commit()
			if update
				downloadTranslation(translation)

		if window.Worker
			let dexieWorker = new Worker('/static/bolls/public/dexie_worker.js')

			dexieWorker.postMessage(translation)

			dexieWorker.addEventListener('message', do |event|
				if event.data[1] == translation
					resolveDeletion(event.data))

			dexieWorker.addEventListener('error', do |event|
				console.error('error received from dexieWorker => ', event)
				handleDownloadingError(translation))
		else
			db.transaction("rw", db.verses, do
				db.verses.where({translation: translation}).delete().then(do |deleteCount|
					resolveDeletion(deleteCount)
					return 1
				)
			).catch(do |e|
				console.error(e)
			)

	def deleteBookmark pks
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
			downloading_of_this_translations = []
			deleting_of_all_transllations = no
			imba.commit()
		).catch(do |e|
			console.error(e)
		)

	def saveBookmarksToStorageUntillOnline bookmarkobj
		let bookmarks_array = []
		let bookmarks = await db.transaction("r", db.bookmarks, do
			return db.bookmarks.toArray()
		).catch (do |e|
			console.error(e)
		)

		for verse in bookmarkobj.verses
			if bookmarks.find(do |element| return element.verse == verse)
				deleteBookmark([verse])
			bookmarks_array.push({
				verse: verse,
				date: bookmarkobj.date,
				color: bookmarkobj.color,
				collections: bookmarkobj.collections
				note: bookmarkobj.note
			})
		db.transaction("rw", db.bookmarks, do
			await db.bookmarks.bulkPut(bookmarks_array)
		).catch (do |e|
			console.error(e)
		)

	def getChapterBookmarksFromStorage bookmarks_array
		db.transaction("r", db.bookmarks, do
			let some_array = await Promise.all(
				bookmarks_array.map(do |versepk|
					await db.bookmarks.get(versepk)
				)
			)
			return some_array.filter(do |item| return item != undefined)
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
		search.search_input = search.search_input.toLowerCase()

		def resolveSearch data
			db_is_available = yes
			console.log("Finded ", data.length, " objects. Time: ", (Date.now() - begtime) / 1000)
			if data.length
				return data
			else
				return []

		if window.Worker
			return new Promise(do |resolveSearch|
				let dexieWorker = new Worker('/static/bolls/public/dexie_worker.js')

				dexieWorker.postMessage(search)

				dexieWorker.addEventListener('message', do |event|
					if event.data[0] == 'search'
						resolveSearch(event.data[1]))

				dexieWorker.addEventListener('error', do |event|
					console.error('error received from dexieWorker => ', event)
					return [])).then(do |data| resolveSearch(data))
		else
			db.transaction("r", db.verses, do
				let data = await db.verses.where({translation: search.search_result_translation}).filter(do |verse|
					return verse.text.includes(search.search_input)
				).toArray()
				resolveSearch(data)
			).catch(do |e|
				console.error(e)
				return []
			)

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

	def copyToClipboard copyobj
		let text = '«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title
		copyTextToClipboard(text)
		showNotification('copied')

	def shareCopying copyobj
		let text = '«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title + ' ' + copyobj.translation + ' ' + "https://bolls.life" + '/'+ copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + versePart(copyobj.verse) + '/'
		copyTextToClipboard(text)
		showNotification('copied')

	def internationalShareCopying copyobj
		let text = '«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title + ' ' + copyobj.translation + ' ' + "https://bolls.life/international" + '/'+ copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + versePart(copyobj.verse) + '/'
		copyTextToClipboard(text)
		showNotification('copied')

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
			imba.commit()

		imba.commit()

	def hideNotification ntfctn
		notifications.find(|el| return el == ntfctn).className = 'hide-notification'
		imba.commit()



	def requestDeleteBookmark pks
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
			.then(do |data| showNotification('deleted'))
		else
			# AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
			deleteBookmark(pks)
			setCookie('bookmarks-to-delete', JSON.stringify(pks))

	def hideBible
		let bible = document.getElementsByTagName("bible-reader")
		if bible[0]
			bible[0].classList.add("display_none")

	def showBible
		let bible = document.getElementsByTagName("bible-reader")
		if bible[0] then bible[0].classList.remove("display_none")

	def getUserName
		if user.username
			if user.name
				return user.name
			return user.username
		return undefined
