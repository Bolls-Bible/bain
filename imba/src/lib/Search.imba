import { setValue, getValue, scoreSearch } from '../utils'

import activities from './Activities'
import API from './Api'
import reader from './Reader'
import vault from './Vault'

import { translations } from '../constants'

import type { Verse } from './types'

class Search
	@observable query\string = ''
	currentQuery = ''
	loading = no
	results\Verse[] = []
	exactMatchesCount = 0
	filter\number|string = ''
	resultBooks = []
	suggestions = {}
	@observable match_case\boolean = getValue('match_case')
	@observable match_whole\boolean = getValue('match_whole')
	page\number = 1
	total = 0
	pageSize = 128

	@autorun
	def saveMatchCase
		setValue('match_case', match_case)

	@autorun
	def saveMatchWhole
		setValue('match_whole', match_whole)

	get pages\number
		return Math.ceil(total / pageSize)

	def isNTBook bookid
		if 43 < bookid < 67
			return yes
		return no

	get inputElement
		return document.getElementById('generalsearch')

	def suggestTranslations query\string
		let suggested_translations = []
		if query.length > 2
			for translation in translations
				if query in translation.short_name.toLowerCase! or query in translation.full_name.toLowerCase!
					suggested_translations.push(translation)
		return suggested_translations

	@autorun
	def generateSuggestions
		const trimmedQuery = query.trim!.toLowerCase!
		unless trimmedQuery.length
			suggestions = {}
			return

		const parts = trimmedQuery.split(' ')
		let numbers_part = ''
		for part, index in parts when index > 0
			if /\d/.test(part)
				numbers_part = part
				break

		suggestions.chapter = null
		suggestions.verse = null
		suggestions.translation = null

		# Check if the ending of the trimmedQuery contains numbers
		if numbers_part
			# If verse is included
			if numbers_part.indexOf(':') > -1
				const ch_v_numbers = numbers_part.split(':')
				suggestions.chapter = parseInt(ch_v_numbers[0])
				if ch_v_numbers[1].length
					suggestions.verse = parseInt(ch_v_numbers[1])
			else
				suggestions.chapter = parseInt(numbers_part)

			if numbers_part != parts[-1]
				# Then test also translation part
				suggestions.translation = suggestTranslations(parts[-1])[0]..short_name
				parts.pop!
				parts.pop!
			else
				parts.pop!
		unless suggestions.translation
			suggestions.translation = reader.translation


		# If no numbers provided -- suggest first chapter
		unless suggestions.chapter
			suggestions.chapter = 1

		const bookname = parts.join(' ')

		let filtered_books = []
		if bookname.length > 1
			for book in reader.books
				const score = scoreSearch(book.name, bookname)
				if score
					filtered_books.push({
						book: book
						score: score
					})

			filtered_books = filtered_books.sort(do |a, b| b.score - a.score)


		# Generate suggestions list
		suggestions.books = []
		for item in filtered_books
			if reader.theChapterExistInThisTranslation
				suggestions.books.push item.book

		suggestions.translations = suggestTranslations(trimmedQuery)

	def isNumber str
		return !isNaN(str) && !isNaN(parseFloat(str))

	def run
		# Clear the searched text to avoid 400 error
		# If the query is long enough -- do the search
		if query.length <= 2 && !isNumber(query)
			return
		if activities.activeModal !== 'search'
			activities.cleanUp!
			activities.openModal 'search'
		inputElement..blur!
		if currentQuery != query
			page = 1
		currentQuery = ''
		loading = yes

		const url = '/v2/find/' + reader.translation + '?search=' + window.encodeURIComponent(query) + '&match_case=' + match_case + '&match_whole=' + match_whole + '&book=' + filter + '&page=' + page

		results = []
		total = 0
		try
			let res = await API.getJson(url)
			results = res["results"]
			exactMatchesCount = res["exact_matches"]
			total = res["total"]
			console.log 'Search results:', results
		catch error
			console.error error
			if vault.downloaded_translations.indexOf(reader.translation) != -1
				let result = await vault.search(reader.translation + '/' + query.toLowerCase() + '?book=' + filter + '&page=' + page)
				console.log 'Search results:', result
				results = result.data
				total = result.total
				exactMatchesCount = result.exact_matches
			else
				results = []

		resultBooks = []
		for verse in results
			if !resultBooks.find(do |element| return element == verse.book)
				resultBooks.push verse.book

		currentQuery = query
		loading = no
		imba.commit!
		

	def addFilter book\number|string
		filter = book
		activities.show_filters = no
		page = 1
		run!

	def dropFilter
		filter = ''
		activities.show_filters = no
		page = 1
		run!

	def getSuggestionText book
		let text = book.name + ' '
		if suggestions.chapter
			text += suggestions.chapter
		if suggestions.verse
			text += ':' + suggestions.verse
		if suggestions.translation
			text += ' ' + suggestions.translation
		return text
	
	def goToPage newPage\number
		if newPage > 0 && newPage <= pages && newPage != page
			page = newPage
			run!


const search = new Search()

export default search
