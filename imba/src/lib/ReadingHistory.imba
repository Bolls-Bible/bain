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

	@autorun(delay:500ms) def saveHistoryToServer
		if !user.username || !window.navigator.onLine
			return

		try
			const cloudData = await API.requestJson('/v2/history/', "PUT", {
				history: JSON.stringify(history),
			})
			if cloudData.compare_translations..length
				compare.translations = JSON.parse(cloudData.compare_translations) || cloudData.compare_translations

			if cloudData.favorite_translations
				settings.favoriteTranslations = JSON.parse(cloudData.favorite_translations) || cloudData.favorite_translations

			if cloudData.history
				history = JSON.parse(cloudData.history) || history
		catch error
			console.warn(error)

	@action def clear
		history = []
		if user.username && window.navigator.onLine
			try
				await API.delete('/v2/history/')
			catch error
				console.warn(error)
				notifications.push('error')

	@action def saveToHistory translation\string, book\number, chapter\number, verse\number|string
		unless #omitInit
			#omitInit = yes
			return

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

			if cloudData.history
				history = JSON.parse(cloudData.history) || history
		catch error
			console.warn('Error syncing history', error)

		# Remove items exceeding limit
		if history.length > 256
			history.length = 256

		imba.commit!


const readingHistory = new ReadingHistory

export default readingHistory