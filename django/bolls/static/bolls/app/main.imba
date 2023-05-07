import { State } from './state.imba'
import './views/BibleReader.imba'
import './views/donate.imba'
import './views/Profile.imba'
import './views/downloads.imba'
import { Notifications } from './views/Notifications.imba'
import './icons.imba'
import languages from "./views/languages.json"

let state = new State()

const RTLTranslations = languages.flatMap(do(language)
	return language.translations.reduce(
		(do(acumulator, translation)
			if translation.dir
				acumulator.push(translation.short_name)
			return acumulator
			), [])
)

extend tag element
	get state
		return state

	def textDirection text
		// check if there are present rtl characters
		if text..match(/[\u0590-\u08FF]/)
			return 'rtl'
		return 'ltr'

	def translationTextDirection translation
		# Sadly there are some translations that contain mixed rtl/ltr content
		# So the best result is to strictly specify what translations what text direction should have
		if RTLTranslations.includes(translation)
			return 'rtl'
		return 'ltr'

tag the-app
	<self>
		<profile-page route='/profile/'>
		<downloads-page route='/downloads/'>
		<donate route='/donate/'>

		<bible-reader route='*'>

imba.mount <the-app>

imba.mount <Notifications>
