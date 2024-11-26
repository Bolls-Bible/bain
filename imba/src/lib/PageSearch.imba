import parallelReader from './ParallelReader.imba'
import activities from './Activities'

class PageSearch
	on = no
	query = ''
	matches = []
	current_occurence = 1
	rects = []

	get drawerOffset
		return Math.min(32, Math.max(16, window.innerWidth * 0.02))
	
	get inputElement\HTMLInputElement
		document.getElementById('pagesearch')


	def pageSearch event
		let selectionStart = 0
		if event
			selectionStart = event.target.selectionStart

		# Show pageSearch box
		clearSpace()
		on = yes

		def focusInput
			if inputElement
				imba.commit().then do
					inputElement.focus()
					inputElement.setSelectionRange(selectionStart, selectionStart)
			else setTimeout(&,50) do focusInput()

		# Check if query is not an empty string
		unless query.length
			matches = []
			rects = []
			focusInput()
			return 0

		# if the query is not an emty string lets clean it up for regex
		let regex_compatible_query
		unless activities.activeModal
			regex_compatible_query = query.replace(/[.*+\-?^${}()|[\]\\]/g, '\\$&')
		else
			regex_compatible_query = search.query.replace(/[.*+\-?^${}()|[\]\\]/g, '\\$&')

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
				if parallel == 'ps'
					return rect_top + search_body.scrollTop - search_body.offsetTop - search_body.parentNode.offsetTop
				elif parallelReader.enabled
					if window.innerWidth < 639 && parallel
						return rect_top + chapter_articles[parallel].parentElement.scrollTop - chapter_articles[parallel].parentElement.offsetTop + activities.IOSKeyboardHeight
					else
						return rect_top + chapter_articles[parallel].parentElement.scrollTop + activities.IOSKeyboardHeight
				else return rect_top + scrollTop + activities.IOSKeyboardHeight

			def getSearchSelectionLeftOffset rect_left
				if parallel == 'ps'
					return rect_left - search_body.offsetLeft - search_body.parentNode.offsetLeft
				elif parallelReader.enabled
					if window.innerWidth > 639 && parallel
						return rect_left - chapter_articles[parallel].parentNode.offsetLeft - drawerOffset
					else
						return rect_left - drawerOffset
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
			if current_occurence == matches.length
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
		rects = []
		let nskrjvnslif = []
		for match in matches
			nskrjvnslif = nskrjvnslif.concat match.rects
		rects = nskrjvnslif

		# After all scroll to results
		if current_occurence > matches.length - 1
			current_occurence = 0
			if matches.length
				pageSearch!
		if matches[current_occurence]
			findVerse(matches[current_occurence].id, no, no)
		# focusInput()
		imba.commit()


	def changeSelectionRectClass class_name
		if matches[current_occurence]
			let rects = matches[current_occurence].rects
			for rect in rects
				rect.class = class_name

	def prevOccurence
		changeSelectionRectClass('another_occurences')
		if current_occurence == 0
			current_occurence = matches.length - 1
		else
			current_occurence--
		changeSelectionRectClass('current_occurence')
		if matches[current_occurence]
			findVerse(matches[current_occurence].id, no, no)
		imba.commit()

	def nextOccurence
		changeSelectionRectClass('another_occurences')
		if current_occurence == matches.length - 1
			current_occurence = 0
		else
			current_occurence++
		changeSelectionRectClass('current_occurence')
		if matches[current_occurence] then findVerse(matches[current_occurence].id, no, no)
		imba.commit()


const pageSearch = new PageSearch()

export default pageSearch
