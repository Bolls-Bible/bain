import {State} from './views/state'
import './views/Bible'
import './views/Profile'
import './views/downloads'
import {Notifications} from './views/Notifications'
import {verse-navigator, chapter-navigator} from './route-navigators'


let state = new State()

tag the-app
	<self>
		<bible-reader route='/' data=state>
		<verse-navigator route='/:translation/:book/:chapter/:verse/'>
		<chapter-navigator route='/:translation/:book/:chapter/'>

		<profile-page route.exact='/profile/$' data=state>
		<downloads-page route.exact='/downloads/$' data=state>


imba.mount <the-app>

imba.mount <Notifications data=state>