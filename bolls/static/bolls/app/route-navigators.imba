export tag verse-navigator
	def unmount
		const bible = document.getElementsByTagName("BIBLE-READER")
		if bible[0]
			bible[0].clearSpace!

	def routed params
		state = window.history.state
		if state.verse || state.parallel-verse
			window.on_pops_tate = yes
			const bible = document.getElementsByTagName("BIBLE-READER")

			if bible[0]
				if state.parallel
					bible[0].getParallelText(
						state.parallel-translation,
						parseInt(state.parallel-book),
						parseInt(state.parallel-chapter),
						parseInt(state.parallel-verse))
				else
					bible[0].getText(params.translation, parseInt(params.book), parseInt(params.chapter), parseInt(params.verse))
	<self>


export tag chapter-navigator
	def routed params
		state = window.history.state
		if state
			if state.translation
				window.on_pops_tate = yes
				const bible = document.getElementsByTagName("BIBLE-READER")
				if bible[0]
					bible[0].getText(params.translation, parseInt(params.book), parseInt(params.chapter))
	<self>