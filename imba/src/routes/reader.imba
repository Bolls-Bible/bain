import '../ui'

import { hasTouchEvents } from '../constants'
import { getValue, deleteValue } from '../utils'

import ChevronRight from 'lucide-static/icons/chevron-right.svg'
import ChevronLeft from 'lucide-static/icons/chevron-left.svg'
import ChevronUp from 'lucide-static/icons/chevron-up.svg'
import ChevronDown from 'lucide-static/icons/chevron-down.svg'
import Search from 'lucide-static/icons/search.svg'
import BookOpenText from 'lucide-static/icons/book-open-text.svg'
import SlidersHorizontal from 'lucide-static/icons/sliders-horizontal.svg'

import * as ICONS from 'imba-phosphor-icons'

let lastPopStateTime = 0;

tag reader
	initialTouch = null
	inTouchZone = no
	inClosingTouchZone = no

	def onPopState event
		if event.target.hash
			return
		const currentTime = Date.now();
		if (currentTime - lastPopStateTime) < 300
			return
		lastPopStateTime = currentTime;
		activities.cleanUp { onPopState: yes }

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
		window.onresize = imba.commit

		window.strongDefinition = do(topic)
			self.dictionary.query = topic
			self.dictionary.loadDefinitions!

		# TODO clean up this at some point
		if getValue('enable_dynamic_contrast')
			setTimeout(&, 2000) do
				// Tell the user we don't support this feature anymore and offer them to create a custom theme instead which has better control
				const message = "Dynamic contrast is not supported anymore. You can create a custom theme instead, that has better control over the contrast."
				const confirm = await window.confirm(message)
				if confirm
					activities.openCustomTheme!
				deleteValue('enable_dynamic_contrast')


	def unmount
		document.removeEventListener('selectionchange', onSelectionChange.bind(self))
		window.removeEventListener('popstate', onPopState.bind(self))

	@action def routed params
		const link_segments = window.location.pathname.split('/').filter(Boolean)
		if params.translation && params.book && params.chapter
			if 'international' in window.location.pathname
				if link_segments.length == 5
					reader.verse = link_segments[-1]
			else
				reader.translation = params.translation
				if link_segments.length == 4
					reader.verse = link_segments[-1]
			reader.book = parseInt(params.book)
			reader.chapter = parseInt(params.chapter)


	def hidePanels event\MouseEvent
		if !settings.fixdrawers && (event.clientY < 0 || event.clientX < 0 || (event.clientX > window.innerWidth || event.clientY > window.innerHeight))
			inTouchZone = no
			inClosingTouchZone = no
			activities.booksDrawerOffset = -300
			activities.settingsDrawerOffset = -300
			imba.commit!


	def slidestart touch
		unless touch.changedTouches.length
			return
		initialTouch = touch.changedTouches[0]
		if initialTouch.clientX < 16 or initialTouch.clientX > window.innerWidth - 16
			inTouchZone = yes

	def slideend touch
		unless initialTouch
			return
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
		elif document.getSelection().isCollapsed && Math.abs(touch.dy / touch.dx) < 0.3 && !activities.selectedVerses.length
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
		unless e.changedTouches.length
			return
		e.dx = e.changedTouches[0].clientX - initialTouch.clientX

		if activities.booksDrawerOffset > -300 && e.dx < 0
			activities.booksDrawerOffset = e.dx
		if activities.settingsDrawerOffset > -300 && e.dx > 0
			activities.settingsDrawerOffset = - e.dx
		inClosingTouchZone = yes

	def openingdrawer e
		unless e.changedTouches.length
			return
		if inTouchZone
			e.dx = e.changedTouches[0].clientX - initialTouch.clientX

			if activities.booksDrawerOffset < 0 && e.dx > 0
				activities.booksDrawerOffset = e.dx - 300
			if activities.settingsDrawerOffset < 0 && e.dx < 0
				activities.settingsDrawerOffset = - e.dx - 300

	def closedrawersend touch
		unless touch.changedTouches.length
			return
		touch.dx = touch.changedTouches[0].clientX - initialTouch.clientX

		if activities.booksDrawerOffset > -300
			touch.dx < -64 ? activities.booksDrawerOffset = -300 : activities.booksDrawerOffset = 0
		elif activities.settingsDrawerOffset > -300
			touch.dx > 64 ? activities.settingsDrawerOffset = -300 : activities.settingsDrawerOffset = 0
		inClosingTouchZone = no

	def openBooksDrawer
		unless settings.fixdrawers or hasTouchEvents
			activities.booksDrawerOffset = 0
	
	def closeBooksDrawer
		unless settings.fixdrawers or hasTouchEvents
			activities.booksDrawerOffset = -300

	def openSettingsDrawer
		unless settings.fixdrawers or hasTouchEvents
			activities.settingsDrawerOffset = 0
	
	def closeSettingsDrawer
		unless settings.fixdrawers or hasTouchEvents
			activities.settingsDrawerOffset = -300

	def interpolate value, max
		# result should be between 0 and max
		Math.min(Math.max(value, 0), max)
		

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
		activities.cleanUp { onPopState: yes }

	def openProfile
		if user.username
			router.go('/profile')
		else
			window.location.href = '/accounts/login'

	def render
		<self[d:flex] @touchstart=slidestart @touchmove=openingdrawer @touchend=slideend @touchcancel=slideend>
			<button.drawer-handle
				[transform:translateX({bibleIconTransform}px)]
				@pointerenter=openBooksDrawer
				@click=activities.toggleBooksMenu>
				<svg src=ChevronRight aria-label=t.change_book
					[transform:rotate({180*+!!bibleIconTransform}deg)]>

			<main id="main"
				.parallel_text=parallelReader.enabled .hide-comments=!settings.verse_commentary .parallels=parallelReader.enabled
				[pos:{parallelReader.enabled ? 'relative' : 'static'} ff:{theme.fontFamily} fs:{theme.fontSize}px lh:{theme.lineHeight} fw:{theme.fontWeight} ta:{theme.align} fl:1]
				>
				<chapter id="main-reader" me=reader [padding-inline:{readerPadding!}] />
				if parallelReader.enabled
					<chapter id="parallel-reader" me=parallelReader [padding-inline:{readerPadding(no)}] versePrefix="p" />

			<button.drawer-handle
				[transform:translateX({settingsIconTransform}px)]
				@pointerenter=openSettingsDrawer
				@click=activities.toggleSettingsMenu>
				<svg src=ChevronLeft aria-label=t.settings
					[transform:rotate({180*+!!settingsIconTransform}deg)]>

			<global
				@hotkey('mod+shift+f|mod+k').force.prevent.stop.cleanUpSelection=activities.showSearch
				@hotkey('s|f|і|а').prevent.stop.cleanUpSelection=activities.showSearch

				@hotkey('mod+f').prevent.stop.cleanUpSelection=pageSearch.run
				@hotkey('alt+r').prevent.stop=reader.randomVerse
				@hotkey('mod+y').prevent.stop=(settings.fixdrawers = !settings.fixdrawers)

				@hotkey('mod+d|mod+в').prevent.stop=dictionary.showDictionary
				@hotkey('alt+s|alt+і').prevent.stop=dictionary.showStrongNumberDefinition
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
				@hotkey('alt+z').prevent.stop=openProfile
			>
				<books-drawer
					[l:{activities.booksDrawerOffset}px bxs:{boxShadow(activities.booksDrawerOffset)} transition-duration:{drawerTransiton}]
					@touchstart=slidestart @touchend=closedrawersend @touchcancel=closedrawersend @touchmove=closingdrawer @pointerleave=closeBooksDrawer>

				<settings-drawer
					[r:{activities.settingsDrawerOffset}px bxs:{boxShadow(activities.settingsDrawerOffset)} transition-duration:{drawerTransiton}]
					@touchstart=slidestart @touchend=closedrawersend @touchcancel=closedrawersend @touchmove=closingdrawer @pointerleave=closeSettingsDrawer>


				if activities.activeModal
					<modal />

				if activities.activeVerseAction
					<verse-actions />

				if reader.loading || parallelReader.loading || dictionary.loading || search.loading || compare.loading
					<loading>

				if pageSearch.on
					<section ease>
						css
							pos:fixed b:0 y@off:100% l:0 r:0 zi:1100
							d:flex ai:center
							p:.5rem
							bdt:1px solid $acc-bgc
							bgc:$bgc

							input
								inline-size: auto
								min-width: 4rem;
								padding: .25rem
								font-size: 1.25rem
								background: $acc-bgc focus:$acc-bgc-hover
								border: 1px solid $acc-bgc
								color: inherit
								-webkit-border-radius: .25rem
								border-radius: .25rem
								opacity: 0.7 @hover:1 @focus:1
								border-top-right-radius:0
								border-bottom-right-radius:0

							button
								opacity: 0.7 @hover:1
								d:hcc
								svg
									height: 2rem
									width: 2.25rem
									min-width: 2rem

						<[d:flex mr:1rem rd:.25rem] [ol:.25rem solid rose8/50]=(!pageSearch.matches.length && pageSearch.query.length)>
							<input#pageSearch bind=pageSearch.query
								@input=pageSearch.run @keydown.enter=pageSearch.pageSearchKeydownManager
								[direction:{textDirection(pageSearch.query)}]
								placeholder=t.find_in_chapter>
							<button @click=pageSearch.prevOccurrence title=t.prev
								[rd:0 bgc:$acc-bgc @hover:$acc-bgc-hover]>
								<svg src=ChevronUp>
							<button @click=pageSearch.nextOccurrence title=t.next
								[border-top-right-radius:.25rem border-bottom-right-radius:.25rem bgc:$acc-bgc @hover:$acc-bgc-hover]>
								<svg src=ChevronDown>

						if pageSearch.matches.length
							<p> pageSearch.current_occurrence + 1, ' / ', pageSearch.matches.length
						elif pageSearch.query.length != 0 && window.innerWidth > 640
							<p> t.phrase_not_found

						<button[c@hover:red4 ml:auto] @click=activities.cleanUp title=t.close>
							<svg src=ICONS.X aria-hidden=yes>

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



	css
		nav, aside
			h: 100vh
			position: fixed
			top: 0
			bottom: 0
			width: 300px
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

		.parallels
			d:flex
			fld@lt-sm:column
			g:1rem @lt-sm:0

			section
				max-height@lt-sm: 50vh
				-webkit-overflow-scrolling: touch

		.drawer-handle
			w:2vw w:min(1.5rem, max(1rem, 2vw))
			h:100vh
			bgc:gray4/25
			o:0 @hover:1
			d:hcc cursor:pointer zi:2 c:$acc 
