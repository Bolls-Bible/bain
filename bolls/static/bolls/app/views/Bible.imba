import *  as BOOKS from "./translations_books.json"
import languages from "./languages.json"
import './Profile'
import "./loading.imba"
import "./downloads.imba"
import "./rich_text_editor"
import "./colorPicker.imba"
import './search-text-as-html'
import "./note-up"
import "./menu-popup"
import './orderable-list'
import {thanks_to} from './thanks_to'
import {svg_paths} from "./svg_paths"
import {scrollToY} from './smooth_scrolling'

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
# let isTablet = (isIPad || (isMobile && !isSmallScreen))
let MOBILE_PLATFORM = no

const applemob\boolean = window.navigator.platform.charAt(0) == 'i'

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
	translation: 'YLT'
	book: 1
	chapter: 1
	font:
		size: 20
		family: "sans, sans-serif"
		name: "Sans Serif"
		line-height: 1.8
		weight: 400
		max-width: 30
		align: ''
	verse_number: yes
	verse_break: no
	verse_picker: no
	transitions: yes
	name_of_book: ''
	filtered_books: []
	parallel_synch: yes

	get light
		if this.theme == 'dark' or this.theme == 'black'
			return 'dark'
		return 'light'



# Detect dark mode
if window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches
	settings.theme = 'dark'
	settings.accent = 'gold'


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
let choosen_parallel = no
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
let max_header_font = 0
let show_accents = no
let show_language_of = ''
let show_verse_picker = no
let show_parallel_verse_picker = no
let show_share_box = no
let what_to_show_in_pop_up_block = ''
let choosen_for_comparison = []
let comparison_parallel = []
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
		name: "Sans Serif",
		code: "sans, sans-serif"
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
		name: "Tinos",
		code: "'Tinos', serif"
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
	prop search = {suggestions:{}}
	#main_header_arrow_size = ''

	def setup
		# # # Setup some global events
		# Detect change of dark/light mode
		window.matchMedia('(prefers-color-scheme: dark)')
		.addEventListener('change', do |event|
			if event.matches
				changeTheme('dark')
			else
				changeTheme('light')
		)

		# Focus the reader tag in order to enable keyboard navigation
		document.onfocus = do
			if document.getSelection().toString().length == 0
				focus!

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
			### ### ### ### ### ### ### ### ### ### ### ###
			changeTheme(settings.theme)

		else
			changeTheme(settings.theme)

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
		if !verses.length
			getChapter(settings.translation, settings.book, settings.chapter)
		if getCookie('parallel_display') == 'true'
			toggleParallelMode!
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
		history = JSON.parse(getCookie("history")) || []
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
			search_div: no
			search_input: ''
			search_result_header: ''
			show_filters: no
			counter: 50
			results:0
			filter: 0
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
		else
			if settings.translation != translation || !books.length
				books = BOOKS[translation]

	def saveToHistory translation, book, chapter, verse, parallel
		if data.user.username && window.navigator.onLine
			history = await loadData('/get-history')

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
			.catch(do |e| console.log(e))

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
		router.go(window.location.origin + '/' + translation + '/' + book + '/' + chapter + '/')
		getChapter translation, book, chapter, verse

	def getChapter translation, book, chapter, verse
		let changeParallel = yes
		const does_the_chapter_exist_in_this_translation = theChapterExistInThisTranslation(translation, book, chapter)
		unless does_the_chapter_exist_in_this_translation
			book = settings.book
			chapter = settings.chapter
			changeParallel = no

		# const locations_are_different = "/{translation}/{book}/{chapter}/" != window.location.pathname
		const the_same_chapter = translation == settings.translation && book == settings.book && chapter == settings.chapter

		if !the_same_chapter or !verses.length
			loading = yes
			switchTranslation translation
			clearSpace()
			document.title = nameOfBook(book, translation) + ' ' + chapter + ' ' + translations.find(do |element| element.short_name == translation).full_name + " Bolls Bible"
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
			let url = "/get-chapter/" + translation + '/' + book + '/' + chapter + '/'
			try
				verses = []
				imba.commit()
				if data.db_is_available && data.downloaded_translations.indexOf(translation) != -1
					verses = await data.getChapterFromDB(translation, book, chapter, verse)
				else
					verses = await loadData(url)
				loading = no
				imba.commit()

			catch error
				loading = no
				imba.commit()
				console.error('Error: ', error)
				if window.navigator.onLine
					data.showNotification('error')

			if settings.parallel_synch && settingsp.display && changeParallel
				getParallelText settingsp.translation, book, chapter, verse, yes
			if data.user.username then getBookmarks("/get-bookmarks/" + translation + '/' + book + '/' + chapter + '/', 'bookmarks')
		clearSpace!
		window.on_pops_tate = no
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


	def getParallelText translation, book, chapter, verse, caller
		let changeParallel = yes
		const does_the_chapter_exist_in_this_translation = theChapterExistInThisTranslation(translation, book, chapter)
		unless does_the_chapter_exist_in_this_translation
			book = settingsp.book
			chapter = settingsp.chapter
			changeParallel = no

		if !(translation == settingsp.translation && book == settingsp.book && chapter == settingsp.chapter) || !parallel_verses.length || !settingsp.display
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
			let url = "/get-chapter/" + translation + '/' + book + '/' + chapter + '/'
			parallel_verses = []
			try
				if data.db_is_available && data.downloaded_translations.indexOf(translation) != -1
					parallel_verses = await data.getChapterFromDB(translation, book, chapter, verse)
				else
					parallel_verses = await loadData(url)
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
			else
				setTimeout(&, 100) do
					chapter_headers.fontsize2 = 2
					scrollToY($secondparallel,0)
			if !window.on_pops_tate && verses && !verse && settingsp.display
				show_parallel_verse_picker = true

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
				let topScroll = verse.offsetTop
				if (isIPad or isIOS) and page_search.d
					topScroll -= iOS_keaboard_height
				else
					topScroll -= (window.innerHeight * 0.05)

				if settingsp.display
					# verse.parentNode.parentNode.scroll({left:0, top: topScroll, behavior: 'smooth'})
					scrollToY(verse.parentNode.parentNode, topScroll)
				else
					scrollToY(self, topScroll)
				if highlight then highlightLinkedVerses(id, endverse)
			else findVerse(id, endverse, highlight)

	def highlightLinkedVerses verse, endverse
		if isIOS
			return
		setTimeout(&, 250) do
			const versenode = document.getElementById(verse)
			if versenode
				if endverse
					let nodes = []
					for id in [verse..endverse]
						if id <= verses.length
							nodes.push document.getElementById(id)
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
					if window.getSelection
						const window_selection = window.getSelection()
						const selection_range = document.createRange()
						selection_range.selectNodeContents(versenode)
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
			return

		# Clean all the variables in order to free space around the text
		bible_menu_left = -300
		settings_menu_left = -300
		search.search_div = no
		onzone = no
		inzone = no
		store.show_history = no
		search.filter = no
		search.show_filters = no
		search.counter = 50
		choosen = []
		choosenid = []
		addcollection = no
		store.show_color_picker = no
		show_collections = no
		choosen_parallel = no
		store.show_fonts = no
		show_language_of = ''
		show_translations_for_comparison = no
		show_parallel_verse_picker = no
		show_verse_picker = no
		show_share_box = no
		choosen_categories = []

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
			range.setStart(node.firstChild, lastIndex - page_search.query.length)	# Start at first character of query
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

	def toggleParallelMode
		let parallel = !settingsp.display
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
		searchSuggestions!
		setTimeout(&, 300) do $generalsearch.select!

	def getSearchText e
		# Clear the searched text to preserver the request for breaking
		let query = search.search_input

		# If the query is long enough and it is different from the previous query -- do the search again.
		if search.search_input.length > 2 && (search.search_result_header != query || !search.search_div)
			clearSpace!
			$generalsearch.blur!
			popUp 'search'
			search.search_result_header = ''
			loading = yes

			search.translation = searchTranslation!
			const url = '/search/' + search.translation + '/?search=' + window.encodeURIComponent(query) + '&match_case=' + search.match_case + '&match_whole=' + search.match_whole

			search_verses = {}
			try
				search_verses = await loadData(url)
				search.bookid_of_results = []
				for verse in search_verses
					if !search.bookid_of_results.find(do |element| return element == verse.book)
						search.bookid_of_results.push verse.book
			catch error
				console.error error
				if data.db_is_available && data.downloaded_translations.indexOf(search.translation) != -1
					search_verses = await data.getSearchedTextFromStorage(search)
					search.bookid_of_results = []
					for verse in search_verses
						if !search.bookid_of_results.find(do |element| return element == verse.book)
							search.bookid_of_results.push verse.book

			search.results = 0
			for result in search_verses
				search.results += (result.text.match(/<mark>/g) || []).length
			closeSearch!
			imba.commit!


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


	def searchTranslation
		if settingsp.edited_version == settingsp.translation && settingsp.display
			return settingsp.edited_version
		return settings.translation


	def addFilter book
		page_search.matches = []
		page_search.rects = []
		search.filter = book
		search.show_filters = no
		search.counter = 50

	def dropFilter
		search.filter = ''
		search.show_filters = no
		search.counter = 50

	def getFilteredASearchVerses
		if search.filter
			return search_verses.filter(do |verse| verse.book == search.filter)
		else
			return search_verses



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
			collections += category.trim()
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
		store.show_history = !store.show_history
		settings_menu_left = -300
		if store.show_history && data.user.username && window.navigator.onLine
			history = await loadData('/get-history')
			history = JSON.parse(history)
			imba.commit!

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

	def toggleVerseNumber
		settings.verse_number = !settings.verse_number
		setCookie('verse_number', settings.verse_number)

	def fixDrawers
		fixdrawers = !fixdrawers
		setCookie("fixdrawers", fixdrawers)

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
				scrollToY($compare_body, 0)
				loading = no
				imba.commit()
			)
			.catch(do |error|
				console.error error
				loading = no
				data.showNotification('error'))
		else
			compare_translations.splice(compare_translations.indexOf(translation.short_name), 1)
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

	### Used only for books filtering ###
	# Compute a search relevance score for an item.
	def scoreSearch item, search_query
		item = item.toLowerCase!
		search_query = search_query.toLowerCase!
		let score = 0
		let p = 0 # Position within the `item`
		# Look through each character of the search string, stopping at the end(s)...

		for i in [0 ... search_query.length]
			# Figure out if the current letter is found in the rest of the `item`.
			const index = item.indexOf(search_query[i], p)
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
				const score = scoreSearch(book.name, store.book_search)
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

	def saveCompareChanges arr
		log arr
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
		if e.target.classList.contains('ref--firstparallel')
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
					if window.innerWidth >= 1024
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
		if settingsp.display && settingsp.edited_version == settingsp.translation
			settingsp.filtered_books = filteredBooks('parallel_books')
		else
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
		elif document.getSelection().isCollapsed && Math.abs(touch.dy) < 36 && !search.search_div && !store.show_history && !choosenid.length
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

	def tDir translation
		if translation in ['WLC', 'WLCC', 'POV']
			return 'rtl'
		return 'ltr'

	def layerHeight parallel
		if parallel
			return $secondparallel.clientHeight
		else
			if settingsp.display
				return $firstparallel.clientHeight
			return $main.clientHeight

	def layerWidth parallel
		if parallel
			return $secondparallel.clientWidth
		else
			if settingsp.display
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
		if data.translations_in_downloading.find(do |tr| return tr == translation.short_name)
			return 'processing'
		elif data.downloaded_translations.indexOf(translation.short_name) != -1
			return 'delete'
		else
			return 'download'

	def offlineTranslationAction tr
		if data.translations_in_downloading.find(do |translation| return translation == tr.short_name)
			return
		elif data.downloaded_translations.indexOf(tr.short_name) != -1
			data.deleteTranslation(tr.short_name)
		else
			data.downloadTranslation(tr.short_name)


	def render
		if applemob
			iOS_keaboard_height = Math.abs(inner_height - window.innerHeight)

		<self .display_none=hideReader! @scroll=triggerNavigationIcons @mousemove=mousemove .fixscroll=(what_to_show_in_pop_up_block or inzone or onzone)>
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

				if show_list_of_translations
					<div[m:16px 0 @off:0 p:8px h:auto max-height:100% @off:0px o@off:0 ofy:scroll @off:hidden -webkit-overflow-scrolling:touch pb:256px @off:0 y@off:-16px] ease>
						for language in languages
							<div $key=language.language>
								<p.book_in_list[justify-content:start] .pressed=(language.language == show_language_of) .selected=(language.translations.find(do |translation| currentTranslation(translation.short_name))) @click=showLanguageTranslations(language.language)>
									language.language
									<svg.arrow_next[margin-left:auto min-width:16px] width="16" height="10" viewBox="0 0 8 5">
										<title> data.lang.open
										<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
								if language.language == show_language_of
									<ul [o@off:0 m:0 0 16px @off:-24px 0 24px transition-timing-function:quad h@off:0px of:hidden] dir="auto" ease>
										let no_translation_downloaded = yes
										for translation in language.translations
											if window.navigator.onLine || data.downloaded_translations.indexOf(translation.short_name) != -1
												no_translation_downloaded = no
												<li.book_in_list .selected=currentTranslation(translation.short_name) [display: flex]>
													<span @click=changeTranslation(translation.short_name)>
														<b> translation.short_name
														', '
														translation.full_name
													if translation.info then <a href=translation.info title=translation.info target="_blank" rel="noreferrer">
														<svg[size:20px min-width:20px min-height:20px ml:16px] viewBox="0 0 24 24">
															<title> translation.info
															<path d="M11 7h2v2h-2zm0 4h2v6h-2zm1-9C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z">
										if no_translation_downloaded
											<p.book_in_list> data.lang["no_translation_downloaded"]


				<$books.books-container dir="auto" .lower=(settingsp.display) [pb: 256px pt:{iOS_keaboard_height ? iOS_keaboard_height * 0.8 : 0}px]>
					<>
						if settingsp.display && settingsp.edited_version == settingsp.translation
							<>
								for book in settingsp.filtered_books
									<div $key=book.bookid>
										<p.book_in_list dir="auto" .selected=(book.bookid == settingsp.book) @click=showChapters(book.bookid)> book.name
										if book.bookid == show_chapters_of
											<ul[o@off:0 m:0 0 16px @off:-24px 0 24px transition-timing-function:quad h@off:0px of:hidden] dir="auto" ease>
												for i in [0 ... book.chapters]
													<li.chapter_number .selected=(i + 1 == settingsp.chapter && book.bookid==settingsp.book) @click=getParallelText(settingsp.translation, book.bookid, i+1)> i+1
							if !settingsp.filtered_books.length
								<p.book_in_list [white-space: pre]> '(ಠ╭╮ಠ)  ¯\\_(ツ)_/¯  ノ( ゜-゜ノ)'
						else
							<>
								for book in settings.filtered_books
									<div $key=book.bookid>
										<p.book_in_list dir="auto" .selected=(book.bookid == settings.book) @click=showChapters(book.bookid)> book.name
										if book.bookid == show_chapters_of
											<ul[o@off:0 m:0 0 16px @off:-24px 0 24px transition-timing-function:quad h@off:0px of:hidden] dir="auto" ease>
												for i in [0 ... book.chapters]
													<li.chapter_number .selected=(i + 1 == settings.chapter && book.bookid == settings.book) @click=getText(settings.translation, book.bookid, i+1) > i+1
							if !settings.filtered_books.length
								<p.book_in_list [white-space: pre]> '(ಠ╭╮ಠ)  ¯\\_(ツ)_/¯  ノ( ゜-゜ノ)'
				<input$bookssearch.search @keyup=filterBooks bind=store.book_search type="text" placeholder=data.lang.search aria-label=data.lang.search> data.lang.search
				<svg id="close_book_search" @click=(store.book_search = '', $bookssearch.focus(), filterBooks()) viewBox="0 0 20 20">
					<title> data.lang.delete
					<path[m: auto] d=svg_paths.close>


			<div[w:2vw w:min(32px, max(16px, 2vw)) h:100% pos:sticky t:0 bg@hover:#8881 o:0 @hover:1 d:flex ai:center jc:center cursor:pointer transform:translateX({bibleIconTransform(yes)}px) zi:{what_to_show_in_pop_up_block ? -1 : 2}] @click=toggleBibleMenu @touchstart=slidestart @touchmove=openingdrawer @touchend=slideend @touchcancel=slideend>
				<svg .arrow_next=!bibleIconTransform(yes) .arrow_prev=bibleIconTransform(yes) [fill:$acc-color] width="16" height="10" viewBox="0 0 8 5">
					<title> data.lang.change_book
					<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

			<main$main .main [pos:{page_search.d ? 'static' : 'relative'}] @touchstart=slidestart @touchmove=openingdrawer @touchend=slideend @touchcancel=slideend .parallel_text=settingsp.display [font-family: {settings.font.family} font-size: {settings.font.size}px line-height:{settings.font.line-height} font-weight:{settings.font.weight} text-align: {settings.font.align}]>
				<section$firstparallel .parallel=settingsp.display @scroll=changeHeadersSizeOnScroll dir=tDir(settings.translation) [margin: auto; max-width: {settings.font.max-width}em]>
					for rect in page_search.rects when rect.mathcid.charAt(0) != 'p' and what_to_show_in_pop_up_block == ''
						<.{rect.class} id=rect.matchid [top: {rect.top}px; left: {rect.left}px; width: {rect.width}px; height: {rect.height}px]>
					if verses.length
						<header[h: 0 mt:4em zi:1] @click=toggleBibleMenu()>
							#main_header_arrow_size = "min(64px, max({max_header_font}em, {chapter_headers.fontsize1}em))"
							<h1[lh:1 m: 0 ff: {settings.font.family} fw: {settings.font.weight + 200} fs:max({max_header_font}em, {chapter_headers.fontsize1}em) d@md:flex ai@md:center jc@md:space-between direction:ltr] title=translationFullName(settings.translation)>
								<a.arrow @click.prevent.stop.prevChapter() [d@lt-md:none max-height:{#main_header_arrow_size} max-width:{#main_header_arrow_size} min-height:{#main_header_arrow_size} min-width:{#main_header_arrow_size}] title=data.lang.prev href="{prevChapterLink()}">
									<svg.arrow_prev width="16" height="10" viewBox="0 0 8 5">
										<title> data.lang.prev
										<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
								settings.name_of_book, ' ', settings.chapter

								<a.arrow @click.prevent.stop.nextChapter() [d@lt-md:none max-height:{#main_header_arrow_size} max-width:{#main_header_arrow_size} min-height:{#main_header_arrow_size} min-width:{#main_header_arrow_size}] title=data.lang.next href="{nextChapterLink()}">
									<svg.arrow_next width="16" height="10" viewBox="0 0 8 5">
										<title> data.lang.next
										<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
						<p[mb:1em p: 0 8px o:0 lh:1 ff: {settings.font.family} fw: {settings.font.weight + 200} fs: {settings.font.size * 2}px]> settings.name_of_book, ' ', settings.chapter
						<article[text-indent: {settings.verse_number ? 0 : 2.5}em]>
							for verse in verses
								let bukmark = getBookmark(verse.pk, 'bookmarks')
								let super_style = "padding-bottom:{0.8 * settings.font.line-height}em;padding-top:{settings.font.line-height - 1}em"

								if settings.verse_number
									unless settings.verse_break
										<span> ' '
									<span.verse style=super_style @click=goToVerse(verse.verse)> '\u2007\u2007\u2007' + verse.verse + "\u2007"
								else
									<span> ' '
								<span innerHTML=verse.text
								 		id=verse.verse
										@click=addToChosen(verse.pk, verse.verse, 'first')
										[background-image: {getHighlight(verse.pk, 'bookmarks')}]
									>
								if bukmark
									if bukmark.collection || bukmark.note
										<note-up style=super_style parallelMode=settingsp.display bookmark=bukmark containerWidth=layerWidth(no) containerHeight=layerHeight(no)>
											<svg viewBox="0 0 20 20" alt=data.lang.note>
												<title> data.lang.note
												<path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2zm2 0v15l6-3 6 3V2H4z">

								if verse.comment
									<note-up style=super_style parallelMode=settingsp.display bookmark=verse.comment containerWidth=layerWidth(no) containerHeight=layerHeight(no)>
										<span[c:$acc-color @hover:$acc-color-hover]> '✦'

								if settings.verse_break
									<br>
									unless settings.verse_number
										<span> '	'
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
						<p.in_offline>
							data.lang.unexisten_chapter
							<br>
							<a.reload @click=(do window.location.reload(yes))> data.lang.reload

				<section$secondparallel.parallel @scroll=changeHeadersSizeOnScroll dir=tDir(settingsp.translation) [margin: auto max-width: {settings.font.max-width}em display: {settingsp.display ? 'inline-block' : 'none'}]>
					for rect in page_search.rects when rect.mathcid.charAt(0) == 'p'
						<.{rect.class} [top: {rect.top}px; left: {rect.left}px; width: {rect.width}px; height: {rect.height}px]>
					if parallel_verses.length
						<header[h: 0 mt:4em zi:1] @click=toggleBibleMenu(yes)>
							<h1[lh:1 m: 0 ff: {settings.font.family} fw: {settings.font.weight + 200} fs: {chapter_headers.fontsize2}em] title=translationFullName(settingsp.translation)>
								settingsp.name_of_book, ' ', settingsp.chapter
						<p[mb:1em p: 0 8px o:0 lh:1 ff: {settings.font.family} fw: {settings.font.weight + 200} fs: {settings.font.size * 2}px]> settingsp.name_of_book, ' ', settingsp.chapter
						<article[text-indent: {settings.verse_number ? 0 : 2.5}em]>
							for parallel_verse in parallel_verses
								let super_style = "padding-bottom:{0.8 * settings.font.line-height}em;padding-top:{settings.font.line-height - 1}em"
								let bukmark = getBookmark(parallel_verse.pk, 'parallel_bookmarks')

								if settings.verse_number
									unless settings.verse_break
										<span> ' '
									<span.verse style=super_style @click=goToVerse(parallel_verse.verse)> '\u2007\u2007\u2007', parallel_verse.verse, "\u2007"
								else
									<span> ' '
								<span innerHTML=parallel_verse.text
									id="p{parallel_verse.verse}"
									@click=addToChosen(parallel_verse.pk, parallel_verse.verse, 'second')
									[background-image: {getHighlight(parallel_verse.pk, 'parallel_bookmarks')}]>
								if bukmark
									if bukmark.collection || bukmark.note
										<note-up style=super_style parallelMode=settingsp.display bookmark=bukmark containerWidth=layerWidth(no) containerHeight=layerHeight(no)>
											<svg viewBox="0 0 20 20" alt=data.lang.note>
												<title> data.lang.note
												<path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2zm2 0v15l6-3 6 3V2H4z">

								if parallel_verse.comment
									<note-up style=super_style parallelMode=settingsp.display bookmark=parallel_verse.comment containerWidth=layerWidth(yes) containerHeight=layerHeight(yes)>
										<span[c:$acc-color @hover:$acc-color-hover]> '✦'

								if settings.verse_break
									<br>
									unless settings.verse_number
										<span> '	'
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

			<div[w:2vw w:min(32px, max(16px, 2vw)) h:100% pos:sticky t:0 bg@hover:#8881 o:0 @hover:1 d:flex ai:center jc:center cursor:pointer transform:translateX({settingsIconTransform(yes)}px) zi:{what_to_show_in_pop_up_block ? -1 : 2}] @click=toggleSettingsMenu @touchstart=slidestart @touchmove=openingdrawer @touchend=slideend @touchcancel=slideend>
				<svg .arrow_next=settingsIconTransform(yes) .arrow_prev=!settingsIconTransform(yes) [fill:$acc-color] width="16" height="10" viewBox="0 0 8 5">
					<title> data.lang.other
					<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">


			<aside @touchstart=slidestart @touchend=closedrawersend @touchcancel=closedrawersend @touchmove=closingdrawer style="right:{MOBILE_PLATFORM ? settings_menu_left : settings_menu_left ? settings_menu_left : settings_menu_left + 12}px;{boxShadow(settings_menu_left)}{(onzone || inzone) ? 'transition:none;' : ''}">
				<p[fs:24px h:32px d:flex jc:space-between ai:center]>
					data.lang.other
					<.current_accent .enlarge_current_accent=show_accents>
						<.visible_accent @click=(do show_accents = !show_accents)>
						<.accents .show_accents=show_accents>
							for accent in accents when accent.name != settings.accent
								<.accent @click=changeAccent(accent.name) [background-color: {settings.theme == 'dark' ? accent.light : accent.dark}]>
				<[d:flex m:24px 0 ai:center $fill-on-hover:$c @hover:$acc-color-hover]>
					if data.getUserName()
						<svg.helpsvg route-to='/profile/' xmlns="http://www.w3.org/2000/svg" height="32px" viewBox="0 0 24 24" width="32px">
							<title> data.getUserName()
							<path d="M0 0h24v24H0z" fill="none">
							<path d="M18 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zM6 4h5v8l-2.5-1.5L6 12V4z">
						<a.username [w:100%] route-to='/profile/'> data.getUserName()
						<a.prof_btn @click.stop.prevent=(window.location = "/accounts/logout/") href="/accounts/logout/"> data.lang.logout
					else
						<a.prof_btn @click.stop.prevent=(window.location = "/accounts/login/") href="/accounts/login/"> data.lang.login
						<a.prof_btn.signin @click.stop.prevent=(window.location = "/signup/") href="/signup/"> data.lang.signin
				<button.btnbox.cbtn.aside_button @click=turnGeneralSearch>
					<svg.helpsvg [p:0 4px] viewBox="0 0 12 12" width="24px" height="24px">
						<title> data.lang.find_in_chapter
						<path d=svg_paths.search>
					data.lang.bible_search
				<button.btnbox.cbtn.aside_button @click=pageSearch()>
					<svg.helpsvg [p:0 4px] viewBox="0 0 12 12" width="24px" height="24px">
						<title> data.lang.find_in_chapter
						<path d=svg_paths.search>
					data.lang.find_in_chapter
				<button.btnbox.cbtn.aside_button @click=turnHistory>
					<svg.helpsvg width="24" height="24" viewBox="0 0 24 24">
						<title> data.lang.history
						<path d="M0 0h24v24H0z" fill="none">
						<path d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z">
					data.lang.history

				<menu-popup bind=store.show_themes>
					<.btnbox.cbtn.aside_button.popup_menu_box [d:flex transform@important:none ai:center pos:relative] @click=(do store.show_themes = !store.show_themes)>
						<svg[size:24px ml:4px mr:16px] xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
							<title> 'Clair de lune'
							<path d="M167.02 309.34c-40.12 2.58-76.53 17.86-97.19 72.3-2.35 6.21-8 9.98-14.59 9.98-11.11 0-45.46-27.67-55.25-34.35C0 439.62 37.93 512 128 512c75.86 0 128-43.77 128-120.19 0-3.11-.65-6.08-.97-9.13l-88.01-73.34zM457.89 0c-15.16 0-29.37 6.71-40.21 16.45C213.27 199.05 192 203.34 192 257.09c0 13.7 3.25 26.76 8.73 38.7l63.82 53.18c7.21 1.8 14.64 3.03 22.39 3.03 62.11 0 98.11-45.47 211.16-256.46 7.38-14.35 13.9-29.85 13.9-45.99C512 20.64 486 0 457.89 0z">
						state.lang.theme
						if store.show_themes
							<.popup_menu.themes_popup [l:0 y@off:-32px o@off:0] ease>
								<button.butt[bgc:black c:white bdr:32px solid white] @click=changeTheme('black')> 'Black'
								<button.butt[bgc:rgb(4, 6, 12) c:rgb(255, 238, 238) bdr:32px solid rgb(255, 238, 238)] @click=changeTheme('dark')> data.lang.nighttheme
								<button.butt[bgc:#f1f1f1 c:black bdr:32px solid black] @click=changeTheme('gray')> 'Gray'
								<button.butt[bgc:rgb(235, 219, 183) c:rgb(46, 39, 36) bdr:32px solid rgb(46, 39, 36)] @click=changeTheme('sepia')> 'Sepia'
								<button.butt[bgc:rgb(255, 238, 238) c:rgb(4, 6, 12) bdr:32px solid rgb(4, 6, 12)] @click=changeTheme('light')> data.lang.lighttheme
								<button.butt[bgc:white c:black bdr:32px solid black] @click=changeTheme('white')> 'White'

				<.btnbox>
					<button[p:12px fs:20px].cbtn @click=decreaseFontSize title=data.lang.decrease_font_size> "B-"
					<button[p:8px fs:24px].cbtn @click=increaseFontSize title=data.lang.increase_font_size> "B+"
				<.btnbox>
					<button.cbtn [p:8px fs:24px fw:100] @click=changeFontWeight(-100) title=data.lang.decrease_font_weight> "B"
					<button.cbtn [p:8px fs:24px fw:900] @click=changeFontWeight(100) title=data.lang.increase_font_weight> "B"
				<.btnbox>
					<svg.cbtn @click.changeLineHeight(no) viewBox="0 0 38 14" fill="context-fill" [p:16px 0]>
						<title> data.lang.decrease_line_height
						<rect x="0" y="0" width="28" height="2">
						<rect x="0" y="6" width="38" height="2">
						<rect x="0" y="12" width="18" height="2">
					<svg.cbtn @click.changeLineHeight(yes) viewBox="0 0 38 24" fill="context-fill" [p:10px 0]>
						<title> data.lang.increase_line_height
						<rect x="0" y="0" width="28" height="2">
						<rect x="0" y="11" width="38" height="2">
						<rect x="0" y="22" width="18" height="2">
				if window.chrome
					<.btnbox>
						<svg.cbtn @click=changeAlign(yes) viewBox="0 0 20 20" [p:10px 0]>
							<title> data.lang.auto_align
							<path d="M1 1h18v2H1V1zm0 8h18v2H1V9zm0 8h18v2H1v-2zM1 5h12v2H1V5zm0 8h12v2H1v-2z">
						<svg.cbtn @click=changeAlign(no) viewBox="0 0 20 20" [p:10px 0]>
							<title> data.lang.align_justified
							<path d="M1 1h18v2H1V1zm0 8h18v2H1V9zm0 8h18v2H1v-2zM1 5h18v2H1V5zm0 8h18v2H1v-2z">
				if window.innerWidth > 639
					<.btnbox>
						<svg.cbtn @click=changeMaxWidth(no) width="42" height="16" viewBox="0 0 42 16" fill="context-fill" [p: calc(42px - 28px) 0]>
							<title> data.lang.increase_max_width
							<path d="M14.5,7 L8.75,1.25 L10,-1.91791433e-15 L18,8 L17.375,8.625 L10,16 L8.75,14.75 L14.5,9 L1.13686838e-13,9 L1.13686838e-13,7 L14.5,7 Z">
							<path d="M38.5,7 L32.75,1.25 L34,6.58831647e-15 L42,8 L41.375,8.625 L34,16 L32.75,14.75 L38.5,9 L24,9 L24,7 L38.5,7 Z" transform="translate(33.000000, 8.000000) scale(-1, 1) translate(-33.000000, -8.000000)">
						<svg.cbtn @click=changeMaxWidth(yes) width="44" height="16" viewBox="0 0 44 16" fill="context-fill" [padding: calc(42px - 28px) 0]>
							<title> data.lang.decrease_max_width
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

				<menu-popup bind=data.show_languages>
					<.nighttheme.flex.popup_menu_box @click=(do data.show_languages = !data.show_languages)>
						data.lang.language
						<button.change_language> currentLanguage!
						if data.show_languages
							<.popup_menu [l:0 y@off:-32px o@off:0] ease>
								<button.butt .active_butt=('ukr'==data.language) @click=(do data.setLanguage('ukr'))> "Українська"
								<button.butt .active_butt=('ru'==data.language) @click=(do data.setLanguage('ru'))> "Русский"
								<button.butt .active_butt=('eng'==data.language) @click=(do data.setLanguage('eng'))> "English"
								<button.butt .active_butt=('de'==data.language) @click=(do data.setLanguage('de'))> "Deutsch"
								<button.butt .active_butt=('pt'==data.language) @click=(do data.setLanguage('pt'))> "Portuguese"
								<button.butt .active_butt=('es'==data.language) @click=(do data.setLanguage('es'))> "Español"
				<button.nighttheme.parent_checkbox.flex @click=toggleParallelMode .checkbox_turned=settingsp.display>
					data.lang.parallel
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleParallelSynch .checkbox_turned=settings.parallel_synch>
					data.lang.parallel_synch
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleVersePicker .checkbox_turned=settings.verse_picker>
					data.lang.verse_picker
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleVerseBreak .checkbox_turned=settings.verse_break>
					data.lang.verse_break
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleVerseNumber .checkbox_turned=settings.verse_number>
					data.lang.verse_number
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleTransitions .checkbox_turned=settings.transitions>
					data.lang.transitions
					<p.checkbox> <span>
				<button.nighttheme.parent_checkbox.flex @click=toggleChronorder .checkbox_turned=chronorder>
					data.lang.chronological_order
					<p.checkbox> <span>
				unless MOBILE_PLATFORM
					<button.nighttheme.parent_checkbox.flex @click=fixDrawers .checkbox_turned=fixdrawers>
						data.lang.fixdrawers
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
					<a.help href='https://bohuslav.me/Dictionary/' target='_blank'>
						<span.font_icon> 'א'
						'Dictionary'
				<a.help @click=turnHelpBox>
					<svg.helpsvg aria-hidden="true" width="24" height="24" viewBox="0 0 24 24">
						<title> data.lang.help
						<path fill="none" d="M0 0h24v24H0z">
						<path d="M11 18h2v-2h-2v2zm1-16C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm0-14c-2.21 0-4 1.79-4 4h2c0-1.1.9-2 2-2s2 .9 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5 0-2.21-1.79-4-4-4z">
					data.lang.help
				<a.help @click=turnSupport() id="animated-heart">
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
						unless data.pswv
							<a route-to="/donate/"> '🔥 ', data.lang.donate, " 🐈"
						<a target="_blank" rel="noreferrer" href="https://imba.io"> "Imba"
						<a target="_blank" rel="noreferrer" href="https://docs.djangoproject.com/en/3.0/"> "Django"
						<a target="_blank" href="/static/privacy_policy.html"> "Privacy Policy"
						<a target="_blank" rel="noreferrer" href="http://www.patreon.com/bolls"> "Patreon"
						<a target="_blank" href="/static/disclaimer.html"> "Disclaimer"
						<a target="_blank" rel="noreferrer" href="http://t.me/Boguslavv"> "Hire me"
					<p>
						"©", <time dateTime='2021-11-25T20:41'> "2019"
						"-present Павлишинець Богуслав 🎻 Pavlyshynets Bohuslav"



			if what_to_show_in_pop_up_block.length
				<section [pos:fixed t:0 b:0 r:0 l:0 bgc:#0004 h:100% d:flex jc:center p:14vh 0 @lt-sm:0 o@off:0 visibility@off:hidden zi:{what_to_show_in_pop_up_block == "show_note" ? 1200 : 3}] @click=(do unless state.intouch then clearSpace!) ease>

					<div[pos:relative max-height:72vh @lt-sm:100vh max-width:64em @lt-sm:100% w:80% @lt-sm:100% bgc:$bgc bd:1px solid $acc-bgc-hover @lt-sm:none rd:16px @lt-sm:0 p:12px 24px @lt-sm:12px scale@off:0.75] .height_auto=(!search.search_result_header && what_to_show_in_pop_up_block=='search') @click.stop>

						if what_to_show_in_pop_up_block == 'show_help'
							<article.search_hat>
								<svg.close_search @click=clearSpace() viewBox="0 0 20 20">
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
								<p[color: $acc-color-hover font-size: 0.9em]> data.lang.faqmsg
								<h3> data.lang.content
								<ul>
									for q in data.lang.HB
										<li> <a href="#{q[0]}"> q[0]
									if window.innerWidth >= 1024
										<li> <a href="#shortcuts"> data.lang.shortcuts
								for q in data.lang.HB
									<h3 id=q[0] > q[0]
									<p> q[1]
								if window.innerWidth >= 1024
									<div id="shortcuts">
										<h3> data.lang.shortcuts
										for shortcut in data.lang.shortcuts_list
											<p> <span innerHTML=shortcut>
								<address.still_have_questions>
									data.lang.still_have_questions
									<a target="_blank" href="mailto:bpavlisinec@gmail.com"> " bpavlisinec@gmail.com"

						elif what_to_show_in_pop_up_block == 'show_compare'
							<article.search_hat>
								<svg.close_search @click=clearSpace() viewBox="0 0 20 20">
									<title> data.lang.close
									<path[m: auto] d=svg_paths.close>
								<h1> highlighted_title
								<svg.filter_search @click=(do show_translations_for_comparison = !show_translations_for_comparison) viewBox="0 0 20 20" alt=data.lang.addcollection [stroke:$c stroke-width:2px]>
									<title> data.lang.compare
									<line x1="0" y1="10" x2="20" y2="10">
									<line x1="10" y1="0" x2="10" y2="20">
								if show_translations_for_comparison
									<[z-index: 1100 scale@off:0.75 y@off:-16px o@off:0 visibility@off:hidden] .filters ease>
										if compare_translations.length == translations.length
											<p[padding: 12px 8px]> data.lang.nothing_else
										<div[d:hflex bg:$bgc pos:sticky t:-8px]>
											<input.search [p:0 8px] bind=store.compare_translations_search placeholder=data.lang.search aria-label=data.lang.search [m:2px 8px max-width: calc(100% - 16px)]>
											<svg.close_search [mr:-16px @lt-sm:8px h:42px p:0px] @click=(show_translations_for_comparison = no) viewBox="0 0 20 20">
												<title> data.lang.close
												<path[m: auto] d=svg_paths.close>

										for translation in translations when (!compare_translations.find(do |element| return element == translation.short_name) and filterCompareTranslation translation)
											<a.book_in_list.book_in_filter dir="auto" @click=addTranslation(translation)> translation.short_name, ', ', translation.full_name


							<article$compare_body.search_body [pb: 256px scroll-behavior: auto]>
								<p.total_msg> data.lang.add_translations_msg

								<orderable-list list=comparison_parallel saveCompareChanges=saveCompareChanges>

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
										<path d=svg_paths.loading [marker:none c:#000 of:visible fill:$c]>
								else
									<svg.close_search @click=(do data.clearVersesTable()) viewBox="0 0 12 16" alt=data.lang.delete>
										<title> data.lang.remove_all_translations
										<path fill-rule="evenodd" clip-rule="evenodd" d="M11 2H9C9 1.45 8.55 1 8 1H5C4.45 1 4 1.45 4 2H2C1.45 2 1 2.45 1 3V4C1 4.55 1.45 5 2 5V14C2 14.55 2.45 15 3 15H10C10.55 15 11 14.55 11 14V5C11.55 5 12 4.55 12 4V3C12 2.45 11.55 2 11 2ZM10 14H3V5H4V13H5V5H6V13H7V5H8V13H9V5H10V14ZM11 4H2V3H11V4Z">
							<article.search_body>
								for language in languages
									<div $key=language.language>
										<a.book_in_list dir="auto" [jc: start pl: 0px] .pressed=(language.language == show_language_of) @click=showLanguageTranslations(language.language)>
											language.language
											<svg[ml: auto].arrow_next width="16" height="10" viewBox="0 0 8 5">
												<title> data.lang.open
												<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

										if language.language == show_language_of
											<ul[o@off:0 m:0 0 16px @off:-24px 0 24px transition-timing-function:quad h@off:0px of:hidden] dir="auto" ease>
												let no_translation_downloaded = yes
												for tr in language.translations
													if window.navigator.onLine || data.downloaded_translations.indexOf(tr.short_name) != -1
														no_translation_downloaded = no
														<a[d:flex py:8px pl:8px cursor:pointer bgc@hover:$acc-bgc-hover fill:$c @hover:$acc-color-hover rd:8px] @click=offlineTranslationAction(tr)>
															if data.translations_in_downloading.find(do |translation| return translation == tr.short_name)
																<svg.remove_parallel.close_search.animated_downloading  [fill:inherit] width="16" height="16" viewBox="0 0 16 16">
																	<title> data.lang.loading
																	<path d=svg_paths.loading [marker:none c:#000 of:visible fill:$c]>
															elif data.downloaded_translations.indexOf(tr.short_name) != -1
																<svg.remove_parallel.close_search [fill:inherit]  viewBox="0 0 12 16" alt=data.lang.delete>
																	<title> data.lang.delete
																	<path fill-rule="evenodd" clip-rule="evenodd" d="M11 2H9C9 1.45 8.55 1 8 1H5C4.45 1 4 1.45 4 2H2C1.45 2 1 2.45 1 3V4C1 4.55 1.45 5 2 5V14C2 14.55 2.45 15 3 15H10C10.55 15 11 14.55 11 14V5C11.55 5 12 4.55 12 4V3C12 2.45 11.55 2 11 2ZM10 14H3V5H4V13H5V5H6V13H7V5H8V13H9V5H10V14ZM11 4H2V3H11V4Z">
															else
																<svg.remove_parallel.close_search [fill:inherit]  viewBox="0 0 212.646728515625 159.98291015625">
																	<title> data.lang.download
																	<g transform="matrix(1.5 0 0 1.5 0 128)">
																		<path d=svg_paths.download>
															<span> "{data.lang[translationDownloadStatus(tr)]} {<b> tr.short_name}, {tr.full_name}"

												if no_translation_downloaded
													data.lang["no_translation_downloaded"]
								<.freespace>

						elif what_to_show_in_pop_up_block == 'show_support'
							<article.search_hat>
								<svg.close_search @click=clearSpace() viewBox="0 0 20 20">
									<title> data.lang.close
									<path[m: auto] d=svg_paths.close>
								<h1> data.lang.support
								<a target="_blank" href="mailto:bpavlisinec@gmail.com">
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
								<svg.close_search @click=clearSpace() viewBox="0 0 20 20">
									<title> data.lang.close
									<path[m: auto] d=svg_paths.close>
								<h1> data.lang.note, ', ', highlighted_title
								<svg.save_bookmark [width: 26px] viewBox="0 0 12 16" @click=sendBookmarksToDjango alt=data.lang.create>
									<title> data.lang.create
									<path fill-rule="evenodd" clip-rule="evenodd" d="M12 5L4 13L0 9L1.5 7.5L4 10L10.5 3.5L12 5Z">
							unless isNoteEmpty()
								<p id="note_placeholder"> data.lang.write_something_awesone
							<rich-text-editor bind=store dir="auto">

						else	# search
							if search_verses.length
								if search.show_filters
									<[z-index: 1 scale@off:0.75 y@off:-16px o@off:0 visibility@off:hidden] .filters ease>
										<div[d:hflex bg:$bgc ai:center jc:space-between p:0 8px pos:sticky t:-8px]>
											<p[ws:nowrap mr:8px fs:0.8em fw:bold]> data.lang.addfilter
											<svg.close_search [mr:-16px @lt-sm:0 h:42px p:0px] @click=(search.show_filters = no) viewBox="0 0 20 20">
												<title> data.lang.close
												<path[m: auto] d=svg_paths.close>
										if settingsp.edited_version == settingsp.translation && settingsp.display
											if search.filter then <button.book_in_list @click=dropFilter> data.lang.drop_filter
											<>
												for book in parallel_books
													<button.book_in_list.book_in_filter dir="auto" @click=addFilter(book.bookid)> book.name
										else
											if search.filter then <button.book_in_list @click=dropFilter> data.lang.drop_filter
											for book in books when search.bookid_of_results.find(do |element| return element == book.bookid)
												<button.book_in_list.book_in_filter dir="auto" @click=addFilter(book.bookid)> book.name
							<article.search_hat#gs_hat [pos:relative]>
								<svg.close_search [min-width:24px] @click=closeSearch(true) viewBox="0 0 20 20">
									<title> data.lang.close
									<path[m: auto] d=svg_paths.close>

								<input$generalsearch[w:100% bg:transparent font:inherit c:inherit p:0 8px fs:1.2em min-width:128px bd:none bdb@invalid:1px solid $acc-bgc bxs:none] bind=search.search_input minLength=3 type='text' placeholder=(data.lang.bible_search + ', ' + search.translation) aria-label=data.lang.bible_search @keydown.enter=getSearchText @input=searchSuggestions>

								# TODO LOCALIZE THIS

								<svg.search_option .search_option_on=search.match_case @click=(search.match_case = !search.match_case, setCookie("match_case", search.match_case)) width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg" fill="currentColor">
									<title> data.lang.match_case
									<path d="M8.85352 11.7021H7.85449L7.03809 9.54297H3.77246L3.00439 11.7021H2L4.9541 4H5.88867L8.85352 11.7021ZM6.74268 8.73193L5.53418 5.4502C5.49479 5.34277 5.4554 5.1709 5.41602 4.93457H5.39453C5.35872 5.15299 5.31755 5.32487 5.271 5.4502L4.07324 8.73193H6.74268Z">
									<path d="M13.756 11.7021H12.8752V10.8428H12.8537C12.4706 11.5016 11.9066 11.8311 11.1618 11.8311C10.6139 11.8311 10.1843 11.686 9.87273 11.396C9.56479 11.106 9.41082 10.721 9.41082 10.2412C9.41082 9.21354 10.016 8.61556 11.2262 8.44727L12.8752 8.21631C12.8752 7.28174 12.4974 6.81445 11.7419 6.81445C11.0794 6.81445 10.4815 7.04004 9.94793 7.49121V6.58887C10.4886 6.24512 11.1117 6.07324 11.8171 6.07324C13.1097 6.07324 13.756 6.75716 13.756 8.125V11.7021ZM12.8752 8.91992L11.5485 9.10254C11.1403 9.15983 10.8324 9.26188 10.6247 9.40869C10.417 9.55192 10.3132 9.80794 10.3132 10.1768C10.3132 10.4453 10.4081 10.6655 10.5978 10.8374C10.7912 11.0057 11.0472 11.0898 11.3659 11.0898C11.8027 11.0898 12.1626 10.9377 12.4455 10.6333C12.7319 10.3254 12.8752 9.93685 12.8752 9.46777V8.91992Z">

								<svg.search_option .search_option_on=search.match_whole @click=(search.match_whole = !search.match_whole, setCookie("match_whole", search.match_whole)) width="16" height="16" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg" fill="currentColor">
									<title> data.lang.match_whole
									<path fill-rule="evenodd" clip-rule="evenodd" d="M0 11H1V13H15V11H16V14H15H1H0V11Z">
									<path d="M6.84048 11H5.95963V10.1406H5.93814C5.555 10.7995 4.99104 11.1289 4.24625 11.1289C3.69839 11.1289 3.26871 10.9839 2.95718 10.6938C2.64924 10.4038 2.49527 10.0189 2.49527 9.53906C2.49527 8.51139 3.10041 7.91341 4.3107 7.74512L5.95963 7.51416C5.95963 6.57959 5.58186 6.1123 4.82632 6.1123C4.16389 6.1123 3.56591 6.33789 3.03238 6.78906V5.88672C3.57307 5.54297 4.19612 5.37109 4.90152 5.37109C6.19416 5.37109 6.84048 6.05501 6.84048 7.42285V11ZM5.95963 8.21777L4.63297 8.40039C4.22476 8.45768 3.91682 8.55973 3.70914 8.70654C3.50145 8.84977 3.39761 9.10579 3.39761 9.47461C3.39761 9.74316 3.4925 9.96338 3.68228 10.1353C3.87564 10.3035 4.13166 10.3877 4.45035 10.3877C4.8872 10.3877 5.24706 10.2355 5.52994 9.93115C5.8164 9.62321 5.95963 9.2347 5.95963 8.76562V8.21777Z">
									<path d="M9.3475 10.2051H9.32601V11H8.44515V2.85742H9.32601V6.4668H9.3475C9.78076 5.73633 10.4146 5.37109 11.2489 5.37109C11.9543 5.37109 12.5057 5.61816 12.9032 6.1123C13.3042 6.60286 13.5047 7.26172 13.5047 8.08887C13.5047 9.00911 13.2809 9.74674 12.8333 10.3018C12.3857 10.8532 11.7734 11.1289 10.9964 11.1289C10.2695 11.1289 9.71989 10.821 9.3475 10.2051ZM9.32601 7.98682V8.75488C9.32601 9.20964 9.47282 9.59635 9.76644 9.91504C10.0636 10.2301 10.4396 10.3877 10.8944 10.3877C11.4279 10.3877 11.8451 10.1836 12.1458 9.77539C12.4502 9.36719 12.6024 8.79964 12.6024 8.07275C12.6024 7.46045 12.4609 6.98063 12.1781 6.6333C11.8952 6.28597 11.512 6.1123 11.0286 6.1123C10.5166 6.1123 10.1048 6.29134 9.7933 6.64941C9.48177 7.00391 9.32601 7.44971 9.32601 7.98682Z">

								<svg.close_search [w:24px min-width:24px mr:8px] viewBox="0 0 12 12" width="24px" height="24px" @click=getSearchText>
									<title> data.lang.bible_search
									<path d=svg_paths.search>

								if search_verses.length
									<svg.filter_search [min-width:24px] ease .filter_search_hover=search.show_filters||search.filter @click=(do search.show_filters = !search.show_filters) viewBox="0 0 20 20">
										<title> data.lang.addfilter
										<path d="M12 12l8-8V0H0v4l8 8v8l4-4v-4z">

								if search.suggestions.books
									if search.suggestions.books.length or search.suggestions.translations.length
										<.search_suggestions>
											for book in search.suggestions.books
												<search-text-as-html.book_in_list data={translation:search.suggestions.translation, book:book.bookid, chapter:search.suggestions.chapter, verse:search.suggestions.verse}>
													searchSuggestionText(book)


											for translation in search.suggestions.translations
												<li.book_in_list [display: flex]>
													<span @click=changeTranslation(translation.short_name)>
														<b> translation.short_name
														', '
														translation.full_name

							if search.search_result_header
								<article.search_body id="search_body" @scroll=searchPagination>
									<p.total_msg> search.search_result_header, ': ', search.results, ' / ',  getFilteredASearchVerses().length, ' ', data.lang.totalyresultsofsearch

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
										if search.filter then <div[p:12px 0px ta:center]>
											data.lang.filter_name, ' ', nameOfBook(search.filter, (settingsp.display ? settingsp.edited_version : settings.translation))
											<br>
											<button[d: inline-block; mt: 12px].more_results @click=dropFilter> data.lang.drop_filter
									unless search_verses.length
										<div[display:flex flex-direction:column height:100% justify-content:center align-items:center]>
											<p> data.lang.nothing
											<p[padding:32px 0px 8px]> data.lang.translation, ' ', search.translation
											<button.more_results @click=showTranslations> data.lang.change_translation
									<.freespace>


			if show_collections || show_share_box || choosenid.length
				<section [pos:fixed b:0 l:0 r:0 w:100% bgc:$bgc bdt:1px solid $acc-bgc ta:center p:{show_collections || show_share_box ? "0" : "16px 0"} zi:1100 y@off:100%] ease>
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
						<.mark_grid [pt:0 pb:8px]>
							if addcollection
								<input.newcollectioninput placeholder=data.lang.newcollection id="newcollectioninput" bind=store.newcollection @keydown.enter.addNewCollection(store.newcollection) @keyup.validateNewCollectionInput type="text">
							elif categories.length
								<>
									if categories.length > 8
										<input.search placeholder=data.lang.search bind=store.collections_search [font:inherit c:inherit w:8em m:4px]>
								<>
									for category in categories.filter(do(el) return el.toLowerCase!.indexOf(store.collections_search.toLowerCase!) > -1)
										<p.collection .add_new_collection=(choosen_categories.find(do |element| return element == category)) @click=addNewCollection(category)> category
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
						<.mark_grid[py:8px]>
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
						<p>
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
										<title> data.lang.delete
										<path d=svg_paths.close>
						<div id="addbuttons">
							if show_delete_bookmark
								<div .collection=(window.innerWidth > 475) @click=deleteBookmarks(choosenid) [o@off:0 w@off:0 p@off:0 of@off:hidden mr@off:-4px] ease>
									<svg.close_search viewBox="0 0 12 16" alt=data.lang.delete>
										<title> data.lang.delete
										<path fill-rule="evenodd" clip-rule="evenodd" d="M11 2H9C9 1.45 8.55 1 8 1H5C4.45 1 4 1.45 4 2H2C1.45 2 1 2.45 1 3V4C1 4.55 1.45 5 2 5V14C2 14.55 2.45 15 3 15H10C10.55 15 11 14.55 11 14V5C11.55 5 12 4.55 12 4V3C12 2.45 11.55 2 11 2ZM10 14H3V5H4V13H5V5H6V13H7V5H8V13H9V5H10V14ZM11 4H2V3H11V4Z">
									<p> data.lang.delete
							<div .collection=(window.innerWidth > 475) @click=clearSpace()>
								<svg.close_search viewBox="0 0 20 20" alt=data.lang.close>
									<title> data.lang.close
									<path d=svg_paths.close alt=data.lang.close>
								<p> data.lang.close
							<div .collection=(window.innerWidth > 475) @click=(do show_share_box = yes)>
								<svg.save_bookmark [stroke:none] @click=(do show_share_box = yes) xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24">
									<title> data.lang.share
									<path d="M0 0h24v24H0V0z" fill="none">
									<path d="M16 5l-1.42 1.42-1.59-1.59V16h-1.98V4.83L9.42 6.42 8 5l4-4 4 4zm4 5v11c0 1.1-.9 2-2 2H6c-1.11 0-2-.9-2-2V10c0-1.11.89-2 2-2h3v2H6v11h12V10h-3V8h3c1.1 0 2 .89 2 2z">
								<p> data.lang.share
							<div .collection=(window.innerWidth > 475) @click=copyToClipboard()>
								<svg.save_bookmark viewBox="0 0 561 561" alt=data.lang.copy>
									<title> data.lang.copy
									<path d=svg_paths.copy>
								<p> data.lang.copy
							<div .collection=(window.innerWidth > 475) @click=toggleCompare()>
								<svg.save_bookmark viewBox='0 0 400 400'>
									<title> data.lang.compare
									<path d="m 158.87835,59.714254 c -22.24553,22.942199 -40.6885,42.183936 -40.98426,42.758776 -0.8318,1.61252 -0.20661,2.77591 3.5444,6.59866 5.52042,5.6227 1.07326,9.0169 37.637,-28.724885 17.50924,-18.073765 32.15208,-32.92934 32.53977,-33.012765 2.11329,-0.454845 1.99262,-9.787147 1.99262,154.63098 0,162.70162 0.0852,155.59667 -1.92404,155.16124 -0.4175,-0.0891 -31.30684,-31.67221 -68.64371,-70.1831 -82.516734,-85.113 -79.762069,-82.23881 -79.523922,-82.9759 0.156562,-0.48685 7.785466,-0.64342 40.516819,-0.82856 33.282953,-0.18856 40.451433,-0.33827 41.056163,-0.85598 0.99477,-0.85141 1.07891,-10.82255 0.10651,-12.19963 -1.01499,-1.43197 -104.747791,-1.64339 -106.131194,-0.216 -1.408859,1.45366 -1.422172,108.27345 -0.01065,109.72598 1.061864,1.09597 10.873494,1.39767 11.873689,0.36572 0.405788,-0.41828 0.535724,-10.38028 0.551701,-41.94167 0.01065,-31.23452 0.150173,-41.70737 0.55383,-42.67534 l 0.533593,-1.28109 78.641191,81.10851 c 43.25264,44.609 79.6823,82.26506 80.95505,83.67874 1.27157,1.41482 2.51534,2.57136 2.7635,2.57136 3.82365,0.0993 6.74023,0.19783 10.78264,0.32569 l 2.48223,-2.72678 c 9.56539,-10.51282 158.34672,-163.337 159.13762,-163.46273 1.69462,-0.2697 1.72007,0.33714 1.72678,42.53708 0.007,40.52683 0.0212,41.4788 0.86376,41.94164 1.22845,0.67884 10.78936,0.61599 11.45949,-0.0754 0.94791,-0.97828 0.75087,-109.32029 -0.20024,-110.13513 -0.61027,-0.52227 -9.49349,-0.64912 -53.0551,-0.75425 l -52.32298,-0.128 -0.77536,0.97824 c -1.17177,1.47768 -1.14409,11.36197 0.032,12.46251 0.74235,0.69256 4.25002,0.75654 41.35204,0.75654 22.29752,0 40.6652,0.12915 40.81803,0.28686 0.75194,0.77597 -5.99106,7.88549 -73.9736,77.99435 -74.8598,77.20005 -74.60834,76.94635 -75.706,76.51207 -0.65608,-0.25942 -1.04162,-309.073405 -0.38768,-310.829927 0.51549,-1.385101 3.29625,1.278819 28.18793,26.998083 44.2328,45.702694 38.02575,40.757704 43.65905,34.786424 4.03624,-4.27873 4.21348,-4.55415 3.74602,-5.85812 -0.56235,-1.56794 -81.63283,-85.027265 -82.59319,-85.027265 -0.5123,0 -16.36846,16.023541 -41.27664,41.713088" [stroke-width:20;stroke-miterlimit:4;stroke-opacity:1;stroke-linecap:round;stroke-linejoin:round;paint-order:normal] fill-rule="evenodd">
								<p> data.lang.compare
							<div .collection=(window.innerWidth > 475) @click=makeNote()>
								<svg.save_bookmark .filled=isNoteEmpty() viewBox="0 0 24 24" fill="black" alt=data.lang.note>
									<title> data.lang.note
									<path d="M 9.0001238,20.550118 H 24.00033 V 16.550063 H 13.000179 Z M 16.800231,8.7499555 c 0.400006,-0.400006 0.400006,-1.0000139 0,-1.4000194 L 13.200182,3.7498865 c -0.400006,-0.4000055 -1.000014,-0.4000055 -1.40002,0 L 0,15.550049 v 5.000069 h 5.0000688 z">
								<p> data.lang.note
							<div .collection=(window.innerWidth > 475) @click=turnCollections()>
								<svg.save_bookmark .filled=choosen_categories.length viewBox="0 0 20 20" alt=data.lang.bookmark>
									<title> data.lang.bookmark
									<path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2zm2 0v15l6-3 6 3V2H4z">
								<p> data.lang.bookmark
							<div .collection=(window.innerWidth > 475) @click=sendBookmarksToDjango>
								<svg.save_bookmark viewBox="0 0 12 16" alt=data.lang.create>
									<title> data.lang.create
									<path fill-rule="evenodd" clip-rule="evenodd" d="M12 5L4 13L0 9L1.5 7.5L4 10L10.5 3.5L12 5Z">
								<p> data.lang.create
						if store.show_color_picker
							<svg.close_colorPicker
									@click=(do store.show_color_picker = no)
									xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 16"
									[scale@off:0.75 o@off:0] ease>
								<title> data.lang.close
								<path fill-rule="evenodd" clip-rule="evenodd" d="M12 5L4 13L0 9L1.5 7.5L4 10L10.5 3.5L12 5Z">
							<color-picker bind=store .show-canvas=store.show_color_picker width="320" height="208" alt=data.lang.canvastitle [scale@off:0.75 o@off:0] ease>  data.lang.canvastitle


			if store.show_history
				<menu-popup bind=store.show_history scrollinview=no ease>
					<section.small_box.filters [pos:fixed b:16px t:auto r:16px w:300px max-height:calc(100vh - 32px) p:8px zi:4 o@off:0 origin:bottom right transform@off:scale(0.75)]>
						<[m: 0 c:inherit].nighttheme.flex>
							<svg[m: 0 8px].close_search @click=turnHistory() viewBox="0 0 20 20">
									<title> data.lang.close
									<path d=svg_paths.close>
							<h1[margin: 0 0 0 8px]> data.lang.history
							<svg.close_search [p:0 m:0 4px 0 auto w:32px] @click=clearHistory() viewBox="0 0 24 24" alt=data.lang.delete>
								<title> data.lang.delete
								<path d="M15 16h4v2h-4v-2zm0-8h7v2h-7V8zm0 4h6v2h-6v-2zM3 20h10V8H3v12zM14 5h-3l-1-1H6L5 5H2v2h12V5z">
						<article[of:auto max-height: calc(97vh - 82px)]>
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
							unless history.length
								<p[padding: 12px]> data.lang.empty_history


			if menuicons and not (what_to_show_in_pop_up_block && window.innerWidth < 640)
				<section#navigation [o@off:0 t@lg:0px b@lt-lg:{-menu_icons_transform}px height:54px @lg:0px bgc@lt-lg:$bgc d:flex jc:space-between] ease>
					<div[transform: translateY({menu_icons_transform}%) translateX({bibleIconTransform!}px)] @click=toggleBibleMenu>
						<svg viewBox="0 0 16 16">
							<title> data.lang.change_book
							<path d="M3 5H7V6H3V5ZM3 8H7V7H3V8ZM3 10H7V9H3V10ZM14 5H10V6H14V5ZM14 7H10V8H14V7ZM14 9H10V10H14V9ZM16 3V12C16 12.55 15.55 13 15 13H9.5L8.5 14L7.5 13H2C1.45 13 1 12.55 1 12V3C1 2.45 1.45 2 2 2H7.5L8.5 3L9.5 2H15C15.55 2 16 2.45 16 3ZM8 3.5L7.5 3H2V12H8V3.5ZM15 3H9.5L9 3.5V12H15V3Z">
						<p> data.lang.change_book
					<div[transform: translateY({menu_icons_transform}%) d@lg:none] @click=turnGeneralSearch>
						<svg.helpsvg [p:0 4px] viewBox="0 0 12 12" width="24px" height="24px">
							<title> data.lang.find_in_chapter
							<path d=svg_paths.search>
						<p> data.lang.bible_search.split(' ')[0]
					<div[transform: translateY({menu_icons_transform}%) translateX({settingsIconTransform!}px)] @click=toggleSettingsMenu>
						<svg enable-background="new 0 0 24 24" height="24" viewBox="0 0 24 24" width="24">
							<title> data.lang.other
							<g>
								<path d="M19.14,12.94c0.04-0.3,0.06-0.61,0.06-0.94c0-0.32-0.02-0.64-0.07-0.94l2.03-1.58c0.18-0.14,0.23-0.41,0.12-0.61 l-1.92-3.32c-0.12-0.22-0.37-0.29-0.59-0.22l-2.39,0.96c-0.5-0.38-1.03-0.7-1.62-0.94L14.4,2.81c-0.04-0.24-0.24-0.41-0.48-0.41 h-3.84c-0.24,0-0.43,0.17-0.47,0.41L9.25,5.35C8.66,5.59,8.12,5.92,7.63,6.29L5.24,5.33c-0.22-0.08-0.47,0-0.59,0.22L2.74,8.87 C2.62,9.08,2.66,9.34,2.86,9.48l2.03,1.58C4.84,11.36,4.8,11.69,4.8,12s0.02,0.64,0.07,0.94l-2.03,1.58 c-0.18,0.14-0.23,0.41-0.12,0.61l1.92,3.32c0.12,0.22,0.37,0.29,0.59,0.22l2.39-0.96c0.5,0.38,1.03,0.7,1.62,0.94l0.36,2.54 c0.05,0.24,0.24,0.41,0.48,0.41h3.84c0.24,0,0.44-0.17,0.47-0.41l0.36-2.54c0.59-0.24,1.13-0.56,1.62-0.94l2.39,0.96 c0.22,0.08,0.47,0,0.59-0.22l1.92-3.32c0.12-0.22,0.07-0.47-0.12-0.61L19.14,12.94z M12,15.6c-1.98,0-3.6-1.62-3.6-3.6 s1.62-3.6,3.6-3.6s3.6,1.62,3.6,3.6S13.98,15.6,12,15.6z">
						<p> data.lang.other


			if loading
				<loading-animation [pos:fixed t:50% l:50% zi:100 o@off:0] ease>


			if settings.verse_picker and (show_verse_picker || show_parallel_verse_picker)
				<section.small_box [pos:fixed t:8vh l:48px w:300px p:12px pt:8px zi:100  max-height:86% origin:top left scale@off:0.96 y@off:-16px o@off:0] ease>
					<.flex>
						<h1[margin: 0 auto;font-size: 1.3em; line-height: 1;]> data.lang.choose_verse
						<svg[m: 0 8px].close_search @click=hideVersePicker viewBox="0 0 20 20">
							<title> data.lang.close
							<path d=svg_paths.close>
					<div>
						if show_verse_picker
							<>
								for i in [0 ... verses.length]
									<a.chapter_number @click=goToVerse(i + 1)> i + 1
						elif show_parallel_verse_picker
							<>
								for j in [0 ... parallel_verses.length]
									<a.chapter_number @click=goToVerse('p' + (j + 1))> j + 1


			if welcome != 'false'
				<section#welcome.small_box [pos:fixed zi:9999 r:16px b:16px p:16px o@off:0 scale@off:0.75 origin:bottom right w:300px] ease>
					<h1[margin: 0 auto 12px; font-size: 1.2em]> data.lang.welcome
					<p[mb:8px text-indent:1.5em lh:1.5 fs:0.9em]> data.lang.welcome_msg, <span.emojify> ' 😉'
					<button [w:100% h:32px bg:$acc-bgc @hover:$acc-bgc-hover c:$c @hover:$acc-color-hover ta:center border:none fs:1em rd:4px cursor:pointer] @click=welcomeOk> "Ok ", <span.emojify> '👌🏽'


			if page_search.d
				<section#page_search [background-color: {page_search.matches.length || !page_search.query.length ? 'var(--background-color)' : 'firebrick'} pos:fixed b:0 y@off:100% l:0 r:0 d:flex ai:center bdt:1px solid $acc-bgc p:2px 8px zi:1100] ease>
					<input$pagesearch.search bind=page_search.query @input.pageSearch @keydown.enter.pageSearchKeydownManager [border-top-right-radius: 0;border-bottom-right-radius: 0] placeholder=data.lang.find_in_chapter>
					<button.arrow @click=prevOccurence() title=data.lang.prev [border-radius: 0]>
						<svg width="16" height="10" viewBox="0 0 8 5" [transform: rotate(180deg)]>
							<title> data.lang.prev
							<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
					<button.arrow @click=nextOccurence() title=data.lang.next [border-top-left-radius: 0; border-bottom-left-radius: 0; border-top-right-radius: 4px; border-bottom-right-radius: 4px margin-right:16px]>
						<svg width="16" height="10" viewBox="0 0 8 5">
							<title> data.lang.next
							<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
					if page_search.matches.length
						<p> page_search.current_occurence + 1, ' / ', page_search.matches.length
					elif page_search.query.length != 0 && window.innerWidth > 640
						<p> data.lang.phrase_not_found, '!'
						<title> data.lang.delete
						<path[m:auto] d=svg_paths.close>

					<svg.close_search [ml:auto min-width:26px] @click=clearSpace viewBox="0 0 20 20">
						<title> data.lang.close
						<path[m: auto] d=svg_paths.close>



			<global
				@hotkey('mod+shift+f').capture.prevent.stop.prepareForHotKey=turnGeneralSearch
				@hotkey('mod+k').capture.prevent.stop.prepareForHotKey=turnGeneralSearch
				@hotkey('mod+f').prevent.stop.prepareForHotKey=pageSearch
				@hotkey('escape').capture.prevent.stop=clearSpace
				@hotkey('mod+y').prevent.stop=fixDrawers
				@hotkey('mod+alt+h').prevent.stop=(menuicons = !menuicons, setCookie("menuicons", menuicons), imba.commit!)

				@hotkey('mod+right').prevent.stop=nextChapter()
				@hotkey('mod+left').prevent.stop=prevChapter()
				@hotkey('alt+n').prevent.stop=nextBook()
				@hotkey('alt+p').prevent.stop=prevBook()
				@hotkey('mod+n').prevent.stop=nextBook()
				@hotkey('mod+p').prevent.stop=prevBook()
				@hotkey('alt+shift+right').prevent.stop=nextChapter('true')
				@hotkey('alt+shift+left').prevent.stop=prevChapter('true')

				@hotkey('alt+right').prevent.stop=window.history.forward!
				@hotkey('alt+left').prevent.stop=window.history.back!

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
		padding:3vw @lt-lg:4px
		width:calc(100% / 3) @lg:calc(32px + 6vw)
		height:54px @lg:calc(32px + 6vw)
		c@hover:$acc-color-hover
		fill:$acc-color @hover:$acc-color-hover @lt-lg:$c
		d@lt-lg:vflex jc:center ai:center

	css #navigation svg
		width: 32px
		height: 32px
		min-height: 32px
		fill:inherit
		o@lt-lg:0.75 @hover:1

	css #navigation p
		display:inline-block @lg:none
		p:0 8px o:0.75 @hover:1
		fs:12px

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

	css .search_option_on
		o:1 @hover:1