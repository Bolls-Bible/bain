import { remark } from './remark.imba'
import "./loading.imba"

import {default as BOOKS} from "./translations_books.json"

import { svg_paths } from "./svg_paths.imba"

let highlights_range = {
	from: 0,
	to: 32,
	loaded: 0
}
let collection_range = {
	from: 0,
	to: 32,
	loaded: 0
}
let notes_range = {
	from: 0,
	to: 32,
	loaded: 0
}
let query = ''
let store =
	username: ''
	name: ''
	show_options_of: ''
	collections_search: ''
	merge_replace: 'false'
	import_data: []

let extab = yes


let account_action = 0

let expand_note = -1

let taken_usernames = []
let loading = no
let importing = no

tag profile-page
	bookmarks = []
	highlights = []
	notes = []
	books = []
	collections = []
	tab = 0
	list_for_display = []
	filterTranslation
	filterBook

	def setaleup
		highlights_range = {
			from: 0,
			to: 0,
			loaded: 0
		}
		notes_range = {
			from: 0,
			to: 32,
			loaded: 0
		}
		collection_range = {
			from: 0,
			to: 32,
			loaded: 0
		}
		loading = yes
		bookmarks = []
		highlights = []
		notes = []
		query = ''
		store.show_options_of = ''
		account_action = 0
		getProfileBookmarks()
		if window.navigator.onLine
			getCategories()


	def mount
		document.title = "Bolls · " + state.userName
		setaleup!

	def loadData url
		var res = await window.fetch url
		return res.json!

	def nameOfBook bookid, translation
		for book in BOOKS[translation]
			if book.bookid == bookid
				return book.name

	def getTitleRow translation, book, chapter, verses
		let row = nameOfBook(book, translation) + ' ' + chapter + ':'
		for id, key in verses.sort(do |a, b| return a - b)
			if id == verses[key - 1] + 1
				if id == verses[key+1] - 1
					continue
				else
					row += '-' + id
			else
				!key ? (row += id) : (row += ',' + id)
		return row

	def getCategories
		const url = "/get-categories/"
		collections = []
		const resdata = await loadData(url)
		collections = resdata.data
		imba.commit()

	def parseBookmarks bookmarksdata, bookmarkstype
		let newItem = {
			verse: [],
			text: []
		}
		for item, key in bookmarksdata
			newItem.date = new Date(item.date)
			newItem.color = item.color
			newItem.collection = item.collection
			newItem.note = await remark (item.note)
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
		highlights_range.to += 32
		if highlights_range.loaded != highlights_range.to
			highlights_range.from = highlights_range.loaded

			const url = new URL("/get-profile-bookmarks/{highlights_range.from}/{highlights_range.to}/", window.origin)

			if filterTranslation
				url.searchParams.append('translation', filterTranslation)
			if filterBook
				url.searchParams.append('book', filterBook)

			let bookmarksdata
			if window.navigator.onLine
				bookmarksdata = await loadData(url)
			else
				bookmarksdata = await state.getBookmarksFromStorage() || []
			highlights_range.loaded += bookmarksdata.length
			parseBookmarks(bookmarksdata, 'highlights')
		list_for_display = highlights
		loading = no
		imba.commit!


	def getSearchedBookmarks collection
		collection_range.from = collection_range.loaded
		collection_range.to = collection_range.from + 32
		tab = 1
		if collection
			if collection != query
				collection_range.from = 0
				collection_range.to = 32
				collection_range.loaded = 0
				bookmarks = []

			query = collection
			if collection_range.loaded == collection_range.to or collection_range.loaded == 0
				const url = "/get-searched-bookmarks/{collection}/{collection_range.from}/{collection_range.to}/"
				const data = await loadData(url)
				collection_range.loaded += data[0].length
				parseBookmarks(data[0], 'bookmarks')
			list_for_display = bookmarks
			loading = no
			imba.commit()

	def getBookmarksWithNotes
		notes_range.from = notes_range.loaded
		notes_range.to = notes_range.from + 32
		tab = 2
		if notes_range.loaded == notes_range.to or notes_range.loaded == 0
			const data = await loadData("/get-notes-bookmarks/{notes_range.from}/{notes_range.to}/")
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
					getProfileBookmarks()
				else
					loading = no

			elif tab == 1
				if collection_range.loaded == collection_range.to
					getSearchedBookmarks()
				else
					loading = no

			else
				if notes_range.loaded == notes_range.to
					getBookmarksWithNotes!
				else
					loading = no


	def goToBookmark bookmark
		router.go(bookmark.translation + '/' + bookmark.book + '/' + bookmark.chapter + '/' + bookmark.verse[0] + '/')


	def showOptions title
		if store.show_options_of == title
			store.show_options_of = ''
		else
			store.show_options_of = title

	def deleteBookmark bookmark
		state.requestDeleteBookmark(bookmark.pks)
		for pk in bookmark.pks
			if bookmarks.find(do |bm| return bm.pks == pk)
				bookmarks.splice(bookmarks.indexOf(bookmarks.find(do |bm| return bm.pks == pk)), 1)
			if highlights.find(do |bm| return bm.pks == pk)
				highlights.splice(highlights.indexOf(highlights.find(do |bm| return bm.pks == pk)), 1)
		store.show_options_of = ''
		imba.commit()

	def copyToClipboard bookmark
		state.shareCopying(bookmark)
		store.show_options_of = ''

	def showDeleteForm
		account_action = 2
		store.username = ''
		window.history.pushState({profile: yes}, "Delete Account")

	def showIEport
		account_action = 3
		window.history.pushState({profile: yes}, "Export Bookmarks")

	def showEditForm
		account_action = 1
		store.username = state.user.username
		store.name = state.user.name
		window.history.pushState({profile: yes}, "Edit Account")

	def editAccountFormIsValid
		let valid = -1
		let edit_account = document.getElementById('edit_account')
		if edit_account
			for node in edit_account.childNodes
				if node.tagName == 'INPUT'
					if node.checkValidity()
						valid++
		return valid

	def editAccount
		if editAccountFormIsValid() && window.navigator.onLine
			loading = yes
			window.fetch("/edit-account/", {
				method: "POST",
				cache: "no-cache",
				headers: {
					'X-CSRFToken': state.get_cookie('csrftoken'),
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					newusername: store.username,
					newname: store.name || '',
				}),
			})
			.then(do |response|
				if response.status == 200
					state.showNotification('account_edited')
					state.user.username = store.username
					state.user.name = store.name
					state.setCookie('username', state.user.username)
					state.setCookie('name', state.user.name)
					account_action = 0
				elif response.status == 409
					taken_usernames.push store.username
					state.showNotification('username_taken')
			).catch(do |error|
				state.showNotification('error')
				console.error(error)
			)
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
				let content = JSON.parse(contents)
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
		window.fetch('/import-notes/', {
			method: "POST",
			cache: "no-cache",
			headers: {
				'X-CSRFToken': state.get_cookie('csrftoken'),
				"Content-Type": "application/json"
			},
			body: JSON.stringify({
				data: store.import_data,
				merge_replace: store.merge_replace,
			}),
		}).then(do(response)
			importing = no
			if response.status == 200
				window.location.reload!
		).catch(do(error)
			console.error error
		)

	def getFilterBooks
		if filterTranslation
			return BOOKS[filterTranslation]
		else return BOOKS['YLT']

	def updatedFilters event
		highlights_range.to = 32
		highlights_range.loaded = 0
		highlights = []
		getProfileBookmarks!

	def render
		<self @scroll=scroll>
			<header.profile_hat>
				<.collectionsflex[z-index: 100000 of:visible]>
					<a.svgBack [pos:relative m:auto 16px auto 0 l:8px] route-to='/'>
						<svg[w:20px min-width: 20px h:32px fill:inherit] viewBox="0 0 20 20">
							<title> state.lang.back
							<path d="M3.828 9l6.071-6.071-1.414-1.414L0 10l.707.707 7.778 7.778 1.414-1.414L3.828 11H20V9H3.828z">
					<h1[margin: 1em 4px]> state.userName
					if window.navigator.onLine
						<.change_password.help.popup_menu_box>
							<svg.helpsvg @click=showOptions('account_actions') xmlns="http://www.w3.org/2000/svg" viewBox="0 0 23 23">
								<title> "Edit account"
								<g transform="matrix(1.6312057,0,0,1.6312057,-7.2588652,-7.2588652)">
									<path d="M 11.5,4.45 A 7.05,7.05 0 1 0 18.55,11.5 7.058,7.058 0 0 0 11.5,4.45 Z m 4.415,11.025 c -0.5,-0.917 -2.28,-1.708 -4.415,-1.708 -2.135,0 -3.912,0.791 -4.415,1.708 a 5.95,5.95 0 1 1 8.83,0 z">
									<ellipse cx="11.5" cy="10" rx="2.375" ry="2.5">

							if store.show_options_of == 'account_actions'
								<.popup_menu [y@off:-32px o@off:0] ease>
									<button.butt @click=showEditForm()> state.lang.edit_account
									if state.user.is_password_usable
										<a @click.prevent=(do window.location = "/accounts/password_change/")>
											<button.butt> state.lang.change_password
									<button.butt @click=showIEport> 'Import / Export Bookmarks'
									<button.butt @click=showDeleteForm> state.lang.delete_account

			<div[pos:sticky t:0 bgc:$bgc zi:1]>
				<div.bookmark_filters>
					<.bookmark_select_wrapper>
						<select bind=filterTranslation @change=updatedFilters>
							<option value=false> state.lang.translation
							for own translation, value of BOOKS
								<option value=translation> translation

					<.bookmark_select_wrapper>
						<select bind=filterBook @change=updatedFilters>
							<option value=false> "-- {state.lang.book} --"
							for book in getFilterBooks!
								<option value=book.bookid> book.name
					
				<div.nav>
					<button.tab .active-tab=tab==0 @click=getProfileBookmarks()> state.lang.all
					<button.tab .active-tab=tab==1 @click=getSearchedBookmarks(0)> state.lang.collections
					<button.tab .active-tab=tab==2 @click=getBookmarksWithNotes> state.lang.notes
				
			if tab == 1
				<.collectionsflex [flex-wrap: wrap max-height:24vh of:auto]>
					if collections.length > 8
						<input.search placeholder=state.lang.search bind=store.collections_search [font:inherit c:inherit w:8em m:4px]>

					for collection in collections.filter(do(el) return el.toLowerCase!.indexOf(store.collections_search.toLowerCase!) > -1)
						<p.collection .add_new_collection=(collection==query) @click=getSearchedBookmarks(collection)> collection

					<div [min-width: 16px]>

			for bookmark, i in list_for_display
				<article.bookmark_in_list [border-color: {bookmark.color}]>
					<p.bookmark_text innerHTML=bookmark.text.join(" ") @click=goToBookmark(bookmark) dir="auto">
					if bookmark.collection
						<p.bookmark_collections>
							for collection in bookmark.collection.split(' | ')
								<p.collection @click=getSearchedBookmarks(collection)> collection
					if bookmark.note
						<p.profile_note[overflow: auto] .expand_note=(i == expand_note) innerHTML=bookmark.note dir="auto" @click=expandNote(i)>
					<p.dataflex.popup_menu_box>
						<span.booktitle dir="auto"> bookmark.title, ' ', bookmark.translation
						<time.time dateTime="bookmark.date"> bookmark.date.toLocaleString()
						<menu-popup bind=(bookmark.title == store.show_options_of)>
							<svg._options @pointerdown=showOptions(bookmark.title) viewBox="0 0 20 20">
								<title> state.lang.options
								<path d="M10 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm0-6a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm0 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4z">
							if bookmark.title == store.show_options_of
								<.popup_menu [y@off:-32px o@off:0] ease>
									<button.butt @click.stop=deleteBookmark(bookmark)> state.lang.delete
									<button.butt @click.stop=goToBookmark(bookmark)> state.lang.open
									<button.butt @click.stop=copyToClipboard(bookmark)> state.lang.copy
				<hr.hr>

			if loading
				<loading-animation[padding: 128px 0 o@off:0] ease>
			else
				<div.freespace>

			if !(highlights.length && collections.length)
				<p[text-align: center]> state.lang.thereisnobookmarks

			if !list_for_display.length && !loading
				<p[ta:center]> '(ಠ╭╮ಠ)  ¯\\_(ツ)_/¯  ノ( ゜-゜ノ)'


			if account_action
				<section.daf [pos:fixed t:0 b:0 r:0 l:0 zi:100000 bgc:#0008 h:100% d:flex jc:center p:14vh 0 @lt-sm:0 o@off:0] @click=(account_action = 0) ease>
					<div @click.stop [p:relative max-height:72vh @lt-sm:100vh max-width:468px @lt-sm:100% w:80% @lt-sm:100% bgc:$bgc bd:1px solid $acc-bgc-hover @lt-sm:none rd:16px @lt-sm:0 p:16px @lt-sm:12px m:auto scale@off:0.75]>
						if account_action == 3
							<header.search_hat [pos:relative]>
								<svg.close_search [fill@hover:firebrick pos:sticky zi:222] @click=(account_action = 0) viewBox="0 0 20 20">
									<title> 'Close'
									<path[m:auto] d=svg_paths.close>

								<div.imex_block>
									<button.imex_block_btn .active_tab=extab @click=(extab = yes)> state.lang.export
									<button.imex_block_btn .active_tab=!extab @click=(extab = no)> state.lang.import

							<article#imex>
								if extab
									<h1> state.lang.export_bookmarks
									<a download="notes.json" target="__blank" href='/download-notes'> state.lang.download + ' notes.json'
								else
									<h1> state.lang.import_bookmarks
									<input.file-input type='file' @change=readSingleFile>
									<p[m:24px 0 8px fw:600]>
										state.lang.merge_strategy

									<label>
										<input type="radio" value="false" bind=store.merge_replace>
										<p> state.lang.skip_conflicts
									<label>
										<input type="radio" value="true" bind=store.merge_replace>
										<p> state.lang.replace_existing

									<button.change_language [mt:16px] disabled=(!store.import_data.length || !importing) @click=importNotes> state.lang.import

						elif account_action == 2
							<form action="/delete-my-account/">
								<header.search_hat>
									<h1[margin:auto]> state.lang.are_you_sure
									<svg.close_search @click=(do account_action = 0) viewBox="0 0 20 20" tabindex="0">
										<title> state.lang.close
										<path d=svg_paths.close [margin:auto]>
								<p[margin-bottom:16px]> state.lang.cannot_be_undone
								<label> state.lang.delete_account_label
								<input.search bind=store.username [margin: 8px 0 border-radius:4px]>
								if store.username == state.user.username
									<button.change_language> state.lang.i_understand
								else
									<button.change_language disabled> state.lang.i_understand

						else
							<article id="edit_account">
								<header.search_hat>
									<h1[margin:auto]> state.lang.edit_account
									<svg.close_search @click=(do account_action = 0) viewBox="0 0 20 20" tabindex="0">
										<title> state.lang.close
										<path d=svg_paths.close css:margin="auto">
								<label> state.lang.edit_username_label
								<input.search bind=store.username .invalid=taken_usernames.includes(store.username) pattern='[a-zA-Z0-9_@+\.-]{1,150}' required maxlength=150 [margin:8px 0 border-radius:4px]>
								if taken_usernames.includes(store.username)
									<p.errormessage> state.lang.username_taken
								<label> state.lang.edit_name_label
								<input.search bind=store.name maxlength=30 [margin: 8px 0 border-radius:4px]>
								if editAccountFormIsValid()
									<button.change_language @click=editAccount> state.lang.edit_account
								else
									<button.change_language disabled @click=editAccount> state.lang.edit_account

			if !window.navigator.onLine
				<div[position:fixed bottom:16px left:16px color:$c background:$bgc padding:8px 16px border-radius:8px text-align:center border:1px solid $acc-bgc-hover z-index:1000]>
					state.lang.offline
					<svg[transform:translateY(0.2em) fill:$c] width="1.25em" height="1.26em" viewBox="0 0 24 24">
						<path fill="none" d="M0 0h24v24H0V0z">
						<path d="M23.64 7c-.45-.34-4.93-4-11.64-4-1.32 0-2.55.14-3.69.38L18.43 13.5 23.64 7zM3.41 1.31L2 2.72l2.05 2.05C1.91 5.76.59 6.82.36 7L12 21.5l3.91-4.87 3.32 3.32 1.41-1.41L3.41 1.31z">
					<a.reload @click=(do window.location.reload(true))> state.lang.reload

	css
		h: 100vh
		ofy: auto
		padding: 0 calc(50% - 470px) 256px
		d: block
		pos: relative


	css
		.bookmark_filters
			d:flex

		.bookmark_select_wrapper
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
		
		.bookmark_select_wrapper::after
			content: '⏷'
			position: absolute
			d:block
			zi: 11
			p:0 8px
			fs:1.2em
			lh:1.75rem
			t:0 r:0
			pointer-events: none;

		.nav
			d:flex

		.tab
			p:12px 16px
			font:inherit
			fs:0.8em
			c:inherit
			tt:uppercase
			bg:transparent @hover:$acc-bgc-hover
			bdb:4px solid transparent
			cursor:pointer

		.active-tab
			bcb:$acc-color-hover

		.expand_note
			max-height:4096px


		.imex_block
			d:flex jc:center g:8px p:4px m:0 auto

		.imex_block_btn
			font:inherit
			c:inherit
			bgc:$acc-bgc @hover:$acc-bgc-hover
			p:0 12px
			rd:4px
			cursor:pointer
			fw:bold

		.active_tab
			bgc:$acc-color-hover
			c:$bgc

		#imex
			h1
				my:16px

			a
				c:$c fw:bolder
				d:inline-block
				td:none
				p:12px
				bgc:$acc-bgc
				rd:4px

			label
				d:flex a:center
				cursor:pointer
				h:36px
			
			input[type="radio"]
				size: 36px
				appearance: none
				border:none
			
			input[type="radio"]::after
				d:block
				w:36px
				p:0 8px
				c:$c
				fs:2.4em
				content:'○'
				lh:1

			input[type="radio"]@checked::after
				content: '●'


		.file-input
			font:inherit
			w:100% h:46px
			cursor: pointer
			appearance:none

		.file-input::-webkit-file-upload-button
			visibility:hidden

		.file-input::before
			content: 'bookmaks.json'
			display: inline-block
			background:$acc-bgc
			w:auto ta:center
			border-radius: 8px
			padding: 12px 16px
			outline: none
			white-space: nowrap
			-webkit-user-select: none

		.file-input@hover::before
			bgc:$acc-bgc-hover

		.file-input@active::before
			bgc:$acc-bgc-hover
