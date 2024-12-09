import API from './Api'

import { setValue, getValue, deleteValue } from '../utils'

import readingHistory from './ReadingHistory'

class User
	username = getValue('username')
	is_password_usable = getValue('is_password_usable')
	name = getValue('name')
	bookmarksMap = getValue('bookmarksMap') || {}

	@autorun def saveUsername
		if username
			setValue('username', username)
		else
			deleteValue('username')
	
	@autorun def saveName
		if name
			setValue('name', name)
		else
			deleteValue('name')
	
	@autorun def saveBookmarksMap
		if bookmarksMap
			setValue('bookmarksMap', bookmarksMap)
		else
			deleteValue('bookmarksMap')
	
	constructor
		getMe!

	def logout
		deleteValue 'username'
		deleteValue 'name'
		deleteValue 'bookmarksMap'
		await API.fetch("/accounts/logout/", "POST")
		window.location.replace("/")

	def getMe
		if window.navigator.onLine
			try
				let userdata = await API.getJson("/user-logged/")
				console.log('userdata', userdata)
				if userdata.username
					is_password_usable = userdata.is_password_usable
					username = userdata.username
					name = userdata.name || ''
					if userdata.bookmarksMap
						bookmarksMap = userdata.bookmarksMap
					await readingHistory.syncHistory!
				else
					bookmarksMap = {}
					username = ''
					name = ''

			catch err

const user = new User()

export default user
