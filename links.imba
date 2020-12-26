# To fully regenerate the sitemap.
		makeSiteMap()

	def makeSiteMap
		let sitemap = '<?xml version="1.0" encoding="utf-8" ?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"><url><loc>https://bolls.life</loc><lastmod>2020-11-26</lastmod></url><url><loc>https://bolls.life/api/</loc><lastmod>2020-11-26</lastmod></url><url><loc>https://bolls.life/downloads/</loc><lastmod>2020-11-26</lastmod></url>'
		for translation in translations
			for book in BOOKS[translation.short_name]
				for chapter in Array.from(Array(book.chapters).keys())
					sitemap += "<url><loc>https://bolls.life" + '/' + translation.short_name + '/' + book.bookid + '/' + (chapter + 1) + "/</loc><lastmod>2020-11-26</lastmod></url>"
		sitemap += "</urlset>"
		console.log sitemap


# To create urls for a new single translation
	# 	makeSiteMap()

	# def makeSiteMap
	# 	let sitemap = ''
	# 	# for translation in translations
	# 	for book in BOOKS['SUV']
	# 		for chapter in Array.from(Array(book.chapters).keys())
	# 			sitemap += "<url><loc>https://bolls.life" + '/SUV/' + book.bookid + '/' + (chapter + 1) + "/</loc><lastmod>2020-11-26</lastmod></url>"
	# 	sitemap += "</urlset>"
	# 	console.log sitemap