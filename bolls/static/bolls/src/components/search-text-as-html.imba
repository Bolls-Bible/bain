tag search-text-as-html < span
	def mount
		schedule(events: yes)
		dom:innerHTML = @data:text

	def tick
		if @data:text != dom:innerHTML
			dom:innerHTML = @data:text
			render

	def onclick event
		if event:_event:ctrlKey
			window.open("/{@data:translation}/{@data:book}/{@data:chapter}/{@data:verse}", '_blank')
		else
			trigger('gettext', @data)

	def render
		<self>