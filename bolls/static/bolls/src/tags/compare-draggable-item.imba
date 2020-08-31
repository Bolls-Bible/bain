import {svg_paths} from "./svg_paths"
import './search-text-as-html'

tag compare-draggable-item
	prop genesis = 0
	prop drag = no
	prop topchange = 0
	prop topinchange = 0
	prop nodesinchange = []
	prop scroll_on_genesis = 0
	prop lang

	def mount
		console.log lang, lang.copy

	def touchHandler touch
		console.log touch.type
		# touch.dx = touch.x - touch.events[0].x
		# touch.dy = touch.y - touch.events[0].y

		unless drag
			scroll_on_genesis = parentNode.parentNode.scrollTop
			drag = yes
		if touch.y > parentNode.parentNode.clientHeight + parentNode.previousElementSibling.clientHeight
			parentNode.parentNode.scroll(0, parentNode.parentNode.scrollTop + 64)
		elif touch.y < parentNode.offsetTop + parentNode.previousElementSibling.clientHeight
			parentNode.parentNode.scroll(0, parentNode.parentNode.scrollTop - 64)

		className = 'dragging'
		parentNode.className = 'DRAGGING'
		if nextSibling
			if touch.dy > (topchange - (parentNode.parentNode.scrollTop - scroll_on_genesis) + topinchange + nextSibling.clientHeight)
				let node_to_change = null
				let startnode = nextSibling
				while !node_to_change && startnode
					if !nodesinchange[nodesinchange.indexOf(startnode)]
						node_to_change = startnode
						nodesinchange.push startnode
					else startnode = startnode.nextSibling

				if node_to_change
					topinchange -= node_to_change.clientHeight
					node_to_change.style.transform = "translateY({clientHeight + 20}px)"
					node_to_change.style.transition-duration = 0
					topchange += node_to_change.clientHeight + 20 - (parentNode.parentNode.scrollTop - scroll_on_genesis)
					scroll_on_genesis = parentNode.parentNode.scrollTop
					parentNode.insertBefore(node_to_change, dom)
					style.transform = "translateY({touch.dy - topchange}px)"
					setTimeout(&, 15) do
						topinchange += node_to_change.clientHeight
						nodesinchange.shift()
						node_to_change.style.transform = ""
						node_to_change.style.transition-duration = "300ms"
						Imba.commit
		if previousSibling
			if touch.dy < (topchange - (parentNode.parentNode.scrollTop - scroll_on_genesis) + topinchange - previousSibling.clientHeight)
				let node_to_change = null
				let startnode = previousSibling
				while !node_to_change && startnode
					if !nodesinchange[nodesinchange.indexOf(startnode)]
						node_to_change = startnode
						nodesinchange.push startnode
					else startnode = startnode.previousSibling

				if node_to_change
					topinchange += node_to_change.clientHeight
					node_to_change.style.transform = "translateY(-{clientHeight + 20}px)"
					topchange -= node_to_change.clientHeight - 20 - (parentNode.parentNode.scrollTop - scroll_on_genesis)
					scroll_on_genesis = parentNode.parentNode.scrollTop
					parentNode.insertBefore(node_to_change, nextSibling)
					style.transform = "translateY(-{touch.dy - topchange}px)"
					setTimeout(&, 15) do
						nodesinchange.shift()
						topinchange -= node_to_change.clientHeight
						node_to_change.style.transform = ""
						node_to_change.style.transition-duration = "300ms"
						Imba.commit
		style.transform = "translateY({touch.dy - topchange + (parentNode.parentNode.scrollTop - scroll_on_genesis)}px)"

		if touch.type.slice(-2) == 'up' or touch.type.slice(-6) == 'cancel'
			touchend(touch)

	def touchend touch
		clearVars()

	def touchcancel touch
		clearVars()

	def clearVars
		className = ''
		parentNode.className = ''
		style.transform = ''
		genesis = 0
		topchange = 0
		drag = no
		collectWhatWeHave()
		topinchange = 0
		nodesinchange = []

	def collectWhatWeHave
		let arr = []
		for item in parentNode.childNodes
			arr.push item.id.slice(8, 16)
		emit('savechangestocomparetranslations', arr)
		savechangestocomparetranslations arr


	def render
		<self id="compare_{data[0].translation}">
			if data[0].text
				<li.search_item>
					<.search_res_verse_text>
						for aoefv in data
							<search-text-as-html innerHTML="{aoefv.text + ' '}">

					<.search_res_verse_header>
						<svg.drag_handle @touch=touchHandler xmlns="http://www.w3.org/2000/svg" enable-background="new 0 0 24 24" viewBox="0 0 24 24">
							<path d="M20,9H4v2h16V9z M4,15h16v-2H4V15z">
						<span> data[0].translation

						<svg.open_in_parallel @click.prevent.copyToClipboardFromParallel(data) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 561 561" alt=lang.copy>
							<title> lang.copy
							<path d=svg_paths.copy>

						<svg.open_in_parallel style="margin: 0 8px;" viewBox="0 0 400 338" @click.prevent.backInHistory({translation: data[0].translation, book: data[0].book, chapter: data[0].chapter,verse: data[0].verse}, yes)>
							<title> lang.open_in_parallel
							<path d=svg_paths.columnssvg style="fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187">

						<svg.remove_parallel.close_search @click.prevent.addTranslation({short_name: data[0].translation}) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=lang.delete>
							<title> lang.delete
							<path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z">
			else
				<li.search_res_verse_header style="padding: 16px 0;display: flex; align-items: center;">
					lang.the_verse_is_not_available, ' ', data[0].translation, data[0].text
					<svg.remove_parallel.close_search style="margin: -8px 8px 0 auto;" @click.prevent.addTranslation({short_name: data[0].translation}) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=lang.delete>
						<title> lang.delete
						<path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z">
