tag text-as-html
	def goToVerse event
		// state.intouch is defined when the element is a child of ordered list at the copare translations modal
		unless state..intouch
			let route = "/{data.translation}/{data.book}/{data.chapter}"
			if data.verse
				route += "/{data.verse}"

			if event.ctrlKey
				window.open(route, '_blank')
			elif document.getSelection().isCollapsed
				router.go route
				emit "gotoverse", data

	def render
		<self [d:inline dir:auto] dir=translationTextDirection(data.translation) @click=goToVerse>
			<slot>
