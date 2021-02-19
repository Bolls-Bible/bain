import {State} from './views/state'
import './views/Bible'
import './views/Profile'
import './views/downloads'
import {Notifications} from './views/Notifications'


let Data = new State()

tag the-app
	<self>
		<bible-reader route='/' bind=Data>
		<verse-navigator route='/:translation/:book/:chapter/:verse/'>
		<chapter-navigator route='/:translation/:book/:chapter/'>

		<profile-page route.exact='/profile/$' bind=Data>
		<downloads-page route.exact='/downloads/$' bind=Data>



tag verse-navigator
	def unmount
		const bible = document.getElementsByTagName("BIBLE-READER")
		if bible[0]
			bible[0].clearSpace!
	<self>

tag chapter-navigator
	def routed params
		window.on_pops_tate = yes
		const bible = document.getElementsByTagName("BIBLE-READER")
		if bible[0]
			bible[0].getText(params.translation, parseInt(params.book), parseInt(params.chapter))
	<self>


imba.mount <the-app>

imba.mount <Notifications data=Data>