import { getValue, setValue } from '../utils/index.imba' 

import API from './Api'
import GenericReader from './GenericReader'
import activities from './Activities'
import readingHistory from './ReadingHistory'
import vault from './Vault'
import settings from './Settings'
import reader from './Reader'
import notifications from './Notifications'


class ParallelReader < GenericReader
	@observable translation\string = getValue('parallel_translation') || 'WLCa'
	@observable book\number = getValue('parallel_book') || 1
	@observable chapter\number = getValue('parallel_chapter') || 1
	@observable enabled\boolean = getValue('parallel_display') || false
	verse\number|string = 0

	me = 'parallel'

	@autorun def saveTranslation
		setValue('parallel_translation', translation)
	
	@autorun def saveBook
		setValue('parallel_book', book)
	
	@autorun def saveChapter
		setValue('parallel_chapter', chapter)

	@autorun def saveEnabled
		setValue('parallel_display', enabled)

	# Whenever translation, book or chapter changes, we need to fetch the verses for the current chapter.
	@autorun(delay:2ms)
	def fetchVerses
		unless theChapterExistInThisTranslation!
			return
		
		loading = yes

		try
			verses = []
			imba.commit!
			if vault.downloaded_translations.indexOf(translation) != -1
				verses = await vault.getChapterFromDB(translation, book, chapter)
			else
				verses = await API.getJson("/get-chapter/{translation}/{book}/{chapter}/")
		catch error
			console.error(error)
			# if window.navigator.onLine
			notifications.push('error')
		finally
			loading = no
			activities.cleanUp!

		readingHistory.saveToHistory(translation, book, chapter)
		if settings.parallel_sync && enabled
			reader.book = book
			reader.chapter = chapter
		# if state.user.username then getBookmarks("/get-bookmarks/" + translation + '/' + book + '/' + chapter + '/', 'bookmarks')
		if verse
			if typeof verse === 'string' and verse.includes('-')
				const parts = verse.split('-')
				findVerse(parts[0], parts[1], yes)
			else
				findVerse(verse, undefined, yes)
			verse = undefined
		# if verse > 0 then show_verse_picker = no else show_verse_picker = yes



const parallelReader = new ParallelReader()

export default parallelReader