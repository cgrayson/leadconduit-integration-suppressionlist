const express    = require('express'),
      { json }   = require('body-parser'),
      auth       = require('./auth'),
      credential = require('./credential'),
      ensureList = require('./ensure-list');


module.exports =
  express.Router()
         .use(json())
         .use('/credential', credential)
         .use(auth)
         .use('/lists', lists)
         .use('/ensure_list', ensureList);