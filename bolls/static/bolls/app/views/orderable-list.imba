import {svg_paths} from "./svg_paths"
import './search-text-as-html'

tag orderable-list
	prop list = []
	#swapped_offset = 0
	#dy = 0
	#scroll_direction = 0
	#initial_parent_scroll = 0

	def mount
		$timer = setInterval(autoscroll.bind(self),25)

	def unmount
		clearInterval($timer)


	def reorder touch, id
		#dy = touch.y - touch.events[0].y
		state.intouch = yes

		unless #drugging_target
			#drugging_target = id
			#initial_parent_scroll = parentNode.scrollTop

		else
			# target -- draggable item. After every swap it is a different node of DOM
			let target = document.getElementById(#drugging_target)
			let index = list.indexOf(list.find(do(el) return el[0].translation == #drugging_target))

			# log target
			if target.nextSibling
				if #dy + scrolledOffset! > #swapped_offset + (target.nextSibling.clientHeight / 2)
					if index < list.length - 1
						list[index + 1] = list.splice(index, 1, list[index + 1])[0]
						#swapped_offset += target.nextSibling.clientHeight
			if target.previousSibling
				if #dy + scrolledOffset! < #swapped_offset - (target.previousSibling.clientHeight / 2)
					if index > 0
						list[index - 1] = list.splice(index, 1, list[index - 1])[0]
						#swapped_offset -= target.previousSibling.clientHeight


		if touch.phase == 'ended'
			touchend(touch)


	def touchend touch
		#drugging_target = ''
		#swapped_offset = 0
		#scroll_direction = 0
		#initial_parent_scroll = parentNode.scrollTop
		await imba.commit!

		.then do state.intouch = no
		let arr = []
		for item in childNodes
			arr.push item.id

		saveCompareChanges(arr)



	def triggerAutoscroll event
		# Trigger intersect only for the target
		if event.target.id != #drugging_target
			return

		if event.delta >= 0 and event.entry.isIntersecting
			# log 'in'
			stopIntersect!
			return

		# Autoscroll when on the top/bottom edge of the app
		let boundingClientRect = event.entry.boundingClientRect
		if boundingClientRect.top < window.innerHeight / 2
			#scroll_direction = -1
		else
			#scroll_direction = 1


	def autoscroll
		if #scroll_direction == 1
			# Prevent scrolling to bottom if the target is already the last one
			if list.indexOf(#drugging_target) != list.length - 1
				parentNode.scroll(0, parentNode.scrollTop + 8)
		elif #scroll_direction == -1
			if parentNode.scrollTop > 3
				parentNode.scroll(0, parentNode.scrollTop - 8)
		imba.commit!

	def stopIntersect
		#scroll_direction = 0

	def scrolledOffset
		return parentNode.scrollTop - #initial_parent_scroll

	def draggedOffset item
		if item == #drugging_target
			return #dy - #swapped_offset + scrolledOffset!
		return 0

	def druggable id
		return id == #drugging_target


	def render
		<self[d:block] @mouseup=stopIntersect>
			for item in list
				if item[0].text
					<div.search_item .draggable=(druggable item[0].translation) id=item[0].translation [transform:translateY({draggedOffset(item[0].translation)}px)] @intersect(self.parentNode,100)=triggerAutoscroll>
						<div.search_res_verse_text>
							for aoefv in item
								<search-text-as-html data=aoefv innerHTML="{aoefv.text + ' '}">

						<div.search_res_verse_header [mb:0 pb:16px]>
							<svg.drag_handle @touch=reorder(e, item[0].translation) xmlns="http://www.w3.org/2000/svg" enable-background="new 0 0 24 24" viewBox="0 0 24 24">
								<path d="M20,9H4v2h16V9z M4,15h16v-2H4V15z">
							<span> item[0].translation

							<svg.open_in_parallel @click.prevent.copyToClipboardFromParallel(item) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 561 561" alt=state.lang.copy>
								<title> state.lang.copy
								<path d=svg_paths.copy>


							<svg.open_in_parallel [margin: 0 8px] viewBox="0 0 400 338" @click.prevent.backInHistory({translation: item[0].translation, book: item[0].book, chapter: item[0].chapter,verse: item[0].verse}, yes)>
								<title> state.lang.open_in_parallel
								<path d=svg_paths.columnssvg style="fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187">

							<svg.remove_parallel.close_search @click.prevent.addTranslation({short_name: item[0].translation}) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=state.lang.delete>
								<title> state.lang.delete
								<path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z">
				else
					<div.search_res_verse_header .draggable=(druggable item[0].translation) id=item[0].translation [p: 16px 0px mb:0 display:flex align-items:center transform:translateY({draggedOffset(item[0].translation)}px)] @intersect(self.parentNode,100)=triggerAutoscroll>
						<svg.drag_handle [margin-right: 16px] @touch=reorder(e, item[0].translation) xmlns="http://www.w3.org/2000/svg" enable-background="new 0 0 24 24" viewBox="0 0 24 24">
							<path d="M20,9H4v2h16V9z M4,15h16v-2H4V15z">

						state.lang.the_verse_is_not_available, ' ', item[0].translation, item[0].text

						<svg.remove_parallel.close_search [margin: -8px 8px 0 auto] @click.prevent.addTranslation({short_name: item[0].translation}) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=state.lang.delete>
							<title> state.lang.delete
							<path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z">


	css
		self > div
			p:8px

		.draggable
			zi:2
			pos:sticky
			o:0.75
			cursor: move
			transition-property@important:background-color, opacity
