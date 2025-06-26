import languages from './data/languages.json'
import ALL_BOOKS from './data/translations_books.json'

export const translations = languages.flatMap(do(language) return language.translations)

export const RTLTranslations = languages.flatMap(do(language)
	return language.translations.reduce(&, []) do(accumulator, translation)
			if translation.dir
				accumulator.push(translation.short_name)
			return accumulator
)

export const translationNames = languages.reduce(&, {}) do(accumulator, language)
	for translation in language.translations
		accumulator[translation.short_name] = translation.full_name
	return accumulator


# create an index of book names where [translation][bookid] is a key and book.name is a value
export const bookNameIndex = new Map()
for translation in translations
	for book in ALL_BOOKS[translation.short_name]
		bookNameIndex.set("{translation.short_name}:{book.bookid}", book.name)
