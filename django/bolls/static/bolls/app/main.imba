import { State } from './state.imba'
import './views/BibleReader.imba'
import './views/donate.imba'
import './views/Profile.imba'
import './views/downloads.imba'
import { Notifications } from './views/Notifications.imba'
import './icons.imba'

let state = new State()

extend tag element
	get state
		return state

	def textDirection text
		// check if there are present rtl characters
		if text..match(/[\u0590-\u08FF]/)
			return 'rtl'
		return 'ltr'

tag the-app
	<self>
		<profile-page route='/profile/'>
		<downloads-page route='/downloads/'>
		<donate route='/donate/'>

		<bible-reader route='*'>

imba.mount <the-app>

imba.mount <Notifications>
