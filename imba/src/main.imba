import './lib'
import './global.css'
import './routes'

tag app
	count = 0
	<self>
		<profile route='/profile/'>
		<downloads route='/downloads/'>
		<donate route='/donate/'>

		<reader route='/international/:translation/:book/:chapter'>
		<reader route='/:translation/:book/:chapter'>
		<reader route='/*'>

		<notifications>



imba.mount <app>
