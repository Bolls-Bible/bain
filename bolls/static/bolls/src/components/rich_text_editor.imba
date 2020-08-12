# # For reference look at
# https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Editable_content/Rich-Text_Editing_in_Mozilla

export tag RichTextEditor
	def mount
		if data:note
			dom:innerHTML = data:note
		else
			dom:innerHTML = ''
		setTimeout(&, 100) do
			dom.focus()

	# def doRichEditCommand aName, aArg
	# 	getIFrameDocument('editorWindow').execCommand(aName,false, aArg)
	# 	dom:contentWindow.focus()

	def onkeyup
		data:note = dom:innerHTML


	def render
		<self>