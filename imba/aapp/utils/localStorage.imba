export def setValue key, value
	localStorage.setItem(key, JSON.stringify(value));

export def getValue key
	try
		JSON.parse(localStorage.getItem(key))
	catch e
		# console.warn e, localStorage.getItem(key)
		localStorage.getItem(key)

export def deleteValue key
	localStorage.removeItem(key)
