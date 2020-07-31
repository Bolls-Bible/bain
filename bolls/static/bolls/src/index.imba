import {Bible} from './components/Bible'
import {State} from './components/state'

let Data = State.new

Imba.mount <Bible[Data]>

import 'smoothscroll-polyfill' as smoothscroll

smoothscroll.polyfill()

tag Notification < section
	def render
		<self> if @data.notifications:length
			for notification in @data.notifications
				<p> notification

Imba.mount <Notification[Data]>
