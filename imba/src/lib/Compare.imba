import vault from './Vault';
import notifications from './Notifications';
import activities from './Activities';
import API from './Api';
import user from './User';
import reader from './Reader';
import parallelReader from './ParallelReader';

import { setValue, getValue } from '../utils/index.imba'

import type { Verse, Translation } from './types'

class Compare
	@observable translations\string[] = getValue('compare_translations') ?? [
		reader.translation,
		parallelReader.translation,
	]

	versesToCompare = []
	chapterToCompare = 0
	bookToCompare = 0
	loading = no
	@observable list\(Verse[])[] = []

	search = ''

	@autorun def saveTranslations
		setValue('compare_translations', translations)
		unless #omitInit
			#omitInit = yes
			return

		if window.navigator.onLine && user.username
			API.put('/save-compare-translations/', {
				translations: JSON.stringify(translations),
			})

	def getCompareTranslationsFromDB
		const result = await vault.getCompareVerses(translations, versesToCompare, bookToCompare, chapterToCompare)
		loading = no
		activities.openModal 'compare'
		return result

	def load
		if activities.selectedVerses.length then versesToCompare = activities.selectedVerses
		if activities.selectedParallel == parallelReader.me
			chapterToCompare = parallelReader.chapter
			bookToCompare = parallelReader.book
		else
			chapterToCompare = reader.chapter
			bookToCompare = reader.book
		unless translations.includes(reader.translation)
			translations.unshift(reader.translation)
		activities.cleanUp!
		activities.openModal 'compare'
		loading = yes

		if !window.navigator.onLine && vault.downloaded_translations.indexOf(reader.translation) != -1
			list = await getCompareTranslationsFromDB!
		else
			list = []
			try
				list = await API.requestJson("/get-parallel-verses/", 'POST', {
					translations: translations,
					verses: versesToCompare,
					book: bookToCompare,
					chapter: chapterToCompare,
				})
				activities.openModal 'compare'
			catch error
				console.error error
				if vault.downloaded_translations.indexOf(reader.translation) != -1
					list = await getCompareTranslationsFromDB!
				else
					notifications.push('error')
			finally
				loading = no
		imba.commit!
	
	def addAllTranslations language\{translations: Translation[]}
		for translation in language.translations
			if translations.indexOf(translation.short_name) == -1
				translations.unshift(translation.short_name)
		load!
		imba.commit!

	def toggleTranslation translation\{short_name: string}
		if translations.indexOf(translation.short_name) < 0
			translations.unshift(translation.short_name)
			try
				const response = await API.requestJson("/get-parallel-verses/", 'POST', {
					translations: [translation.short_name],
					verses: versesToCompare,
					book: bookToCompare,
					chapter: chapterToCompare,
				})
				list = response.concat(list)
			catch error
				console.error error
				if vault.downloaded_translations.indexOf(reader.translation) != -1
					const response = await getCompareTranslationsFromDB!
					list = response.concat(list)
				else
					notifications.push('error')
			finally
				const compareElement = document.getElementById('compare')
				if compareElement
					compareElement.scrollIntoView({behavior: 'smooth', block: 'start'})
				loading = no
		else
			translations.splice(translations.indexOf(translation.short_name), 1)
			translations = translations
			list.splice(list.indexOf(list.find(do |parallel| return parallel[0].translation == translation.short_name)), 1)
		window.localStorage.setItem("translations", JSON.stringify(translations))
		activities.show_comparison_options = no
		imba.commit!

const compare = new Compare()

export default compare
