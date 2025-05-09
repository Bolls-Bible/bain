import { setValue, getValue } from '../utils/index.imba'

import user from './User'
import API from './Api'

class SettingsState
	@observable verse_number\boolean = getValue('verse_number') ?? yes
	@observable verse_break\boolean = getValue('verse_break') ?? no
	@observable verse_picker\boolean = getValue('verse_picker') ?? no
	@observable verse_commentary\boolean = getValue('verse_commentary') ?? yes
	@observable parallel_sync\boolean = getValue('parallel_synch') ?? yes
	@observable lock_books_menu\boolean = getValue('lock_books_menu') ?? no
	@observable extended_dictionary_search\boolean = getValue('extended_dictionary_search') ?? no
	@observable fixdrawers\boolean = getValue('fixdrawers') ?? no
	@observable menuicons\boolean = getValue('menuicons') ?? yes
	@observable contrast\number = getValue('contrast') ?? 105
	@observable chronorder\boolean = getValue('chronorder') ?? no
	@observable favoriteTranslations\string[] = getValue('favorite_translations') ?? []

	@autorun def saveVerseNumber
		setValue('verse_number', verse_number)
	
	@autorun def saveVerseBreak
		setValue('verse_break', verse_break)
	
	@autorun def saveVersePicker
		setValue('verse_picker', verse_picker)
	
	@autorun def saveVerseCommentary
		setValue('verse_commentary', verse_commentary)
	
	@autorun def saveParallelSync
		setValue('parallel_synch', parallel_sync)
	
	@autorun def saveLockBooksMenu
		setValue('lock_books_menu', lock_books_menu)
	
	@autorun def saveExtendedDictionarySearch
		setValue('extended_dictionary_search', extended_dictionary_search)
	
	@autorun def saveFixDrawers
		setValue('fixdrawers', fixdrawers)
	
	@autorun def saveMenuIcons
		setValue('menuicons', menuicons)

	@autorun def saveContrast
		setValue('contrast', contrast)
	
	@autorun def saveChronorder
		setValue('chronorder', chronorder)
	
	@autorun def saveFavoriteTranslations
		setValue('favorite_translations', favoriteTranslations)
		try
			if window.navigator.onLine && user.username
				API.put('/api/save-favorite-translations/', {
					// TODO: remove unnecessary JSON.stringify
					translations: JSON.stringify(favoriteTranslations),
				})
		catch err
			console.warn(err)

const settings = new SettingsState()

export default settings