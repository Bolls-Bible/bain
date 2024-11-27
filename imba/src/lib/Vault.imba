import db from './dexie'

import { getValue, setValue } from '../utils' 

import notifications from './Notifications'

import { translations } from '../constants.imba'
import dictionaries from '../data/dictionaries.json'

class  Vault
	available\boolean = no
	downloaded_translations\string[] = []
	translations_in_downloading\string[] = []
	deleting_of_all_transllations\boolean = no
	translations_current_state\object = {}

	dictionaries_in_downloading\string[] = []
	downloaded_dictionaries\string[] = []
	deleting_of_all_dictionaries\boolean = no
	dictionaries_current_state\object = {}



	def constructor
		# Initialize the IndexedDB in order to be able to work with downloaded translations and offline bookmarks if such exist.

		checkDownloadedData()

		# # Update obsole translations if such exist.
		setTimeout(&, 2048) do
			checkTranslationsUpdates()
			# checkSavedBookmarks()

	def checkDownloadedData
		downloaded_translations = getValue('downloaded_translations') || []
		let checked_translations = await Promise.all(
			translations.map(
				do |translation|
					db.transaction('r', db.verses, do
						const resd = await db.verses.get({translation: translation.short_name})
						return resd.translation
					).catch(do
						return null
					)
			)
		)
		downloaded_translations = checked_translations.filter(do |item| return item != null) || []
		setValue('downloaded_translations', downloaded_translations)

		downloaded_dictionaries = getValue('downloaded_dictionaries') || []
		let checked_dictionaries = await Promise.all(
			dictionaries.map(
				do |dictionary|
					db.transaction('r', db.dictionaries, do
						const resd = await db.dictionaries.get({dictionary: dictionary.abbr})
						return resd.dictionary
					).catch(do
						return null
					)
			)
		)
		downloaded_dictionaries = checked_dictionaries.filter(do |item| return item != null) || []
		setValue('downloaded_dictionaries', downloaded_dictionaries)
		imba.commit!


	def checkTranslationsUpdates
		let stored_translations_updates = getValue('stored_translations_updates')
		for translation in translations
			if downloaded_translations.indexOf(translation.short_name) > -1
				translations_current_state[translation.short_name] = translation.updated
		if stored_translations_updates
			for translation in downloaded_translations
				if translations_current_state[translation] > stored_translations_updates[translation]
					console.log("Need to be updated")
					deleteTranslation(translation, yes)
			console.log "finish translations update check"
		else
			stored_translations_updates = translations_current_state
			setValue('stored_translations_updates', translations_current_state)

	def downloadTranslation translation
		if (downloaded_translations.indexOf(translation) < 0 && window.navigator.onLine)
			translations_in_downloading.push(translation)
			let begtime = Date.now()
			let url = '/static/translations/' + translation

			let response = await window.fetch(url)
			if response.status == 200
				downloaded_translations.push(translation)
				setValue('downloaded_translations', downloaded_translations)
				translations_in_downloading.splice(translations_in_downloading.indexOf(translation), 1)
				translations_current_state[translation] = Date.now()
				setValue('stored_translations_updates', translations_current_state)
				console.log("Translation ", translation, " is saved. Time: ", (Date.now() - begtime) / 1000, "s")
				imba.commit!
			else
				handleDownloadingError(translation)

	def handleDownloadingError translation
		translations_in_downloading.splice(translations_in_downloading.indexOf(translation), 1)
		notifications.push('error')

	def deleteTranslation translation, update = no
		downloaded_translations.splice(downloaded_translations.indexOf(translation), 1)
		translations_in_downloading.push(translation)
		let begtime = Date.now()

		let response = await window.fetch('/sw/delete-translation/' + translation)
		if response.status == 200
			console.log( "Deleted ", translation, ". Time: ", (Date.now() - begtime) / 1000)
			translations_in_downloading.splice(translations_in_downloading.indexOf(translation), 1)
			delete translations_current_state[translation]
			setValue('stored_translations_updates', translations_current_state)
			imba.commit!
			if update
				downloadTranslation(translation)
		else
			handleDownloadingError(translation)



const vault = new  Vault()

export default vault
