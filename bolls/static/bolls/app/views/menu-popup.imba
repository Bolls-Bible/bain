# Used to hide it on global click and scroll into view when selected
tag menu-popup
	prop show = no
	prop scrollinview = yes

	def scrollInView
		if scrollinview
			if window.innerHeight > 640
				scrollIntoView({behavior:'smooth', block:"center"})
			else
				scrollIntoView({behavior:'smooth', block:"start"})


	def render
		<self @click=scrollInView>
			<slot>

			if data
				<global @click.capture.outside=(data=no)>