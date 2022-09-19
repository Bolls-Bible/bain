import { State } from './state.imba'
import './views/Bible.imba'
import './views/donate.imba'
import './views/Profile.imba'
import './views/downloads.imba'
import { Notifications } from './views/Notifications.imba'
import './icons.imba'

let state = new State()

extend tag element
	get state
		return state

tag the-app
	<self>
		<profile-page route='/profile/' data=state>
		<downloads-page route='/downloads/' data=state>
		<donate route='/donate/'>

		<bible-reader route='*' data=state>

imba.mount <the-app>

imba.mount <Notifications data=state>
