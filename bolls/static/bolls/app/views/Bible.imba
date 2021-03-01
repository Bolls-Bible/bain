import *  as BOOKS from "./translations_books.json"
import languages from "./languages.json"
import './Profile'
import "./loading.imba"
import "./downloads.imba"
import "./rich_text_editor"
import "./colorPicker.imba"
import "./compare-draggable-item"
import './search-text-as-html'
import {thanks_to} from './thanks_to'
import {svg_paths} from "./svg_paths"

let html = document.documentElement

let agent = window.navigator.userAgent;
let isWebkit = (agent.indexOf("AppleWebKit") > 0);
let isIPad = (agent.indexOf("iPad") > 0);
let isIOS = (agent.indexOf("iPhone") > 0 || agent.indexOf("iPod") > 0)
let isAndroid = (agent.indexOf("Android")  > 0)
let isNewBlackBerry = (agent.indexOf("AppleWebKit") > 0 && agent.indexOf("BlackBerry") > 0)
let isWebOS = (agent.indexOf("webOS") > 0);
let isWindowsMobile = (agent.indexOf("IEMobile") > 0)
let isSmallScreen = (screen.width < 767 || (isAndroid && screen.width < 1000))
let isUnknownMobile = (isWebkit && isSmallScreen)
let isMobile = (isIOS || isAndroid || isNewBlackBerry || isWebOS || isWindowsMobile || isUnknownMobile)
let isTablet = (isIPad || (isMobile && !isSmallScreen))

let MOBILE_PLATFORM = no

if isMobile && isSmallScreen && document.cookie.indexOf( "mobileFullSiteClicked=") < 0
	MOBILE_PLATFORM = yes

const inner_height = window.innerHeight
let iOS_keaboard_height = 0

let translations = []
for language in languages
	translations = translations.concat(language.translations)

let settings =
	theme: 'light'
	accent: 'blue'
	sepia: yes
	translation: 'YLT'
	book: 1
	chapter: 1
	font:
		size: window.innerWidth > 512 ? 24 : 20
		family: "sans, sans-serif"
		name: "Sans Serif"
		line-height: window.innerWidth > 512 ? 2 : 1.8
		weight: 400
		max-width: 30
		align: ''
	verse_break: no
	verse_picker: no
	transitions: yes
	name_of_book: ''
	filtered_books: []
	parallel_synch: yes

# Detect dark mode
if window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
	settings.theme = 'dark'
	settings.sepia = no
	settings.accent = 'gold'

# Detect change of dark/light mode
window.matchMedia('(prefers-color-scheme: dark)')
.addEventListener('change', do |event|
	const bible = document.getElementsByTagName("BIBLE-READER")
	if bible[0]
		if event.matches
			bible[0].changeTheme('dark')
		else
			bible[0].turnSepia!
)


let settingsp = {
	display: no
	translation: 'WLCC'
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
let show_history = no
let choosen_parallel = no
let store =
	newcollection: ''
	book_search: ''
	highlight_color: ''
	show_color_picker: no
	note: ''

let page_search =
	d: no
	query: ''
	matches: []
	current_occurence: 1
	rects: []

let addcollection = no
let choosen_categories = []
window.on_pops_tate = no
let loading = no
let menuicons = yes
let fixdrawers = no
let show_fonts = no
let max_header_font = 0
let show_accents = no
let show_verse_picker = no
let show_parallel_verse_picker = no
let show_language_of = ''
let show_share_box = no
let what_to_show_in_pop_up_block = ''
let deleting_of_all_transllations = no
let choosen_for_comparison = []
let comparison_parallel = []
let new_comparison_parallel = []
let show_delete_bookmark = no
let show_translations_for_comparison = no
let welcome = yes
let slidetouch = null
let compare_translations = []
let compare_parallel_of_chapter
let compare_parallel_of_book
let highlighted_title = ''
const fonts = [
	{
		name: "David Libre",
		code: "'David Libre', serif"
	},
	{
		name: "Bellefair",
		code: "'Bellefair', serif"
	},
	{
		name: "Tinos",
		code: "'Tinos', serif"
	},
	{
		name: "Roboto Slab",
		code: "'Roboto Slab', sans-serif"
	},
	{
		name: "Sans Serif",
		code: "sans, sans-serif"
	},
	{
		name: "Monospace",
		code: "monospace"
	},
	{
		name: "Deutsch Gothic",
		code: "Deutsch Gothic, sans-serif"
	},
]

const accents = [
	{
		name: "green",
		light: '#9acd32',
		dark: '#9acd32'
	},
	{
		name: "blue",
		light: '#8080FF',
		dark: '#417690'
	},
	{
		name: "purple",
		light: '#984da5',
		dark: '#994EA6'
	},
	{
		name: "gold",
		light: '#DAA520',
		dark: '#E1AF33'
	},
	{
		name: "red",
		light: '#DE5454',
		dark: '#D93A3A'
	},
]

document.onkeydown = do |e|
	e = e || window.event
	const bible = document.getElementsByTagName("BIBLE-READER")
	if bible[0]
		const bibletag = bible[0]
		if document.activeElement.tagName != 'INPUT' && document.activeElement.contentEditable != 'true' && document.getSelection().isCollapsed
			if e.code == "ArrowRight" && e.altKey && e.ctrlKey
				bibletag.nextChapter('true')
			elif e.code == "ArrowLeft" && e.altKey && e.ctrlKey
				bibletag.prevChapter('true')
			elif e.code == "ArrowRight" && e.ctrlKey
				bibletag.nextChapter()
			elif e.code == "ArrowLeft" && e.ctrlKey
				bibletag.prevChapter()
			elif e.code == "KeyN" && e.altKey
				bibletag.nextBook()
			elif e.code == "KeyP" && e.altKey
				bibletag.prevBook()
		if e.code == "Escape"
			bibletag.clearSpace()
		if e.ctrlKey && e.code == "KeyF"
			e.preventDefault!
			e.stopPropagation!
			page_search.query = window.getSelection().toString()
			bibletag.clearSpace!
			bibletag.pageSearch!
		if e.ctrlKey && e.code == "KeyF" && e.shiftKey
			e.preventDefault!
			e.stopPropagation!
			bibletag.clearSpace!
			bibletag.turnGeneralSearch!
	if e.code == "KeyH" && e.altKey && e.ctrlKey
		menuicons = !menuicons
		imba.commit()
		window.localStorage.setItem("menuicons", menuicons)
	elif e.code == "KeyY" && e.ctrlKey
		fixdrawers = !fixdrawers
		imba.commit()
		window.localStorage.setItem("fixdrawers", fixdrawers)
	elif e.code == "ArrowRight" && e.altKey
		e.preventDefault()
		window.history.forward()
	elif e.code == "ArrowLeft" && e.altKey
		e.preventDefault()
		window.history.back()

document.onfocus = do
	for item in document.getElementsByTagName('BIBLE-READER')
		item.focus!

export tag bible-reader
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
	prop search = {}

	def setup
		# We check this out in the case when url has parameters that indicates wantes translation, chapter, etc
		if window.translation
			if translations.find(do |element| return element.short_name == window.translation)
				if window.location.pathname.indexOf('international') > -1
					console.log("HERE WE GO")
					window.translation = getCookie('translation') || settings.translation
					window.verses = []
				setCookie('translation', window.translation)
				setCookie('book', window.book)
				setCookie('chapter', window.chapter)
				settings.translation = window.translation
				settings.book = window.book
				settings.chapter = window.chapter
				settings.name_of_book = nameOfBook(settings.book, settings.translation)
				document.title += " " + getNameOfBookFromHistory(window.translation, window.book) + ' ' + window.chapter
				if window.verses
					verses = window.verses
					getBookmarks("/get-bookmarks/" + window.translation + '/' + window.book + '/' + window.chapter + '/', 'bookmarks')
				if window.verse
					document.title += ':' + window.verse
					findVerse(window.verse, window.endverse)
				document.title += ' ' + window.translation
		if getCookie('theme')
			settings.theme = getCookie('theme')
			settings.accent = getCookie('accent') || settings.accent
			changeTheme(settings.theme)
			if getCookie('sepia') == 'true'
				turnSepia!
		else
			if settings.theme == 'dark'
				changeTheme(settings.theme)
			else
				turnSepia!

		if getCookie('transitions') == 'false'
			settings.transitions = no
			html.dataset.transitions = "false"
		welcome = getCookie('welcome') || welcome
		settings.font.size = parseInt(getCookie('font')) || settings.font.size
		settings.font.family = getCookie('font-family') || settings.font.family
		settings.font.name = getCookie('font-name') || settings.font.name
		settings.font.weight = parseInt(getCookie('font-weight')) || settings.font.weight
		settings.font.line-height = parseFloat(getCookie('line-height')) || settings.font.line-height
		settings.font.max-width = parseInt(getCookie('max-width')) || settings.font.max-width
		settings.font.align = getCookie('align') || settings.font.align
		settings.verse_picker = (getCookie('verse_picker') == 'true') || settings.verse_picker
		settings.verse_break = (getCookie('verse_break') == 'true') || settings.verse_break
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
		getText(settings.translation, settings.book, settings.chapter)
		if getCookie('parallel_display') == 'true'
			toggleParallelMode("build")
		if window.navigator.onLine
			try
				let userdata = await loadData("/user-logged/")
				if userdata.username
					data.user.username = userdata.username
					data.user.is_password_usable = userdata.is_password_usable
					data.user.name = userdata.name || ''
					setCookie('username', data.user.username)
					setCookie('name', data.user.name)
					try
						history = JSON.parse(userdata.history)
					catch error
						history = JSON.parse(getCookie("history")) || []
					if history.length then window.localStorage.setItem("history", JSON.stringify(history))
				else
					window.localStorage.removeItem('username')
					window.localStorage.removeItem('name')
					data.user = {}
			catch err
				console.error('Error: ', err)
				data.showNotification('error')
		if window.message
			data.showNotification(window.message)
		if getCookie('chronorder') == 'true'
			toggleChronorder!
		highlights = JSON.parse(getCookie("highlights")) || []
		menuicons = !(getCookie('menuicons') == 'false')
		fixdrawers = getCookie('fixdrawers') == 'true'
		compare_translations.push(settings.translation)
		compare_translations.push(settingsp.translation)
		if JSON.parse(getCookie("compare_translations")) then compare_translations = (JSON.parse(getCookie("compare_translations")).length ? JSON.parse(getCookie("compare_translations")) : no) || compare_translations
		search =
			search_div: no,
			search_input: '',
			search_result_header: '',
			search_result_translation: '',
			show_filters: no,
			counter: 50,
			filter: 0,
			loading: no,
			change_translation: no,
			bookid_of_results: [],
			translation: settings.translation
		let bookmarks-to-delete = JSON.parse(getCookie("bookmarks-to-delete"))
		if bookmarks-to-delete
			deleteBookmarks(bookmarks-to-delete)
			window.localStorage.removeItem("bookmarks-to-delete")


	# def routed params
	# 	state = window.history.state
	# 	onpopstate = yes
	# 	if params.path.length > 1
	# 		if state.parallel-translation && state.parallel-book && state.parallel-chapter
	# 			getParallelText(state.parallel-translation, state.parallel-book, state.parallel-chapter, state.parallel-verse)
	# 		getText(params.translation, parseInt(params.book), parseInt(params.chapter), parseInt(params.verse))

	# 		settingsp.display = state.parallel_display
	# 		window.localStorage.setItem('parallel_display', state.parallel_display)
	# 	clearSpace!


	def searchPagination e
		if e.target.scrollTop > e.target.scrollHeight - e.target.clientHeight - 512 && search.counter < search_verses.length
			search.counter += 20
			setTimeout(&, 500) do pageSearch()

	# I call items from localStorage cookies :P
	def getCookie c_name
		window.localStorage.getItem(c_name)

	def setCookie c_name, value
		window.localStorage.setItem(c_name, value)

	def switchTranslation translation, parallel
		if parallel
			if settingsp.translation != translation || !parallel_books.length
				parallel_books = BOOKS[translation]
		else
			if settings.translation != translation || !books.length
				books = BOOKS[translation]

	def saveToHistory translation, book, chapter, verse, parallel
		if getCookie("history")
			history = JSON.parse(getCookie("history")) || []
		if history.find(do |element| return element.chapter == chapter && element.book == book && element.translation == translation)
			history.splice(history.indexOf(history.find(do |element| return element.chapter == chapter && element.book == book && element.translation == translation)), 1)
		history.push({"translation": translation, "book": book, "chapter": chapter, "verse": verse, "parallel": parallel})
		window.localStorage.setItem("history", JSON.stringify(history))

		if data.user.username && window.navigator.onLine
			window.fetch("/save-history/", {
				method: "POST",
				cache: "no-cache",
				headers: {
					'X-CSRFToken': data.get_cookie('csrftoken'),
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
						history: JSON.stringify(history),
					})
			})
			.then(do |response| response.json())
			.then(do |data| undefined)
			.catch(do |e|
				console.log(e)
				data.showNotification('error'))

	def loadData url
		let res = await window.fetch(url)
		return res.json()

	def getBookmarks url, type
		this[type] = []
		try
			this[type] = await loadData(url)
		catch error
			if data.db_is_available
				if type == 'bookmarks'
					this[type] = await data.getChapterBookmarksFromStorage(verses.map(do |verse| return verse.pk))
				else
					this[type] = await data.getChapterBookmarksFromStorage(parallel_verses.map(do |verse| return verse.pk))
		imba.commit()

	def getText translation, book, chapter, verse
		let changeParallel = yes
		const does_the_chapter_exist_in_this_translation = theChapterExistInThisTranslation(translation, book, chapter)
		unless does_the_chapter_exist_in_this_translation
			book = settings.book
			chapter = settings.chapter
			changeParallel = no

		if !(translation == settings.translation && book == settings.book && chapter == settings.chapter) || !verses.length
			loading = yes
			switchTranslation translation
			if !window.on_pops_tate && (verses.length || !window.navigator.onLine)
				window.history.pushState({
						translation: translation,
						book: book,
						chapter: chapter,
						verse: verse,
						parallel: no,
						parallel_display: settingsp.display
						parallel-translation: settingsp.translation,
						parallel-book: settingsp.book,
						parallel-chapter: settingsp.chapter,
						parallel-verse: 0,
					},
					'',
					window.location.origin + '/' + translation + '/' + book + '/' + chapter + '/'
				)
			clearSpace()
			document.title = "Bolls Bible " + " " + nameOfBook(book, translation) + ' ' + chapter + ' ' + translations.find(do |element| element.short_name == translation).full_name
			if chronorder
				chronorder = !chronorder
				toggleChronorder!
			settings.book = book
			settings.chapter = chapter
			settings.translation = translation
			setCookie('book', book)
			setCookie('chapter', chapter)
			setCookie('translation', translation)
			settings.name_of_book = nameOfBook(settings.book, settings.translation)
			settings.filtered_books = filteredBooks('books')
			saveToHistory(translation, book, chapter, verse, no)
			let url = "/get-text/" + translation + '/' + book + '/' + chapter + '/'
			try
				verses = []
				imba.commit()
				if data.db_is_available && data.downloaded_translations.indexOf(translation) != -1
					verses = await data.getChapterFromDB(translation, book, chapter, verse)
				else
					verses = await loadData(url)
				loading = no
				imba.commit()
				if verse > 0 then show_verse_picker = no else show_verse_picker = yes

			catch error
				loading = no
				imba.commit()
				console.error('Error: ', error)
				data.showNotification('error')
			if settings.parallel_synch && settingsp.display && changeParallel
				getParallelText settingsp.translation, book, chapter, verse, yes
			if data.user.username then getBookmarks("/get-bookmarks/" + translation + '/' + book + '/' + chapter + '/', 'bookmarks')
		if verse
			findVerse(verse)
		clearSpace!
		window.on_pops_tate = no
		setTimeout(&, 100) do window.scroll(0,0)


	def getParallelText translation, book, chapter, verse, caller
		let changeParallel = yes
		const does_the_chapter_exist_in_this_translation = theChapterExistInThisTranslation(translation, book, chapter)
		unless does_the_chapter_exist_in_this_translation
			book = settingsp.book
			chapter = settingsp.chapter
			changeParallel = no

		if !(translation == settingsp.translation && book == settingsp.book && chapter == settingsp.chapter) || !parallel_verses.length || !settingsp.display
			# if !window.on_pops_tate && verses
			# 	window.history.pushState({
			# 			translation: settings.translation,
			# 			book: settings.book,
			# 			chapter: settings.chapter,
			# 			verse: settings.verse,
			# 			parallel: yes,
			# 			parallel_display: settingsp.display
			# 			parallel-translation: translation,
			# 			parallel-book: book,
			# 			parallel-chapter: chapter,
			# 			parallel-verse: verse,
			# 		},
			# 		0,
			# 		null
			# 	)
			# window.on_pops_tate = no
			if chronorder
				chronorder = !chronorder
				toggleChronorder!
			switchTranslation translation, yes
			settingsp.translation = translation
			settingsp.edited_version = translation
			settingsp.book = book
			settingsp.chapter = chapter
			settingsp.name_of_book = nameOfBook(settingsp.book, settingsp.translation)
			settingsp.filtered_books = filteredBooks('parallel_books')
			clearSpace()
			let url = "/get-text/" + translation + '/' + book + '/' + chapter + '/'
			parallel_verses = []
			try
				if data.db_is_available && data.downloaded_translations.indexOf(translation) != -1
					parallel_verses = await data.getChapterFromDB(translation, book, chapter, verse)
				else
					parallel_verses = await loadData(url)
				if !window.on_pops_tate && verses && !verse && settingsp.display
					show_parallel_verse_picker = true
				imba.commit()
			catch error
				console.error('Error: ', error)
				data.showNotification('error')
			if settings.parallel_synch && settingsp.display && changeParallel && not caller
				getText settings.translation, book, chapter, verse
			if data.user.username
				getBookmarks("/get-bookmarks/" + translation + '/' + book + '/' + chapter + '/', 'parallel_bookmarks')
			imba.commit()
			setCookie('parallel_display', settingsp.display)
			saveToHistory translation, book, chapter, 0, yes
			setCookie('parallel_translation', translation)
			setCookie('parallel_book', book)
			setCookie('parallel_chapter', chapter)
			if verse
				findVerse("p{verse}")

	def theChapterExistInThisTranslation translation, book, chapter
		const theBook = BOOKS[translation].find(do |element| return element.bookid == book)
		if theBook
			if theBook.chapters >= chapter
				return yes
		return no

	def findVerse id, endverse, highlight = yes
		if id == -1 && verses.length > 0
			id = Math.round(Math.random() * (verses.length - 1) + 1)

		setTimeout(&,250) do
			const verse = document.getElementById(id)
			if verse
				if settingsp.display
					verse.parentNode.parentNode.scroll({left:0, top: verse.offsetTop - (window.innerHeight * 0.05), behavior: 'smooth'})
				else
					scrollTo(0, verse.offsetTop - (window.innerHeight * 0.05))
				if highlight then highlightLinkedVerses(id, endverse)
			else findVerse(id, endverse, highlight)

	def highlightLinkedVerses verse, endverse
		setTimeout(&, 250) do
			const versenode = document.getElementById(verse)
			if versenode
				if endverse
					let nodes = []
					for id in [verse..endverse]
						if id <= verses.length
							nodes.push document.getElementById(id).nextSibling
					let node = document.getElementById(verse).nextSibling
					if window.getSelection
						const selection = window.getSelection()
						selection.removeAllRanges()
						for node in nodes
							const range = document.createRange()
							range.selectNodeContents(node)
							selection.addRange(range)
					else
						console.warn("Could not select text in node: Unsupported browser.")
				else
					let node = versenode.nextSibling
					if window.getSelection
						const window_selection = window.getSelection()
						const selection_range = document.createRange()
						selection_range.selectNodeContents(node)
						window_selection.removeAllRanges()
						window_selection.addRange(selection_range)
					else
						console.warn("Could not select text in node: Unsupported browser.")
			else
				highlightLinkedVerses verse, endverse


	def clearSpace
		# If user write a note then instead of clearing everything just hide the note panel.
		if what_to_show_in_pop_up_block == "show_note"
			what_to_show_in_pop_up_block = ''
			return 0

		# Clean all the variables in order to free space around the text
		bible_menu_left = -300
		settings_menu_left = -300
		search.search_div = no
		onzone = no
		inzone = no
		show_history = no
		search.filter = no
		search.show_filters = no
		search.counter = 50
		choosen = []
		choosenid = []
		addcollection = no
		store.show_color_picker = no
		show_collections = no
		choosen_parallel = no
		show_fonts = no
		show_language_of = ''
		show_translations_for_comparison = no
		show_parallel_verse_picker = no
		show_verse_picker = no
		show_share_box = no
		choosen_categories = []

		# If the user is watching his profile then turn back from profile to the reader
		let profile = document.getElementsByClassName("Profile")
		if profile[0]
			profile[0]._tag.orphanize()
			window.history.back()

		# unless the user is typing something focus the reader in order to enable arrow navigation on the text
		unless page_search.d
			focus()
		if page_search.d || what_to_show_in_pop_up_block
			page_search.d = no
			page_search.matches = []
			page_search.rects = []
		window.getSelection().removeAllRanges()
		what_to_show_in_pop_up_block = ''
		imba.commit()


	def toggleChronorder
		if chronorder
			parallel_books.sort(do |book, koob| return book.bookid - koob.bookid)
			books.sort(do |book, koob| return book.bookid - koob.bookid)
		else
			parallel_books.sort(do |book, koob| return book.chronorder - koob.chronorder)
			books.sort(do |book, koob| return book.chronorder - koob.chronorder)

		settingsp.filtered_books = filteredBooks('parallel_books')
		settings.filtered_books = filteredBooks('books')

		chronorder = !chronorder
		setCookie('chronorder', chronorder.toString())

	def nameOfBook bookid, translation
		for book in BOOKS[translation]
			if book.bookid == bookid
				return book.name


	def pageSearch event
		let selectionStart = 0
		if event
			selectionStart = event.target.selectionStart

		# Show pageSearch box
		unless what_to_show_in_pop_up_block
			clearSpace()
			page_search.d = yes

		def focusInput
			const input = document.getElementById('pagesearch')
			if input
				input.focus()
				input.setSelectionRange(selectionStart, selectionStart)
			else setTimeout(&,50) do focusInput()

		# Check if query is not an empty string
		unless page_search.query.length || what_to_show_in_pop_up_block
			page_search.matches = []
			page_search.rects = []
			focusInput()
			return 0

		if window.navigator.platform.charAt(0) == 'i' && inner_height > window.innerHeight
			iOS_keaboard_height = inner_height - window.innerHeight

		# if the query is not an emty string lets clean it up for regex
		let regex_compatible_query
		unless what_to_show_in_pop_up_block
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
			unless what_to_show_in_pop_up_block
				range.setStart(node.firstChild, lastIndex - page_search.query.length)	# Start at first character of query
			else
				range.setStart(node.firstChild, lastIndex - search.search_input.length)
			range.setEnd(node.firstChild, lastIndex)	# End at last character

			def getSearchSelectionTopOffset rect_top
				if parallel == 'ps'
					return rect_top + search_body.scrollTop - search_body.offsetTop - search_body.parentNode.offsetTop
				elif settingsp.display
					if window.innerWidth < 639 && parallel
						return rect_top + chapter_articles[parallel].parentElement.scrollTop - chapter_articles[parallel].parentElement.offsetTop + iOS_keaboard_height
					else
						return rect_top + chapter_articles[parallel].parentElement.scrollTop + iOS_keaboard_height
				else return rect_top + scrollTop + iOS_keaboard_height

			def getSearchSelectionLeftOffset rect_left
				if parallel == 'ps'
					return rect_left - search_body.offsetLeft - search_body.parentNode.offsetLeft
				elif settingsp.display
					if window.innerWidth > 639 && parallel
						return rect_left - chapter_articles[parallel].parentNode.offsetLeft - chapter_articles[parallel].offsetLeft
					else
						return rect_left - window.innerWidth * 0.02
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
						mathcid: node.previousSibling ? node.previousSibling.id : ''
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

		# Search process
		const regex1 = RegExp(regex_compatible_query, 'gi')
		let array1
		page_search.matches = []
		unless what_to_show_in_pop_up_block
			let parallel = 0
			for chapter in chapter_articles
				for child in chapter.children
					while ((array1 = regex1.exec(child.textContent)) !== null)
						# Save the index of found text to page_search.matches
						# for further navigation
						page_search.matches.push({
							id: child.previousSibling.id,
							rects: getSelectionHighlightRect(child, regex1.lastIndex, parallel)
						})

				parallel++
		else
			for i in [1 ... search_body.children.length - 1]
				let text = search_body.children[i]
				if text.className == 'more_results'
					break

				if text.firstChild
					while ((array1 = regex1.exec(text.firstChild.textContent)) !== null)
						page_search.matches.push({
							rects: highlightText(text.firstChild, regex1.lastIndex, 'another_occurences', 'ps')
						})

		# Gather all rects to one array
		page_search.rects = []
		let nskrjvnslif = []
		for match in page_search.matches
			nskrjvnslif = nskrjvnslif.concat match.rects
		page_search.rects = nskrjvnslif

		# After all scroll to results
		unless what_to_show_in_pop_up_block
			if page_search.current_occurence > page_search.matches.length - 1
				page_search.current_occurence = 0
				if page_search.matches.length
					pageSearch()
			if page_search.matches[page_search.current_occurence]
				findVerse(page_search.matches[page_search.current_occurence].id, no, no)
			focusInput()
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
		if page_search.matches[page_search.current_occurence] then findVerse(page_search.matches[page_search.current_occurence].id, no, no)
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
		if what_to_show_in_pop_up_block == "show_help"
			clearSpace()
		else
			clearSpace()
			popUp 'show_help'

	def turnSupport
		if what_to_show_in_pop_up_block == "show_support"
			clearSpace()
		else
			clearSpace()
			popUp 'show_support'

	def toggleParallelMode parallel
		console
		if !parallel
			settingsp.display = no
			clearSpace()
		else
			if settings.parallel_synch
				getParallelText(settingsp.translation, settings.book, settings.chapter)
			else
				getParallelText(settingsp.translation, settingsp.book, settingsp.chapter)
			settingsp.display = yes
		setCookie('parallel_display', settingsp.display)

	def changeEditedParallel translation
		settingsp.edited_version = translation
		if search.change_translation
			getSearchText()
			search.change_translation = no
		show_list_of_translations = no

	def changeTranslation translation
		if settingsp.edited_version == settingsp.translation && settingsp.display
			switchTranslation translation, yes
			if parallel_books.find(do |element| return element.bookid == settingsp.book)
				getParallelText(translation, settingsp.book, settingsp.chapter)
			else
				getParallelText(translation, parallel_books[0].bookid, 1)
				settingsp.book = parallel_books[0].bookid
				settingsp.chapter = 1
			settingsp.translation = translation
			setCookie('translation', translation)
		else
			switchTranslation translation, no
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
		focusElement "generalsearch"


	def getSearchText e
		# Clear the searched text to preserver the request for breaking
		let query = search.search_input.replace(/\//g, '')
		query = query.replace(/\\/g, '')
		query = query.trim!

		# If the query is long enough and it is different from the previous query -- do the search again.
		if query.length > 1 && (search.search_result_header != query || !search.search_div)
			clearSpace!
			document.getElementById("generalsearch").blur!
			popUp 'search'
			search.search_result_header = ''
			loading = yes

			let url
			if settingsp.edited_version == settingsp.translation && settingsp.display
				search.translation = settingsp.edited_version
				url = '/search/' + settingsp.edited_version + '/' + query + '/'
				search.search_result_translation = settingsp.edited_version
			else
				search.translation = settings.translation
				url = '/search/' + settings.translation + '/' + query + '/'
				search.search_result_translation = settings.translation

			search_verses = {}
			try
				search_verses = await loadData(url)
				search.bookid_of_results = []
				for verse in search_verses
					if !search.bookid_of_results.find(do |element| return element == verse.book)
						search.bookid_of_results.push verse.book
				closeSearch!
				# popUp 'search'
				highlightSearchResults!
				imba.commit!
			catch error
				console.error error
				if data.db_is_available && data.downloaded_translations.indexOf(search.search_result_translation) != -1
					search_verses = await data.getSearchedTextFromStorage(search)
					search.bookid_of_results = []
					for verse in search_verses
						if !search.bookid_of_results.find(do |element| return element == verse.book)
							search.bookid_of_results.push verse.book
					closeSearch!
					# popUp 'search'
					highlightSearchResults!
					imba.commit!

	def highlightSearchResults
		page_search.matches = []
		page_search.rects = []
		unless search_verses.length then return
		if document.getElementById('search_body')
			if document.getElementById('search_body').children[0]
				if Array.from(document.getElementById('search_body').children).find(do |element| return element.className.indexOf('total_msg') > -1)
					setTimeout(&, 1000) do
						pageSearch()
					return
		setTimeout(&, 16) do highlightSearchResults()

	def moreSearchResults
		search.counter += 50
		pageSearch()

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

	def addFilter book
		page_search.matches = []
		page_search.rects = []
		search.filter = book
		search.show_filters = no
		search.counter = 50
		setTimeout(&, 16) do highlightSearchResults()

	def dropFilter
		search.filter = ''
		search.show_filters = no
		search.counter = 50
		setTimeout(&, 16) do highlightSearchResults()

	def getFilteredASearchVerses
		if search.filter
			return search_verses.filter(do |verse| verse.book == search.filter)
		else
			return search_verses



	def changeTheme theme
		html.dataset.pukaka = 'yes'

		settings.sepia = no
		settings.theme = theme
		html.dataset.theme = settings.accent + settings.theme
		html.dataset.light = settings.theme
		html.dataset.sepia = no

		setCookie('theme', theme)
		setCookie('sepia', settings.sepia)

		setTimeout(&, 75) do
			imba.commit!.then do html.dataset.pukaka = 'no'

	def turnSepia
		html.dataset.pukaka = 'yes'

		settings.sepia = yes
		settings.theme = 'light'

		html.dataset.theme = settings.accent + settings.theme
		html.dataset.light = settings.theme
		html.dataset.sepia = 'yes'

		setCookie('sepia', settings.sepia)

		setTimeout(&, 75) do
			imba.commit!.then do html.dataset.pukaka = 'no'

	def changeAccent accent
		settings.accent = accent
		html.dataset.theme = settings.accent + settings.theme
		setCookie('accent', accent)
		show_accents = no

	def getRandomColor
		return 'rgb(' + Math.round(Math.random()*255) + ',' + Math.round(Math.random()*255) + ',' + Math.round(Math.random()*255) + ')'

	def decreaseFontSize
		if settings.font.size > 16
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

	def nextChapter parallel
		if parallel == 'true'
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

	def prevChapter parallel
		if parallel == 'true'
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
		if not MOBILE_PLATFORM and not fixdrawers
			if e.x < 32
				bible_menu_left = 0
			elif e.x > window.innerWidth - 32
				settings_menu_left = 0
			elif 300 < e.x < window.innerWidth - 300
				bible_menu_left = -300
				settings_menu_left = -300

		if e.y < 32 && not MOBILE_PLATFORM
			max_header_font = 1.2
		else
			max_header_font = 0

	def getHighlight verse, bookmarks
		if choosenid.length && choosenid.find(do |element| return element == verse)
			return 'repeating-linear-gradient(90deg, rgba(0,0,0,0), rgba(0,0,0,0) 4px, ' + store.highlight_color + ' 4px, ' + store.highlight_color + ' 8px)'
		else
			let highlight = self[bookmarks].find(do |element| return element.verse == verse)
			if highlight
				return  "linear-gradient({highlight.color} 0px, {highlight.color} 100%)"
			else
				return ''

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
		unless document.getSelection().isCollapsed
			return
		if !settings_menu_left || !bible_menu_left
			return clearSpace()
		store.highlight_color = getRandomColor()
		if document.getSelection().isCollapsed
			# # If the verse is in area under bottom section
			# scroll to it, to see the full verse
			if !settingsp.display
				const verse = document.getElementById(id)
				const top_offset_of_verse = verse.nextSibling.offsetHeight + verse.offsetTop + 200 - scrollTop
				if top_offset_of_verse > window.innerHeight
					scrollTo(0, scrollTop - (window.innerHeight - top_offset_of_verse))
			else
				let verse
				if parallel == 'first'
					verse = document.getElementById(id)
				else
					verse = document.getElementById("p{id}")
				const top_offset = verse.nextSibling.offsetHeight + verse.offsetTop + 200 - verse.parentNode.parentNode.scrollTop
				if top_offset > verse.parentNode.parentNode.clientHeight
					verse.parentNode.parentNode.scroll(0, verse.parentNode.parentNode.scrollTop - (verse.parentNode.parentNode.clientHeight - top_offset))

			# # Handle the first click
			# initial setup of "Choosing" verses
			if !choosen_parallel
				choosen_parallel = parallel
				choosenid.push(pk)
				choosen.push(id)
				pushCollectionIfExist(pk)
				window.history.pushState({
						translation: settings.translation,
						book: settings.book,
						chapter: settings.chapter,
						verse: id,
						parallel: parallel != 'first',
						parallel_display: settingsp.display
						parallel-translation: settingsp.translation,
						parallel-book: settingsp.book,
						parallel-chapter: settingsp.chapter,
						parallel-verse: id,
					}
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

	def sendBookmarksToDjango
		if store.note == '<br>'
			store.note == ''
		if store.highlight_color.length >= 16
			if highlights.find(do |element| return element == store.highlight_color)
				highlights.splice(highlights.indexOf(highlights.find(do |element| return element == store.highlight_color)), 1)
			highlights.push(store.highlight_color)
			window.localStorage.setItem("highlights", JSON.stringify(highlights))
		let collections = ''
		for category, key in choosen_categories
			collections += category
			if key + 1 < choosen_categories.length
				collections += " | "
		unless data.user.username
			window.location.pathname = "/signup/"
			return
		if window.navigator.onLine
			window.fetch("/save-bookmarks/", {
				method: "POST",
				cache: "no-cache",
				headers: {
					'X-CSRFToken': data.get_cookie('csrftoken'),
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					verses: JSON.stringify(choosenid),
					color: store.highlight_color,
					date: Date.now(),
					collections: collections
					note: store.note
				}),
			})
			.then(do |response| response.json())
			.then(do |resdata| data.showNotification('saved'))
			.catch(do |e|
				console.log(e)
				data.showNotification('error')
				if data.db_is_available
					data.saveBookmarksToStorageUntillOnline({
						verses: choosenid,
						color: store.highlight_color,
						date: Date.now(),
						collections: choosen_categories
						note: store.note
					}))
		elif data.db_is_available
			data.saveBookmarksToStorageUntillOnline({
				verses: choosenid,
				color: store.highlight_color,
				date: Date.now(),
				collections: choosen_categories
				note: store.note
			})
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
					}
				)
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
		clearSpace()
		clearSpace()

	def deleteColor color_to_delete
		highlights.splice(highlights.indexOf(color_to_delete), 1)
		window.localStorage.setItem("highlights", JSON.stringify(highlights))

	def deleteBookmarks pks
		let should_to_delete = no
		let indexes_of_bookmarks = parallel_bookmarks.map(do |x| x.verse)
		indexes_of_bookmarks = indexes_of_bookmarks.concat(bookmarks.map(do |x| x.verse))
		for pk in pks
			if indexes_of_bookmarks.indexOf(pk) != -1
				should_to_delete = yes
				break
		if data.user.username && should_to_delete
			data.requestDeleteBookmark(pks)
			if choosen_parallel == 'second'
				for verse in choosenid
					if parallel_bookmarks.find(do |bookmark| return bookmark.verse == verse)
						parallel_bookmarks.splice(parallel_bookmarks.indexOf(parallel_bookmarks.find(do |bookmark| return bookmark.verse == verse)), 1)
			else
				for verse in choosenid
					if bookmarks.find(do |bookmark| return bookmark.verse == verse)
						bookmarks.splice(bookmarks.indexOf(bookmarks.find(do |bookmark| return bookmark.verse == verse)), 1)
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
		data.copyToClipboard(getShareObj())
		clearSpace()

	def byteCount s
		window.encodeURI(s).split(/%..|./).length - 1

	def canShareViaTelegram
		const copyobj = getShareObj()
		return byteCount("https://t.me/share/url?url={window.encodeURIComponent("https://bolls.life" + '/'+ copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + data.versePart(copyobj.verse) + '/')}&text={window.encodeURIComponent('«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title + ' ' + copyobj.translation)}") < 4096

	def shareTelegram
		const copyobj = getShareObj()
		const text = '«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title + ' ' + copyobj.translation
		const url = "https://bolls.life" + '/'+ copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + data.versePart(copyobj.verse) + '/'
		const link = "https://t.me/share/url?url={window.encodeURIComponent(url)}&text={window.encodeURIComponent(text)}"
		if byteCount(link) < 4096
			window.open(link, '_blank')
		clearSpace()

	def sharedText
		const copyobj = getShareObj()
		const text = '«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title + ' ' + copyobj.translation + "https://bolls.life" + '/'+ copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + data.versePart(copyobj.verse) + '/'
		return text

	def canMakeTweet
		return sharedText().length < 281

	def makeTweet
		window.open("https://twitter.com/intent/tweet?text={window.encodeURIComponent(sharedText())}", '_blank')
		clearSpace()

	def shareViaFB
		const copyobj = getShareObj()
		window.open("https://www.facebook.com/sharer.php?u=https://bolls.life/" + copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + data.versePart(copyobj.verse) + '/', '_blank')
		clearSpace()

	def shareViaWhatsApp
		window.open("https://api.whatsapp.com/send?text={window.encodeURIComponent(sharedText())}", '_blank')
		clearSpace()

	def shareViaVK
		const copyobj = getShareObj()
		const text = '«' + copyobj.text.join(' ').trim().replace(/<[^>]*>/gi, '') + '»\n\n' + copyobj.title + ' ' + copyobj.translation
		const url = "https://bolls.life" + '/'+ copyobj.translation + '/' + copyobj.book + '/' + copyobj.chapter + '/' + data.versePart(copyobj.verse) + '/'
		window.open("http://vk.com/share.php?url={window.encodeURIComponent(url)}&title={window.encodeURIComponent(text)}", '_blank')
		clearSpace()

	def shareViaViber
		window.open("viber://forward?text={window.encodeURIComponent(sharedText())}", '_blank')
		clearSpace()

	def getNameOfBookFromHistory translation, bookid
		let books = []
		books = BOOKS[translation]
		for book in books
			if book.bookid == bookid
				return book.name

	def turnHistory
		show_history = !show_history
		settings_menu_left = -300

	def clearHistory
		turnHistory()
		history = []
		window.localStorage.setItem("history", "[]")
		if data.user.username
			window.fetch("/save-history/", {
				method: "POST",
				cache: "no-cache",
				headers: {
					'X-CSRFToken': data.get_cookie('csrftoken'),
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
						history: "[]",
					})
			})
			.then(do |response| response.json())
			.then(do |data| undefined)
			.catch(do |error|
				console.error(error)
				data.showNotification('error'))

	def turnCollections
		if addcollection
			addcollection = no
		else
			show_collections = !show_collections
			store.show_color_picker = no
			if show_collections && data.user.username
				let url = "/get-categories/"
				if window.navigator.onLine
					let data = await loadData(url)
					categories = []
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
		addcollection = yes
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
		if settingsp.display
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
			settingsp.display = yes
			setCookie('parallel_display', settingsp.display)
		else
			getText(h.translation, h.book, h.chapter, h.verse)

	def toggleTransitions
		settings.transitions = !settings.transitions
		setCookie('transitions', settings.transitions)
		html.dataset.transitions = settings.transitions

	def toggleVersePicker
		settings.verse_picker = !settings.verse_picker
		setCookie('verse_picker', settings.verse_picker)

	def toggleParallelSynch
		settings.parallel_synch = !settings.parallel_synch
		setCookie('parallel_synch', settings.parallel_synch)

	def toggleVerseBreak
		settings.verse_break = !settings.verse_break
		setCookie('verse_break', settings.verse_break)

	def translationFullName tr
		translations.find(do |translation| return translation.short_name == tr).full_name

	def popUp what
		what_to_show_in_pop_up_block = what
		window.history.pushState(no, what)
		router.go("/{settings.translation}/{settings.book}/{settings.chapter}/0/")

	def makeNote
		if what_to_show_in_pop_up_block
			what_to_show_in_pop_up_block = ''
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
		if what_to_show_in_pop_up_block == "show_compare"
			clearSpace()
			popUp 'show_compare'
		else clearSpace()
		loading = yes
		if !window.navigator.onLine && data.db_is_available && data.downloaded_translations.indexOf(settings.translation) != -1
			comparison_parallel = await data.getParallelVersesFromStorage(compare_translations, choosen_for_comparison, compare_parallel_of_book, compare_parallel_of_chapter)
			loading = no
			popUp 'show_compare'
			imba.commit()
		else
			comparison_parallel = []
			window.fetch("/get-paralel-verses/", {
				method: "POST",
				cache: "no-cache",
				headers: {
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					translations: JSON.stringify(compare_translations),
					verses: JSON.stringify(choosen_for_comparison),
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
				data.showNotification('error'))

	def addTranslation translation
		if compare_translations.indexOf(translation.short_name) < 0
			compare_translations.unshift(translation.short_name)
			window.fetch("/get-paralel-verses/", {
				method: "POST",
				cache: "no-cache",
				headers: {
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					translations: JSON.stringify([translation.short_name]),
					verses: JSON.stringify(choosen_for_comparison),
					book: compare_parallel_of_book,
					chapter: compare_parallel_of_chapter,
				}),
			})
			.then(do |response| response.json())
			.then(do |resdata|
				comparison_parallel = resdata.concat(comparison_parallel)
				loading = no
				imba.commit()
			)
			.catch(do |error|
				console.error error
				loading = no
				data.showNotification('error'))
		else
			compare_translations.splice(compare_translations.indexOf(translation.short_name), 1)
			document.getElementById("compare_{translation.short_name}").style.animation = "the-element-left-us 300ms ease forwards"
			setTimeout(&, 300) do
				document.getElementById("compare_{translation.short_name}").style.animation = ""
				comparison_parallel.splice(comparison_parallel.indexOf(comparison_parallel.find(do |prlll| return prlll[0].translation == translation.short_name)), 1)
				imba.commit()
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
		if increase && settings.font.max-width < 120 && (settings.font.max-width - 15) * settings.font.size < window.innerWidth
			settings.font.max-width += 15
		elif settings.font.max-width > 15
			settings.font.max-width -= 15
		setCookie('max-width', settings.font.max-width)

	def toggleDownloads
		clearSpace()
		popUp 'show_downloads'

	def changeFontWeight value
		if settings.font.weight + value < 1000 && settings.font.weight + value > 0
			settings.font.weight += value
			setCookie('font-weight', settings.font.weight)

	def boxShadow grade
		settings.theme == 'light' ? "box-shadow: 0 0 {(grade + 300) / 5}px rgba(0, 0, 0, 0.067);" : ''



	def cleanString s
		if s
			return s.toLowerCase().replace(/[^0-9a-zа-яіїєёґ\s]+/g, "")
		else return ''

	# Compute a search relevance score for an item.
	def scoreSearch item
		let thename = cleanString(item)
		let search_query = cleanString(store.book_search)
		let score = 0
		let p = 0 # Position within the `item`
		# Look through each character of the search string, stopping at the end(s)...

		for i in [0 ... search_query.length]
			# Figure out if the current letter is found in the rest of the `item`.
			const index = thename.indexOf(search_query[i], p)
			# If not, stop here.
			if index < 0
				break
			#  If it is, add to the score...
			score++
			#  ... and skip the position within `item` forward.
			p = index

		return score


	def filteredBooks books
		let result = []

		if store.book_search.length
			let filtered_books = []

			for book in self[books]
				const score = scoreSearch(book.name)
				if score > 0
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
		data.shareCopying(copyobj)

	def copyToClipboardFromSerach obj
		data.shareCopying({
			text: [obj.text],
			translation: obj.translation,
			book: obj.book,
			chapter: obj.chapter,
			verse: [obj.verse],
			title: getHighlightedRow(obj.translation, obj.book, obj.chapter, [obj.verse])
		})

	def onsavechangestocomparetranslations arr
		compare_translations = arr
		window.localStorage.setItem("compare_translations", JSON.stringify(arr))

	def currentLanguage
		switch data.language
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
			no,
			"Welcome 🤗",
			window.location.origin + '/' + settings.translation + '/' + settings.book + '/' + settings.chapter + '/'
		)
		toggleBibleMenu()

	def changeHeadersSizeOnScroll e
		if e.target.id == 'firstparallel'
			let testsize = 2 - ((e.target.scrollTop * 4) / window.innerHeight)
			if testsize * settings.font.size < 12
				chapter_headers.fontsize1 = 12 / settings.font.size
			elif e.target.scrollTop > 0
				chapter_headers.fontsize1 = testsize
			else
				chapter_headers.fontsize1 = 2
		else
			let testsize = 2 - ((e.target.scrollTop * 4) / window.innerHeight)
			if testsize * settings.font.size < 12
				chapter_headers.fontsize2 = 12 / settings.font.size
			elif e.target.scrollTop > 0
				chapter_headers.fontsize2 = testsize
			else
				chapter_headers.fontsize2 = 2

			const last_known_scroll_position = e.target.scrollTop
			setTimeout(&, 100) do
				if e.target.scrollTop < last_known_scroll_position || not e.target.scrollTop
					menu_icons_transform = 0
				elif e.target.scrollTop > last_known_scroll_position
					if window.innerWidth > 1024
						menu_icons_transform = -100
					else
						menu_icons_transform = 100
		imba.commit()

	def triggerNavigationIcons
		let testsize = 2 - ((scrollTop * 4) / window.innerHeight)
		if testsize * settings.font.size < 12
			chapter_headers.fontsize1 = 12 / settings.font.size
		elif scrollTop > 0
			chapter_headers.fontsize1 = testsize
		else
			chapter_headers.fontsize1 = 2

		const last_known_scroll_position = scrollTop
		setTimeout(&, 100) do
			if scrollTop < last_known_scroll_position || not scrollTop
				menu_icons_transform = 0
			elif scrollTop > last_known_scroll_position
				if window.innerWidth > 1024
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
		if settingsp.display && settingsp.edited_version == settingsp.translation
			settingsp.filtered_books = filteredBooks('parallel_books')
		else
			settings.filtered_books = filteredBooks('books')

	def goToVerse id
		if settings.parallel_synch
			if id.toString().charAt(0) == 'p'
				findVerse id, 0, no
				findVerse id.toString().slice(1, id.length), 0, no
			else
				findVerse ('p' + id), 0, no
				findVerse id, 0, no
		else
			findVerse id, 0, no
		hideVersePicker()

	def randomVerse
		const random_book = books[Math.round(Math.random() * books.length) - 1]
		const random_chapter = Math.round(Math.random() * (random_book.chapters - 1) + 1)
		getText settings.translation, random_book.bookid, random_chapter, -1




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
		elif document.getSelection().isCollapsed && Math.abs(touch.dy) < 36 && !search.search_div && !show_history && !choosenid.length
			if window.innerWidth > 600
				if touch.dx < -32
					settingsp.display && touch.x > window.innerWidth / 2 ? prevChapter("true") : prevChapter()
				elif touch.dx > 32
					settingsp.display && touch.x > window.innerWidth / 2 ? nextChapter("true") : nextChapter()
			else
				if touch.dx < -32
					settingsp.display && touch.y > window.innerHeight / 2 ? prevChapter("true") : prevChapter()
				elif touch.dx > 32
					settingsp.display && touch.y > window.innerHeight / 2 ? nextChapter("true") : nextChapter()

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
		data.deferredPrompt.prompt()

	def settingsIconTransform
		if fixdrawers && window.innerWidth > 1024
			return -(300 + settings_menu_left)
		else
			return 0

	def bibleIconTransform
		if fixdrawers && window.innerWidth > 1024
			return 300 + bible_menu_left
		else
			return 0


	css
		height: 100vh
		display: block
		ofy: auto
		pos: relative
		transition-property@force: none
		-webkit-overflow-scrolling@force: auto

	css .height_auto
		max-height: 76px

	def hideReader
		return window.location.pathname.indexOf('profile') > -1 || window.location.pathname.indexOf('downloads') > -1

	def render
		<self .display_none=hideReader! @scroll=triggerNavigationIcons @mousemove=mousemove .fixscroll=what_to_show_in_pop_up_block>
			<nav @touchstart=slidestart @touchend=closedrawersend @touchcancel=closedrawersend @touchmove=closingdrawer style="left: {bible_menu_left}px; {boxShadow(bible_menu_left)}{(onzone || inzone) ? 'transition:none;' : ''}">
				if settingsp.display
					<.choose_parallel>
						<p.translation_name title=translationFullName(settings.translation) .current_translation=(settingsp.edited_version == settings.translation) @click=changeEditedParallel(settings.translation)> settings.translation
						<p.translation_name title=translationFullName(settingsp.translation) .current_translation=(settingsp.edited_version == settingsp.translation) @click=changeEditedParallel(settingsp.translation)> settingsp.translation
				<header[d:flex jc:space-between cursor:pointer]>
					<svg.chronological_order @click=toggleChronorder .hide_chron_order=show_list_of_translations .chronological_order_in_use=chronorder viewBox="0 0 20 20" title=data.lang.chronological_order>
						<title> data.lang.chronological_order
						<path d="M10 20a10 10 0 1 1 0-20 10 10 0 0 1 0 20zm0-2a8 8 0 1 0 0-16 8 8 0 0 0 0 16zm-1-7.59V4h2v5.59l3.95 3.95-1.41 1.41L9 10.41z">
					if settingsp.edited_version == settingsp.translation && settingsp.display
						<p.translation_name title=data.lang.change_translation @click=(show_list_of_translations = !show_list_of_translations)> settingsp.edited_version
					else
						<p.translation_name title=data.lang.change_translation @click=(show_list_of_translations = !show_list_of_translations)> settings.translation
					if data.db_is_available
						<svg.download_translations @click=toggleDownloads .hide_chron_order=show_list_of_translations viewBox="0 0 212.646728515625 159.98291015625">
							<title> data.lang.download
							<g transform="matrix(1.5 0 0 1.5 0 128)">
								<path d=svg_paths.download>
				<.translations_list .show_translations_list=show_list_of_translations [pb: {show_list_of_translations ? '256px' : 0}]>
					for language in languages
						<p.book_in_list[justify-content:start] .pressed=(language.language == show_language_of) .selected=(language.translations.find(do |translation| currentTranslation(translation.short_name))) @click=showLanguageTranslations(language.language)>
							language.language
							<svg.arrow_next[margin-left:auto min-width:8px] width="16" height="10" viewBox="0 0 8 5">
								<title> data.lang.open
								<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
						<ul.list_of_chapters dir="auto" .show_list_of_chapters=(language.language == show_language_of)>
							for translation in language.translations
								<li.book_in_list .selected=currentTranslation(translation.short_name) [display: flex]>
									<span @click=changeTranslation(translation.short_name)> translation.full_name
									if translation.info then <a href=translation.info title=translation.info target="_blank" rel="noreferrer">
										<svg.translation_info viewBox="0 0 24 24">
											<title> translation.info
											<path d="M11 7h2v2h-2zm0 4h2v6h-2zm1-9C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z">
				<.books-container dir="auto" .lower=(settingsp.display) [pb: 256px]>
					if settingsp.display && settingsp.edited_version == settingsp.translation
						<>
							for book in settingsp.filtered_books
								<p.book_in_list dir="auto" .selected=(book.bookid == settingsp.book) @click=showChapters(book.bookid)> book.name
								<ul.list_of_chapters dir="auto" .show_list_of_chapters=(book.bookid == show_chapters_of)>
									for i in [0 ... book.chapters]
										<li.chapter_number .selected=(i + 1 == settingsp.chapter && book.bookid==settingsp.book) @click=getParallelText(settingsp.translation, book.bookid, i+1)> i+1
						if !settingsp.filtered_books.length
							<p.book_in_list [white-space: pre]> '(ಠ╭╮ಠ)  ¯\\_(ツ)_/¯  ノ( ゜-゜ノ)'
					else
						<>
							for book in settings.filtered_books
								<p.book_in_list dir="auto" .selected=(book.bookid == settings.book) @click=showChapters(book.bookid)> book.name
								<ul.list_of_chapters dir="auto" .show_list_of_chapters=(book.bookid == show_chapters_of)>
									for i in [0 ... book.chapters]
										<li.chapter_number .selected=(i + 1 == settings.chapter && book.bookid == settings.book) @click=getText(settings.translation, book.bookid, i+1) > i+1
						if !settings.filtered_books.length
							<p.book_in_list [white-space: pre]> '(ಠ╭╮ಠ)  ¯\\_(ツ)_/¯  ノ( ゜-゜ノ)'
				<input$bookssearch.search @keyup.filterBooks bind=store.book_search type="text" placeholder=data.lang.search aria-label=data.lang.search> data.lang.search
				<svg#close_book_search @click=(store.book_search = '', $bookssearch.focus(), filterBooks()) viewBox="0 0 20 20">
					<title> data.lang.delete
					<path[m: auto] d=svg_paths.close>


			<main.main @touchstart=slidestart @touchmove=openingdrawer @touchend=slideend @touchcancel=slideend .parallel_text=settingsp.display [font-family: {settings.font.family} font-size: {settings.font.size}px line-height:{settings.font.line-height} font-weight:{settings.font.weight} text-align: {settings.font.align}]>
				<section#firstparallel .parallel=settingsp.display @scroll=changeHeadersSizeOnScroll dir="auto" [margin: auto; max-width: {settings.font.max-width}em]>
					for rect in page_search.rects when rect.mathcid.charAt(0) != 'p' and what_to_show_in_pop_up_block == ''
						<.{rect.class} id=rect.matchid [top: {rect.top}px; left: {rect.left}px; width: {rect.width}px; height: {rect.height}px]>
					if verses.length
						<header[h: 0 mt:4em z-index: {what_to_show_in_pop_up_block ? 0 : 1}] @click=toggleBibleMenu()>
							<h1[lh:1 m: 0 ff: {settings.font.family} fw: {settings.font.weight + 200} fs: max({max_header_font}em, {chapter_headers.fontsize1}em) d@md:flex ai@md:center jc@md:space-between direction:ltr] title=translationFullName(settings.translation)>
								<a.arrow @click.prevent.stop.prevChapter() [d@lt-md:none max-height:max({max_header_font}em, {chapter_headers.fontsize1}em) max-width:max({max_header_font}em, {chapter_headers.fontsize1}em)] title=data.lang.prev href="{prevChapterLink()}">
									<svg.arrow_prev width="16" height="10" viewBox="0 0 8 5">
										<title> data.lang.prev
										<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
								settings.name_of_book, ' ', settings.chapter

								<a.arrow @click.prevent.stop.nextChapter() [d@lt-md:none max-height:max({max_header_font}em, {chapter_headers.fontsize1}em) max-width:max({max_header_font}em, {chapter_headers.fontsize1}em)] title=data.lang.next href="{nextChapterLink()}">
									<svg.arrow_next width="16" height="10" viewBox="0 0 8 5">
										<title> data.lang.next
										<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
						<p[mb:1em p: 0 8px o:0 lh:1 ff: {settings.font.family} fw: {settings.font.weight + 200} fs: {settings.font.size * 2}px]> settings.name_of_book, ' ', settings.chapter
						<article>
							for verse in verses
								if settings.verse_break
									<br>
								<span.verse id=verse.verse @click=goToVerse(verse.verse)> ' \t', verse.verse
								<span innerHTML=verse.text
										@click=addToChosen(verse.pk, verse.verse, 'first')
										[background-image: {getHighlight(verse.pk, 'bookmarks')}]
									>
						<.arrows>
							<a.arrow @click.prevent.prevChapter() title=data.lang.prev href="{prevChapterLink()}">
								<svg.arrow_prev width="16" height="10" viewBox="0 0 8 5">
									<title> data.lang.prev
									<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
							<a.arrow @click.prevent.nextChapter() title=data.lang.next href="{nextChapterLink()}">
								<svg.arrow_next width="16" height="10" viewBox="0 0 8 5">
									<title> data.lang.next
									<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
					elif !window.navigator.onLine && data.downloaded_translations.indexOf(settings.translation) == -1
						<p.in_offline>
							data.lang.this_translation_is_unavailable
							<br>
							<a.reload @click=(do window.location.reload(yes))> data.lang.reload
					elif not loading
						<p.in_offline> data.lang.unexisten_chapter
				<section#secondparallel.parallel @scroll=changeHeadersSizeOnScroll dir="auto" [margin: auto max-width: {settings.font.max-width}em display: {settingsp.display ? 'inline-block' : 'none'}]>
					for rect in page_search.rects when rect.mathcid.charAt(0) == 'p'
						<.{rect.class} [top: {rect.top}px; left: {rect.left}px; width: {rect.width}px; height: {rect.height}px]>
					if parallel_verses.length
						<header[h: 0 mt:4em z-index: {what_to_show_in_pop_up_block ? 0 : 1}] @click=toggleBibleMenu(yes)>
							<h1[lh:1 m: 0 ff: {settings.font.family} fw: {settings.font.weight + 200} fs: {chapter_headers.fontsize2}em] title=translationFullName(settingsp.translation)>
								settingsp.name_of_book, ' ', settingsp.chapter

						<p[mb:1em p: 0 8px o:0 lh:1 ff: {settings.font.family} fw: {settings.font.weight + 200} fs: {settings.font.size * 2}px]> settingsp.name_of_book, ' ', settingsp.chapter
						<article>
							for parallel_verse in parallel_verses
								if settings.verse_break
									<br>
								<span.verse id="p{parallel_verse.verse}" @click=goToVerse('p' + parallel_verse.verse)> ' \t', parallel_verse.verse
								<span innerHTML=parallel_verse.text
									@click=addToChosen(parallel_verse.pk, parallel_verse.verse, 'second')
									[background-image: {getHighlight(parallel_verse.pk, 'parallel_bookmarks')}]>
						<.arrows>
							<a.arrow @click=prevChapter("true")>
								<svg.arrow_prev width="16" height="10" viewBox="0 0 8 5">
									<title> data.lang.prev
									<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
							<a.arrow @click=nextChapter("true")>
								<svg.arrow_next width="16" height="10" viewBox="0 0 8 5">
									<title> data.lang.next
									<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
					elif !window.navigator.onLine && data.downloaded_translations.indexOf(settingsp.translation) == -1
						<p.in_offline> data.lang.this_translation_is_unavailable


			<aside @touchstart=slidestart @touchend=closedrawersend @touchcancel=closedrawersend @touchmove=closingdrawer style="right:{MOBILE_PLATFORM ? settings_menu_left : settings_menu_left ? settings_menu_left : settings_menu_left + 12}px;{boxShadow(settings_menu_left)}{(onzone || inzone) ? 'transition:none;' : ''}">
				<p.settings_header>
					if data.getUserName()
						<a.helpsvg route-to.exact='/profile/$'>
							<svg.helpsvg viewBox="0 0 70.000000 70.000000" preserveAspectRatio="xMidYMid meet">
								<title> data.getUserName()
								<g transform="translate(0.000000,70.000000) scale(0.100000,-0.100000)" stroke="none">
									<path d="M400 640 c-19 -7 -13 -8 22 -4 95 12 192 -38 234 -118 41 -78 12 -200 -65 -277 -26 -26 -41 -50 -41 -66 0 -21 -10 -30 -66 -55 -37 -16 -68 -30 -70 -30 -2 0 -4 21 -6 48 l-3 47 -40 3 c-43 3 -65 23 -65 56 0 12 -7 34 -15 50 -12 23 -13 32 -3 43 7 8 15 44 19 79 6 63 17 91 26 67 11 -32 63 -90 96 -107 31 -17 39 -18 61 -7 59 32 79 -30 24 -73 -18 -14 -28 -26 -22 -26 6 0 23 9 38 21 56 44 19 133 -40 94 -21 -14 -27 -14 -53 -1 -35 18 -73 62 -90 105 -8 17 -17 31 -21 31 -13 0 -30 -59 -30 -102 0 -21 -7 -53 -16 -70 -12 -23 -14 -36 -6 -48 5 -9 13 -35 17 -58 8 -49 34 -72 82 -72 33 0 33 0 33 -50 0 -34 4 -50 13 -50 6 0 44 17 82 38 54 29 71 43 74 62 1 14 18 42 37 62 122 136 105 316 -37 388 -44 23 -133 33 -169 20z">
									<path d="M320 606 c-19 -13 -46 -43 -60 -66 -107 -179 -149 -214 -229 -186 -23 8 -24 7 -19 -38 7 -57 47 -112 100 -136 24 -11 46 -30 57 -51 33 -62 117 -101 178 -83 24 7 19 9 -32 13 -69 7 -108 28 -130 71 -14 27 -14 31 0 36 8 3 15 12 15 19 0 19 -30 27 -37 10 -13 -35 -97 19 -124 79 -27 60 -25 64 25 59 41 -5 47 -2 90 37 25 23 63 74 85 113 38 70 75 113 116 135 11 6 15 12 10 12 -6 0 -26 -11 -45 -24z">

					data.lang.other
					<.current_accent .enlarge_current_accent=show_accents>
						<.visible_accent @click=(do show_accents = !show_accents)>
						<.accents .show_accents=show_accents>
							for accent in accents when accent.name != settings.accent
								<.accent @click=changeAccent(accent.name) [background-color: {settings.theme == 'dark' ? accent.light : accent.dark}]>
				<button.btnbox.cbtn [w:100% h:46px bg:transparent @hover:$btn-bg-hover d:flex ai:center font:inherit p:0 12px] @click=turnGeneralSearch>
					<svg.helpsvg[p:0 4px] viewBox="0 0 12 12" width="24px" height="24px">
						<title> data.lang.find_in_chapter
						<path d=svg_paths.search>
					data.lang.bible_search
				<.btnbox>
					<svg.cbtn[p:8px w:33.333%] @click=changeTheme('dark') enable-background="new 0 0 24 24" viewBox="0 0 24 24" >
						<title> data.lang.nighttheme
						<g>
							<path d="M11.1,12.08C8.77,7.57,10.6,3.6,11.63,2.01C6.27,2.2,1.98,6.59,1.98,12c0,0.14,0.02,0.28,0.02,0.42 C2.62,12.15,3.29,12,4,12c1.66,0,3.18,0.83,4.1,2.15C9.77,14.63,11,16.17,11,18c0,1.52-0.87,2.83-2.12,3.51 c0.98,0.32,2.03,0.5,3.11,0.5c3.5,0,6.58-1.8,8.37-4.52C18,17.72,13.38,16.52,11.1,12.08z">
						<path d="M7,16l-0.18,0C6.4,14.84,5.3,14,4,14c-1.66,0-3,1.34-3,3s1.34,3,3,3c0.62,0,2.49,0,3,0c1.1,0,2-0.9,2-2 C9,16.9,8.1,16,7,16z">
					<svg.cbtn[w:33.333%] @click=turnSepia viewBox="0 0 8 8">
						<title> 'sepia'
						<rect x=1 y=2 width=6 height=4 rx=1 fill='#DEBB68'>
					<svg.cbtn[w:33.333%] @click=changeTheme('light') [p: 8px] viewBox="0 0 20 20">
						<title> data.lang.lighttheme
						<path d="M10 14a4 4 0 1 1 0-8 4 4 0 0 1 0 8zM9 1a1 1 0 1 1 2 0v2a1 1 0 1 1-2 0V1zm6.65 1.94a1 1 0 1 1 1.41 1.41l-1.4 1.4a1 1 0 1 1-1.41-1.41l1.4-1.4zM18.99 9a1 1 0 1 1 0 2h-1.98a1 1 0 1 1 0-2h1.98zm-1.93 6.65a1 1 0 1 1-1.41 1.41l-1.4-1.4a1 1 0 1 1 1.41-1.41l1.4 1.4zM11 18.99a1 1 0 1 1-2 0v-1.98a1 1 0 1 1 2 0v1.98zm-6.65-1.93a1 1 0 1 1-1.41-1.41l1.4-1.4a1 1 0 1 1 1.41 1.41l-1.4 1.4zM1.01 11a1 1 0 1 1 0-2h1.98a1 1 0 1 1 0 2H1.01zm1.93-6.65a1 1 0 1 1 1.41-1.41l1.4 1.4a1 1 0 1 1-1.41 1.41l-1.4-1.4z">
				<.btnbox>
					<a[p: 12px fs: 20px].cbtn @click=decreaseFontSize title=data.lang.decrease_font_size> "B-"
					<a[p: 8px fs: 24px].cbtn @click=increaseFontSize title=data.lang.increase_font_size> "B+"
				<.btnbox>
					<a.cbtn [padding: 8px font-size: 24px font-weight: 100] @click=changeFontWeight(-100) title=data.lang.decrease_font_weight> "B"
					<a.cbtn [padding: 8px font-size: 24px font-weight: 900] @click=changeFontWeight(100) title=data.lang.increase_font_weight> "B"
				<.btnbox>
					<svg.cbtn @click.changeLineHeight(no) viewBox="0 0 38 14" fill="context-fill" [padding: 16px 0]>
						<title> data.lang.decrease_line_height
						<rect x="0" y="0" width="28" height="2">
						<rect x="0" y="6" width="38" height="2">
						<rect x="0" y="12" width="18" height="2">
					<svg.cbtn @click.changeLineHeight(yes) viewBox="0 0 38 24" fill="context-fill" [padding: 10px 0]>
						<title> data.lang.increase_line_height
						<rect x="0" y="0" width="28" height="2">
						<rect x="0" y="11" width="38" height="2">
						<rect x="0" y="22" width="18" height="2">
				if window.chrome
					<.btnbox>
						<svg.cbtn @click=changeAlign(yes) viewBox="0 0 20 20" [padding: 10px 0]>
							<title> data.lang.auto_align
							<path d="M1 1h18v2H1V1zm0 8h18v2H1V9zm0 8h18v2H1v-2zM1 5h12v2H1V5zm0 8h12v2H1v-2z">
						<svg.cbtn @click=changeAlign(no) viewBox="0 0 20 20" [padding: 10px 0]>
							<title> data.lang.align_justified
							<path d="M1 1h18v2H1V1zm0 8h18v2H1V9zm0 8h18v2H1v-2zM1 5h18v2H1V5zm0 8h18v2H1v-2z">
				if window.innerWidth > 639
					<.btnbox>
						<svg.cbtn @click=changeMaxWidth(no) width="42" height="16" viewBox="0 0 42 16" fill="context-fill" [padding: calc(42px - 28px) 0]>
							<title> data.lang.increase_max_width
							<path d="M14.5,7 L8.75,1.25 L10,-1.91791433e-15 L18,8 L17.375,8.625 L10,16 L8.75,14.75 L14.5,9 L1.13686838e-13,9 L1.13686838e-13,7 L14.5,7 Z">
							<path d="M38.5,7 L32.75,1.25 L34,6.58831647e-15 L42,8 L41.375,8.625 L34,16 L32.75,14.75 L38.5,9 L24,9 L24,7 L38.5,7 Z" transform="translate(33.000000, 8.000000) scale(-1, 1) translate(-33.000000, -8.000000)">
						<svg.cbtn @click=changeMaxWidth(yes) width="44" height="16" viewBox="0 0 44 16" fill="context-fill" [padding: calc(42px - 28px) 0]>
							<title> data.lang.decrease_max_width
							<path d="M14.5,7 L8.75,1.25 L10,-1.91791433e-15 L18,8 L17.375,8.625 L10,16 L8.75,14.75 L14.5,9 L1.13686838e-13,9 L1.13686838e-13,7 L14.5,7 Z" transform="translate(9.000000, 8.000000) scale(-1, 1) translate(-9.000000, -8.000000)">
							<path d="M40.5,7 L34.75,1.25 L36,-5.17110888e-16 L44,8 L43.375,8.625 L36,16 L34.75,14.75 L40.5,9 L26,9 L26,7 L40.5,7 Z">
				<.btnbox>
					<svg.cbtn @click=toggleParallelMode(no) [padding: 8px] viewBox="0, 0, 400,338.0281690140845" height="338.0281690140845" width="400">
						<title> data.lang.usual_reading
						<path[stroke-width:1.81818] fill-rule="evenodd" stroke="none" d="m 35.947276,15.059555 c -7.969093,0.761817 -16.59819,3.661819 -16.59819,5.578181 0,0.283637 -0.409086,0.516365 -0.909082,0.516365 -0.498182,0 -1.332726,0.650909 -1.85455,1.445454 -0.52,0.794546 -2.256363,2.158182 -3.856362,3.030909 -4.2854562,2.334545 -5.9854559,4.496363 -7.5981831,9.663636 -0.7927271,2.536365 -1.6272721,4.750909 -1.8581814,4.921819 -0.2290909,0.170909 -1.0600003,2.521818 -1.845455,5.225455 L 0,50.355918 v 118.650912 118.6509 l 1.4272725,4.91455 c 0.7854547,2.70182 1.6163641,5.05454 1.845455,5.22545 0.2309093,0.17092 1.0654543,2.38546 1.8581814,4.92182 1.6127272,5.16727 3.3127269,7.32727 7.5981831,9.66364 1.599999,0.87273 3.336362,2.23636 3.856362,3.03091 0.521824,0.79455 1.356368,1.44363 1.85455,1.44363 0.499996,0 0.909082,0.23273 0.909082,0.51818 0,0.97456 6.109095,3.84182 10.278187,4.82546 7.178184,1.69455 80.296367,1.94181 87.632717,0.29818 6.04365,-1.35454 8.16365,-2.48181 9.22729,-4.90545 0.40182,-0.91091 0.87272,-1.79637 1.04909,-1.96545 5.33636,-5.1291 5.29091,-24.29273 -0.0654,-26.33274 -0.29454,-0.11268 -0.53818,-0.5109 -0.53818,-0.88363 0,-1.30001 -2.77637,-4.72909 -4.30182,-5.31454 -5.89454,-2.25456 -9.98909,-2.51091 -40.25999,-2.51091 -36.860011,0 -34.947285,0.51454 -36.567285,-9.83638 -0.858181,-5.48544 -0.858181,-198.0018 0,-203.48908 1.62,-10.350906 -0.292726,-9.83636 36.567285,-9.83636 30.2709,0 34.36545,-0.254546 40.25999,-2.51091 1.52545,-0.583635 4.30182,-4.012727 4.30182,-5.312726 0,-0.374547 0.24364,-0.772729 0.53818,-0.885456 5.35637,-2.039999 5.40182,-21.203635 0.0654,-26.332727 -0.17637,-0.16909 -0.64727,-1.052727 -1.04909,-1.965455 -1.05091,-2.392726 -3.17092,-3.545454 -8.92,-4.845453 -5.51091,-1.245455 -69.73091,-1.65091 -81.620004,-0.512728 m 246.100004,0.529091 c -5.69091,1.21091 -7.93818,2.427273 -8.91455,4.82909 -0.37092,0.912728 -1.60181,3.692727 -2.73818,6.18 -4.27454,9.361819 0.24,27.027274 7.32909,28.67091 8.94545,2.072727 10.5,2.156364 40.21636,2.156364 36.34,0 34.19273,-0.589092 35.82364,9.83636 0.85818,5.48728 0.85818,198.00364 0,203.48908 -1.63091,10.42547 0.51636,9.83638 -35.82364,9.83638 -29.71636,0 -31.27091,0.0837 -40.21636,2.15817 -7.08909,1.64183 -11.60363,19.30728 -7.32909,28.67092 1.13637,2.48545 2.36726,5.26727 2.73818,6.17818 2.17818,5.35635 7.25091,5.97636 48.9909,5.98727 47.96183,0.0107 53.39273,-0.65818 60.00001,-7.4 1.30545,-1.33091 3.97273,-3.35819 5.92728,-4.50364 5.00908,-2.93635 5.34181,-3.44363 7.8509,-12.03272 1.23454,-4.22727 2.63637,-8.98183 3.11636,-10.56727 1.30909,-4.32001 1.30909,-235.821822 0,-240.14364 -0.47999,-1.585454 -1.88182,-6.34 -3.11636,-10.565454 -2.50909,-8.589091 -2.84182,-9.098182 -7.8509,-12.032728 -1.95455,-1.147272 -4.62183,-3.172727 -5.92728,-4.505454 -6.62546,-6.76 -12.08,-7.425455 -60.30728,-7.36 -30.57272,0.04 -35.33817,0.174546 -39.76908,1.118182 M 87.376365,80.17046 c -4.607268,1.17637 -8.121822,2.99091 -9.203631,4.75273 -0.276368,0.44909 -2.036365,1.68182 -3.910922,2.74 -5.672718,3.20364 -7.954534,10.04727 -6.37817,19.13091 0.736355,4.23455 3.161809,9.6491 4.325448,9.6491 0.303645,0 2.779999,1.52726 5.505457,3.39272 8.17091,5.59636 101.970903,6.05455 126.714543,5.66182 l 107.36546,-0.32001 5.72727,-2.60363 c 7.41637,-3.3709 9.73092,-5.63091 13.21091,-12.89273 3.39091,-7.07272 3.38727,-7.00363 0.48909,-13.67818 -2.98545,-6.87273 -6.95454,-10.82363 -14.29273,-14.22363 l -5.09272,-2.36 -108.00001,-0.24 C 184.65273,78.95774 91.839996,79.03228 87.376365,80.17046 m -2.554545,68.22365 c -16.609096,1.92908 -23.163632,22.64726 -11.147273,35.23271 6.041822,6.3291 5.400003,6.20546 34.032723,6.47819 33.53273,0.32 214.32191,2.93417 217.311,-3.40764 0.68001,-1.44182 4.32537,-7.49055 5.54355,-9.29964 3.30727,-4.90545 3.30727,-11.87637 0,-16.78181 -1.21818,-1.8091 -2.77273,-4.47091 -3.45272,-5.91273 -2.89273,-6.13636 -94.60182,-6.93273 -125.25091,-6.82 -12.34183,0.0454 -115.007284,0.27454 -117.03637,0.51092 m 2.616365,65.16725 c -3.589093,0.91638 -5.980003,2.05274 -9.718185,4.61274 -2.727272,1.86726 -5.207265,3.39454 -5.51091,3.39454 -1.163639,0 -3.589093,5.41455 -4.325448,9.65091 -1.576364,9.08363 0.705452,15.92727 6.37817,19.12909 1.874557,1.05818 3.634554,2.29091 3.910922,2.74 3.005453,4.89818 101.847266,6.2 126.289086,5.81273 l 107.39819,-0.31818 5.08,-2.35455 c 7.32544,-3.39454 11.29817,-7.34909 14.28181,-14.22 2.89818,-6.67272 2.90182,-6.60364 -0.48909,-13.67637 -3.47999,-7.26545 -5.79454,-9.52181 -13.22182,-12.89999 l -5.74,-2.6091 -107.96909,-0.24 c -19.0691,-0.22 -111.976369,-0.14363 -116.363635,0.97818">
					<svg.cbtn @click=toggleParallelMode(yes) [padding: 8px] viewBox="0 0 400 338">
						<title> data.lang.parallel
						<path d=svg_paths.columnssvg [fill:inherit fill-rule:evenodd stroke:none stroke-width:1.81818187]>
				<.nighttheme @click=(do show_fonts = !show_fonts)>
					<span.font_icon> "B"
					settings.font.name
					<.languages .show_languages=show_fonts>
						for font in fonts
							<button[ff: {font.code}] @click=setFontFamily(font)> font.name
				<.profile_in_settings>
					if data.getUserName()
						<a.username route-to.exact='/profile/$'> data.getUserName()
						<a.prof_btn @click.stop.prevent=(window.location = "/accounts/logout/") href="/accounts/logout/"> data.lang.logout
					else
						<a.prof_btn @click.stop.prevent=(window.location = "/accounts/login/") href="/accounts/login/"> data.lang.login
						<a.prof_btn.signin @click.stop.prevent=(window.location = "/signup/") href="/signup/"> data.lang.signin
				<.help @click=turnHistory>
					<svg.helpsvg width="24" height="24" viewBox="0 0 24 24">
						<title> data.lang.history
						<path d="M0 0h24v24H0z" fill="none">
						<path d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z">
					data.lang.history
				<.help @click=pageSearch()>
					<svg.helpsvg[p:0 4px] viewBox="0 0 12 12" width="24px" height="24px">
						<title> data.lang.find_in_chapter
						<path d=svg_paths.search>
					data.lang.find_in_chapter
				<.nighttheme.flex @click=(do data.show_languages = !data.show_languages)>
					data.lang.language
					<button.change_language> currentLanguage!
					<.languages .show_languages=data.show_languages>
						<button @click=(do data.setLanguage('ukr'))> "Українська"
						<button @click=(do data.setLanguage('ru'))> "Русский"
						<button @click=(do data.setLanguage('eng'))> "English"
						<button @click=(do data.setLanguage('de'))> "Deutsch"
						<button @click=(do data.setLanguage('pt'))> "Portuguese"
						<button @click=(do data.setLanguage('es'))> "Español"
				<.nighttheme.parent_checkbox.flex @click=toggleParallelSynch() .checkbox_turned=settings.parallel_synch>
					data.lang.parallel_synch
					<p.checkbox> <span>
				<.nighttheme.parent_checkbox.flex @click=toggleVersePicker() .checkbox_turned=settings.verse_picker>
					data.lang.verse_picker
					<p.checkbox> <span>
				<.nighttheme.parent_checkbox.flex @click=toggleTransitions() .checkbox_turned=settings.transitions>
					data.lang.transitions
					<p.checkbox> <span>
				<.nighttheme.parent_checkbox.flex @click=toggleVerseBreak() .checkbox_turned=settings.verse_break>
					data.lang.verse_break
					<p.checkbox> <span>

				if window.navigator.onLine
					if data.db_is_available
						<.help @click=toggleDownloads>
							<svg.helpsvg @click=toggleDownloads viewBox="0 0 212.646728515625 159.98291015625">
								<title> data.lang.download_translations
								<g transform="matrix(1.5 0 0 1.5 0 128)">
									<path d=svg_paths.download>
							data.lang.download_translations
					<a.help href='/downloads/' target="_blank" @click=install>
						<img.helpsvg[size:32px rd: 23%] src='/static/bolls.png' alt=data.lang.install_app>
						data.lang.install_app
				<a.help @click=turnHelpBox>
					<svg.helpsvg aria-hidden="true" width="24" height="24" viewBox="0 0 24 24">
						<title> data.lang.help
						<path fill="none" d="M0 0h24v24H0z">
						<path d="M11 18h2v-2h-2v2zm1-16C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm0-14c-2.21 0-4 1.79-4 4h2c0-1.1.9-2 2-2s2 .9 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5 0-2.21-1.79-4-4-4z">
					data.lang.help
				<a#animated-heart.help @click=turnSupport()>
					<svg.helpsvg aria-hidden="true" height="24" viewBox="0 0 24 24" width="24">
						<title> data.lang.support
						<path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z" fill="firebrick" >
					data.lang.support
				<.help @click=randomVerse>
					<svg.helpsvg viewBox="0 0 25 25" role="img" aria-hidden="true" width="24px" height="24px">
						<path fill="none" d="M0 0h25v25H0z">
						<path d="M17.5 4h-10A3.5 3.5 0 004 7.5v10A3.5 3.5 0 007.5 21h10a3.5 3.5 0 003.5-3.5v-10A3.5 3.5 0 0017.5 4zm-10 1H12v4.414A5.537 5.537 0 0010.973 7.6 2.556 2.556 0 009.1 6.869a2.5 2.5 0 00-1.814.794 2.614 2.614 0 00.2 3.684A3.954 3.954 0 008.671 12H5V7.5A2.5 2.5 0 017.5 5zm4.271 6.846a11.361 11.361 0 01-3.6-1.231 1.613 1.613 0 01-.146-2.271 1.5 1.5 0 011.094-.476h.021a1.7 1.7 0 011.158.464 11.4 11.4 0 011.472 3.514zM5 17.5V13h6.64c-.653 1.149-2.117 3.2-4.4 3.568a.5.5 0 10.158.987A7.165 7.165 0 0012 14.318V20H7.5A2.5 2.5 0 015 17.5zM17.5 20H13v-5.7a7.053 7.053 0 004.6 3.259.542.542 0 00.074.005.5.5 0 00.072-.995c-2.194-.325-3.632-2.253-4.377-3.567H20v4.5A2.5 2.5 0 0117.5 20zm2.5-8h-3.735a4.1 4.1 0 001.251-.678 2.614 2.614 0 00.2-3.684 2.5 2.5 0 00-1.816-.793 2.634 2.634 0 00-1.872.732A5.537 5.537 0 0013 9.389V5h4.5A2.5 2.5 0 0120 7.5zm-6.77-.179a11.405 11.405 0 011.479-3.513 1.694 1.694 0 011.158-.464h.021a1.5 1.5 0 011.094.476 1.613 1.613 0 01-.146 2.271 11.366 11.366 0 01-3.606 1.23z">
					data.lang.random
				<footer>
					<p.footer_links>
						<a target="_blank" rel="noreferrer" href="http://t.me/bollsbible"> "Telegram"
						<a target="_blank" rel="noreferrer" href="https://github.com/Bohooslav/bain/"> "GitHub"
						<a target="_blank" href="/api"> "API "
						<a target="_blank" rel="noreferrer" href="https://send.monobank.ua/6ao79u5rFZ"> '🔥 ', data.lang.donate, " 🐈"
						<a target="_blank" rel="noreferrer" href="https://v2.imba.io"> "Imba"
						<a target="_blank" rel="noreferrer" href="https://docs.djangoproject.com/en/3.0/"> "Django"
						<a target="_blank" rel="noreferrer" href="http://www.patreon.com/bolls"> "Patreon"
						<a target="_blank" href="/static/privacy_policy.html"> "Privacy Policy"
						<a target="_blank" href="/static/disclaimer.html"> "Disclaimer"
						<a target="_blank" rel="noreferrer" href="http://t.me/Boguslavv"> "Hire me"
					<p>
						"©",	<time dateTime='2020-07-26T12:11'> "2019"
						"-present Павлишинець Богуслав 🎻 Pavlyshynets Bohuslav"


			<section.search_results .height_auto=(!search.search_result_header && what_to_show_in_pop_up_block=='search') .show_search_results=(what_to_show_in_pop_up_block) [zi:{what_to_show_in_pop_up_block == "show_note" ? 1200 : 'auto'}]>
				if what_to_show_in_pop_up_block == 'show_help'
					<article.search_hat>
						<svg.close_search @click=turnHelpBox() viewBox="0 0 20 20">
							<title> data.lang.close
							<path[m: auto] d=svg_paths.close>
						<h1> data.lang.help
						<a href="mailto:bpavlisinec@gmail.com">
							<svg.filter_search width="16" height="16" viewBox="0 0 16 16">
								<title> data.lang.help
								<g>
									<path d="M16 2L0 7l3.5 2.656L14.563 2.97 5.25 10.656l4.281 3.156z">
									<path d="M3 8.5v6.102l2.83-2.475-.66-.754L4 12.396V8.5z" color="#000" font-weight="400" font-family="sans-serif" white-space="normal" overflow="visible" fill-rule="evenodd">
					<article.helpFAQ.search_body>
						<p[color: $accent-hover-color font-size: 0.9em]> data.lang.faqmsg
						<h3> data.lang.content
						<ul>
							for q in data.lang.HB
								<li> <a href="#{q[0]}"> q[0]
							if window.innerWidth > 1024
								<li> <a href="#shortcuts"> data.lang.shortcuts
						for q in data.lang.HB
							<h3 id=q[0] > q[0]
							<p> q[1]
						if window.innerWidth > 1024
							<div id="shortcuts">
								<h3> data.lang.shortcuts
								for shortcut in data.lang.shortcuts_list
									<p> <span innerHTML=shortcut>
						<address.still_have_questions>
							data.lang.still_have_questions
							<a href="mailto:bpavlisinec@gmail.com"> " bpavlisinec@gmail.com"
				elif what_to_show_in_pop_up_block == 'show_compare'
					<article.search_hat>
						<svg.close_search @click=clearSpace() viewBox="0 0 20 20">
							<title> data.lang.close
							<path[m: auto] d=svg_paths.close>
						<h1> highlighted_title
						<svg.filter_search @click=(do show_translations_for_comparison = !show_translations_for_comparison) viewBox="0 0 20 20" alt=data.lang.addcollection [stroke: $text-color]>
							<title> data.lang.compare
							<line x1="0" y1="10" x2="20" y2="10">
							<line x1="10" y1="0" x2="10" y2="20">
						<[z-index: 1100].filters .show=show_translations_for_comparison>
							if compare_translations.length == translations.length
								<p[padding: 12px 8px]> data.lang.nothing_else
							for translation in translations when !compare_translations.find(do |element| return element == translation.short_name)
								<a.book_in_list.book_in_filter dir="auto" @click=addTranslation(translation)> translation.short_name, ', ', translation.full_name
					<article.search_body [pb: 256px scroll-behavior: auto]>
						<p.total_msg> data.lang.add_translations_msg
						<ul.comparison_box>
							for tr in comparison_parallel
								<compare-draggable-item data=tr id="compare_{tr[0].translation}" langdata=data.lang>
						unless compare_translations.length
							<button[m: 16px auto; d: flex].more_results @click=(do show_translations_for_comparison = !show_translations_for_comparison)> data.lang.add_translation_btn
				elif what_to_show_in_pop_up_block == 'show_downloads'
					<article.search_hat>
						<svg.close_search @click=clearSpace() viewBox="0 0 20 20">
							<title> data.lang.close
							<path[m: auto] d=svg_paths.close>
						<h1> data.lang.download_translations
						if data.deleting_of_all_transllations
							<svg.close_search.animated_downloading width="16" height="16" viewBox="0 0 16 16">
								<title> data.lang.loading
								<path d=svg_paths.loading [marker:none c:#000 of:visible fill:$text-color]>
						else
							<svg.close_search @click=(do data.clearVersesTable()) viewBox="0 0 12 16" alt=data.lang.delete>
								<title> data.lang.remove_all_translations
								<path fill-rule="evenodd" clip-rule="evenodd" d="M11 2H9C9 1.45 8.55 1 8 1H5C4.45 1 4 1.45 4 2H2C1.45 2 1 2.45 1 3V4C1 4.55 1.45 5 2 5V14C2 14.55 2.45 15 3 15H10C10.55 15 11 14.55 11 14V5C11.55 5 12 4.55 12 4V3C12 2.45 11.55 2 11 2ZM10 14H3V5H4V13H5V5H6V13H7V5H8V13H9V5H10V14ZM11 4H2V3H11V4Z">
					<article.search_body>
						for language in languages
							<a.book_in_list dir="auto" [jc: start pl: 0px] .pressed=(language.language == show_language_of) @click=showLanguageTranslations(language.language)>
								language.language
								<svg[ml: auto].arrow_next width="16" height="10" viewBox="0 0 8 5">
									<title> data.lang.open
									<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
							<ul.list_of_chapters dir="auto" .show_list_of_chapters=(language.language == show_language_of)>
								for tr in language.translations
									if window.navigator.onLine || data.downloaded_translations().indexOf(tr.short_name) != -1
										<a.search_res_verse_header>
											<.search_res_verse_text [margin-right: auto text-align: left]> tr.short_name, ', ', tr.full_name
											if data.downloading_of_this_translations.find(do |translation| return translation == tr.short_name)
												<svg.remove_parallel.close_search.animated_downloading width="16" height="16" viewBox="0 0 16 16">
													<title> data.lang.loading
													<path d=svg_paths.loading [marker:none c:#000 of:visible fill:$text-color]>
											elif data.downloaded_translations.indexOf(tr.short_name) != -1
												<svg.remove_parallel.close_search @click=(do data.deleteTranslation(tr.short_name)) viewBox="0 0 12 16" alt=data.lang.delete>
													<title> data.lang.delete
													<path fill-rule="evenodd" clip-rule="evenodd" d="M11 2H9C9 1.45 8.55 1 8 1H5C4.45 1 4 1.45 4 2H2C1.45 2 1 2.45 1 3V4C1 4.55 1.45 5 2 5V14C2 14.55 2.45 15 3 15H10C10.55 15 11 14.55 11 14V5C11.55 5 12 4.55 12 4V3C12 2.45 11.55 2 11 2ZM10 14H3V5H4V13H5V5H6V13H7V5H8V13H9V5H10V14ZM11 4H2V3H11V4Z">
											else
												<svg.remove_parallel.close_search @click=(do data.downloadTranslation(tr.short_name)) viewBox="0 0 212.646728515625 159.98291015625">
													<title> data.lang.download
													<g transform="matrix(1.5 0 0 1.5 0 128)">
														<path d=svg_paths.download>
						<.freespace>
				elif what_to_show_in_pop_up_block == 'show_support'
					<article.search_hat>
						<svg.close_search @click=turnSupport() viewBox="0 0 20 20">
							<title> data.lang.close
							<path[m: auto] d=svg_paths.close>
						<h1> data.lang.support
						<a href="mailto:bpavlisinec@gmail.com">
							<svg.filter_search width="16" height="16" viewBox="0 0 16 16">
								<title> data.lang.help
								<g>
										<path d="M16 2L0 7l3.5 2.656L14.563 2.97 5.25 10.656l4.281 3.156z">
										<path d="M3 8.5v6.102l2.83-2.475-.66-.754L4 12.396V8.5z" color="#000" font-weight="400" font-family="sans-serif" white-space="normal" overflow="visible" fill-rule="evenodd">
					<article.helpFAQ.search_body>
						<h3> data.lang.ycdtitnw
						<ul> for text in data.lang.SUPPORT
							<li> <span innerHTML=text>
						<h3> data.lang.bgthnkst, ":"
						<ul> for text in thanks_to
							<li> <span innerHTML=text>
				elif what_to_show_in_pop_up_block == "show_note"
					<article.search_hat>
						<svg.close_search @click=makeNote() viewBox="0 0 20 20">
							<title> data.lang.close
							<path[m: auto] d=svg_paths.close>
						<h1> data.lang.note, ',', highlighted_title
						<svg.save_bookmark [width: 26px] viewBox="0 0 12 16" @click=sendBookmarksToDjango alt=data.lang.create>
							<title> data.lang.create
							<path fill-rule="evenodd" clip-rule="evenodd" d="M12 5L4 13L0 9L1.5 7.5L4 10L10.5 3.5L12 5Z">
					unless isNoteEmpty()
						<p#note_placeholder> data.lang.write_something_awesone
					<rich-text-editor bind=store dir="auto">
				else
					if search_verses.length
						<.filters .show=search.show_filters [z-index:1]>
							if settingsp.edited_version == settingsp.translation && settingsp.display
								if search.filter then <button.book_in_list @click=dropFilter> data.lang.drop_filter
								<>
									for book in parallel_books
										<button.book_in_list.book_in_filter dir="auto" @click=addFilter(book.bookid)> book.name
							else
								if search.filter then <button.book_in_list @click=dropFilter> data.lang.drop_filter
								for book in books when search.bookid_of_results.find(do |element| return element == book.bookid)
									<button.book_in_list.book_in_filter dir="auto" @click=addFilter(book.bookid)> book.name
					<article.search_hat>
						<svg.close_search [min-width:24px] @click=closeSearch(true) viewBox="0 0 20 20">
							<title> data.lang.close
							<path[m: auto] d=svg_paths.close>

						<input#generalsearch[w:100% bg:transparent font:inherit c:inherit p:0 8px fs:1.2em min-width:128px bd:none] bind=search.search_input type='text' placeholder=data.lang.bible_search aria-label=data.lang.bible_search @keydown.enter=getSearchText>

						<svg.close_search [w:24px min-width:24px mr:8px] viewBox="0 0 12 12" width="24px" height="24px" @click=getSearchText>
							<title> data.lang.bible_search
							<path d=svg_paths.search>
						if search_verses.length
							<svg.filter_search [min-width:24px] .filter_search_hover=search.show_filters||search.filter @click=(do search.show_filters = !search.show_filters) viewBox="0 0 20 20">
								<title> data.lang.addfilter
								<path d="M12 12l8-8V0H0v4l8 8v8l4-4v-4z">

					if search.search_result_header
						<article#search_body.search_body [position:relative] @scroll=searchPagination>
							for rect in page_search.rects
								<div.{rect.class}[top: {rect.top}px left: {rect.left}px width: {rect.width}px height: {rect.height}px]>

							<p.total_msg> search.search_result_header, ': ', page_search.rects.length, ' / ',  getFilteredASearchVerses().length, ' ', data.lang.totalyresultsofsearch

							<>
								for verse, key in getFilteredASearchVerses()
									<a.search_item>
										<search-text-as-html.search_res_verse_text data=verse innerHTML=verse.text>
										<.search_res_verse_header>
											<span> nameOfBook(verse.book, (settingsp.display ? settingsp.edited_version : settings.translation)), ' '
											<span> verse.chapter, ':'
											<span> verse.verse
											<svg.open_in_parallel @click=copyToClipboardFromSerach(verse) viewBox="0 0 561 561" alt=data.lang.copy>
												<title> data.lang.copy
												<path d=svg_paths.copy>
											<svg.open_in_parallel [margin-left: 4px] viewBox="0 0 400 338" @click=backInHistory({translation: search.translation, book: verse.book, chapter: verse.chapter,verse: verse.verse}, yes)>
												<title> data.lang.open_in_parallel
												<path d=svg_paths.columnssvg [fill:inherit fill-rule:evenodd stroke:none stroke-width:1.81818187]>
								if search.filter then <div[p: 12px 0px; text-align: center]>
									data.lang.filter_name, ' ', nameOfBook(search.filter, (settingsp.display ? settingsp.edited_version : settings.translation))
									<br>
									<button[d: inline-block; mt: 12px].more_results @click=dropFilter> data.lang.drop_filter
							unless search_verses.length
								<div[display:flex flex-direction:column height:100% justify-content:center align-items:center]>
									<p> data.lang.nothing
									<p[padding: 32px 0px 8px]> data.lang.translation, ' ', search.search_result_translation
									<button.more_results @click=showTranslations> data.lang.change_translation
							<.freespace>


			<section.hide .without_padding=(show_collections || show_share_box) .choosen_verses=choosenid.length>
				if show_collections
					<.collectionshat>
						<svg.svgBack viewBox="0 0 20 20" @click=turnCollections>
							<title> data.lang.back
							<path d="M3.828 9l6.071-6.071-1.414-1.414L0 10l.707.707 7.778 7.778 1.414-1.414L3.828 11H20V9H3.828z">
						if addcollection
							<p.saveto> data.lang.newcollection
						else
							<p.saveto> data.lang.saveto
							<svg.svgAdd @click=addCollection viewBox="0 0 20 20" alt=data.lang.addcollection>
								<title> data.lang.addcollection
								<line x1="0" y1="10" x2="20" y2="10">
								<line x1="10" y1="0" x2="10" y2="20">
					<.mark_grid>
						if addcollection
							<input#newcollectioninput.newcollectioninput bind=store.newcollection @keydown.enter.addNewCollection(store.newcollection) type="text">
						elif categories.length
							for category in categories
								if category
									<p.collection
									.add_new_collection=(choosen_categories.find(do |element| return element == category))
									@click=addNewCollection(category)> category
							<div[min-width: 16px]>
						else
							<p[m: 8px auto].collection.add_new_collection @click=addCollection> data.lang.addcollection
					if (store.newcollection && addcollection) || (choosen_categories.length && !addcollection)
						<button.cancel.add_new_collection @click=addNewCollection(store.newcollection)> data.lang.save
					else
						<button.cancel @click=turnCollections> data.lang.cancel
				elif show_share_box
					<.collectionshat>
						<p.saveto> data.lang.share_via
					<.mark_grid>
						<.share_box @click=(do data.shareCopying(getShareObj()) && clearSpace())>
							<svg.share_btn viewBox="0 0 561 561" alt=data.lang.copy fill="var(--text-color)">
								<title> data.lang.copy
								<path d=svg_paths.copy>
						<.share_box @click=(do data.internationalShareCopying(getShareObj()) && clearSpace())>
							<svg.share_btn height="24" viewBox="0 0 24 24" width="24" fill="var(--text-color)">
								<title> data.lang.copy_international
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
						<.share_box @click=shareViaVK()>
							<svg.share_btn width="445" height="445" viewBox="0 0 445 445">
								<title> "Vkontakte"
								<g id="icon" [stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-linejoin: miter; stroke-miterlimit: 10; fill: none; fill-rule: nonzero; opacity: 1] transform="translate(-2.4722222222222285 -2.4722222222222285) scale(4.94 4.94)">
									<path d="M 31.2 0 c 25.2 0 2.4 0 27.6 0 S 90 6 90 31.2 s 0 2.4 0 27.6 S 84 90 58.8 90 s -2.4 0 -27.6 0 S 0 84 0 58.8 s 0 -13.528 0 -27.6 C 0 6 6 0 31.2 0 z" [stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-linejoin: miter; stroke-miterlimit: 10; fill: rgb(81,129,184); fill-rule: nonzero; opacity: 1] transform=" matrix(1 0 0 1 0 0) " stroke-linecap="round">
									<path d="M 73.703 31.006 c 0.417 -1.391 0 -2.412 -1.985 -2.412 h -6.563 c -1.669 0 -2.438 0.883 -2.855 1.856 c 0 0 -3.337 8.134 -8.065 13.418 c -1.53 1.53 -2.225 2.016 -3.059 2.016 c -0.417 0 -1.021 -0.487 -1.021 -1.877 V 31.006 c 0 -1.669 -0.484 -2.412 -1.875 -2.412 H 37.969 c -1.043 0 -1.67 0.774 -1.67 1.508 c 0 1.582 2.364 1.947 2.607 6.396 v 9.664 c 0 2.119 -0.383 2.503 -1.217 2.503 c -2.225 0 -7.636 -8.171 -10.846 -17.52 c -0.629 -1.817 -1.26 -2.551 -2.937 -2.551 h -6.563 c -1.875 0 -2.25 0.883 -2.25 1.856 c 0 1.738 2.225 10.359 10.359 21.761 c 5.423 7.787 13.063 12.008 20.016 12.008 c 4.171 0 4.688 -0.938 4.688 -2.552 v -5.885 c 0 -1.875 0.395 -2.249 1.716 -2.249 c 0.973 0 2.642 0.487 6.535 4.241 c 4.45 4.45 5.183 6.446 7.686 6.446 h 6.563 c 1.875 0 2.813 -0.938 2.272 -2.788 c -0.592 -1.844 -2.716 -4.519 -5.535 -7.691 c -1.53 -1.808 -3.824 -3.754 -4.519 -4.728 c -0.973 -1.251 -0.695 -1.808 0 -2.92 C 64.874 46.093 72.869 34.83 73.703 31.006 z" [stroke: none; stroke-width: 1; stroke-dasharray: none; stroke-linecap: butt; stroke-linejoin: miter; stroke-miterlimit: 10; fill: rgb(255,255,255); fill-rule: nonzero; opacity: 1] transform=" matrix(1 0 0 1 0 0) " stroke-linecap="round">
						<.share_box @click=shareViaViber()>
							<svg.share_btn viewBox='0 0 72 72' [border-radius: 23%]>
								<rect x="0" y="0" [fill:#7D3DAF] width="455.731" height="455.731">
								<title> "Viber"
								<g fill="#FFF" [transform: translateY(-20%) translateX(-25%) scale(1.5)]>
									<path d="M45.775 39.367c-.732-.589-1.514-1.118-2.284-1.658-1.535-1.078-2.94-1.162-4.085.573-.644.974-1.544 1.017-2.486.59-2.596-1.178-4.601-2.992-5.775-5.63-.52-1.168-.513-2.215.702-3.04.644-.437 1.292-.954 1.24-1.908-.067-1.244-3.088-5.402-4.281-5.84-.494-.182-.985-.17-1.488-.002-2.797.94-3.955 3.241-2.846 5.965 3.31 8.127 9.136 13.784 17.155 17.237.457.197.965.275 1.222.346 1.826.018 3.964-1.74 4.582-3.486.595-1.68-.662-2.346-1.656-3.147zm-8.991-16.08c5.862.9 8.566 3.688 9.312 9.593.07.545-.134 1.366.644 1.381.814.016.618-.793.625-1.339.068-5.56-4.78-10.716-10.412-10.906-.425.061-1.304-.293-1.359.66-.036.641.704.536 1.19.61z">
									<path d="M37.93 24.905c-.564-.068-1.308-.333-1.44.45-.137.82.692.737 1.225.856 3.621.81 4.882 2.127 5.478 5.719.087.524-.086 1.339.804 1.203.66-.1.421-.799.476-1.207.03-3.448-2.925-6.586-6.543-7.02z">
									<path d="M38.263 27.725c-.377.01-.746.05-.884.452-.208.601.229.745.674.816 1.485.239 2.267 1.114 2.415 2.596.04.402.295.727.684.682.538-.065.587-.544.57-.998.027-1.665-1.854-3.588-3.46-3.548z">
					<button.cancel @click=(do show_share_box = no)> data.lang.cancel
				else
					if store.show_color_picker
						if window.innerWidth < 640
							<svg.close_colorPicker
								@click=(do store.show_color_picker = !store.show_color_picker)
								xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 16"
							>
								<title> data.lang.close
								<path fill-rule="evenodd" clip-rule="evenodd" d="M12 5L4 13L0 9L1.5 7.5L4 10L10.5 3.5L12 5Z">
						<color-picker bind=store .show-canvas=store.show_color_picker width="320" height="208" alt=data.lang.canvastitle>  data.lang.canvastitle
					<p> highlighted_title, ' ', choosen_parallel == "first" ? settings.translation : settingsp.translation
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
									<title> data.lang.delete
									<path d=svg_paths.close>
					<#addbuttons>
						if show_delete_bookmark then <svg.close_search @click=deleteBookmarks(choosenid) viewBox="0 0 12 16" alt=data.lang.delete>
							<title> data.lang.delete
							<path fill-rule="evenodd" clip-rule="evenodd" d="M11 2H9C9 1.45 8.55 1 8 1H5C4.45 1 4 1.45 4 2H2C1.45 2 1 2.45 1 3V4C1 4.55 1.45 5 2 5V14C2 14.55 2.45 15 3 15H10C10.55 15 11 14.55 11 14V5C11.55 5 12 4.55 12 4V3C12 2.45 11.55 2 11 2ZM10 14H3V5H4V13H5V5H6V13H7V5H8V13H9V5H10V14ZM11 4H2V3H11V4Z">
						<svg.close_search @click=clearSpace() viewBox="0 0 20 20" alt=data.lang.close>
							<title> data.lang.close
							<path d=svg_paths.close alt=data.lang.close>
						<svg.save_bookmark [stroke:none] @click=(do show_share_box = yes) xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24">
							<title> data.lang.share
							<path d="M0 0h24v24H0V0z" fill="none">
							<path d="M16 5l-1.42 1.42-1.59-1.59V16h-1.98V4.83L9.42 6.42 8 5l4-4 4 4zm4 5v11c0 1.1-.9 2-2 2H6c-1.11 0-2-.9-2-2V10c0-1.11.89-2 2-2h3v2H6v11h12V10h-3V8h3c1.1 0 2 .89 2 2z">
						<svg.save_bookmark @click=copyToClipboard() viewBox="0 0 561 561" alt=data.lang.copy>
							<title> data.lang.copy
							<path d=svg_paths.copy>
						<svg.save_bookmark @click=toggleCompare() viewBox='0 0 400 400'>
							<title> data.lang.compare
							<path d="m 158.87835,59.714254 c -22.24553,22.942199 -40.6885,42.183936 -40.98426,42.758776 -0.8318,1.61252 -0.20661,2.77591 3.5444,6.59866 5.52042,5.6227 1.07326,9.0169 37.637,-28.724885 17.50924,-18.073765 32.15208,-32.92934 32.53977,-33.012765 2.11329,-0.454845 1.99262,-9.787147 1.99262,154.63098 0,162.70162 0.0852,155.59667 -1.92404,155.16124 -0.4175,-0.0891 -31.30684,-31.67221 -68.64371,-70.1831 -82.516734,-85.113 -79.762069,-82.23881 -79.523922,-82.9759 0.156562,-0.48685 7.785466,-0.64342 40.516819,-0.82856 33.282953,-0.18856 40.451433,-0.33827 41.056163,-0.85598 0.99477,-0.85141 1.07891,-10.82255 0.10651,-12.19963 -1.01499,-1.43197 -104.747791,-1.64339 -106.131194,-0.216 -1.408859,1.45366 -1.422172,108.27345 -0.01065,109.72598 1.061864,1.09597 10.873494,1.39767 11.873689,0.36572 0.405788,-0.41828 0.535724,-10.38028 0.551701,-41.94167 0.01065,-31.23452 0.150173,-41.70737 0.55383,-42.67534 l 0.533593,-1.28109 78.641191,81.10851 c 43.25264,44.609 79.6823,82.26506 80.95505,83.67874 1.27157,1.41482 2.51534,2.57136 2.7635,2.57136 3.82365,0.0993 6.74023,0.19783 10.78264,0.32569 l 2.48223,-2.72678 c 9.56539,-10.51282 158.34672,-163.337 159.13762,-163.46273 1.69462,-0.2697 1.72007,0.33714 1.72678,42.53708 0.007,40.52683 0.0212,41.4788 0.86376,41.94164 1.22845,0.67884 10.78936,0.61599 11.45949,-0.0754 0.94791,-0.97828 0.75087,-109.32029 -0.20024,-110.13513 -0.61027,-0.52227 -9.49349,-0.64912 -53.0551,-0.75425 l -52.32298,-0.128 -0.77536,0.97824 c -1.17177,1.47768 -1.14409,11.36197 0.032,12.46251 0.74235,0.69256 4.25002,0.75654 41.35204,0.75654 22.29752,0 40.6652,0.12915 40.81803,0.28686 0.75194,0.77597 -5.99106,7.88549 -73.9736,77.99435 -74.8598,77.20005 -74.60834,76.94635 -75.706,76.51207 -0.65608,-0.25942 -1.04162,-309.073405 -0.38768,-310.829927 0.51549,-1.385101 3.29625,1.278819 28.18793,26.998083 44.2328,45.702694 38.02575,40.757704 43.65905,34.786424 4.03624,-4.27873 4.21348,-4.55415 3.74602,-5.85812 -0.56235,-1.56794 -81.63283,-85.027265 -82.59319,-85.027265 -0.5123,0 -16.36846,16.023541 -41.27664,41.713088" [stroke-width:20;stroke-miterlimit:4;stroke-opacity:1;stroke-linecap:round;stroke-linejoin:round;paint-order:normal] fill-rule="evenodd">
						<svg.save_bookmark .filled=isNoteEmpty() @click=makeNote() viewBox="0 0 24 24" fill="black" alt=data.lang.note>
							<title> data.lang.note
							<path d="M 9.0001238,20.550118 H 24.00033 V 16.550063 H 13.000179 Z M 16.800231,8.7499555 c 0.400006,-0.400006 0.400006,-1.0000139 0,-1.4000194 L 13.200182,3.7498865 c -0.400006,-0.4000055 -1.000014,-0.4000055 -1.40002,0 L 0,15.550049 v 5.000069 h 5.0000688 z">
						<svg.save_bookmark .filled=choosen_categories.length @click=turnCollections() viewBox="0 0 20 20" alt=data.lang.addtocollection>
							<title> data.lang.addtocollection
							<path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2zm2 0v15l6-3 6 3V2H4z">
						<svg.save_bookmark [width: 26px] viewBox="0 0 12 16" @click=sendBookmarksToDjango alt=data.lang.create>
							<title> data.lang.create
							<path fill-rule="evenodd" clip-rule="evenodd" d="M12 5L4 13L0 9L1.5 7.5L4 10L10.5 3.5L12 5Z">


			<section.history.filters .show_history=show_history>
				<[m: 0].nighttheme.flex>
					<svg[m: 0 8px].close_search @click=turnHistory() viewBox="0 0 20 20">
							<title> data.lang.close
							<path d=svg_paths.close>
					<h1[margin: 0 0 0 8px]> data.lang.history
					<svg[margin-left: auto; padding: 0; margin: 0 12px 0 16px; width: 32px;].close_search @click=clearHistory() viewBox="0 0 24 24" alt=data.lang.delete>
						<title> data.lang.delete
						<path d="M15 16h4v2h-4v-2zm0-8h7v2h-7V8zm0 4h6v2h-6v-2zM3 20h10V8H3v12zM14 5h-3l-1-1H6L5 5H2v2h12V5z">
				<article.historylist>
					for h in history.slice().reverse()
						<div[display: flex]>
							<a.book_in_list @click=backInHistory(h)>
								getNameOfBookFromHistory(h.translation, h.book) + ' ' + h.chapter
								if h.verse
									':' + h.verse
								' ' + h.translation
							<svg.open_in_parallel viewBox="0 0 400 338" @click=backInHistory(h, yes)>
								<title> data.lang.open_in_parallel
								<path d=svg_paths.columnssvg [fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187]>
					else
						<p[padding: 12px]> data.lang.empty_history


			if menuicons and not (what_to_show_in_pop_up_block && window.innerWidth < 640)
				<section#navigation>
					<[l:0 transform: translateY({menu_icons_transform}%) translateX({bibleIconTransform!}px)] @click=toggleBibleMenu>
						<svg viewBox="0 0 16 16">
							<title> data.lang.change_book
							<path d="M3 5H7V6H3V5ZM3 8H7V7H3V8ZM3 10H7V9H3V10ZM14 5H10V6H14V5ZM14 7H10V8H14V7ZM14 9H10V10H14V9ZM16 3V12C16 12.55 15.55 13 15 13H9.5L8.5 14L7.5 13H2C1.45 13 1 12.55 1 12V3C1 2.45 1.45 2 2 2H7.5L8.5 3L9.5 2H15C15.55 2 16 2.45 16 3ZM8 3.5L7.5 3H2V12H8V3.5ZM15 3H9.5L9 3.5V12H15V3Z">
						<p> data.lang.change_book
					<[r:0 transform: translateY({menu_icons_transform}%) translateX({settingsIconTransform!}px)] @click=toggleSettingsMenu>
						<svg enable-background="new 0 0 24 24" height="24" viewBox="0 0 24 24" width="24">
							<title> data.lang.other
							<g>#
								<path d="M19.14,12.94c0.04-0.3,0.06-0.61,0.06-0.94c0-0.32-0.02-0.64-0.07-0.94l2.03-1.58c0.18-0.14,0.23-0.41,0.12-0.61 l-1.92-3.32c-0.12-0.22-0.37-0.29-0.59-0.22l-2.39,0.96c-0.5-0.38-1.03-0.7-1.62-0.94L14.4,2.81c-0.04-0.24-0.24-0.41-0.48-0.41 h-3.84c-0.24,0-0.43,0.17-0.47,0.41L9.25,5.35C8.66,5.59,8.12,5.92,7.63,6.29L5.24,5.33c-0.22-0.08-0.47,0-0.59,0.22L2.74,8.87 C2.62,9.08,2.66,9.34,2.86,9.48l2.03,1.58C4.84,11.36,4.8,11.69,4.8,12s0.02,0.64,0.07,0.94l-2.03,1.58 c-0.18,0.14-0.23,0.41-0.12,0.61l1.92,3.32c0.12,0.22,0.37,0.29,0.59,0.22l2.39-0.96c0.5,0.38,1.03,0.7,1.62,0.94l0.36,2.54 c0.05,0.24,0.24,0.41,0.48,0.41h3.84c0.24,0,0.44-0.17,0.47-0.41l0.36-2.54c0.59-0.24,1.13-0.56,1.62-0.94l2.39,0.96 c0.22,0.08,0.47,0,0.59-0.22l1.92-3.32c0.12-0.22,0.07-0.47-0.12-0.61L19.14,12.94z M12,15.6c-1.98,0-3.6-1.62-3.6-3.6 s1.62-3.6,3.6-3.6s3.6,1.62,3.6,3.6S13.98,15.6,12,15.6z">
						<p> data.lang.other


			if loading
				<loading-animation[position: fixed; top: 50%; left: 50%;]>


			if settings.verse_picker
				<section.verse_picker.filters [z-index: 100] .show=(show_verse_picker || show_parallel_verse_picker)>
					<.flex>
						<h1[margin: 0 auto;font-size: 1.3em; line-height: 1;]> data.lang.choose_verse
						<svg[m: 0 8px].close_search @click=hideVersePicker() viewBox="0 0 20 20">
							<title> data.lang.close
							<path d=svg_paths.close>
					<[m: 0].list_of_chapters.show_list_of_chapters>
						if show_verse_picker
							for i in [0 ... verses.length]
								<a.chapter_number @click=goToVerse(i + 1)> i + 1
						elif show_parallel_verse_picker
							for j in [0 ... parallel_verses.length]
								<a.chapter_number @click=goToVerse('p' + (j + 1))> j + 1


			if welcome != 'false'
				<section#welcome.history.filters [right: 3vw top: auto bottom: 2% visibility: visible transform: none]>
					<h1[margin: 0 auto 12px; font-size: 1.2em]> data.lang.welcome
					<p> data.lang.welcome_msg, <span.emojify> ' 😉'
					<button @click=welcomeOk> "Ok ", <span.emojify> '👌🏽'


			if page_search.d
				<section#page_search [background-color: {page_search.matches.length || !page_search.query.length ? 'var(--background-color)' : 'firebrick'}]>
					<input#pagesearch.search bind=page_search.query @input.pageSearch @keydown.enter.pageSearchKeydownManager [border-top-right-radius: 0;border-bottom-right-radius: 0] placeholder=data.lang.find_in_chapter>
					<button.arrow @click=prevOccurence() title=data.lang.prev [border-radius: 0]>
						<svg width="16" height="10" viewBox="0 0 8 5" [transform: rotate(180deg)]>
							<title> data.lang.prev
							<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
					<button.arrow @click=nextOccurence() title=data.lang.next [border-top-left-radius: 0; border-bottom-left-radius: 0; border-top-right-radius: 4px; border-bottom-right-radius: 4px]>
						<svg width="16" height="10" viewBox="0 0 8 5">
							<title> data.lang.next
							<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
					if page_search.matches.length
						<p> page_search.current_occurence + 1, ' / ', page_search.matches.length
					elif page_search.query.length != 0 && window.innerWidth > 640
						<p> data.lang.phrase_not_found, '!'
						<title> data.lang.delete
						<path[m:auto] d=svg_paths.close>

					<svg.close_search [ml: auto] @click=clearSpace viewBox="0 0 20 20">
						<title> data.lang.close
						<path[m: auto] d=svg_paths.close>
