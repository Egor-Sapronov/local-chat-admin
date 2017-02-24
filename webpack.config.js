var path = require("path")
var webpack = require('webpack');

module.exports = {
  entry: {
    app: [
      './src/index.js'
    ]
  },
  output: {
    path: path.resolve(__dirname + '/dist'),
    filename: '[name].js',
  },
  module: {
    rules: [
      {
        test:    /\.html$/,
        exclude: /node_modules/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name].[ext]'
            }
          }
        ],
      },
      {
        test:    /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use:  [
          {
            loader: 'elm-webpack-loader',
            options: {
              debug: false
            }
          }
        ],
      },
    ],
    noParse: /\.elm$/
  },
  plugins: [
    new webpack.DefinePlugin({
      'process.env.API_KEY': JSON.stringify(process.env.API_KEY),
      'process.env.AUTH_DOMAIN': JSON.stringify(process.env.AUTH_DOMAIN),
      'process.env.DATABASE_URL': JSON.stringify(process.env.DATABASE_URL),
      'process.env.STORAGE_BUCKET': JSON.stringify(process.env.STORAGE_BUCKET),
  }),
],
  devServer: {
    inline: true,
    stats: { colors: true },
  },
};
