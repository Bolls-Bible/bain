import index from './index.html'
import express  from 'express'
import type {Request, Response} from 'express'
const app = express!
const port = process.env.PORT or 3000

app.use(express.static('dist/public',maxAge:'1m'))

app.get '/sw/:path' do(req, res)
	# because these are js files, they aren't served by express.static automatically
	res.sendFile `{__dirname}/public/sw/{req.params.path}`

app.get '/site.webmanifest' do(req, res)
	res.sendFile `{__dirname}/public/site.webmanifest`

app.get '/service.worker.js' do(req, res)
	res.sendFile `{__dirname}/public/sw/service.worker.js`


def clean_up_html raw_html\string
	// first remove all strong tags like this "<S>(.*?)</S>"
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
		return ''

def getChapterVerses translation\string, book\number, chapter\number
	const response = await fetch "{process.env.API_URL}/get-chapter/{translation}/{book}/{chapter}/"
	return response.json()

def setDescription html\string, description\string
	return html.replace('<!-- description -->', `<meta name="description" content="{description}"/>`)
		.replace('<!-- og-description -->', `<meta property="og:description" content="{description}"/>`)


def preloadChapter req\Request<{
	translation:string;
	book:string;
	chapter:string;
	verseRange:string;
	}>, res\Response<any, Record<string, any>, number>
	try
		let {translation, book, chapter, verseRange } = req.params
		let verses = await getChapterVerses translation, Number(book), Number(chapter)

		let [verse, endVerse] = verseRange..split('-') ?? []

		let description = get_description verses, Number(verse), Number(endVerse ?? 0)
		console.log(description)
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
		res.send index.body

app.get '/:translation/:book/:chapter', preloadChapter
app.get '/international/:translation/:book/:chapter', preloadChapter

app.get '/:translation/:book/:chapter/:verseRange', preloadChapter
app.get '/international/:translation/:book/:chapter/:verseRange', preloadChapter


app.get '*' do(req, res)
	let result = index.body.replace('<!-- og-url -->', `<meta property="og:url" content="https://bolls.life/"/>`)
		.replace('<!-- canonical -->', `<link rel="canonical" href="https://bolls.life/"/>`)
		.replace('<!-- description -->', `<meta name="description" content="{"A web app for reading the Bible with full emphasis on the God's Word only. Sola scriptura"}"/>`)
		.replace('<!-- og-description -->', `<meta property="og:description" content="{"Read God's Word with a deep understanding of His design. Bible elevates your soul with rapid ascension to calm, safety and more."}"/>`)
		.replace('<!-- og-url -->', `<meta property="og:url" content="https://bolls.life/"/>`)
		.replace('<!-- script -->', "")

	res.send result

imba.serve app.listen(port)
