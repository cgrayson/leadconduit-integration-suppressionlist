const express = require('express'),
      path    = require('path'),
      webpack = require('./webpack'),
      api     = require('./api');


module.exports =
  express.Router()
         .use(express.static(path.join(__dirname, '/public')))
         .use(webpack)
         .use(api);
