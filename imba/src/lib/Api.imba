class API
	baseUrl = ''
	# baseUrl = 'http://bolls.local'
	# baseUrl = 'https://bolls.life'

	def getJson pathname\string
		const url = baseUrl + pathname
		const response = await window.fetch(url)
		return response.json()

	def fetch pathname\string, method\string, data\object = undefined
		if method == 'GET'
			const url = baseUrl + pathname
			return window.fetch(url)

		const url = baseUrl + pathname
		return window.fetch(url, {
			method: method,
			cache: "no-cache",
			headers: {
				'Content-Type': 'application/json',
				'X-CSRFToken': get_cookie('csrftoken')
			},
			credentials: 'include'
			body: JSON.stringify(data)
		})
	
	def requestJson pathname\string, method\string, data\object = {}
		const response = await self.fetch(pathname, method, data)
		return response.json()

	def post pathname\string, data\object = {}
		requestJson(pathname, 'POST', data)
	
	def put pathname\string, data\object = {}
		requestJson(pathname, 'PUT', data)
	
	def delete pathname\string, data\object = {}
		requestJson(pathname, 'DELETE', data)

	def get_cookie name\string
		let cookieValue = null
		if document.cookie && document.cookie !== ''
			let cookies = document.cookie.split(';')
			for i in cookies
				let cookie = i.trim()
				if (cookie.substring(0, name.length + 1) === (name + '='))
					cookieValue = window.decodeURIComponent(cookie.substring(name.length + 1))
					break
		return cookieValue

const api = new API()

export default api
