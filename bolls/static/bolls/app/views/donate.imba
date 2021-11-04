export tag donate
	def mount
		document.title = 'Bolls Bible · ' + state.lang.donate

	def render
		<self>
			<header[d:flex jc:center pos:relative]>

				<a.svgBack [pos:absolute l:0 m:auto 16px auto 0 c:$text-color @hover:$accent-hover-color d:flex ai:center] route-to='/'>
					<arrow-back>
					state.lang.back
				<h1[fs:1.2em]> "Donate"
			<main[py:32px]>
				<a target="_blank" rel="noreferrer" href="https://send.monobank.ua/6ao79u5rFZ">
					<h3[d:flex g:8px ai:center fill:$text-color @hover:$accent-hover-color]>
						"🐈 Monobank"
						<svg[fill:inherit] xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px">
							<path d="M0 0h24v24H0z" fill="none">
							<path d="M19 19H5V5h7V3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z">

				<h3 @click=state.copyTextToClipboard("0x956cfb69b00df2a32df76ca4b3452565061f9d1a")>
					<span> "ETH "
					<b> "0x956cfb69b00df2a32df76ca4b3452565061f9d1a"
				<h3 @click=state.copyTextToClipboard("0xaC59aB2d41028Bc6C4EDD58bA75E5c711771a62d")>
					<span> "ETH "
					<b> "0xaC59aB2d41028Bc6C4EDD58bA75E5c711771a62d"
				<h3 @click=state.copyTextToClipboard("1NTDTBJHfCawieco1TP2B1vAHE4CPJHtbc")>
					<span> "BTC "
					<b> "1NTDTBJHfCawieco1TP2B1vAHE4CPJHtbc"
				<h3 @click=state.copyTextToClipboard("0x956cfb69b00df2a32df76ca4b3452565061f9d1a")>
					<span> "USDT in ETH network "
					<b> "0x956cfb69b00df2a32df76ca4b3452565061f9d1a"


	css
		h:100vh
		ofy:auto
		max-width:1024px
		m:auto
		p:32px 16px 64px

	css
		h3
			c:$text-color @hover:$accent-hover-color
			cursor:copy
			py:8px

			span
				o:0.75
