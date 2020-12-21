export tag Notifications
	def render
		<self>
			for notification in data.notifications
				<p.{notification.className} @click=data.hideNotification(notification)> notification.title

	css
		position: fixed
		bottom: 0
		right: 0
		left: 0
		display: flex
		justify-content: center
		height: 0
		z-index: 1600
		cursor: pointer

	css p
		color: var(--background-color)
		background-color: var(--accent-hover-color)
		animation: show-notification 500ms cubic-bezier(1, 0, 0, 1) both
		padding: 16px 32px
		border-radius: 16px
		position: absolute
		top: 0

	css .hide-notification
		animation-name: hide-notification



	css @keyframes
		show-notification
			0%
				top: 64px
				transform: scale(1.6)

			100%
				top: -96px
				transform: none

		hide-notification
			0%
				top: -96px
				transform: none
				opacity: 1

			100%
				top: -64px
				transform: scale(0.75)
				opacity: 0
				visibility: hidden