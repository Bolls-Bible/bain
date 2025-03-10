import {default as BOOKS} from "./translations_books.json"
import languages from "./languages.json"
import dictionaries from "./dictionaries.json"
import './Profile.imba'
import "./loading.imba"
import "./downloads.imba"
import "./colorPicker.imba"
import './text-as-html.imba'
import "./note-up.imba"
import "./menu-popup.imba"
import "./mark-down.imba"
import './orderable-list.imba'
import {thanks_to} from './thanks_to.imba'
import {svg_paths, swirl, Heart} from "./svg_paths.imba"
import {scrollToY} from './smooth_scrolling.imba'
import { scoreSearch } from './scoreSearch.js'

let html = document.documentElement

let agent = window.navigator.userAgent;
let isWebkit = (agent.indexOf("AppleWebKit") > 0);
let isIPad = (agent.indexOf("iPad") > 0);
let isIOS = (agent.indexOf("iPhone") > 0 || agent.indexOf("iPod") > 0)
let isApple = isIPad || isIOS
let isAndroid = (agent.indexOf("Android")  > 0)
let isNewBlackBerry = (agent.indexOf("AppleWebKit") > 0 && agent.indexOf("BlackBerry") > 0)
let isWebOS = (agent.indexOf("webOS") > 0);
let isWindowsMobile = (agent.indexOf("IEMobile") > 0)
let isSmallScreen = (screen.width < 767 || (isAndroid && screen.width < 1000))
let isUnknownMobile = (isWebkit && isSmallScreen)
let isMobile = (isIOS || isAndroid || isNewBlackBerry || isWebOS || isWindowsMobile || isUnknownMobile)
# let isTablet = (isIPad || (isMobile && !isSmallScreen))
let MOBILE_PLATFORM = no

if isMobile && isSmallScreen && document.cookie.indexOf( "mobileFullSiteClicked=") < 0
	MOBILE_PLATFORM = yes

const DRAWERARROWWIDTH = do Math.min(32, Math.max(16, window.innerWidth * 0.02))
let print = console.log

let localFonts = new Set()
def checkFonts()
	if window.queryLocalFonts !== undefined
		// The Local Font Access API is supported
		// Query for all available fonts.
		try
			const availableFonts = await window.queryLocalFonts();
			for fontData of availableFonts
				localFonts.add(fontData.family)
		catch err
			console.error(err.name, err.message);
checkFonts()

def noop
	return

const inner_height = window.innerHeight
let iOS_keaboard_height = 0

let translations = []
for language in languages
	translations = translations.concat(language.translations)

let settings =
	translation: 'YLT'
	book: 1
	chapter: 1
	name_of_book: ''
	filtered_books: []

	theme: 'light'
	accent: 'blue'
	font:
		size: 20
		family: "'Ezra SIL', serif"
		name: "Ezra SIL"
		line-height: 1.8
		weight: 400
		max-width: 40
		align: ''

	verse_number: yes
	verse_break: no
	verse_picker: no
	verse_commentary: yes
	transitions: yes
	parallel_synch: yes
	lock_books_menu: no
	extended_dictionary_search: no
	enable_dynamic_contrast: no
	favorite_translations: []

	get light
		if this.theme == 'dark' or this.theme == 'black'
			return 'dark'
		return 'light'



# Detect dark mode
try
	if window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
		settings.theme = 'dark'
		settings.accent = 'gold'
catch error
	console.log "This browser doesn't support window.matchMedia: ", error

let settingsp = {
	enabled: no
	translation: 'WLCa'
	book: 1
	chapter: 1
	edited_version: settings.translatoin
	name_of_book: ''
	filtered_books: []
	
}

let chapter_headers = {
	fontsize1: 2
	fontsize2: 2
}

let onzone = no
let inzone = no
let bible_menu_left = -300
let settings_menu_left = -300
let menu_icons_transform = 0
let choosen = []
let choosenid = []
let highlights = []
let show_collections = no
let choosen_parallel = no
let lock_panel = no

let page_search =
	d: no
	query: ''
	matches: []
	current_occurence: 1
	rects: []

let store =
	newcollection: ''
	book_search: ''
	highlight_color: ''
	show_color_picker: no
	note: ''
	collections_search: ''
	compare_translations_search: ''
	show_fonts: no
	show_history: no
	show_themes: no
	show_dictionaries: no
	definition_search: ''
	font_search: ''
	contrast: 100

# Dictionary
let host_rectangle = null
let definitions = []
let definitions_history = []
let definitions_history_index = -1
let expanded_definition = 0
let download_dictionaries = no


# Some messy stuff
let showAddCollection = no
let choosen_categories = []
let loading = no
let menuicons = yes
let fixdrawers = no
let max_header_font = 0
let show_accents = no
let show_language_of = ''
let show_verse_picker = no
let show_parallel_verse_picker = no
let show_share_box = no
let big_modal_block_content = ''
let choosen_for_comparison = []
let comparison_parallel = []
let show_delete_bookmark = no
let show_translations_for_comparison = no
let welcome = yes
let slidetouch = null
let compare_parallel_of_chapter
let compare_parallel_of_book
let highlighted_title = ''
let scroll_timer = null
let scrolled_block = null

const fonts = [
	{
		name: "Sans Serif",
		code: "sans, sans-serif"
	},
	{
		name: "Raleway",
		code: "'Raleway', sans-serif"
	},
	{
		name: "David Libre",
		code: "'David Libre', serif"
	},
	{
		name: "Bellefair",
		code: "'Bellefair', serif"
	},
	{
		name: "Ezra SIL",
		code: "'Ezra SIL', serif"
	},
	{
		name: "Roboto Slab",
		code: "'Roboto Slab', sans-serif"
	},
	{
		name: "JetBrains Mono",
		code: "'JetBrains Mono', monospace"
	},
	{
		name: "Bookerly"
		code: "'Bookerly', sans-serif"
	},
	{
		name: "Deutsch Gothic",
		code: "'Deutsch Gothic', sans-serif"
	},
]

const accents = [
	{
		name:"blue"
		light:'hsl(219,100%,77%)'
		dark:'hsl(200,100%,32%)'
	}
	{
		name:"green"
		light:'hsl(80,100%,76%)'
		dark:'hsl(80,100%,32%)'
	}
	{
		name:"purple"
		light:'hsl(291,100%,76%)'
		dark:'hsl(291,100%,32%)'
	}
	{
		name:"gold"
		light:'hsl(43,100%,76%)'
		dark:'hsl(43,100%,32%)'
	}
	{
		name:"red"
		light:'hsl(0,100%,76%)'
		dark:'hsl(0,100%,32%)'
	}
]



tag bible-reader
	prop verses = []
	prop search_verses = {}
	prop parallel_bookmarks = []
	prop parallel_verses = []
	prop parallel_books = []
	prop bookmarks = []
	prop books = []
	prop show_chapters_of = 0
	prop show_list_of_translations = no
	prop show_languages = no
	prop history = []
	prop categories = []
	prop chronorder = no
	prop search = {suggestions:{}}
	userBookmarkMap = {}
	#main_header_arrow_size = ''

	get compare_translations
		return #compare_translations || [
			settings.translation
			settingsp.translation
		]

	set compare_translations new_translations
		unless new_translations
			return
		#compare_translations = new_translations
		if window.navigator.onLine && state.user.username
			window.fetch("/save-compare-translations/", {
				method: "PUT",
				cache: "no-cache",
				headers: {
					'X-CSRFToken': state.get_cookie('csrftoken'),
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					translations: JSON.stringify(new_translations),
				})
			})
		window.localStorage.setItem("compare_translations", JSON.stringify(new_translations))


	def setup
		# Setup some global events handlers
		# Detect change of dark/light mode
		try
			if window.matchMedia
				window.matchMedia('(prefers-color-scheme: dark)')
				.addEventListener('change', do |event|
					if event.matches
						changeTheme('dark')
					else
						changeTheme('light')
				)
		catch error
			log error

		# Focus the reader tag in order to enable keyboard navigation
		document.onfocus = do
			if document.getSelection().toString().length == 0
				focus!

		# We check this out in the case when url has parameters that indicates wantes translation, chapter, etc
		if window.translation
			if translations.find(do |element| return element.short_name == window.translation)
				if window.location.pathname.indexOf('international') > -1
					window.translation = getCookie('translation') || settings.translation
					window.verses = []
				setCookie('translation', window.translation)
				setCookie('book', window.book)
				setCookie('chapter', window.chapter)
				settings.translation = window.translation
				settings.book = window.book
				settings.chapter = window.chapter
				settings.name_of_book = nameOfBook(settings.book, settings.translation)
				document.title = " " + getNameOfBookFromHistory(window.translation, window.book) + ' ' + window.chapter
				if window.verses
					verses = window.verses
					getBookmarks("/get-bookmarks/" + window.translation + '/' + window.book + '/' + window.chapter + '/', 'bookmarks')
				if window.verse
					document.title += ':' + window.verse
					findVerse(window.verse, window.endverse)
				document.title += ' ' + window.translation + " Bolls Bible"

		if getCookie('theme')
			settings.theme = getCookie('theme')
			settings.accent = getCookie('accent') || settings.accent

			### This legacy should be removed in future ###
			const sepiaaa = getCookie('sepia') == 'true'
			const grayyy = getCookie('gray') == 'true'
			if sepiaaa
				settings.theme = 'sepia'
			if grayyy
				settings.theme = 'gray'
			window.localStorage.removeItem('sepia')
			window.localStorage.removeItem('gray')
			### ###
		changeTheme(settings.theme)

		if getCookie('transitions') == 'false'
			settings.transitions = no
			html.dataset.transitions = "false"
		
		try 
			let bookmarkMap = JSON.parse(window.localStorage.getItem("userBookmarkMap"))
			if bookmarkMap
				userBookmarkMap = bookmarkMap
		catch error
			window.localStorage.removeItem("userBookmarkMap")
			console.warn 'Error getting bookmarks map from localstorage', error


		welcome = getCookie('welcome') || welcome
		settings.font.size = parseInt(getCookie('font')) || settings.font.size
		settings.font.family = getCookie('font-family') || settings.font.family
		settings.font.name = getCookie('font-name') || settings.font.name
		settings.font.weight = parseInt(getCookie('font-weight')) || settings.font.weight
		settings.font.line-height = parseFloat(getCookie('line-height')) || settings.font.line-height
		settings.font.max-width = parseInt(getCookie('max-width')) || settings.font.max-width
		settings.font.align = getCookie('align') || settings.font.align
		settings.verse_picker = (getCookie('verse_picker') == 'true')
		settings.verse_commentary = !(getCookie('verse_commentary') == 'false')
		settings.lock_books_menu = (getCookie('lock_books_menu') == 'true')
		settings.verse_break = (getCookie('verse_break') == 'true')
		settings.extended_dictionary_search = (getCookie('extended_dictionary_search') === 'true')
		settings.verse_number = !(getCookie('verse_number') == 'false')
		settings.parallel_synch = !(getCookie('parallel_synch') == 'false')
		settings.translation = getCookie('translation') || settings.translation
		settings.book = parseInt(getCookie('book')) || settings.book
		settings.chapter = parseInt(getCookie('chapter')) || settings.chapter
		settingsp.translation = getCookie('parallel_translation') || settingsp.translation
		settingsp.book = parseInt(getCookie('parallel_book')) || settingsp.book
		settingsp.chapter = parseInt(getCookie('parallel_chapter')) || settingsp.chapter
		show_chapters_of = settings.book
		switchTranslation(settings.translation, no)
		settings.filtered_books = filteredBooks('books')
		settingsp.filtered_books = filteredBooks('parallel_books')

		if getCookie('parallel_display') == 'true'
			toggleParallelMode!

		getChapter(settings.translation, settings.book, settings.chapter)

		history = JSON.parse(getCookie("history")) || []
		history.sort(do(a, b) return a.date - b.date)

		if window.navigator.onLine
			try
				let userdata = await loadData("/user-logged/")
				if userdata.username
					state.user.is_password_usable = userdata.is_password_usable
					state.user.username = userdata.username
					setCookie('username', state.user.username)
					state.user.name = userdata.name || ''
					setCookie('name', state.user.name)
					if userdata.bookmarksMap
						userBookmarkMap = userdata.bookmarksMap
						setCookie('userBookmarkMap', JSON.stringify(userBookmarkMap))
					syncHistory!
				else
					window.localStorage.removeItem('username')
					window.localStorage.removeItem('name')
					window.localStorage.removeItem('userBookmarkMap')
					userBookmarkMap = {}
					state.user = {}
			catch err
				console.error('Error: ', err)
				# state.showNotification('error')

		if window.message
			state.showNotification(window.message)
		setChronorder getCookie('chronorder') == 'true'
		highlights = JSON.parse(getCookie("highlights")) || []
		menuicons = !(getCookie('menuicons') == 'false')
		fixdrawers = getCookie('fixdrawers') == 'true'

		store.contrast = parseInt(getCookie('contrast')) || store.contrast
		if getCookie('enable_dynamic_contrast') == 'true' 
			toggleDynamicContrast!

		compare_translations.push(settings.translation)
		compare_translations.push(settingsp.translation)
		if JSON.parse(getCookie("compare_translations"))
			compare_translations = (JSON.parse(getCookie("compare_translations")).length ? JSON.parse(getCookie("compare_translations")) : no) || compare_translations
		if JSON.parse(getCookie("favorite_translations"))
			settings.favorite_translations = JSON.parse(getCookie("favorite_translations"))
		
		search =
			search_div: no
			search_input: ''
			search_result_header: ''
			show_filters: no
			counter: 50
			results:0
			filter: ''
			loading: no
			change_translation: no
			bookid_of_results: []
			translation: settings.translation
			suggestions: {}
			match_case: getCookie('match_case') == 'true'
			match_whole: getCookie('match_whole') == 'true'
		
		let bookmarks-to-delete = JSON.parse(getCookie("bookmarks-to-delete"))
		if bookmarks-to-delete
			deleteBookmarks(bookmarks-to-delete)
			window.localStorage.removeItem("bookmarks-to-delete")


	def hidePanels event
		if !fixdrawers && (event.clientY < 0 || event.clientX < 0 || (event.clientX > window.innerWidth || event.clientY > window.innerHeight))
			onzone = no
			inzone = no
			bible_menu_left = -300
			settings_menu_left = -300
			imba.commit!

	def onSelectionChange
		if window.getSelection().toString().length > 0		
			this.showDefOptions!
		setTimeout(&, 150) do
			let selection = document.getSelection()
			if selection.isCollapsed
				host_rectangle = null

	def onPopState event
		clearSpace { onPopState: yes }
		# The event.state is not very reliable, may be null sometimes, hence we use window.location.pathname
		let link = window.location.pathname.split('/')
		if 'international' in link
			if link[2] && link[3] && link[4]
				getChapter settings.translation || link[2], parseInt(link[3]), parseInt(link[4]), parseInt(link[5])
		else
			if link[1] && link[2] && link[3]
				getChapter link[1], parseInt(link[2]), parseInt(link[3]), parseInt(link[4])

	def mount
		# silly analog of routed
		let link = window.location.pathname.split('/')
		if 'international' in link
			if link[2] && link[3] && link[4]
				getChapter settings.translation || link[2], parseInt(link[3]), parseInt(link[4]), parseInt(link[5])
		else
			if link[1] && link[2] && link[3]
				getChapter link[1], parseInt(link[2]), parseInt(link[3]), parseInt(link[4])

		document.addEventListener('selectionchange', onSelectionChange.bind(self))
		window.addEventListener('popstate', onPopState.bind(self))
		window.onblur = hidePanels
		document.body.onmouseleave = hidePanels
		document.onmouseleave = hidePanels
		window.onmouseout = hidePanels

		window.strongDefinition = do(topic)
			store.definition_search = topic
			loadDefinitions!
 
	def unmount
		document.removeEventListener('selectionchange', onSelectionChange.bind(self))
		window.removeEventListener('popstate', onPopState.bind(self))
		window.onblur = noop
		document.body.onmouseleave = noop
		document.onmouseleave = noop
		window.onmouseout = noop
		window.strongDefinition = null

	def searchPagination e
		if e.target.scrollTop > e.target.scrollHeight - e.target.clientHeight - 512 && search.counter < search_verses.length
			search.counter += 20

	# I call items from localStorage cookies :P
	def getCookie c_name
		window.localStorage.getItem(c_name)

	def setCookie c_name, value
		window.localStorage.setItem(c_name, value)

	def switchTranslation translation, parallel
		if parallel
			if settingsp.translation != translation || !parallel_books.length
				parallel_books = BOOKS[translation]
				settingsp.filtered_books = filteredBooks('parallel_books')
		else
			if settings.translation != translation || !books.length
				books = BOOKS[translation]
				settings.filtered_books = filteredBooks('books')

	def saveToHistory translation, book, chapter, verse
		if state.user.username && window.navigator.onLine
			history = await loadData('/history')

		if getCookie("history")
			history = JSON.parse(getCookie("history")) || []
		let already_recorded = history.find(do |element| return element.chapter == chapter && element.book == book && element.translation == translation)
		if already_recorded
			history.splice(history.indexOf(already_recorded), 1)

		history.sort(do(a, b) return b.date - a.date)

		history.unshift({translation: translation, book: book, chapter: chapter, verse: verse, date:Date.now!})
		if history.length > 256
			history.length = 256

		window.localStorage.setItem("history", JSON.stringify(history))
		saveHistoryToServer!

	def syncHistory
		if state.user.username && window.navigator.onLine
			let cloud_history = await loadData('/history')
			if cloud_history.compare_translations..length
				#compare_translations = JSON.parse(cloud_history.compare_translations) || []
				settings.favorite_translations = JSON.parse(cloud_history.favorite_translations) || []
			# Merge local history and server copy
			history = JSON.parse(getCookie("history")) || []
			try
				history = JSON.parse(cloud_history.history).concat(history)

				# Remove duplicates
				let unique_history = []
				for c in history
					let unique = unique_history.find(do |element| return element.chapter == c.chapter && element.book == c.book && element.translation == c.translation && element.parallel == c.parallel)
					if !unique && c.date >= cloud_history.purge_date
						unique_history.push(c)

				history = unique_history

			# Remove items exceeding limit
			if history.length > 256
				history.length = 256

			imba.commit!

			# Update history in localStorage and server
			if history.length
				window.localStorage.setItem("history", JSON.stringify(history))
				saveHistoryToServer!


	def saveHistoryToServer
		if state.user.username && window.navigator.onLine
			window.fetch("/history/", {
				method: "PUT",
				cache: "no-cache",
				headers: {
					'X-CSRFToken': state.get_cookie('csrftoken'),
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					history: JSON.stringify(history),
				})
			})
			.then(do |response| if(response.status !== 200)
				throw new Error(response.statusText)
			).catch(do |e| console.error(e))


	def toggleTranslationFavor translation_short_name
		if translation_short_name in settings.favorite_translations
			settings.favorite_translations.splice(settings.favorite_translations.indexOf(translation_short_name), 1)
		else
			settings.favorite_translations.push(translation_short_name)
		if window.navigator.onLine && state.user.username
			window.fetch("/api/save-favorite-translations/", {
				method: "PUT",
				cache: "no-cache",
				headers: {
					'X-CSRFToken': state.get_cookie('csrftoken'),
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					translations: JSON.stringify(settings.favorite_translations),
				})
			})
		window.localStorage.setItem("favorite_translations", JSON.stringify(settings.favorite_translations))

	def loadData url
		let res = await window.fetch(url)
		return res.json()

	def getBookmarks url, type
		let server_bookmarks = []
		let offline_bookmarks = []
		if window.navigator.onLine
			try
				server_bookmarks = await loadData(url)
			catch error
				console.warn error
				offline_bookmarks = []

		if state.db_is_available
			if type == 'bookmarks'
				offline_bookmarks = await state.getChapterBookmarksFromStorage(verses.map(do |verse| return verse.pk))
			else
				offline_bookmarks = await state.getChapterBookmarksFromStorage(parallel_verses.map(do |verse| return verse.pk))
		this[type] = offline_bookmarks.concat(server_bookmarks)
		imba.commit()

	def getText translation, book, chapter, verse
		getChapter translation, book, chapter, verse
		window.history.pushState({
			translation: translation,
			book: book,
			chapter: chapter,
			verse: verse,
		}
		'',
		window.location.origin + '/' + translation + '/' + book + '/' + chapter + '/' + (verse ? verse : ''))


	def getChapter translation, book, chapter, verse
		let changeParallel = yes
		unless theChapterExistInThisTranslation(translation, book, chapter)
			book = settings.book
			chapter = settings.chapter
			changeParallel = no

		const locations_are_same = window.location.pathname.includes("/{translation}/{book}/{chapter}/")
		if verses.length > 0 and locations_are_same
			if settings.translation == translation && settings.book == book && settings.chapter == chapter
				return

		loading = yes
		switchTranslation translation
		clearSpace()
		document.title = nameOfBook(book, translation) + ' ' + chapter + ' ' + translations.find(do |element| element.short_name == translation).full_name + " Bolls Bible"
		if chronorder
			setChronorder(yes)
		settings.book = book
		settings.chapter = chapter
		settings.translation = translation
		setCookie('book', book)
		setCookie('chapter', chapter)
		setCookie('translation', translation)
		settings.name_of_book = nameOfBook(settings.book, settings.translation)
		settings.filtered_books = filteredBooks('books')
		settingsp.filtered_books = filteredBooks('parallel_books')
		saveToHistory(translation, book, chapter, verse)
		let url = "/get-chapter/" + translation + '/' + book + '/' + chapter + '/'
		try
			verses = []
			imba.commit()
			if state.downloaded_translations.indexOf(translation) != -1
				verses = await state.getChapterFromDB(translation, book, chapter, verse)
			else
				verses = await loadData(url)
			loading = no
		catch error
			loading = no
			console.error('Error: ', error)
			if window.navigator.onLine
				state.showNotification('error')

		if settings.parallel_synch && settingsp.enabled && changeParallel
			getParallelText settingsp.translation, book, chapter, verse, yes
		if state.user.username then getBookmarks("/get-bookmarks/" + translation + '/' + book + '/' + chapter + '/', 'bookmarks')
		clearSpace!
		if verse
			if verse.length > 1
				findVerse(verse[0], verse[verse.length - 1])
			else
				findVerse(verse)
		else
			setTimeout(&, 100) do
				chapter_headers.fontsize1 = 2
				scrollToY($firstparallel,0)
				scrollToY(self, 0)
		if verse > 0 then show_verse_picker = no else show_verse_picker = yes
		show_chapters_of = book
		imba.commit()


	def getParallelText translation, book, chapter, verse, caller
		let changeParallel = yes
		unless theChapterExistInThisTranslation(translation, book, chapter)
			book = settingsp.book
			chapter = settingsp.chapter
			changeParallel = no

		if parallel_verses.length && !settingsp.enabled
			if settingsp.translation == translation && settingsp.book == book && settingsp.chapter == chapter
				return

		if chronorder
			setChronorder(yes)
		switchTranslation translation, yes
		settingsp.translation = translation
		settingsp.edited_version = settings.translation
		settingsp.book = book
		settingsp.chapter = chapter
		settingsp.name_of_book = nameOfBook(settingsp.book, settingsp.translation)
		settingsp.filtered_books = filteredBooks('parallel_books')
		clearSpace()
		let url = "/get-chapter/" + translation + '/' + book + '/' + chapter + '/'
		parallel_verses = []
		try
			if state.downloaded_translations.indexOf(translation) != -1
				parallel_verses = await state.getChapterFromDB(translation, book, chapter)
			else
				parallel_verses = await loadData(url)
			imba.commit()
		catch error
			console.error('Error: ', error)
			state.showNotification('error')
		if settings.parallel_synch && settingsp.enabled && changeParallel && not caller
			getText settings.translation, book, chapter, verse
		if state.user.username
			getBookmarks("/get-bookmarks/" + translation + '/' + book + '/' + chapter + '/', 'parallel_bookmarks')
		imba.commit()
		setCookie('parallel_display', settingsp.enabled)
		saveToHistory translation, book, chapter, 0
		setCookie('parallel_translation', translation)
		setCookie('parallel_book', book)
		setCookie('parallel_chapter', chapter)
		if verse
			findVerse("p{verse}")
		else
			setTimeout(&, 100) do
				chapter_headers.fontsize2 = 2
				scrollToY($secondparallel,0)
		if verses && !verse && settingsp.enabled
			show_parallel_verse_picker = true

	def theChapterExistInThisTranslation translation, book, chapter
		const theBook = BOOKS[translation]?.find(do |element| return element.bookid == book)
		if theBook
			if theBook.chapters >= chapter
				return yes
		return no


	def setScrolledBlock scroll_time
		unless scrolled_block
			let dummyblock = <div[size:0px]>
			dummyblock.classList.add('ref--firstparallel')
			dummyblock.classList.add('ref--secondparallel')
			document.body.appendChild(dummyblock)
			scrolled_block = dummyblock

			setTimeout(&, scroll_time * 1000) do
				scrolled_block = null
				document.body.removeChild(dummyblock)


	def findVerse id, endverse, highlight = yes
		setTimeout(&,250) do
			const verse = document.getElementById(id)
			if verse
				let topScroll = verse.offsetTop
				if (isIPad or isIOS) and page_search.d
					topScroll -= iOS_keaboard_height
				else
					topScroll -= (window.innerHeight * 0.05)

				let scroll_time
				if settingsp.enabled
					# verse.parentNode.parentNode.scroll({left:0, top: topScroll, behavior: 'smooth'})
					scroll_time = scrollToY(verse.parentNode.parentNode, topScroll)
				else
					scroll_time = scrollToY(self, topScroll)
				if highlight then highlightLinkedVerses(id, endverse)
				setScrolledBlock scroll_time
			else findVerse(id, endverse, highlight)


	def highlightLinkedVerses verse, endverse
		if isIOS
			return

		setTimeout(&, 250) do
			const versenode = document.getElementById(verse)
			unless versenode
				return highlightLinkedVerses verse, endverse

			const selection = window.getSelection()
			selection.removeAllRanges()
			if endverse
				for id in [parseInt(verse) .. parseInt(endverse)]
					if id <= verses.length
						const range = document.createRange()
						const node = document.getElementById(id)
						range.selectNodeContents(node)
						selection.addRange(range)
			else
				const range = document.createRange()
				range.selectNodeContents(versenode)
				selection.addRange(range)

	def closeVerseOptions
		choosen = []
		choosenid = []
		show_collections = no
		choosen_parallel = no
		showAddCollection = no
		store.show_color_picker = no
		choosen_categories = []


	def clearSpace { onPopState } = {}
		# If user write a note then instead of clearing everything just hide the note panel.
		if big_modal_block_content == "show_note"
			big_modal_block_content = ''
			return

		if (big_modal_block_content and not onPopState) or choosen.length > 0
			window.history.back()

		# Clean all the variables in order to free space around the text
		bible_menu_left = -300
		settings_menu_left = -300
		onzone = no
		inzone = no
		search.search_div = no
		store.show_history = no
		search.show_filters = no
		search.counter = 50
		definitions = []
		store.show_fonts = no
		show_language_of = ''
		show_translations_for_comparison = no
		show_parallel_verse_picker = no
		show_verse_picker = no
		show_share_box = no
		host_rectangle = null
		closeVerseOptions!

		# unless the user is typing something focus the reader in order to enable arrow navigation on the text
		unless page_search.d
			focus()
			window.getSelection().removeAllRanges()
		if page_search.d || big_modal_block_content
			page_search.d = no
			page_search.matches = []
			page_search.rects = []
		big_modal_block_content = ''
		imba.commit()


	def setChronorder shouldUseChronorder
		let orderBy = shouldUseChronorder ? 'chronorder' : 'bookid'
		parallel_books.sort(do |book, koob| return book[orderBy] - koob[orderBy])
		books.sort(do |book, koob| return book[orderBy] - koob[orderBy])

		settingsp.filtered_books = filteredBooks('parallel_books')
		settings.filtered_books = filteredBooks('books')

		chronorder = shouldUseChronorder
		setCookie('chronorder', chronorder.toString())

	def toggleChronorder
		setChronorder !chronorder
	
	def changeContrast event
		setCookie('contrast', store.contrast.toString())
		# set filter to the body
		document.body.style.filter = 'contrast(' + store.contrast + '%)'

	def toggleDynamicContrast
		settings.enable_dynamic_contrast = !settings.enable_dynamic_contrast
		setCookie('enable_dynamic_contrast', settings.enable_dynamic_contrast.toString())
		if settings.enable_dynamic_contrast
			document.body.style.filter = 'contrast(' + store.contrast + '%)'
		else
			document.body.style.filter = 'none'

	def nameOfBook bookid, translation
		if !translation
			return bookid
		for book in BOOKS[translation]
			if book.bookid == bookid
				return book.name
		return bookid

	get editedTranslation
		return settingsp.enabled ? settingsp.edited_version : settings.translation

	def pageSearch event
		let selectionStart = 0
		if event
			selectionStart = event.target.selectionStart

		# Show pageSearch box
		clearSpace()
		page_search.d = yes

		def focusInput
			if $pagesearch
				imba.commit().then do
					$pagesearch.focus()
					$pagesearch.setSelectionRange(selectionStart, selectionStart)
			else setTimeout(&,50) do focusInput()

		# Check if query is not an empty string
		unless page_search.query.length
			page_search.matches = []
			page_search.rects = []
			focusInput()
			return 0

		# if the query is not an emty string lets clean it up for regex
		let regex_compatible_query
		unless big_modal_block_content
			regex_compatible_query = page_search.query.replace(/[.*+\-?^${}()|[\]\\]/g, '\\$&')
		else
			regex_compatible_query = search.search_input.replace(/[.*+\-?^${}()|[\]\\]/g, '\\$&')

		# Lets get chapter node to iterate verses for match
		let all_articles = document.getElementsByTagName('article')
		let chapter_articles = []
		for article in all_articles
			# articles that does not have className contain chapters
			if article.nextSibling
				if article.nextSibling.className
					if article.nextSibling.className.includes('arrows')
						chapter_articles.push(article)

		let search_body = document.getElementById('search_body')

		def highlightText node, lastIndex, cssclass, parallel
			# Create range of matched text to get its position in document
			const range = document.createRange()

			let range_start = lastIndex - page_search.query.length
			let range_end_index = lastIndex
			let range_node

			# The node may contain multiple text nodes and some minor HTML tags like <i>, <b> or <br>
			# That is why we need to iterate through all the childNodes of the node
			# and find the node that contains the matched text
			for child in node.childNodes
				# if child is a text node
				# then check if its length is greater than the range_start
				# if it is then we found the node that contains the matched text
				if child.nodeType == 3
					if range_start < child.length
						range_node = child
						break
					else
						range_start -= child.length
						range_end_index -= child.length
				else
					# if child is not a text node then we need to check against its firstChild
					# if the length of the firstChild is greater than the range_start
					# then we found the node that contains the matched text
					# Again the fuss around firstChild is just guessing.
					# Ideally it should work well without deep recursion
					if range_start < child.firstChild.length
						range_node = child.firstChild
						break
					else
						range_start -= child.firstChild.length
						range_end_index -= child.firstChild.length

			range.setStart(range_node, range_start)	# Start at first character of query
			range.setEnd(range_node, range_end_index)	# End at last character

			def getSearchSelectionTopOffset rect_top
				if parallel == 'ps'
					return rect_top + search_body.scrollTop - search_body.offsetTop - search_body.parentNode.offsetTop
				elif settingsp.enabled
					if window.innerWidth < 639 && parallel
						return rect_top + chapter_articles[parallel].parentElement.scrollTop - chapter_articles[parallel].parentElement.offsetTop + iOS_keaboard_height
					else
						return rect_top + chapter_articles[parallel].parentElement.scrollTop + iOS_keaboard_height
				else return rect_top + scrollTop + iOS_keaboard_height

			def getSearchSelectionLeftOffset rect_left
				if parallel == 'ps'
					return rect_left - search_body.offsetLeft - search_body.parentNode.offsetLeft
				elif settingsp.enabled
					if window.innerWidth > 639 && parallel
						return rect_left - chapter_articles[parallel].parentNode.offsetLeft - DRAWERARROWWIDTH!
					else
						return rect_left - DRAWERARROWWIDTH!
				else return rect_left

			# getClientRects returns metrics of selections
			const rects = range.getClientRects()
			let selections = []
			for rect in rects
				if rect.width && rect.height
					# Save data about selection rectangles to display them later
					const selection = {
						top: getSearchSelectionTopOffset(rect.top)
						left: getSearchSelectionLeftOffset(rect.left)
						height: rect.height
						width: rect.width
						class: cssclass
						mathcid: node.id
					}
					# Save it to and array to display it later
					selections.push(selection)
			return selections

		def getSelectionHighlightRect child, lastIndex, parallel
			# Highlight found text
			if page_search.current_occurence == page_search.matches.length
				highlightText(child, lastIndex, 'current_occurence', parallel)
			else
				highlightText(child, lastIndex, 'another_occurences', parallel)

		def matchId node
			if node.id
				return node.id
			return node.nextSibling.id


		# Search process
		const regex1 = RegExp(regex_compatible_query, 'gi')
		let array1
		page_search.matches = []
		let parallel = 0

		for chapter in chapter_articles
			for child in chapter.children
				if child.tagName == 'NOTE-UP'
					continue
				while ((array1 = regex1.exec(child.textContent)) !== null)
					# Save the index of found text to page_search.matches
					# for further navigation
					page_search.matches.push({
						id: matchId(child),
						rects: getSelectionHighlightRect(child, regex1.lastIndex, parallel)
					})

			parallel++

		# Gather all rects to one array
		page_search.rects = []
		let nskrjvnslif = []
		for match in page_search.matches
			nskrjvnslif = nskrjvnslif.concat match.rects
		page_search.rects = nskrjvnslif

		# After all scroll to results
		if page_search.current_occurence > page_search.matches.length - 1
			page_search.current_occurence = 0
			if page_search.matches.length
				pageSearch()
		if page_search.matches[page_search.current_occurence]
			findVerse(page_search.matches[page_search.current_occurence].id, no, no)
		# focusInput()
		imba.commit()


	def changeSelectionRectClass class_name
		if page_search.matches[page_search.current_occurence]
			let rects = page_search.matches[page_search.current_occurence].rects
			for rect in rects
				rect.class = class_name

	def prevOccurence
		changeSelectionRectClass('another_occurences')
		if page_search.current_occurence == 0
			page_search.current_occurence = page_search.matches.length - 1
		else
			page_search.current_occurence--
		changeSelectionRectClass('current_occurence')
		if page_search.matches[page_search.current_occurence]
			findVerse(page_search.matches[page_search.current_occurence].id, no, no)
		imba.commit()

	def nextOccurence
		changeSelectionRectClass('another_occurences')
		if page_search.current_occurence == page_search.matches.length - 1
			page_search.current_occurence = 0
		else
			page_search.current_occurence++
		changeSelectionRectClass('current_occurence')
		if page_search.matches[page_search.current_occurence] then findVerse(page_search.matches[page_search.current_occurence].id, no, no)
		imba.commit()


	def turnHelpBox
		if big_modal_block_content == "show_help"
			clearSpace()
		else
			clearSpace()
			popUp 'show_help'

	def turnSupport
		if big_modal_block_content == "show_support"
			clearSpace()
		else
			clearSpace()
			popUp 'show_support'

	def toggleParallelMode
		if settingsp.enabled
			settingsp.enabled = no
			clearSpace()
		else
			settingsp.enabled = yes
			if settings.parallel_synch
				getParallelText(settingsp.translation, settings.book, settings.chapter)
			else
				getParallelText(settingsp.translation, settingsp.book, settingsp.chapter)
		setCookie('parallel_display', settingsp.enabled)

	def changeEditedParallel translation
		settingsp.edited_version = translation
		if search.change_translation
			getSearchText()
			search.change_translation = no
		show_list_of_translations = no

	def swapTranslations
		let main_translation = settings.translation
		let main_book = settings.book
		let main_chapter = settings.chapter
		getText(settingsp.translation, settingsp.book, settingsp.chapter)
		getParallelText(main_translation, main_book, main_chapter)


	def changeTranslation translation
		if settingsp.enabled && settingsp.edited_version == settingsp.translation
			switchTranslation(translation, yes)
			if parallel_books.find(do |element| return element.bookid == settingsp.book)
				getParallelText(translation, settingsp.book, settingsp.chapter)
			else
				getParallelText(translation, parallel_books[0].bookid, 1)
				settingsp.book = parallel_books[0].bookid
				settingsp.chapter = 1
			settingsp.translation = translation
		else
			switchTranslation(translation, no)
			if books.find(do |element| return element.bookid == settings.book)
				getText(translation, settings.book, settings.chapter)
			else
				getText(translation, books[0].bookid, 1)
				settings.book = books[0].bookid
				settings.chapter = 1
			settings.translation = translation
			setCookie('translation', translation)
		if search.change_translation
			getSearchText()
			search.change_translation = no
		show_list_of_translations = no


	def focusElement id
		setTimeout(&,250) do
			const theel = document.getElementById(id)
			if theel
				theel.focus!
			else focusElement id

	def turnGeneralSearch
		clearSpace!
		popUp 'search'
		searchSuggestions!
		setTimeout(&, 300) do $generalsearch.select!

	def ntBook bookid
		if 43 < bookid < 67
			return yes
		return no

	def isNumber str
		return !isNaN(str) && !isNaN(parseFloat(str))

	def getSearchTranslation
		if settingsp.edited_version == settingsp.translation && settingsp.enabled
			return settingsp.edited_version
		return settings.translation

	def getSearchText e
		# Clear the searched text to preserver the request for breaking
		let query = search.search_input

		# If the query is long enough -- do the search
		if query.length > 2 || isNumber(query)
			if big_modal_block_content !== 'search'
				clearSpace!
				popUp 'search'
			$generalsearch.blur!
			search.search_result_header = ''
			loading = yes

			search.translation = getSearchTranslation!
			const url = '/search/' + search.translation + '/?search=' + window.encodeURIComponent(query) + '&match_case=' + search.match_case + '&match_whole=' + search.match_whole + '&book=' + search.filter

			search_verses = {}
			try
				let res = await window.fetch(url)
				# extract Exact_matches from headers
				search.results = res.headers.get("exact_matches")
				search_verses = await res.json()
			catch error
				console.error error
				if state.downloaded_translations.indexOf(search.translation) != -1
					let { data, exact_matches } = await state.getSearchedTextFromStorage(search)
					search_verses = data
					search.results = exact_matches
				else
					search_verses = []

			search.bookid_of_results = []
			for verse in search_verses
				if !search.bookid_of_results.find(do |element| return element == verse.book)
					search.bookid_of_results.push verse.book

			closeSearch!
			imba.commit!


	def closeSearch close
		loading = no
		search.counter = 50
		search.search_div = yes
		if close
			search.search_div = !search.search_div
			search.change_translation = no
			clearSpace()
		search.search_result_header = search.search_input
		settings_menu_left = -300
		if document.getElementById('search')
			document.getElementById('search').blur()

	def suggestTranslations query
		let suggested_translations = []
		if query.length > 2
			for translation in translations
				if query in translation.short_name.toLowerCase! or query in translation.full_name.toLowerCase!
					suggested_translations.push(translation)
		return suggested_translations

	def searchSuggestions
		const query = search.search_input.trim!.toLowerCase!

		const parts = query.split(' ')
		let numbers_part = ''
		for part, index in parts when index > 0
			if /\d/.test(part)
				numbers_part = part
				break

		search.suggestions.chapter = null
		search.suggestions.verse = null
		search.suggestions.translation = null

		# Check if the ending of the query contains numbers
		if numbers_part
			# If verse is included
			if numbers_part.indexOf(':') > -1
				const ch_v_numbers = numbers_part.split(':')
				search.suggestions.chapter = parseInt(ch_v_numbers[0])
				if ch_v_numbers[1].length
					search.suggestions.verse = parseInt(ch_v_numbers[1])
			else
				search.suggestions.chapter = parseInt(numbers_part)

			if numbers_part != parts[-1]
				# Then test also translation part
				search.suggestions.translation = suggestTranslations(parts[-1])[0]..short_name
				parts.pop!
				parts.pop!
			else
				parts.pop!
		unless search.suggestions.translation
			search.suggestions.translation = settings.translation


		# If no numbers provided -- suggest first chapter
		unless search.suggestions.chapter
			search.suggestions.chapter = 1

		const bookname = parts.join(' ')

		let filtered_books = []
		if bookname.length > 1
			for book in self['books'] # in aa given translations book
				const score = scoreSearch(book.name, bookname)
				if score > bookname.length * 0.75
					filtered_books.push({
						book: book
						score: score
					})

			filtered_books = filtered_books.sort(do |a, b| b.score - a.score)


		# Generate suggestions list
		search.suggestions.books = []
		for item in filtered_books
			if theChapterExistInThisTranslation settings.translation, item.book.bookid, search.suggestions.chapter
				search.suggestions.books.push item.book

		search.suggestions.translations = suggestTranslations(query)

	def addFilter book
		page_search.matches = []
		page_search.rects = []
		search.filter = book
		search.show_filters = no
		search.counter = 50
		let search_body = document.getElementById('search_body')
		search_body.scrollTo(0,0)

	def dropFilter
		search.filter = ''
		search.show_filters = no
		search.counter = 50
		let search_body = document.getElementById('search_body')
		search_body.scrollTo(0,0)
		getSearchText!


	def getFilteredSearchVerses
		if search.filter
			if search.filter == "ot"
				return search_verses.filter(do |verse| !ntBook(verse.book))
			elif search.filter == "nt"
				return search_verses.filter(do |verse| ntBook(verse.book))
			else
				return search_verses.filter(do |verse| verse.book == search.filter)
		else
			return search_verses

	def isBookPresentInSearchResults bookid
		return search.bookid_of_results.find(do |element| return element == bookid)


	def changeTheme theme
		html.dataset.pukaka = 'yes'
		settings.theme = theme

		html.dataset.accent = settings.accent + settings.light
		html.dataset.theme = settings.theme

		state.setCookie('theme', theme)

		setTimeout(&, 75) do
			imba.commit!.then do html.dataset.pukaka = 'no'


	def changeAccent accent
		settings.accent = accent
		html.dataset.accent = settings.accent + settings.light
		setCookie('accent', accent)
		show_accents = no

	def getRandomColor
		return 'rgb(' + Math.round(Math.random()*255) + ',' + Math.round(Math.random()*255) + ',' + Math.round(Math.random()*255) + ')'

	def decreaseFontSize
		if settings.font.size > 14
			settings.font.size -= 2
			setCookie('font', settings.font.size)

	def increaseFontSize
		if settings.font.size < 64 && window.innerWidth > 480
			settings.font.size = settings.font.size + 2
		elif settings.font.size < 40
			settings.font.size = settings.font.size + 2
		setCookie('font', settings.font.size)

	def setFontFamily font
		settings.font.family = font.code
		settings.font.name = font.name
		setCookie('font-family', font.code)
		setCookie('font-name', font.name)
	
	def setLocalFontFamily font
		clearSpace!
		settings.font.family = font
		settings.font.name = font
		setCookie('font-family', font)
		setCookie('font-name', font)

	def showChapters bookid
		if bookid != show_chapters_of
			show_chapters_of = bookid
		else show_chapters_of = 0

	def showLanguageTranslations language
		if language != show_language_of
			show_language_of = language
		else show_language_of = ''

	def chaptersOfCurrentBook parallel
		if parallel
			for book in parallel_books
				if book.bookid == settingsp.book
					return book.chapters
		else
			for book in books
				if book.bookid == settings.book
					return book.chapters

	def nextChapter parallel=no
		if parallel
			if settingsp.chapter + 1 <= chaptersOfCurrentBook parallel
				getParallelText(settingsp.translation, settingsp.book, settingsp.chapter + 1)
			else
				let current_index = parallel_books.indexOf(parallel_books.find(do |element| return element.bookid == settingsp.book))
				if parallel_books[current_index + 1]
					getParallelText(settingsp.translation, parallel_books[current_index + 1].bookid, 1)
		else
			if settings.chapter + 1 <= chaptersOfCurrentBook parallel
				getText(settings.translation, settings.book, settings.chapter + 1)
			else
				let current_index = books.indexOf(books.find(do |element| return element.bookid == settings.book))
				if books[current_index + 1]
					getText(settings.translation, books[current_index + 1].bookid, 1)

	def prevChapter parallel=no
		if parallel
			if settingsp.chapter - 1 > 0
				getParallelText(settingsp.translation, settingsp.book, settingsp.chapter - 1)
			else
				let current_index = parallel_books.indexOf(parallel_books.find(do |element| return element.bookid == settingsp.book))
				if parallel_books[current_index - 1]
					getParallelText(settingsp.translation, parallel_books[current_index - 1].bookid, parallel_books[current_index - 1].chapters)
		else
			if settings.chapter - 1 > 0
				getText(settings.translation, settings.book, settings.chapter - 1)
			else
				let current_index = books.indexOf(books.find(do |element| return element.bookid == settings.book))
				if books[current_index - 1]
					getText(settings.translation, books[current_index - 1].bookid, books[current_index - 1].chapters)

	def prevChapterLink
		if settings.chapter - 1 > 0
			return "/{settings.translation}/{settings.book}/{settings.chapter - 1}/"
		else
			let current_index = books.indexOf(books.find(do |element| return element.bookid == settings.book))
			if books[current_index - 1]
				return "/{settings.translation}/{books[current_index - 1].bookid}/{books[current_index - 1].chapters}/"

	def nextChapterLink
		if settings.chapter + 1 <= chaptersOfCurrentBook()
			return "/{settings.translation}/{settings.book}/{settings.chapter + 1}/"
		else
			let current_index = books.indexOf(books.find(do |element| return element.bookid == settings.book))
			if books[current_index + 1]
				return "/{settings.translation}/{books[current_index+1].bookid}/1/"

	def nextBook
		let current_index = books.indexOf(books.find(do |element| return element.bookid == settings.book))
		if books[current_index + 1]
			getText(settings.translation, books[current_index + 1].bookid, 1)

	def prevBook
		let current_index = books.indexOf(books.find(do |element| return element.bookid == settings.book))
		if books[current_index - 1]
			getText(settings.translation, books[current_index - 1].bookid, 1)

	def mousemove e
		const isRangeInputFocues = document.activeElement.tagName == 'INPUT' && document.activeElement.type == 'range'
		if not MOBILE_PLATFORM and not fixdrawers and not isRangeInputFocues
			if e.x < 32
				bible_menu_left = 0
			elif e.x > window.innerWidth - 32
				settings_menu_left = 0
			elif 300 < e.x < window.innerWidth - 300
				bible_menu_left = -300 unless lock_panel
				settings_menu_left = -300

			if 300 > e.x
				lock_panel = no

		if e.y < 32 && not MOBILE_PLATFORM
			max_header_font = 1.2
		else
			max_header_font = 0

	def getHighlight verse, bookmarks
		if choosenid.length && choosenid.find(do |element| return element == verse)
			let width = Math.ceil(0.5 * settings.font.size)	# size of dots
			return "repeating-linear-gradient(90deg, {store.highlight_color}, {store.highlight_color} {width}px, rgba(0,0,0,0) {width}px, rgba(0,0,0,0) {width * 2}px)"
		else
			let highlight = self[bookmarks].find(do |element| return element.verse == verse)
			if highlight
				return  "linear-gradient({highlight.color} 0px, {highlight.color} 100%)"
			else
				return ''

	def getBookmark verse, bookmarks
		if state.user.username
			return self[bookmarks].find(do |element| return element.verse == verse)

	def getParallelHighlight verse
		if choosenid.length && choosenid.find(do |element| return element == verse)
			return store.highlight_color
		else
			let highlight = parallel_bookmarks.find(do |element| return element.verse == verse)
			if highlight
				return highlight.color

	def getCollectionOfChoosen verse
		let highlight = bookmarks.find(do |element| return element.verse == verse)
		if highlight then highlight.collection else ''

	def pushCollectionIfExist pk
		let collection = getCollectionOfChoosen(pk)
		if collection
			for piece in collection.split(' | ')
				if piece != '' && !choosen_categories.find(do |element| return element == piece)
					choosen_categories.push(piece)

	def mergeNotes
		store.note = ''
		for verse in choosenid
			let vrs = bookmarks.find(do |element| return element.verse == verse) || parallel_bookmarks.find(do |element| return element.verse == verse)
			if vrs
				if store.note.indexOf(vrs.note) < 0
					store.note += vrs.note

	def addToChosen pk, id, parallel
		if !document.getSelection().isCollapsed or big_modal_block_content
			return no
		if !settings_menu_left || !bible_menu_left
			return clearSpace()
		store.highlight_color = getRandomColor()
		# # If the verse is in area under bottom section
		# scroll to it, to see the full verse
		if !settingsp.enabled
			const verse = document.getElementById(id)
			const top_offset_of_verse = verse.offsetHeight + verse.offsetTop + 200 - scrollTop
			if top_offset_of_verse > window.innerHeight
				scrollToY(self, scrollTop - (window.innerHeight - top_offset_of_verse))
		else
			let verse
			if parallel == 'first'
				verse = document.getElementById(id)
			else
				verse = document.getElementById("p{id}")
			const top_offset = verse.offsetHeight + verse.offsetTop + 200 - verse.parentNode.parentNode.scrollTop
			if top_offset > verse.parentNode.parentNode.clientHeight
				scrollToY(verse.parentNode.parentNode, verse.parentNode.parentNode.scrollTop - (verse.parentNode.parentNode.clientHeight - top_offset))

		# # Handle the first click
		# initial setup of "Choosing" verses
		if !choosen_parallel
			choosen_parallel = parallel
			choosenid.push(pk)
			choosen.push(id)
			pushCollectionIfExist(pk)
			window.history.pushState(
				{},
				'',
				window.location.origin + '/' + settings.translation + '/' + settings.book + '/' + settings.chapter + '/' + id + '/')

		# Check if the user choosed a verse in the same parallel scope
		elif choosen_parallel == parallel
			if choosenid.find(do |element| return element == pk)
				choosenid.splice(choosenid.indexOf(pk), 1)
				choosen.splice(choosen.indexOf(id), 1)
				let collection = getCollectionOfChoosen(pk)
				if collection
					for piece in collection.split(' | ')
						if piece != ''
							choosen_categories.splice(choosen_categories.indexOf(choosen_categories.find(do |element| return element == piece)), 1)
			else
				choosenid.push(pk)
				choosen.push(id)
				pushCollectionIfExist(pk)
			if !choosenid.length
				clearSpace()
			show_collections = no

		if choosenid.length
			if choosen_parallel == 'first'
				highlighted_title = getHighlightedRow(settings.translation, settings.book, settings.chapter, choosen)
			else
				highlighted_title = getHighlightedRow(settingsp.translation, settingsp.book, settingsp.chapter, choosen)
			showDeleteBookmark()
			mergeNotes()



	def showDeleteBookmark
		show_delete_bookmark = no
		for verse in choosenid
			let vrs = bookmarks.find(do |element| return element.verse == verse) || parallel_bookmarks.find(do |element| return element.verse == verse)
			if vrs
				show_delete_bookmark = yes
				return 1

	def changeHighlightColor color
		store.show_color_picker = no
		store.highlight_color = color

	def getHighlightedRow translation, book, chapter, verses
		let row = nameOfBook(book, translation) + ' ' + chapter + ':'
		for id, key in verses.sort(do |a, b| return a - b)
			if id == verses[key - 1] + 1
				if id == verses[key+1] - 1
					continue
				else row += '-' + id
			else
				unless key
					row += id
				else row += ',' + id
		return row

	def saveUserBookmarkToMap translation, book, chapter
		unless userBookmarkMap[translation]
			userBookmarkMap[translation] = {}
		unless userBookmarkMap[translation][book]
			userBookmarkMap[translation][book] = {}
		unless userBookmarkMap[translation][book][chapter]
			userBookmarkMap[translation][book][chapter] = []
		userBookmarkMap[translation][book][chapter].push(store.highlight_color)
		window.localStorage.setItem("userBookmarkMap", JSON.stringify(userBookmarkMap))

	def sendBookmarksToDjango
		unless state.user.username
			window.location.pathname = "/signup/"
			return

		if store.note == '<br>'
			store.note == ''

		if store.highlight_color.length >= 16
			if highlights.find(do |element| return element == store.highlight_color)
				highlights.splice(highlights.indexOf(highlights.find(do |element| return element == store.highlight_color)), 1)
			highlights.push(store.highlight_color)
			window.localStorage.setItem("highlights", JSON.stringify(highlights))
		let collections = ''
		for category, key in choosen_categories
			collections += category.trim()
			if key + 1 < choosen_categories.length
				collections += " | "

		def saveOffline
			if state.db_is_available
				state.saveBookmarksToStorageUntillOnline({
					verses: choosenid,
					color: store.highlight_color,
					date: Date.now(),
					collections: choosen_categories
					note: store.note
				})

		if window.navigator.onLine
			window.fetch("/save-bookmarks/", {
				method: "POST",
				cache: "no-cache",
				headers: {
					'X-CSRFToken': state.get_cookie('csrftoken'),
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					verses: choosenid,
					color: store.highlight_color,
					date: Date.now(),
					collections: collections
					note: store.note
				}),
			})
			.then(do |response| response.json())
			.then(do state.showNotification('saved'))
			.catch(do |e|
				console.error(e)
				state.showNotification('error')
				saveOffline!)
		else saveOffline!

		if choosen_parallel == 'second'
			for verse in choosenid
				if parallel_bookmarks.find(do |bookmark| return bookmark.verse == verse)
					parallel_bookmarks.splice(parallel_bookmarks.indexOf(parallel_bookmarks.find(do |bookmark| return bookmark.verse == verse)), 1)
				parallel_bookmarks.push({
					verse: verse,
					date: Date.now(),
					color: store.highlight_color,
					collection: collections
					note: store.note
				})
				saveUserBookmarkToMap settingsp.translation, settingsp.book, settingsp.chapter
		else
			for verse in choosenid
				if bookmarks.find(do |bookmark| return bookmark.verse == verse)
					bookmarks.splice(bookmarks.indexOf(bookmarks.find(do |bookmark| return bookmark.verse == verse)), 1)
				bookmarks.push({
					verse: verse,
					date: Date.now(),
					color: store.highlight_color,
					collection: collections
					note: store.note
					}
				)
				saveUserBookmarkToMap settings.translation, settings.book, settings.chapter
		clearSpace()
		clearSpace()

	def deleteColor color_to_delete
		highlights.splice(highlights.indexOf(color_to_delete), 1)
		window.localStorage.setItem("highlights", JSON.stringify(highlights))

	def deleteBookmarkFromUserMap translation, book, chapter
		// remove also from userBookmarkMap its color
		if userBookmarkMap[translation][book][chapter].length >= 1
			delete userBookmarkMap[translation][book][chapter]
		else
			userBookmarkMap[translation][book][chapter].splice(userBookmarkMap[translation][book][chapter].indexOf(userBookmarkMap[translation][book][chapter].find(do |color| return color == store.highlight_color)), 1)
		window.localStorage.setItem("userBookmarkMap", JSON.stringify(userBookmarkMap))

	def deleteBookmarks pks
		if state.user.username
			state.requestDeleteBookmark(pks)
			if choosen_parallel == 'second'
				for verse in choosenid
					if parallel_bookmarks.find(do |bookmark| return bookmark.verse == verse)
						parallel_bookmarks.splice(parallel_bookmarks.indexOf(parallel_bookmarks.find(do |bookmark| return bookmark.verse == verse)), 1)
				deleteBookmarkFromUserMap settingsp.translation, settingsp.book, settingsp.chapter
			else
				for verse in choosenid
					if bookmarks.find(do |bookmark| return bookmark.verse == verse)
						bookmarks.splice(bookmarks.indexOf(bookmarks.find(do |bookmark| return bookmark.verse == verse)), 1)
				deleteBookmarkFromUserMap settings.translation, settings.book, settings.chapter
		clearSpace()



	def getShareObj
		let copyobj = {
			text: [],
			verse: [],
			translation: '',
			book: 0,
			chapter: 0
		}
		if choosen_parallel == 'first'
			copyobj.title = getHighlightedRow(settings.translation, settings.book, settings.chapter, choosen)
		else
			copyobj.title = getHighlightedRow(settingsp.translation, settingsp.book, settingsp.chapter, choosen)
		if choosen_parallel == 'second'
			for verse in parallel_verses
				if choosenid.find(do |element| return element == verse.pk)
					copyobj.text.push(verse.text)
					copyobj.verse.push(verse.verse)
			copyobj.translation = settingsp.translation
			copyobj.book = settingsp.book
			copyobj.chapter = settingsp.chapter
		else
			for verse in verses
				if choosenid.find(do |element| return element == verse.pk)
					copyobj.text.push(verse.text)
					copyobj.verse.push(verse.verse)
			copyobj.translation = settings.translation
			copyobj.book = settings.book
			copyobj.chapter = settings.chapter
		return copyobj

	def copyToClipboard
		state.copyToClipboard(getShareObj())
		clearSpace()

	def byteCount s
		window.encodeURI(s).split(/%..|./).length - 1

	def canShareViaTelegram
		const copyobj = getShareObj()
		return byteCount("https://t.me/share/url?url={window.encodeURIComponent("https://bolls.life" + '/'+ copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + state.versePart(copyobj.verse) + '/')}&text={window.encodeURIComponent('«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title + ' ' + copyobj.translation)}") < 4096

	def shareTelegram
		const copyobj = getShareObj()
		const text = '«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title + ' ' + copyobj.translation
		const url = "https://bolls.life" + '/'+ copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + state.versePart(copyobj.verse) + '/'
		const link = "https://t.me/share/url?url={window.encodeURIComponent(url)}&text={window.encodeURIComponent(text)}"
		if byteCount(link) < 4096
			window.open(link, '_blank')
		clearSpace()

	def sharedText
		const copyobj = getShareObj()
		const text = '«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title + ' ' + copyobj.translation + "https://bolls.life" + '/'+ copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + state.versePart(copyobj.verse) + '/'
		return text

	def canMakeTweet
		return sharedText().length < 281

	def makeTweet
		window.open("https://twitter.com/intent/tweet?text={window.encodeURIComponent(sharedText())}", '_blank')
		clearSpace()

	def shareViaFB
		const copyobj = getShareObj()
		window.open("https://www.facebook.com/sharer.php?u=https://bolls.life/" + copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + state.versePart(copyobj.verse) + '/', '_blank')
		clearSpace()

	def shareViaWhatsApp
		window.open("https://api.whatsapp.com/send?text={window.encodeURIComponent(sharedText())}", '_blank')
		clearSpace()

	def shareViaViber
		window.open("viber://forward?text={window.encodeURIComponent(sharedText())}", '_blank')
		clearSpace()

	def copyComparisonList
		let msg = highlighted_title

		for translation in comparison_parallel
			let verses = []
			let texts = []
			for verse in translation
				if verse.text
					texts.push(verse.text)
					verses.push(verse.verse)
			const firstVerse = translation[0]
			if firstVerse.text
				msg += '\n\n«' + state.cleanUpCopyText(texts) + '»\n\n' + firstVerse.translation + ' ' + "https://bolls.life" + '/'+ firstVerse.translation + '/' + firstVerse.book + '/' + firstVerse.chapter + '/' + state.versePart(verses) + '/'

		state.copyTextToClipboard(msg)

	def getNameOfBookFromHistory translation, bookid
		let books = []
		books = BOOKS[translation]
		for book in books
			if book.bookid == bookid
				return book.name

	def turnHistory
		store.show_history = !store.show_history
		settings_menu_left = -300
		if store.show_history
			syncHistory!

	def clearHistory
		turnHistory!
		history = []
		window.localStorage.setItem("history", "[]")
		if state.user.username && window.navigator.onLine
			try
				const response = await window.fetch("/history/", {
					method: "DELETE",
					cache: "no-cache",
					headers: {
						'X-CSRFToken': state.get_cookie('csrftoken'),
						"Content-Type": "application/json"
					},
					body: JSON.stringify({
						history: "[]",
						purge_date: Date.now!
					})
				})
				await response.json()
			catch error
				console.error(error)
				state.showNotification('error')

	def turnCollections
		if showAddCollection
			showAddCollection = no
		else
			show_collections = !show_collections
			store.show_color_picker = no
			if show_collections && state.user.username
				if window.navigator.onLine
					let data = await loadData("/get-categories/")
					categories = data.data
					for category in choosen_categories
						if !categories.find(do |element| return element == category)
							categories.unshift category
					categories = Array.from(new Set(categories))
					window.localStorage.setItem('categories', JSON.stringify(categories))
					imba.commit()
				else
					categories = JSON.parse(window.localStorage.getItem('categories'))

	def addCollection
		showAddCollection = yes
		focusElement 'newcollectioninput'

	def addNewCollection collection
		if choosen_categories.find(do |element| return element == collection)
			choosen_categories.splice(choosen_categories.indexOf(choosen_categories.find(do |element| return element == collection)), 1)
		elif collection
			choosen_categories.push collection
			if !categories.find(do |element| return element == collection)
				categories.unshift(collection)
				sendBookmarksToDjango()
				clearSpace()
			if collection == store.newcollection
				document.getElementById('newcollectioninput').value = ''
				store.newcollection = ""
		else
			sendBookmarksToDjango()
			clearSpace()
		window.localStorage.setItem('categories', JSON.stringify(categories))

	def currentTranslation translation
		if settingsp.enabled
			if settingsp.edited_version == settingsp.translation
				return translation == settingsp.translation
			else
				return translation == settings.translation
		else
			return translation == settings.translation

	def toggleBibleMenu parallel
		if bible_menu_left
			if !settings_menu_left && MOBILE_PLATFORM
				clearSpace()
				return
			bible_menu_left = 0
			settings_menu_left = -300
			if parallel
				settingsp.edited_version = settingsp.translation
			else
				settingsp.edited_version = settings.translation
		else
			bible_menu_left = -300

	def toggleSettingsMenu
		if settings_menu_left
			if !bible_menu_left && MOBILE_PLATFORM
				clearSpace()
				return
			settings_menu_left = 0
			bible_menu_left = -300
		else
			settings_menu_left = -300

	def showTranslations
		show_list_of_translations = yes
		search.change_translation = yes
		toggleBibleMenu()

	def backInHistory h, parallel
		if parallel != undefined
			getParallelText(h.translation, h.book, h.chapter, h.verse)
			settingsp.enabled = yes
			setCookie('parallel_display', settingsp.enabled)
		else
			getText(h.translation, h.book, h.chapter, h.verse)

	def toggleTransitions
		settings.transitions = !settings.transitions
		setCookie('transitions', settings.transitions)
		html.dataset.transitions = settings.transitions

	def toggleVersePicker
		settings.verse_picker = !settings.verse_picker
		setCookie('verse_picker', settings.verse_picker)

	def toggleVerseCommentary
		settings.verse_commentary = !settings.verse_commentary
		setCookie('verse_commentary', settings.verse_commentary)

	def toggleLockBooksMenu
		settings.lock_books_menu = !settings.lock_books_menu
		setCookie('lock_books_menu', settings.lock_books_menu)

	def toggleParallelSynch
		settings.parallel_synch = !settings.parallel_synch
		setCookie('parallel_synch', settings.parallel_synch)

	def toggleVerseBreak
		settings.verse_break = !settings.verse_break
		setCookie('verse_break', settings.verse_break)

	def toggleVerseNumber
		settings.verse_number = !settings.verse_number
		setCookie('verse_number', settings.verse_number)

	def fixDrawers
		fixdrawers = !fixdrawers
		setCookie("fixdrawers", fixdrawers)

	def translationFullName tr
		translations.find(do |translation| return translation.short_name == tr).full_name

	def popUp modal_name
		if big_modal_block_content !== modal_name
			big_modal_block_content = modal_name
			window.history.pushState({}, modal_name)

	def makeNote
		if big_modal_block_content
			big_modal_block_content = ''
		else
			popUp 'show_note'
		
	def toggleCompare
		if choosen.length then choosen_for_comparison = choosen
		if choosen_parallel == 'second'
			compare_parallel_of_chapter = settingsp.chapter
			compare_parallel_of_book = settingsp.book
		else
			compare_parallel_of_chapter = settings.chapter
			compare_parallel_of_book = settings.book
		if compare_translations.indexOf(settings.translation) == -1
			compare_translations.unshift(settings.translation)
		if big_modal_block_content == "show_compare"
			clearSpace()
			popUp 'show_compare'
		else clearSpace()
		loading = yes

		def getCompareTranslationsFromDB
			comparison_parallel = await state.getParallelVersesFromStorage(compare_translations, choosen_for_comparison, compare_parallel_of_book, compare_parallel_of_chapter)
			loading = no
			popUp 'show_compare'
			imba.commit()

		if !window.navigator.onLine && state.downloaded_translations.indexOf(settings.translation) != -1
			getCompareTranslationsFromDB!
		else
			comparison_parallel = []
			window.fetch("/get-parallel-verses/", {
				method: "POST",
				cache: "no-cache",
				headers: {
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					translations: compare_translations,
					verses: choosen_for_comparison,
					book: compare_parallel_of_book,
					chapter: compare_parallel_of_chapter,
				}),
			})
			.then(do |response| response.json())
			.then(do |resdata|
				comparison_parallel = resdata
				loading = no
				popUp 'show_compare'
				imba.commit()
			)
			.catch(do |error|
				console.error error
				loading = no
				if state.downloaded_translations.indexOf(settings.translation) != -1
					return getCompareTranslationsFromDB!
				state.showNotification('error'))

	def addTranslation translation
		if compare_translations.indexOf(translation.short_name) < 0
			compare_translations.unshift(translation.short_name)
			compare_translations = compare_translations
			window.fetch("/get-parallel-verses/", {
				method: "POST",
				cache: "no-cache",
				headers: {
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					translations: [translation.short_name],
					verses: choosen_for_comparison,
					book: compare_parallel_of_book,
					chapter: compare_parallel_of_chapter,
				}),
			})
			.then(do |response| response.json())
			.then(do |resdata|
				comparison_parallel = resdata.concat(comparison_parallel)
				scrollToY($compare_body, 0)
				loading = no
				imba.commit()
			)
			.catch(do |error|
				console.error error
				loading = no
				state.showNotification('error'))
		else
			compare_translations.splice(compare_translations.indexOf(translation.short_name), 1)
			compare_translations = compare_translations
			comparison_parallel.splice(comparison_parallel.indexOf(comparison_parallel.find(do |prlll| return prlll[0].translation == translation.short_name)), 1)
		window.localStorage.setItem("compare_translations", JSON.stringify(compare_translations))
		show_translations_for_comparison = no

	def changeLineHeight increase
		if increase && settings.font.line-height < 2.6
			settings.font.line-height += 0.2
		elif settings.font.line-height > 1.2
			settings.font.line-height -= 0.2
		setCookie('line-height', settings.font.line-height)

	def changeAlign auto
		if auto
			settings.font.align = ''
		else
			settings.font.align = 'justify'
		setCookie('align', settings.font.align)

	def changeMaxWidth increase
		if increase && settings.font.max-width < 120 && (settings.font.max-width - 8) * settings.font.size < window.innerWidth
			settings.font.max-width += 8
		elif settings.font.max-width > 16
			settings.font.max-width -= 8
		setCookie('max-width', settings.font.max-width)

	def toggleDownloads
		clearSpace()
		popUp 'show_downloads'
		download_dictionaries = no

	def openDictionaryDownloads
		toggleDownloads!
		download_dictionaries = yes


	def changeFontWeight value
		if settings.font.weight + value < 1000 && settings.font.weight + value > 0
			settings.font.weight += value
			setCookie('font-weight', settings.font.weight)

	def boxShadow grade
		settings.light == 'light' ? "box-shadow: 0 0 {(grade + 300) / 5}px rgba(0, 0, 0, 0.067);" : ''

	def filteredBooks books
		let result = []

		if store.book_search.length
			let filtered_books = []

			for book in self[books]
				const score = scoreSearch(book.name, store.book_search)
				if score >= store.book_search.length * 2
					filtered_books.push({
						book: book
						score: score
					})

			filtered_books = filtered_books.sort(do |a, b| b.score - a.score)

			for item in filtered_books
				result.push item.book
		else
			result = self[books]

		return result


	def copyToClipboardFromParallel tr
		let copyobj = {
			text: [],
			translation: tr[0].translation,
			book: tr[0].book,
			chapter: tr[0].chapter,
			verse: [],
		}
		for t in tr
			copyobj.text.push(t.text)
			copyobj.verse.push(t.verse)
		copyobj.title = getHighlightedRow(copyobj.translation, copyobj.book, copyobj.chapter, copyobj.verse)
		state.shareCopying(copyobj)

	def copyToClipboardFromSerach obj
		state.shareCopying({
			text: [obj.text],
			translation: obj.translation,
			book: obj.book,
			chapter: obj.chapter,
			verse: [obj.verse],
			title: getHighlightedRow(obj.translation, obj.book, obj.chapter, [obj.verse])
		})

	def saveCompareChanges arr
		compare_translations = arr

	def currentLanguage
		switch state.language
			when 'ukr' then "Українська"
			when 'ru' then "Русский"
			when 'pt' then "Portuguese"
			when 'de' then "Deutsch"
			when 'es' then "Español"
			else "English"

	def hideVersePicker
		show_parallel_verse_picker = no
		show_verse_picker = no

	def welcomeOk
		welcome = 'false'
		setCookie('welcome', no)
		window.history.pushState(
			{},
			"Welcome 🤗",
			window.location.origin + '/' + settings.translation + '/' + settings.book + '/' + settings.chapter + '/'
		)
		lock_panel = yes
		toggleBibleMenu()

	def calculateTopVerse e
		if settings.parallel_synch
			if scroll_timer != null
				clearTimeout(scroll_timer)

			scroll_timer = setTimeout(&, 1250) do
				scrolled_block = null


			if scrolled_block == null
				if e.target.classList.contains('ref--firstparallel')
					scrolled_block = $firstparallel
				elif e.target.classList.contains('ref--secondparallel')
					scrolled_block = $secondparallel
			else
				if e.target.classList.contains('ref--firstparallel') && scrolled_block != $firstparallel
					return
				elif e.target.classList.contains('ref--secondparallel') && scrolled_block != $secondparallel
					return

			let top_verse = {
				distance: 10000
				id: ''
			}

			for kid in scrolled_block.children[2]..children
				if kid.id
					let new_distance = Math.abs(kid.offsetTop - scrolled_block.scrollTop)
					if new_distance < top_verse.distance
						top_verse.distance = new_distance
						top_verse.id = kid.id

			if top_verse.id
				if top_verse.id.startsWith('p')
					findVerse top_verse.id.slice(1), 0, no
				else
					findVerse "p{top_verse.id}", 0, no


	def changeHeadersSizeOnScroll e
		if e.target.classList.contains('ref--firstparallel')
			let testsize = 2 - ((e.target.scrollTop * 4) / window.innerHeight)
			if testsize * settings.font.size < 12
				chapter_headers.fontsize1 = 16 / settings.font.size
			elif e.target.scrollTop > 0
				chapter_headers.fontsize1 = testsize
			else
				chapter_headers.fontsize1 = 2
		else
			let testsize = 2 - ((e.target.scrollTop * 4) / window.innerHeight)
			if testsize * settings.font.size < 12
				chapter_headers.fontsize2 = 16 / settings.font.size
			elif e.target.scrollTop > 0
				chapter_headers.fontsize2 = testsize
			else
				chapter_headers.fontsize2 = 2

			const last_known_scroll_position = e.target.scrollTop
			setTimeout(&, 100) do
				if e.target.scrollTop < last_known_scroll_position || not e.target.scrollTop
					menu_icons_transform = 0
				elif e.target.scrollTop > last_known_scroll_position
					if window.innerWidth >= 1024
						menu_icons_transform = -100
					else
						menu_icons_transform = 100
		calculateTopVerse e
		host_rectangle = null
		imba.commit()

	def triggerNavigationIcons
		let testsize = 2 - ((scrollTop * 4) / window.innerHeight)
		if testsize * settings.font.size < 12
			chapter_headers.fontsize1 = 16 / settings.font.size
		elif scrollTop > 0
			chapter_headers.fontsize1 = testsize
		else
			chapter_headers.fontsize1 = 2

		const last_known_scroll_position = scrollTop
		setTimeout(&, 250) do
			if scrollTop - last_known_scroll_position + 32 < 0 || not scrollTop
				menu_icons_transform = 0
			elif scrollTop - last_known_scroll_position - 32 > 0
				if window.innerWidth >= 1024
					menu_icons_transform = -100
				else
					menu_icons_transform = 100

			imba.commit()

	def pageSearchKeydownManager event
		if event.code == "Enter"
			if event.shiftKey
				prevOccurence()
			else
				nextOccurence()

	def isNoteEmpty
		return store.note && store.note != '<br>'

	def filterBooks
		scrollToY($books,0)
		settingsp.filtered_books = filteredBooks('parallel_books')
		settings.filtered_books = filteredBooks('books')

	def goToVerse id
		if settings.parallel_synch
			if id.toString().charAt(0) == 'p'
				findVerse id.toString().slice(1, id.length), 0, no
			else
				findVerse ('p' + id), 0, no

		findVerse id, 0, no
		hideVersePicker()
		focus!

	def randomVerse
		try
			// check if the translation is available offline and make offline request
			if state.downloaded_translations.indexOf(settings.translation) != -1
				const randomVerse = await loadData("/sw/get-random-verse/{settings.translation}/")
				getText settings.translation, randomVerse.book, randomVerse.chapter, randomVerse.verse
			else
				if window.navigator.onLine
					const randomVerse = await loadData("/get-random-verse/{settings.translation}/")
					getText settings.translation, randomVerse.book, randomVerse.chapter, randomVerse.verse
		catch error
			console.error error
			state.showNotification('error')



	def slidestart touch
		slidetouch = touch.changedTouches[0]

		if slidetouch.clientX < 16 or slidetouch.clientX > window.innerWidth - 16
			inzone = yes

	def slideend touch
		touch = touch.changedTouches[0]

		touch.dy = slidetouch.clientY - touch.clientY
		touch.dx = slidetouch.clientX - touch.clientX

		if bible_menu_left > -300
			if inzone
				touch.dx < -64 ? bible_menu_left = 0 : bible_menu_left = -300
			else
				touch.dx > 64 ? bible_menu_left = -300 : bible_menu_left = 0
		elif settings_menu_left > -300
			if inzone
				touch.dx > 64 ? settings_menu_left = 0 : settings_menu_left = -300
			else
				touch.dx < -64 ? settings_menu_left = -300 : settings_menu_left = 0
		elif document.getSelection().isCollapsed && Math.abs(touch.dy) < 32 && !search.search_div && !store.show_history && !choosenid.length
			if window.innerWidth > 600
				if touch.dx < -42
					settingsp.enabled && touch.clientX > window.innerWidth / 2 ? prevChapter(yes) : prevChapter()
				elif touch.dx > 42
					settingsp.enabled && touch.clientX > window.innerWidth / 2 ? nextChapter(yes) : nextChapter()
			else
				if touch.dx < -42
					settingsp.enabled && touch.clientY > window.innerHeight / 2 ? prevChapter(yes) : prevChapter()
				elif touch.dx > 42
					settingsp.enabled && touch.clientY > window.innerHeight / 2 ? nextChapter(yes) : nextChapter()

		slidetouch = null
		inzone = no


	def closingdrawer e
		e.dx = e.changedTouches[0].clientX - slidetouch.clientX

		if bible_menu_left > -300 && e.dx < 0
			bible_menu_left = e.dx
		if settings_menu_left > -300 && e.dx > 0
			settings_menu_left = - e.dx
		onzone = yes

	def openingdrawer e
		if inzone
			e.dx = e.changedTouches[0].clientX - slidetouch.clientX

			if bible_menu_left < 0 && e.dx > 0
				bible_menu_left = e.dx - 300
			if settings_menu_left < 0 && e.dx < 0
				settings_menu_left = - e.dx - 300

	def closedrawersend touch
		touch.dx = touch.changedTouches[0].clientX - slidetouch.clientX

		if bible_menu_left > -300
			touch.dx < -64 ? bible_menu_left = -300 : bible_menu_left = 0
		elif settings_menu_left > -300
			touch.dx > 64 ? settings_menu_left = -300 : settings_menu_left = 0
		onzone = no


	def install
		state.deferredPrompt.prompt()

	def settingsIconTransform huh
		if (fixdrawers && window.innerWidth >= 1024) or huh
			return -(300 + settings_menu_left)
		else
			return 0

	def bibleIconTransform huh
		if (fixdrawers && window.innerWidth >= 1024) or huh
			return 300 + bible_menu_left
		else
			return 0


	def hideReader
		return window.location.pathname.indexOf('profile') > -1 || window.location.pathname.indexOf('downloads') > -1 || window.location.pathname.indexOf('donate') > -1

	def validateNewCollectionInput e
		if store.newcollection.length > 2 && store.newcollection[store.newcollection.length - 1] == store.newcollection[store.newcollection.length - 2]
			store.newcollection = store.newcollection.trim!
		if e.enter
			addNewCollection(store.newcollection)

	def layerHeight parallel
		if parallel
			return $secondparallel.clientHeight
		else
			if settingsp.enabled
				return $firstparallel.clientHeight
			return $main.clientHeight

	def layerWidth parallel
		if parallel
			return $secondparallel.clientWidth
		else
			if settingsp.enabled
				return $firstparallel.clientWidth
			return $main.clientWidth


	def filterCompareTranslation translation
		unless store.compare_translations_search.length
			return 1
		else
			return store.compare_translations_search.toLowerCase() in (translation.short_name + translation.full_name).toLowerCase()


	def searchSuggestionText book
		let text = book.name + ' '
		if search.suggestions.chapter
			text += search.suggestions.chapter
		if search.suggestions.verse
			text += ':' + search.suggestions.verse
		if search.suggestions.translation
			text += ' ' + search.suggestions.translation
		return text

	def prepareForHotKey
		page_search.query = window.getSelection!.toString!
		search.search_input = page_search.query
		clearSpace!


	def translationDownloadStatus translation
		if state.translations_in_downloading.find(do |tr| return tr == translation)
			return 'processing'
		elif state.downloaded_translations.indexOf(translation) != -1
			return 'delete'
		else
			return 'download'

	def dictionaryDownloadStatus dictionary
		if state.dictionaries_in_downloading.find(do |tr| return tr == dictionary)
			return 'processing'
		elif state.downloaded_dictionaries.indexOf(dictionary) != -1
			return 'delete'
		else
			return 'download'

	def offlineTranslationAction tr
		if state.translations_in_downloading.find(do |translation| return translation == tr)
			return
		elif state.downloaded_translations.indexOf(tr) != -1
			state.deleteTranslation(tr)
		else
			state.downloadTranslation(tr)

	def offlineDictionaryAction dict
		if state.dictionaries_in_downloading.find(do |translation| return translation == dict)
			return
		elif state.downloaded_dictionaries.indexOf(dict) != -1
			state.deleteDictionary(dict)
		else
			state.downloadDictionary(dict)


	def nextVerseHasTheSameBookmark verse_index
		let current_bukmark = getBookmark(verses[verse_index].pk, 'bookmarks')
		if current_bukmark
			const next_verse = verses[verse_index + 1]
			if next_verse
				let next_bookmark = getBookmark(next_verse.pk, 'bookmarks')
				if next_bookmark
					if next_bookmark.collection == current_bukmark.collection and next_bookmark.note == current_bukmark.note
						return yes
		return no

	def nextParallelVerseHasTheSameBookmark verse_index
		let current_bukmark = getBookmark(parallel_verses[verse_index].pk, 'parallel_bookmarks')
		if current_bukmark
			const next_verse = parallel_verses[verse_index + 1]
			if next_verse
				let next_bookmark = getBookmark(next_verse.pk, 'parallel_bookmarks')
				if next_bookmark
					if next_bookmark.collection == current_bukmark.collection and next_bookmark.note == current_bukmark.note
						return yes
		return no

	def strongHunber selection, number
		# checking for Hebrew symbols is not reliable for cases when translation is English or Dutch but we're still at the old testament
		# And at the same time parallel mode may be selected and selection may be either in one or another parallel which may be both NT and OT
		# So we need to check to what translation the selection belongs
		if settingsp.enabled
			if $secondparallel.contains(selection.anchorNode)
				if settingsp.book < 40
					return 'H' + number
				else
					return 'G' + number
		if settings.book < 40
			return 'H' + number
		else
			return 'G' + number


	def showDefOptions
		const selection = window.getSelection!
		const selected = selection.toString!.trim!

		# Trigger the definition popup only when a single hebrew or greekword is selected or there are Strong tags init <S> or <s>
		let hebrew_or_greek = selected.match(/[\u0370-\u03FF]/) or  selected.match(/[\u0590-\u05FF]/) or selection.anchorNode.parentElement.querySelectorAll("s").length 
		if [...selected.matchAll(/\s/g)].length > 1 or selected == '' or not hebrew_or_greek
			host_rectangle = null
			return imba.commit!

		# The feature is not available offline without downloads
		if window.navigator.onLine or state.downloaded_dictionaries.length
			let range = selection.getRangeAt(0)
			# let rangeContainer = range.commonAncestorContainer
			let rangeContainer = range.endContainer.parentElement

			if $main.contains(rangeContainer)
				let viewportRectangle = range.getBoundingClientRect()
				host_rectangle = {
					top: viewportRectangle.top + settings.font.size * (MOBILE_PLATFORM ? 2.2 : 1.4),
					left: 'auto'
					right: 'auto'
					width: viewportRectangle.width
					height: viewportRectangle.height
					selected: selected
				}
				# Prevent overflowing
				if viewportRectangle.left <= window.innerWidth / 2
					host_rectangle.left = viewportRectangle.left
				else
					host_rectangle.right = window.innerWidth - viewportRectangle.right
				# Iterate through selected range nodes and find the first node having S tag type
				# Avoid using rangeContainer.childNodes cus it containes nodes outside of the selection
				# use document.createNodeIterator instead
				let iterator = document.createNodeIterator(rangeContainer, NodeFilter.SHOW_ALL)
				let node = iterator.nextNode()
				# always omit the first node cus it's the text node before the selection
				let first_node_omitten = no
				while node
					# If we run out of nodes, instead of instanteniously writing the possible null into node, I wanna preserve the last node in the node variable
					let next_node = iterator.nextNode()
					if !next_node
						break
					node = next_node

					# check if the node is inside the selection
					if !selection.containsNode(node, true)
						if first_node_omitten
							node = iterator.previousNode()
							break
						else
							continue

					# First node is never interesting. Strong number always follows the word, not preceeds it.
					if !first_node_omitten
						first_node_omitten = yes
						continue

					# Strong numbers are always inside S tag
					if node.tagName == 'S' or node.tagName == 's'
						host_rectangle.strong = strongHunber(selection, node.textContent)
						break

				if !host_rectangle.strong
					# If no S tag found, try at first to find the strong number in the next node
					if node
						host_rectangle.strong = strongHunber(selection, node.textContent)
					# Otherwise try our old approach
					elif selection.anchorOffset > 1 && selection.focusNode.previousSibling..textContent
						host_rectangle.strong = strongHunber(selection, selection.focusNode.previousSibling.textContent)
					else
						if selection.anchorNode.nextSibling..textContent
							host_rectangle.strong = strongHunber(selection, selection.anchorNode.nextSibling.textContent)

				imba.commit!


	def showDictionaryView
		const selection = window.getSelection!
		const selected = selection.toString!.trim!
		if selected
			store.definition_search = selected
		loadDefinitions!
		setTimeout(&, 300) do $dictionarysearch.select!

	def showStongNumberDefinition
		if host_rectangle..strong
			loadDefinitions(host_rectangle.strong)

	def stripVowels rawString
		# Clear Hebrew
		let res =  rawString.replace(/[\u0591-\u05C7]/g,"")
		# Replace some letters, which are not present in a given unicode range, manually.
		res = res.replace('שׁ', 'ש')
		res = res.replace('שׂ', 'ש')
		res = res.replace('‎', '')

		# Clear Greek
		res = res.normalize('NFD').replace(/[\u0300-\u036f]/g, "");
		return res

	# Get query results from the dictionary, or Strong's number 
	def loadDefinitions query
		let selected_text = window.getSelection!.toString!.trim!
		if typeof query === 'string' # imba may pass the event object from input
			selected_text = query
		if selected_text
			store.definition_search = selected_text

		closeVerseOptions!
		clearSpace { onPopState: yes }
		popUp 'dictionary'

		definitions = []
		if store.definition_search && (window.navigator.onLine or state.downloaded_dictionaries.length)
			if definitions_history.indexOf(store.definition_search) == -1
				definitions_history_index += 1
				definitions_history[definitions_history_index] = store.definition_search
				definitions_history.length = definitions_history_index + 1

			loading = yes
			def loadDefinitionsFromOffline
				let unvoweled_query = stripVowels(store.definition_search)
				search_results = await state.searchDefinitionsOffline {dictionary: state.dictionary, query: unvoweled_query}
				definitions = []
				for definition in search_results
					const score = scoreSearch(definition.lexeme, unvoweled_query)
					if score or definition.topic == store.definition_search.toUpperCase!
						definitions.push({
							... definition
							score: score
						})
				definitions = definitions.sort(do |a, b| b.score - a.score)

			if window.navigator.onLine
				try
					definitions = await loadData("/dictionary-definition/{state.dictionary}/{store.definition_search}?extended={settings.extended_dictionary_search ? 'true' : ''}")
				catch error
					console.error error
					if state.dictionary in state.downloaded_dictionaries
						await loadDefinitionsFromOffline()
			elif state.dictionary in state.downloaded_dictionaries
				await loadDefinitionsFromOffline()
			loading = no
			expanded_definition = 0
			# When definitions are loaded we have to parse inner MyBible links and replace them custom click events
			parseDefinitionsLinks!
			imba.commit!

	# Since I use MyBible modules they have their own links format, which is not supported by the browser.
	# So we have to parse them and replace with custom click events.
	def parseDefinitionsLinks
		# Parse Strong links
		let patterns = [
			/<a href='S:(.*?)'>/g,
			/<a href=\"S:(.*?)\">/g,
			/<a href=S:(.*?)>/g
		]
		for definition, index in definitions
			for pattern in patterns
				let matches = [... definition.definition.matchAll(pattern)]
				for match in matches
					definition.definition = definition.definition.replace(match[0], "<a onclick='strongDefinition(\"{match[1]}\")'>")

		# Unlink TWOT links
		patterns = [
			/<a class="T" href='S:(.*?)'>/g,
			/<a class="T" href=\"S:(.*?)\">/g,
			/<a class="T" href=S:(.*?)>/g
		]
		for definition, index in definitions
			for pattern in patterns
				let matches = [... definition.definition.matchAll(pattern)]
				for match in matches
					definition.definition = definition.definition.replace(match[0], match[1])


	def prevDefinition
		if definitions_history_index > 0
			definitions_history_index -= 1
			store.definition_search = definitions_history[definitions_history_index]
			loadDefinitions!

	def nextDefinition
		if definitions_history_index < definitions_history.length - 1
			definitions_history_index += 1
			store.definition_search = definitions_history[definitions_history_index]
			loadDefinitions!

	def expandDefinition index
		if expanded_definition == index
			expanded_definition = -1
		else
			expanded_definition = index
			setTimeout(&, 300) do
				for kid, i in $definitions.children
					if i + 1 == index
						$definitions.children[i+1].scrollIntoView()

	def currentDictionary
		for dictionary in dictionaries
			if dictionary.abbr == state.dictionary
				return dictionary.name

	def closecp
		store.show_color_picker = no
	
	def toggleExtendedDictionarySearch
		settings.extended_dictionary_search = !settings.extended_dictionary_search
		setCookie 'extended_dictionary_search', settings.extended_dictionary_search

	def openSearchVerse event
		if event.detail.translation && event.detail.book && event.detail.chapter
			getText event.detail.translation, event.detail.book, event.detail.chapter, event.detail.verse

	def purcheCache
		# ask confirmation
		const confirmed = await window.confirm(state.lang.purge_cache + '?')
		if confirmed
			# unregister service worker and purge cache
			if window.navigator.serviceWorker != undefined
				window.navigator.serviceWorker.getRegistrations().then(do(registrations)
					for registration in registrations
						await registration.unregister()
				)

			window.caches.keys().then(do(cacheNames)	
				for cacheName in cacheNames
					await window.caches.delete(cacheName)
				)
			# & reload
			window.history.go()

	def toggleFontModal
		clearSpace()
		popUp("font")
	
	def translationHeartFill trabbr
		if settings.favorite_translations.includes(trabbr)
			return 'currentColor'
		return 'none'

	def openTranslationInParallel translation
		settingsp.enabled = yes
		setCookie('parallel_display', settingsp.enabled)
		parallel_books = BOOKS[translation]
		settingsp.filtered_books = filteredBooks('parallel_books')
		if parallel_books.find(do |element| return element.bookid == settingsp.book)
			getParallelText(translation, settingsp.book, settingsp.chapter)
		else
			getParallelText(translation, parallel_books[0].bookid, 1)
			settingsp.book = parallel_books[0].bookid
			settingsp.chapter = 1
		settingsp.translation = translation

	def logout
		await window.fetch("/accounts/logout/", {method:"POST", headers:{'X-CSRFToken': state.get_cookie('csrftoken')}})
		window.location.replace("/")

	def render
		if isApple
			iOS_keaboard_height = Math.abs(inner_height - window.innerHeight)

		<self id="reader" tabIndex="0" .display_none=hideReader! @scroll=triggerNavigationIcons @mousemove=mousemove @gotoverse=openSearchVerse .fixscroll=(big_modal_block_content)>
			<nav .lock-books=settings.lock_books_menu @touchstart=slidestart @touchend=closedrawersend @touchcancel=closedrawersend @touchmove=closingdrawer style="left: {bible_menu_left}px; {boxShadow(bible_menu_left)}{(onzone || inzone) ? 'transition:none;' : ''}">
				if settingsp.enabled
					<.choose_parallel>
						<button.translation_name title=translationFullName(settings.translation) .current_translation=(settingsp.edited_version == settings.translation) @click=changeEditedParallel(settings.translation)> settings.translation
						<button.translation_name [fw:black] @click=swapTranslations> "⇄"
						<button.translation_name title=translationFullName(settingsp.translation) .current_translation=(settingsp.edited_version == settingsp.translation) @click=changeEditedParallel(settingsp.translation)> settingsp.translation
				<header[d:flex jc:space-between cursor:pointer]>
					<svg.chronological_order @click=toggleChronorder .hide_chron_order=show_list_of_translations .chronological_order_in_use=chronorder viewBox="0 0 20 20" title=state.lang.chronological_order>
						<title> state.lang.chronological_order
						<path d="M10 20a10 10 0 1 1 0-20 10 10 0 0 1 0 20zm0-2a8 8 0 1 0 0-16 8 8 0 0 0 0 16zm-1-7.59V4h2v5.59l3.95 3.95-1.41 1.41L9 10.41z">
					if settingsp.edited_version == settingsp.translation && settingsp.enabled
						<button.translation_name title=state.lang.change_translation @click=(show_list_of_translations = !show_list_of_translations)>
							settingsp.edited_version
							<svg.arrow_next[min-width:16px h:0.65em ml:4px pt:4px] width="16" height="10" viewBox="0 0 8 5">
								<title> state.lang.open
								<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
					else
						<button.translation_name title=state.lang.change_translation @click=(show_list_of_translations = !show_list_of_translations)>
							settings.translation
							<svg.arrow_next[min-width:16px h:0.65em ml:4px pt:4px] width="16" height="10" viewBox="0 0 8 5">
								<title> state.lang.open
								<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
					if state.db_is_available
						<svg.download_translations @click=toggleDownloads .hide_chron_order=show_list_of_translations viewBox="0 0 212.646728515625 159.98291015625">
							<title> state.lang.download
							<g transform="matrix(1.5 0 0 1.5 0 128)">
								<path d=svg_paths.download>

				if show_list_of_translations
					<div[m:16px 0 @off:0 p:8px h:auto max-height:100% @off:0px o@off:0 ofy:scroll @off:hidden -webkit-overflow-scrolling:touch pb:256px @off:0 y@off:-16px] ease>
						# show favorites first
						if settings.favorite_translations.length
							<[d:flex flw:wrap ai:center p:10px]>
								<Heart [size:1em stroke:$c @hover:$acc-color fill: currentColor]>
								for favorite in settings.favorite_translations
									<span.translation_name [w:auto p:0 8px] @click=changeTranslation(favorite)> favorite
						for language in languages
							<div key=language.language>
								<p.book_in_list[justify-content:start] .pressed=(language.language == show_language_of) .selected=(language.translations.find(do |translation| currentTranslation(translation.short_name))) @click=showLanguageTranslations(language.language)>
									language.language
									<svg.arrow_next[margin-left:auto min-width:16px] width="16" height="10" viewBox="0 0 8 5">
										<title> state.lang.open
										<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
								if language.language == show_language_of
									<ul [o@off:0 m:0 0 16px @off:-24px 0 24px transition-timing-function:quad h@off:0px of:hidden] dir="auto" ease>
										let no_translation_downloaded = yes
										for translation in language.translations
											if window.navigator.onLine || state.downloaded_translations.indexOf(translation.short_name) != -1
												no_translation_downloaded = no
												<li.book_in_list .selected=currentTranslation(translation.short_name) [display: flex]>
													<span @click=changeTranslation(translation.short_name)>
														<b> translation.short_name
														', '
														translation.full_name
													<[d:flex fld:column ml:4px]>
														<Heart [size:1em stroke:$c @hover:$acc-color fill: {translationHeartFill(translation.short_name)}] @click.prevent.stop=toggleTranslationFavor(translation.short_name)>
										if no_translation_downloaded
											<p.book_in_list> state.lang["no_translation_downloaded"]


				<$books.books-container dir="auto" .lower=(settingsp.enabled) [pb: 256px pt:{iOS_keaboard_height ? iOS_keaboard_height * 0.8 : 0}px]>
					<>
						if settingsp.enabled && settingsp.edited_version == settingsp.translation
							<>
								for book in settingsp.filtered_books
									<div key=book.bookid>
										if book.bookid == 40
											<div[d:flex jc:center]>
												swirl
										<p.book_in_list dir="auto" .selected=(book.bookid == settingsp.book) @click=showChapters(book.bookid)> book.name
										if book.bookid == show_chapters_of
											<ul[o@off:0 m:0 0 16px @off:-24px 0 24px transition-timing-function:quad h@off:0px of:hidden] dir="auto" ease>
												for i in [0 ... book.chapters]
													<li.chapter_number .selected=(i + 1 == settingsp.chapter && book.bookid==settingsp.book) @click=getParallelText(settingsp.translation, book.bookid, i+1)>
														i+1
														<div.nav_bookmarks>
															if userBookmarkMap[settingsp.translation] and userBookmarkMap[settingsp.translation][book.bookid] and userBookmarkMap[settingsp.translation][book.bookid][i+1]
																for color in userBookmarkMap[settingsp.translation][book.bookid][i+1]
																	<span [bgc:{color}]>
							if !settingsp.filtered_books.length
								<p.book_in_list [white-space: pre]> '(ಠ╭╮ಠ)  ¯\\_(ツ)_/¯  ノ( ゜-゜ノ)'
						else
							<>
								for book in settings.filtered_books
									<div key=book.bookid>
										if book.bookid == 40
											<div[d:flex jc:center]>
												swirl
										<p.book_in_list dir="auto" .selected=(book.bookid == settings.book) @click=showChapters(book.bookid)> book.name
										if book.bookid == show_chapters_of
											<ul[o@off:0 m:0 0 16px @off:-24px 0 24px transition-timing-function:quad h@off:0px of:hidden] dir="auto" ease>
												for i in [0 ... book.chapters]
													<li.chapter_number .selected=(i + 1 == settings.chapter && book.bookid == settings.book) @click=getText(settings.translation, book.bookid, i+1)>
														i+1
														<div.nav_bookmarks>
															if userBookmarkMap[settings.translation] and userBookmarkMap[settings.translation][book.bookid] and userBookmarkMap[settings.translation][book.bookid][i+1]
																for color in userBookmarkMap[settings.translation][book.bookid][i+1]
																	<span [bgc:{color}]>
							if !settings.filtered_books.length
								<p.book_in_list [white-space: pre]> '(ಠ╭╮ಠ)  ¯\\_(ツ)_/¯  ノ( ゜-゜ノ)'
				<input$bookssearch.search @keyup=filterBooks bind=store.book_search type="text" placeholder=state.lang.search aria-label=state.lang.search>
				<svg id="close_book_search" @click=(store.book_search = '', $bookssearch.focus(), filterBooks()) viewBox="0 0 20 20">
					<title> state.lang.delete
					<path[m: auto] d=svg_paths.close>

			<div
				[w:2vw w:min(32px, max(16px, 2vw)) h:100% pos:sticky t:0 bg@hover:#8881 o:0 @hover:1 d:flex ai:center jc:center cursor:pointer transform:translateX({bibleIconTransform(yes)}px) zi:2]
				@click=toggleBibleMenu @touchstart=slidestart @touchmove=openingdrawer @touchend=slideend @touchcancel=slideend>
				<svg .arrow_next=!bibleIconTransform(yes) .arrow_prev=bibleIconTransform(yes) [fill:$acc-color] width="16" height="10" viewBox="0 0 8 5">
					<title> state.lang.change_book
					<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

			if host_rectangle
				<div.host_rectangle
					[pos:fixed l:{host_rectangle.left}px r:{host_rectangle.right}px t:{host_rectangle.top}px zi:1 scale@off:0.75 o@off:0 origin:top center]
					ease
					>
					<button @click=loadDefinitions(host_rectangle.selected)> host_rectangle.selected
					if host_rectangle.strong
						'|'
						<button @click=loadDefinitions(host_rectangle.strong)> host_rectangle.strong

			<main$main .main @touchstart=slidestart @touchmove=openingdrawer @touchend=slideend @touchcancel=slideend .parallel_text=settingsp.enabled .hide_comments=!settings.verse_commentary
				[pos:{settingsp.enabled ? 'relative' : 'static'} ff: {settings.font.family} fs: {settings.font.size}px lh:{settings.font.line-height} fw:{settings.font.weight} ta: {settings.font.align}]>
				<section$firstparallel .parallel=settingsp.enabled @scroll=changeHeadersSizeOnScroll dir=translationTextDirection(settings.translation) [margin: auto; max-width: {settings.font.max-width}em]>
					for rect in page_search.rects when rect.mathcid.charAt(0) != 'p' and big_modal_block_content == ''
						<.{rect.class} id=rect.matchid [top: {rect.top}px; left: {rect.left}px; width: {rect.width}px; height: {rect.height}px]>

					if verses.length
						<header[h: 0 mt:4em zi:1] @click=toggleBibleMenu()>
							#main_header_arrow_size = "min(64px, max({max_header_font}em, {chapter_headers.fontsize1}em))"
							<h1[lh:1 padding-block:0.2em m: 0 ff: {settings.font.family} fw: {settings.font.weight + 200} fs:max({max_header_font}em, {chapter_headers.fontsize1}em) d@md:flex ai@md:center jc@md:space-between direction:ltr] title=translationFullName(settings.translation)>
								<a.arrow @click.prevent.stop=prevChapter() [d@lt-md:none max-height:{#main_header_arrow_size} max-width:{#main_header_arrow_size} min-height:{#main_header_arrow_size} min-width:{#main_header_arrow_size}] title=state.lang.prev href="{prevChapterLink()}">
									<svg.arrow_prev width="16" height="10" viewBox="0 0 8 5">
										<title> state.lang.prev
										<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
								settings.name_of_book, ' ', settings.chapter

								<a.arrow @click.prevent.stop=nextChapter() [d@lt-md:none max-height:{#main_header_arrow_size} max-width:{#main_header_arrow_size} min-height:{#main_header_arrow_size} min-width:{#main_header_arrow_size}] title=state.lang.next href="{nextChapterLink()}">
									<svg.arrow_next width="16" height="10" viewBox="0 0 8 5">
										<title> state.lang.next
										<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
						<p[mb:1em p: 0 8px o:0 lh:1 ff: {settings.font.family} fw: {settings.font.weight + 200} fs: {settings.font.size * 2}px us:none]> settings.name_of_book, ' ', settings.chapter
						<article[text-indent: {settings.verse_number ? 0 : 2.5}em]>
							for verse, verse_index in verses
								let bukmark = getBookmark(verse.pk, 'bookmarks')
								let super_style = "padding-bottom:{0.8 * settings.font.line-height}em;padding-top:{settings.font.line-height - 1}em"

								if settings.verse_number
									unless settings.verse_break
										<span> ' '
									<span.verse dir="ltr" style=super_style @click=goToVerse(verse.verse)> '\u2007\u2007\u2007' + verse.verse + "\u2007"
								else
									<span> ' '
								<span innerHTML=verse.text
								 		id=verse.verse
										@click.wait(200ms)=addToChosen(verse.pk, verse.verse, 'first')
										[background-image: {getHighlight(verse.pk, 'bookmarks')}]
									>
								if bukmark and not nextVerseHasTheSameBookmark(verse_index)
									if bukmark.collection || bukmark.note
										<note-up style=super_style parallelMode=settingsp.enabled bookmark=bukmark containerWidth=layerWidth(no) containerHeight=layerHeight(no)>
											<svg viewBox="0 0 20 20" alt=state.lang.note>
												<title> state.lang.note
												<path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2zm2 0v15l6-3 6 3V2H4z">

								if verse.comment and settings.verse_commentary
									<note-up style=super_style parallelMode=settingsp.enabled bookmark=verse.comment containerWidth=layerWidth(no) containerHeight=layerHeight(no)>
										<span[c:$acc-color @hover:$acc-color-hover]> '†'

								if settings.verse_break
									<br>
									unless settings.verse_number
										<span.ws> '	'
						<.arrows>
							<a.arrow @click.prevent=prevChapter() title=state.lang.prev href="{prevChapterLink()}">
								<svg.arrow_prev width="16" height="10" viewBox="0 0 8 5">
									<title> state.lang.prev
									<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
							<a.arrow @click.prevent=nextChapter() title=state.lang.next href="{nextChapterLink()}">
								<svg.arrow_next width="16" height="10" viewBox="0 0 8 5">
									<title> state.lang.next
									<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
					elif !window.navigator.onLine && state.downloaded_translations.indexOf(settings.translation) == -1
						<p.in_offline>
							state.lang.this_translation_is_unavailable
							<br>
							<a.reload @click=(do window.location.reload(yes))> state.lang.reload
					elif not loading
						<p.in_offline>
							state.lang.unexisten_chapter
							<br>
							<a.reload @click=(do window.location.reload(yes))> state.lang.reload

				<section$secondparallel.parallel @scroll=changeHeadersSizeOnScroll dir=translationTextDirection(settingsp.translation) [margin: auto max-width: {settings.font.max-width}em display: {settingsp.enabled ? 'inline-block' : 'none'}]>
					for rect in page_search.rects when rect.mathcid.charAt(0) == 'p'
						<.{rect.class} [top: {rect.top}px; left: {rect.left}px; width: {rect.width}px; height: {rect.height}px]>
					if parallel_verses.length
						<header[h: 0 mt:4em zi:1] @click=toggleBibleMenu(yes)>
							<h1[lh:1 padding-block:0.2em m: 0 ff: {settings.font.family} fw: {settings.font.weight + 200} fs:max({max_header_font}em, {chapter_headers.fontsize2}em) d@md:flex ai@md:center jc@md:space-between direction:ltr] title=translationFullName(settingsp.translation)>
								<a.arrow @click.prevent.stop=prevChapter(yes) [d@lt-md:none max-height:{#main_header_arrow_size} max-width:{#main_header_arrow_size} min-height:{#main_header_arrow_size} min-width:{#main_header_arrow_size}] title=state.lang.prev href="{prevChapterLink()}">
									<svg.arrow_prev width="16" height="10" viewBox="0 0 8 5">
										<title> state.lang.prev
										<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
								settingsp.name_of_book, ' ', settingsp.chapter

								<a.arrow @click.prevent.stop=nextChapter(yes) [d@lt-md:none max-height:{#main_header_arrow_size} max-width:{#main_header_arrow_size} min-height:{#main_header_arrow_size} min-width:{#main_header_arrow_size}] title=state.lang.next href="{nextChapterLink()}">
									<svg.arrow_next width="16" height="10" viewBox="0 0 8 5">
										<title> state.lang.next
										<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
						<p[mb:1em p: 0 8px o:0 lh:1 ff: {settings.font.family} fw: {settings.font.weight + 200} fs: {settings.font.size * 2}px us:none]> settingsp.name_of_book, ' ', settingsp.chapter
						<article[text-indent: {settings.verse_number ? 0 : 2.5}em]>
							for parallel_verse, verse_index in parallel_verses
								let super_style = "padding-bottom:{0.8 * settings.font.line-height}em;padding-top:{settings.font.line-height - 1}em"
								let bukmark = getBookmark(parallel_verse.pk, 'parallel_bookmarks')

								if settings.verse_number
									unless settings.verse_break
										<span> ' '
									<span.verse dir="ltr" style=super_style @click=goToVerse("p{parallel_verse.verse}")> '\u2007\u2007\u2007', parallel_verse.verse, "\u2007"
								else
									<span> ' '
								<span innerHTML=parallel_verse.text
									id="p{parallel_verse.verse}"
									@click.wait(200ms)=addToChosen(parallel_verse.pk, parallel_verse.verse, 'second')
									[background-image: {getHighlight(parallel_verse.pk, 'parallel_bookmarks')}]>
								if bukmark and not nextParallelVerseHasTheSameBookmark(verse_index)
									if bukmark.collection || bukmark.note
										<note-up style=super_style parallelMode=settingsp.enabled bookmark=bukmark containerWidth=layerWidth(no) containerHeight=layerHeight(no)>
											<svg viewBox="0 0 20 20" alt=state.lang.note>
												<title> state.lang.note
												<path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2zm2 0v15l6-3 6 3V2H4z">

								if parallel_verse.comment and settings.verse_commentary
									<note-up style=super_style parallelMode=settingsp.enabled bookmark=parallel_verse.comment containerWidth=layerWidth(yes) containerHeight=layerHeight(yes)>
										<span[c:$acc-color @hover:$acc-color-hover]> '†'

								if settings.verse_break
									<br>
									unless settings.verse_number
										<span> '	'
						<.arrows>
							<a.arrow @click=prevChapter(yes)>
								<svg.arrow_prev width="16" height="10" viewBox="0 0 8 5">
									<title> state.lang.prev
									<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
							<a.arrow @click=nextChapter(yes)>
								<svg.arrow_next width="16" height="10" viewBox="0 0 8 5">
									<title> state.lang.next
									<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
					elif !window.navigator.onLine && state.downloaded_translations.indexOf(settingsp.translation) == -1
						<p.in_offline> state.lang.this_translation_is_unavailable

			<div
				[w:2vw w:min(32px, max(16px, 2vw)) h:100% pos:sticky t:0 bg@hover:#8881 o:0 @hover:1 d:flex ai:center jc:center cursor:pointer transform:translateX({settingsIconTransform(yes)}px) zi:2]
				@click=toggleSettingsMenu @touchstart=slidestart @touchmove=openingdrawer @touchend=slideend @touchcancel=slideend>
				<svg .arrow_next=settingsIconTransform(yes) .arrow_prev=!settingsIconTransform(yes) [fill:$acc-color] width="16" height="10" viewBox="0 0 8 5">
					<title> state.lang.other
					<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">


			<aside @touchstart=slidestart @touchend=closedrawersend @touchcancel=closedrawersend @touchmove=closingdrawer style="right:{MOBILE_PLATFORM ? settings_menu_left : settings_menu_left ? settings_menu_left : settings_menu_left + 12}px;{boxShadow(settings_menu_left)}{(onzone || inzone) ? 'transition:none;' : ''}">
				<p[fs:24px h:32px d:flex jc:space-between ai:center]>
					state.lang.other
					<.current_accent .enlarge_current_accent=show_accents>
						<.visible_accent @click=(do show_accents = !show_accents)>
						<.accents .show_accents=show_accents>
							for accent in accents when accent.name != settings.accent
								<.accent @click=changeAccent(accent.name) [background-color: {settings.light == 'dark' ? accent.light : accent.dark}]>
				<[d:flex m:24px 0 ai:center]>
					if state.userName
						<[w:100% d:flex ai:center $fill-on-hover:$c @hover:$acc-color-hover cursor:pointer] route-to='/profile/'>
							<svg.helpsvg xmlns="http://www.w3.org/2000/svg" height="32px" viewBox="0 0 24 24" width="32px">
								<title> state.userName
								<path d="M0 0h24v24H0z" fill="none">
								<path d="M18 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zM6 4h5v8l-2.5-1.5L6 12V4z">
							<a.username [c:$fill-on-hover]> state.userName
						<a.prof_btn [ws:pre] @click.stop.prevent=logout> state.lang.logout
					else
						<a.prof_btn @click.stop.prevent=(window.location = "/accounts/login/") href="/accounts/login/"> state.lang.login
						<a.prof_btn.signin @click.stop.prevent=(window.location = "/signup/") href="/signup/"> state.lang.signin
				<button.btnbox.cbtn.aside_button @click=turnGeneralSearch>
					<svg.helpsvg [p:0 4px] viewBox="0 0 12 12" width="24px" height="24px">
						<title> state.lang.find_in_chapter
						<path d=svg_paths.search>
					state.lang.bible_search
				<button.btnbox.cbtn.aside_button @click=pageSearch()>
					<svg.helpsvg [p:0 4px] viewBox="0 0 12 12" width="24px" height="24px">
						<title> state.lang.find_in_chapter
						<path d=svg_paths.search>
					state.lang.find_in_chapter
				<button.btnbox.cbtn.aside_button @click=turnHistory>
					<svg.helpsvg width="24" height="24" viewBox="0 0 24 24">
						<title> state.lang.history
						<path d="M0 0h24v24H0z" fill="none">
						<path d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z">
					state.lang.history

				<menu-popup bind=store.show_themes>
					<.btnbox.cbtn.aside_button.popup_menu_box [d:flex transform@important:none ai:center pos:relative] @click=(do store.show_themes = !store.show_themes)>
						<svg[size:24px ml:4px mr:16px] xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
							<title> 'Clair de lune'
							<path d="M167.02 309.34c-40.12 2.58-76.53 17.86-97.19 72.3-2.35 6.21-8 9.98-14.59 9.98-11.11 0-45.46-27.67-55.25-34.35C0 439.62 37.93 512 128 512c75.86 0 128-43.77 128-120.19 0-3.11-.65-6.08-.97-9.13l-88.01-73.34zM457.89 0c-15.16 0-29.37 6.71-40.21 16.45C213.27 199.05 192 203.34 192 257.09c0 13.7 3.25 26.76 8.73 38.7l63.82 53.18c7.21 1.8 14.64 3.03 22.39 3.03 62.11 0 98.11-45.47 211.16-256.46 7.38-14.35 13.9-29.85 13.9-45.99C512 20.64 486 0 457.89 0z">
						state.lang.theme
						if store.show_themes
							<.popup_menu [l:0 y@off:-32px o@off:0] ease>
								<button.butt[fw:900 bgc:black c:white bdr:32px solid white] @click=changeTheme('black')> 'Black'
								<button.butt[fw:900 bgc:rgb(4, 6, 12) c:rgb(255, 238, 238) bdr:32px solid rgb(255, 238, 238)] @click=changeTheme('dark')> state.lang.nighttheme
								<button.butt[fw:900 bgc:#f1f1f1 c:black bdr:32px solid black] @click=changeTheme('gray')> 'Gray'
								<button.butt[fw:900 bgc:rgb(235, 219, 183) c:rgb(46, 39, 36) bdr:32px solid rgb(46, 39, 36)] @click=changeTheme('sepia')> 'Sepia'
								<button.butt[fw:900 bgc:rgb(255, 238, 238) c:rgb(4, 6, 12) bdr:32px solid rgb(4, 6, 12)] @click=changeTheme('light')> state.lang.lighttheme
								<button.butt[fw:900 bgc:white c:black bdr:32px solid black] @click=changeTheme('white')> 'White'

				<.btnbox>
					<button[p:12px fs:20px].cbtn @click=decreaseFontSize title=state.lang.decrease_font_size> "B-"
					<button[p:8px fs:24px].cbtn @click=increaseFontSize title=state.lang.increase_font_size> "B+"
				<.btnbox>
					<button.cbtn [p:8px fs:24px fw:100] @click=changeFontWeight(-100) title=state.lang.decrease_font_weight> "B"
					<button.cbtn [p:8px fs:24px fw:900] @click=changeFontWeight(100) title=state.lang.increase_font_weight> "B"
				<.btnbox>
					<svg.cbtn @click=changeLineHeight(no) viewBox="0 0 38 14" fill="context-fill" [p:16px 0]>
						<title> state.lang.decrease_line_height
						<rect x="0" y="0" width="28" height="2">
						<rect x="0" y="6" width="38" height="2">
						<rect x="0" y="12" width="18" height="2">
					<svg.cbtn @click=changeLineHeight(yes) viewBox="0 0 38 24" fill="context-fill" [p:10px 0]>
						<title> state.lang.increase_line_height
						<rect x="0" y="0" width="28" height="2">
						<rect x="0" y="11" width="38" height="2">
						<rect x="0" y="22" width="18" height="2">
				if window.chrome
					<.btnbox>
						<svg.cbtn @click=changeAlign(yes) viewBox="0 0 20 20" [p:10px 0]>
							<title> state.lang.auto_align
							<path d="M1 1h18v2H1V1zm0 8h18v2H1V9zm0 8h18v2H1v-2zM1 5h12v2H1V5zm0 8h12v2H1v-2z">
						<svg.cbtn @click=changeAlign(no) viewBox="0 0 20 20" [p:10px 0]>
							<title> state.lang.align_justified
							<path d="M1 1h18v2H1V1zm0 8h18v2H1V9zm0 8h18v2H1v-2zM1 5h18v2H1V5zm0 8h18v2H1v-2z">
				if window.innerWidth > 639
					<.btnbox>
						<svg.cbtn @click=changeMaxWidth(no) width="42" height="16" viewBox="0 0 42 16" fill="context-fill" [p: calc(42px - 28px) 0]>
							<title> state.lang.increase_max_width
							<path d="M14.5,7 L8.75,1.25 L10,-1.91791433e-15 L18,8 L17.375,8.625 L10,16 L8.75,14.75 L14.5,9 L1.13686838e-13,9 L1.13686838e-13,7 L14.5,7 Z">
							<path d="M38.5,7 L32.75,1.25 L34,6.58831647e-15 L42,8 L41.375,8.625 L34,16 L32.75,14.75 L38.5,9 L24,9 L24,7 L38.5,7 Z" transform="translate(33.000000, 8.000000) scale(-1, 1) translate(-33.000000, -8.000000)">
						<svg.cbtn @click=changeMaxWidth(yes) width="44" height="16" viewBox="0 0 44 16" fill="context-fill" [padding: calc(42px - 28px) 0]>
							<title> state.lang.decrease_max_width
							<path d="M14.5,7 L8.75,1.25 L10,-1.91791433e-15 L18,8 L17.375,8.625 L10,16 L8.75,14.75 L14.5,9 L1.13686838e-13,9 L1.13686838e-13,7 L14.5,7 Z" transform="translate(9.000000, 8.000000) scale(-1, 1) translate(-9.000000, -8.000000)">
							<path d="M40.5,7 L34.75,1.25 L36,-5.17110888e-16 L44,8 L43.375,8.625 L36,16 L34.75,14.75 L40.5,9 L26,9 L26,7 L40.5,7 Z">

				<menu-popup bind=store.show_fonts>
					<.btnbox.cbtn.aside_button.popup_menu_box [d:flex transform@important:none ai:center] @click=(do store.show_fonts = !store.show_fonts)>
						<span.font_icon> "B"
						settings.font.name
						if store.show_fonts
							<.popup_menu [l:0 y@off:-32px o@off:0] ease>
								for font in fonts
									<button.butt[ff: {font.code}] .active_butt=font.name==settings.font.name @click=setFontFamily(font)> font.name
								if localFonts.size
									<button.butt @click=toggleFontModal> '+ More'

				<menu-popup bind=state.show_languages>
					<.nighttheme.flex.popup_menu_box @click=(do state.show_languages = !state.show_languages)>
						state.lang.language
						<button.change_language> currentLanguage!
						if state.show_languages
							<.popup_menu [l:0 y@off:-32px o@off:0] ease>
								<button.butt .active_butt=('ukr'==state.language) @click=(do state.setLanguage('ukr'))> "Українська"
								<button.butt .active_butt=('eng'==state.language) @click=(do state.setLanguage('eng'))> "English"
								<button.butt .active_butt=('de'==state.language) @click=(do state.setLanguage('de'))> "Deutsch"
								<button.butt .active_butt=('pt'==state.language) @click=(do state.setLanguage('pt'))> "Portuguese"
								<button.butt .active_butt=('es'==state.language) @click=(do state.setLanguage('es'))> "Español"
								<button.butt .active_butt=('ru'==state.language) @click=(do state.setLanguage('ru'))> "русский"
				<button.nighttheme.parent_checkbox.flex @click=toggleParallelMode .checkbox_turned=settingsp.enabled>
					state.lang.parallel
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleParallelSynch .checkbox_turned=settings.parallel_synch>
					state.lang.parallel_synch
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleVersePicker .checkbox_turned=settings.verse_picker>
					state.lang.verse_picker
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleVerseBreak .checkbox_turned=settings.verse_break>
					state.lang.verse_break
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleVerseNumber .checkbox_turned=settings.verse_number>
					state.lang.verse_number
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleVerseCommentary .checkbox_turned=settings.verse_commentary>
					state.lang.verse_commentary
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleLockBooksMenu .checkbox_turned=settings.lock_books_menu>
					state.lang.lock_books_menu
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleTransitions .checkbox_turned=settings.transitions>
					state.lang.transitions
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleChronorder .checkbox_turned=chronorder>
					state.lang.chronological_order
					<p.checkbox> <span>
				unless MOBILE_PLATFORM
					<button.nighttheme.parent_checkbox.flex @click=fixDrawers .checkbox_turned=fixdrawers>
						state.lang.fixdrawers
						<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleDynamicContrast .checkbox_turned=settings.enable_dynamic_contrast>
					state.lang.dynamic_contrast
					<p.checkbox> <span>
				if settings.enable_dynamic_contrast
					<.contrast-slider>
						<p.flex>
							state.lang.contrast
							<span[ml:auto]> store.contrast
						<input id="contrast" type="range" min=20 max=200 step=5 bind=store.contrast @input=changeContrast>
						<datalist id="contrast">
							<option value="20" label="20">
							<option value="60" label="60">
							<option value="100" label="100">
							<option value="150" label="150">
							<option value="200" label="200">

				if window.navigator.onLine
					if state.db_is_available
						<.help @click=toggleDownloads>
							<svg.helpsvg viewBox="0 0 212.646728515625 159.98291015625" aria-hidden-true>
								<title> state.lang.download_translations
								<g transform="matrix(1.5 0 0 1.5 0 128)">
									<path d=svg_paths.download>
							state.lang.download_translations
					<a.help href='/downloads/' target="_blank" @click=install>
						<img.helpsvg[size:32px rd: 23%] src='/static/bolls.png' alt=state.lang.install_app>
						state.lang.install_app
					<.help @click=showDictionaryView>
						<span.font_icon> 'א'
						state.lang.dictionary
						<a[ml:auto] href='https://bohuslav.me/Dictionary/' target='_blank'>
							<svg.helpsvg[p:4px] xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px">
								<title> state.lang.dictionary + 'link'
								<path d="M0 0h24v24H0z" fill="none">
								<path d="M19 19H5V5h7V3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z">

				<.help @click=turnHelpBox>
					<svg.helpsvg aria-hidden="true" width="24" height="24" viewBox="0 0 24 24">
						<title> state.lang.help
						<path fill="none" d="M0 0h24v24H0z">
						<path d="M11 18h2v-2h-2v2zm1-16C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm0-14c-2.21 0-4 1.79-4 4h2c0-1.1.9-2 2-2s2 .9 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5 0-2.21-1.79-4-4-4z">
					state.lang.help
				<.help @click=turnSupport id="animated-heart">
					<svg.helpsvg aria-hidden="true" height="24" viewBox="0 0 24 24" width="24">
						<title> state.lang.support
						<path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="firebrick" >
					state.lang.support
				<.help @click=randomVerse>
					<svg.helpsvg viewBox="0 0 25 25" role="img" aria-hidden="true" width="24px" height="24px">
						<path fill="none" d="M0 0h25v25H0z">
						<path d="M17.5 4h-10A3.5 3.5 0 004 7.5v10A3.5 3.5 0 007.5 21h10a3.5 3.5 0 003.5-3.5v-10A3.5 3.5 0 0017.5 4zm-10 1H12v4.414A5.537 5.537 0 0010.973 7.6 2.556 2.556 0 009.1 6.869a2.5 2.5 0 00-1.814.794 2.614 2.614 0 00.2 3.684A3.954 3.954 0 008.671 12H5V7.5A2.5 2.5 0 017.5 5zm4.271 6.846a11.361 11.361 0 01-3.6-1.231 1.613 1.613 0 01-.146-2.271 1.5 1.5 0 011.094-.476h.021a1.7 1.7 0 011.158.464 11.4 11.4 0 011.472 3.514zM5 17.5V13h6.64c-.653 1.149-2.117 3.2-4.4 3.568a.5.5 0 10.158.987A7.165 7.165 0 0012 14.318V20H7.5A2.5 2.5 0 015 17.5zM17.5 20H13v-5.7a7.053 7.053 0 004.6 3.259.542.542 0 00.074.005.5.5 0 00.072-.995c-2.194-.325-3.632-2.253-4.377-3.567H20v4.5A2.5 2.5 0 0117.5 20zm2.5-8h-3.735a4.1 4.1 0 001.251-.678 2.614 2.614 0 00.2-3.684 2.5 2.5 0 00-1.816-.793 2.634 2.634 0 00-1.872.732A5.537 5.537 0 0013 9.389V5h4.5A2.5 2.5 0 0120 7.5zm-6.77-.179a11.405 11.405 0 011.479-3.513 1.694 1.694 0 011.158-.464h.021a1.5 1.5 0 011.094.476 1.613 1.613 0 01-.146 2.271 11.366 11.366 0 01-3.606 1.23z">
					state.lang.random

				unless state.pswv
					<a.help route-to="/donate/">
						<span.font_icon [mr:2px]> '🔥'
						state.lang.donate

				<.help @click=purcheCache>
					<span.font_icon [mr:2px]> '🧹'
					state.lang.purge_cache

				<footer>
					<p.footer_links>
						<a target="_blank" rel="noreferrer" href="http://t.me/bollsbible"> "Official Telegram"
						<a target="_blank" rel="noreferrer" href="https://github.com/Bolls-Bible/bain"> "GitHub"
						<a target="_blank" href="/api"> "API "
						<a target="_blank" href="/static/privacy_policy.html"> "Privacy Policy"
						<a target="_blank" rel="noreferrer" href="http://www.patreon.com/bolls"> "Patreon"
						<a target="_blank" href="/static/disclaimer.html"> "Disclaimer"
						<a target="_blank" rel="noreferrer" href="https://imba.io"> "Imba"
						<a target="_blank" rel="noreferrer" href="https://docs.djangoproject.com"> "Django"
						<a target="_blank" rel="noreferrer" href="http://t.me/Boguslavv"> "My Telegram 📱"
					<p[fs:12px pb:12px]>
						"🍇 v2.7.4 🗓 "
						<time dateTime='2025-03-08'> "8.3.2025"
					<p[fs:12px]>
						"© 2019-{new Date().getFullYear()} Павлишинець Богуслав 🎻 Pavlyshynets Bohuslav"


			if big_modal_block_content.length
				<section [pos:fixed t:0 b:0 r:0 l:0 bg:rgba(0,0,0,0.75) h:100% d:flex jc:center p:14vh 0 @lt-sm:0 o@off:0 visibility@off:hidden zi:{big_modal_block_content == "show_note" ? 1200 : 3}]
					@click=(do unless state.intouch then clearSpace!) ease>

					<div[pos:relative max-height:72vh @lt-sm:100vh max-width:64em @lt-sm:100% w:80% @lt-sm:100% bgc:$bgc bd:1px solid $acc-bgc-hover @lt-sm:none rd:16px @lt-sm:0 p:12px 24px @lt-sm:12px scale@off:0.75]
						.height_auto=((!search.search_result_header && big_modal_block_content=='search') or (big_modal_block_content=='dictionary' && (loading or !definitions_history.length))) @click.stop>

						if big_modal_block_content == 'show_help'
							<article.search_hat>
								<svg.close_search @click=clearSpace() viewBox="0 0 20 20">
									<title> state.lang.close
									<path[m: auto] d=svg_paths.close>
								<h1> state.lang.help
								<a href="mailto:bpavlisinec@gmail.com">
									<svg.filter_search width="16" height="16" viewBox="0 0 16 16">
										<title> state.lang.help
										<g>
											<path d="M16 2L0 7l3.5 2.656L14.563 2.97 5.25 10.656l4.281 3.156z">
											<path d="M3 8.5v6.102l2.83-2.475-.66-.754L4 12.396V8.5z" color="#000" font-weight="400" font-family="sans-serif" white-space="normal" overflow="visible" fill-rule="evenodd">
							<article.helpFAQ.search_body>
								<p[color: $acc-color-hover font-size: 0.9em]> state.lang.faqmsg
								<h3> state.lang.content
								<ul>
									for q in state.lang.HB
										<li> <a href="#{q[0]}"> q[0]
									if window.innerWidth >= 1024
										<li> <a href="#shortcuts"> state.lang.shortcuts
								for q in state.lang.HB
									<h3 id=q[0] > q[0]
									<p innerHTML=q[1]>
								if !MOBILE_PLATFORM
									<div id="shortcuts">
										<h3> state.lang.shortcuts
										for shortcut in state.lang.shortcuts_list
											<p> <span innerHTML=shortcut>
								<address.still_have_questions>
									state.lang.still_have_questions
									<a target="_blank" href="mailto:bpavlisinec@gmail.com"> " bpavlisinec@gmail.com"

						elif big_modal_block_content == 'show_compare'
							<article.search_hat>
								<svg.close_search @click=clearSpace() viewBox="0 0 20 20">
									<title> state.lang.close
									<path[m: auto] d=svg_paths.close>
								<h1> highlighted_title
								<svg.filter_search [stroke:$c stroke-width:2px] viewBox="0 0 561 561" @click=copyComparisonList>
									<title> state.lang.copy
									<path d=svg_paths.copy>
								<svg.filter_search [stroke:$c stroke-width:2px] @click=(do show_translations_for_comparison = !show_translations_for_comparison) viewBox="0 0 20 20" alt=state.lang.addcollection>
									<title> state.lang.compare
									<line x1="0" y1="10" x2="20" y2="10">
									<line x1="10" y1="0" x2="10" y2="20">
								if show_translations_for_comparison
									<[z-index: 1100 scale@off:0.75 y@off:-16px o@off:0 visibility@off:hidden] .filters ease>
										if compare_translations.length == translations.length
											<p[padding: 12px 8px]> state.lang.nothing_else
										<div[d:hflex bg:$bgc pos:sticky t:-8px]>
											<input.search [p:0 8px] bind=store.compare_translations_search placeholder=state.lang.search aria-label=state.lang.search [m:2px 8px max-width: calc(100% - 16px)]>
											<svg.close_search [mr:-16px @lt-sm:8px h:42px p:0px] @click=(show_translations_for_comparison = no) viewBox="0 0 20 20">
												<title> state.lang.close
												<path[m: auto] d=svg_paths.close>

										for translation in translations when (!compare_translations.find(do |element| return element == translation.short_name) and filterCompareTranslation translation)
											<a.book_in_list.book_in_filter dir="auto" @click=addTranslation(translation)> translation.short_name, ', ', translation.full_name


							<article$compare_body.search_body [scroll-behavior: auto]>
								<p.total_msg> state.lang.add_translations_msg

								<orderable-list list=comparison_parallel saveCompareChanges=saveCompareChanges.bind(this)>

								unless compare_translations.length
									<button[m: 16px auto; d: flex].more_results @click=(do show_translations_for_comparison = !show_translations_for_comparison)> state.lang.add_translation_btn

						elif big_modal_block_content == 'show_downloads'
							<article.search_hat>
								<svg.close_search @click=clearSpace() viewBox="0 0 20 20">
									<title> state.lang.close
									<path[m: auto] d=svg_paths.close>
								<h1[transform@important:none pos:relative c@hover:$acc-color-hover fill:$c @hover:$acc-color-hover cursor:pointer d:flex w:100% h:50px jc:center ai:center us:none]
									@click=(download_dictionaries = !download_dictionaries)>
									<span>
										if download_dictionaries
											state.lang.download_dictionaries
										else
											state.lang.download_translations
									<span[p:0 8px m:auto 0]>
										<svg [fill:inherit min-width:16px] width="16" height="10" viewBox="0 0 8 5">
											<title> 'expand'
											<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

								if state.deleting_of_all_dictionaries
									<svg.close_search.animated_downloading width="16" height="16" viewBox="0 0 16 16">
										<title> state.lang.loading
										<path d=svg_paths.loading [marker:none c:#000 of:visible fill:$c]>
								else
									<svg.close_search @click=(do state.clearDictionariesTable()) viewBox="0 0 12 16" alt=state.lang.delete>
										<title> state.lang.remove_all_dictionaries
										<path fill-rule="evenodd" clip-rule="evenodd" d="M11 2H9C9 1.45 8.55 1 8 1H5C4.45 1 4 1.45 4 2H2C1.45 2 1 2.45 1 3V4C1 4.55 1.45 5 2 5V14C2 14.55 2.45 15 3 15H10C10.55 15 11 14.55 11 14V5C11.55 5 12 4.55 12 4V3C12 2.45 11.55 2 11 2ZM10 14H3V5H4V13H5V5H6V13H7V5H8V13H9V5H10V14ZM11 4H2V3H11V4Z">
							<article.search_body>
								if download_dictionaries
									<div[o@off:0] ease>
										let no_dictionary_downloaded = yes
										for dictionary in dictionaries
											if window.navigator.onLine || state.downloaded_dictionaries.indexOf(dictionary.abbr) != -1
												no_dictionary_downloaded = no
												<a[d:flex py:8px pl:8px cursor:pointer bgc@hover:$acc-bgc-hover fill:$c @hover:$acc-color-hover rd:8px] @click=offlineDictionaryAction(dictionary.abbr)>
													if state.dictionaries_in_downloading.find(do |dict| return dict == dictionary.abbr)
														<svg.remove_parallel.close_search.animated_downloading  [fill:inherit] width="16" height="16" viewBox="0 0 16 16">
															<title> state.lang.loading
															<path d=svg_paths.loading [marker:none c:#000 of:visible fill:$c]>
													elif state.downloaded_dictionaries.indexOf(dictionary.abbr) != -1
														<svg.remove_parallel.close_search [fill:inherit]  viewBox="0 0 12 16" alt=state.lang.delete>
															<title> state.lang.delete
															<path fill-rule="evenodd" clip-rule="evenodd" d="M11 2H9C9 1.45 8.55 1 8 1H5C4.45 1 4 1.45 4 2H2C1.45 2 1 2.45 1 3V4C1 4.55 1.45 5 2 5V14C2 14.55 2.45 15 3 15H10C10.55 15 11 14.55 11 14V5C11.55 5 12 4.55 12 4V3C12 2.45 11.55 2 11 2ZM10 14H3V5H4V13H5V5H6V13H7V5H8V13H9V5H10V14ZM11 4H2V3H11V4Z">
													else
														<svg.remove_parallel.close_search [fill:inherit]  viewBox="0 0 212.646728515625 159.98291015625">
															<title> state.lang.download
															<g transform="matrix(1.5 0 0 1.5 0 128)">
																<path d=svg_paths.download>
													<span> "{state.lang[dictionaryDownloadStatus(dictionary.abbr)]} {<b> dictionary.abbr}, {dictionary.name}"
										if no_dictionary_downloaded
											state.lang["no_dictionary_downloaded"]

								else
									<div>
										for language in languages
											<div key=language.language>
												<a.book_in_list dir="auto" [jc: start pl: 0px] .pressed=(language.language == show_language_of) @click=showLanguageTranslations(language.language)>
													language.language
													<svg[ml: auto].arrow_next width="16" height="10" viewBox="0 0 8 5">
														<title> state.lang.open
														<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

												if language.language == show_language_of
													<ul[o@off:0 m:0 0 16px @off:-24px 0 24px transition-timing-function:quad h@off:0px of:hidden] dir="auto" ease>
														let no_translation_downloaded = yes
														for tr in language.translations
															if window.navigator.onLine || state.downloaded_translations.indexOf(tr.short_name) != -1
																no_translation_downloaded = no
																<a[d:flex py:8px pl:8px cursor:pointer bgc@hover:$acc-bgc-hover fill:$c @hover:$acc-color-hover rd:8px] @click=offlineTranslationAction(tr.short_name)>
																	if state.translations_in_downloading.find(do |translation| return translation == tr.short_name)
																		<svg.remove_parallel.close_search.animated_downloading  [fill:inherit] width="16" height="16" viewBox="0 0 16 16">
																			<title> state.lang.loading
																			<path d=svg_paths.loading [marker:none c:#000 of:visible fill:$c]>
																	elif state.downloaded_translations.indexOf(tr.short_name) != -1
																		<svg.remove_parallel.close_search [fill:inherit]  viewBox="0 0 12 16" alt=state.lang.delete>
																			<title> state.lang.delete
																			<path fill-rule="evenodd" clip-rule="evenodd" d="M11 2H9C9 1.45 8.55 1 8 1H5C4.45 1 4 1.45 4 2H2C1.45 2 1 2.45 1 3V4C1 4.55 1.45 5 2 5V14C2 14.55 2.45 15 3 15H10C10.55 15 11 14.55 11 14V5C11.55 5 12 4.55 12 4V3C12 2.45 11.55 2 11 2ZM10 14H3V5H4V13H5V5H6V13H7V5H8V13H9V5H10V14ZM11 4H2V3H11V4Z">
																	else
																		<svg.remove_parallel.close_search [fill:inherit]  viewBox="0 0 212.646728515625 159.98291015625">
																			<title> state.lang.download
																			<g transform="matrix(1.5 0 0 1.5 0 128)">
																				<path d=svg_paths.download>
																	<span> "{state.lang[translationDownloadStatus(tr.short_name)]} {<b> tr.short_name}, {tr.full_name}"

														if no_translation_downloaded
															state.lang["no_translation_downloaded"]

						elif big_modal_block_content == 'show_support'
							<article.search_hat>
								<svg.close_search @click=clearSpace() viewBox="0 0 20 20">
									<title> state.lang.close
									<path[m: auto] d=svg_paths.close>
								<h1> state.lang.support
								<a target="_blank" href="mailto:bpavlisinec@gmail.com">
									<svg.filter_search width="16" height="16" viewBox="0 0 16 16">
										<title> state.lang.help
										<g>
												<path d="M16 2L0 7l3.5 2.656L14.563 2.97 5.25 10.656l4.281 3.156z">
												<path d="M3 8.5v6.102l2.83-2.475-.66-.754L4 12.396V8.5z" color="#000" font-weight="400" font-family="sans-serif" white-space="normal" overflow="visible" fill-rule="evenodd">
							<article.helpFAQ.search_body>
								<h3> state.lang.ycdtitnw
								<ul> for text in state.lang.SUPPORT
									<li> <span innerHTML=text>
								<h3> state.lang.bgthnkst, ":"
								<ul> for text in thanks_to
									<li> <span innerHTML=text>

						elif big_modal_block_content == "show_note"
							<article.search_hat>
								<svg.close_search @click=clearSpace() viewBox="0 0 20 20">
									<title> state.lang.close
									<path[m: auto] d=svg_paths.close>
								<h1> state.lang.note, ', ', highlighted_title
								<svg.save_bookmark [width: 26px] viewBox="0 0 12 16" @click=sendBookmarksToDjango alt=state.lang.create>
									<title> state.lang.create
									<path fill-rule="evenodd" clip-rule="evenodd" d="M12 5L4 13L0 9L1.5 7.5L4 10L10.5 3.5L12 5Z">
							<article[o:0.8 fs:0.8em]>
								# display here the choosen verses
								let chosenVersesToIterate = choosen_parallel == 'first' ? verses : parallel_verses
								for verse in chosenVersesToIterate
									<>
										if verse.pk in choosenid
											<span innerHTML=verse.text id=verse.pk>
											' '
							<mark-down store=store lemon=state.lang.write_something_awesone>

						elif big_modal_block_content == "dictionary"
							<article#dict_hat.search_hat [pos:relative]>
								<svg.close_search [min-width:24px] @click=closeSearch(true) viewBox="0 0 20 20">
									<title> state.lang.close
									<path[m: auto] d=svg_paths.close>
								<button.arrow @click=prevDefinition() .disabled=(definitions_history_index == 0 or definitions_history.length == 0) title=state.lang.back>
									<svg.arrow_prev width="16" height="10" viewBox="0 0 8 5">
										<title> state.lang.back
										<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
								<button.arrow @click=nextDefinition() .disabled=(definitions_history.length - 1 == definitions_history_index) title=state.lang.next>
									<svg.arrow_next width="16" height="10" viewBox="0 0 8 5">
										<title> state.lang.next
										<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

								<input$dictionarysearch[w:100% bg:transparent font:inherit c:inherit p:0 8px fs:1.2em min-width:128px bd:none bdb@invalid:1px solid $acc-bgc bxs:none direction: {textDirection(store.definition_search)}]
									bind=store.definition_search minLength=2 type='text' placeholder=(state.lang.search) aria-label=state.lang.search
									@keydown.enter=loadDefinitions>

								<svg.close_search [w:24px min-width:24px mr:8px] viewBox="0 0 12 12" width="24px" height="24px" @click=loadDefinitions>
									<title> state.lang.search
									<path d=svg_paths.search>

								<svg.close_search [min-width:28px] @click=openDictionaryDownloads viewBox="0 0 212.646728515625 159.98291015625">
									<title> state.lang.download
									<g transform="matrix(1.5 0 0 1.5 0 128)">
										<path d=svg_paths.download>

							if !loading && definitions_history.length
								<article$definitions.search_body>
									<menu-popup bind=store.show_dictionaries>
										<.popup_menu_box
											[transform@important:none pos:relative p:8px 0px c@hover:$acc-color-hover fill:$c @hover:$acc-color-hover cursor:pointer tt:uppercase fw:500 fs:0.9em d:flex]
											@click=(do store.show_dictionaries = !store.show_dictionaries)>
											currentDictionary!
											<span[p:0 8px m:auto 0 auto auto]>
												<svg [fill:inherit min-width:16px] width="16" height="10" viewBox="0 0 8 5">
													<title> 'expand'
													<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

											if store.show_dictionaries
												<.popup_menu [l:0 y@off:-32px o@off:0] ease>
													for dictionary in dictionaries
														<button.butt .active_butt=(state.dictionary==dictionary.abbr) @click=(state.dictionary=dictionary.abbr;loadDefinitions!)> dictionary.name
									if window.navigator.onLine
										<button.nighttheme.parent_checkbox.flex [m:8px 0 fs:0.85em] @click=toggleExtendedDictionarySearch .checkbox_turned=settings.extended_dictionary_search>
											<span[ml:auto]> state.lang.extended_search
											<p.checkbox [m:0 8px 0 24px]> <span>

									for definition, index in definitions when index < 64
										<div.definition .expanded=(expanded_definition == index)>
											<div.hat @click=expandDefinition(index)>
												<p>
													<b> definition.lexeme
													<span> ' · '
													<span> definition.pronunciation
													<span> ' · '
													<span> definition.transliteration
													<span> ' · '
													<b> definition.short_definition
													<span> ' · '
													<span> definition.topic
												<svg [fill:$c min-width:16px] width="16" height="10" viewBox="0 0 8 5">
													<title> 'expand'
													<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">


											if expanded_definition == index
												<div[p:16px 0px 64px @off:0 h:auto @off:0px overflow:hidden bg:$bg o@off:0] innerHTML=definition.definition ease>

									unless definitions.length
										<div[display:flex flex-direction:column pt:25% lh:1.6]>
											<p> state.lang.nothing
											<p[pt:16px]> state.lang.dictionary_help

						elif big_modal_block_content == 'font'
							<article.search_hat>
								<svg.close_search @click=clearSpace() viewBox="0 0 20 20">
									<title> state.lang.close
									<path[m: auto] d=svg_paths.close>
								<h1> state.lang.setlocalfont

							<article.search_body>
								<input[w:100% bg:transparent font:inherit c:inherit p:0 8px fs:1.2em min-width:128px bd:none bdb@invalid:1px solid $acc-bgc bxs:none] bind=store.font_search minLength=2 type='text' placeholder=(state.lang.search) aria-label=state.lang.search>

								for font of localFonts when font.toLowerCase().includes(store.font_search.toLowerCase())
									<div[d:flex jc:space-between flw:wrap p:0.5rem bg@hover:var(--acc-bgc-hover) rd:0.25rem cursor:pointer] @click=(do state.font = font; setCookie("font", font)) @click=setLocalFontFamily(font)>
										<strong> font
										<span[font-family: {font}]> "The quick brown fox jumps over the lazy dog."

						else	# MAIN SEARCH
							if search_verses.length
								if search.show_filters
									<[z-index: 1 scale@off:0.75 y@off:-16px o@off:0 visibility@off:hidden] .filters ease>
										<div[d:hflex bg:$bgc ai:center jc:space-between p:0 8px pos:sticky t:-8px zi:24]>
											<p[ws:nowrap mr:8px fs:0.8em fw:bold]> state.lang.addfilter
											<svg.close_search [mr:-16px @lt-sm:0 h:42px p:0px] @click=(search.show_filters = no) viewBox="0 0 20 20">
												<title> state.lang.close
												<path[m: auto] d=svg_paths.close>
										if search.filter
											<button.book_in_list @click=dropFilter> state.lang.drop_filter

										<button.book_in_list[ta:left] @click=addFilter("ot")> state.lang.ot
										<button.book_in_list[ta:left] @click=addFilter("nt")> state.lang.nt

										if settingsp.edited_version == settingsp.translation && settingsp.enabled
											<>
												for book in parallel_books
													<button.book_in_list.book_in_filter .selected=(search.filter==book.bookid) .fruitless_book_in_filter=(!isBookPresentInSearchResults(book.bookid)) dir="auto" @click=addFilter(book.bookid)> book.name
										else
											<>
												for book in books
													<button.book_in_list.book_in_filter .selected=(search.filter==book.bookid) .fruitless_book_in_filter=(!isBookPresentInSearchResults(book.bookid)) dir="auto" @click=addFilter(book.bookid)> book.name

							<article.search_hat#gs_hat [pos:relative]>
								<svg.close_search [min-width:24px] @click=closeSearch(true) viewBox="0 0 20 20">
									<title> state.lang.close
									<path[m: auto] d=svg_paths.close>

								<input$generalsearch
									[w:100% bg:transparent font:inherit c:inherit p:0 8px fs:1.2em min-width:128px bd:none bdb@invalid:1px solid $acc-bgc bxs:none direction: {textDirection(search.search_input)}]
									minLength=3 type='text' placeholder=(state.lang.bible_search + ', ' + search.translation) aria-label=state.lang.bible_search
									bind=search.search_input @keydown.enter=getSearchText @input=searchSuggestions>

								if window.navigator.onLine
									<svg.search_option .search_option_on=search.match_case @click=(search.match_case = !search.match_case, setCookie("match_case", search.match_case)) width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg" fill="currentColor">
										<title> state.lang.match_case
										<path d="M8.85352 11.7021H7.85449L7.03809 9.54297H3.77246L3.00439 11.7021H2L4.9541 4H5.88867L8.85352 11.7021ZM6.74268 8.73193L5.53418 5.4502C5.49479 5.34277 5.4554 5.1709 5.41602 4.93457H5.39453C5.35872 5.15299 5.31755 5.32487 5.271 5.4502L4.07324 8.73193H6.74268Z">
										<path d="M13.756 11.7021H12.8752V10.8428H12.8537C12.4706 11.5016 11.9066 11.8311 11.1618 11.8311C10.6139 11.8311 10.1843 11.686 9.87273 11.396C9.56479 11.106 9.41082 10.721 9.41082 10.2412C9.41082 9.21354 10.016 8.61556 11.2262 8.44727L12.8752 8.21631C12.8752 7.28174 12.4974 6.81445 11.7419 6.81445C11.0794 6.81445 10.4815 7.04004 9.94793 7.49121V6.58887C10.4886 6.24512 11.1117 6.07324 11.8171 6.07324C13.1097 6.07324 13.756 6.75716 13.756 8.125V11.7021ZM12.8752 8.91992L11.5485 9.10254C11.1403 9.15983 10.8324 9.26188 10.6247 9.40869C10.417 9.55192 10.3132 9.80794 10.3132 10.1768C10.3132 10.4453 10.4081 10.6655 10.5978 10.8374C10.7912 11.0057 11.0472 11.0898 11.3659 11.0898C11.8027 11.0898 12.1626 10.9377 12.4455 10.6333C12.7319 10.3254 12.8752 9.93685 12.8752 9.46777V8.91992Z">

									<svg.search_option .search_option_on=search.match_whole @click=(search.match_whole = !search.match_whole, setCookie("match_whole", search.match_whole)) width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg" fill="currentColor">
										<title> state.lang.match_whole
										<path fill-rule="evenodd" clip-rule="evenodd" d="M0 11H1V13H15V11H16V14H15H1H0V11Z">
										<path d="M6.84048 11H5.95963V10.1406H5.93814C5.555 10.7995 4.99104 11.1289 4.24625 11.1289C3.69839 11.1289 3.26871 10.9839 2.95718 10.6938C2.64924 10.4038 2.49527 10.0189 2.49527 9.53906C2.49527 8.51139 3.10041 7.91341 4.3107 7.74512L5.95963 7.51416C5.95963 6.57959 5.58186 6.1123 4.82632 6.1123C4.16389 6.1123 3.56591 6.33789 3.03238 6.78906V5.88672C3.57307 5.54297 4.19612 5.37109 4.90152 5.37109C6.19416 5.37109 6.84048 6.05501 6.84048 7.42285V11ZM5.95963 8.21777L4.63297 8.40039C4.22476 8.45768 3.91682 8.55973 3.70914 8.70654C3.50145 8.84977 3.39761 9.10579 3.39761 9.47461C3.39761 9.74316 3.4925 9.96338 3.68228 10.1353C3.87564 10.3035 4.13166 10.3877 4.45035 10.3877C4.8872 10.3877 5.24706 10.2355 5.52994 9.93115C5.8164 9.62321 5.95963 9.2347 5.95963 8.76562V8.21777Z">
										<path d="M9.3475 10.2051H9.32601V11H8.44515V2.85742H9.32601V6.4668H9.3475C9.78076 5.73633 10.4146 5.37109 11.2489 5.37109C11.9543 5.37109 12.5057 5.61816 12.9032 6.1123C13.3042 6.60286 13.5047 7.26172 13.5047 8.08887C13.5047 9.00911 13.2809 9.74674 12.8333 10.3018C12.3857 10.8532 11.7734 11.1289 10.9964 11.1289C10.2695 11.1289 9.71989 10.821 9.3475 10.2051ZM9.32601 7.98682V8.75488C9.32601 9.20964 9.47282 9.59635 9.76644 9.91504C10.0636 10.2301 10.4396 10.3877 10.8944 10.3877C11.4279 10.3877 11.8451 10.1836 12.1458 9.77539C12.4502 9.36719 12.6024 8.79964 12.6024 8.07275C12.6024 7.46045 12.4609 6.98063 12.1781 6.6333C11.8952 6.28597 11.512 6.1123 11.0286 6.1123C10.5166 6.1123 10.1048 6.29134 9.7933 6.64941C9.48177 7.00391 9.32601 7.44971 9.32601 7.98682Z">

								<svg.close_search [w:24px min-width:24px mr:8px] viewBox="0 0 12 12" width="24px" height="24px" @click=getSearchText>
									<title> state.lang.bible_search
									<path d=svg_paths.search>

								if search_verses.length
									<svg.filter_search [min-width:24px] ease .filter_search_hover=search.show_filters||search.filter @click=(do search.show_filters = !search.show_filters) viewBox="0 0 20 20">
										<title> state.lang.addfilter
										<path d="M12 12l8-8V0H0v4l8 8v8l4-4v-4z">

								if search.suggestions.books..length or search.suggestions.translations..length
									<.search_suggestions>
										for book in search.suggestions.books
											<.flex>
												<text-as-html.book_in_list.focusable tabIndex="0" data={translation:search.suggestions.translation, book:book.bookid, chapter:search.suggestions.chapter, verse:search.suggestions.verse}>
													searchSuggestionText(book)
												<svg.open_in_parallel.focusable [margin-left: 4px] tabIndex="0" viewBox="0 0 400 338" @click=backInHistory({translation: search.suggestions.translation, book: book.bookid, chapter: search.suggestions.chapter,verse: search.suggestions.verse}, yes) @keydown.enter=backInHistory({translation: search.suggestions.translation, book: book.bookid, chapter: search.suggestions.chapter,verse: search.suggestions.verse}, yes)>
													<title> state.lang.open_in_parallel
													<path d=svg_paths.columnssvg [fill:inherit fill-rule:evenodd stroke:none stroke-width:1.81818187]>

										for translation in search.suggestions.translations
											<.flex>
												<li.book_in_list.focusable [display: flex] tabIndex="0" @click=changeTranslation(translation.short_name) @keydown.enter=changeTranslation(translation.short_name)>
													<span>
														<b> translation.short_name
														', '
														translation.full_name
												<svg.open_in_parallel.focusable tabIndex="0" [margin-left: 4px] viewBox="0 0 400 338" @click=openTranslationInParallel(translation.short_name) @keydown.enter=openTranslationInParallel(translation.short_name)>
													<title> state.lang.open_in_parallel
													<path d=svg_paths.columnssvg [fill:inherit fill-rule:evenodd stroke:none stroke-width:1.81818187]>

							if search.search_result_header
								<article.search_body id="search_body" @scroll=searchPagination>
									let filtered_books = getFilteredSearchVerses()
									<p.total_msg> search.search_result_header, ': ', search.results, ' / ',  filtered_books.length, ' ', state.lang.totalyresultsofsearch

									<>
										for verse, key in filtered_books when key < search.counter
											<a.search_item>
												<text-as-html.search_res_verse_text data=verse innerHTML=verse.text>
												<.search_res_verse_header>
													<span> nameOfBook(verse.book, self.editedTranslation), ' '
													<span> verse.chapter, ':'
													<span> verse.verse
													<svg.open_in_parallel @click=copyToClipboardFromSerach(verse) viewBox="0 0 561 561" alt=state.lang.copy>
														<title> state.lang.copy
														<path d=svg_paths.copy>
													<svg.open_in_parallel [margin-left: 4px] viewBox="0 0 400 338" @click=backInHistory({translation: search.translation, book: verse.book, chapter: verse.chapter,verse: verse.verse}, yes)>
														<title> state.lang.open_in_parallel
														<path d=svg_paths.columnssvg [fill:inherit fill-rule:evenodd stroke:none stroke-width:1.81818187]>
										if search.filter then <div[p:12px 0px ta:center]>
											state.lang.filter_name + ' ' + nameOfBook(search.filter, self.editedTranslation)
											<br>
											<button[d: inline-block; mt: 12px].more_results @click=dropFilter> state.lang.drop_filter
									unless search_verses.length
										<div[display:flex flex-direction:column height:100% justify-content:center align-items:center]>
											<p> state.lang.nothing
											<p[padding:32px 0px 8px]> state.lang.translation, ' ', search.translation
											<button.more_results @click=(lock_panel = yes;showTranslations!)> state.lang.change_translation


			if show_collections || show_share_box || choosenid.length
				<section [pos:fixed b:0 l:0 r:0 w:100% bgc:$bgc bdt:1px solid $acc-bgc ta:center zi:1100 y@off:100%] ease>
					if show_collections
						<div[o@off:0 h:auto @off:0px of@off:hidden] ease>
							<.collectionshat>
								<svg.svgBack viewBox="0 0 20 20" @click=turnCollections>
									<title> state.lang.back
									<path d="M3.828 9l6.071-6.071-1.414-1.414L0 10l.707.707 7.778 7.778 1.414-1.414L3.828 11H20V9H3.828z">
								if showAddCollection
									<p.saveto> state.lang.newcollection
								else
									<p.saveto> state.lang.saveto
									<svg.svgAdd @click=addCollection viewBox="0 0 20 20" alt=state.lang.showAddCollection>
										<title> state.lang.addcollection
										<line x1="0" y1="10" x2="20" y2="10">
										<line x1="10" y1="0" x2="10" y2="20">

							<.mark_grid [pt:0 pb:8px]>
								if showAddCollection
									<input.newcollectioninput placeholder=state.lang.newcollection id="newcollectioninput" bind=store.newcollection @keydown.enter.addNewCollection(store.newcollection) @keyup.validateNewCollectionInput type="text">
								elif categories.length
									<>
										if categories.length > 8
											<input.search placeholder=state.lang.search bind=store.collections_search [font:inherit c:inherit w:8em m:4px]>
									<>
										for category in categories.filter(do(el) return el.toLowerCase!.indexOf(store.collections_search.toLowerCase!) > -1)
											<p.collection .add_new_collection=(choosen_categories.find(do |element| return element == category)) @click=addNewCollection(category)> category
									<div[min-width: 16px]>
								else
									<p[m: 8px auto].collection.add_new_collection @click=addCollection> state.lang.addcollection
							if (store.newcollection && showAddCollection) || (choosen_categories.length && !showAddCollection)
								<button.cancel.add_new_collection @click=addNewCollection(store.newcollection)> state.lang.save
							else
								<button.cancel @click=turnCollections> state.lang.cancel
					elif show_share_box
						<div[o@off:0 h:auto @off:0px of@off:hidden] ease>
							<.collectionshat>
								<p.saveto> state.lang.share_via
							<.mark_grid[py:3px]>
								<.share_box @click=(do state.shareCopying(getShareObj()) && clearSpace())>
									<svg.share_btn viewBox="0 0 561 561" alt=state.lang.copy fill="var(--c)">
										<title> state.lang.copy
										<path d=svg_paths.copy>
								<.share_box @click=(do state.internationalShareCopying(getShareObj()) && clearSpace())>
									<svg.share_btn height="24" viewBox="0 0 24 24" width="24" fill="var(--c)">
										<title> state.lang.copy_international
										<path d="M12.87 15.07l-2.54-2.51.03-.03c1.74-1.94 2.98-4.17 3.71-6.53H17V4h-7V2H8v2H1v1.99h11.17C11.5 7.92 10.44 9.75 9 11.35 8.07 10.32 7.3 9.19 6.69 8h-2c.73 1.63 1.73 3.17 2.98 4.56l-5.09 5.02L4 19l5-5 3.11 3.11.76-2.04zM18.5 10h-2L12 22h2l1.12-3h4.75L21 22h2l-4.5-12zm-2.62 7l1.62-4.33L19.12 17h-3.24z">
								if canShareViaTelegram() then <.share_box @click=shareTelegram()>
									<svg.share_btn viewBox="0 0 240 240" [background: linear-gradient(#37aee2, #1e96c8); border-radius: 50%] alt="Telegram">
										<title> "Telegram"
										<g transform="matrix(3.468208 0 0 3.468208 0 -.00001)">
											<path d="M14.4 34.3l23.3-9.6c2.3-1 10.1-4.2 10.1-4.2s3.6-1.4 3.3 2c-.1 1.4-.9 6.3-1.7 11.6l-2.5 15.7s-.2 2.3-1.9 2.7-4.5-1.4-5-1.8c-.4-.3-7.5-4.8-10.1-7-.7-.6-1.5-1.8.1-3.2 3.6-3.3 7.9-7.4 10.5-10 1.2-1.2 2.4-4-2.6-.6l-14.1 9.5s-1.6 1-4.6.1-6.5-2.1-6.5-2.1-2.4-1.5 1.7-3.1z" fill="#fff">
								if canMakeTweet() then <.share_box @click=makeTweet()>
									<svg.share_btn viewBox="0 0 24 24" alt="Twitter">
										<title> "Twitter"
										<path d="M23.643 4.937c-.835.37-1.732.62-2.675.733.962-.576 1.7-1.49 2.048-2.578-.9.534-1.897.922-2.958 1.13-.85-.904-2.06-1.47-3.4-1.47-2.572 0-4.658 2.086-4.658 4.66 0 .364.042.718.12 1.06-3.873-.195-7.304-2.05-9.602-4.868-.4.69-.63 1.49-.63 2.342 0 1.616.823 3.043 2.072 3.878-.764-.025-1.482-.234-2.11-.583v.06c0 2.257 1.605 4.14 3.737 4.568-.392.106-.803.162-1.227.162-.3 0-.593-.028-.877-.082.593 1.85 2.313 3.198 4.352 3.234-1.595 1.25-3.604 1.995-5.786 1.995-.376 0-.747-.022-1.112-.065 2.062 1.323 4.51 2.093 7.14 2.093 8.57 0 13.255-7.098 13.255-13.254 0-.2-.005-.402-.014-.602.91-.658 1.7-1.477 2.323-2.41z" fill="#1da1f2">
								<.share_box @click=shareViaFB()>
									<svg.share_btn x="0px" y="0px" viewBox="0 0 64 64" [border-radius: 23% enable-background:new 0 0 64 64] alt="Facebook">
										<title> "Facebook"
										<path fill="#3D5A98" d="M60.5,64c2,0,3.5-1.6,3.5-3.5V3.5c0-2-1.6-3.5-3.5-3.5H3.5C1.6,0,0,1.6,0,3.5v56.9  c0,2,1.6,3.5,3.5,3.5H60.5z">
										<path fill="#FFFFFF" d="M44.2,64V39.2h8.3l1.2-9.7h-9.6v-6.2c0-2.8,0.8-4.7,4.8-4.7l5.1,0V10c-0.9-0.1-3.9-0.4-7.5-0.4  c-7.4,0-12.4,4.5-12.4,12.8v7.1h-8.3v9.7h8.3V64H44.2z">
								<.share_box @click=shareViaWhatsApp()>
									<svg.share_btn x="0px" y="0px" viewBox="0 0 512.303 512.303" [enable-background:new 0 0 512.303 512.303] alt="WhatsApp">
										<title> "WhatsApp"
										<path[fill:#4CAF50] d="M256.014,0.134C114.629,0.164,0.038,114.804,0.068,256.189c0.01,48.957,14.059,96.884,40.479,138.1 L0.718,497.628c-2.121,5.496,0.615,11.671,6.111,13.792c1.229,0.474,2.534,0.717,3.851,0.715c1.222,0.006,2.435-0.203,3.584-0.619 l106.667-38.08c120.012,74.745,277.894,38.048,352.638-81.965s38.048-277.894-81.965-352.638 C350.922,13.495,303.943,0.087,256.014,0.134z">
										<path[fill:#FAFAFA] d="M378.062,299.889c0,0-26.133-12.8-42.496-21.333c-18.517-9.536-40.277,8.32-50.517,18.475 c-15.937-6.122-30.493-15.362-42.816-27.179c-11.819-12.321-21.059-26.877-27.179-42.816c10.155-10.261,27.968-32,18.475-50.517 c-8.427-16.384-21.333-42.496-21.333-42.517c-1.811-3.594-5.49-5.863-9.515-5.867h-21.333c-31.068,5.366-53.657,32.474-53.333,64 c0,33.493,40.085,97.835,67.115,124.885s91.371,67.115,124.885,67.115c31.526,0.324,58.634-22.266,64-53.333v-21.333 C384.018,305.401,381.71,301.686,378.062,299.889z">
								<.share_box @click=shareViaViber()>
									<svg.share_btn viewBox='0 0 72 72' [border-radius: 23%]>
										<rect x="0" y="0" [fill:#7D3DAF] width="455.731" height="455.731">
										<title> "Viber"
										<g fill="#FFF" [transform: translateY(-20%) translateX(-25%) scale(1.5)]>
											<path d="M45.775 39.367c-.732-.589-1.514-1.118-2.284-1.658-1.535-1.078-2.94-1.162-4.085.573-.644.974-1.544 1.017-2.486.59-2.596-1.178-4.601-2.992-5.775-5.63-.52-1.168-.513-2.215.702-3.04.644-.437 1.292-.954 1.24-1.908-.067-1.244-3.088-5.402-4.281-5.84-.494-.182-.985-.17-1.488-.002-2.797.94-3.955 3.241-2.846 5.965 3.31 8.127 9.136 13.784 17.155 17.237.457.197.965.275 1.222.346 1.826.018 3.964-1.74 4.582-3.486.595-1.68-.662-2.346-1.656-3.147zm-8.991-16.08c5.862.9 8.566 3.688 9.312 9.593.07.545-.134 1.366.644 1.381.814.016.618-.793.625-1.339.068-5.56-4.78-10.716-10.412-10.906-.425.061-1.304-.293-1.359.66-.036.641.704.536 1.19.61z">
											<path d="M37.93 24.905c-.564-.068-1.308-.333-1.44.45-.137.82.692.737 1.225.856 3.621.81 4.882 2.127 5.478 5.719.087.524-.086 1.339.804 1.203.66-.1.421-.799.476-1.207.03-3.448-2.925-6.586-6.543-7.02z">
											<path d="M38.263 27.725c-.377.01-.746.05-.884.452-.208.601.229.745.674.816 1.485.239 2.267 1.114 2.415 2.596.04.402.295.727.684.682.538-.065.587-.544.57-.998.027-1.665-1.854-3.588-3.46-3.548z">
							<button.cancel @click=(do show_share_box = no; imba.commit!)> state.lang.cancel
					else
						<div[o@off:0 h:auto @off:0px of@off:hidden] ease>
							<p[pt:16px]>
								highlighted_title, ' '
								<span>
									if choosen_parallel == "first"
										settings.translation
									else
										settingsp.translation
							<ul.mark_grid>
								<li[border: none; bg: linear-gradient(217deg, rgba(255,0,0,.8), rgba(255,0,0,0) 70.71%), linear-gradient(127deg, rgba(0,255,0,.8), rgba(0,255,0,0) 70.71%), linear-gradient(336deg, rgba(0,0,255,.8), rgba(0,0,255,0) 70.71%)].color_mark @click=(do store.show_color_picker = !store.show_color_picker)>

								<li[background: FireBrick].color_mark @click=changeHighlightColor("#b22222")>
								<li[background: Chocolate].color_mark @click=changeHighlightColor("#d2691e")>
								<li[background: GoldenRod].color_mark @click=changeHighlightColor("#daa520")>
								<li[background: OliveDrab].color_mark @click=changeHighlightColor("#6b8e23")>
								<li[background: RoyalBlue].color_mark @click=changeHighlightColor("#4169e1")>
								<li[background: #984da5].color_mark @click=changeHighlightColor("#984da5")>

								for highlight in highlights.slice().reverse()
									<li[background: {highlight}].color_mark @click=changeHighlightColor(highlight)>
										<svg.delete_color
												@click=deleteColor(highlight)
												xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"
												>
											<title> state.lang.delete
											<path d=svg_paths.close>
							<div[pb:16px] id="addbuttons">
								if show_delete_bookmark
									<div .collection=(window.innerWidth > 475) @click=deleteBookmarks(choosenid) [o@off:0 w@off:0 p@off:0 of@off:hidden mr@off:-4px] ease>
										<svg.close_search viewBox="0 0 12 16" alt=state.lang.delete>
											<title> state.lang.delete
											<path fill-rule="evenodd" clip-rule="evenodd" d="M11 2H9C9 1.45 8.55 1 8 1H5C4.45 1 4 1.45 4 2H2C1.45 2 1 2.45 1 3V4C1 4.55 1.45 5 2 5V14C2 14.55 2.45 15 3 15H10C10.55 15 11 14.55 11 14V5C11.55 5 12 4.55 12 4V3C12 2.45 11.55 2 11 2ZM10 14H3V5H4V13H5V5H6V13H7V5H8V13H9V5H10V14ZM11 4H2V3H11V4Z">
										<p> state.lang.delete
								<div .collection=(window.innerWidth > 475) @click=clearSpace()>
									<svg.close_search viewBox="0 0 20 20" alt=state.lang.close>
										<title> state.lang.close
										<path d=svg_paths.close alt=state.lang.close>
									<p> state.lang.close
								<div .collection=(window.innerWidth > 475) @click=(do show_share_box = yes)>
									<svg.save_bookmark [stroke:none] @click=(do show_share_box = yes) xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24">
										<title> state.lang.share
										<path d="M0 0h24v24H0V0z" fill="none">
										<path d="M16 5l-1.42 1.42-1.59-1.59V16h-1.98V4.83L9.42 6.42 8 5l4-4 4 4zm4 5v11c0 1.1-.9 2-2 2H6c-1.11 0-2-.9-2-2V10c0-1.11.89-2 2-2h3v2H6v11h12V10h-3V8h3c1.1 0 2 .89 2 2z">
									<p> state.lang.share
								<div .collection=(window.innerWidth > 475) @click=copyToClipboard()>
									<svg.save_bookmark viewBox="0 0 561 561" alt=state.lang.copy>
										<title> state.lang.copy
										<path d=svg_paths.copy>
									<p> state.lang.copy
								<div .collection=(window.innerWidth > 475) @click=toggleCompare()>
									<svg.save_bookmark viewBox='0 0 400 400'>
										<title> state.lang.compare
										<path d="m 158.87835,59.714254 c -22.24553,22.942199 -40.6885,42.183936 -40.98426,42.758776 -0.8318,1.61252 -0.20661,2.77591 3.5444,6.59866 5.52042,5.6227 1.07326,9.0169 37.637,-28.724885 17.50924,-18.073765 32.15208,-32.92934 32.53977,-33.012765 2.11329,-0.454845 1.99262,-9.787147 1.99262,154.63098 0,162.70162 0.0852,155.59667 -1.92404,155.16124 -0.4175,-0.0891 -31.30684,-31.67221 -68.64371,-70.1831 -82.516734,-85.113 -79.762069,-82.23881 -79.523922,-82.9759 0.156562,-0.48685 7.785466,-0.64342 40.516819,-0.82856 33.282953,-0.18856 40.451433,-0.33827 41.056163,-0.85598 0.99477,-0.85141 1.07891,-10.82255 0.10651,-12.19963 -1.01499,-1.43197 -104.747791,-1.64339 -106.131194,-0.216 -1.408859,1.45366 -1.422172,108.27345 -0.01065,109.72598 1.061864,1.09597 10.873494,1.39767 11.873689,0.36572 0.405788,-0.41828 0.535724,-10.38028 0.551701,-41.94167 0.01065,-31.23452 0.150173,-41.70737 0.55383,-42.67534 l 0.533593,-1.28109 78.641191,81.10851 c 43.25264,44.609 79.6823,82.26506 80.95505,83.67874 1.27157,1.41482 2.51534,2.57136 2.7635,2.57136 3.82365,0.0993 6.74023,0.19783 10.78264,0.32569 l 2.48223,-2.72678 c 9.56539,-10.51282 158.34672,-163.337 159.13762,-163.46273 1.69462,-0.2697 1.72007,0.33714 1.72678,42.53708 0.007,40.52683 0.0212,41.4788 0.86376,41.94164 1.22845,0.67884 10.78936,0.61599 11.45949,-0.0754 0.94791,-0.97828 0.75087,-109.32029 -0.20024,-110.13513 -0.61027,-0.52227 -9.49349,-0.64912 -53.0551,-0.75425 l -52.32298,-0.128 -0.77536,0.97824 c -1.17177,1.47768 -1.14409,11.36197 0.032,12.46251 0.74235,0.69256 4.25002,0.75654 41.35204,0.75654 22.29752,0 40.6652,0.12915 40.81803,0.28686 0.75194,0.77597 -5.99106,7.88549 -73.9736,77.99435 -74.8598,77.20005 -74.60834,76.94635 -75.706,76.51207 -0.65608,-0.25942 -1.04162,-309.073405 -0.38768,-310.829927 0.51549,-1.385101 3.29625,1.278819 28.18793,26.998083 44.2328,45.702694 38.02575,40.757704 43.65905,34.786424 4.03624,-4.27873 4.21348,-4.55415 3.74602,-5.85812 -0.56235,-1.56794 -81.63283,-85.027265 -82.59319,-85.027265 -0.5123,0 -16.36846,16.023541 -41.27664,41.713088" [stroke-width:20;stroke-miterlimit:4;stroke-opacity:1;stroke-linecap:round;stroke-linejoin:round;paint-order:normal] fill-rule="evenodd">
									<p> state.lang.compare
								<div .collection=(window.innerWidth > 475) @click=makeNote()>
									<svg.save_bookmark .filled=isNoteEmpty() viewBox="0 0 24 24" fill="black" alt=state.lang.note>
										<title> state.lang.note
										<path d="M 9.0001238,20.550118 H 24.00033 V 16.550063 H 13.000179 Z M 16.800231,8.7499555 c 0.400006,-0.400006 0.400006,-1.0000139 0,-1.4000194 L 13.200182,3.7498865 c -0.400006,-0.4000055 -1.000014,-0.4000055 -1.40002,0 L 0,15.550049 v 5.000069 h 5.0000688 z">
									<p> state.lang.note
								<div .collection=(window.innerWidth > 475) @click=turnCollections()>
									<svg.save_bookmark .filled=choosen_categories.length viewBox="0 0 20 20" alt=state.lang.bookmark>
										<title> state.lang.bookmark
										<path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2zm2 0v15l6-3 6 3V2H4z">
									<p> state.lang.bookmark
								<div .collection=(window.innerWidth > 475) @click=sendBookmarksToDjango>
									<svg.save_bookmark viewBox="0 0 12 16" alt=state.lang.create>
										<title> state.lang.create
										<path fill-rule="evenodd" clip-rule="evenodd" d="M12 5L4 13L0 9L1.5 7.5L4 10L10.5 3.5L12 5Z">
									<p> state.lang.create
							if store.show_color_picker
								<svg.close_colorPicker
										xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 16"
										[scale@off:0.75 o@off:0] ease>
									<title> state.lang.close
									<path fill-rule="evenodd" clip-rule="evenodd" d="M12 5L4 13L0 9L1.5 7.5L4 10L10.5 3.5L12 5Z">
								<color-picker bind=store @closecp=closecp .show-canvas=store.show_color_picker width="320" height="208" alt=state.lang.canvastitle [scale@off:0.75 o@off:0] ease>  state.lang.canvastitle


			if store.show_history
				<menu-popup bind=store.show_history scrollinview=no ease>
					<section.small_box.filters [pos:fixed b:16px t:auto r:16px w:300px max-height:calc(100vh - 32px) p:8px zi:4 o@off:0 origin:bottom right transform@off:scale(0.75)]>
						<[m: 0 c:inherit].nighttheme.flex>
							<svg[m: 0 8px].close_search @click=turnHistory() viewBox="0 0 20 20">
									<title> state.lang.close
									<path d=svg_paths.close>
							<h1[margin: 0 0 0 8px]> state.lang.history
							<svg.close_search [p:0 m:0 4px 0 auto w:32px] @click=clearHistory() viewBox="0 0 24 24" alt=state.lang.delete>
								<title> state.lang.delete
								<path d="M15 16h4v2h-4v-2zm0-8h7v2h-7V8zm0 4h6v2h-6v-2zM3 20h10V8H3v12zM14 5h-3l-1-1H6L5 5H2v2h12V5z">
						<article[of:auto max-height: calc(97vh - 82px)]>
							for h in history
								<div[display: flex]>
									<a.book_in_list @click=backInHistory(h)>
										getNameOfBookFromHistory(h.translation, h.book) + ' ' + h.chapter
										if h.verse
											':' + h.verse
										' ' + h.translation
									<svg.open_in_parallel viewBox="0 0 400 338" @click=backInHistory(h, yes)>
										<title> state.lang.open_in_parallel
										<path d=svg_paths.columnssvg [fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187]>
							unless history.length
								<p[padding: 12px]> state.lang.empty_history


			if menuicons and not (big_modal_block_content && window.innerWidth < 640)
				<section#navigation [o@off:0 t@lg:0px b@lt-lg:{-menu_icons_transform}px height:48px @lg:0px bgc@lt-lg:$bgc d:flex jc:space-between] ease>
					<div[transform: translateY({menu_icons_transform}%) translateX({bibleIconTransform!}px)] @click=toggleBibleMenu>
						<svg viewBox="0 0 16 16">
							<title> state.lang.change_book
							<path d="M3 5H7V6H3V5ZM3 8H7V7H3V8ZM3 10H7V9H3V10ZM14 5H10V6H14V5ZM14 7H10V8H14V7ZM14 9H10V10H14V9ZM16 3V12C16 12.55 15.55 13 15 13H9.5L8.5 14L7.5 13H2C1.45 13 1 12.55 1 12V3C1 2.45 1.45 2 2 2H7.5L8.5 3L9.5 2H15C15.55 2 16 2.45 16 3ZM8 3.5L7.5 3H2V12H8V3.5ZM15 3H9.5L9 3.5V12H15V3Z">
					<div[transform: translateY({menu_icons_transform}%) d@lg:none] @click=turnGeneralSearch>
						<svg.helpsvg [p:2px] viewBox="0 0 12 12" width="24px" height="24px">
							<title> state.lang.search
							<path d=svg_paths.search>
					<div[transform: translateY({menu_icons_transform}%) translateX({settingsIconTransform!}px)] @click=toggleSettingsMenu>
						<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
							<title> state.lang.other
							<path d="M7.502 1.019a.996.996 0 0 0-.998.998v.451a5.734 5.734 0 0 0-1.356.566l-.322-.322a.995.995 0 0 0-1.41 0l-.705.705a.995.995 0 0 0 0 1.41l.32.32a5.734 5.734 0 0 0-.56 1.358h-.454a.995.995 0 0 0-.998.996V8.5c0 .553.446.996.998.996h.45a5.734 5.734 0 0 0 .566 1.356l-.322.322a.995.995 0 0 0 0 1.41l.705.705c.39.391 1.02.391 1.41 0l.32-.32a5.734 5.734 0 0 0 1.358.56v.456c0 .552.445.996.998.996h.996a.995.995 0 0 0 .998-.996v-.451a5.734 5.734 0 0 0 1.355-.567l.323.322c.39.391 1.02.391 1.41 0l.705-.705a.995.995 0 0 0 0-1.41l-.32-.32a5.734 5.734 0 0 0 .56-1.358h.453a.995.995 0 0 0 .998-.996v-.998a.995.995 0 0 0-.998-.996h-.449a5.734 5.734 0 0 0-.566-1.355l.322-.323a.995.995 0 0 0 0-1.41l-.705-.705a.995.995 0 0 0-1.41 0l-.32.32a5.734 5.734 0 0 0-1.358-.56v-.455a.996.996 0 0 0-.998-.998zm.515 3.976a3 3 0 0 1 3 3 3 3 0 0 1-3 3 3 3 0 0 1-3-3 3 3 0 0 1 3-3z" style="marker:none">


			if loading
				<loading-animation [pos:fixed t:50% l:50% zi:100 o@off:0] ease>


			if settings.verse_picker and (show_verse_picker || show_parallel_verse_picker)
				<section.small_box [pos:fixed t:8vh l:48px w:300px p:12px pt:8px zi:100  max-height:86% origin:top left scale@off:0.96 y@off:-16px o@off:0] ease>
					<.flex>
						<h1[margin: 0 auto;font-size: 1.3em; line-height: 1;]> state.lang.choose_verse
						<svg[m: 0 8px].close_search @click=hideVersePicker viewBox="0 0 20 20">
							<title> state.lang.close
							<path d=svg_paths.close>
					<div>
						if show_verse_picker
							<>
								for verse in verses
									<a.chapter_number @click=goToVerse(verse.verse)> verse.verse
						elif show_parallel_verse_picker
							<>
								for pverse in parallel_verses
									<a.chapter_number @click=goToVerse('p' + (pverse.verse))> pverse.verse


			if welcome != 'false'
				<section#welcome.small_box [pos:fixed zi:9999 r:16px b:16px p:16px o@off:0 scale@off:0.75 origin:bottom right w:300px] ease>
					<h1[margin: 0 auto 12px; font-size: 1.2em]> state.lang.welcome
					<p[mb:8px lh:1.5 fs:0.9em ws:pre-line]> state.lang.welcome_msg, <span.emojify> ' 😉'
					<button [w:100% h:32px bg:$acc-bgc @hover:$acc-bgc-hover c:$c @hover:$acc-color-hover ta:center border:none fs:1em rd:4px cursor:pointer] @click=welcomeOk> "Ok ", <span.emojify> '👌🏽'


			if page_search.d
				<section#page_search [background-color: {page_search.matches.length || !page_search.query.length ? 'var(--bgc)' : 'firebrick'} pos:fixed b:0 y@off:100% l:0 r:0 d:flex ai:center bdt:1px solid $acc-bgc p:2px 8px zi:1100] ease>
					<input$pagesearch.search bind=page_search.query @input.pageSearch @keydown.enter.pageSearchKeydownManager [border-top-right-radius: 0;border-bottom-right-radius: 0 direction: {textDirection(page_search.query)}] placeholder=state.lang.find_in_chapter>
					<button.arrow @click=prevOccurence() title=state.lang.prev [border-radius: 0]>
						<svg width="16" height="10" viewBox="0 0 8 5" [transform: rotate(180deg)]>
							<title> state.lang.prev
							<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
					<button.arrow @click=nextOccurence() title=state.lang.next [border-top-left-radius: 0; border-bottom-left-radius: 0; border-top-right-radius: 4px; border-bottom-right-radius: 4px margin-right:16px]>
						<svg width="16" height="10" viewBox="0 0 8 5">
							<title> state.lang.next
							<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
					if page_search.matches.length
						<p> page_search.current_occurence + 1, ' / ', page_search.matches.length
					elif page_search.query.length != 0 && window.innerWidth > 640
						<p> state.lang.phrase_not_found, '!'
						<title> state.lang.delete
						<path[m:auto] d=svg_paths.close>

					<svg.close_search [ml:auto min-width:26px] @click=clearSpace viewBox="0 0 20 20">
						<title> state.lang.close
						<path[m: auto] d=svg_paths.close>


			if window.location.pathname != '/profile/'
				<global
					@hotkey('mod+shift+f|mod+k').force.prevent.stop.cleanUpSelection=turnGeneralSearch
					@hotkey('s|f|і|а').prevent.stop.prepareForHotKey=turnGeneralSearch
					@hotkey('mod+f').prevent.stop.prepareForHotKey=pageSearch
					@hotkey('mod+d').prevent.stop=showDictionaryView
					@hotkey('alt+s').prevent.stop=showStongNumberDefinition
					@hotkey('alt+r').prevent.stop=randomVerse
					@hotkey('escape').force.prevent.stop=clearSpace
					@hotkey('mod+y').prevent.stop=fixDrawers
					@hotkey('mod+alt+h').prevent.stop=(menuicons = !menuicons, setCookie("menuicons", menuicons), imba.commit!)


					@hotkey('mod+right').prevent.stop=nextChapter(no)
					@hotkey('mod+left').prevent.stop=prevChapter(no)
					@hotkey('mod+n').prevent.stop=nextBook
					@hotkey('mod+p').prevent.stop=prevBook
					@hotkey('alt+n').prevent.stop=nextBook
					@hotkey('alt+p').prevent.stop=prevBook
					@hotkey('alt+shift+right').prevent.stop=nextChapter(yes)
					@hotkey('alt+shift+left').prevent.stop=prevChapter(yes)

					@hotkey('mod+[').prevent.stop=decreaseFontSize
					@hotkey('mod+]').prevent.stop=increaseFontSize

					@hotkey('alt+right').prevent.stop=window.history.forward!
					@hotkey('alt+left').prevent.stop=window.history.back!

					@hotkey('mod+,').prevent.stop=turnHelpBox
				>



	css
		height: 100vh
		display: flex
		ofy: auto
		pos: relative
		transition-property@force: none
		-webkit-overflow-scrolling@force: auto

	css .height_auto
		max-height@important:76px
		mb:auto
		border-bottom:1px solid $acc-bgc-hover

	css .aside_button
		w:100% h:46px bg:transparent @hover:$acc-bgc-hover d:flex ai:center font:inherit p:0 12px

	css .search_suggestions
		d:flex fld:column p:8px
		max-height:calc(72vh - 50px)
		of:auto
		pos:absolute t:100% r:0 l:0 zi:1
		bg:$bgc
		border:1px solid $acc-bgc-hover bdt:none rdbl:8px rdbr:8px
		visibility:hidden
		o:0

	css #gs_hat:focus-within > .search_suggestions
		visibility:visible
		o:1

	css
		#dict_hat
			button
				bgc:transparent
				w:32px
				min-width:26px
				h:50px
				p:8px 0


	css note-up svg
		size:0.68em
		fill:inherit
		stroke:inherit

	css #navigation
		pos:fixed
		right: 0px
		left: 0px
		w:100%
		zi:2 cursor:pointer
		bdt@lt-lg:1px solid $acc-bgc

	css #navigation > div
		padding:3em @lt-lg:4px
		width:calc(100% / 3) @lg:auto
		height:48px @lg:auto
		c@hover:$acc-color-hover
		fill:$acc-color @hover:$acc-color-hover @lt-lg:$c
		d@lt-lg:vflex jc:center ai:center

	css #navigation svg
		width: 26px
		height: 26px
		min-height: 26px
		fill:inherit
		o@lt-lg:0.75 @hover:1

	css .small_box
		bgc:$bgc
		bd:1px solid $acc-bgc
		rd:16px
		ofy:auto
		-webkit-overflow-scrolling:touch

	css .search_option
		w:24px min-width:24px mr:8px
		o:0.5 @hover: 0.75
		h:auto
		cursor:pointer

	css
		.search_option_on
			o:1 @hover:1

		.definition
			overflow:hidden
			lh:1.6

		.definition
			.hat
				d:flex
				ai:center
				pos:sticky
				p:8px 8px 8px 0
				cursor:pointer
				t:0px
				m:0
				bg:$bg
				bdt:1px solid $acc-bgc

			p
				ws:break-spaces

			svg
				transform:$svg-transform
				ml:auto

		.expanded
			$svg-transform:rotate(180deg)

		.disabled
			o:0.5
			transform:none

		.host_rectangle
			bg:$acc-bgc rd:4px
			bd:1px solid $acc-bgc-hover

		.host_rectangle button
			p: 8px
			bgc:transparent @hover:$acc-bgc-hover
			fs:inherit font:inherit c:inherit
			cursor:pointer

		.contrast-slider
			input
				w:100%
				accent-color: $acc-color
				-webkit-appearance: none
				appearance: none
				bgc: $acc-bgc @hover: $acc-bgc-hover
				outline: none
				mt:0.5rem
				rd:full
				h:0.5rem

			datalist
				display: flex
				justify-content: space-between
				width: 100%
				margin-top: 7px
				padding: 0 5px

			input[type="range"]::-webkit-slider-thumb, input[type=range]::-moz-range-thumb
				-webkit-appearance: none
				height: 1.25rem
				width: 1.25rem
				border-radius: 50%
				background: $acc-color
				cursor: ew-resize
			

