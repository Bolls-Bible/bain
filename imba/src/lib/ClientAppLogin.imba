import API from './Api.imba'
import { getValue, deleteValue } from '../utils'

def CheckIfShouldLoginClientApp
	const sessionid = API.get_cookie('sessionid')
	const clientAppLogin = getValue('client-app-login')
	const base64sessionid = btoa(sessionid)
	if sessionid and clientAppLogin
		deleteValue('client-app-login')
		window.location.replace "bolls://client-app-login?sessionid={base64sessionid}"

CheckIfShouldLoginClientApp!