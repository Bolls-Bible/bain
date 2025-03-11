import { marked } from 'marked'
import DOMPurify from 'dompurify';

tag note-tooltip
	prop text = ''
	prop containerHeight = 0
	prop containerWidth = 0
	prop bookmark = {}
	prop parallelMode = no

	#max_content_length = 0
	#left_offset = '0px'
	#right_offset = 'auto'
	#vertclass = ''
	#hortclass = ''
	#show = no

	def setBorders event
		unless (event.target == self or event.target == children[0])
			return

		#show = !#show
		event.target ||= event.target

		let offsetX = 0
		if parallelMode
			offsetX = event.layerX
		else
			offsetX = event.clientX

		if containerHeight - event.clientY < 720
			#vertclass = 'bottom'
		else
			#vertclass = ''

		if offsetX < containerWidth / 2
			#left_offset = offsetX + 'px'
			#right_offset = 'auto'
		else
			#left_offset = 'auto'
			#right_offset = (containerWidth - offsetX) + 'px'

		if containerWidth < 480
			#left_offset = 'auto'
			#right_offset = 'auto'

		let reader = document.getElementById('reader')
		if window.innerHeight - (self.offsetTop - reader.scrollTop) < 256
			let style = window.getComputedStyle(self, null).getPropertyValue('line-height')
			let line_height = parseFloat(style)
			reader.scrollTo(reader.scrollLeft, reader.scrollTop + line_height + (288 - (window.innerHeight - (self.offsetTop - reader.scrollTop))))


	def render
		<self @click.stop.prevent=setBorders>
			'\u2007\u2007'
			<slot>
			"  "
			if #show
				<note-body bookmark=bookmark .{#vertclass} [left:{#left_offset}px right:{#right_offset} w:{#max_content_length > 800 ? 48em : 'auto'} o@off:0 scale@off:0.75] ease>
				<global @click.outside=(do #show = no)>



	css
		d:inline
		font-size: 0.68em
		cursor:pointer
		vertical-align: super
		us:none
		fill:$acc-color @hover:$acc-color-hover
		stroke:$acc-color @hover:$acc-color-hover
		bg@hover:$acc-bgc-hover


		.bottom
			transform:translateY(calc(-100% - 2em))


tag note-body
	prop bookmark\any

	#inner_html = ''

	def mount
		if typeof bookmark == 'object'
			if bookmark.note
				const note = await marked.parse(DOMPurify.sanitize(bookmark.note))
				if bookmark.collection
					#inner_html = '<b>' + bookmark.collection + '</b><br>' + note
				else
					#inner_html = note
			else
				#inner_html = '<b>' + bookmark.collection + '</b>'
		else
			#inner_html = bookmark

		imba.commit!

	def render
		<self>
			<p innerHTML=#inner_html>

	css
		pos:absolute zi:1
		p:12px
		rd:12px
		border:2px solid $acc-bgc
		bg:$bgc
		min-width:16em
		max-height:256px
		us:text

	css
		p
			overflow:auto
			max-height:232px
			cursor:text
