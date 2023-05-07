let transfer_option = 0

tag donate
	def mount
		document.title = 'Bolls Bible · ' + state.lang.donate

	def toggleTransferOption option
		if transfer_option == option
			transfer_option = 0
		else
			transfer_option = option

	def render
		<self>
			<header[d:flex jc:center pos:relative]>

				<a.svgBack [pos:absolute l:0 m:auto 16px auto 0 c:$c @hover:$acc-color-hover d:flex ai:center] route-to='/'>
					<arrow-back>
					state.lang.back
				<h1[fs:1.2em]> "Donate"
			<main[py:32px]>
				<a target="_blank" rel="noreferrer" href="https://send.monobank.ua/jar/6LydRJ3zbt">
					<h3[d:flex g:8px ai:center fill:$c @hover:$acc-color-hover]>
						"🐈 Monobank (International)"
						<svg[fill:inherit] xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px">
							<path d="M0 0h24v24H0z" fill="none">
							<path d="M19 19H5V5h7V3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z">

				<a target="_blank" rel="noreferrer" href="https://www.paypal.com/donate/?hosted_button_id=D6TEK8Q99J7SN">
					<h3[d:flex g:8px ai:center fill:$c @hover:$acc-color-hover]>
						<svg[fill:inherit] xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px">
							<path d="M0 0h24v24H0z" fill="none">
							<path d="M19 19H5V5h7V3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z">
						"PayPal (USD)"

				<h3 @click=state.copyTextToClipboard("7dzCPPBde4FrnTHL4XcJc8v7gFjTjsupZJLpYpJuVHnq")>
					<span> "SOL "
					<b> "7dzCPPBde4FrnTHL4XcJc8v7gFjTjsupZJLpYpJuVHnq"

				<h3 @click=state.copyTextToClipboard("rHDmcgtUmh7Jcc7RmL8PMPowLfNWXokw1y")>
					<span> "XRP "
					<b> "rHDmcgtUmh7Jcc7RmL8PMPowLfNWXokw1y"

				<h3 @click=state.copyTextToClipboard("0xaC59aB2d41028Bc6C4EDD58bA75E5c711771a62d")>
					<span> "ETH "
					<b> "0xaC59aB2d41028Bc6C4EDD58bA75E5c711771a62d"

				<h3 @click=state.copyTextToClipboard("0xaC59aB2d41028Bc6C4EDD58bA75E5c711771a62d")>
					<span> "USDT in ETH network "
					<b> "0xaC59aB2d41028Bc6C4EDD58bA75E5c711771a62d"

				<h3 @click=state.copyTextToClipboard("bc1qdjq8k942vhh5frra3pp30qc28aqsknmswe48z8")>
					<span> "BTC "
					<b> "bc1qdjq8k942vhh5frra3pp30qc28aqsknmswe48z8"


				<h2 @click=toggleTransferOption(1)>
					"SWIFT TRANSFER (USD)"
					<svg width="16" height="10" viewBox="0 0 8 5" [transform: rotate({transfer_option == 1 ? 180 : 0}deg)]>
						<title> 'arrow'
						<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
				if transfer_option == 1
					<section[h:auto @off:3.5em of:hidden] ease>
						<h4> "Beneficiary (Бенефіціар)"
						<p> "IBAN"
						<b> "UA 92 322001 00000 2620 0303 9339 58"
						<p> "Account No"
						<b> "26200303933958"
						<p> "Receiver"
						<b> "PAVLYSHYNETS BOHUSLAV, 90400, Ukraine, reg. Zakarpatska, district. Khustskyi, c. Khust, st. Vatutina, build. 17"

						<h4> "Account with Institution (Банк Бенефіціара)"
						<p> "Bank"
						<b> "JSC UNIVERSAL BANK"
						<p> "City"
						<b> "KYIV, UKRAINE"
						<p> "Swift code"
						<b> "UNJSUAUKXXX"

						<h4> "Intermediary (Банк посередник)"
						<p> "Bank"
						<b> "DEUTSCHE BANK TRUST CO. AMERICAS"
						<p> "City"
						<b> "NEW YORK, USA"
						<p> "Account number"
						<b> "4452477"
						<p> "Swift code"
						<b> "BKTRUS33XXX"

						<p[ws:pre-line]> "Details of payment (Призначення платежу)\n- private transfer\n- help to relative"

				<h2 @click=toggleTransferOption(2)>
					"SEPA TRANSFER (In Europe)"
					<svg width="16" height="10" viewBox="0 0 8 5" [transform: rotate({transfer_option == 2 ? 180 : 0}deg)]>
						<title> 'arrow'
						<polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
				if transfer_option == 2
					<section[h:auto @off:3.5em of:hidden] ease>
						<p> "Account number (IBAN)"
						<b> "GB79CLJU00997180712783"
						<p> "BIC"
						<b> "CLJUGB21"
						<p> "Account Holder Name"
						<b> "PAVLYSHYNETS BOHUSLAV"
						<p> "TIN (Taxpayer Identification Number)"
						<b> "3670304411"
						<p> "Bank"
						<b> "Clear Junction Limited"
						<p> "Bank address"
						<b> "15 Kingsway, London WC2B 6UN"


	css
		h:100vh
		ofy:auto
		max-width:1024px
		m:auto
		p:32px 16px 64px

	css
		h3
			c:$c @hover:$acc-color-hover
			cursor:copy
			py:12px

			span
				o:0.75

		section
			pb:32px

		h2
			ta:left
			fs:1.2em
			m:1em 0
			d:flex
			jc:space-between
			cursor:pointer
			fill:$c @hover:$acc-color-hover
			c@hover:$acc-color-hover

		h2 svg
			fill:inherit

		section h4
			pt:32px
			mb:-10px


		section p
			pt:12px
			fs:0.9em
			pb:2px
			o:0.8

		section b
			fw:500
