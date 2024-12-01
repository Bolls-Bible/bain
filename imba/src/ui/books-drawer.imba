import languages from '../data/languages.json'
import ALL_BOOKS from '../data/translations_books.json'

import HourGlassIcon from 'lucide-static/icons/hourglass.svg'
import CloudDownload from 'lucide-static/icons/cloud-download.svg'
import Heart from 'lucide-static/icons/heart.svg'
import ChevronDown from 'lucide-static/icons/chevron-down.svg'

tag books-drawer < nav
	unfoldTranslationsList = no
	unfoldedLanguage = ''
	unfoldedBook = reader.book
	
	@observable get activeTranslation
		if activities.activeTranslation && parallelReader.enabled
			return activities.activeTranslation
		return reader.translation
	
	@computed get books
		let orderBy = settings.chronorder ? 'chronorder' : 'bookid'
		return ALL_BOOKS[activeTranslation].sort(do(a, b) return a[orderBy] - b[orderBy])
	
	@computed get activeLanguage
		return languages.find(do(lang)
			return lang.translations.find(do|translation| translation.short_name == activeTranslation)
		).language
	
	@computed get activeBook
		if activeTranslation == parallelReader.translation
			return parallelReader.book
		return reader.book
	
	@computed get activeChapter
		if activeTranslation == parallelReader.translation
			return parallelReader.chapter
		return reader.chapter

	def isCurrentTranslation translation\string
		if parallelReader.enabled
			if activeTranslation == parallelReader.translation
				return translation == parallelReader.translation
			else
				return translation == reader.translation
		else
			return translation == reader.translation

	def setActiveTranslation translation\string
		activities.activeTranslation = translation

	def swapTranslations
		let main_translation = reader.translation
		let main_book = reader.book
		let main_chapter = reader.chapter
		
		reader.translation = parallelReader.translation
		reader.book = parallelReader.book
		reader.chapter = parallelReader.chapter

		parallelReader.translation = main_translation
		parallelReader.book = main_book
		parallelReader.chapter = main_chapter
	
	def toggleChronorder
		settings.chronorder = !settings.chronorder

	def toggleLanguageTranslations language\string
		if language != unfoldedLanguage
			unfoldedLanguage = language
		else unfoldedLanguage = ''

	def translationHeartFill trabbr\string
		if settings.favoriteTranslations.includes(trabbr)
			return 'currentColor'
		return 'none'

	def toggleTranslationFavor translation_short_name\string
		if translation_short_name in settings.favoriteTranslations
			settings.favoriteTranslations.splice(settings.favoriteTranslations.indexOf(translation_short_name), 1)
		else
			settings.favoriteTranslations.push(translation_short_name)

	def changeTranslation translation\string
		if parallelReader.enabled && activeTranslation == parallelReader.translation
			unless ALL_BOOKS[translation].find(do |element| return element.bookid == parallelReader.book)
				parallelReader.book = ALL_BOOKS[translation][0].bookid
				parallelReader.chapter = 1
			parallelReader.translation = translation
		else
			unless ALL_BOOKS[translation].find(do |element| return element.bookid == reader.book)
				reader.book = ALL_BOOKS[translation][0].bookid
				reader.chapter = 1
			reader.translation = translation
		unfoldTranslationsList = no

	def goToChapter bookid\number, chapter\number
		if parallelReader.enabled && activeTranslation == parallelReader.translation
			parallelReader.book = bookid
			parallelReader.chapter = chapter
		else
			reader.book = bookid
			reader.chapter = chapter

	def render
		<self>
			<header>
				if parallelReader.enabled
					<[d:flex mih:36px]>
						<button.btn title=translationFullName(reader.translation) .active=(activeTranslation == reader.translation) @click=setActiveTranslation(reader.translation)> reader.translation
						<button.btn [fw:black w:40%] @click=swapTranslations title=t.swap_parallels> "⇄"
						<button.btn title=translationFullName(parallelReader.translation) .active=(activeTranslation == parallelReader.translation) @click=setActiveTranslation(parallelReader.translation)> parallelReader.translation
				<[d:flex jc:space-between ai:center cursor:pointer padding-inline:0.5rem]>
					<svg src=HourGlassIcon
						[transform:rotate({63 * (1 - +settings.chronorder)}deg)]
						@click=toggleChronorder
						aria-label=t.chronological_order>
					<button.btn title=t.change_translation @click=(unfoldTranslationsList = !unfoldTranslationsList)>
						activeTranslation
						<svg[min-width:16px h:1.1em mb:-0.2em transform:rotate({180 * +unfoldTranslationsList}deg)] src=ChevronDown aria-label="">
					if vault.available
						<svg src=CloudDownload role="button" @click=activities.toggleDownloads aria-label=t.download>
				
			if unfoldTranslationsList
				<div[h:auto max-height:100% @off:0px o@off:0 ofy:scroll @off:hidden -webkit-overflow-scrolling:touch pb:8rem @off:0 y@off:-2rem] ease>
					if settings.favoriteTranslations.length
						<[d:flex flw:wrap ai:center p:0.5rem]>
							<svg src=Heart [size:1em stroke:$c fill:currentColor]>
							for favorite in settings.favoriteTranslations
								<span.li [w:auto p:0 8px] @click=changeTranslation(favorite)> favorite
					for language in languages
						<section key=language.language>
							<p.li .active=(language.language == activeLanguage) @click=toggleLanguageTranslations(language.language)>
								language.language
								<svg[min-width:16px h:1.1em ml:auto mb:-0.2em transform:rotate({180 * +(language.language == unfoldedLanguage)}deg)] src=ChevronDown aria-label="">
							if language.language == unfoldedLanguage
								<ul [o@off:0 m:0 0 16px @off:-24px 0 24px transition-timing-function:quad h@off:0px of:hidden] dir="auto" ease>
									for translation in language.translations
										if window.navigator.onLine || vault.downloaded_translations.indexOf(translation.short_name) != -1
											<li.li .active=(translation.short_name == activeTranslation) [display: flex]>
												<span @click=changeTranslation(translation.short_name)>
													<b> translation.short_name
													', '
													translation.full_name
												<[d:flex fld:column ml:4px]>
													<svg src=Heart [size:1em stroke:$c @hover:$acc-hover fill: {translationHeartFill(translation.short_name)}] @click.prevent.stop=toggleTranslationFavor(translation.short_name)>
									if vault.downloaded_translations.length == 0 && !window.navigator.onLine
										<p.li> t["no_translation_downloaded"]
			else
				<ul[h:auto max-height:100% @off:0px o@off:0 ofy:scroll @off:hidden -webkit-overflow-scrolling:touch pb:8rem @off:0 y@off:-2rem] ease>
					for book, index in books
						<li key=book.bookid>
							<p.li dir="auto" .active=(book.bookid == activeBook) @click=(unfoldedBook = book.bookid)> book.name
							if book.bookid == unfoldedBook
								<ul[o@off:0 m:0 0 16px @off:-24px 0 24px transition-timing-function:quad h@off:0px of:hidden] dir="auto" ease>
									for i in [0 ... book.chapters]
										<li .active=(i + 1 == activeChapter && book.bookid == activeBook) @click=goToChapter(book.bookid, i+1)>
											css
												cursor:pointer
												d:inline-block ta:center
												c@hover:$acc-hover
												h:54px w:20%
												fs:20px pt:16px
												pos:relative
											i+1
											if user.bookmarksMap[activeTranslation] and user.bookmarksMap[activeTranslation][book.bookid] and user.bookmarksMap[activeTranslation][book.bookid][i+1]
												<div[pos:absolute d:flex jc:center g:2px r:0 l:0 maw:100% flw:wrap mah:32px of:hidden] aria-hidden=true>
													for color in user.bookmarksMap[activeTranslation][book.bookid][i+1]
														<span [bgc:{color}]>

							if book.bookid == 39
								<pre[d:flex jc:center] aria-hidden=true>
									"≽^•⩊•^≼"
							if index == 65
								<pre[d:flex jc:center] aria-hidden=true>
									"-ˋˏ ༻⟡༺ ˎˊ-"

			unless activities.booksDrawerOffset
				<global @click.outside=activities.toggleBooksMenu>

	css
		.btn
			background-color: transparent
			border: none
			font-weight: bold
			text-align: center
			font-size: 20px
			width: 100%
			padding: 8px 0
			color: inherit @hover:$acc-hover
			cursor: pointer

		header > div > svg
			s:2rem
			p:0.25rem
			c@hover:$acc-hover

		.li
			d:hcs
			color:inherit
			background:inherit
			padding:0.5rem
			height:auto
			cursor:pointer
			width:100%
			fill:$c @hover:$acc-hover
			c@hover:$acc-hover
			font:inherit

			span 
				flex: 1
	
		.active
			c:$acc
