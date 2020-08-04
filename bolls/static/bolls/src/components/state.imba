import "./languages.json" as languages
import en_lang, uk_lang, ru_lang, pt_lang, es_lang from './langdata'

let translations = []
for language in languages
	translations = translations.concat(language:translations)

# let db = Dexie.new('versesdb')

# db.version(1).stores({
# 	verses: '&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]',
# 	bookmarks: '&verse, *notes'
# })

export class State
	prop downloaded_translations
	prop db_is_available
	prop db
	prop downloading_of_this_translations
	prop deleting_of_all_transllations
	prop show_languages
	prop language
	prop lang
	prop notifications default: []
	prop lastPushedNotificationWasAt
	prop user default: {}
	prop translations_current_state default: {}
	prop addBtn default: no
	prop deferredPrompt

	def initialize
		@db_is_available = yes
		@downloaded_translations = []
		@downloading_of_this_translations = []
		@deleting_of_all_transllations = no
		@show_languages = no
		@db = Dexie.new('versesdb')
		@db.version(1).stores({
			verses: '&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]',
			bookmarks: '&verse, *notes'
		})
		@user:username = getCookie('username') || ''
		if getCookie('language')
			setLanguage(getCookie('language'))
		else
			switch window:navigator:language.slice(0, 2)
				when 'uk'
					@language = 'ukr'
					document:lastChild:lang = "uk"
					if !window:translation
						setCookie('translation', 'UBIO')
				when 'ru'
					@language = 'ru'
					document:lastChild:lang = "ru-RU"
					if !window:translation
						setCookie('translation', 'SYNOD')
				when 'es'
					@language = 'es'
					document:lastChild:lang = "es"
					if !window:translation
						setCookie('translation', 'BTX3')
				when 'pt'
					@language = 'pt'
					document:lastChild:lang = "pt"
					if !window:translation
						setCookie('translation', 'ARA')
				when 'no'
					@language = 'eng'
					document:lastChild:lang = "en"
					if !window:translation
						setCookie('translation', 'DNB')
				when 'de'
					@language = 'eng'
					document:lastChild:lang = "en"
					if !window:translation
						setCookie('translation', 'MB')
				when 'he'
					@language = 'eng'
					document:lastChild:lang = "en"
					if !window:translation
						setCookie('translation', 'WLCC')
				when 'zh'
					@language = 'eng'
					document:lastChild:lang = "en"
					if !window:translation
						setCookie('translation', 'CUV')
				when 'pl'
					@language = 'eng'
					document:lastChild:lang = "en"
					if !window:translation
						setCookie('translation', 'BW')
				else
					@language = 'eng'
					document:lastChild:lang = "en"
			setLanguage(@language)
		checkDownloadedTranslations()
		checkSavedBookmarks()
		setTimeout(&, 2048) do
			checkTranslationsUpdates()
		window.addEventListener('beforeinstallprompt', do |e|
				e.preventDefault()
				deferredPrompt = e
				addBtn = yes
				Imba.commit
			)

	def get_cookie name
		let cookieValue = null
		if document:cookie && document:cookie !== ''
			let cookies = document:cookie.split(';')
			for i in cookies
				let cookie = i.trim()
				if (cookie.substring(0, name:length + 1) === (name + '='))
					cookieValue = window.decodeURIComponent(cookie.substring(name:length + 1))
					break
		return cookieValue

	def getCookie c_name
		return window:localStorage.getItem(c_name)

	def setCookie c_name, value
		window:localStorage.setItem(c_name, value)

	def loadData url
		let res = await window.fetch url
		return res.json

	def checkDownloadedTranslations
		@downloaded_translations = JSON.parse(getCookie('downloaded_translations')) || []
		let checked_translations = await Promise.all(
			translations.map(
				do |translation|
					db.transaction('r', db:verses, do
						const data = await db:verses.get({translation: translation:short_name})
						return data:translation
					).catch(do |e|
						return null
					)
			)
		)
		@downloaded_translations = checked_translations.filter(do |item| return item != null)
		setCookie('downloaded_translations', JSON.stringify(@downloaded_translations))

	def checkTranslationsUpdates
		let stored_translations_updates = JSON.parse(window:localStorage.getItem('stored_translations_updates'))
		for translation in translations
			if @downloaded_translations.indexOf(translation:short_name) > -1
				translations_current_state[translation:short_name] = translation:updated
		if stored_translations_updates
			for translation in @downloaded_translations
				if translations_current_state[translation] > stored_translations_updates[translation]
					console.log("Need to be updated")
					let werfvsd = await deleteTranslation(translation)
					if werfvsd
						downloadTranslation(translation)
		else
			stored_translations_updates = translations_current_state
			window:localStorage.setItem('stored_translations_updates', JSON.stringify(translations_current_state))

	def checkSavedBookmarks
		db.transaction('rw', db:bookmarks, do
			const stored_bookmarks_count = await db:bookmarks.count()
			if stored_bookmarks_count > 0 &&  window:navigator:onLine
				const bookmarks_in_offline = await db:bookmarks.toArray()
				let verses = [], bookmarks = [], date = bookmarks_in_offline[0]:date, color = bookmarks_in_offline[0]:color
				let notes = ''
				for category, key in bookmarks_in_offline[0]:notes
					notes += category
					if key + 1 < bookmarks_in_offline[0]:notes:length
						notes += " | "
				let bkmrk = {
					verses: verses,
					date: date,
					color: color,
					notes: notes
				}
				for bookmark in bookmarks_in_offline
					if bookmark:date == date
						verses.push(bookmark:verse)
					else
						bookmarks.push(bkmrk)
						verses = [bookmark:verse]
						date = bookmark:date
						color = bookmark:color
						for category, key in bookmark:notes
							notes += category
							if key + 1 < bookmark:notes:length
								notes += " | "
					if bookmark == bookmarks_in_offline[bookmarks_in_offline:length - 1]
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
							verses: JSON.stringify(bookmark:verses),
							color: bookmark:color,
							date: bookmark:date,
							notes: bookmark:notes
						}),
					})
					.then(do |response| response.json())
					.then(do |data| undefined)
					.catch(do |e| console.log(e))
				)
				db.transaction('rw', db:bookmarks, do
					db:bookmarks.clear()
				)
		).catch(do |e|
			@db_is_available = no
			console.log('Uh oh : ' + e)
		)

	def downloadTranslation translation
		if (@downloaded_translations.indexOf(translation) < 0 && window:navigator:onLine)
			@downloading_of_this_translations.push(translation)
			let begtime = Date.now()
			let url = '/get-translation/' + translation + '/'

			def resolveDownload translation
				@db_is_available = yes
				@downloaded_translations.push(translation)
				setCookie('downloaded_translations', JSON.stringify(@downloaded_translations))
				@downloading_of_this_translations.splice(@downloading_of_this_translations.indexOf(translation), 1)
				@translations_current_state[translation] = Date.now()
				setCookie('stored_translations_updates', JSON.stringify(translations_current_state))
				console.log("Translation is saved. Time: ", (Date.now() - begtime) / 1000, "s")
				Imba.commit

			if window:Worker
				let dexieWorker = Worker.new('/static/bolls/dist/dexie_worker.js')

				dexieWorker.postMessage(url)

				dexieWorker.addEventListener('message', do |event|
					if event:data[0] == 'downloaded'
						resolveDownload(event:data[1]))

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
					@db_is_available = no
					db.transaction("rw", db:verses, do
						await db:verses.bulkPut(array_of_verses)
						resolveDownload()
					).catch (do |e|
						handleDownloadingError(translation)
						console.error(e)
					)

	def handleDownloadingError translation
		@downloading_of_this_translations.splice(@downloading_of_this_translations.indexOf(translation), 1)
		showNotification('error')

	def deleteTranslation translation
		@downloaded_translations.splice(@downloaded_translations.indexOf(translation), 1)
		@downloading_of_this_translations.push(translation)
		let begtime = Date.now()
		@db_is_available = no

		def resolveDeletion deleteCount
			@db_is_available = yes
			console.log( "Deleted ", deleteCount[1], " objects of ",  deleteCount[0], ". Time: ", (Date.now() - begtime) / 1000)
			@downloading_of_this_translations.splice(@downloading_of_this_translations.indexOf(deleteCount[1]), 1)
			delete translations_current_state[deleteCount[1]]
			setCookie('stored_translations_updates', JSON.stringify(translations_current_state))
			Imba.commit

		if window:Worker
			let dexieWorker = Worker.new('/static/bolls/dist/dexie_worker.js')

			dexieWorker.postMessage(translation)

			dexieWorker.addEventListener('message', do |event|
				if event:data[1] == translation
					resolveDeletion(event:data))

			dexieWorker.addEventListener('error', do |event|
				console.error('error received from dexieWorker => ', event)
				handleDownloadingError(translation))
		else
			db.transaction("rw", db:verses, do
				db:verses.where({translation: translation}).delete().then(do |deleteCount|
					resolveDeletion(deleteCount)
					return 1
				)
			).catch(do |e|
				console.error(e)
			)

	def deleteBookmark pks
		let begtime = Date.now()
		db.transaction("rw", db:bookmarks, do
			const res = await Promise.all(pks.map(do |pk|
				db:bookmarks.where({verse: pk}).delete().then(do |deleteCount|
					console.log( "Deleted ", deleteCount, " objects. Time: ", (Date.now() - begtime) / 1000)
				)
			))
		).catch(do |e|
			console.error(e)
		)

	def clearVersesTable
		@deleting_of_all_transllations = yes
		db.transaction("rw", db:verses, do
			await db:verses.clear()
			@downloaded_translations = []
			@downloading_of_this_translations = []
			@deleting_of_all_transllations = no
			Imba.commit
		).catch(do |e|
			console.log(e)
		)

	def saveBookmarksToStorageUntillOnline bookmarkobj
		let bookmarks_array = []
		let bookmarks = await db.transaction("r", db:bookmarks, do
			return db:bookmarks.toArray()
		).catch (do |e|
			console.error(e)
		)

		for verse in bookmarkobj:verses
			if bookmarks.find(do |element| return element:verse == verse)
				deleteBookmark([verse])
			bookmarks_array.push({
				verse: verse,
				date: bookmarkobj:date,
				color: bookmarkobj:color,
				notes: bookmarkobj:notes
			})
		console.log bookmarks[0], bookmarks_array[0]
		db.transaction("rw", db:bookmarks, do
			await db:bookmarks.bulkPut(bookmarks_array)
		).catch (do |e|
			console.error(e)
		)

	def getChapterBookmarksFromStorage bookmarks_array
		db.transaction("r", db:bookmarks, do
			let some_array = await Promise.all(
				bookmarks_array.map(do |versepk|
					await db:bookmarks.get(versepk)
				)
			)
			return some_array.filter(do |item| return item != undefined)
		).catch (do |e|
			console.error(e)
		)

	def getChapterFromDB translation, book, chapter, verse
		db.transaction("r", db:verses, do
			let data = await db:verses.where({translation: translation, book: book, chapter: chapter}).toArray()
			if data:length
				data.sort(do |a, b| return a:verse - b:verse)
				return data
			else
				return []
		).catch(do |e|
			console.log(e)
			return []
		)

	def getParallelVersesFromStorage compare_translations, choosen_for_comparison, compare_parallel_of_book, compare_parallel_of_chapter
		return await Promise.all(compare_translations.map(do |translation|
			const finded_verses = await Promise.all(choosen_for_comparison.map(do |verse|
				db.transaction("r", db:verses, do
					const wait_for_verses = await db:verses.get({translation: translation, book: compare_parallel_of_book, chapter: compare_parallel_of_chapter, verse: verse})
					return wait_for_verses ? wait_for_verses : {"translation": translation}
				).catch(do |e|
					console.log(e)
					return {"translation": translation}
				)))
			return finded_verses
		))

	def getSearchedTextFromStorage search
		let begtime = Date.now()
		@db_is_available = no
		search:search_input = search:search_input.toLowerCase()

		def resolveSearch data
			@db_is_available = yes
			console.log("Finded ", data:length, " objects. Time: ", (Date.now() - begtime) / 1000)
			if data:length
				return data
			else
				return []

		if window:Worker
			return Promise.new(do |resolveSearch|
				let dexieWorker = Worker.new('/static/bolls/dist/dexie_worker.js')

				dexieWorker.postMessage(search)

				dexieWorker.addEventListener('message', do |event|
					if event:data[0] == 'search'
						resolveSearch(event:data[1]))

				dexieWorker.addEventListener('error', do |event|
					console.error('error received from dexieWorker => ', event)
					return [])).then(do |data| resolveSearch(data))
		else
			db.transaction("r", db:verses, do
				let data = await db:verses.where({translation: search:search_result_translation}).filter(do |verse|
					return verse:text.includes(search:search_input)
				).toArray()
				resolveSearch(data)
			).catch(do |e|
				console.error(e)
				return []
			)

	def getBookmarksFromStorage
		db.transaction("r", db:bookmarks, db:verses, do
			let bookmarks = await db:bookmarks.toArray()
			bookmarks = Promise.all(bookmarks.map(do |bookmark|
				bookmark:verse = await db.transaction("r", db:verses, do
					db:verses.get({pk: bookmark:verse})
				).catch (do |e|
					console.error(e)
				)
				return bookmark
			))
			return bookmarks
		).catch (do |e|
			console.error(e)
		)

	def setLanguage language
		@language = language
		switch language
			when 'ukr' then @lang = uk_lang
			when 'ru' then @lang = ru_lang
			when 'pt' then @lang = pt_lang
			when 'es' then @lang = es_lang
			else @lang = en_lang
		setCookie('language', language)

	def fallbackCopyTextToClipboard text
		let textArea = document.createElement("textarea")
		textArea:value = text
		textArea:style:top = "0"
		textArea:style:left = "0"
		textArea:style:position = "fixed"

		document:body.appendChild(textArea)
		textArea.focus()
		textArea.select()

		try
			let successful = document.execCommand('copy')
			let msg = successful ? 'successful' : 'unsuccessful'
			console.log('Fallback: Copying text command was ' + msg)
		catch err
			console.error('Fallback: Oops, unable to copy', err)

		document:body.removeChild(textArea)

	def copyTextToClipboard text
		if !window:navigator:clipboard
			fallbackCopyTextToClipboard(text)
			return
		window:navigator:clipboard.writeText(text).then(
			do console.log('Async: Copying to clipboard was successful!')
		).catch(do |err|
			console.error('Async: Could not copy text: ', err)
			fallbackCopyTextToClipboard(text)
		)

	def copyToClipboard copyobj
		let text = '«' + copyobj:text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj:title
		copyTextToClipboard(text)
		showNotification('copied')

	def shareCopying copyobj
		let text = '«' + copyobj:text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj:title + ' ' + copyobj:translation + ' ' + "https://bolls.life" + '/'+ copyobj:translation + '/' + copyobj:book + '/' + copyobj:chapter + '/' + versePart(copyobj:verse) + '/'
		copyTextToClipboard(text)
		showNotification('copied')

	def versePart verses
		verses:length > 1 ? (verses.sort(do |a, b| return a - b)[0] + '-' + verses.sort(do |a, b| return a - b)[verses:length - 1]) : (verses.sort(do |a, b| return a - b)[0])

	def showNotification ntfctn
		if @lang[ntfctn]
			@notifications.push(@lang[ntfctn])
		else @notifications.push(ntfctn)
		@lastPushedNotificationWasAt = Date.now()
		setTimeout(&, 5000) do
			if Date.now() - @lastPushedNotificationWasAt > 2000
				@notifications = []
				Imba.commit

	def requestDeleteBookmark pks
		if window:navigator:onLine
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
			deleteBookmark(bookmark:verse)
			setCookie('bookmarks-to-delete', JSON.stringify(pks))

	def hideBible
		let bible = document:getElementsByClassName("Bible")
		if bible[0]
			bible[0]:classList.add("display_none")

	def showBible
		let bible = document:getElementsByClassName("Bible")
		if bible[0] then bible[0]:classList.remove("display_none")

	def getUserName
		if @user:username
			if @user:name
				return @user:name
			return @user:username
		return undefined
