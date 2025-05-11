import Color from "colorjs.io"

import { setValue, getValue } from '../utils'

class CustomTheme
	# control variables. "ct" is a shortcut for "custom theme"
	@observable #color = new Color(getValue('ct-color') || 'hsl(281 44% 68%)')

	@computed get color
		return #color.to("hsl").toString()

	@observable darkness = getValue('ct-darkness') || .001525
	@observable lightness = getValue('ct-lightness') || .56625

	# all the rest should be calculated from the above
	@computed get foreground
		# calculate foreground color based on #color and lightness
		const clone = #color.to('oklab')
		clone.l = lightness
		return clone.to("hsl").toString()

	@computed get background
		# calculate background color based 	on #color and darkness
		const clone = #color.to('oklab')
		clone.l = darkness
		return clone.to("hsl").toString()

	# Subtle elevation color
	@computed get accBgc
		# should be a bit brighter than the background
		const clone = #color.to('oklab')
		if darkness > .5
			clone.l = darkness - .04
		else
			clone.l = darkness + .04
		return clone.to("hsl").toString()

	@computed get accBgcHover
		# should be a bit brighter than the background
		const clone = #color.to('oklab')
		if darkness > .5
			clone.l = darkness - .08
		else
			clone.l = darkness + .08
		return clone.to("hsl").toString()

	# Highlight color
	@computed get acc
		return #color.to("hsl").toString()

	@computed get accHover
		# should be a bit darker or brighter than the accent color depending on the lightness
		const clone = #color.to('oklab')
		if clone.l > .5
			clone.l -= .08
		else
			clone.l += .08
		return clone.to("hsl").toString()

	@computed get contrast
		const fgClone = #color.to('oklab')
		fgClone.l = lightness
		const bgClone = #color.to('oklab')
		bgClone.l = darkness
		return Math.round(bgClone.contrast(fgClone, "APCA"))

	@computed get contrastRateColor
		const contrastRate = Math.abs(contrast)
		if contrastRate > 90
			return "#77ffee"
		if contrastRate > 75
			return "#88ffcc"
		if contrastRate > 60
			return "#bbffaa"
		if contrastRate > 45
			return "#eeff44"
		if contrastRate > 30
			return "#ffcc66"
		if contrastRate > 15
			return "#ff8888"
		return "#ff0000"

	def setColor newColor
		unless newColor.detail
			return
		console.log("%cNEW COLOR", "color: {newColor.detail}; font-weight: bolder")
		#color = new Color(newColor.detail)
		imba.commit!

	def applyCustomTheme
		const colors = {
			"--bgc": background,
			"--c": foreground,
			"--acc-bgc": accBgc,
			"--acc-bgc-hover": accBgcHover,
			"--acc": acc,
			"--acc-hover": accHover
		}

		for own key, value of colors
			document.documentElement.style.setProperty(key, value)

		setValue("ct-color", color)
		setValue("ct-darkness", darkness)
		setValue("ct-lightness", lightness)
		

	def cleanUpCustomTheme
		document.documentElement.style = ""


const customTheme = new CustomTheme()

export default customTheme
