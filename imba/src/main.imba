import './lib'
import './global.css'
import './routes'
import { Profile } from './routes/profile'

tag app
	count = 0
	<self>
		<Profile route='/profile/'>

		<reader route='/international/:translation/:book/:chapter'>
		<reader route='/:translation/:book/:chapter'>
		<reader route='/*'>

		<notifications>



imba.mount <app>
