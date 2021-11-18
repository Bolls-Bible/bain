# To fully regenerate the sitemap.


		makeSiteMap()

	def makeSiteMap
		let urls = []
		for translation in translations
			for book in BOOKS[translation.short_name]
				for chapter in Array.from(Array(book.chapters).keys())
					urls.push "<url><loc>https://bolls.life" + '/' + translation.short_name + '/' + book.bookid + '/' + (chapter + 1) + "/</loc><lastmod>2020-11-26</lastmod></url>"


		let sitemap0 = '<?xml version="1.0" encoding="utf-8" ?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"><url><loc>https://bolls.life</loc><lastmod>2020-11-26</lastmod></url><url><loc>https://bolls.life/api/</loc><lastmod>2020-11-26</lastmod></url><url><loc>https://bolls.life/downloads/</loc><lastmod>2020-11-26</lastmod></url>'
		let sitemap1 = sitemap0

		for url, index in urls
			if index < 50000
				sitemap0 += url
			else
				sitemap1 += url

		sitemap0 += "</urlset>"
		sitemap1 += "</urlset>"
		console.log sitemap0, sitemap1, urls
