import './fonts/fontstylesheet.css'

global css
	html[data-theme="light"]
		--bgc: hsl(0, 100%, 97%)
		--c: rgb(4, 6, 12)
		--acc-bgc: hsl(256, 100%, 92%)
		--acc-bgc-hover: hsl(256, 100%, 96%)

		# /* Markdown */
		--codebg: hsla(0, 93.33%, 94.12%, 100%)
		--code: hsla(12, 6.49%, 15.1%, 100%)
		--indigo: hsla(243.65, 54.5%, 41.37%, 100%)
		--lime: hsla(85.87, 78.42%, 27.25%, 100%)
		--cyan: hsla(188.74, 94.5%, 42.75%, 100%)
		--violet: hsla(263.39, 69.96%, 50.39%, 100%)
		--orange: hsla(17.47, 88.35%, 40.39%, 100%)
		--yellow: hsla(35.45, 91.67%, 32.94%, 100%)
		--sky: hsla(200.41, 98.01%, 39.41%, 100%)
		--amber: hsla(32.13, 94.62%, 43.73%, 100%)
		--blue: hsla(224.28, 76.33%, 48.04%, 100%)
		--rose: hsla(345.35, 82.69%, 40.78%, 100%)
		--cool: hsla(220, 8.94%, 46.08%, 100%)


	html[data-theme="dark"]
		--bgc: #00061A
		--c: #B29595
		# --c: #C19A9A
		--acc-bgc: #252749
		--acc-bgc-hover: #383a6d

		# /* Markdown */
		--codebg: hsla(175.93, 60.82%, 19.02%, 50%)
		--code: hsla(140.62, 84.21%, 92.55%, 100%)
		--indigo: hsla(229.66, 93.55%, 81.76%, 100%)
		--lime: hsla(82.71, 77.97%, 55.49%, 100%)
		--cyan: hsla(186.99, 92.41%, 69.02%, 100%)
		--violet: hsla(255.14, 91.74%, 76.27%, 100%)
		--orange: hsla(27.02, 95.98%, 60.98%, 100%)
		--yellow: hsla(47.95, 95.82%, 53.14%, 100%)
		--sky: hsla(198.44, 93.2%, 59.61%, 100%)
		--amber: hsla(37.69, 92.13%, 50.2%, 100%)
		--blue: hsla(213.12, 93.9%, 67.84%, 100%)
		--rose: hsla(351.3, 94.52%, 71.37%, 100%)
		--cool: hsla(220, 8.94%, 46.08%, 100%)

	html[data-theme="sepia"]
		--bgc: rgb(235, 219, 183)
		--c: rgb(46, 39, 36)
		--acc-bgc: rgb(226, 204, 152)
		--acc-bgc-hover: rgb(230, 211, 167)

	html[data-theme="gray"]
		--bgc: #f1f1f1
		--c: black
		--acc-bgc: #d3d3d3
		--acc-bgc-hover: #e5e5e5

	html[data-theme="black"]
		--bgc: black
		--c: white
		--acc-bgc: #252749
		--acc-bgc-hover: #383a6d

	html[data-theme="white"]
		--bgc: white
		--c: black
		--acc-bgc: hsl(256, 100%, 92%)
		--acc-bgc-hover: hsl(256, 100%, 96%)


	html[data-accent="bluedark"]
		--acc: hsl(240, 100%, 75%)
		--acc-hover: hsla(219, 100%, 77%, 0.996)

	html[data-accent="bluelight"]
		--acc: hsl(240, 100%, 24%)
		--acc-hover: hsla(200, 100%, 32%, 0.996)

	html[data-accent="greendark"]
		--acc: hsl(80, 100%, 70%)
		--acc-hover: hsla(80, 100%, 76%, 0.996)

	html[data-accent="greenlight"]
		--acc: hsl(80, 100%, 24%)
		--acc-hover: hsla(80, 100%, 32%, 0.996)

	html[data-accent="purpledark"]
		--acc: hsl(291, 100%, 70%)
		--acc-hover: hsla(291, 100%, 76%, 0.996)
	
	html[data-accent="purplelight"]
		--acc: hsl(291, 100%, 24%)
		--acc-hover: hsla(291, 100%, 32%, 0.996)

	html[data-accent="golddark"]
		--acc: hsl(43, 100%, 70%)
		--acc-hover: hsla(43, 100%, 76%, 0.996)

	html[data-accent="goldlight"]
		--acc: hsl(43, 100%, 24%)
		--acc-hover: hsla(43, 100%, 32%, 0.996)

	html[data-accent="reddark"]
		--acc: hsl(0, 100%, 70%)
		--acc-hover: hsla(0, 100%, 76%, 0.996)

	html[data-accent="redlight"]
		--acc: hsl(0, 100%, 24%)
		--acc-hover: hsla(0, 100%, 32%, 0.996)


	html[data-transitions="true"] *
		transition-timing-function: cubic-bezier(0.455, 0.03, 0.515, 0.955)
		transition-delay: 0
		transition-duration: 450ms
		transition-property: color, background, width, height, transform, opacity, max-height, max-width, top, left, bottom, right, visibility, fill, stroke, margin, padding, font-size, border-color, box-shadow, border-radius

	html[data-transitions="false"] *
		transition!: none


	* 
		box-sizing: border-box
		scrollbar-color: var(--acc-bgc-hover) rgba(0, 0, 0, 0)
		scrollbar-width: auto
		margin: 0
		padding: 0
		scroll-behavior: smooth
		-webkit-tap-highlight-color: transparent
		ff:inherit
		c:inherit


	*::selection
		text-decoration-color: $bgc
		color: $bgc
		background-color: $acc-hover

	::-webkit-scrollbar-track
		background: transparent

	::-webkit-scrollbar-thumb
		background: $acc-bgc-hover
		border-radius: .25rem;

	::-webkit-scrollbar-thumb:hover
		background: $acc-bgc

	*@focus
		outline: none

	.focusable
		border-radius: .5rem
		ol@focus: 1px solid $acc-hover @focus-within: 1px solid $acc-hover
		olo@focus: -1px @focus-within: -1px

	a
		text-decoration: none


	button
		border: none
		cursor: pointer
		bgc:transparent
	
	.ws, nav, button, aside, .platform-item, img, .mark-grid, #page-search, .collectionshat
		user-select: none

	html
		m:0 p:0
		font-family: sans, sans-serif, "Apple Color Emoji", "Droid Sans Fallback", "Noto Color Emoji", "Segoe UI Emoji"
		bgc: $bgc
		color: $c
		mih: 100vh
		mih: -webkit-fill-available
		height: -webkit-fill-available
	
	body
		m:0 p:0

	mark
		c: inherit
		bgc: $acc-bgc-hover



	# Classes #
	.button
		c:$c p:.5rem 1rem ml:auto bgc:$acc-bgc @hover:$acc-bgc-hover cursor:pointer fs:inherit rd:0.25rem 

	.popup-menu
		bgc: $bgc
		pos: absolute
		right: 0
		top: calc(100% + .25rem)
		rd: .5rem
		zi: 10000000
		br: .5rem
		of: hidden
		bxs: 0 0 0 1px $acc-bgc-hover, 0 3px 6px $acc-bgc-hover, 0 9px 24px $acc-bgc-hover

		button, a
			background: transparent @hover:$acc-bgc-hover
			c: $c
			cursor: pointer
			padding: 0.75rem
			font-size: 1rem
			display: block
			width: 100%
			text-align: left
			min-width: 8rem

		.active-butt
			background: $acc-bgc

	.option-box
		d:flex ai:center
		padding-block:1rem
		cursor:pointer

	.checkbox-parent
		c:$c
		background-color: transparent
		text-align: left
		width: 100%
		font: inherit
		o: 0.8

	.checkbox
		width: 2.8em
		min-width: 2.8em
		height: 1.5em
		border: 2px solid $c
		border-radius: 2.24em
		margin-left: auto
		box-sizing: content-box

		span
			display: block
			width: 1.5em
			height: 1.5em
			background: $c
			border-radius: 0.8em
			transform: translateX(-1px)

	html[data-theme="dark"] .checkbox-turned, html[data-theme="black"] .checkbox-turned
		div
			box-shadow: inset 0 0 0.8em 0.2em currentColor

	.checkbox-turned
		o: 1
		span
			transform: translateX(1.4em)
			opacity: 1

	#iosinstall a, .rich-text a
		color: inherit
		background-image: linear-gradient($c 0px, $c 100%)

	#iosinstall a, footer a, .rich-text a, main span
		cursor: pointer
		background-repeat: no-repeat
		background-size: 100% calc(0.2em)
		background-position: 0px 110%


	@keyframes link-hover 
		0% 
			background-size: 100% 0.3em;
			background-position: 0px 110%;

		50%
			background-size: 0% 0.3em;
			background-position: 0px 110%;

		50.01%
			background-size: 0% 0.3em;
			background-position: right 0px top 110%;

		100%
			background-size: 100% 0.3em;
			background-position: right 0px top 110%;


	html[data-transitions="true"] #iosinstall a@hover, html[data-transitions="true"] .main span@hover, html[data-transitions="true"] footer a@hover,html[data-transitions="true"] .rich-text a@hover
		animation: 0.4s cubic-bezier(0.58, 0.3, 0.005, 1) 0s 1 normal none link-hover

	s
		d:none


	.definition
		a
			color:$acc @hover:$acc-hover
			text-decoration: underline
			cursor: pointer

		ol, ul
			padding-left: 2rem
			margin: 1em 0

		li > ol
			margin: 0

	.stdbtn
		c:inherit
		bgc:$acc-bgc @hover:$acc-bgc-hover
		cursor:pointer
		fs:inherit rd:0.25rem
		p:0.5rem 1rem

	@keyframes spin
		0% 
			transform: rotate(0deg)
		100%
			transform: rotate(360deg)
	
	.spin
		animation: spin 1s linear infinite

	.current_occurrence
		bgc: $acc-bgc
		filter: saturate(4)

	.another_occurrences
		bgc: $acc-bgc-hover

	.markdown
		display: block
		background-color: $acc-bgc
		max-height: 8rem
		margin: .5rem 0
		padding: .25rem .5rem
		border-radius: .25rem
		overflow: auto

	note-body, .markdown
		ul, ol
			line-height: 1.6
			padding: 1rem 0 1rem 2rem
			li
				list-style-type: disc

		a
			color: $acc @hover: $acc-hover
			font-weight: 500
			text-decoration: underline

		img
			max-width: 100%;
			height: auto;

		* 
			transition@important: none;
