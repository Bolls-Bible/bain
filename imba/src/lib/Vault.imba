import db from './dexie'

import { getValue, setValue } from '../utils' 

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
		# setTimeout(&, 2048) do
		# 	checkTranslationsUpdates()
		# 	checkSavedBookmarks()

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
		setValue('downloaded_translations', JSON.stringify(downloaded_translations))

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
		setValue('downloaded_dictionaries', JSON.stringify(downloaded_dictionaries))
		imba.commit!

const vault = new  Vault()

export default vault
