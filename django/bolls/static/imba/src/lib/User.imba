import API from './Api'

import { setValue, getValue, deleteValue } from '../utils'

class User
	@observable username\string = getValue('username')
	is_password_usable = getValue('is_password_usable')
	@observable name\string = getValue('name')
	@observable bookmarksMap\Record<string, Record<number, Record<number, Array<string>>>> = getValue('bookmarksMap') || {}
	@observable labels\string = []
	@observable categories\string[] = getValue('categories') || []

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
			setValue('userBookmarkMap', bookmarksMap)
		else
			deleteValue('userBookmarkMap')

	@autorun def saveCategories
		if categories
			setValue('categories', categories)
		else
			deleteValue('categories')

	constructor
		getMe!
		# listen when user gets online
		window.addEventListener('online', getMe.bind(this))

	def logout
		deleteValue 'username'
		deleteValue 'name'
		deleteValue 'bookmarksMap'
		await API.fetch("/accounts/logout/", "POST")
		API.deleteAllCookies()
		window.location.replace("/")

	@action def getMe
		if window.navigator.onLine
			try
				let userdata = await API.getJson("/user-logged/")
				if userdata.username
					is_password_usable = userdata.is_password_usable
					username = userdata.username
					name = userdata.name || ''
					if userdata.bookmarksMap
						bookmarksMap = userdata.bookmarksMap
					if userdata.categories
						categories = userdata.categories
				else
					bookmarksMap = {}
					username = ''
					name = ''
					categories = []
			catch err
				console.warn(err)
	
	def saveUserBookmarkToMap translation\string, book\number, chapter\number, color\string
		unless bookmarksMap[translation]
			bookmarksMap[translation] = {}
		unless bookmarksMap[translation][book]
			bookmarksMap[translation][book] = {}
		unless bookmarksMap[translation][book][chapter]
			bookmarksMap[translation][book][chapter] = []
		bookmarksMap[translation][book][chapter].push(color)

	def deleteBookmarkFromUserMap translation\string, book\number, chapter\number, color\string
		if bookmarksMap[translation][book][chapter].length >= 1
			delete bookmarksMap[translation][book][chapter]
		else
			bookmarksMap[translation][book][chapter].splice(
				bookmarksMap[translation][book][chapter].indexOf(color), 1)


const user = new User()

export default user
