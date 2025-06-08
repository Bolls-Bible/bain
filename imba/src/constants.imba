import languages from './data/languages.json'
import ALL_BOOKS from './data/translations_books.json'

export const translations = languages.flatMap(do(language) return language.translations)

export const RTLTranslations\stringp[] = languages.flatMap(do(language)
	return language.translations.reduce(&, []) do(accumulator, translation)
			if translation.dir
				accumulator.push(translation.short_name)
			return accumulator
)

export const translationNames = languages.reduce(&, {}) do(accumulator, language)
	for translation in language.translations
		accumulator[translation.short_name] = translation.full_name
	return accumulator

let agent = window.navigator.userAgent;
let isWebkit = (agent.indexOf("AppleWebKit") > 0);
let isIPad = (agent.indexOf("iPad") > 0);
export let isIOS = (agent.indexOf("iPhone") > 0 || agent.indexOf("iPod") > 0)
export let isApple = isIPad || isIOS
let isAndroid = (agent.indexOf("Android")  > 0)
let isNewBlackBerry = (agent.indexOf("AppleWebKit") > 0 && agent.indexOf("BlackBerry") > 0)
let isWebOS = (agent.indexOf("webOS") > 0);
let isWindowsMobile = (agent.indexOf("IEMobile") > 0)
let isSmallScreen = (screen.width < 767 || (isAndroid && screen.width < 1000))
let isUnknownMobile = (isWebkit && isSmallScreen)
let isMobile = (isIOS || isAndroid || isNewBlackBerry || isWebOS || isWindowsMobile || isUnknownMobile)
# let isTablet = (isIPad || (isMobile && !isSmallScreen))
export let MOBILE_PLATFORM = no

if isMobile && isSmallScreen && document.cookie.indexOf( "mobileFullSiteClicked=") < 0
	MOBILE_PLATFORM = yes

# create an index of book names where [translation][bookid] is a key and book.name is a value
export const bookNameIndex = new Map()
for translation in translations
	for book in ALL_BOOKS[translation.short_name]
		bookNameIndex.set("{translation.short_name}:{book.bookid}", book.name)

export const contributors = [
	"Павлишинець Тимофій, advocate, sponsor"
	"Vladimir Pandovski, donator, patron"
	"Andrew Horvath, maintainer"
	"David Andrews, donator"
	"Silvia Sanchez (Kohane), German localisation."
	"Rodolfo Schonhals Fischer, contributor, security auditor, Portuguese and Español localisation"
	"Joel Chackosaji, patron"
	"Benjamin J. Conway, donator"
	"Juan Martin, donator"
	"Ryne4S, tester"
	"Dj. Crouch, donator"
	"George Dulishkovich, patron"
	"Alexander Alemayhu, patron"
	"Павлишинець Едуард, contributor"
	"Eric Tirado, contributor, donator"
	"Dmytro Majewski, donator"
	"Володимир Стільник, advocate"
]
