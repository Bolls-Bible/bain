tag text-as-html < span
	prop thegiventext default: ""

	def mount
		schedule(events: yes)
		dom:innerHTML = @data:text
		@thegiventext = @data:text

	def tick
		if @data:text != @thegiventext
			dom:innerHTML = @data:text
			@thegiventext = @data:text
			render

	def render
		<self>
