import { getValue, setValue } from '../utils'

import ALL_BOOKS from '../data/translations_books.json'
import { isIOS } from '../constants'

import API from './Api'
import theme from './Theme'
import settings from './Settings'
import activities from './Activities'
import user from './User'
import vault from './Vault'
import notifications from './Notifications'

import type { Verse, Bookmark } from './types'

class GenericReader
	@observable translation\string
	@observable book\number
	@observable chapter\number
	verses\Array<Verse> = []
	loading\boolean = yes
	@observable bookmarks\Bookmark[] = []
	show_verse_picker\boolean = no
	verse\number|string = 0

	me = '' # constant to indicate the main reader versus the parallel reader

	@computed get books
		let orderBy = settings.chronorder ? 'chronorder' : 'bookid'
		return ALL_BOOKS[translation].sort(do(a, b) return a[orderBy] - b[orderBy])

	@computed get nameOfCurrentBook
		for tr_book in books
			if tr_book.bookid == book
				return tr_book.name
		return book
	
	get theChapterExistInThisTranslation
		const theBook = books.find(do |element| return element.bookid == book)
		if theBook
			if theBook.chapters >= chapter
				return yes
		return no

	@computed get chaptersOfCurrentBook
		for book in books
			if book.bookid == self.book
				return book.chapters
	
	def nextChapter
		if chapter + 1 <= chaptersOfCurrentBook
			chapter += 1
		else
			let current_index = books.indexOf(books.find(do |element| return element.bookid == book))
			if books[current_index + 1]
				book = books[current_index + 1].bookid
				chapter = 1

	def prevChapter
		if chapter - 1 > 0
			chapter -= 1
		else
			let current_index = books.indexOf(books.find(do |element| return element.bookid == book))
			if books[current_index - 1]
				book = books[current_index - 1].bookid
				chapter = books[current_index - 1].chapters

	@computed get prevChapterLink
		if chapter - 1 > 0
			return "/{translation}/{book}/{chapter - 1}/"
		else
			let current_index = books.indexOf(books.find(do |element| return element.bookid == book))
			if books[current_index - 1]
				return "/{translation}/{books[current_index - 1].bookid}/{books[current_index - 1].chapters}/"
		return "/{translation}/{book}/{chapter}/" # default plug

	@computed get nextChapterLink
		if chapter + 1 <= chaptersOfCurrentBook
			return "/{translation}/{book}/{chapter + 1}/"
		else
			let current_index = books.indexOf(books.find(do |element| return element.bookid == book))
			if books[current_index + 1]
				return "/{translation}/{books[current_index+1].bookid}/1/"
		return "/{translation}/{book}/{chapter}/" # default plug

	def nextBook
		let current_index = books.indexOf(books.find(do |element| return element.bookid == book))
		if books[current_index + 1]
			book = books[current_index + 1].bookid
			chapter = 1

	def prevBook
		let current_index = books.indexOf(books.find(do |element| return element.bookid == book))
		if books[current_index - 1]
			book = books[current_index - 1].bookid
			chapter = 1

	def getBookmark verseNumber\number
		if user.username
			return bookmarks.find(do |element| return element.verse == verseNumber)

	def getHighlight pk\number
		if activities.selectedVersesPKs.length && activities.selectedVersesPKs.includes(pk)
			let width = Math.ceil(0.5 * theme.fontSize)	# size of dots
			return "repeating-linear-gradient(90deg, {activities.highlight_color}, {activities.highlight_color} {width}px, rgba(0,0,0,0) {width}px, rgba(0,0,0,0) {width * 2}px)"
		else
			let highlight = bookmarks.find(do |element| return element.verse == pk)
			if highlight
				return  "linear-gradient({highlight.color} 0px, {highlight.color} 100%)"
			else
				return ''
	
	def getBookmarks
		if !user.username
			return

		let server_bookmarks = []
		let offline_bookmarks = []
		if window.navigator.onLine
			try
				server_bookmarks = await API.getJson("/get-bookmarks/" + translation + '/' + book + '/' + chapter + '/', 'bookmarks')
			catch error
				console.warn error

		if vault.available
			offline_bookmarks = await vault.getChapterBookmarks(verses.map(do |verse| return verse.pk))

		bookmarks = offline_bookmarks.concat(server_bookmarks)
		imba.commit!

	@computed get selectionHasBookmark
		for verse in activities.selectedVersesPKs
			if bookmarks.find(do |element| return element.verse == verse)
				return yes
		return no

	def getCollectionOfChosen verseNumber\number
		let highlight = bookmarks.find(do |element| return element.verse == verseNumber)
		if highlight
			return highlight.collection
		else ''

	def pushCollectionIfExist pk\number
		for piece in getCollectionOfChosen(pk).split(' | ')
			if piece != '' && !activities.selectedCategories.includes(piece)
				activities.selectedCategories.push(piece)


	def selectVerse pk\number, id\number
		if !document.getSelection().isCollapsed or activities.activeModal
			return

		if activities.selectedParallel != undefined and activities.selectedParallel != me
			return

		activities.selectedParallel = me
		activities.highlight_color = activities.randomColor

		if activities.selectedVersesPKs.length == 0
			window.history.pushState(
				{},
				'',
				me == 'main' ? (
					window.location.origin + '/' + translation + '/' + book + '/' + chapter + '/' + id + '/'
				) : window.location.pathname)

		# Check if the user chosen a verse in the same parallel scope
		if activities.selectedVersesPKs.includes(pk)
			activities.selectedVersesPKs.splice(activities.selectedVersesPKs.indexOf(pk), 1)
			activities.selectedVerses.splice(activities.selectedVerses.indexOf(id), 1)
			let collection = getCollectionOfChosen(pk)
			if collection
				for piece in collection.split(' | ')
					if piece != ''
						activities.selectedCategories.splice(activities.selectedCategories.indexOf(piece), 1)
		else
			activities.selectedVersesPKs.push(pk)
			activities.selectedVerses.push(id)
			pushCollectionIfExist(pk)

		# If the verse is in area under bottom section
		# scroll to it, to see the full verse
		let verseElement
		if me == 'main'
			verseElement = document.getElementById(String(id)).nextSibling
		else
			verseElement = document.getElementById("p{id}").nextSibling

		const boundingRect = verseElement.getBoundingClientRect()
		if boundingRect.bottom + activities.bottomDrawerOffset > window.innerHeight - 124 # 124 is the relative height of the bottom drawer
			verseElement.scrollIntoView({behavior: theme.scrollBehavior, block: 'center'})

		if activities.selectedVersesPKs.length
			showDeleteBookmark()
			mergeNotes()
			activities.activeVerseAction ||= 'options'
		else
			activities.activeVerseAction = undefined
			activities.selectedParallel = undefined


	def mergeNotes
		activities.note = ''
		for versePK in activities.selectedVersesPKs
			let vrs = bookmarks.find(do |element| return element.verse == versePK)
			if vrs
				if activities.note.indexOf(vrs.note) < 0
					activities.note += vrs.note


	def showDeleteBookmark
		let show_delete_bookmark = no
		for verseNumber in activities.selectedVerses
			let vrs = bookmarks.find(do |element| return element.verse == verseNumber)
			#  || parallel_bookmarks.find(do |element| return element.verse == verse)
			if vrs
				show_delete_bookmark = yes
				return 1

	@computed get selectedVersesTitle
		let row = nameOfCurrentBook + ' ' + chapter + ':'
		for id, key in activities.selectedVerses.sort(do |a, b| return a - b)
			if id == activities.selectedVerses[key - 1] + 1
				if id == activities.selectedVerses[key+1] - 1
					continue
				else row += '-' + id
			else
				unless key
					row += id
				else row += ',' + id
		return row


	def findVerse id, endverse\string|number = undefined, highlight = no
		setTimeout(&,250) do
			const verseNumberElement = document.getElementById(id)
			if verseNumberElement
				verseNumberElement.offsetParent.scrollTo({
					behavior: theme.scrollBehavior,
					top: verseNumberElement.offsetTop - theme.fontSize
				})
				if highlight then highlightLinkedVerses(id, endverse)
			else
				findVerse(id, endverse, highlight)


	def highlightLinkedVerses verseNumber, endverse
		if isIOS or !window.getSelection
			return

		setTimeout(&, 250) do
			const verseNode = document.getElementById(verseNumber)
			unless verseNode
				return highlightLinkedVerses verseNumber, endverse

			const selection = window.getSelection()
			selection.removeAllRanges()
			if endverse
				for id in [parseInt(verseNumber) .. parseInt(endverse)]
					if id <= verses.length
						const range = document.createRange()
						const node = document.getElementById(String(id))
						range.selectNodeContents(node.nextSibling || node)
						selection.addRange(range)
			else
				const range = document.createRange()
				range.selectNodeContents(verseNode.nextSibling || verseNode)
				selection.addRange(range)

	def saveBookmark
		unless user.username
			window.location.pathname = "/signup/"
			return

		if activities.note == '<br>'
			activities.note = ''

		let collections = activities.selectedCategories.map(do(str) str.trim!).join(' | ')

		let bookmarkToSave = {
			verses: activities.selectedVersesPKs,
			color: activities.highlight_color,
			date: Date.now(),
			collections: collections
			note: activities.note
		}

		def saveOffline
			if vault.available
				vault.saveBookmarksToStorageUntilOnline(bookmarkToSave)

		if window.navigator.onLine
			try
				await API.post("/save-bookmarks/", bookmarkToSave)
				notifications.push('saved')
			catch e
				console.error(e)
				notifications.push('error')
				saveOffline!
		else saveOffline!

		for verse in activities.selectedVersesPKs
			if bookmarks.find(do |bookmark| return bookmark.verse == verse)
				bookmarks.splice(bookmarks.indexOf(bookmarks.find(do |bookmark| return bookmark.verse == verse)), 1)
			bookmarks.push({
				verse: verse,
				date: Date.now(),
				color: activities.highlight_color,
				collection: collections
				note: activities.note
			})
		user.saveUserBookmarkToMap translation, book, chapter, activities.highlight_color
		# add to user.categories the new collections
		for category in activities.selectedCategories
			if !user.categories.includes(category)
				user.categories.push(category)
		activities.cleanUp!

	def requestDeleteBookmark pks\number[]
		vault.deleteBookmarks(pks)
		if window.navigator.onLine
			try
				await API.post("/delete-bookmarks/", { verses: pks })
				notifications.push('deleted')
			catch err
				console.error err
				deleteLater (pks)
		else deleteLater (pks)

	def deleteLater pks\number[]
		let bookmarksToDelete = getValue('bookmarks-to-delete')
		setValue('bookmarks-to-delete', bookmarksToDelete.concat(pks))

	def deleteBookmark pks\number[]
		if !user.username
			window.location.pathname = "/signup/"
			return

		const deletedColors = new Set<string>()
		for verse in activities.selectedVersesPKs
			let bookmark = bookmarks.find(do |element| return element.verse == verse)
			if bookmark
				deletedColors.add(bookmark.color)

		requestDeleteBookmark(pks)
		for verse in activities.selectedVersesPKs
			if bookmarks.find(do |bookmark| return bookmark.verse == verse)
				bookmarks.splice(bookmarks.indexOf(bookmarks.find(do |bookmark| return bookmark.verse == verse)), 1)

		if bookmarks.length !== 0
			for color in deletedColors when !bookmarks.find(do |bookmark| return bookmark.color == color)
				user.deleteBookmarkFromUserMap translation, book, chapter, color
		activities.cleanUp!

	def nextVerseHasTheSameBookmark verse_index
		let current_bookmark = getBookmark(verses[verse_index].pk)
		if current_bookmark
			const next_verse = verses[verse_index + 1]
			if next_verse
				let next_bookmark = getBookmark(next_verse.pk)
				if next_bookmark
					if next_bookmark.collection == current_bookmark.collection and next_bookmark.note == current_bookmark.note
						return yes
		return no

export default GenericReader