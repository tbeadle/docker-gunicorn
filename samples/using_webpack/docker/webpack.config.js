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
	module: {
		loaders: [
			{
				test: /\.vue$/,
				loader: 'vue-loader',
				options: {
					loaders: {
						// Since sass-loader (weirdly) has SCSS as its default parse mode, we map
						// the "scss" and "sass" values for the lang attribute to the right configs here.
						// other preprocessors should work out of the box, no loader config like this nessessary.
						'scss': 'vue-style-loader!css-loader!sass-loader',
						'sass': 'vue-style-loader!css-loader!sass-loader?indentedSyntax'
					}
					// other vue-loader options go here
				}
			},
			{
				test: /\.js$/,
				loader: 'babel-loader',
				exclude: /node_modules/,
				query: {
					presets: ['es2015'],
				},
			},
		],
	},
	resolve: {
		alias: {
			'vue$': 'vue/dist/vue.common.js',
		},
	},
	resolveLoader: {
		root: '/node_modules',
	},
}
