
import { english, ukrainian, russian, portuguese, espanol, german } from '../data/langdata'
import { getValue, setValue } from '../utils'

if window.navigator.userAgent.indexOf('Android') > -1
	english["SUPPORT"].length = 4
	ukrainian["SUPPORT"].length = 4
	russian["SUPPORT"].length = 4
	portuguese["SUPPORT"].length = 4
	espanol["SUPPORT"].length = 4
	german["SUPPORT"].length = 4

class Localization
	#lang\(typeof english)

	def constructor
		if getValue('language')
			language = getValue('language')
		# Otherwise, set the default language and translation in dependence with his browser navigator settings.
		else
			switch window.navigator.language.toLowerCase().slice(0, 2)
				when 'uk'
					#language = 'ukr'
					document.documentElement.lang = "uk"
					if !window.translation
						setValue('translation', 'UBIO')
				when 'es'
					#language = 'es'
					document.documentElement.lang = "es"
					if !window.translation
						setValue('translation', 'BTX3')
				when 'pt'
					#language = 'pt'
					document.documentElement.lang = "pt"
					if !window.translation
						setValue('translation', 'NTJud')
				when 'de'
					#language = 'de'
					document.documentElement.lang = "de"
					if !window.translation
						setValue('translation', 'MB')
				when 'ru'
					#language = 'ru'
					document.documentElement.lang = "ru"
					if !window.translation
						setValue('translation', 'JNT')
				when 'no'
					setDefaultTranslation 'DNB'
				when 'nl'
					setDefaultTranslation 'NLD'
				when 'fr'
					setDefaultTranslation 'NBS'
				when 'it'
					setDefaultTranslation 'NR06'
				when 'he'
					setDefaultTranslation 'WLCa'
				when 'zh'
					setDefaultTranslation 'CUV'
				when 'pl'
					setDefaultTranslation 'BW'
				when 'ja'
					setDefaultTranslation 'NJB'
				when 'kn'
					setDefaultTranslation 'KNCL'
				when 'ar'
					setDefaultTranslation 'NAV'
				else
					#language = 'eng'
					document.documentElement.lang = "en"
					setDefaultTranslation 'YLT'
			language = #language

	set language newLang
		#language = newLang
		switch newLang
			when 'ukr' then #lang = ukrainian
			when 'ru' then #lang = russian
			when 'pt' then #lang = portuguese
			when 'es' then #lang = espanol
			when 'de' then #lang = german
			else #lang = english
		setValue 'language', newLang
	
	get language
		return #language
	
	get lang
		return #lang
	
	def setDefaultTranslation translation\string
		language = 'eng'
		document.documentElement.lang = "en"
		if !window.translation
			setValue('translation', translation)

const localization = new Localization()

export default localization
