export tag Notifications
	def render
		<self>
			for notification in data.notifications
				<p> notification

	css
		position: fixed
		bottom: 0
		right: 0
		left: 0
		display: flex
		justify-content: center
		height: 0
		z-index: 1600

	css p
		color: var(--background-color)
		background-color: var(--accent-hover-color)
		animation: show-notification 3000ms cubic-bezier(1, 0, 0, 1) both
		padding: 16px 32px
		border-radius: 16px
		position: absolute
		top: 0