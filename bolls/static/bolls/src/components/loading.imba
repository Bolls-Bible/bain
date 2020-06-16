export tag Load
	prop genesis
	prop period

	def build
		@genesis = Date.now
		@period = 2700

	def mount
		schedule(raf: yes)

	def scale delay
		return Math.cos(((Date.now - @genesis - delay) / @period + 0.25)*2*Math.PI) + 2

	def translateX delay
		return 64 * Math.cos(((Date.now - @genesis - delay) / @period)*2*Math.PI)

	def translateY delay
		return 32 * Math.sin(((Date.now - @genesis - delay) / @period)*2*Math.PI)

	def rotate delay
		return Math.floor(((Date.now - @genesis - delay) / @period) * 360 - 270)


	def render
		<self>
			<div css:transform="scale({scale(2400)}) translateX({translateX(2400)}px) translateY({translateY(2400)}px)">
				<svg:svg
						css:transform="rotateY({rotate(2400)}deg)"
						xmlns="http://www.w3.org/2000/svg"
						viewBox="0 0 20 20"
					>
					<svg:title> "loading animation"
					<svg:path d="M5.33 12.77A4 4 0 1 1 3 5.13V5a4 4 0 0 1 5.71-3.62 3.5 3.5 0 0 1 6.26 1.66 2.5 2.5 0 0 1 2 2.08 4 4 0 1 1-2.7 7.49A5.02 5.02 0 0 1 12 14.58V18l2 1v1H6v-1l2-1v-3l-2.67-2.23zM5 10l3 3v-3H5z">
			<div css:transform="scale({scale(2100)}) translateX({translateX(2100)}px) translateY({translateY(2100)}px)">
				<svg:svg
						css:transform="rotateY({rotate(2100)}deg)"
						xmlns="http://www.w3.org/2000/svg"
						viewBox="0 0 20 20"
					>
					<svg:title> "loading animation"
					<svg:path d="M0 0l20 8-8 4-2 8z">
			<div css:transform="scale({scale(1800)}) translateX({translateX(1800)}px) translateY({translateY(1800)}px)">
				<svg:svg
						css:transform="rotateY({rotate(1800)}deg)"
						xmlns="http://www.w3.org/2000/svg"
						viewBox="0 0 20 20"
					>
					<svg:title> "loading animation"
					<svg:path d="M8 1.88V0h2v16h10l-4 4H2l-2-4h8v-2H0v-.26A24.03 24.03 0 0 0 8 1.88zM19.97 14H10v-.36A11.94 11.94 0 0 0 10 .36v-.2A16.01 16.01 0 0 1 19.97 14z">
			<div css:transform="scale({scale(1500)}) translateX({translateX(1500)}px) translateY({translateY(1500)}px)">
				<svg:svg
						css:transform="rotateY({rotate(1500)}deg)"
						xmlns="http://www.w3.org/2000/svg"
						viewBox="0 0 20 20"
					>
					<svg:title> "loading animation"
					<svg:path d="M8.4 12H2.8L1 15H0V5h1l1.8 3h5.6L6 0h2l4.8 8H18a2 2 0 1 1 0 4h-5.2L8 20H6l2.4-8z">
			<div css:transform="scale({scale(1200)}) translateX({translateX(1200)}px) translateY({translateY(1200)}px)">
				<svg:svg
						css:transform="rotateY({rotate(1200)}deg)"
						xmlns="http://www.w3.org/2000/svg"
						viewBox="0 0 20 20"
					>
					<svg:title> "loading animation"
					<svg:path d="M10 20a10 10 0 1 1 0-20 10 10 0 0 1 0 20zm2-2.25a8 8 0 0 0 4-2.46V9a2 2 0 0 1-2-2V3.07a7.95 7.95 0 0 0-3-1V3a2 2 0 0 1-2 2v1a2 2 0 0 1-2 2v2h3a2 2 0 0 1 2 2v5.75zm-4 0V15a2 2 0 0 1-2-2v-1h-.5A1.5 1.5 0 0 1 4 10.5V8H2.25A8.01 8.01 0 0 0 8 17.75z">
			<div css:transform="scale({scale(900)}) translateX({translateX(900)}px) translateY({translateY(900)}px)">
				<svg:svg
						css:transform="rotateY({rotate(900)}deg)"
						xmlns="http://www.w3.org/2000/svg"
						viewBox="0 0 20 20"
					>
					<svg:title> "loading animation"
					<svg:path d="M20.5 6c-2.61.7-5.67 1-8.5 1s-5.89-.3-8.5-1L3 8c1.86.5 4 .83 6 1v13h2v-6h2v6h2V9c2-.17 4.14-.5 6-1l-.5-2zM12 6c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2z">
			<div css:transform="scale({scale(600)}) translateX({translateX(600)}px) translateY({translateY(600)}px)">
				<svg:svg
						xmlns="http://www.w3.org/2000/svg"
						css:transform="rotateY({rotate(600)}deg)"
						viewBox="0 0 24 24"
					>
					<svg:title> "loading animation"
					<svg:path d="M10 20a10 10 0 1 1 0-20 10 10 0 0 1 0 20zM7.88 7.88l-3.54 7.78 7.78-3.54 3.54-7.78-7.78 3.54zM10 11a1 1 0 1 1 0-2 1 1 0 0 1 0 2z">
			<div css:transform="scale({scale(300)}) translateX({translateX(300)}px) translateY({translateY(300)}px)">
				<svg:svg
						css:transform="rotateY({rotate(300)}deg)"
						xmlns="http://www.w3.org/2000/svg"
						viewBox="0 0 20 20"
					>
					<svg:title> "loading animation"
					<svg:path d="M10 14a4 4 0 1 1 0-8 4 4 0 0 1 0 8zM9 1a1 1 0 1 1 2 0v2a1 1 0 1 1-2 0V1zm6.65 1.94a1 1 0 1 1 1.41 1.41l-1.4 1.4a1 1 0 1 1-1.41-1.41l1.4-1.4zM18.99 9a1 1 0 1 1 0 2h-1.98a1 1 0 1 1 0-2h1.98zm-1.93 6.65a1 1 0 1 1-1.41 1.41l-1.4-1.4a1 1 0 1 1 1.41-1.41l1.4 1.4zM11 18.99a1 1 0 1 1-2 0v-1.98a1 1 0 1 1 2 0v1.98zm-6.65-1.93a1 1 0 1 1-1.41-1.41l1.4-1.4a1 1 0 1 1 1.41 1.41l-1.4 1.4zM1.01 11a1 1 0 1 1 0-2h1.98a1 1 0 1 1 0 2H1.01zm1.93-6.65a1 1 0 1 1 1.41-1.41l1.4 1.4a1 1 0 1 1-1.41 1.41l-1.4-1.4z">
			<div css:transform="scale({scale(0)}) translateX({translateX(0)}px) translateY({translateY(0)}px)">
				<svg:svg
						css:transform="rotateY({rotate(0)}deg)"
						xmlns="http://www.w3.org/2000/svg"
						viewBox="0 0 20 20" width="913.059px" height="913.059px" viewBox="0 0 913.059 913.059"
					>
					<svg:title> "loading animation"
					<svg:path d="M789.581,777.485c62.73-62.73,103.652-139.002,122.785-219.406c5.479-23.031-22.826-38.58-39.524-21.799   c-0.205,0.207-0.41,0.412-0.615,0.617c-139.57,139.57-367.531,136.879-503.693-8.072   c-128.37-136.658-126.685-348.817,3.673-483.579c1.644-1.699,3.3-3.378,4.97-5.037c16.744-16.635,1.094-44.811-21.869-39.354   c-79.689,18.938-155.326,59.276-217.75,121.035c-182.518,180.576-183.546,473.345-2.245,655.14   C315.821,958.032,608.883,958.182,789.581,777.485z">