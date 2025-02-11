import { getValue, setValue } from '../utils'

import API from './Api'
import activities from './Activities'
import { translations } from '../constants.imba'
import vault from './Vault'
import settings from './Settings'
import parallelReader from './ParallelReader.imba'
import readingHistory from './ReadingHistory'
import notifications from './Notifications'

import GenericReader from './GenericReader'


class Reader < GenericReader
	@observable translation\string = getValue('translation')
	@observable book\number = getValue('book') || 1
	@observable chapter\number = getValue('chapter') || 1
	verse\number|string = 0

	me = 'main'

	@autorun def saveTranslation
		setValue('translation', translation)

	@autorun def saveBook
		setValue('book', book)

	@autorun def saveChapter
		setValue('chapter', chapter)

	def initReaderFromLocation
		let link = window.location.pathname.split('/')
		if 'international' in link
			if link[2] && link[3] && link[4]
				translation = translation || link[2]
				book = parseInt(link[3])
				chapter = parseInt(link[4])
		else
			if link[1] && link[2] && link[3]
				translation = link[1]
				book = parseInt(link[2])
				chapter = parseInt(link[3])
				console.log(link[4])

	def constructor
		super()
		initReaderFromLocation!


	# Whenever translation, book or chapter changes, we need to fetch the verses for the current chapter.
	@autorun(delay:2ms)
	def fetchVerses
		unless theChapterExistInThisTranslation!
			return
		
		const translationName = translations.find(do |element| element.short_name == translation)..full_name || translation
		document.title = nameOfCurrentBook + ' ' + chapter + ' ' + translationName + " Bolls Bible"
		loading = yes

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
		if settings.parallel_sync && parallelReader.enabled
			parallelReader.book = book
			parallelReader.chapter = chapter

		getBookmarks!

		if verse
			if typeof verse === 'string' and verse.includes('-')
				const parts = verse.split('-')
				findVerse(parts[0], parts[1], yes)
			else
				findVerse(verse, undefined, yes)
			verse = undefined

		# if verse > 0 then show_verse_picker = no else show_verse_picker = yes

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