# Used to hide it on global click and scroll into view when selected
export tag menu-popup
	prop show = no

	def render
		<self @click=scrollIntoView({behavior:'smooth', block:"center"})>
			<slot>

			if data
				<global @click.capture.outside.stop=(data=no;log data)>