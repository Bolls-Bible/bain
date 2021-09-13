tag search-text-as-html
	def goToVerse event
		unless state.intouch
			if event.ctrlKey
				window.open("/{data.translation}/{data.book}/{data.chapter}/{data.verse}", '_blank')
			elif document.getSelection().isCollapsed
				router.go "/{data.translation}/{data.book}/{data.chapter}/{data.verse}"

	def render
		<self @click=goToVerse>
			<slot>