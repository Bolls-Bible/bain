import localization from './Localization'
import activities from './Activities'
import dictionary from './Dictionary'
import notifications from './Notifications'
import pageSearch from './PageSearch'
import parallelReader from './ParallelReader'
import reader from './Reader'
import readingHistory from './ReadingHistory'
import search from './Search'
import settings from './Settings'
import theme from './Theme'
import user from './User'
import vault from './Vault'
import compare from './Compare'


import { translations, RTLTranslations, bookNameIndex } from '../constants'

extend tag element
	get reader
		return reader

	get parallelReader
		return parallelReader

	get theme
		return theme

	get settings
		return settings

	get activities
		return activities

	set language newLang\string
		localization.language = newLang

	get language
		return localization.language

	get t
		return localization.lang
	
	get vault
		return vault
	
	get readingHistory
		return readingHistory
	
	get user
		return user
	
	get pageSearch
		return pageSearch
	
	get search
		return search
	
	get dictionary
		return dictionary
	
	get notifications
		return notifications
	
	get compare
		return compare
	
	### Utilities ###
	def textDirection text\string
		// check if there are present rtl characters
		if text..match(/[\u0590-\u08FF]/)
			return 'rtl'
		return 'ltr'

	def translationTextDirection translation\string
		# Sadly there are some translations that contain mixed rtl/ltr content
		# So the best result is to strictly specify what translations what text direction should have
		if RTLTranslations.includes(translation)
			return 'rtl'
		return 'ltr'

	def translationFullName tr\string
		unless tr
			return ''
		translations.find(do |translation| return translation.short_name == tr).full_name

	def getBookName translation\string, bookid\number|string
		return bookNameIndex.get("{translation}:{bookid}") || bookid

	def openInParallel place\{translation:string, book:number, chapter:number, verse:number}
		if settings.parallel_sync && parallelReader.enabled
			if place.book then reader.book = place.book
			if place.chapter then reader.chapter = place.chapter
		else
			if place.book then parallelReader.book = place.book
			if place.chapter then parallelReader.chapter = place.chapter
		if place.translation !== reader.translation then parallelReader.translation = place.translation

