tag search-text-as-html
	def click event
		if event.ctrlKey
			window.open("/{data.translation}/{data.book}/{data.chapter}/{data.verse}", '_blank')
		else
			emit('gettext', data)

	def render
		<self @click=click>