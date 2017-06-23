const path = require('path');

module.exports = {
  context: path.join(__dirname, 'public'),
  entry: './app/index.js',
  output: {
    path: path.join(__dirname, 'public'),
    publicPath: '/dist',
    filename: 'index.js'
  }
};
