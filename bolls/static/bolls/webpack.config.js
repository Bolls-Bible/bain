module.exports = {
	module: {
		rules: [{
			test: /\.imba$/,
			use: 'imba/loader'
		},]
	},
	resolve: {
		extensions: [".imba", ".js", ".json"]
	},
	entry: "./src/index.imba",
	output: {
		path: __dirname + '/dist',
		filename: "index.js"
	}
}