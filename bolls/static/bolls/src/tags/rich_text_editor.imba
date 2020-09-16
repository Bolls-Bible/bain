# # For reference take a look at
# https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Editable_content/Rich-Text_Editing_in_Mozilla
# https://github.com/jaredreich/pell

const formatBlock = 'formatBlock'
const defaultParagraphSeparator = 'defaultParagraphSeparator' || 'div'

tag editing-area
	css
		overflow: auto
		height: 100%

	def mount
		if data.note
			innerHTML = data.note
		else
			innerHTML = ''
		setTimeout(&, 1000) do focus()

	def exec command, value = null
		document.execCommand(command, no, value)
		focus()

	def handleinput e
		const firstChild = e.target.firstChild
		if firstChild && firstChild.nodeType === 3
			exec(formatBlock, "<{defaultParagraphSeparator}>")
		elif innerHTML === '<br>'
			innerHTML = ''
		data.note = innerHTML

	def handlekeydown event
		# This enables major keybidings
		if event.ctrlKey == yes
			switch event.code
				when 'KeyI'
					event.preventDefault()
					exec('italic')
				when 'KeyB'
					event.preventDefault()
					exec('bold')
				when 'KeyU'
					event.preventDefault()
					exec('underline')
				when 'KeyE'
					event.preventDefault()
					exec('justifycenter')
				when 'KeyR'
					event.preventDefault()
					exec('justifyright')
				when 'KeyL'
					event.preventDefault()
					exec('justifyleft')
				when 'KeyJ'
					event.preventDefault()
					exec('justifyFull')

		# If tab is pressed prevent the event and insert a tab
		if event.which == 9
			event.preventDefault()

			var sel = document.getSelection()
			var range = sel.getRangeAt(0)

			var tabNode = document.createTextNode("\u00a0\u00a0\u00a0\u00a0")
			range.insertNode(tabNode)

			range.setStartAfter(tabNode)
			range.setEndAfter(tabNode)
			sel.removeAllRanges()
			sel.addRange(range)

		if event.key === 'Enter' && document.queryCommandValue(formatBlock) === 'blockquote'
			setTimeout(&, 0) do exec(formatBlock, "<{defaultParagraphSeparator}>")

	def handlepaste event
		event.preventDefault()

		def replaceInvalidCharacters string
			let specialCharacters = ["–", "’"]
			let normalCharacters = ["-", "'"]
			let regEx

			for x in [0 ... specialCharacters.length]
				regEx = RegExp.new(specialCharacters[x], 'g')
				string = string.replace(regEx, normalCharacters[x])
			return string

		let plainText = event.clipboardData.getData('text/plain')
		let cleanText = replaceInvalidCharacters(plainText)

		document.execCommand('inserttext', no, cleanText)

		# // Backup to the event.preventDefault()
		return no

	def render
		<self @keydown=handlekeydown @input=handleinput @paste=handlepaste contentEditable='true'>

export tag rich-text-editor
	def exec command, value = null
		document.execCommand(command, no, value)
		document.getElementsByTagName("editing-area")[0].focus()

	css
		width: 100%
		height: calc(100% - 50px)
		display: flex
		flex-direction: column

	css article
		display: flex
		flex-wrap: wrap
		justify-content: center
		margin-top: 8px

	css .editing-icon
		width: 32px
		padding: 4px 0
		background: transparent
		font-size: 20px
		cursor: pointer
		color: inherit @hover: var(--accent-color)

	css .editing-icon > svg
		width: 20px
		height: 20px
		fill: var(--text-color) @hover: var(--accent-color)


	def render
		<self>
			<editing-area bind=data>

			<article>
				<button.editing-icon @click.prevent.exec('bold')> <b> "B"
				<button.editing-icon @click.prevent.exec('italic')> <i> "I"
				<button.editing-icon @click.prevent.exec('underline')> <u> "U"
				<button.editing-icon @click.prevent.exec('strikeThrough')> <s> "S"
				<button.editing-icon @click.prevent.exec(formatBlock, '<h1>')>
					<b>
						'H'
						<sub> '1'
				<button.editing-icon @click.prevent.exec(formatBlock, '<h2>')>
					<b>
						'H'
						<sub> '2'
				<button.editing-icon @click.prevent.exec(formatBlock, '<p>')> '¶'
				<button.editing-icon @click.prevent.exec(formatBlock, '<blockquote>')> '“ ”'
				<button.editing-icon @click.prevent.exec('insertOrderedList') style="font-style:italic;"> '#'
				<button.editing-icon @click.prevent.exec('insertUnorderedList')> '•'
				<button.editing-icon @click.prevent.exec(formatBlock, '<pre>')> '< >'
				<button.editing-icon @click.prevent.exec('justifyleft')>
					<svg:svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
						<svg:title> "👈🏽"
						<svg:path d="M1 1h18v2H1V1zm0 8h18v2H1V9zm0 8h18v2H1v-2zM1 5h12v2H1V5zm0 8h12v2H1v-2z">
				<button.editing-icon @click.prevent.exec('justifycenter')>
					<svg:svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
						<svg:title> "🙏🏽"
						<svg:path d="M1 1h18v2H1V1zm0 8h18v2H1V9zm0 8h18v2H1v-2zM4 5h12v2H4V5zm0 8h12v2H4v-2z">
				<button.editing-icon @click.prevent.exec('justifyright')>
					<svg:svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
						<svg:title> "👉🏽"
						<svg:path d="M1 1h18v2H1V1zm0 8h18v2H1V9zm0 8h18v2H1v-2zM7 5h12v2H7V5zm0 8h12v2H7v-2z">
				<button.editing-icon @click.prevent.exec('justifyFull')>
					<svg:svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
						<svg:title> "🙌🏽"
						<svg:path d="M1 1h18v2H1V1zm0 8h18v2H1V9zm0 8h18v2H1v-2zM1 5h18v2H1V5zm0 8h18v2H1v-2z">
				unless window.navigator.vendor
					<button.editing-icon @click.prevent.exec('removeFormat')> "🧹"