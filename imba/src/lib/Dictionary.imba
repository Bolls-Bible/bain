import activities from './Activities'
import API from './Api'
import reader from './Reader'
import vault from './Vault'
import settings from './Settings'
import parallelReader from './ParallelReader'
import theme from './Theme'
import localization from './Localization'

import dictionaries from "../data/dictionaries.json"

import { getValue, setValue } from '../utils'

import { MOBILE_PLATFORM } from '../constants'
import { scoreSearch } from '../utils'
import type { Definition } from './types.ts'

class Dictionary
	definitions\Definition[] = []
	history = []
	historyIndex = -1
	expandedTopic = ''
	showDownloads = no
	tooltip = null
	query = ''
	loading = no
	dictionaries = dictionaries

	@observable currentDictionary\string = getValue('dictionary')

	@autorun def saveCurrentDictionary
		setValue('dictionary', currentDictionary)

	def constructor
		unless currentDictionary
			if localization.language == 'ru' or localization.language == 'ukr'
				currentDictionary = 'RUSD'
			else
				currentDictionary = 'BDBT'

	def strongNumber selection\Selection, number\string
		# checking for Hebrew symbols is not reliable for cases when translation is English or Dutch but we're still at the old testament
		# And at the same time parallel mode may be selected and selection may be either in one or another parallel which may be both NT and OT
		# So we need to check to what translation the selection belongs
		if parallelReader.enabled
			const parallelReaderElement = document.getElementById('parallel-reader')
			if parallelReaderElement.contains(selection.anchorNode)
				if parallelReader.book < 40
					return 'H' + number
				else
					return 'G' + number
		if reader.book < 40
			return 'H' + number
		else
			return 'G' + number

	def showTooltip
		const selection = window.getSelection!
		const selected = selection.toString!.trim!

		# Trigger the definition popup only when a single hebrew or greekword is selected or there are Strong tags init <S> or <s>
		let hebrew_or_greek = selected.match(/[\u0370-\u03FF]/) or  selected.match(/[\u0590-\u05FF]/) or selection.anchorNode.parentElement.querySelectorAll("s").length 
		if [...selected.matchAll(/\s/g)].length > 1 or selected == '' or not hebrew_or_greek
			tooltip = null
			return imba.commit!

		# The feature is not available offline without downloads
		if window.navigator.onLine or vault.downloaded_dictionaries.length
			let range = selection.getRangeAt(0)
			# let rangeContainer = range.commonAncestorContainer
			let rangeContainer = range.endContainer.parentElement
			const main = document.getElementById('main')

			if main.contains(rangeContainer)
				let viewportRectangle = range.getBoundingClientRect()
				tooltip = {
					top: viewportRectangle.top + theme.fontSize * (MOBILE_PLATFORM ? 2.2 : 1.4),
					left: 'auto'
					right: 'auto'
					width: viewportRectangle.width
					height: viewportRectangle.height
					selected: selected
				}
				# Prevent overflowing
				if viewportRectangle.left <= window.innerWidth / 2
					tooltip.left = viewportRectangle.left
				else
					tooltip.right = window.innerWidth - viewportRectangle.right
				# Iterate through selected range nodes and find the first node having S tag type
				# Avoid using rangeContainer.childNodes cus it containes nodes outside of the selection
				# use document.createNodeIterator instead
				let iterator = document.createNodeIterator(rangeContainer, NodeFilter.SHOW_ALL)
				let node = iterator.nextNode()
				# always omit the first node cus it's the text node before the selection
				let first_node_omitten = no
				while node
					# If we run out of nodes, instead of instanteniously writing the possible null into node, I wanna preserve the last node in the node variable
					let next_node = iterator.nextNode()
					if !next_node
						break
					node = next_node

					# check if the node is inside the selection
					if !selection.containsNode(node, true)
						if first_node_omitten
							node = iterator.previousNode()
							break
						else
							continue

					# First node is never interesting. Strong number always follows the word, not preceeds it.
					if !first_node_omitten
						first_node_omitten = yes
						continue

					# Strong numbers are always inside S tag
					if node.tagName == 'S' or node.tagName == 's'
						tooltip.strong = strongNumber(selection, node.textContent)
						break

				if !tooltip.strong
					# If no S tag found, try at first to find the strong number in the next node
					if node
						tooltip.strong = strongNumber(selection, node.textContent)
					# Otherwise try our old approach
					elif selection.anchorOffset > 1 && selection.focusNode.previousSibling..textContent
						tooltip.strong = strongNumber(selection, selection.focusNode.previousSibling.textContent)
					else
						if selection.anchorNode.nextSibling..textContent
							tooltip.strong = strongNumber(selection, selection.anchorNode.nextSibling.textContent)

				imba.commit!

	def showDictionary
		const selection = window.getSelection!
		const selected = selection.toString!.trim!
		if selected
			query = selected
		loadDefinitions!
		setTimeout(&, 300) do
			const dictionarySearchInput\(as HTMLInputElement) = document.getElementById('dictionarysearch')
			dictionarySearchInput..select!

	def showStongNumberDefinition
		if tooltip..strong
			loadDefinitions(tooltip.strong)

	def stripVowels rawString
		# Clear Hebrew
		let res =  rawString.replace(/[\u0591-\u05C7]/g,"")
		# Replace some letters, which are not present in a given unicode range, manually.
		res = res.replace('שׁ', 'ש')
		res = res.replace('שׂ', 'ש')
		res = res.replace('‎', '')

		# Clear Greek
		res = res.normalize('NFD').replace(/[\u0300-\u036f]/g, "");
		return res

	# Get query results from the dictionary, or Strong's number 
	def loadDefinitions newQuery = undefined
		let selected_text = window.getSelection!.toString!.trim!
		if typeof newQuery === 'string' # imba may pass the event object from input
			query = newQuery
		elif selected_text
			query = selected_text

		activities.cleanUp { onPopState: yes }
		activities.openModal 'dictionary'

		definitions = []
		if query && (window.navigator.onLine or vault.downloaded_dictionaries.length)
			if history.indexOf(query) == -1
				historyIndex += 1
				history[historyIndex] = query
				history.length = historyIndex + 1

			loading = yes
			def loadDefinitionsFromOffline
				let unvoweled_query = stripVowels(query)
				let offlineResults = await vault.searchDefinitions({dictionary: currentDictionary, query: unvoweled_query})
				definitions = []
				for definition in offlineResults
					const score = scoreSearch(definition.lexeme, unvoweled_query)
					if score or definition.topic == query.toUpperCase!
						definitions.push({
							... definition
							score: score
						})
				definitions = definitions.sort(do |a, b| b.score - a.score)

			if window.navigator.onLine
				try
					definitions = await API.getJson("/dictionary-definition/{currentDictionary}/{query}/?extended={settings.extended_dictionary_search ? 'true' : ''}")
				catch error
					console.error error
					if currentDictionary in vault.downloaded_dictionaries
						await loadDefinitionsFromOffline()
			elif currentDictionary in vault.downloaded_dictionaries
				await loadDefinitionsFromOffline()
			loading = no
			expandedTopic = definitions[0]..topic
			# When definitions are loaded we have to parse inner MyBible links and replace them custom click events
			parseDefinitionsLinks!
			imba.commit!

	# Since I use MyBible modules they have their own links format, which is not supported by the browser.
	# So we have to parse them and replace with custom click events.
	def parseDefinitionsLinks
		# Parse Strong links
		let patterns = [
			/<a href='S:(.*?)'>/g,
			/<a href=\"S:(.*?)\">/g,
			/<a href=S:(.*?)>/g
		]
		for definition, index in definitions
			for pattern in patterns
				let matches = [... definition.definition.matchAll(pattern)]
				for match in matches
					definition.definition = definition.definition.replace(match[0], "<a onclick='strongDefinition(\"{match[1]}\")'>")

		# Unlink TWOT links
		patterns = [
			/<a class="T" href='S:(.*?)'>/g,
			/<a class="T" href=\"S:(.*?)\">/g,
			/<a class="T" href=S:(.*?)>/g
		]
		for definition, index in definitions
			for pattern in patterns
				let matches = [... definition.definition.matchAll(pattern)]
				for match in matches
					definition.definition = definition.definition.replace(match[0], match[1])


	def prevDefinition
		if historyIndex > 0
			historyIndex -= 1
			query = history[historyIndex]
			loadDefinitions!

	def nextDefinition
		if historyIndex < history.length - 1
			historyIndex += 1
			query = history[historyIndex]
			loadDefinitions!

	def expandDefinition topic\string
		const definitionEl = document.getElementById(topic)
		unless definitionEl
			return
		if expandedTopic == topic
			expandedTopic = ''
		else
			expandedTopic = topic
			setTimeout(&, 500) do
				definitionEl.scrollIntoView()

	def currentDictionaryName
		for dictionary in dictionaries
			if dictionary.abbr == currentDictionary
				return dictionary.name

const dictionary = new Dictionary()

export default dictionary
