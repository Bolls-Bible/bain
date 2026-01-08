import parallelReader from './ParallelReader.imba'
import activities from './Activities'
import search from './Search'
import reader from './Reader'

import type { HighlightRectangular } from './types'

class PageSearch
	on = no
	query = ''
	matches = []
	current_occurrence = 1
	rects\HighlightRectangular[] = []

	get drawerOffset
		// query select a button with className drawer-handle
		const drawerHandle = document.querySelector('.drawer-handle')
		return drawerHandle..clientWidth
	
	get inputElement\HTMLInputElement
		document.getElementById('pageSearch')


	def run event = null
		let selectionStart = 0
		if event
			selectionStart = event.target.selectionStart

		# Show pageSearch box
		activities.cleanUp!
		on = yes

		def focusInput
			if inputElement
				imba.commit().then do
					inputElement.focus()
					inputElement.setSelectionRange(selectionStart, selectionStart)
			else setTimeout(&,50) do focusInput()

		focusInput()
		# Check if query is not an empty string
		unless query.length
			matches = []
			rects = []
			return 0

		# if the query is not an empty string lets clean it up for regex
		let regex_compatible_query
		unless activities.activeModal
			regex_compatible_query = query.replace(/[.*+\-?^${}()|[\]\\]/g, '\\$&')
		else
			regex_compatible_query = search.query.replace(/[.*+\-?^${}()|[\]\\]/g, '\\$&')

		# Lets get chapter node to iterate verses for match
		const main = document.getElementById('main')
		let chapter_articles = []
		for section in main.children
			# articles that does not have className contain chapters
			for child in section.children
				if child.tagName == 'ARTICLE' 
					chapter_articles.push(child)

		def highlightText node, lastIndex, cssClass, parallel
			# Create range of matched text to get its position in document
			const range = document.createRange()

			let range_start = lastIndex - query.length
			let range_end_index = lastIndex
			let range_node

			# The node may contain multiple text nodes and some minor HTML tags like <i>, <b> or <br>
			# That is why we need to iterate through all the childNodes of the node
			# and find the node that contains the matched text
			for child in node.childNodes
				# if child is a text node
				# then check if its length is greater than the range_start
				# if it is then we found the node that contains the matched text
				if child.nodeType == 3
					if range_start < child.length
						range_node = child
						break
					else
						range_start -= child.length
						range_end_index -= child.length
				else
					unless child.firstChild
						continue
					# if child is not a text node then we need to check against its firstChild
					# if the length of the firstChild is greater than the range_start
					# then we found the node that contains the matched text
					# Again the fuss around firstChild is just guessing.
					# Ideally it should work well without deep recursion
					if range_start < child.firstChild.length
						range_node = child.firstChild
						break
					else
						range_start -= child.firstChild.length
						range_end_index -= child.firstChild.length

			range.setStart(range_node, range_start)	# Start at first character of query
			range.setEnd(range_node, range_end_index)	# End at last character

			def getSearchSelectionTopOffset rect_top
				if parallelReader.enabled
					if window.innerWidth < 639 && parallel
						return rect_top + chapter_articles[parallel].parentElement.scrollTop - chapter_articles[parallel].parentElement.offsetTop
				return rect_top + chapter_articles[parallel].parentElement.scrollTop

			def getSearchSelectionLeftOffset rect_left
				if parallelReader.enabled
					if window.innerWidth > 639 && parallel
						return rect_left - chapter_articles[parallel].parentNode.offsetLeft - drawerOffset
				return rect_left - drawerOffset

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
						class: cssClass
						matchID: node.id
					}
					# Save it to and array to display it later
					selections.push(selection)
			return selections

		def getSelectionHighlightRect child, lastIndex, parallel
			# Highlight found text
			if current_occurrence == matches.length
				highlightText(child, lastIndex, 'current_occurrence', parallel)
			else
				highlightText(child, lastIndex, 'another_occurrences', parallel)

		def matchId node
			if node.id
				return node.id
			return node.nextSibling.id


		# Search process
		const regex1 = RegExp(regex_compatible_query, 'gi')
		let array1
		matches = []
		let parallel = 0

		for chapter in chapter_articles
			for child in chapter.children
				if child.tagName == 'NOTE-UP'
					continue
				while ((array1 = regex1.exec(child.textContent)) !== null)
					# Save the index of found text to matches
					# for further navigation
					matches.push({
						id: matchId(child),
						rects: getSelectionHighlightRect(child, regex1.lastIndex, parallel)
					})

			parallel++

		# Gather all rects to one array
		rects = matches.flatMap(do(match) match.rects)

		# After all scroll to results
		if current_occurrence > matches.length - 1
			current_occurrence = 0
			if matches.length
				run!

		if matches[current_occurrence]
			reader.findVerse(matches[current_occurrence].id, 0, no)
		# focusInput()
		imba.commit()


	def changeSelectionRectClass class_name
		if matches[current_occurrence]
			let rects = matches[current_occurrence].rects
			for rect in rects
				rect.class = class_name

	def prevOccurrence
		changeSelectionRectClass('another_occurrences')
		if current_occurrence == 0
			current_occurrence = matches.length - 1
		else
			current_occurrence--
		changeSelectionRectClass('current_occurrence')
		if matches[current_occurrence]
			reader.findVerse(matches[current_occurrence].id, 0, no)
		imba.commit()

	def nextOccurrence
		changeSelectionRectClass('another_occurrences')
		if current_occurrence == matches.length - 1
			current_occurrence = 0
		else
			current_occurrence++
		changeSelectionRectClass('current_occurrence')
		if matches[current_occurrence] then reader.findVerse(matches[current_occurrence].id, 0, no)
		imba.commit()

	def pageSearchKeydownManager event
		if event.code == "Enter"
			if event.shiftKey
				prevOccurrence()
			else
				nextOccurrence()


const pageSearch = new PageSearch()

export default pageSearch
