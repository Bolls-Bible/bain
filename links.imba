
		makeSiteMap()

	def makeSiteMap
		let urls = []
		for translation in translations
			for book in BOOKS[translation.short_name]
				for chapter in Array.from(Array(book.chapters).keys())
					urls.push "<url><loc>https://bolls.life" + '/' + translation.short_name + '/' + book.bookid + '/' + (chapter + 1) + "/</loc></url>"


		let sitemap0 = '<?xml version="1.0" encoding="utf-8" ?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"><url><loc>https://bolls.life</loc></url><url><loc>https://bolls.life/api/</loc></url><url><loc>https://bolls.life/downloads/</loc></url><url><loc>https://bolls.life/donate/</loc></url>'
		let sitemap1 = '<?xml version="1.0" encoding="utf-8" ?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">'

		for url, index in urls
			if index < 49990
				sitemap0 += url
			else
				sitemap1 += url

		sitemap0 += "</urlset>"
		sitemap1 += "</urlset>"
		console.log sitemap0, sitemap1