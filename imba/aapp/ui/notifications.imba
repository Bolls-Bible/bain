tag notifications
	def render
		<self>
			for notification in notifications.notifications
				<p.{notification.className} @click=notifications.hide(notification)> notification.message

	css
		position: fixed
		b:0 r:0 l:0
		d:hcc
		height:0
		zi:1600
		cursor:pointer

	css p
		color: $bgc
		bgc: $acc-hover
		animation: show-notification 500ms cubic-bezier(1, 0, 0, 1) both
		p: 16px 32px
		border-radius: 16px
		position:absolute
		top: 0

	css .hide-notification
		animation-name: hide-notification



	css @keyframes
		show-notification
			0%
				top: 32px
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
				top: 0px
				transform: scale(0.75)
				opacity: 0
				visibility: hidden
