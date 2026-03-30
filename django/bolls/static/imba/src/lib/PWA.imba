import type { BeforeInstallPromptEvent } from './types.ts'

class PWA
	hideInstallPromotion = no
	deferredPrompt\BeforeInstallPromptEvent
	pswv = no # Play Store Web View
	isWin10Plus = no

	def constructor
		if window.navigator.userAgent.indexOf('Android') > -1 && window.navigator.userAgent.indexOf(' Bolls') > -1
			pswv = yes

		window.addEventListener('beforeinstallprompt', do(e\BeforeInstallPromptEvent)
			e.preventDefault()
			deferredPrompt = e
			imba.commit!
		)

		window.addEventListener('appinstalled', do(event)
			// Clear the deferredPrompt so it can be garbage collected
			window.deferredPrompt = null
			deferredPrompt = null
			hideInstallPromotion = yes
		)

		#  Detect if the app is installed in order to prevent the install app button and its text
		let isStandalone\boolean
		try
			isStandalone = window.matchMedia('(display-mode: standalone)').matches
		catch error
			console.warn('The browser doesn\'t support matchMedia API', error)
		if (document.referrer.startsWith('android-app://'))
			hideInstallPromotion = yes
		elif (window.navigator.standalone || window.isStandalone || isStandalone)
			hideInstallPromotion = yes
		
		try
			window.navigator.userAgentData.getHighEntropyValues(["platformVersion"])
				.then(do(ua)
					if (window.navigator.userAgentData.platform === "Windows")
						const majorPlatformVersion = parseInt(ua.platformVersion..split('.')[0])
						if (majorPlatformVersion > 0)
							isWin10Plus = yes)
		catch
			isWin10Plus = no

	def install
		if deferredPrompt
			deferredPrompt.prompt()

const pwa = new PWA()

export default pwa