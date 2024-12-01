import vault from './Vault';
import notifications from './Notifications';
import activities from './Activities';
import API from './Api';
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
	list\(Verse[])[] = []

	search = ''

	@autorun def saveTranslations
		setValue('compare_translations', translations)

	def load
		if activities.selectedVerses.length then versesToCompare = activities.selectedVerses
		if activities.selectedParallel == parallelReader.me
			chapterToCompare = parallelReader.chapter
			bookToCompare = parallelReader.book
		else
			chapterToCompare = reader.chapter
			bookToCompare = reader.book
		if translations.indexOf(reader.translation) == -1
			translations.unshift(reader.translation)
		activities.cleanUp!
		activities.openModal 'compare'
		loading = yes

		def getCompareTranslationsFromDB
			list = await vault.getCompareVerses(translations, versesToCompare, bookToCompare, chapterToCompare)
			loading = no
			activities.openModal 'compare'

		if !window.navigator.onLine && vault.downloaded_translations.indexOf(reader.translation) != -1
			getCompareTranslationsFromDB!
		else
			list = []
			try
				list = await API.post("/get-parallel-verses", {
					translations: translations,
					verses: versesToCompare,
					book: bookToCompare,
					chapter: chapterToCompare,
				})
				loading = no
				activities.openModal 'compare'
			catch error
				console.error error
				loading = no
				if vault.downloaded_translations.indexOf(reader.translation) != -1
					return getCompareTranslationsFromDB!
				notifications.push('error')
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
				const response = await API.post("/get-parallel-verses", {
					translations: [translation.short_name],
					verses: versesToCompare,
					book: bookToCompare,
					chapter: chapterToCompare,
				})
				list = response.concat(list)
				const compareElement = document.getElementById('compare')
				if compareElement
					compareElement.scrollIntoView({behavior: 'smooth', block: 'start'})
				loading = no
			catch error
				console.error error
				loading = no
				notifications.push('error')
		else
			translations.splice(translations.indexOf(translation.short_name), 1)
			translations = translations
			list.splice(list.indexOf(list.find(do |parallel| return parallel[0].translation == translation.short_name)), 1)
		window.localStorage.setItem("translations", JSON.stringify(translations))
		activities.show_comparison_optinos = no
		imba.commit!

const compare = new Compare()

export default compare
