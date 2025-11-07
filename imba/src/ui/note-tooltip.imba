import { marked } from 'marked'
import DOMPurify from 'dompurify';
import { computePosition, autoUpdate, shift, offset, autoPlacement } from '@floating-ui/dom';
import type { Bookmark } from '../lib/types'
import X from 'lucide-static/icons/x.svg'


tag note-tooltip
	prop bookmark\(string|Bookmark)

	#show = no
	#textToRender = ''
	contentPosition = { x: undefined, y: undefined }
	isExpanded = no
	cleanupAutoupdate = null

	get anchorElement
		return self.childNodes[1] || self

	def updatePosition
		contentPosition = await computePosition(anchorElement, $content, {
			middleware: [offset(8), shift({ padding: 8 }), autoPlacement()],
		})

	def close
		#show = no
		contentPosition = { x: undefined, y: undefined }
		if cleanupAutoupdate
			cleanupAutoupdate()
			cleanupAutoupdate = null

	def toggle
		#show = !#show

		if !#show
			close!
			return

		# put together text to render
		if typeof bookmark == 'object'
			if bookmark.note
				const note = await marked.parse(DOMPurify.sanitize(bookmark.note))
				if bookmark.collection
					#textToRender = '<b>' + bookmark.collection + '</b><br>' + note
				else
					#textToRender = note
			else
				#textToRender = '<b>' + bookmark.collection + '</b>'
		else
			#textToRender = bookmark

		await imba.commit()
		updatePosition()

		cleanupAutoupdate = autoUpdate(
			anchorElement,
			$content,
			updatePosition.bind(this),
		);

	<self @click=toggle>
		'\u2007\u2007'
		<slot>
		"  "
		if #show
			<aside$content @click.stop [o@off:0 scale@off:0.95 origin:top center maw:{theme.maxWidth}em t:{contentPosition.y}px l:{contentPosition.x}px] ease>
				<p innerHTML=#textToRender>
				<button @click=close aria-label=t.close [pos:absolute t:0 r:0 m:0.5em bxs:none]>
					<svg src=X aria-hidden=true>

			<global @click.outside=close>

	css
		pos:relative
		d:inline
		cursor:pointer
		vertical-align: super
		us:none
		fill:$acc-color @hover:$acc-color-hover
		stroke:$acc-color @hover:$acc-color-hover
		bg@hover:$acc-bgc-hover


	css aside
		pos:fixed zi:1
		p:1rem
		rd:1rem
		border:2px solid $acc-bgc
		bg:$bgc
		min-width:8em
		us:text
		bxs:xl

		p
			font-size: 0.85em
			overflow:auto
			max-height:42vh
			h:auto
			cursor:text
