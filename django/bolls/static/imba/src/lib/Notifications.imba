import type { Notification } from './types'
import localization from './Localization'

class Notifications
	notifications\Notification[] = []
	notificationsTimeout\Timeout|null = null

	def constructor
		const searchParams = new URLSearchParams window.location.search
		if searchParams.has 'message'
			push searchParams.get 'message'

	def push notification\string
		if typeof notificationsTimeout === 'number'
			window.clearTimeout(notificationsTimeout)

		let ntfc\Notification = {
			id: Math.round(Math.random() * 4294967296)
			message: localization.lang[notification] || notification
		}

		notifications.push ntfc

		setTimeout(&, 4000) do
			hide(ntfc)
		notificationsTimeout = setTimeout(&, 4500) do
			notifications = []
			imba.commit!

		imba.commit!

	def hide notification\Notification
		notifications.find(|el| return el == notification).className = 'hide-notification'
		imba.commit!

const notifications = new Notifications()

export default notifications
