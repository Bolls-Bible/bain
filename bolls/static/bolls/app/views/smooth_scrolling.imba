# first add raf shim
# http://www.paulirish.com/2011/requestanimationframe-for-smart-animating/

# def scrollToY(scrollblock, scrollTargetY)
export def scrollToY(scrollblock, scrollTargetY)
	# scrollTargetY: the target scrollY property of the window
	# speed: time in pixels per second
	# easing: easing equation to use

	# If transitions are disables -- don't smooth the scrolling
	if document.firstElementChild.dataset["transitions"] == 'false' or scrollTargetY == scrollblock.scrollTop
		scrollblock.scrollTo(0, scrollTargetY)
		return no

	let scrollY = scrollblock.scrollTop
	scrollTargetY = scrollTargetY || 0
	let speed = 300
	let currentTime = 0

	# min time 1, max time 1.25 seconds
	let time = Math.max(1, Math.min(Math.abs(scrollY - scrollTargetY) / speed, 1.25));

	# easing equations from https://github.com/danro/easing-js/blob/master/easing.js
	# let PI_D2 = Math.PI / 2

	def easing(pos)
		if (pos /= 0.5) < 1
			return 0.5 * Math.pow(pos, 5)
		return 0.5 * (Math.pow(pos - 2, 5) + 2)

	# add animation loop
	def tick
		currentTime += 1 / 60

		let p = currentTime / time
		let t = easing(p)

		if p < 1
			requestAnimationFrame(tick)
			scrollblock.scrollTo(0, scrollY + (scrollTargetY - scrollY) * t)
		else
			scrollblock.scrollTo(0, scrollTargetY)
	tick()
	return time
