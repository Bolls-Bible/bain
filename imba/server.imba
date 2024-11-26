import index from './index.html'
import express from 'express'
const app = express!
const port = process.env.PORT or 3000
const print = console.log

app.use(express.static('dist/public',maxAge:'1m'))

app.get '/sw/:path' do(req, res)
	# because these are js files, they aren't served by express.static automatically
	res.sendFile `{__dirname}/public/sw/{req.params.path}`

app.get '/site.webmanifest' do(req, res)
	res.sendFile `{__dirname}/public/site.webmanifest`

app.get '/service.worker.js' do(req, res)
	res.sendFile `{__dirname}/public/sw/service.worker.js`

app.get '*' do(req, res)
	print req.url
	res.send index.body

imba.serve app.listen(port)
