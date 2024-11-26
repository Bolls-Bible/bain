import Sortable from 'sortablejs'

import Copy from 'lucide-static/icons/copy.svg'
import SquareSplitHorizontal from 'lucide-static/icons/square-split-horizontal.svg'
import * as ICONS from 'imba-phosphor-icons'

tag compare-list
	def mount
		let sortable = new Sortable(self.firstChild, {
			animation: 150,
			ghostClass: 'in-drag',
			store:
				get: do()
					return compare.list
				set: do(sortable)
					var order = sortable.toArray()
					console.log order, compare.translations
					compare.translations = order
		})

	def copyToClipboardFromParallel tr
		let texts = []
		let verses = []
		for verse in tr
			texts.push(verse.text)
			verses.push(verse.verse)

		activities.copyWithLink({
			title: activities.getSelectedVersesTitle(tr[0].translation, tr[0].book, tr[0].chapter, verses)
			text: activities.cleanUpCopyTexts(texts),
			translation: tr[0].translation,
			book: tr[0].book,
			chapter: tr[0].chapter,
			verses: verses,
		})

	def render
		<self>
			<ul>
				for tr in compare.list
					if tr[0].text
						<li data-id=tr[0].translation>
							for verse in tr when verse.text
								<text-as-html data=verse innerHTML="{verse.text + ' '}">

							<menu>
								<svg[mr:auto cursor:move] src=ICONS.DOTS_SIX width="1.5rem" height="1.5rem" fill="currentColor" aria-hidden=yes>

								tr[0].translation

								<button @click.prevent=copyToClipboardFromParallel(tr) title=t.copy>
									<svg src=Copy aria-hidden=yes>

								<button @click.prevent=openInParallel({translation: tr[0].translation, book: tr[0].book, chapter: tr[0].chapter,verse: tr[0].verse}, yes) title=t.open_in_parallel>
									<svg src=SquareSplitHorizontal aria-hidden=yes>

								<button @click.prevent=compare.toggleTranslation({short_name: tr[0].translation}) title=t.delete>
									<svg src=ICONS.X aria-hidden=yes>

					else
						<li[p: 16px 0px mb:0 display:flex align-items:center] id=tr[0].translation key=tr[0].translation>
							<menu>
								<svg[mr:auto cursor:move] src=ICONS.DOTS_SIX width="1.5rem" height="1.5rem" fill="currentColor" aria-hidden=yes>

								t.the_verse_is_not_available, ' ', tr[0].translation

								<button @click.prevent=compare.toggleTranslation({short_name: tr[0].translation}) title=t.delete>
									<svg src=ICONS.X aria-hidden=yes>

	css
		li
			cursor:default
			fs:1.2rem

		menu
			d:flex ai:center
			g:0.25rem w:100%
			mb:0 pb:1rem
			o:0.75

			button
				bgc:transparent c:inherit @hover:$acc-hover
				min-width:1.625rem w:2rem h:100% cursor:pointer
		
global css .in-drag
	opacity:0.75 c:$acc
	transition:opacity 0.3s
