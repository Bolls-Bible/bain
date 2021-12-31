tag verse-navigator
	def unmount
		const bible = document.getElementsByTagName("BIBLE-READER")
		if bible[0]
			bible[0].clearSpace!

	def routed params
		const bible = document.getElementsByTagName("BIBLE-READER")

		if bible[0]
			let verse
			if '-' in params.verse
				verse = params.verse.split('-').map(do(el) parseInt(el))
			else
				verse = parseInt(params.verse)
			unless verse == 0
				bible[0].getChapter(params.translation, parseInt(params.book), parseInt(params.chapter), verse)


tag chapter-navigator
	def routed params
		unless window.location.pathname.split('/').length == 5
			const bible = document.getElementsByTagName("BIBLE-READER")
			if bible[0] and not window.location.pathname.endsWith('/0/')
				bible[0].getChapter(params.translation, parseInt(params.book), parseInt(params.chapter))