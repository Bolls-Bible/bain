tag text-as-html
	def goToVerse event
		let route = "/{data.translation}/{data.book}/{data.chapter}"
		if data.verse
			route += "/{data.verse}"

		if event.ctrlKey
			window.open(route, '_blank')
		elif document.getSelection().isCollapsed
			reader.translation = data.translation
			reader.book = data.book
			reader.chapter = data.chapter
			reader.verse = data.verse

	def render
		<self [d:inline dir:auto] dir=translationTextDirection(data.translation) @click=goToVerse>
			<slot>
