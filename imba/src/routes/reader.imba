import '../ui'

import { MOBILE_PLATFORM } from '../constants'

import ChevronRight from 'lucide-static/icons/chevron-right.svg'
import ChevronLeft from 'lucide-static/icons/chevron-left.svg'
import Search from 'lucide-static/icons/search.svg'
import BookOpenText from 'lucide-static/icons/book-open-text.svg'
import SlidersHorizontal from 'lucide-static/icons/sliders-horizontal.svg'

tag reader
	initialTouch = null
	inTouchZone = no
	inClosingTouchZone = no
	welcomeLock = no

	def onPopState event
		if event.explicitOriginalTarget.hash
			return
		activities.cleanUp { onPopState: yes }
		reader.initReaderFromLocation!

	def onSelectionChange
		if window.getSelection().toString().length > 0
			self.dictionary.showTooltip!
		setTimeout(&, 150) do
			let selection = document.getSelection()
			if selection.isCollapsed and self.dictionary.tooltip
				self.dictionary.tooltip = null
				imba.commit!

	def mount
		document.addEventListener('selectionchange', onSelectionChange.bind(self))
		window.addEventListener('popstate', onPopState.bind(self))
		window.onblur = hidePanels.bind(self)
		document.body.onmouseleave = hidePanels.bind(self)
		document.onmouseleave = hidePanels.bind(self)
		window.onmouseout = hidePanels.bind(self)

		window.strongDefinition = do(topic)
			dictionary.query = topic
			dictionary.loadDefinitions!
 
	def unmount
		document.removeEventListener('selectionchange', onSelectionChange.bind(self))
		window.removeEventListener('popstate', onPopState.bind(self))
		window.onblur = null
		document.body.onmouseleave = null
		document.onmouseleave = null
		window.onmouseout = null
		window.strongDefinition = null


	def hidePanels event\MouseEvent
		if !settings.fixdrawers && (event.clientY < 0 || event.clientX < 0 || (event.clientX > window.innerWidth || event.clientY > window.innerHeight))
			inTouchZone = no
			inClosingTouchZone = no
			activities.booksDrawerOffset = -300
			activities.settingsDrawerOffset = -300
			imba.commit!


	def slidestart touch
		touch.preventDefault()
		initialTouch = touch.changedTouches[0]
		if initialTouch.clientX < 16 or initialTouch.clientX > window.innerWidth - 16
			inTouchZone = yes

	def slideend touch
		touch = touch.changedTouches[0]

		touch.dy = initialTouch.clientY - touch.clientY
		touch.dx = initialTouch.clientX - touch.clientX

		if activities.booksDrawerOffset > -300
			if inTouchZone
				touch.dx < -64 ? activities.booksDrawerOffset = 0 : activities.booksDrawerOffset = -300
			else
				touch.dx > 64 ? activities.booksDrawerOffset = -300 : activities.booksDrawerOffset = 0
		elif activities.settingsDrawerOffset > -300
			if inTouchZone
				touch.dx > 64 ? activities.settingsDrawerOffset = 0 : activities.settingsDrawerOffset = -300
			else
				touch.dx < -64 ? activities.settingsDrawerOffset = -300 : activities.settingsDrawerOffset = 0
		elif document.getSelection().isCollapsed && Math.abs(touch.dy) < 36 && !activities.show_history && !activities.selectedVerses.length
			if window.innerWidth > 600
				if touch.dx < -32
					parallelReader.enabled && touch.clientX > window.innerWidth / 2 ? parallelReader.prevChapter! : reader.prevChapter!
				elif touch.dx > 32
					parallelReader.enabled && touch.clientX > window.innerWidth / 2 ? parallelReader.nextChapter! : reader.nextChapter!
			else
				if touch.dx < -32
					parallelReader.enabled && touch.clientY > window.innerHeight / 2 ? parallelReader.prevChapter! : reader.prevChapter!
				elif touch.dx > 32
					parallelReader.enabled && touch.clientY > window.innerHeight / 2 ? parallelReader.nextChapter! : reader.nextChapter!

		initialTouch = null
		inTouchZone = no


	def closingdrawer e
		e.dx = e.changedTouches[0].clientX - initialTouch.clientX

		if activities.booksDrawerOffset > -300 && e.dx < 0
			activities.booksDrawerOffset = e.dx
		if activities.settingsDrawerOffset > -300 && e.dx > 0
			activities.settingsDrawerOffset = - e.dx
		inClosingTouchZone = yes

	def openingdrawer e
		if inTouchZone
			e.dx = e.changedTouches[0].clientX - initialTouch.clientX

			if activities.booksDrawerOffset < 0 && e.dx > 0
				activities.booksDrawerOffset = e.dx - 300
			if activities.settingsDrawerOffset < 0 && e.dx < 0
				activities.settingsDrawerOffset = - e.dx - 300

	def closedrawersend touch
		touch.dx = touch.changedTouches[0].clientX - initialTouch.clientX

		if activities.booksDrawerOffset > -300
			touch.dx < -64 ? activities.booksDrawerOffset = -300 : activities.booksDrawerOffset = 0
		elif activities.settingsDrawerOffset > -300
			touch.dx > 64 ? activities.settingsDrawerOffset = -300 : activities.settingsDrawerOffset = 0
		inClosingTouchZone = no

	def mousemove e
		const isRangeInputFocues = document.activeElement.tagName == 'INPUT' && document.activeElement.type == 'range'
		if not MOBILE_PLATFORM and not settings.fixdrawers and not isRangeInputFocues
			if e.x < 24
				activities.booksDrawerOffset = 0
			elif e.x > window.innerWidth - 24
				activities.settingsDrawerOffset = 0
			elif 300 < e.x < window.innerWidth - 300
				activities.booksDrawerOffset = -300 unless welcomeLock
				activities.settingsDrawerOffset = -300

			if 300 > e.x
				welcomeLock = no

	def interpolate value, max
		# vresult hsould be between 0 and max
		const result = Math.min(Math.max(value, 0), max)
		

	def boxShadow grade\number
		const abs = grade + 300
		return "0 0 0 {interpolate(abs, 1)}px var(--acc-bgc), 0 {interpolate(abs,1)}px {interpolate(abs, 6)}px var(--acc-bgc), 0 {interpolate(abs,3)}px {interpolate(abs, 36)}px var(--acc-bgc), 0 9px {interpolate(abs, 128)}px -{interpolate(abs, 64)}px var(--acc-bgc)"

	get drawerTransiton
		(inClosingTouchZone || inTouchZone) ? '0' : '450ms'
	
	def readerPadding mainReader = yes
		if parallelReader.enabled
			# the padding is 0 on the side of the parallel reader
			# the parallel should not have padding in between them. Take into account text direction
			const textDirection = translationTextDirection(mainReader ? reader.translation : parallelReader.translation)
			const oneSidePadding = (window.innerWidth - theme.maxWidth * theme.fontSize * 2) / 2 - pageSearch.drawerOffset
			if (textDirection == 'rtl' && mainReader) or (textDirection == 'ltr' && !mainReader)
				return "0 {oneSidePadding}px"
			return "{oneSidePadding}px 0"
		# the body should be centered theme.maxWidth
		return "{(window.innerWidth - theme.maxWidth * theme.fontSize) / 2 - pageSearch.drawerOffset}px"

	get bibleIconTransform
		if (settings.fixdrawers && window.innerWidth >= 1024)
			return 300 + activities.booksDrawerOffset
		return 0
	
	get settingsIconTransform
		if (settings.fixdrawers && window.innerWidth >= 1024)
			return -300 - activities.settingsDrawerOffset
		return 0

	def cleanUpSelection
		let selectedText = window.getSelection().toString()
		if selectedText.length > 0
			pageSearch.query = selectedText
			search.query = selectedText
		activities.cleanUp!


	def render
		<self>
			<[d:flex] @mousemove=mousemove>
				<books-drawer
					[l:{activities.booksDrawerOffset}px bxs:{boxShadow(activities.booksDrawerOffset)} transition-duration:{drawerTransiton}]
					@touchstart=slidestart @touchend=closedrawersend @touchcancel=closedrawersend @touchmove=closingdrawer>

				<button.drawer-handle
					[transform:translateX({bibleIconTransform}px)]
					@click=activities.toggleBooksMenu @touchstart=slidestart @touchmove=openingdrawer @touchend=slideend @touchcancel=slideend>
					<svg src=ChevronRight aria-label=t.change_book
						[transform:rotate({180*+!!bibleIconTransform}deg)]>

				<main id="main"
					@touchstart=slidestart @touchmove=openingdrawer @touchend=slideend @touchcancel=slideend
					.parallel_text=parallelReader.enabled .hide-comments=!settings.verse_commentary .parallels=parallelReader.enabled
					[pos:{parallelReader.enabled ? 'relative' : 'static'} ff:{theme.fontFamily} fs:{theme.fontSize}px lh:{theme.lineHeight} fw:{theme.fontWeight} ta:{theme.align} fl:1]
					>
					<chapter id="main-reader" state=reader [padding-inline:{readerPadding!}] />
					if parallelReader.enabled
						<chapter id="parallel-reader" state=parallelReader [padding-inline:{readerPadding(no)}] versePrefix="p" />
				
				<button.drawer-handle
					[transform:translateX({settingsIconTransform}px)]
					@click=activities.toggleSettingsMenu @touchstart=slidestart @touchmove=openingdrawer @touchend=slideend @touchcancel=slideend>
					<svg src=ChevronLeft aria-label=t.change_book
						[transform:rotate({180*+!!settingsIconTransform}deg)]>

				<settings-drawer
					[r:{activities.settingsDrawerOffset}px bxs:{boxShadow(activities.settingsDrawerOffset)} transition-duration:{drawerTransiton}]
					@touchstart=slidestart @touchend=closedrawersend @touchcancel=closedrawersend @touchmove=closingdrawer>

			if dictionary.tooltip
				<div
					[pos:fixed l:{dictionary.tooltip.left}px r:{dictionary.tooltip.right}px t:{dictionary.tooltip.top}px zi:1 scale@off:0.75 o@off:0] ease>
					css
						bg:$acc-bgc rd:4px
						origin:top center
						bd:1px solid $acc-bgc-hover
						
						button
							bgc:transparent @hover:$acc-bgc-hover
							fs:inherit font:inherit c:inherit
							cursor:pointer p: 8px

					<button @click=dictionary.loadDefinitions(dictionary.tooltip.selected)> dictionary.tooltip.selected
					if dictionary.tooltip.strong
						'|'
						<button @click=dictionary.loadDefinitions(dictionary.tooltip.strong)> dictionary.tooltip.strong

			if settings.menuicons and not (activities.activeModal && window.innerWidth < 640)
				<section [o@off:0 t@lg:0px b@lt-lg:{-activities.menuIconsTransform}px] ease>
					css
						pos:fixed right:0px left:0px
						bgc@lt-lg:$bgc d:flex jc:space-between
						w:100% height:auto @lg:0px zi:2 cursor:pointer
						bdt@lt-lg:1px solid $acc-bgc
						button
							padding:3em @lt-lg:0
							width:calc(100% / 3) @lg:auto
							height:2.75rem @lg:auto
							bgc:transparent
							c:$acc @lt-lg:$c @hover:$acc-hover
							d@lt-lg:hcc
						svg
							o@lt-lg:0.75 @hover:1

					<button[transform: translateY({activities.menuIconsTransform}%) translateX({bibleIconTransform}px)] @click=activities.toggleBooksMenu title=t.change_book>
						<svg src=BookOpenText aria-hidden=yes>
					<button[transform: translateY({activities.menuIconsTransform}%) d@lg:none] @click=activities.showSearch title=t.search>
						<svg src=Search aria-hidden=yes>
					<button[transform: translateY({activities.menuIconsTransform}%) translateX({settingsIconTransform}px)] @click=activities.toggleSettingsMenu title=t.settings>
						<svg src=SlidersHorizontal aria-hidden=yes>

			if activities.activeModal
				<modal />

			if activities.activeVerseAction
				<verse-actions />
			
			if reader.loading || parallelReader.loading || dictionary.loading || search.loading || compare.loading
				<loading>
			
			<global
				@hotkey('mod+shift+f|mod+k').force.prevent.stop.cleanUpSelection=activities.showSearch
				@hotkey('s|f|і|а').prevent.stop.cleanUpSelection=activities.showSearch
				
				# @hotkey('mod+f').prevent.stop.prepareForHotKey=pageSearch
				# @hotkey('alt+r').prevent.stop=randomVerse
				@hotkey('mod+y').prevent.stop=(settings.fixdrawers = !settings.fixdrawers)
				
				@hotkey('mod+d').prevent.stop=dictionary.showDictionary
				@hotkey('alt+s|alt+і').prevent.stop=dictionary.showStongNumberDefinition
				@hotkey('escape').force.prevent.stop=activities.cleanUp
				@hotkey('mod+alt+h').prevent.stop=(settings.menuicons = !settings.menuicons)

				@hotkey('mod+right').prevent.stop=reader.nextChapter
				@hotkey('mod+left').prevent.stop=reader.prevChapter
				@hotkey('mod+n').prevent.stop=reader.nextBook
				@hotkey('mod+p').prevent.stop=reader.prevBook
				@hotkey('alt+n').prevent.stop=reader.nextBook
				@hotkey('alt+p').prevent.stop=reader.prevBook
				@hotkey('alt+shift+right').prevent.stop=parallelReader.nextChapter
				@hotkey('alt+shift+left').prevent.stop=parallelReader.prevChapter

				@hotkey('mod+[').prevent.stop=theme.decreaseFontSize
				@hotkey('mod+]').prevent.stop=theme.increaseFontSize
				
				@hotkey('mod+,').prevent.stop=activities.showHelp
			>


	css
		nav, aside
			h: 100vh
			position: fixed
			top: 0
			bottom: 0
			width: 300px
			touch-action: pan-y
			z-index: 1000
			background-color: var(--bgc)

		nav
			border-right: 1px solid var(--acc-bgc)
			transition-property: left
			will-change: left
			padding-inline: 0
			padding-block: 0.5rem 2rem


		aside
			border-left: 1px solid var(--acc-bgc)
			transition-property: right
			will-change: right
			padding-inline: 0.75rem
			padding-block: 1rem 2rem
			overflow-y: auto
			-webkit-overflow-scrolling: touch
		
		.hide-comments
			sup
				display: none

		.parallels
			d:flex
			fld@lt-sm:column
			g:1rem @lt-sm:0

			section
				max-height@lt-sm: 50vh
				-webkit-overflow-scrolling: touch
		
		.drawer-handle
			w:2vw w:min(32px, max(16px, 2vw))
			h:100vh
			bgc:gray4/25
			o:0 @hover:1
			d:hcc cursor:pointer zi:2 c:$acc 
