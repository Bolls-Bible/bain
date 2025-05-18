import Color from "colorjs.io"

import Pipette from 'lucide-static/icons/pipette.svg'
import ChevronUp from 'lucide-static/icons/chevron-up.svg'
import ChevronDown from 'lucide-static/icons/chevron-down.svg'


const ctx = document.createElement('canvas').getContext('2d');

tag number-cell
	prop value\number
	prop up
	prop down
	prop change
	prop name\string

	#holding
	#timeout

	def cancel
		clearTimeout #timeout
		clearInterval #holding

	def hold direction
		self[direction]!
		#timeout = setTimeout(&,250) do
			#holding = setInterval(&, 50) do
				self[direction]!

	def proxyChange e
		const newValue = Number(e.target.value)
		if newValue isa 'number' and newValue != value
			change(newValue)

	<self @pointerup=cancel @pointercancel=cancel @pointerleave=cancel>
		<button @pointerdown=hold('up') aria-label='up'> 
			<svg src=ChevronUp width=1rem height=1rem aria-hidden=true>
		<input name=name type="text" value=Math.round(value) @change=proxyChange>
		<button @pointerdown=hold('down') aria-label='down'> 
			<svg src=ChevronDown width=1rem height=1rem aria-hidden=true>

	css
		d:vcc

		input
			w:2.75rem
			bgc:transparent
			font:inherit c:inherit
			fs:1em lh:1rem ta:center
			bd: none
			bxs:none rd:.5rem

		button
			w:2.75rem
			lh:1rem
			fs:1.25rem
			us:none


tag color-picker
	prop color
	oldColor = ''
	format = 'auto'
	colorAreaDims = { x: 0, y: 0, width: 256, height: 128 }
	currentColor = { r: 0, g: 0, b: 0, h: 0, s: 0, v: 0 }
	currentFormat = 'hex'

	get markerX
		return colorAreaDims.width * currentColor.s / 100

	get markerY
		return colorAreaDims.height - (colorAreaDims.height * currentColor.v / 100)

	def openPicker e
		if activities.show_color_picker
			# close the picker
			activities.show_color_picker = false
			return

		activities.show_color_picker = true
		oldColor = color
		currentFormat = getColorFormatFromStr(color)
		setColorFromStr(color)

	# Guess the color format from a string.
	# @param {string} str String representing a color.
	# @return {string} The color format.
	def getColorFormatFromStr str
		const format = str.substring(0, 3).toLowerCase();

		if format === 'rgb' || format === 'hsl'
			return format;

		return 'hex'

	# Convert HSV to RGB.
	# @param {object} hsv Hue, saturation and value values.
	# @return {object} Red, green and blue values.
	def HSVtoRGB(hsv)
		const saturation = hsv.s / 100
		const value = hsv.v / 100
		let chroma = saturation * value
		let hueBy60 = hsv.h / 60
		let x = chroma * (1 - Math.abs(hueBy60 % 2 - 1))
		let m = value - chroma

		chroma = (chroma + m)
		x = (x + m)

		const index = Math.floor(hueBy60) % 6
		const red = [chroma, x, m, m, x, chroma][index]
		const green = [x, chroma, chroma, x, m, m][index]
		const blue = [m, m, x, chroma, chroma, x][index]

		return {
			r: Math.round(red * 255),
			g: Math.round(green * 255),
			b: Math.round(blue * 255),
		}

	# Convert HSV to HSL.
	# @param {object} hsv Hue, saturation and value values.
	# @return {object} Hue, saturation and lightness values.
	def HSVtoHSL(hsv)
		const value = hsv.v / 100
		const lightness = value * (1 - (hsv.s / 100) / 2)
		let saturation

		if lightness > 0 && lightness < 1
			saturation = Math.round((value - lightness) / Math.min(lightness, 1 - lightness) * 100)

		return {
			h: hsv.h,
			s: saturation || 0,
			l: Math.round(lightness * 100),
		}

	# Convert RGB to HSV.
	# @param {object} rgb Red, green and blue values.
	# @return {object} Hue, saturation and value values.
	def RGBtoHSV rgb
		const red = rgb.r / 255
		const green = rgb.g / 255
		const blue = rgb.b / 255
		const xmax = Math.max(red, green, blue)
		const xmin = Math.min(red, green, blue)
		const chroma = xmax - xmin
		const value = xmax
		let hue = 0
		let saturation = 0

		if chroma
			if xmax === red then hue = ((green - blue) / chroma) 
			if xmax === green then hue = 2 + (blue - red) / chroma 
			if xmax === blue then hue = 4 + (red - green) / chroma 
			if xmax then saturation = chroma / xmax 

		hue = Math.floor(hue * 60)

		return {
			h: hue < 0 ? hue + 360 : hue,
			s: Math.round(saturation * 100),
			v: Math.round(value * 100),
		}

	# Parse a string to RGB.
	# @param {string} str String representing a color.
	# @return {object} Red, green and blue values.
	def strToRGB str
		const regex = /^((rgb)|rgb)[\D]+([\d.]+)[\D]+([\d.]+)[\D]+([\d.]+)[\D]*?([\d.]+|$)/i
		let match
		let rgb

		# Default to black for invalid color strings
		ctx.fillStyle = '#000'

		# Use canvas to convert the string to a valid color string
		ctx.fillStyle = str
		match = regex.exec(String(ctx.fillStyle))

		if (match)
			rgb = {
				r: match[3] * 1,
				g: match[4] * 1,
				b: match[5] * 1,
			}

		else
			match = String(ctx.fillStyle).replace('#', '').match(/.{2}/g).map(do(h) Number.parseInt(h, 16))
			rgb = {
				r: match[0],
				g: match[1],
				b: match[2],
			}

		return rgb

	# Convert RGB to Hex.
	# @param {object} rgb Red, green and blue values.
	# @return {string} Hex color string.
	def RGBToHex rgb
		let R = rgb.r.toString(16)
		let G = rgb.g.toString(16)
		let B = rgb.b.toString(16)

		if (rgb.r < 16)
			R = '0' + R

		if (rgb.g < 16)
			G = '0' + G

		if (rgb.b < 16)
			B = '0' + B

		return '#' + R + G + B

	# Convert RGB values to a CSS rgb/rgb string.
	# @param {object} rgb Red, green and blue values.
	# @return {string} CSS color string.
	def RGBToStr rgb
		return `rgb({rgb.r}, {rgb.g}, {rgb.b})`

	# Convert HSL values to a CSS hsl/hsl string.
	# @param {object} hsl Hue, saturation and lightness values.
	# @return {string} CSS color string.
	def HSLToStr hsl
		return `hsl({hsl.h}, {hsl.s}%, {hsl.l}%)`


	# Update the color picker's input field and preview thumb.
	# @param {Object} rgb Red, green and blue values.
	# @param {Object} [hsv] Hue, saturation and value values.
	def updateColor rgb = {}, hsv = {}
		for own key, value of rgb
			currentColor[key] = value

		for own key, value of hsv
			currentColor[key] = value

		# Force repaint the color gradient as a workaround for a Google Chrome bug
		$colorArea.style.display = 'none'
		$colorArea.offsetHeight
		$colorArea.style.display = ''

		if format === 'mixed'
			format = 'hex'
		else if format === 'auto'
			format = currentFormat

		switch format
			when 'hex'
				emit 'change', this.RGBToHex(currentColor)
				break
			when 'rgb'
				emit 'change', this.RGBToStr(currentColor)
				break
			when 'hsl'
				emit 'change', this.HSLToStr(this.HSVtoHSL(currentColor))
				break


	# Set the active color from a string.
	# @param {string} str String representing a color.
	def setColorFromStr str
		const rgb = strToRGB(str)
		const hsv = this.RGBtoHSV(rgb)

		updateColor(rgb, hsv)

	# Set the active color based on a specific point in the color gradient.
	# @param {number} x Left position.
	# @param {number} y Top position.
	def setColorAtPosition x, y
		const hsv = {
			h: Number.parseInt($hueSlider.value) * 1,
			s: x / colorAreaDims.width * 100,
			v: 100 - (y / colorAreaDims.height * 100),
		}
		const rgb = this.HSVtoRGB(hsv)

		updateColor(rgb, hsv)

	# Move the color marker when dragged.
	# @param {object} event The MouseEvent object.
	def moveMarker event
		setMarkerPosition(event.x, event.y)

		# Prevent scrolling while dragging the marker
		event.preventDefault()
		event.stopPropagation()

	# Move the color marker when the arrow keys are pressed.
	# @param {number} offsetX The horizontal amount to move.
	# @param {number} offsetY The vertical amount to move.
	def markerKeydown event
		const movements = {
			ArrowUp: [0, -1],
			ArrowDown: [0, 1],
			ArrowLeft: [-1, 0],
			ArrowRight: [1, 0]
		}

		if Object.keys(movements).includes(event.key)
			const [offsetX, offsetY] = movements[event.key]
			setMarkerPosition(
				markerX + offsetX,
				markerY + offsetY
			)
			event.preventDefault()

	# Set the color marker's position.
	# @param {number} x Left position.
	# @param {number} y Top position.
	def setMarkerPosition x, y
		# Make sure the marker doesn't go out of bounds
		x = (x < 0) ? 0 : (x > colorAreaDims.width) ? colorAreaDims.width : x;
		y = (y < 0) ? 0 : (y > colorAreaDims.height) ? colorAreaDims.height : y;

		# Update the color
		setColorAtPosition(x, y);

		# Make sure the marker is focused
		$colorMarker.focus()

	# Close the color picker.
	# @param {boolean} [revert] If true, revert the color to the original value.
	def closePicker revert\any?
		# revert may be an event
		if revert isa "boolean" and revert
			emit('change', oldColor)
		activities.show_color_picker = false

	def updateRGB values
		for own key, value of values
			if 0 <= value <= 255
				currentColor[key] = value
		
		const rgb = {
			r: currentColor.r,
			g: currentColor.g,
			b: currentColor.b,
		}
		const hsv = this.RGBtoHSV(rgb)

		updateColor(rgb, hsv)

	def updateHSL hsl
		for own key, value of hsl
			if key == 'h'
				if 0 <= value <= 360
					currentColor[key] = value
			else if key == 's' or key == 'v'
				if 0 <= value <= 100
					currentColor[key] = value

		const hsv = {
			h: currentColor.h,
			s: currentColor.s,
			v: currentColor.v,
		}
		const rgb = this.HSVtoRGB(hsv)

		updateColor(rgb, hsv)

	def setHue event
		const hsv = {
			h: Number.parseInt(event.target.value) * 1,
			s: currentColor.s,
			v: currentColor.v,
		}
		const rgb = this.HSVtoRGB(hsv)

		updateColor(rgb, hsv)

	get currentColorRGB
		return this.RGBToStr(currentColor)

	get currentColorHSL
		return this.HSLToStr(this.HSVtoHSL(currentColor))

	get currentColorHex
		return this.RGBToHex(currentColor)

	get currentColorWithoutOpacity
		return this.RGBToStr({ r: currentColor.r, g: currentColor.g, b: currentColor.b })

	get displayBackground
		if !activities.show_color_picker
			return color
		# return linear gradient that paints one half the old color and the other half the new color
		return `linear-gradient(to right, {oldColor} 50%, {color} 50%)`

	get pipetteColor
		const c = new Color(color).to('oklab')
		if c.l < .5
			c.l = 1
		else
			c.l = 0
		return c.to('hsl').toString()

	get offset
		if !activities.show_color_picker
			return { l: "unset", r: "unset", t:"unset", b: "unset" }
		const rect = self.getBoundingClientRect()
		return {
			l: rect.left > window.innerWidth / 2 ? "unset" : "0px",
			r: rect.left > window.innerWidth / 2 ? "0px" : "unset",
			t: rect.top > window.innerHeight / 2 ? "unset" : "calc(100% + .5rem)",
			b: rect.top > window.innerHeight / 2 ? "calc(100% + .5rem)" : "unset",
		}

	css
		pos: relative
		d:hcr
		h:2rem w:4rem
		p: 0 .5rem
		rd: .5rem

	<self[bg:{displayBackground} bgi:{displayBackground}] @click=openPicker role="button" tabIndex="0" title=t.pick_a_color>
		<svg src=Pipette width="1rem" height="1rem" [c:{pipetteColor}] aria-hidden=true>

		if activities.show_color_picker
			<global
				@click.outside=closePicker(true)
				@hotkey('esc').force.stop=closePicker(true)
				@hotkey('enter')=closePicker>

			<$picker[t:{offset.t} b:{offset.b} l:{offset.l} r:{offset.r} color:hsl({currentColor.h}, 100%, 50%)] @click.stop>
				<div$colorArea role="application" aria-label=t.colorPickerInstruction
					@click=moveMarker
					@touch.prevent.stop.fit($colorArea)=moveMarker
					@contextMenu="return false;">

				<div$colorMarker
					@keydown=markerKeydown
					@touch.prevent.fit($colorArea)=moveMarker
					[t:{markerY}px l:{markerX}px color:{currentColorWithoutOpacity}]
					tabIndex="0">

				<div.clr-hue>
					<input$hueSlider name="clr-hue-slider" type="range" min="0" max="360" step="1" aria-label=t.hueSlider value=currentColor.h @input=setHue>
					<div$hueMarker [l: {currentColor.h / 360 * 100}%]>

				<div.dial>
					"rgb("
					<number-cell
						up=(do() updateRGB({ r: currentColor.r + 1 }))
						down=(do() updateRGB({ r: currentColor.r - 1 }))
						change=(do(value) updateRGB({ r: value }))
						value=currentColor.r
						name="red"
					>
					","
					<number-cell
						up=(do() updateRGB({ g: currentColor.g + 1 }))
						down=(do() updateRGB({ g: currentColor.g - 1 }))
						change=(do(value) updateRGB({ g: value }))
						value=currentColor.g
						name="green"
					>
					","
					<number-cell
						up=(do() updateRGB({ b: currentColor.b + 1 }))
						down=(do() updateRGB({ b: currentColor.b - 1 }))
						change=(do(value) updateRGB({ b: value }))
						value=currentColor.b
						name="blue"
					>
					")"

				<div.dial>
					"hsl("
					<number-cell
						up=(do() updateHSL({ h: currentColor.h + 1 }))
						down=(do() updateHSL({ h: currentColor.h - 1 }))
						change=(do(value) updateHSL({ h: value }))
						value=currentColor.h
						name="hue">
					","
					<number-cell
						up=(do() updateHSL({ s: currentColor.s + 1 }))
						down=(do() updateHSL({ s: currentColor.s - 1 }))
						change=(do(value) updateHSL({ s: value }))
						value=currentColor.s
						name="saturation">
					","
					<number-cell
						up=(do() updateHSL({ v: currentColor.v + 1 }))
						down=(do() updateHSL({ v: currentColor.v - 1 }))
						change=(do(value) updateHSL({ v: value }))
						value=currentColor.v
						name="lightness">
					")"

				<[d:flex p:.5rem]>
					<button.action [ml:auto] type="button" @click=closePicker(true)> t.cancel
					<button.action type="button" @click=closePicker> "OK"


	css
		$picker
			bgc: $bgc
			pos: absolute zi:1101
			right: 0
			top: calc(100% + .25rem)
			w:256px
			rdb: .5rem
			bxs: 0 0 0 1px $acc-bgc-hover, 0 3px 6px $acc-bgc-hover, 0 9px 24px $acc-bgc-hover
			transition-duration: 0s

		$colorArea
			position: relative
			width: 100%
			height: 128px
			rd: .25rem .25rem 0 0
			background-image: linear-gradient(rgb(0,0,0,0), #000), linear-gradient(90deg, #fff, currentColor)
			cursor: pointer

		$colorMarker
			pos: absolute
			w: .75rem h: .75rem
			m: -0.375rem 0 0 -0.375rem
			border: 1px solid #fff
			rd: 50%
			cursor: pointer
			transition-duration: 0s

		input[type="range"]
			pos: absolute
			w: calc(100% + 2rem)
			h: 1rem
			l: -1rem
			t: -.25rem
			m: 0
			o: 0
			bgc: transparent
			cursor: pointer
			appearance: none
			-webkit-appearance: none
			transition-duration: 0s


		input[type="range"]::-webkit-slider-runnable-track
			width: 100%
			height: 1rem


		input[type="range"]::-webkit-slider-thumb
			width: 1rem
			height: 1rem
			-webkit-appearance: none


		input[type="range"]::-moz-range-track
			width: 100%
			height: 1rem
			border: 0


		input[type="range"]::-moz-range-thumb
			width: 1rem
			height: 1rem
			border: 0

		.clr-hue
			position: relative
			w: calc(100% - 2.5rem)
			height: .5rem
			margin: .25rem 1.25rem
			rd: .25rem
			background-image: linear-gradient(to right, #f00 0%, #ff0 16.66%, #0f0 33.33%, #0ff 50%, #00f 66.66%, #f0f 83.33%, #f00 100%)
			mt:1rem

			div
				position: absolute
				width: 1rem
				height: 1rem
				left: 0
				top: 50%
				margin-left: -.5rem
				transform: translateY(-50%)
				border: 2px solid #fff
				border-radius: 50%
				background-color: currentColor
				box-shadow: 0 0 1px #888
				pointer-events: none
				transition-duration: 0s

		.dial
			d:hcc
			c:$c

			span
				d:vcc

				input
					w:2.75rem
					bgc:transparent
					font:inherit c:inherit
					fs:1em lh:1rem ta:center
					bd: none
					bxs:none rd:.5rem

				button
					w:2.75rem
					lh:2rem
					fs:1.5rem

		.action
			c:$c
			bgc@hover:$acc-bgc-hover
			p:.25rem 1rem
			fs:1rem
			rd:.25rem
			fw:400
