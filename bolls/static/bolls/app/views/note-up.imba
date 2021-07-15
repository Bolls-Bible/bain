export tag note-up
	prop label = ''
	prop text = ''
	prop containerHeight = 0
	prop parentMaxWidth = 0
	prop bookmark = {}

	#left_offset = '0px'
	#right_offset = 'auto'
	#vertclass = ''
	#hortclass = ''

	def setBorders event
		if event.originalTarget.nodeName == 'P' or event.originalTarget.nodeName == 'DIV'
			return


		log containerHeight, event.layerY, containerHeight - event.layerY
		if containerHeight - event.layerY < 720
			#vertclass = 'bottom'
		else
			#vertclass = ''

		max_content_length = Math.max(bookmark.collection.length, bookmark.note.length) * 10
		if (max_content_length / 2) < parentMaxWidth
			#left_offset = event.layerX + 'px'
			#right_offset = 'auto'
			if parentMaxWidth - event.layerX < Math.max(max_content_length, 200) + 24
				#left_offset = 'auto'
				#right_offset = '0'
		else
			#left_offset = '0px'
			#right_offset = 'auto'


	def inlineNote
		if bookmark.collection && bookmark.note
			return '<b>' + bookmark.collection + '</b><br>' + bookmark.note
		elif bookmark.collection
			return '<b>' + bookmark.collection + '</b>'
		else return bookmark.note



	def render
		<self tabIndex=1 @click.stop.prevent=setBorders>
			" "
			<svg viewBox="0 0 20 20" alt=label>
				<title> label
				<path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2zm2 0v15l6-3 6 3V2H4z">
			<div .{#vertclass} [left:{#left_offset}px right:{#right_offset}]> <p innerHTML=inlineNote()>



	css
		pb:0.75em
		cursor:pointer
		fs:14px

		div
			pos:absolute zi:1
			p:12px
			rd:12px
			border:2px solid $btn-bg
			bg:$background-color
			min-width:16em
			max-height:256px

			visibility:hidden
			o:0
			transform: scale(0.75)

		p
			overflow:auto
			max-height:232px

		svg
			size:0.68em
			fill:$accent-color @hover:$accent-hover-color
			stroke:$accent-color @hover:$accent-hover-color


		@focus-within > div
			visibility:visible
			o:1
			transform:none

		@focus-within > .bottom
			transform:translateY(calc(-100% - 2em))