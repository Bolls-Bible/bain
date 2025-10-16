import { getValue, setValue } from '../utils'

import API from './Api'
import activities from './Activities'
import { translationNames } from '../constants'
import vault from './Vault'
import settings from './Settings'
import parallelReader from './ParallelReader'
import readingHistory from './ReadingHistory'
import notifications from './Notifications'

import GenericReader from './GenericReader'


class Reader < GenericReader
	@observable translation\string
	@observable book\number
	@observable chapter\number

	me = 'main'

	@autorun def saveTranslation
		if translationNames[translation]
			setValue('translation', translation)

	@autorun def saveBook
		setValue('book', book)

	@autorun def saveChapter
		setValue('chapter', chapter)

	def constructor
		super()
		if window.translation
			unless 'international' in window.location.pathname
				translation = window.translation
				book = window.book
				chapter = window.chapter
				verse = window.verse
			verses = window.verses
			loading = no
		else
			translation = getValue('translation')
			book = getValue('book') || 1
			chapter = getValue('chapter') || 1

	get myRenderer
		document.getElementById('main-reader')

	# Whenever translation, book or chapter changes, we need to fetch the verses for the current chapter.
	@autorun(delay:5ms)
	def fetchVerses
		unless theChapterExistInThisTranslation
			return
		
		document.title = nameOfCurrentBook + ' ' + chapter + ' ' + translationNames[translation] + " Bolls Bible"
		loading = yes
		imba.commit!

		if settings.parallel_sync && parallelReader.enabled
			parallelReader.book = book
			parallelReader.chapter = chapter

		try
			verses = []
			imba.commit!
			if vault.downloaded_translations.indexOf(translation) != -1
				verses = await vault.getChapter(translation, book, chapter)
			else
				verses = await API.getJson("/get-chapter/{translation}/{book}/{chapter}/")
		catch error
			console.error(error)
			# if window.navigator.onLine
			notifications.push('error')
		finally
			loading = no
			activities.cleanUp!

		readingHistory.saveToHistory(translation, book, chapter, verse)
		getBookmarks!

		if verse
			if typeof verse === 'string' and verse.includes('-')
				const parts = verse.split('-')
				findVerse(parts[0], parts[1], yes)
			else
				findVerse(verse, undefined, yes)
			verse = undefined
		else
			show_verse_picker = yes
			if myRenderer
				myRenderer.scrollTop = 0

		# if the pathname has one of 4 `/` in it then call the pushState
		const pathnameSlices = window.location.pathname.split('/').filter(Boolean).length
		if pathnameSlices == 0 or pathnameSlices > 2
			window.history.pushState({
					translation: translation,
					book: book,
					chapter: chapter,
				},
				'',
				window.location.origin + '/' + translation + '/' + book + '/' + chapter + '/'
			)

	def randomVerse
		try
			let randomVerse
			// check if the translation is available offline and make offline request
			if vault.downloaded_translations.indexOf(translation) != -1
				const response = await window.fetch("/sw/get-random-verse/{translation}/")
				randomVerse = await response.json()
			else
				if window.navigator.onLine
					randomVerse = await API.getJson("/get-random-verse/{translation}/")
			if randomVerse
				chapter = randomVerse.chapter
				book = randomVerse.book
				verse = randomVerse.verse
		catch error
			console.error error
			notifications.push('error')


const reader = new Reader()

export default reader