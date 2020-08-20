const path = require('path')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')

module.exports = (env, { mode } = {}) => ({
  entry: {
    app: mode === 'development' ? './src/dev.js' : './src/index.js'
  },
  output: {
    path: mode === 'development' ? path.resolve(__dirname, 'dev') : path.resolve(__dirname, 'dist'),
    publicPath: mode === 'development' ? path.resolve(__dirname, 'dev') : path.resolve(__dirname, 'dist'),
    filename: '[name].js'
  },
  plugins: [new MiniCssExtractPlugin()],
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              [
                '@babel/preset-env',
                {
                  useBuiltIns: 'usage',
                  corejs: 3
                }
              ]
            ]
          }
        }
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: [
          { loader: 'elm-hot-webpack-loader' },
          {
            loader: 'elm-webpack-loader',
            options: { debug: mode === 'development', optimize: mode !== 'development' }
          }
        ]
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader', 'resolve-url-loader']
      }
    ]
  },
  devServer: {
    contentBase: mode === 'development' ? path.resolve(__dirname, 'dev') : path.resolve(__dirname, 'dist'),
    writeToDisk: true
  }
})
