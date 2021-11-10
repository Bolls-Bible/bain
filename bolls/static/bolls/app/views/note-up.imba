export tag note-up
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
		unless (event.originalTarget == self or event.originalTarget == children[0])
			return

		#show = !#show
		event.originalTarget ||= event.target

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



	def inlineNote
		if typeof bookmark == 'object'
			if bookmark.collection && bookmark.note
				return '<b>' + bookmark.collection + '</b><br>' + bookmark.note
			elif bookmark.collection
				return '<b>' + bookmark.collection + '</b>'
			else return bookmark.note
		else return bookmark



	def render
		<self @click.stop.prevent=setBorders>
			'\u2007\u2007'
			<slot>
			"  "
			if #show
				<div .{#vertclass} [left:{#left_offset}px right:{#right_offset} w:{#max_content_length > 800 ? 48em : 'auto'} o@off:0 scale@off:0.75] ease>
					<p innerHTML=inlineNote()>

				<global @click.outside=(do #show = no)>



	css
		d:inline
		font-size: 0.68em
		cursor:pointer
		vertical-align: super
		white-space: pre
		us:none
		fill:$accent-color @hover:$accent-hover-color
		stroke:$accent-color @hover:$accent-hover-color
		bg@hover:$btn-bg-hover
		rd:4px


		div
			pos:absolute zi:1
			p:12px
			rd:12px
			border:2px solid $btn-bg
			bg:$background-color
			min-width:16em
			max-height:256px
			us:text
			white-space: break-spaces;

		p
			overflow:auto
			max-height:232px
			cursor:text


		.bottom
			transform:translateY(calc(-100% - 2em))