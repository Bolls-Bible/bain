import { getValue, setValue, deleteValue } from '../utils'

import API from './Api'
import settings from './Settings'
import compare from './Compare'
import user from './User'
import notifications from './Notifications'

import type { HistoryEntry } from './types'

class ReadingHistory
	@observable history\HistoryEntry[] = getValue('history') || []

	@autorun def saveHistory
		if history.length
			setValue('history', history)
		else
			deleteValue('history')

	@autorun(delay:2s) def saveHistoryToServer
		if user.username && window.navigator.onLine
			try
				API.put('/history/', {
					history: JSON.stringify(history),
				})
			catch error
				console.warn(error)

	@action def clear
		history = []
		if user.username && window.navigator.onLine
			try
				await API.delete('/history/')
			catch error
				console.warn(error)
				notifications.push('error')

	@action def saveToHistory translation\string, book\number, chapter\number, verse\number|string
		unless #omitInit
			#omitInit = yes
			return

		await syncHistory!

		let already_recorded = history.find(do |element| return element.chapter == chapter && element.book == book && element.translation == translation && element.verse == verse)
		if already_recorded
			history.splice(history.indexOf(already_recorded), 1)

		history.sort(do(a, b) return b.date - a.date)
		
		history.unshift({
			translation: translation,
			book: book,
			chapter: chapter,
			verse: verse,
			date: Date.now!
		})
		# Remove items exceeding limit to avoid UI lag
		if history.length > 256
			history.length = 256

	@action def syncHistory
		if !user.username || !window.navigator.onLine
			return

		try
			let cloudData = await API.getJson('/history/')
			if cloudData.compare_translations..length
				compare.translations = JSON.parse(cloudData.compare_translations) || []

			if cloudData.favorite_translations
				settings.favoriteTranslations = JSON.parse(cloudData.favorite_translations) || []

			# Merge local history and server copy
			const cloudHistory = JSON.parse(cloudData.history).concat(history)

			# Remove duplicates
			let unique_history = []
			for place in cloudHistory
				let isAlreadyIn = unique_history.find(do |element| return element.chapter == place.chapter && element.book == place.book && element.translation == place.translation)
				if !isAlreadyIn && place.date >= cloudData.purge_date
					unique_history.push(place)

			history = unique_history
		catch error
			console.warn('Error syncing history', error)

		# Remove items exceeding limit
		if history.length > 256
			history.length = 256

		imba.commit!


const readingHistory = new ReadingHistory

export default readingHistory