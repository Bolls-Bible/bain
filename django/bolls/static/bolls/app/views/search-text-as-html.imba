tag search-text-as-html
	def goToVerse event
		unless state.intouch
			let route = "/{data.translation}/{data.book}/{data.chapter}"
			if data.verse
				route += "/{data.verse}"

			if event.ctrlKey
				window.open(route, '_blank')
			elif document.getSelection().isCollapsed
				router.go route
				emit "gotoverse", data

	def render
		<self [d:inline] @click=goToVerse @keyup.enter=goToVerse>
			<slot>
