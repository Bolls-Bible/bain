import { marked } from 'marked'
import DOMPurify from 'dompurify';

import ALL_BOOKS from '../data/translations_books.json'

import UserCog from 'lucide-static/icons/user-cog.svg'
import ArrowLeft from 'lucide-static/icons/arrow-left.svg'
import WifiOff from 'lucide-static/icons/wifi-off.svg'
import EllipsisVertical from 'lucide-static/icons/ellipsis-vertical.svg'
import * as ICONS from 'imba-phosphor-icons'

import type { ProfileBookmark, Verse } from '../lib/types'

let highlights_range = {
	from: 0,
	to: 64,
	loaded: 0
}
let collection_range = {
	from: 0,
	to: 64,
	loaded: 0
}
let notes_range = {
	from: 0,
	to: 64,
	loaded: 0
}
let query = ''
let store =
	username: ''
	name: ''
	collections_search: ''
	merge_replace: 'false'
	import_data: []

let popups = {}

let extab = yes
let account_action = 0
let expand_note = -1
let taken_usernames = []
let loading = no
let importing = no
let deleteMeErrorMessage = ''

export tag profile
	bookmarks = []
	highlights = []
	notes = []
	books = []
	tab = 0
	list_for_display = []
	@observable filterTranslation\string
	filterBook\string

	def routed
		document.title = "Bolls · " + user.username
		highlights_range = {
			from: 0,
			to: 0,
			loaded: 0
		}
		notes_range = {
			from: 0,
			to: 64,
			loaded: 0
		}
		collection_range = {
			from: 0,
			to: 64,
			loaded: 0
		}
		loading = yes
		bookmarks = []
		highlights = []
		notes = []
		query = ''
		popups = {}
		account_action = 0
		getProfileBookmarks()

	def getTitleRow translation\string, book\number, chapter\number, verses\number[]
		let row = getBookName(translation, book) + ' ' + chapter + ':'
		for id, key in verses.sort(do |a, b| return a - b)
			if id == verses[key - 1] + 1
				if id == verses[key+1] - 1
					continue
				else
					row += '-' + id
			else
				!key ? (row += id) : (row += ',' + id)
		return row

	def parseBookmarks bookmarksdata\ProfileBookmark[], bookmarkstype\string
		let newItem\({
				verse: number[],
				text: string[]
				date?: Date,
				color?: string,
				collection?: string,
				note?: string,
				translation?: string,
				book?: number,
				chapter?: number,
				verse?: Verse,
				pks?: number[],
				title?: string
			}) = {
			verse: [],
			text: []
		}
		for item, key in bookmarksdata
			newItem.date = new Date(item.date)
			newItem.color = item.color
			newItem.collection = item.collection
			newItem.note = await marked.parse(DOMPurify.sanitize(item.note))
			newItem.translation = item.verse.translation
			newItem.book = item.verse.book
			newItem.chapter = item.verse.chapter
			newItem.verse = [item.verse.verse]
			newItem.pks = [item.verse.pk]
			newItem.title = getTitleRow newItem.translation, newItem.book, newItem.chapter, newItem.verse
			if self[bookmarkstype][self[bookmarkstype].length - 1]
				if item.date == self[bookmarkstype][self[bookmarkstype].length - 1].date.getTime()
					self[bookmarkstype][self[bookmarkstype].length - 1].verse.push(item.verse.verse)
					self[bookmarkstype][self[bookmarkstype].length - 1].pks.push(item.verse.pk)
					self[bookmarkstype][self[bookmarkstype].length - 1].text.push(item.verse.text)
					self[bookmarkstype][self[bookmarkstype].length - 1].title = getTitleRow newItem.translation, newItem.book, newItem.chapter, self[bookmarkstype][self[bookmarkstype].length - 1].verse
				else
					newItem.text.push(item.verse.text)
					self[bookmarkstype].push(newItem)
					newItem = {
						verse: [],
						text: []
					}
			else
				newItem.text.push(item.verse.text)
				self[bookmarkstype].push(newItem)
				newItem = {
						verse: [],
						text: []
					}

	def getProfileBookmarks
		tab = 0
		highlights_range.to += 64
		if highlights_range.loaded != highlights_range.to
			highlights_range.from = highlights_range.loaded

			const url = new URL("/get-profile-bookmarks/{highlights_range.from}/{highlights_range.to}/", window.origin)

			if filterTranslation
				url.searchParams.append('translation', filterTranslation)
			if filterBook
				url.searchParams.append('book', filterBook)

			let bookmarksdata
			if window.navigator.onLine
				bookmarksdata = await api.getJson(url)
			else
				bookmarksdata = await vault.getBookmarks()
			highlights_range.loaded += bookmarksdata.length
			parseBookmarks(bookmarksdata, 'highlights')
		list_for_display = highlights
		loading = no
		imba.commit!


	def getSearchedBookmarks collection = ''
		collection_range.from = collection_range.loaded
		collection_range.to = collection_range.from + 64
		tab = 1
		if collection
			if collection != query
				collection_range.from = 0
				collection_range.to = 64
				collection_range.loaded = 0
				bookmarks = []

			query = collection
			if collection_range.loaded == collection_range.to or collection_range.loaded == 0
				const url = "/get-searched-bookmarks/{collection}/{collection_range.from}/{collection_range.to}/"
				const data = await api.getJson(url)
				collection_range.loaded += data[0].length
				parseBookmarks(data[0], 'bookmarks')
			list_for_display = bookmarks
			loading = no
			imba.commit()

	def getBookmarksWithNotes
		notes_range.from = notes_range.loaded
		notes_range.to = notes_range.from + 64
		tab = 2
		if notes_range.loaded == notes_range.to or notes_range.loaded == 0
			const data = await api.getJson("/get-notes-bookmarks/{notes_range.from}/{notes_range.to}/")
			notes_range.loaded += data[0].length
			parseBookmarks(data[0], 'notes')
		list_for_display = notes
		loading = no
		imba.commit()

	def scroll
		if (scrollHeight - 512 < scrollTop + window.innerHeight) && !loading && query == ''
			loading = yes
			if tab == 0
				if highlights_range.loaded == highlights_range.to
					return getProfileBookmarks()
			elif tab == 1
				if collection_range.loaded == collection_range.to
					return getSearchedBookmarks()
			else
				if notes_range.loaded == notes_range.to
					return getBookmarksWithNotes!
			loading = no

	def showOptions title\string
		if popups[title]
			delete popups[title]
		else
			popups[title] = yes

	def deleteBookmark bookmark
		reader.requestDeleteBookmark(bookmark.pks)
		for pk in bookmark.pks
			if bookmarks.find(do |bm| return bm.pks == pk)
				bookmarks.splice(bookmarks.indexOf(bookmarks.find(do |bm| return bm.pks == pk)), 1)
			if highlights.find(do |bm| return bm.pks == pk)
				highlights.splice(highlights.indexOf(highlights.find(do |bm| return bm.pks == pk)), 1)
		popups = {}
		imba.commit()

	def copyToClipboard bookmark
		activities.copyWithLink(bookmark)
		popups = {}

	def showDeleteForm
		popups['account_actions'] = no
		account_action = 2
		store.username = ''
		window.history.pushState({profile: yes}, t.delete_account)

	def showImportExport
		popups['account_actions'] = no
		account_action = 3
		window.history.pushState({profile: yes}, t.export_bookmarks)

	def showEditForm
		popups['account_actions'] = no
		account_action = 1
		store.username = user.username
		store.name = user.name
		window.history.pushState({profile: yes}, t.edit_account)

	def editAccount
		if window.navigator.onLine
			loading = yes
			try
				const response = await api.post("/edit-account/", {
					newusername: store.username,
					newname: store.name || '',
				})
				if response.status == 200
					notifications.push('account_edited')
					state.user.username = store.username
					state.user.name = store.name
					state.setCookie('username', state.user.username)
					state.setCookie('name', state.user.name)
					account_action = 0
				elif response.status == 409
					taken_usernames.push store.username
					notifications.push('username_taken')
			catch error
				notifications.push('error')
				console.error(error)
			loading = no


	def expandNote index\number
		if document.getSelection().isCollapsed
			if index == expand_note
				expand_note = -1
			else
				expand_note = index

	def readSingleFile e
		let file = e.target.files[0]
		if !file
			return

		let reader = new FileReader()
		reader.onload = do(e)
			let contents = e.target.result
			try
				let content = JSON.parse(contents\(as string))
				if typeof content == 'object'
					# Now check if the data is correct
					for item in content
						if !item.verse || !item.date || !item.color
							throw 'bad file'
					# log 'good', content
					store.import_data = content
					imba.commit!

			catch e
				log e
				window.alert('Bad file!')
			# log contents
		reader.readAsText(file)


	def importNotes
		importing = yes
		try
			const response = await api.post('/import-notes/', {
				data: store.import_data,
				merge_replace: store.merge_replace,
			})
			if response.status == 200
				window.location.reload!
		catch error
			console.error error
			importing = no
			notifications.push('error')

	get filteredBooks
		if filterTranslation
			return ALL_BOOKS[filterTranslation]
		else return ALL_BOOKS['YLT']

	def updatedFilters
		highlights_range.to = 64
		highlights_range.loaded = 0
		highlights = []
		getProfileBookmarks!
	
	def isDeleteMeFromValid e 
		# if the form is invalid -- simply block it, otherwise let it go through
		if store.username !== user.username
			e.preventDefault!
			e.stopPropagation!
			deleteMeErrorMessage = t.username_mismatch



	<self @scroll=scroll>
		<header[z-index:100000 of:visible d:flex ws:nowrap]>
			<a[pos:relative my:auto mr:1rem l:.5rem d:flex ai:center c@hover:$acc] route-to='/' title=t.back>
				<svg src=ArrowLeft aria-hidden=yes>

			<h1[margin:1rem 0.25rem]> user.username

			if window.navigator.onLine
				<menu-popup[pos:relative ml:auto r:.5rem] bind=popups['account_actions']>
					<button[h:100%] @click=showOptions('account_actions') title=t.edit_account>
						<svg src=UserCog aria-hidden=yes>

					if popups['account_actions']
						<.popup-menu [y@off:-2rem o@off:0 r:.5rem] ease>
							<button @click=showEditForm> t.edit_account
							if user.is_password_usable
								<button @click.prevent=(do window.location.assign "/accounts/password_change/")> t.change_password
							<button @click=showImportExport> "{t.import} / {t.export_bookmarks}"
							<button @click=showDeleteForm> t.delete_account

		<div[pos:sticky t:0 bgc:$bgc zi:1]>
			<div[d:flex]>
				<.select-wrapper>
					<select bind=filterTranslation @change=updatedFilters>
						<option value=false> t.translation
						for own translation, value of ALL_BOOKS
							<option value=translation> translation

				<.select-wrapper>
					<select bind=filterBook @change=updatedFilters>
						<option value=false> "-- {t.book} --"
						for book in filteredBooks
							<option value=book.bookid> book.name
				
			<div[d:flex]>
				css
					button
						p:.75rem 1rem
						font:inherit
						fs:0.8em
						c:inherit
						tt:uppercase
						bg:transparent @hover:$acc-bgc-hover
						bdb:4px solid transparent
						cursor:pointer

					.active-tab
						bcb:$acc-hover

				<button .active-tab=tab==0 @click=getProfileBookmarks()> t.all
				<button .active-tab=tab==1 @click=getSearchedBookmarks('')> t.collections
				<button .active-tab=tab==2 @click=getBookmarksWithNotes> t.notes

		if tab == 1
			<[d:flex flw:wrap mah:24vh of:auto p:.5rem]>
				if user.categories.length > 8
					<input[w:8em p:.25rem m:4px fs:1.25rem bgc:$acc-bgc @focus:$acc-bgc-hover bd:1px solid $acc-bgc font:inherit c:inherit rd:.25rem o:.7 @hover:1] placeholder=t.search bind=store.collections_search>

				for collection in user.categories.filter(do(el) return el.toLowerCase!.indexOf(store.collections_search.toLowerCase!) > -1)
					<p.pill .selected-pill=(collection==query) @click=getSearchedBookmarks(collection)> collection

				<[min-width:1rem]>

		for bookmark, i in list_for_display
			<article[my:.5rem p:.5rem bdl:.5rem solid {bookmark.color}]>
				<a[d:block fs:1.125rem] innerHTML=bookmark.text.join(" ") route-to="/{bookmark.translation}/{bookmark.book}/{bookmark.chapter}/{bookmark.verse[0]}/" dir="auto">
				if bookmark.collection
					<p[p:.5rem o:.8]>
						for collection in bookmark.collection.split(' | ')
							<span.pill @click=getSearchedBookmarks(collection)> collection
				if bookmark.note
					# todo use imba to animate height
					<div.markdown [max-height:auto]=(i == expand_note) innerHTML=bookmark.note dir="auto" @click=expandNote(i)>
				<p[d:flex ai:center]>
					<span[fw:500] dir="auto"> bookmark.title, ' ', bookmark.translation
					<time[ml:auto o:.8] dateTime=bookmark.date> bookmark.date.toLocaleString()
					<menu-popup[pos:relative] bind=popups[bookmark.date]>
						<button @click.stop=showOptions(bookmark.date) title=t.options>
							<svg src=EllipsisVertical aria-hidden=yes>
						if popups[bookmark.date]
							<.popup-menu [y@off:-2rem o@off:0] ease>
								<button @click.stop=copyToClipboard(bookmark)> t.copy
								<a route-to="/{bookmark.translation}/{bookmark.book}/{bookmark.chapter}/{bookmark.verse[0]}/"> t.open
								<button @click.stop=deleteBookmark(bookmark)> t.delete
			<hr[w:92% m:0 4% bd:none bdt:1px solid $acc-bgc]>

		if loading or importing
			<loading>

		if !highlights.length
			<p[text-align: center]> t.highlights_placeholder

		if !list_for_display.length && !loading
			<p[ta:center]> '(ಠ╭╮ಠ)  ¯\\_(ツ)_/¯  ノ( ゜-゜ノ)'

		console.log(account_action)
		if account_action
			<global @hotkey('escape')=(account_action=0)> <section
				[pos:fixed inset:0 bg:rgba(0,0,0,0.75) h:100% d:htc p:14vh 0 @lt-sm:0 o@off:0 zi:99]
				@click=(account_action = 0) ease>

				<[
					pos:relative
					d:flex fld:column as:center
					max-height:72vh @lt-sm:100vh
					block-size@lt-sm:100vh
					max-width:30em @lt-sm:100%
					w:82% @lt-sm:100%
					bgc:$bgc bd:1px solid $acc-bgc-hover @lt-sm:none
					bxs: 0 0 0 1px $acc-bgc, 0 1px 6px $acc-bgc, 0 3px 2.25rem $acc-bgc, 0 9px 12.5rem -4rem $acc-bgc @lt-sm:none
					rd:1rem @lt-sm:0
					p:1rem @lt-sm:0.75rem
					scale@off:0.75] @click.stop>

					css
						header
							d:hcc
							g:0.25rem
							button@has(svg)
								w:1.5rem
								min-width:1.5rem
							h2
								m:auto ta:center

						button
							bgc:transparent c:inherit @hover:$acc-hover
							cursor:pointer
							d:flex fls:0
						
						form
							button
								mt:1rem w:100%

						svg
							min-inline-size: 1.5rem
							min-block-size: 1.5rem

						h2
							margin: 1rem auto
							-webkit-line-clamp: 2
							overflow: hidden
							display: -webkit-box
							-webkit-box-orient: vertical
							fs:1.25em

						input[type="text"]
							w:100%
							p:.25rem 0.5rem
							m:.5rem 0
							fs:1.25em
							lh:2rem
							color: inherit
							bgc: $acc-bgc
							border: 1px solid $acc-bgc
							rd: .25rem
							border-radius: .25rem
							o:.7 @focin:1 @hover:1

					# Import/export
					if account_action == 3
						<header [pos:relative]>
							<[d:hcc g:.5rem p:.25rem m:0 auto]>
								css 
									button
										font:inherit
										c:inherit
										bgc:$acc-bgc @hover:$acc-bgc-hover
										p:.5rem .75rem
										rd:4px
										cursor:pointer
										fw:bold

									.active-action
										bgc:$acc-hover
										c:$bgc

								<button .active-action=extab @click=(extab = yes)> t.export
								<button .active-action=!extab @click=(extab = no)> t.import

							<button @click=(account_action = 0) title=t.close>
								<svg src=ICONS.X [c@hover:red4] aria-hidden=true>

						<form @submit.prevent.stop=importNotes>
							css
								label
									d:flex a:center
									cursor:pointer
									h:2.25rem
								
								input[type="radio"]
									size: 2.25rem
									appearance: none
									border:none
								
								input[type="radio"]::after
									d:block
									w:2.25rem
									p:0 .5rem
									c:$c
									fs:2.4em
									content:'○'
									lh:1

								input[type="radio"]@checked::after
									content: '●'


								input[type="file"]
									font:inherit
									w:100% h:2.875rem
									cursor: pointer
									appearance:none

								input[type="file"]::-webkit-file-upload-button
									visibility:hidden

								input[type="file"]::before
									content: 'bookmaks.json'
									display: inline-block
									background:$acc-bgc
									w:auto ta:center
									border-radius: .5rem
									padding: 0.75rem 1rem
									outline: none
									white-space: nowrap
									-webkit-user-select: none

								input[type="file"]@hover::before, input[type="file"]@active::before
									bgc:$acc-bgc-hover

							if extab
								<h2> t.export_bookmarks
								<a[w:100% ta:center] download="notes.json" target="__blank" href='/download-notes/'> t.download + ' notes.json'
							else
								<h2> t.import_bookmarks
								<input required=yes type='file' @change=readSingleFile>
								<p[m:1.5rem 0 .5rem fw:600]>
									t.merge_strategy

								<label>
									<input type="radio" name="merge-strategy" value="false" bind=store.merge_replace required>
									t.skip_conflicts
								<label>
									<input type="radio" name="merge-strategy" value="true" bind=store.merge_replace>
									t.replace_existing

								<button disabled=(importing) > t.import

					# Delete account
					elif account_action == 2
						<header>
							<h2> t.are_you_sure
							<button @click=(account_action = 0) title=t.close>
								<svg src=ICONS.X [c@hover:red4] aria-hidden=true>
						<form @submit=isDeleteMeFromValid action="/delete-my-account/" method="post">
							<p[my:1rem]> t.cannot_be_undone
							<input type="hidden" name="csrfmiddlewaretoken" value=api.get_cookie('csrftoken')>
							<label>
								t.delete_account_label
								<input type="text" bind=store.username required placeholder=t.delete_account_label>
							if deleteMeErrorMessage
								<p[c:indianred]> deleteMeErrorMessage
							<button> t.i_understand

					# edit account
					else
						<header>
							<h2> t.edit_account
							<button @click=(account_action = 0) title=t.close>
								<svg src=ICONS.X [c@hover:red4] aria-hidden=true>

						<form @submit.prevent.stop=editAccount>
							<label>
								t.edit_username_label
								<input type="text" bind=store.username [box-shadow: 0 0 0 2px #aa3344]=taken_usernames.includes(store.username) pattern='[a-zA-Z0-9_@+\\.\\-]{1,150}' required min=1 max=150 placeholder="john_doe">
							if taken_usernames.includes(store.username)
								<p[mb:1rem c:indianred fs:1.125rem]> t.username_taken
							<label>
								t.edit_name_label
								<input type="text" bind=store.name max=30 placeholder="John Doe">
							<button> t.edit_account

		else
			<global @hotkey('escape')=(router.go('/'))>

		if !window.navigator.onLine
			<div[pos:fixed b:1rem l:1rem p:.5rem 1rem rd:.5rem ta:center border:1px solid $acc-bgc-hover zi:1000]>
				t.offline
				' '
				<svg[transform:translateY(0.2em) fill:$c] src=WifiOff width="1.25rem" height="1.25rem" aria-hidden=true>
				<a[display:block mt:.5rem w:100% cursor:pointer text-decoration:solid underline y@hover:-2px] @click=(do window.location.reload(true))> t.reload

	css
		h: 100vh
		ofy: auto
		padding: 0 calc(50% - 30rem) 8rem
		d: block
		pos: relative


	css
		.select-wrapper
			position: relative

		select
			font-size: 1rem
			position: relative
			font-weight: 400
			font-style: normal
			font-stretch: normal
			padding: 0 1.75rem 0 0.5rem
			display: block
			height: 100%
			color: inherit
			font-size: 1rem
			line-height: 1.75rem
			letter-spacing: .025em
			appearance: none
			border: none
			background: $bgc
			width: 100%
			min-width: 140px
			cursor: pointer
			z-index: 10
		
		.select-wrapper::after
			content: '⏷'
			position: absolute
			d:block
			zi: 11
			p:0 8px
			fs:1.2em
			lh:1.75rem
			t:0 r:0
			pointer-events: none;

		.pill
			display: inline-block
			margin: .25rem
			background: $acc-bgc
			padding: .25rem .5rem
			cursor: pointer
			border: 1px solid acc-bgc
			border-radius: .25rem

		.selected-pill
			background: $acc-hover @hover:$acc
			c: $bgc

		form
			h1
				my:1rem

			a, button
				c:$c @hover: $acc-hover
				fw:bolder
				d:inline-block
				td:none
				p:0.75rem
				bgc:$acc-bgc @hover:$acc-bgc-hover
				rd:.25rem
			
			label@has(input[type="text"])
				display: flex
				fld: column
