export tag colorPicker < canvas
	prop imgData
	prop rgba

	def build
		self.width = 320
		self.height = 208
		let gradient = self:context('2d').createLinearGradient(0,0,self.width,0)
		gradient.addColorStop(0, '#ff0000')
		gradient.addColorStop(1/6, '#ffff00')
		gradient.addColorStop((1/6)*2, '#00ff00')
		gradient.addColorStop((1/6)*3, '#00ffff')
		gradient.addColorStop((1/6)*4, '#0000ff')
		gradient.addColorStop((1/6)*5, '#ff00ff')
		gradient.addColorStop(1, '#ff0000')
		self:context('2d'):fillStyle = gradient
		self:context('2d').fillRect(0, 0, self.width, self.height)

		gradient = self:context('2d').createLinearGradient(0,0,0,self.height)
		gradient.addColorStop(0, 'rgba(255, 255, 255, 1)')
		gradient.addColorStop(0.5, 'rgba(255, 255, 255, 0)')
		gradient.addColorStop(1, 'rgba(255, 255, 255, 0)')
		self:context('2d'):fillStyle = gradient
		self:context('2d').fillRect(0, 0, self.width, self.height)

		gradient = self:context('2d').createLinearGradient(0,0,0,self.height)
		gradient.addColorStop(0, 'rgba(0, 0, 0, 0)')
		gradient.addColorStop(0.5, 'rgba(0, 0, 0, 0)')
		gradient.addColorStop(1, 'rgba(0, 0, 0, 1)')
		self:context('2d'):fillStyle = gradient
		self:context('2d').fillRect(0, 0, self.width, self.height)

	def ontouchstart e
		let offsetX = (window:innerWidth - 320) / 2 + e:_x
		let offsetY = window:innerWidth <= 600 ? e:_y - (window:innerHeight - 210) : e:_y - (window:innerHeight - 383)
		@imgData = self:context('2d').getImageData(offsetX, offsetY, 1, 1)
		@rgba = @imgData:data
		data:highlight_color = "rgba(" + @rgba[0] + "," + @rgba[1] + "," + @rgba[2] + "," + @rgba[3] + ")"
		self

	def ontouchupdate e
		let offsetX = e:_x - ((window:innerWidth - 330) / 2)
		let offsetY = window:innerWidth <= 600 ? e:_y - (window:innerHeight - 210) : e:_y - (window:innerHeight - 383)
		@imgData = self:context('2d').getImageData(offsetX, offsetY, 1, 1)
		@rgba = @imgData:data
		data:highlight_color = "rgba(" + @rgba[0] + "," + @rgba[1] + "," + @rgba[2] + "," + @rgba[3] + ")"
		Imba.commit

	def onclick e
		@imgData = self:context('2d').getImageData(e:_event:offsetX, e:_event:offsetY, 1, 1)
		@rgba = @imgData:data
		data:highlight_color = "rgba(" + @rgba[0] + "," + @rgba[1] + "," + @rgba[2] + "," + @rgba[3] + ")"

	def render
		<self>