import { getValue } from '../utils'

import ALL_BOOKS from '../data/translations_books.json'
import { isIOS } from '../constants'

import theme from './Theme'
import settings from './Settings'
import activities from './Activities'
import user from './User'

import type { Verse } from './types'

class GenericReader
	@observable translation\string
	@observable book\number
	@observable chapter\number
	verses\Array<Verse> = []
	loading\boolean = no
	bookmarks = []

	me = ''

	@computed get books
		let orderBy = settings.chronorder ? 'chronorder' : 'bookid'
		return ALL_BOOKS[translation].sort(do(a, b) return a[orderBy] - b[orderBy])

	@computed get nameOfCurrentBook
		for tr_book in books
			if tr_book.bookid == book
				return tr_book.name
		return book
	
	def theChapterExistInThisTranslation
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
	
	def getCollectionOfChoosen verseNumber\number
		let highlight = bookmarks.find(do |element| return element.verse == verseNumber)
		if highlight
			highlight.collection
		else ''

	def pushCollectionIfExist pk\number
		for piece in getCollectionOfChoosen(pk).split(' | ')
			if piece != '' && !activities.selectedCategories.includes(piece)
				activities.selectedCategories.push(piece)


	def selectVerse pk\number, id\number
		if !document.getSelection().isCollapsed or activities.activeModal
			return

		if activities.selectedParallel != undefined and activities.selectedParallel != me
			return

		activities.selectedParallel = me
		activities.highlight_color = activities.randomColor

		if me == 'main' && activities.selectedVersesPKs.length == 0
			window.history.pushState(
				{},
				'',
				window.location.origin + '/' + translation + '/' + book + '/' + chapter + '/' + id + '/')

		# Check if the user choosed a verse in the same parallel scope
		if activities.selectedVersesPKs.includes(pk)
			activities.selectedVersesPKs.splice(activities.selectedVersesPKs.indexOf(pk), 1)
			activities.selectedVerses.splice(activities.selectedVerses.indexOf(id), 1)
			let collection = getCollectionOfChoosen(pk)
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
				verseNumberElement.scrollIntoView({behavior: theme.scrollBehavior, block: 'start'})
				if highlight then highlightLinkedVerses(id, endverse)
			else
				findVerse(id, endverse, highlight)


	def highlightLinkedVerses verseNumber, endverse
		if isIOS or !window.getSelection
			return

		setTimeout(&, 250) do
			const versenode = document.getElementById(verseNumber)
			unless versenode
				return highlightLinkedVerses verseNumber, endverse

			const selection = window.getSelection()
			selection.removeAllRanges()
			if endverse
				for id in [parseInt(verseNumber) .. parseInt(endverse)]
					if id <= verses.length
						const range = document.createRange()
						const node = document.getElementById(id)
						range.selectNodeContents(node.nextSibling || node)
						selection.addRange(range)
			else
				const range = document.createRange()
				range.selectNodeContents(versenode.nextSibling || versenode)
				selection.addRange(range)


export default GenericReader