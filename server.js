const express = require('express'),
      session = require('express-session'),
      ui      = require('./lib/ui');


express()
  .use(session({ secret: 'dev', resave: false, saveUninitialized: true }))
  .use(ui)
  .listen(8080, () => {
    console.log('listening on 8080');
  });

