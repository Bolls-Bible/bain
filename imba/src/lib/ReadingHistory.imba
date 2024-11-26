import { getValue, setValue } from '../utils'

import API from './Api'
import activities from './Activities'
import settings from './Settings'

class ReadingHistory
	history = getValue('history') || []

	def showHistory
		activities.show_history = !activities.show_history
		# settings_menu_left = -300
		if activities.show_history
			syncHistory!

	def clearHistory
		showHistory!
		history = []
		setValue("history", [])
		# if state.user.username && window.navigator.onLine
		# 	try
		# 		const response = await window.fetch("/history/", {
		# 			method: "DELETE",
		# 			cache: "no-cache",
		# 			headers: {
		# 				'X-CSRFToken': state.get_cookie('csrftoken'),
		# 				"Content-Type": "application/json"
		# 			},
		# 			body: JSON.stringify({
		# 				history: "[]",
		# 				purge_date: Date.now!
		# 			})
		# 		})
		# 		await response.json()
		# 	catch error
		# 		console.error(error)
		# 		notifications.push('error')

	def saveToHistory translation\string, book\number, chapter\number
		# if state.user.username && window.navigator.onLine
		# 	history = await API.get('/history')

		if getValue("history")
			history = getValue("history")
		
		let already_recorded = history.find(do |element| return element.chapter == chapter && element.book == book && element.translation == translation)
		if already_recorded
			history.splice(history.indexOf(already_recorded), 1)

		history.sort(do(a, b) return b.date - a.date)
		
		history.unshift({
			translation: translation,
			book: book,
			chapter: chapter,
			date: Date.now!
		})
		# Remove items exceeding limit to avoid UI lag
		if history.length > 256
			history.length = 256

		setValue("history", history)
		saveHistoryToServer!

	def syncHistory
		return
		# if state.user.username && window.navigator.onLine
		# 	let cloud_history = await API.getJson('/history')
		# 	if cloud_history.compare_translations..length
		# 		#compare_translations = JSON.parse(cloud_history.compare_translations) || []
		# 		if cloud_history.favoriteTranslations
		# 			settings.favoriteTranslations = JSON.parse(cloud_history.favoriteTranslations) || []
		# 	# Merge local history and server copy
		# 	history = JSON.parse(getValue("history")) || []
		# 	try
		# 		history = JSON.parse(cloud_history.history).concat(history)

		# 		# Remove duplicates
		# 		let unique_history = []
		# 		for c in history
		# 			let unique = unique_history.find(do |element| return element.chapter == c.chapter && element.book == c.book && element.translation == c.translation && element.parallel == c.parallel)
		# 			if !unique && c.date >= cloud_history.purge_date
		# 				unique_history.push(c)

		# 		history = unique_history

		# 	# Remove items exceeding limit
		# 	if history.length > 256
		# 		history.length = 256

		# 	imba.commit!

		# 	# Update history in localStorage and server
		# 	if history.length
		# 		window.localStorage.setItem("history", JSON.stringify(history))
		# 		saveHistoryToServer!

	def saveHistoryToServer
		return
		# if state.user.username && window.navigator.onLine
		# 	window.fetch("/history/", {
		# 		method: "PUT",
		# 		cache: "no-cache",
		# 		headers: {
		# 			'X-CSRFToken': state.get_cookie('csrftoken'),
		# 			"Content-Type": "application/json"
		# 		},
		# 		body: JSON.stringify({
		# 			history: JSON.stringify(history),
		# 		})
		# 	})
		# 	.then(do |response| if(response.status !== 200)
		# 		throw new Error(response.statusText)
		# 	).catch(do |e| console.error(e))

const readingHistory = new ReadingHistory

export default readingHistory