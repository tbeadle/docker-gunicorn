var webpack = require('webpack');
var BundleTracker = require('webpack-bundle-tracker');

module.exports = {
	context: __dirname + '/../',
	entry: {
		'main': './app/static/app/js/main',
	},
	output: {
		path: '/static/bundles/',
		filename: '[name]-[hash].js',
	},
	plugins: [
		new BundleTracker({
			path: '/tmp',
			filename: 'webpack-stats.json'
		}),
	],
	loaders: [
		{
			test: /\.js$/,
			exclude: /node_modules/,
			loader: 'babel-loader',
			query: {
				presets: ['es2015'],
			},
		},
	],
	resolve: {
		extensions: ['', '.js'],
	},
}
