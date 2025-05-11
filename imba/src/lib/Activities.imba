import Color from "colorjs.io"

import readingHistory from './ReadingHistory'
import { MOBILE_PLATFORM } from '../constants'

import { getBookName } from '../utils'

import pageSearch from './PageSearch'
import parallelReader from './ParallelReader'
import reader from './Reader'
import dictionary from './Dictionary'
import search from './Search'
import notifications from './Notifications'
import user from './User'
import theme from './Theme'
import customTheme from './CustomTheme'

import type { CopyObject, Verse } from './types'

class Activities 
	show_accents = no
	show_themes = no
	show_fonts = no
	show_languages = no
	show_dictionaries = no
	show_filters = no
	show_sharing = no
	show_comparison_options = no
	show_dictionary_downloads = no
	show_bookmarks = no
	show_add_bookmark = no
	show_color_picker = no

	IOSKeyboardHeight = 0
	blockInScroll = null
	scrollLockTimeout = null
	menuIconsTransform = 0

	booksDrawerOffset = -300
	settingsDrawerOffset = -300
	bottomDrawerOffset = 0

	@observable selectedVerses\number[] = []
	@observable selectedVersesPKs\number[] = []
	selectedParallel = undefined
	selectedCategories = []

	activeModal = ''
	activeVerseAction = ''
	highlight_color\string = ''

	note = ''
	newCategoryName = ''

	@observable activeTranslation\string = ''

	# Clean all the variables in order to free space around the text
	def cleanUp { onPopState } = {}
		if activeModal == 'theme'
			if theme.theme != 'custom'
				customTheme.cleanUpCustomTheme!
			if #hadTransitionsEnabled
				document.documentElement.dataset.transitions = 'true'

		# If user write a note then instead of clearing everything just hide the note panel.
		if activeModal == "notes"
			activeModal = ''
			return

		if (activeModal and not onPopState) or selectedVerses.length > 0
			window.history.back()

		show_accents = no
		show_themes = no
		show_fonts = no
		show_languages = no
		show_dictionaries = no
		show_filters = no
		show_sharing = no
		show_bookmarks = no
		show_comparison_options = no
		show_color_picker = no

		booksDrawerOffset = -300
		settingsDrawerOffset = -300

		dictionary.tooltip = null
		dictionary.loading = no
		dictionary.definitions = []

		selectedVerses = []
		selectedVersesPKs = []
		selectedParallel = undefined
		selectedCategories = []

		reader.show_verse_picker = no
		parallelReader.show_verse_picker = no

		search.currentQuery = ""
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

	def showHistory
		cleanUp!
		readingHistory.syncHistory!
		openModal 'history'

	def showSearch
		cleanUp!
		openModal 'search'
		search.generateSuggestions!
		setTimeout(&, 300) do
			search.inputElement\(as HTMLInputElement).select!

	def openCustomTheme
		cleanUp!
		openModal 'theme'
		#hadTransitionsEnabled = theme.transitions
		document.documentElement.dataset.transitions = 'false'

	def toggleDownloads
		cleanUp!
		openModal 'downloads'
		show_dictionary_downloads = no

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

	@computed get selectedVersesTitle
		if selectedParallel == 'main'
			return getSelectedVersesTitle(reader.translation, reader.book, reader.chapter, selectedVerses) + ' ' + reader.translation
		return
			getSelectedVersesTitle(parallelReader.translation, parallelReader.book, parallelReader.chapter, selectedVerses) + ' ' + parallelReader.translation

	get randomColor
		const randomL = Math.random() * 0.6 + 0.2 # Range [0.2, 0.8]
		const randomC = Math.random() * 0.25 + 0.05 # Range [0.05, 0.3]
		const randomH = Math.random() * 360 # Range [0, 360)
		const randomColor = new Color('oklch', [randomL, randomC, randomH])
		return randomColor.to('hsl').toString()

	def changeHighlightColor color\string
		# get tag with title = color
		let colorBulb = document.querySelector('li.color-option[title="' + color + '"]')
		const computedStyle = window.getComputedStyle(colorBulb)
		const backgroundColor = computedStyle.getPropertyValue('background-color');

		highlight_color = backgroundColor

	def setHighlightColor event
		if event.detail
			highlight_color = event.detail

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

	# returns a string with the range of verses in format 1-3 or 1
	def versesRange verses\number[]
		verses.length > 1 ? (verses.sort(do |a, b| return a - b)[0] + '-' + verses.sort(do |a, b| return b - a)[0]) : verses[0]

	def copyWithoutLink 
		copyTextToClipboard
			'«' + copyObject.text + '»\n\n' + copyObject.title + ' ' + copyObject.translation
		cleanUp!

	def copyWithLink copy\CopyObject
		copyTextToClipboard
			'«' + copy.text + '»\n\n' + copy.title + ' ' + copy.translation + ' ' + "https://bolls.life" + '/'+ copy.translation + '/' + copy.book + '/' + copy.chapter + '/' + versesRange(copyObject.verses) + '/'

	def copyWithInternationalLink
		copyTextToClipboard
			'«' + copyObject.text + '»\n\n' + copyObject.title + ' ' + copyObject.translation + ' ' + "https://bolls.life/international" + '/'+ copyObject.translation + '/' + copyObject.book + '/' + copyObject.chapter + '/' + versesRange(copyObject.verses) + '/'
		cleanUp!


	def copyToClipboardFromSearch copy\Verse
		copyWithLink {
			text: cleanUpCopyTexts([copy.text]),
			translation: copy.translation,
			book: copy.book,
			chapter: copy.chapter,
			verses: [copy.verse],
			title: getSelectedVersesTitle(copy.translation, copy.book, copy.chapter, [copy.verse])
		}

	def toggleBookmarks
		show_bookmarks = !show_bookmarks

	def addNewCategory
		if user.categories.includes(newCategoryName) || selectedCategories.includes(newCategoryName)
			notifications.push('category_exists')
			return
		if newCategoryName
			selectedCategories.push(newCategoryName)
		newCategoryName = ""
		show_add_bookmark = no
		show_bookmarks = no

	def addCategoryToSelected category\string
		if selectedCategories.includes(category)
			selectedCategories = selectedCategories.filter(do |element| return element != category)
		else
			selectedCategories.push(category)

	def saveBookmark
		if selectedParallel == 'main'
			reader.saveBookmark!
		else
			parallelReader.saveBookmark!


const activities = new Activities()

export default activities
