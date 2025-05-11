import { getValue, setValue } from '../utils' 

import activities from './Activities'
import customTheme from './CustomTheme'

import type { colorTheme, Accents, Accent } from './types'

const html = document.documentElement

const lights = {
	light: 'light',
	dark: 'dark',
}

class Theme
	accents\Accent[] = [
		{
			name:"blue"
			light:'hsl(219,100%,77%)'
			dark:'hsl(200,100%,32%)'
		}
		{
			name:"green"
			light:'hsl(80,100%,76%)'
			dark:'hsl(80,100%,32%)'
		}
		{
			name:"purple"
			light:'hsl(291,100%,76%)'
			dark:'hsl(291,100%,32%)'
		}
		{
			name:"gold"
			light:'hsl(43,100%,76%)'
			dark:'hsl(43,100%,32%)'
		}
		{
			name:"red"
			light:'hsl(0,100%,76%)'
			dark:'hsl(0,100%,32%)'
		}
	]

	fonts = [
		{
			name: "Sans Serif",
			code: "sans, sans-serif"
		},
		{
			name: "Raleway",
			code: "'Raleway', sans-serif"
		},
		{
			name: "David Libre",
			code: "'David Libre', serif"
		},
		{
			name: "Bellefair",
			code: "'Bellefair', serif"
		},
		{
			name: "Ezra SIL",
			code: "'Ezra SIL', serif"
		},
		{
			name: "Roboto Slab",
			code: "'Roboto Slab', sans-serif"
		},
		{
			name: "JetBrains Mono",
			code: "'JetBrains Mono', monospace"
		},
		{
			name: "Bookerly"
			code: "'Bookerly', sans-serif"
		},
		{
			name: "Deutsch Gothic",
			code: "'Deutsch Gothic', sans-serif"
		},
	]

	localFonts\Set<string> = new Set()

	def constructor
		# Detect dark mode
		try
			if window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches && !getValue('theme')
				accent = 'gold'
				theme = 'dark'
		catch error
			console.warn "This browser doesn't support window.matchMedia: ", error

		# Setup some global events handlers
		# Detect change of dark/light mode
		# Are we sure we really want this? 🤔
		try
			if window.matchMedia
				window.matchMedia('(prefers-color-scheme: dark)')
				.addEventListener('change', do|event|
					if event.matches
						theme = 'dark'
					else
						theme = 'light'
				)
		catch error
			console.warn error
		
		fontSize = getValue('font') ?? 20
		fontFamily = getValue('font-family') ?? "'Ezra SIL', serif"
		fontName = getValue('font-name') ?? "Ezra SIL"
		lineHeight = getValue('line-height') ?? 1.8
		fontWeight = getValue('font-weight') ?? 400
		maxWidth = getValue('max-width') ?? 32
		align = getValue('align') ?? ''
		transitions = getValue('transitions') ?? yes
		accent = getValue('accent') ?? 'blue'
		#theme = getValue('theme') ?? 'light'
		html.dataset.theme = #theme
		if #theme == "custom"
			customTheme.applyCustomTheme!

	def queryLocalFonts
		unless window.queryLocalFonts
			return
		# Query for all available fonts.
		try
			const availableFonts = await window.queryLocalFonts()
			# Loop through the available fonts and add them to the localFonts set
			for fontData of availableFonts
				localFonts.add(fontData.family)
		catch error
			console.warn error

	@observable #theme\colorTheme
	@observable #accent\Accents

	@computed get light
		if this.theme == 'dark' or this.theme == 'black'
			return lights.dark
		return lights.light

	set theme newTheme\colorTheme
		setValue "theme", newTheme
		html.dataset.transitions = 'false'

		html.dataset.theme = newTheme
		if newTheme != "custom"
			customTheme.cleanUpCustomTheme!

		if transitions
			imba.commit!.then do window.requestAnimationFrame do
				html.dataset.transitions = 'true'
		#theme = newTheme

	get theme
		return #theme

	set accent newAccent\Accents
		setValue "accent", newAccent
		#accent = newAccent

	get accent
		return #accent

	@autorun def setAccent
		html.dataset.accent = accent + light

	def decreaseFontSize
		if #fontSize > 14
			fontSize -= 2

	def increaseFontSize
		if #fontSize < 64 && window.innerWidth > 480
			fontSize = #fontSize + 2
		elif #fontSize < 42
			fontSize = #fontSize + 2

	set fontSize newValue\number
		setValue "font", newValue
		#fontSize = newValue

	get fontSize
		return #fontSize

	set fontFamily newValue\string
		setValue "font-family", newValue
		#fontFamily = newValue

	get fontFamily
		return #fontFamily

	set fontName newValue\string
		setValue "font-name", newValue
		#fontName = newValue

	get fontName
		return #fontName


	def setFontFamily font\{name: string, code: string}
		fontFamily = font.code
		fontName = font.name

	def setLocalFontFamily font\string
		activities.cleanUp!
		fontFamily = font
		fontName = font


	set lineHeight newValue\number
		setValue "line-height", newValue
		#lineHeight = newValue

	get lineHeight
		return #lineHeight

	def changeLineHeight up\boolean
		if up && lineHeight < 2.6
			lineHeight += 0.2
		elif lineHeight > 1.2
			lineHeight -= 0.2


	set fontWeight newValue\number
		setValue "font-weight", newValue
		#fontWeight = newValue

	get fontWeight
		return #fontWeight

	def changeFontWeight change\number
		if fontWeight + change < 1000 && fontWeight + change > 100
			fontWeight += change


	set maxWidth newValue\number
		setValue "max-width", newValue
		#maxWidth = newValue

	get maxWidth
		return #maxWidth

	def changeMaxWidth up\boolean
		if up && maxWidth < 120 && (maxWidth - 8) * fontSize < window.innerWidth
			maxWidth += 8
		elif maxWidth > 16
			maxWidth -= 8


	set align newValue\string
		setValue "align", newValue
		#align = newValue

	get align
		return #align

	def changeAlign auto\boolean
		if auto
			align = ''
		else
			align = 'justify'


	set transitions newValue\boolean
		setValue "transitions", newValue
		setTimeout(&, 0) do html.dataset.transitions = JSON.stringify(newValue)
		#transitions = newValue

	get transitions
		return #transitions

	get scrollBehavior
		if transitions
			return 'smooth'
		return 'auto'

	def applyCustomTheme
		if Math.abs(customTheme.contrast) < 15
			return
		customTheme.applyCustomTheme!
		theme = 'custom'
		activities.cleanUp!


const theme = new Theme()

export default theme