import './lib'
import './global.css'
import './routes'
import * as Sentry from "@sentry/browser";

tag app
	def mount
		Sentry.init({
			dsn: "https://5a69d00bbc564998800e91e75162e31b@o4509977736118272.ingest.de.sentry.io/4509977739984976",
			// Setting this option to true will send default PII data to Sentry.
			// For example, automatic IP address collection on events
			sendDefaultPii: true
		})

	<self>
		<profile route='/profile/'>
		<downloads route='/downloads/'>
		<donate route='/donate/'>

		<reader route='/international/:translation/:book/:chapter'>
		<reader route='/:translation/:book/:chapter'>
		<reader route='/*'>

		<notifications>


imba.mount <app>
