import { MOBILE_PLATFORM } from '../constants'

import { getBookName } from '../utils'

import pageSearch from './PageSearch'
import parallelReader from './ParallelReader'
import reader from './Reader'
import dictionary from './Dictionary'
import search from './Search'
import notifications from './Notifications'

import type { CopyObject, Verse } from './types'

class Activities 
	show_accents = no
	show_themes = no
	show_fonts = no
	show_languages = no
	show_history = no
	show_parallel_verse_picker = no
	show_verse_picker = no
	show_dictionaries = no
	show_filters = no
	show_sharing = no
	show_comparison_optinos = no

	IOSKeyboardHeight = 0
	blockInSctoll = null
	scrollLockTimeout = null
	menuIconsTransform = 0

	booksDrawerOffset = -300
	settingsDrawerOffset = -300
	bottomDrawerOffset = 0

	@observable selectedVerses\number[] = []
	selectedVersesPKs = []
	selectedParallel = undefined
	selectedCategories = []

	activeModal = ''
	activeVerseAction = ''
	highlight_color\string = ''

	note = ''

	@observable activeTranslation\string = ''

	def cleanUp { onPopState } = {}
		# If user write a note then instead of clearing everything just hide the note panel.
		if activeModal == "note"
			activeModal = ''
			return

		if (activeModal and not onPopState) or selectedVerses.length > 0
			window.history.back()
		
		show_accents = no
		show_themes = no
		show_fonts = no
		show_languages = no
		show_history = no
		show_parallel_verse_picker = no
		show_verse_picker = no
		show_dictionaries = no
		show_filters = no
		show_sharing = no

		booksDrawerOffset = -300
		settingsDrawerOffset = -300

		# Clean all the variables in order to free space around the text
		show_filters = no
		show_comparison_optinos = no
		dictionary.tooltip = null
		dictionary.loading = no
		dictionary.definitions = []

		selectedVerses = []
		selectedVersesPKs = []
		selectedParallel = undefined
		# showAddCollection = no
		selectedCategories = []

		search.currentQuery = search.query
		if search.inputElement
			search.inputElement.blur()

		# unless the user is typing something focus the reader in order to enable arrow navigation on the text
		unless pageSearch.on 
			# focus()
			window.getSelection().removeAllRanges()
		if pageSearch.on || activeModal
			pageSearch.on  = no
			pageSearch.matches = []
			pageSearch.rects = []
		activeModal = ''
		activeVerseAction = ''
		selectedParallel = undefined
		imba.commit!
	
	def delayedCleanUp
		imba.commit!.then do
			cleanUp!

	def hideVersePicker
		show_parallel_verse_picker = no
		show_verse_picker = no
	

	def toggleBooksMenu parallel
		if booksDrawerOffset
			if !settingsDrawerOffset && MOBILE_PLATFORM
				return cleanUp!
			booksDrawerOffset = 0
		else
			imba.commit!.then do
				booksDrawerOffset = -300
				imba.commit!
		if typeof parallel == 'boolean'
			if parallel
				activeTranslation = parallelReader.translation
			else
				activeTranslation = reader.translation

	def toggleSettingsMenu
		if settingsDrawerOffset
			if !booksDrawerOffset && MOBILE_PLATFORM
				return cleanUp!
			settingsDrawerOffset = 0
		else
			imba.commit!.then do
				settingsDrawerOffset = -300
				imba.commit!

	def openModal modal_name\string
		if activeModal !== modal_name
			activeModal = modal_name
			window.history.pushState({}, modal_name)
	
	def showHelp
		cleanUp!
		openModal 'help'
	
	def showSupport
		cleanUp!
		openModal 'support'
	
	def showFonts
		cleanUp!
		openModal 'font'
	
	def showSearch
		cleanUp!
		openModal 'search'
		search.generateSuggestions!
		setTimeout(&, 300) do
			search.inputElement.select!

	def getSelectedVersesTitle translation\string, book\number, chapter\number, verses\number[]
		let row = getBookName(translation, book) + ' ' + chapter + ':'
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
	
	@computed get selectedversesTitle
		if selectedParallel == 'main'
			return getSelectedVersesTitle(reader.translation, reader.book, reader.chapter, selectedVerses) + ' ' + reader.translation
		return
			getSelectedVersesTitle(parallelReader.translation, parallelReader.book, parallelReader.chapter, selectedVerses) + ' ' + parallelReader.translation

	get randomColor
		return 'rgb(' + Math.round(Math.random()*255) + ',' + Math.round(Math.random()*255) + ',' + Math.round(Math.random()*255) + ')'

	def changeHighlightColor color\string
		# get tag with title = color
		let colorBulb = document.querySelector('li.color-option[title="' + color + '"]')
		const computedStyle = window.getComputedStyle(colorBulb);
		const backgroundColor = computedStyle.getPropertyValue('background-color');

		highlight_color = backgroundColor


	def cleanUpCopyTexts texts\string[]
		return texts.join(' ').trim().replace(/<s>\w+<\/s>/gi, '').replace(/<[^>]*>/gi, '')

	get copyObject\CopyObject
		const selectedReader = selectedParallel == reader.me ? reader : parallelReader
		let verses = []
		let texts = []
		for verse in selectedReader.verses
			if selectedVersesPKs.find(do |element| return element == verse.pk)
				texts.push(verse.text)
				verses.push(verse.verse)
		return {
			title: selectedReader.selectedVersesTitle,
			text: cleanUpCopyTexts(texts),
			verses: verses,
			translation: selectedReader.translation,
			book: selectedReader.book,
			chapter: selectedReader.chapter
		}

	def fallbackCopyTextToClipboard text\string
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
		notifications.push('copied')


	def copyTextToClipboard text\string
		if !window.navigator.clipboard
			fallbackCopyTextToClipboard(text)
			return
		window.navigator.clipboard.writeText(text).catch(do |err|
			console.error('Async: Could not copy text: ', err)
			fallbackCopyTextToClipboard(text)
		)
		notifications.push('copied')

	def copyToClipboard 
		let text = '«' + copyObject.text + '»\n\n' + copyObject.title
		copyTextToClipboard(text)

	# returns a string with the range of verses in formart 1-3 or 1
	def versesRange verses\number[]
		verses.length > 1 ? (verses.sort(do |a, b| return a - b)[0] + '-' + verses.sort(do |a, b| return b - a)[0]) : verses[0]

	def copyWithoutLink 
		copyTextToClipboard
			'«' + copyObject.text + '»\n\n' + copyObject.title + ' ' + copyObject.translation
		delayedCleanUp!

	def copyWithLink copy\CopyObject
		console.log copy
		copyTextToClipboard
			'«' + copy.text + '»\n\n' + copy.title + ' ' + copy.translation + ' ' + "https://bolls.life" + '/'+ copy.translation + '/' + copy.book + '/' + copy.chapter + '/' + versesRange(copyObject.verses) + '/'

	def copyWithInternationalLink
		copyTextToClipboard
			'«' + copyObject.text + '»\n\n' + copyObject.title + ' ' + copyObject.translation + ' ' + "https://bolls.life/international" + '/'+ copyObject.translation + '/' + copyObject.book + '/' + copyObject.chapter + '/' + versesRange(copyObject.verses) + '/'
		delayedCleanUp!


	def copyToClipboardFromSerach copy\Verse
		copyWithLink {
			text: cleanUpCopyTexts([copy.text]),
			translation: copy.translation,
			book: copy.book,
			chapter: copy.chapter,
			verses: [copy.verse],
			title: getSelectedVersesTitle(copy.translation, copy.book, copy.chapter, [copy.verse])
		}


const activities = new Activities()

export default activities
