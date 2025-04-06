import { setValue } from '../utils'


tag client-login
	def mount
		setValue('client-app-login', true)
		window.location.replace(window.location.href.replace('client-app-login', 'login'))

	<self>
		"Redirecting to the next step..."
