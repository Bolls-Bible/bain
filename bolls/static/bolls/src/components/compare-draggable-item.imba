tag compare-draggable-item
	prop genesis default: 0
	prop drag default: no
	prop topchange default: 0
	prop topinchange default: 0
	prop nodesinchange default: []
	prop scroll_on_genesis default: 0

	def ontouchstart touch
		genesis = Date.now
		self

	def ontouchupdate touch
		if (Date.now - genesis > 150 && touch.dr < 12 && touch:_event:target:className === "search_res_verse_header") || touch:_event:target:nodeName === "svg"
			drag = yes
			scroll_on_genesis = dom:parentNode:parentNode:scrollTop
		if drag
			if touch.y > dom:parentNode:parentNode:clientHeight + dom:parentNode:previousElementSibling:clientHeight
				dom:parentNode:parentNode.scroll(0, dom:parentNode:parentNode:scrollTop + 64)
			elif touch.y < dom:parentNode:offsetTop + dom:parentNode:previousElementSibling:clientHeight
				dom:parentNode:parentNode.scroll(0, dom:parentNode:parentNode:scrollTop - 64)

			flag 'dragging'
			dom:parentNode:className = 'DRAGGING'
			if dom:nextSibling
				if touch.dy > (topchange - (dom:parentNode:parentNode:scrollTop - scroll_on_genesis) + topinchange + dom:nextSibling:clientHeight)
					let node_to_change = null
					let startnode = dom:nextSibling
					while !node_to_change && startnode
						if !nodesinchange[nodesinchange.indexOf(startnode)]
							node_to_change = startnode
							nodesinchange.push startnode
						else startnode = startnode:nextSibling

					if node_to_change
						topinchange -= node_to_change:clientHeight
						node_to_change:style:transform = "translateY({dom:clientHeight + 20}px)"
						node_to_change:style:transition-duration = 0
						topchange += node_to_change:clientHeight + 20 - (dom:parentNode:parentNode:scrollTop - scroll_on_genesis)
						scroll_on_genesis = dom:parentNode:parentNode:scrollTop
						dom:parentNode.insertBefore(node_to_change, dom)
						css transform: "translateY({touch.dy - topchange}px)"
						setTimeout(&, 15) do
							topinchange += node_to_change:clientHeight
							nodesinchange.shift()
							node_to_change:style:transform = ""
							node_to_change:style:transition-duration = "300ms"
							Imba.commit
			if dom:previousSibling
				if touch.dy < (topchange - (dom:parentNode:parentNode:scrollTop - scroll_on_genesis) + topinchange - dom:previousSibling:clientHeight)
					let node_to_change = null
					let startnode = dom:previousSibling
					while !node_to_change && startnode
						if !nodesinchange[nodesinchange.indexOf(startnode)]
							node_to_change = startnode
							nodesinchange.push startnode
						else startnode = startnode:previousSibling

					if node_to_change
						topinchange += node_to_change:clientHeight
						node_to_change:style:transform = "translateY(-{dom:clientHeight + 20}px)"
						topchange -= node_to_change:clientHeight - 20 - (dom:parentNode:parentNode:scrollTop - scroll_on_genesis)
						scroll_on_genesis = dom:parentNode:parentNode:scrollTop
						dom:parentNode.insertBefore(node_to_change, dom:nextSibling)
						css transform: "translateY(-{touch.dy - topchange}px)"
						setTimeout(&, 15) do
							nodesinchange.shift()
							topinchange -= node_to_change:clientHeight
							node_to_change:style:transform = ""
							node_to_change:style:transition-duration = "300ms"
							Imba.commit
			css transform: "translateY({touch.dy - topchange + (dom:parentNode:parentNode:scrollTop - scroll_on_genesis)}px)"

	def ontouchend touch
		clearVars

	def ontouchcancel touch
		clearVars

	def clearVars
		unflag 'dragging'
		dom:parentNode:className = ''
		css transform: ''
		genesis = 0
		topchange = 0
		drag = no
		collectWhatWeHave
		topinchange = 0
		nodesinchange = []

	def collectWhatWeHave
		let arr = []
		for item in dom:parentNode:childNodes
			arr.push item:id.slice(8, 16)
		trigger('savechangestocomparetranslations', arr)


	def render
		<self id="compare_{@data:tr[0]:translation}">
			if @data:tr[0]:text
				<li.search_item>
					<.search_res_verse_text>
						for aoefv in @data:tr
							<search-text-as-html[aoefv]>
							' '
					<.search_res_verse_header>
						<svg:svg.drag_handle xmlns="http://www.w3.org/2000/svg" enable-background="new 0 0 24 24" height="32" viewBox="0 0 24 24" width="32">
							<svg:rect fill="none" height="24" width="24">
							<svg:path d="M20,9H4v2h16V9z M4,15h16v-2H4V15z">
						<span> @data:tr[0]:translation
						<svg:svg.open_in_parallel :click.prevent.copyToClipboardFromParallel(@data:tr) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 561 561" alt=@data:lang:copy>
							<svg:title> @data:lang:copy
							<svg:path d=@data:svg_paths:copy>
						<svg:svg.open_in_parallel style="margin: 0 8px;" viewBox="0 0 400 338" :click.prevent.backInHistory({translation: @data:tr[0]:translation, book: @data:tr[0]:book, chapter: @data:tr[0]:chapter,verse: @data:tr[0]:verse}, yes)>
							<svg:title> @data:lang:open_in_parallel
							<svg:path d=@data:svg_paths:columnssvg style="fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187">
						<svg:svg.remove_parallel.close_search :click.prevent.addTranslation({short_name: @data:tr[0]:translation}) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=@data:lang:delete>
							<svg:title> @data:lang:delete
							<svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" alt=@data:lang:delete>
			else
				<li.search_res_verse_header style="padding: 16px 0;display: flex; align-items: center;">
					@data:lang:the_verse_is_not_available, ' ', @data:tr[0]:translation, @data:tr[0]:text
					<svg:svg.remove_parallel.close_search style="margin: -8px 8px 0 auto;" :click.prevent.addTranslation({short_name: @data:tr[0]:translation}) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=@data:lang:delete>
						<svg:title> @data:lang:delete
						<svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" alt=@data:lang:delete>
