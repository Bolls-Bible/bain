import index from './index.html'
import notFound from './not-found.html'
import express  from 'express'
import type {Request, Response} from 'express'
import { isNumber, getBookId } from './utils/books'
import { translationNames } from './src/dataindex'

const app = express!
const port = process.env.PORT or 3000

app.use(express.static('dist/public', maxAge:'1m'))

# actually handled on nginx level, shouldn't get here
def serviceWorker req, res
	res.sendFile `{__dirname}/public/sw/service.worker.js`

# Sadly I foolishly renamed it a few times 🤦‍♂️
app.get '/service.worker.js', serviceWorker
app.get '/service-worker.js', serviceWorker
app.get '/sw.js', serviceWorker

def clean_up_html raw_html\string
	// first remove all strong tags
	raw_html = raw_html.replace(/<S>(.*?)<\/S>/g, '')
	// then remove all other tags
	return raw_html.replace(/<.*?>|&([a-z0-9]+|#[0-9]{1,6}|#x[0-9a-f]{1,6});/g, '')

def get_description verses, verse\number, endVerse\number
	if verse <= verses.length and verses.length > 0
		i = 0
		let description = verses[verse - 1]["text"]
		if endVerse > 0 and endVerse - verse != 0
			for i in [verse .. endVerse]
				if i < verses.length
					description += " " + verses[i]["text"]
		return clean_up_html(description)
	else
		return "Read God's Word with a deep understanding of His design. Bible elevates your soul with rapid ascension to calm, safety and more."

def getChapterVerses translation\string, book\number|string, chapter\number
	const response = await fetch "{process.env.API_URL}/get-chapter/{translation}/{book}/{chapter}/"
	return response.json()

def setDescription html\string, description\string
	return html.replace('<!-- description -->', `<meta name="description" content="{description}"/>`)
		.replace('<!-- og-description -->', `<meta property="og:description" content="{description}"/>`)

const defaultIndex = index.body.replace('<!-- og-url -->', `<meta property="og:url" content="https://bolls.life/"/>`)
		.replace('<!-- canonical -->', `<link rel="canonical" href="https://bolls.life/"/>`)
		.replace('<!-- description -->', `<meta name="description" content="{"A web app for reading the Bible with full emphasis on the God's Word only. Sola scriptura"}"/>`)
		.replace('<!-- og-description -->', `<meta property="og:description" content="{"Read God's Word with a deep understanding of His design. Bible elevates your soul with rapid ascension to calm, safety and more."}"/>`)
		.replace('<!-- og-url -->', `<meta property="og:url" content="https://bolls.life/"/>`)
		.replace('<!-- script -->', "")

def preloadChapter req\Request<{
	translation:string;
	book:string;
	chapter:string;
	verseRange:string;
	}>, res\Response<any, Record<string, any>, number>
	try
		let { translation, book, chapter, verseRange } = req.params
		if !translationNames[translation]
			return res.redirect(404, '/')

		const isBookANumber = isNumber(book)
		book = getBookId(translation, book)

		if !isBookANumber and isNumber(book)
			return res.redirect(307, `/{translation}/{book}/{chapter}/{verseRange}`)

		let verses = await getChapterVerses translation, book, Number(chapter)

		let [verse, endVerse] = verseRange..split('-') ?? []

		let description = get_description verses, Number(verse ?? 1), Number(endVerse ?? verse ? 0 : 3)
		let result = setDescription index.body, description

		result = result.replace('<!-- og-url -->', `<meta property="og:url" content="https://bolls.life/{translation}/{book}/{chapter}/"/>`)
		result = result.replace('<!-- canonical -->', `<link rel="canonical" href="https://bolls.life/{translation}/{book}/{chapter}/"/>`)

		result = result.replace('<!-- script -->', `<script>
			window.translation = "{ translation }";
			window.book = { book };
			window.chapter = { chapter };
			window.verse = { verse };
			window.endVerse = { endVerse };
			window.verses = { JSON.stringify(verses) };
		</script>`)

		res.send result
	catch error
		res.send defaultIndex

app.get '/:translation/:book/:chapter', preloadChapter
app.get '/international/:translation/:book/:chapter', preloadChapter

app.get '/:translation/:book/:chapter/:verseRange', preloadChapter
app.get '/international/:translation/:book/:chapter/:verseRange', preloadChapter


app.get ['/', '/downloads', '/profile', '/donate'] do(req, res)
	res.send defaultIndex

# 404 handler
app.get '{*splat}', do(req, res)
	res.status(404).send notFound.body

imba.serve app.listen(port)
