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

export * from './dataindex'
