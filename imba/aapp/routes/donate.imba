import ArrowLeft from 'lucide-static/icons/arrow-left.svg'
import ChevronDown from 'lucide-static/icons/chevron-down.svg'
import SquareArrowOutUpRight from 'lucide-static/icons/square-arrow-out-up-right.svg'

let transfer_option = 0

tag donate
	def mount
		document.title = 'Bolls Bible · ' + t.donate

	def toggleTransferOption option\number
		if transfer_option == option
			transfer_option = 0
		else
			transfer_option = option
	
	def copyMe e
		activities.copyTextToClipboard e.target.innerText

	<self>
		<head>
			<title> t.donate
		<header[d:hcc]>
			<a[ml:.5rem d:flex ai:center c@hover:$acc] route-to='/' title=t.back>
				<svg src=ArrowLeft aria-hidden=yes>
				<span[m:1.5rem .5rem fw:500]> t.back
			<h1[fs:1.2em m:auto]> t.donate

		<main[py:2rem]>
			<a target="_blank" rel="noreferrer" href="https://send.monobank.ua/jar/6LydRJ3zbt">
				<h3[d:flex g:.5rem ai:center fill:$c @hover:$acc-color-hover]>
					"🐈 Monobank (International)"
					<svg src=SquareArrowOutUpRight aria-hidden=yes>

			<h3[d:flex g:8px ai:center fill:$c @hover:$acc-color-hover]>
				<span> "PayPal "
				<b @click=copyMe> "bpavlisinec@gmail.com"

			<h3>
				<span> "SOL "
				<b @click=copyMe> "7dzCPPBde4FrnTHL4XcJc8v7gFjTjsupZJLpYpJuVHnq"

			<h3>
				<span> "XRP "
				<b @click=copyMe> "rHDmcgtUmh7Jcc7RmL8PMPowLfNWXokw1y"

			<h3>
				<span> "ETH "
				<b @click=copyMe> "0xaC59aB2d41028Bc6C4EDD58bA75E5c711771a62d"

			<h3>
				<span> "USDT in ETH network "
				<b @click=copyMe> "0xaC59aB2d41028Bc6C4EDD58bA75E5c711771a62d"

			<h3>
				<span> "BTC "
				<b @click=copyMe> "bc1qdjq8k942vhh5frra3pp30qc28aqsknmswe48z8"


			<h2 @click=toggleTransferOption(1)>
				"SWIFT TRANSFER"
				<svg src=ChevronDown aria-hidden=yes [transform: rotate({transfer_option == 1 ? 180 : 0}deg)]>

			if transfer_option == 1
				<section[h:auto @off:3.5em of:hidden] ease>
					<p> "IBAN for USD"
					<b @click=copyMe> "UA923220010000026200303933958"
					<p> "IBAN for EUR"
					<b @click=copyMe> "UA243220010000026201306493911"
					<p> "IBAN for GBP"
					<b @click=copyMe> "UA593220010000026209302258668"
					<hr[mt:1rem c:$acc-bgc w:8rem]>
					<p> "SWIFT/ BIC Code"
					<b @click=copyMe> "UNJSUAUKXXX"
					<p> "Receiver"
					<b @click=copyMe> "PAVLYSHYNETS BOHUSLAV"
					<p> "Address"
					<b @click=copyMe> "90400, Ukraine, reg. Zakarpatska, district Khustskyi, c. Khust, st. Vatutina, build 17"

			<h2 @click=toggleTransferOption(2)>
				"SEPA TRANSFER (In Europe)"
				<svg src=ChevronDown aria-hidden=yes [transform: rotate({transfer_option == 1 ? 180 : 0}deg)]>

			if transfer_option == 2
				<section[h:auto @off:3.5em of:hidden] ease>
					<p> "IBAN"
					<b @click=copyMe> "GB79CLJU00997180712783"
					<p> "BIC code"
					<b @click=copyMe> "CLJUGB21"
					<p> "Receiver"
					<b @click=copyMe> "PAVLYSHYNETS BOHUSLAV"


	css
		mah:100vh
		max-width:64rem
		m:auto
		p:1rem

	css
		h3
			c:$c @hover:$acc-color-hover
			cursor:copy
			py:.75rem

			span
				o:0.75

		h2
			ta:left
			fs:1.2em
			m:1em 0 0
			d:flex
			jc:space-between
			cursor:pointer
			fill:$c @hover:$acc-color-hover
			c@hover:$acc-color-hover

		section
			pb:2rem

			h4
				py:1.5rem .5rem
				mb:-0.625rem

			p
				pt:.75rem
				fs:0.9em
				pb:2px
				o:0.8

			b
				fw:500
				cursor:copy
