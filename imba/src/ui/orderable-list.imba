import Copy from 'lucide-static/icons/copy.svg'
import SquareSplitHorizontal from 'lucide-static/icons/square-split-horizontal.svg'
import * as ICONS from 'imba-phosphor-icons'

const AUTOSCROLL_INCREMENT = 24

tag orderable-list
	#swapped_offset = 0
	#dy = 0
	#starting_scroll_y = 0
	#scroll_direction = 0
	$timer

	def mount
		$timer = setInterval(autoscroll.bind(self),50)

	def unmount
		clearInterval($timer)

	get scrolled_distance
		return parentNode.scrollTop - #starting_scroll_y

	def reorder
		unless #drugging_target
			return

		# target -- draggable item. After every swap it is a different node of DOM
		let target = document.getElementById(#drugging_target)
		let index = compare.list.indexOf(compare.list.find(do(el) return el[0].translation == #drugging_target))

		if target.nextSibling
			if #dy + scrolled_distance > #swapped_offset + (target.nextSibling.clientHeight / 2)
				if index < compare.list.length - 1
					compare.list[index + 1] = compare.list.splice(index, 1, compare.list[index + 1])[0]
					#swapped_offset += target.clientHeight + (target.nextSibling.clientHeight - target.clientHeight)
					return
		if target.previousSibling
			if #dy + scrolled_distance < #swapped_offset - (target.previousSibling.clientHeight / 2)
				if index > 0
					compare.list[index - 1] = compare.list.splice(index, 1, compare.list[index - 1])[0]
					#swapped_offset -= target.clientHeight + (target.previousSibling.clientHeight - target.clientHeight)

	def touchStart event, id\string
		#drugging_target = id
		#starting_scroll_y = parentNode.scrollTop


	def handleTouch touch
		#dy = touch.y - touch.events[0].y
		reorder!

	def touchend
		#drugging_target = ''
		#swapped_offset = 0
		#scroll_direction = 0
		await imba.commit!

		let newOrder = []
		for item in self.querySelectorAll('li')
			newOrder.push(item.id)
		compare.translations = newOrder


	def triggerAutoscroll event
		# Trigger intersect only for the target
		if event.target.id != #drugging_target
			return

		if event.delta >= 0 and event.entry.isIntersecting
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
			if parentNode.scrollTop < parentNode.scrollHeight - parentNode.clientHeight
				parentNode.scroll(0, parentNode.scrollTop + AUTOSCROLL_INCREMENT)
		elif #scroll_direction == -1
			if parentNode.scrollTop > 3
				parentNode.scroll(0, parentNode.scrollTop - AUTOSCROLL_INCREMENT)
		reorder!
		imba.commit!

	def stopIntersect
		#scroll_direction = 0

	def draggedOffset id\string
		if id == #drugging_target
			return #dy - #swapped_offset + scrolled_distance
		return 0



	<self>
		<ul @mouseup=stopIntersect>
			for tr in compare.list
				if tr[0].text
					<li id=tr[0].translation key=tr[0].translation
						@intersect(self.parentNode,1)=triggerAutoscroll
						.in-drag=(tr[0].translation == #drugging_target)
						[transform:translateY({draggedOffset(tr[0].translation)}px)]
					>
						for verse in tr when verse.text
							<text-as-html data=verse innerHTML="{verse.text} ">

						<menu>
							<svg[mr:auto cursor:move touch-action:none fls:0] src=ICONS.DOTS_SIX
								width="1.5rem" height="1.5rem" fill="currentColor" aria-hidden=yes
								@touchstart=touchStart(e, tr[0].translation)
								@touch=handleTouch
								@touchend=touchend
								@touchcancel=touchend

								@pointerdown=touchStart(e, tr[0].translation)
								@pointercancel=touchend
							>

							tr[0].translation

							<button @click.prevent=copyToClipboardFromParallel(tr) title=t.copy>
								<svg src=Copy aria-hidden=yes>

							<button @click.prevent=openInParallel({translation: tr[0].translation, book: tr[0].book, chapter: tr[0].chapter,verse: tr[0].verse}, yes) title=t.open_in_parallel>
								<svg src=SquareSplitHorizontal aria-hidden=yes>

							<button @click.prevent=compare.toggleTranslation({short_name: tr[0].translation}) title=t.delete>
								<svg src=ICONS.X aria-hidden=yes>

				else
					<li id=tr[0].translation key=tr[0].translation
						@intersect(self.parentNode,1)=triggerAutoscroll
						.in-drag=(tr[0].translation == #drugging_target)
						[transform:translateY({draggedOffset(tr[0].translation)}px) p:1rem 0px mb:0 display:flex align-items:center]>
						<menu>
							<svg[mr:auto cursor:move touch-action:none fls:0] src=ICONS.DOTS_SIX
								width="1.5rem" height="1.5rem" fill="currentColor" aria-hidden=yes
								@touchstart=touchStart(e, tr[0].translation)
								@touch=handleTouch
								@touchend=touchend
								@touchcancel=touchend

								@pointerdown=touchStart(e, tr[0].translation)
								@pointercancel=touchend
							>

							t.the_verse_is_not_available, ' ', tr[0].translation

							<button @click.prevent=compare.toggleTranslation({short_name: tr[0].translation}) title=t.delete>
								<svg src=ICONS.X aria-hidden=yes>
		<global
			@pointerup=touchend
		>

	css
		li
			cursor:default
			fs:1.2rem
			transition-property: background-color, opacity

		menu
			d:flex ai:center
			g:0.25rem w:100%
			mb:0 pb:1rem
			o:0.75

			button
				bgc:transparent c:inherit @hover:$acc-hover
				min-width:1.625rem w:2rem h:100% cursor:pointer
		
		.in-drag
			opacity:0.75 c:$acc
			zi:2
			pos:sticky
			cursor: move
