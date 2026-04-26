import type { Edge } from '@atlaskit/pragmatic-drag-and-drop-hitbox/types'

# type Orientation = 'horizontal' | 'vertical'
const edgeToOrientationMap\Record<Edge, 'horizontal' | 'vertical'> = {
	top: 'horizontal'
	bottom: 'horizontal'
	left: 'vertical'
	right: 'vertical'
}


export tag DropIndicator
	prop edge\Edge
	prop gap\string
	prop strokeSize = 2
	prop terminalSize = 8
	prop offsetToAlignTerminalWithLine = (strokeSize - terminalSize) / 2

	def render
		let lineOffset = "calc(-0.5 * ({gap} + {strokeSize}px))"
		let orientation = edgeToOrientationMap[edge]

		<self[
				pos:absolute zi:10 bg:blue7 pe:none

				@before
					content: ''
					width: {terminalSize}px
					height: {terminalSize}px
					box-sizing: border-box
					border: {strokeSize}px solid blue7
					border-radius: full
					pos:absolute
			]

			# Edge styles
			[top:{lineOffset} top@before:{offsetToAlignTerminalWithLine}px]=(edge=="top")
			[right:{lineOffset} right@before:{offsetToAlignTerminalWithLine}px]=(edge=="right")
			[bottom:{lineOffset} bottom@before:{offsetToAlignTerminalWithLine}px]=(edge=="bottom")
			[left:{lineOffset} left@before:{offsetToAlignTerminalWithLine}px]=(edge=="left")

			# Orientation styles
			[h:{strokeSize}px left:{terminalSize / 2}px right:0 left@before:{-terminalSize}px]=(orientation=="horizontal")
			[w:{strokeSize}px top:{terminalSize / 2}px bottom:0 top@before:{-terminalSize}px]=(orientation=="vertical")
		>
	