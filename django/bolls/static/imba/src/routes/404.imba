export tag NotFound
	eyes = []
	mx = null
	my = null

	def can_place_eye(new_eye)
		eyes.every do |eye|
			eye_distance(eye, new_eye) >= eye.sz + new_eye.sz + 5

	get randomColor
		let h = Math.random() * 360
		let s = Math.round(50 + Math.random() * 50)
		let l = Math.round(30 + Math.random() * 40)
		"hsl({h}, {s}%, {l}%)"

	def setup
		mx = Math.random() * window.innerWidth
		my = Math.random() * window.innerHeight
		for i in [1 .. 1000]
			let sz = 20 + Math.random() * 60
			let x = sz + Math.random() * (window.innerWidth - 2 * sz)
			let y = sz + Math.random() * (window.innerHeight - 2 * sz)
			let r = (0.35 + Math.random() * 0.6) * sz
			let new_eye = {x: x, y: y, sz: sz, r: r, color: randomColor}
			if can_place_eye(new_eye)
				eyes.push(new_eye)

	def onmousemove(event)
		let rect = $eyes.getBoundingClientRect()
		mx = event.pageX - rect.x
		my = event.pageY - rect.y

	def eye_distance(eye1, eye2)
		let dx = eye1.x - eye2.x
		let dy = eye1.y - eye2.y
		Math.sqrt((dx * dx) + (dy * dy))

	count = 0
	<self @mousemove=onmousemove>
		<svg$eyes [h:100vh w:100vw d:block bgc:warmer9]>
			for eye in eyes
				let max_eye_movement = (eye.sz - eye.r) * 0.9
				let rx = eye.x
				let ry = eye.y
				if mx != null && my != null
					let dx = mx - eye.x
					let dy = my - eye.y
					let dl = Math.sqrt(dx*dx + dy*dy)
					if dl > max_eye_movement
						dx = max_eye_movement * dx/dl
						dy = max_eye_movement * dy/dl
					rx += dx
					ry += dy
		
				<g>
					<circle[fill:cooler2] cx=(eye.x) cy=(eye.y) r=(eye.sz)>
					<circle cx=(rx) cy=(ry) r=(eye.r) fill=(eye.color)>
					<circle fill="black" cx=(rx) cy=(ry) r=(eye.r * Math.pow(eye.r / eye.sz, 2))>
		
		<main>
			<h1[mb:1rem]>
				"404 - Page Not Found"
			<a href="/" [c:blue2 @hover:blue4 td:underline]>
				"Go Back Home"


	css
		h:100vh
		w:100vw
		of:hidden
	
	css main
		pos:fixed top:50% left:50% transform:translate(-50%, -50%)
		c:cooler1 ta:center

		padding: 1rem

		background: warmer9/50;
		border-radius: 16px;
		box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1);
		backdrop-filter: blur(6.4px);
		-webkit-backdrop-filter: blur(6.4px);
		border: 1px solid  warmer9/70;
		


imba.mount <NotFound>
