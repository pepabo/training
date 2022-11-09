const path = require('path');
const webpack = require('webpack');
const { WebpackManifestPlugin } = require('webpack-manifest-plugin');

module.exports = {
  entry: path.resolve(__dirname, 'app/javascript/packs/application.js'),

  output: {
    filename: '[name].[contenthash].js',
    path: path.resolve(__dirname, 'public/packs'),
    clean: true,
  },

  module: {
    rules: [
      {
        test: /(\.m?js|\.tsx?)$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: 'babel-loader',
        },
      },
    ],
  },

  resolve: {
    modules: ['node_modules', path.resolve(__dirname, 'app/javascript')],
    extensions: ['.js', '.jsx', '.ts', '.tsx', '.json', '.wasm'],
  },

  plugins: [
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
    }),
    new WebpackManifestPlugin({
      publicPath: '/packs/',
    }),
  ],
};
