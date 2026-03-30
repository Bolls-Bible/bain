# Used to hide it on global click outside and scroll into view when selected
tag menu-popup
	prop scrollinview = yes

	def scrollInView
		unless data && scrollinview
			return
		window.requestAnimationFrame do
			# Find relative distance to the top of window
			const { top } = self.getBoundingClientRect()
			const popOverBodyHeight = self.firstChild.lastChild..clientHeight || 512
			if typeof popOverBodyHeight == 'number'
				// if the body already fits in the screen, don't scroll
				if window.innerHeight - top > popOverBodyHeight
					return
				# if it is bigger than the screen, scroll to the top
				const fitsIntoScreen = popOverBodyHeight < window.innerHeight
				if fitsIntoScreen
					scrollIntoView({ behavior: theme.scrollBehavior, block:"center" })
				else
					scrollIntoView({ behavior: theme.scrollBehavior, block:"start" })

	def render
		<self @click=scrollInView>
			<slot>

			if data
				<global @click.capture.outside=(data=no)>
