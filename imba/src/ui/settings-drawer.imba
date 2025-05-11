import Search  from 'lucide-static/icons/search.svg'
import TextSearch from 'lucide-static/icons/text-search.svg'
import Croissant from 'lucide-static/icons/croissant.svg'
import SunMoon from 'lucide-static/icons/sun-moon.svg'
import AlignLeft from 'lucide-static/icons/align-left.svg'
import AlignJustify from 'lucide-static/icons/align-justify.svg'
import MinimizeHorizontal from '../icons/minimize-horizontal.svg'
import MaximizeHorizontal from '../icons/maximize-horizontal.svg'
import Download from 'lucide-static/icons/download.svg'
import CloudDownload from 'lucide-static/icons/cloud-download.svg'
import BadgeInfo from 'lucide-static/icons/badge-info.svg'
import HeartHandshake from 'lucide-static/icons/heart-handshake.svg'
import Dices from 'lucide-static/icons/dices.svg'
import Languages from 'lucide-static/icons/languages.svg'
import Lollipop from 'lucide-static/icons/lollipop.svg'
import CandyCane from 'lucide-static/icons/candy-cane.svg'
import Candy from 'lucide-static/icons/candy.svg'
import CandyOff from 'lucide-static/icons/candy-off.svg'
import VenetianMask from 'lucide-static/icons/venetian-mask.svg'
import Pipette from 'lucide-static/icons/pipette.svg'

import * as ICONS from 'imba-phosphor-icons'


tag settings-drawer < aside
	get currentLanguage
		switch language
			when 'ukr' then "Українська"
			when 'ru' then "русский"
			when 'pt' then "Portuguese"
			when 'de' then "Deutsch"
			when 'es' then "Español"
			else "English"

	def purcheCache
		# ask confirmation
		const confirmed = await window.confirm(t.purge_cache + '?')
		if confirmed
			# unregister service worker and purge cache
			if window.navigator.serviceWorker != undefined
				window.navigator.serviceWorker.getRegistrations().then(do(registrations)
					for registration in registrations
						await registration.unregister()
				)

			window.caches.keys().then(do(cacheNames)	
				for cacheName in cacheNames
					await window.caches.delete(cacheName)
				)
			# & reload
			window.history.go()

	<self>
		<p[fs:1.5rem h:2rem d:flex jc:space-between ai:center p:0.5rem]>
			t.settings
			<.current-accent .enlarge-current-accent=activities.show_accents>
				<.visible-accent @click=(do activities.show_accents = !activities.show_accents)>
				<.accents .show-accents=activities.show_accents>
					for accent in theme.accents when accent.name != theme.accent
						<.accent @click=(do theme.accent = accent.name; activities.show_accents = no) [background-color: {theme.light == 'dark' ? accent.light : accent.dark}]>
		if !!user.username
			<a.settings-btn route-to='/profile/'>
				<svg src=VenetianMask aria-hidden=true>
				user.name || user.username
			<button.settings-btn @click.stop.prevent=user.logout>
				<svg src=CandyOff aria-hidden=true>
				t.logout
		else
			<a.settings-btn @click.stop.prevent=(window.location.pathname = "/accounts/login/") href="/accounts/login/">
				<svg src=Lollipop aria-hidden=true>
				t.login
			<a.settings-btn  @click.stop.prevent=(window.location.pathname = "/signup/") href="/signup/">
				<svg src=Candy aria-hidden=true>
				t.signin
		<button.settings-btn @click=activities.showSearch>
			<svg src=Search aria-hidden=true>
			t.bible_search
		<button.settings-btn @click=pageSearch.run>
			<svg src=TextSearch aria-hidden=true>
			t.find_in_chapter
		<button.settings-btn @click=activities.showHistory>
			<svg src=Croissant aria-hidden=true>
			t.history
		<menu-popup bind=activities.show_themes>
			<button.settings-btn [pos:relative] @click=(do activities.show_themes = !activities.show_themes)>
				<svg src=SunMoon aria-hidden=true>
				t.theme
				if activities.show_themes
					<.popup-menu [l:0 y@off:-2rem o@off:0] ease>
						<button[fw:900 bgc:black c:white bdr:2rem solid white]
							@click=(theme.theme = 'black')> 'Black'
						<button[fw:900 bgc:#00061A c:#B29595 bdr:2rem solid #B29595]
							@click=(theme.theme = 'dark')> t.nighttheme
						<button[fw:900 bgc:#f1f1f1 c:black bdr:2rem solid black]
							@click=(theme.theme = 'gray')> 'Gray'
						<button[fw:900 bgc:rgb(235, 219, 183) c:rgb(46, 39, 36) bdr:2rem solid rgb(46, 39, 36)]
							@click=(theme.theme = 'sepia')> 'Sepia'
						<button[fw:900 bgc:rgb(255, 238, 238) c:rgb(4, 6, 12) bdr:2rem solid rgb(4, 6, 12)]
							@click=(theme.theme = 'light')> t.lighttheme
						<button[fw:900 bgc:white c:black bdr:2rem solid black]
							@click=(theme.theme = 'white')> 'White'
						<button[d:hcs]
							@click=activities.openCustomTheme>
								t.createTheme
								<svg src=Pipette [miw:1rem size:1rem mr:0] aria-hidden=true>

		<.btnbox>
			<button[p:0.75rem fs:1.25rem].cbtn @click=theme.decreaseFontSize title=t.decrease_font_size> "B-"
			<button[p:.5rem fs:1.5rem].cbtn @click=theme.increaseFontSize title=t.increase_font_size> "B+"
		<.btnbox>
			<button.cbtn [p:.5rem fs:1.5rem fw:100] @click=theme.changeFontWeight(-100) title=t.decrease_font_weight> "B"
			<button.cbtn [p:.5rem fs:1.5rem fw:900] @click=theme.changeFontWeight(100) title=t.increase_font_weight> "B"
		<.btnbox>
			<svg.cbtn @click=theme.changeLineHeight(no) viewBox="0 0 38 14" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" [p:1rem 0]>
				<title> t.decrease_line_height
				<rect x="0" y="0" width="28" height="1">
				<rect x="0" y="6" width="38" height="1">
				<rect x="0" y="12" width="18" height="1">
			<svg.cbtn @click=theme.changeLineHeight(yes) viewBox="0 0 38 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" [p:0.5rem 0]>
				<title> t.increase_line_height
				<rect x="0" y="0" width="28" height="1">
				<rect x="0" y="11" width="38" height="1">
				<rect x="0" y="22" width="18" height="1">
		if window.chrome
			<.btnbox>
				<svg.cbtn src=AlignLeft @click=theme.changeAlign(yes) stroke-width="1" aria-label=t.auto_align>
				<svg.cbtn src=AlignJustify @click=theme.changeAlign(no) stroke-width="1" aria-label=t.align_justified>
		if window.innerWidth > 639
			<.btnbox>
				<svg.cbtn @click=theme.changeMaxWidth(no) src=MinimizeHorizontal stroke-width="1" aria-label=t.decrease_max_width>
				<svg.cbtn @click=theme.changeMaxWidth(yes) src=MaximizeHorizontal stroke-width="1" aria-label=t.increase_max_width>

		<menu-popup bind=activities.show_fonts>
			<.settings-btn [pos:relative] role="button" @click=(do
				activities.show_fonts = !activities.show_fonts
				theme.queryLocalFonts!
			)>
				<span.font-icon aria-hidden=true> "B"
				theme.fontName
				if activities.show_fonts
					<.popup-menu [l:0 y@off:-2rem o@off:0] ease>
						for font in theme.fonts
							<button[ff: {font.code}] .active-butt=font.name==theme.fontName @click=theme.setFontFamily(font)> font.name
						if theme.localFonts.size
							<button @click=activities.showFonts> '+ More'
		<menu-popup bind=activities.show_languages>
			<button.settings-btn [pos:relative] @click=(do activities.show_languages = !activities.show_languages)>
				<svg src=Languages aria-hidden=true>
				currentLanguage
				if activities.show_languages
					<.popup-menu [l:0 y@off:-2rem o@off:0] ease>
						<button .active-butt=('ukr'==language) @click=(language = 'ukr')> "Українська"
						<button .active-butt=('eng'==language) @click=(language = 'eng')> "English"
						<button .active-butt=('de'==language) @click=(language = 'de')> "Deutsch"
						<button .active-butt=('pt'==language) @click=(language = 'pt')> "Portuguese"
						<button .active-butt=('es'==language) @click=(language = 'es')> "Español"
						<button .active-butt=('ru'==language) @click=(language = 'ru')> "русский"

		<button.option-box.checkbox-parent @click=(parallelReader.enable = !parallelReader.enabled) .checkbox-turned=parallelReader.enabled>
			t.parallel
			<.checkbox> <span>
		<button.option-box.checkbox-parent @click=(settings.parallel_sync = !settings.parallel_sync) .checkbox-turned=settings.parallel_sync>
			t.parallel_sync
			<.checkbox> <span>
		<button.option-box.checkbox-parent @click=(settings.verse_picker = !settings.verse_picker) .checkbox-turned=settings.verse_picker>
			t.verse_picker
			<.checkbox> <span>
		<button.option-box.checkbox-parent @click=(settings.verse_break = !settings.verse_break) .checkbox-turned=settings.verse_break>
			t.verse_break
			<.checkbox> <span>
		<button.option-box.checkbox-parent @click=(settings.verse_number = !settings.verse_number) .checkbox-turned=settings.verse_number>
			t.verse_number
			<.checkbox> <span>
		<button.option-box.checkbox-parent @click=(settings.verse_commentary = !settings.verse_commentary) .checkbox-turned=settings.verse_commentary>
			t.verse_commentary
			<.checkbox> <span>
		<button.option-box.checkbox-parent @click=(settings.lock_books_menu = !settings.lock_books_menu) .checkbox-turned=settings.lock_books_menu>
			t.lock_books_menu
			<.checkbox> <span>
		<button.option-box.checkbox-parent @click=(theme.transitions = !theme.transitions) .checkbox-turned=theme.transitions>
			t.transitions
			<.checkbox> <span>
		<button.option-box.checkbox-parent @click=(settings.chronorder =! settings.chronorder) .checkbox-turned=settings.chronorder>
			t.chronological_order
			<.checkbox> <span>
		<button.option-box.checkbox-parent @click=(settings.fixdrawers = !settings.fixdrawers) .checkbox-turned=settings.fixdrawers>
			t.fixdrawers
			<.checkbox> <span>

		if window.navigator.onLine
			if vault.available
				<button.settings-btn @click=activities.toggleDownloads>
					<svg src=CloudDownload aria-hidden=true>
					t.download_translations
			<a.settings-btn href='/downloads/' target="_blank" @click=pwa.deferredPrompt.prompt>
				<img[size:2rem rd:23% mr:0.75rem] src='/bolls.png' aria-hidden=true>
				t.install_app
			<button.settings-btn @click=dictionary.showDictionary>
				<span.font-icon aria-hidden=true> 'א'
				t.dictionary
		<button.settings-btn @click=activities.showHelp>
			<svg src=ICONS.CARROT aria-hidden=true>
			t.help
		<button.settings-btn @click=activities.showSupport>
			<svg src=HeartHandshake aria-hidden=true>
			t.support
		<button.settings-btn @click=reader.randomVerse>
			<svg src=Dices aria-hidden=true>
			t.random

		unless !"state.pswv"
			<a.settings-btn route-to="/donate/">
				<svg src=ICONS.TIP_JAR aria-hidden=true>
				t.donate

		<button.settings-btn @click=purcheCache>
			<svg src=ICONS.BROOM aria-hidden=true>
			t.purge_cache

		<footer>
			<p.footer_links>
				<a target="_blank" rel="noreferrer" href="http://t.me/bollsbible"> "Official Telegram"
				<a target="_blank" rel="noreferrer" href="https://github.com/Bolls-Bible/bain"> "GitHub"
				<a target="_blank" href="/api"> "API "
				<a target="_blank" href="/static/privacy_policy.html"> "Privacy Policy"
				<a target="_blank" rel="noreferrer" href="http://www.patreon.com/bolls"> "Patreon"
				<a target="_blank" href="/static/disclaimer.html"> "Disclaimer"
				<a target="_blank" rel="noreferrer" href="https://imba.io"> "Imba"
				<a target="_blank" rel="noreferrer" href="https://docs.djangoproject.com"> "Django"
				<a target="_blank" rel="noreferrer" href="http://t.me/Boguslavv"> "My Telegram 📱"
			<p[fs:0.75rem pb:0.75rem]>
				"🍇 v3.1.1 🗓 "
				<time dateTime='2025-5-11'> "11.5.2025"
			<p[fs:0.75rem]>
				"© 2019-present Павлишинець Богуслав 🎻 Pavlyshynets Bohuslav"

		unless activities.settingsDrawerOffset
			<global @click.outside.capture.stop.prevent=activities.toggleSettingsMenu>

	css
		.current-accent
			cursor: pointer
			height: 1em
			width: 1em
			z-index: 1100

		.visible-accent
			background-color: $acc-hover
			border-radius: 23%
			height: 1em
			width: 1em

		.enlarge-current-accent, .enlarge-current-accent .visible-accent
			height: 2rem
			width: 2rem
			overflow: visible

		.accents
			margin-right: 1em
			margin-top: -28px
			border-radius: 23%
			display: flex
			cursor: pointer
			visibility: hidden
			opacity: 0
			transform: scale(0.8)
			transform-origin: center right

		.show-accents
			margin-left: -2px
			margin-top: -2rem
			visibility: visible
			opacity: 1
			transform: scale(1)

		.accents .accent
			border-radius: 23%
			height: 2rem
			width: 2rem
			margin: 0 2px 0
			cursor: pointer

		.show-accents .accent
			margin: 0 -34px 0

		.cbtn
			w: 50% h: 100%
			color: $c @hover:$acc-hover
			display: inline-block
			text-align: center
			bgc: transparent @hover:$acc-bgc-hover
			border-radius: .5rem

		.btnbox
			cursor: pointer
			height: 2.875rem
			margin: 1rem 0

		.settings-btn
			w:100% h:2.875rem m:1rem 0
			bg:transparent @hover:$acc-bgc-hover
			color: $c @hover:$acc-hover
			d:flex ai:center font:inherit p:0 .5rem
			border-radius: .5rem
			lh:1

		.settings-btn svg
			mr: 0.75rem
			s: 2rem
			min-width: 2rem

		.font-icon
			ff:serif fs:1.6875rem
			ta:center w:2rem
			mr:0.75rem

		footer
			padding-bottom: .5rem
			text-align: center

		footer a
			color: $c
			color@hover:$acc-hover
			font-size: 0.875rem
			background-size: 100% 0.2em
			display: inline-block
			background-image: linear-gradient($c 0px, $c 100%) @hover: linear-gradient($acc-hover 0px, $acc-hover 100%)

		.footer_links
			padding-block: .5rem

			a
				margin-inline:.25rem
				margin-block:.5rem 0



