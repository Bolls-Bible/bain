import API from './Api'

import { setValue, getValue, deleteValue } from '../utils'

class User
	username = getValue('username')
	is_password_usable = getValue('is_password_usable')
	name = getValue('name')
	bookmarksMap = getValue('bookmarksMap') || {}

	@autorun def saveUsername
		setValue('username', username)
	
	@autorun def saveName
		setValue('name', name)
	
	@autorun def saveBookmarksMap
		setValue('bookmarksMap', bookmarksMap)

	def logout
		deleteValue 'username'
		deleteValue 'name'
		deleteValue 'bookmarksMap'
		await API.post("/accounts/logout/")
		window.location.replace("/")



const user = new User()

export default user
