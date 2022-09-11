import {State} from './state'
import './views/Bible'
import './views/donate'
import './views/Profile'
import './views/downloads'
import {Notifications} from './views/Notifications'
import './icons'

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
