export tag color-picker
	prop imgData
	prop rgba

	def mount
		firstChild.width = 320
		firstChild.height = 208
		style.width = '320px'
		style.height = '208px'
		let gradient = firstChild.getContext('2d').createLinearGradient(0,0,width,0)
		gradient.addColorStop(0, '#ff0000')
		gradient.addColorStop(1/6, '#ffff00')
		gradient.addColorStop((1/6)*2, '#00ff00')
		gradient.addColorStop((1/6)*3, '#00ffff')
		gradient.addColorStop((1/6)*4, '#0000ff')
		gradient.addColorStop((1/6)*5, '#ff00ff')
		gradient.addColorStop(1, '#ff0000')
		firstChild.getContext('2d').fillStyle = gradient
		firstChild.getContext('2d').fillRect(0, 0, width, height)

		gradient = firstChild.getContext('2d').createLinearGradient(0,0,0,height)
		gradient.addColorStop(0, 'rgba(255, 255, 255, 1)')
		gradient.addColorStop(0.5, 'rgba(255, 255, 255, 0)')
		gradient.addColorStop(1, 'rgba(255, 255, 255, 0)')
		firstChild.getContext('2d').fillStyle = gradient
		firstChild.getContext('2d').fillRect(0, 0, width, height)

		gradient = firstChild.getContext('2d').createLinearGradient(0,0,0,height)
		gradient.addColorStop(0, 'rgba(0, 0, 0, 0)')
		gradient.addColorStop(0.5, 'rgba(0, 0, 0, 0)')
		gradient.addColorStop(1, 'rgba(0, 0, 0, 1)')
		firstChild.getContext('2d').fillStyle = gradient
		firstChild.getContext('2d').fillRect(0, 0, width, height)

	def pickAColor e
		const offsetX = e.x - ((window.innerWidth - 320) / 2)
		const offsetY = e.y - (window.innerHeight - 208)
		imgData = firstChild.getContext('2d').getImageData(offsetX, offsetY, 1, 1)
		rgba = imgData.data
		data.highlight_color = "rgba(" + rgba[0] + "," + rgba[1] + "," + rgba[2] + "," + rgba[3] + ")"

	def render
		<self>
			<canvas @touch=pickAColor>

	css canvas
		position: absolute
		bottom: 0
		cursor: crosshair
		border: 2px solid var(--background-color)
		right: calc(100% / 2 - 162px)
		z-index: 3
		touch-action: none