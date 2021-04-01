tag search-text-as-html
	def goToVerse event
		if event.ctrlKey
			window.open("/{data.translation}/{data.book}/{data.chapter}/{data.verse}", '_blank')
		elif document.getSelection().isCollapsed
			let bible = document.getElementsByTagName("bible-reader")
			bible[0].getText(data.translation, data.book, data.chapter, data.verse)

	def render
		<self @click=goToVerse>