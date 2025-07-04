import Copy from 'lucide-static/icons/copy.svg'
import Link from 'lucide-static/icons/link.svg'
import ChevronDown from 'lucide-static/icons/chevron-down.svg'
import Dices from 'lucide-static/icons/dices.svg'
import Share from 'lucide-static/icons/share.svg'
import Split from 'lucide-static/icons/split.svg'
import NotebookPen from 'lucide-static/icons/notebook-pen.svg'
import Bookmark from 'lucide-static/icons/bookmark.svg'
import Facebook from 'lucide-static/icons/facebook.svg'
import Eraser from 'lucide-static/icons/eraser.svg'
import Plus from 'lucide-static/icons/plus.svg'
import X from 'lucide-static/icons/x.svg'

import * as ICONS from 'imba-phosphor-icons'

const DEFAULT_Y = 32

const colors = [
	'FireBrick'
	'Chocolate'
	'GoldenRod'
	'OliveDrab'
	'RoyalBlue'
	'RebeccaPurple'
]

tag verse-actions < section
	#isSliding = null
	#dy = DEFAULT_Y
	categoriesSearch = ''

	def close
		# should await for the transition-duration property update to achieve smoothness
		#dy = DEFAULT_Y
		imba.commit!.then do
			activities.cleanUp!

	def touchHandler event
		#dy = Math.max(event.y - event.y0, -DEFAULT_Y) + DEFAULT_Y
		#isSliding = null

		if event.phase == "ended"
			if #dy > DEFAULT_Y * 2
				event.preventDefault()
				close!
			#isSliding = null
			#dy = DEFAULT_Y
		

	get transitionDuration
		return #dy == DEFAULT_Y ? '0.5s' : '0s'


	def byteCount s\string
		window.encodeURI(s).split(/%..|./).length - 1


	get canShareViaTelegram
		return byteCount("https://t.me/share/url?url={window.encodeURIComponent("https://bolls.life" + '/'+ activities.copyObject.translation + '/' + activities.copyObject.book + '/' + activities.copyObject.chapter + '/' + activities.versesRange(activities.copyObject.verses) + '/')}&text={window.encodeURIComponent('«' + activities.copyObject.text + '»\n\n' + activities.copyObject.title + ' ' + activities.copyObject.translation)}") < 4096

	def telegramSharing
		const text = '«' + activities.copyObject.text + '»\n\n' + activities.copyObject.title + ' ' + activities.copyObject.translation
		const url = "https://bolls.life" + '/'+ activities.copyObject.translation + '/' + activities.copyObject.book + '/' + activities.copyObject.chapter + '/' + activities.versesRange(activities.copyObject.verses) + '/'
		const link = "https://t.me/share/url?url={window.encodeURIComponent(url)}&text={window.encodeURIComponent(text)}"
		if byteCount(link) < 4096
			window.open(link, '_blank')

	get sharedText
		const text = '«' + activities.copyObject.text + '»\n\n' + activities.copyObject.title + ' ' + activities.copyObject.translation + "https://bolls.life" + '/'+ activities.copyObject.translation + '/' + activities.copyObject.book + '/' + activities.copyObject.chapter + '/' + activities.versesRange(activities.copyObject.verses) + '/'
		return text

	get canMakeTweet
		return sharedText.length < 281

	def makeTweet
		window.open("https://twitter.com/intent/tweet?text={window.encodeURIComponent(sharedText)}", '_blank')
		activities.cleanUp!

	def shareViaFB
		window.open("https://www.facebook.com/sharer.php?u=https://bolls.life/" + activities.copyObject.translation + '/' + activities.copyObject.book + '/' + activities.copyObject.chapter + '/' + activities.versesRange(activities.copyObject.verses) + '/', '_blank')
		activities.cleanUp!

	def shareViaWhatsApp
		window.open("https://api.whatsapp.com/send?text={window.encodeURIComponent(sharedText)}", '_blank')
		activities.cleanUp!

	def deleteBookmark
		if activities.selectedParallel == 'main'
			reader.deleteBookmark activities.selectedVersesPKs
		else
			parallelReader.deleteBookmark activities.selectedVersesPKs

	def showAddNewCategory
		activities.show_add_bookmark = yes
		imba.commit!.then do $newcategoryinput.focus()

	<self [y:{#dy}px @off:100% o@off:0 transition-duration:{transitionDuration}] ease
			@touch.fit(self)=touchHandler
		>
		<svg.chevron src=ChevronDown @click=close>
		<header>
			<span role="button" @click=activities.copyTextToClipboard(activities.selectedVersesTitle)>
				activities.selectedVersesTitle
			<button @click=activities.saveBookmark> t.save

		<ul>
			<li[d:inline-flex ai:center jc:center cursor:pointer c@hover:$acc m:0 0.25rem]>
				<svg src=Dices width="2rem" height="2rem" role="button" aria-label=t.random
				@click=(activities.highlight_color = activities.randomColor)>

			<li.color-option[scale:unset]>
				<color-picker[w:100%] color=activities.highlight_color @change=activities.setHighlightColor>

			for color in colors
				<li.color-option [background:{color}] title=color role="button" aria-label=color
					@click=activities.changeHighlightColor(color)>


		<menu>
			if reader.selectionHasBookmark or parallelReader.selectionHasBookmark
				<li>
					<button @click=deleteBookmark>
						<svg src=Eraser aria-hidden=yes>
						t.delete
			<li>
				<menu-popup bind=activities.show_sharing>
					<button @click=(do activities.show_sharing = !activities.show_sharing)>
						<svg src=Share aria-hidden=yes>
						t.share
						if activities.show_sharing
							<.popup-menu [l:0 @lt-sm:0.5rem top:unset b:calc(100% + .25rem) y@off:2rem o@off:0 w:14rem] ease>
								<button @click=shareViaWhatsApp>
									<svg src=ICONS.WHATSAPP_LOGO aria-hidden=yes>
									"What's App"
								<button @click=shareViaFB>
									<svg src=Facebook aria-hidden=yes>
									"Facebook"
								if canMakeTweet then <button @click=makeTweet>
									<svg src=ICONS.X_LOGO aria-hidden=yes>
									"𝕏"
								if canShareViaTelegram then <button @click=telegramSharing>
									<svg src=ICONS.TELEGRAM_LOGO aria-hidden=yes>
									"Telegram"
								<button @click=activities.copyWithInternationalLink>
									<svg src=ICONS.TRANSLATE aria-hidden=yes>
									t.copy_international
								<button @click=(do()
										activities.copyWithLink(activities.copyObject)
										activities.cleanUp!
									)>
										<svg src=Link aria-hidden=yes>
										t.copy_with_link

			<li>
				<button @click=activities.copyWithoutLink>
					<svg src=Copy aria-hidden=yes>
					t.copy
			<li>
				<button @click=compare.load>
					<svg src=Split aria-hidden=yes>
					t.compare
			<li>
				<button @click=activities.openModal('notes')>
					<svg src=NotebookPen aria-hidden=yes>
					t.note
			<li>
				<menu-popup bind=activities.show_bookmarks>
					<button @click=activities.toggleBookmarks .applied=(activities.selectedCategories.length > 0)>
						<svg src=Bookmark aria-hidden=yes>
						t.bookmark
					css
						input
							w:100% bg:transparent
							font:inherit c:inherit
							fs:1em lh:2rem
							ol@focin:2px solid $acc-bgc
							bd: 1px solid $acc-bgc
							bdb@invalid:1px solid $acc-bgc
							bxs:none rd:.5rem
							py:.25rem
							px:.75rem

					if activities.show_bookmarks
						<.popup-menu [r:0 @lt-sm:0.5rem top:unset b:calc(100% + 4px) y@off:2rem o@off:0 w:14rem] ease>
							<header[d:vcc p:.5rem]>
								t.saveto
								if user.categories.length > 0
									<input type="text" placeholder=t.search bind=self.categoriesSearch />
							css
								ol
									mah: 50vh
									overflow-y: auto
									p:0 .3rem
									d:flex flw:wrap gap:.25rem
									li
										p:0
										button
											bgc:$acc-bgc
											miw:fit-content
										.selected
											bgc:$acc-hover @hover:$acc
											c:$bgc

							if user.categories.length > 0 or activities.selectedCategories.length > 0 then <ol>
								for category in activities.selectedCategories when !user.categories.includes(category)
									<li>
										<button.selected @click=activities.addCategoryToSelected(category)>
											category
								for category in user.categories when category.toLowerCase().includes(categoriesSearch.toLowerCase())
									<li>
										<button
											.selected=(activities.selectedCategories.includes(category))
											@click=activities.addCategoryToSelected(category)>
												category
							<button[d:hcc p:0.5rem 1rem mt:.25rem] @click=showAddNewCategory>
								<svg src=Plus aria-hidden=yes>
								t.new_collection

					<menu-popup bind=activities.show_add_bookmark>
						if activities.show_add_bookmark
							<form.popup-menu
								[r:0 @lt-sm:0.5rem top:unset b:calc(100% + 4px) y@off:2rem o@off:0 w:14rem] ease
								@submit.prevent.stop=activities.addNewCategory>
								<[d:flex p:.5rem pos:relative]>
									css
										input
											px:.75rem 2.25rem

										button
											size:2.5rem miw:2.5rem 
											pos:absolute r:.5rem top:50% y:-50%

									<input$newcategoryinput
										type="text"
										minLength=2
										# should not have white space
										pattern="^(?!.* \\| ).*"
										required
										placeholder=t.new_collection
										bind=activities.newCategoryName />
									<button
										[p:0 jc:center bgc@hover:transparent]
										type="button"
										@click=activities.show_add_bookmark=no
									>
										<svg src=X aria-hidden=yes>
								<button[jc:center]>
									t.create_collection

	css
		pos:fixed b:0 l:0 r:0 zi:1100
		w:100% bgc:$bgc
		bdt:1px solid $acc-bgc
		ta:center
		d:vcc
		padding-block:1rem 2.5rem

		.chevron
			pos:absolute
			top:-0.25rem
			scale-x: 2
			scale-y: 0.5
			stroke: $acc-bgc-hover

		button
			fs:0.875rem

		header
			d:hcs
			g:0.5rem

			span
				cursor:copy

			button
				bgc:transparent @hover:$acc-bgc-hover
				bxs@hover: 0 0.5rem $acc-bgc-hover, 0 -0.5rem $acc-bgc-hover
				tt:uppercase fw:700
				c:$acc-hover @hover:$acc
				padding-inline:1rem m:0
				cursor:pointer

		ul
			white-space: nowrap
			padding-block: 1rem .5rem
			padding-inline: 0.5rem
			max-width: 100%
			d:hcc
			g:.325rem

		.color-option
			size:2rem
			border-radius: 23%
			cursor: pointer
			border: 1px solid $acc-bgc-hover @hover: 1px solid $bgc
			scale@hover: 1.2

		menu
			d:hcc
			pos:relative
			flw:wrap

			button
				display:hcl g:.25rem
				c:$c @hover:$acc
				bgc:$acc-bgc @hover:$acc-bgc-hover
				bgc:transparent
				padding:0.5rem 0.75rem
				cursor:pointer
				rd:0.25rem

				svg
					size:1rem

		.popup-menu
			> button
				font:inherit
				p:0.75rem
				rd:0

		li
			list-style-type: none
			d:inline-block
		
		.applied
			c@important:$acc
